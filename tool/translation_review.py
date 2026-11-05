#!/usr/bin/env python3
"""Spreadsheet round trip for proof-reading translations.

  translation_review.py export <lang> [-o file.xlsx] [--l10n-dir DIR]
  translation_review.py import <lang> <file.xlsx> [--dry-run] [--l10n-dir DIR]
  translation_review.py selftest [--l10n-dir DIR]

A native speaker reads the translation in a table and writes corrections into
one column; the import writes them back into lib/l10n/app_<lang>.arb.

Messages are ICU (placeholders, plural, select). Each message is split into
its editable *parts* (text before a block, every variant, text after), so a
reviewer never sees ICU syntax. Parts are located by character offsets in the
original string, which makes the way back exact: an untouched part is never
re-serialised, so an import without corrections leaves the file byte-identical.

Only third-party package: openpyxl.
"""

import argparse
import json
import os
import re
import shutil
import sys
import tempfile
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Alignment, Font, PatternFill, Protection
from openpyxl.utils import get_column_letter

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_L10N = ROOT / "lib" / "l10n"
DEFAULT_OUT = ROOT / "build" / "translation_review"
TEMPLATE_LANG = "de"
BRIDGE_LANG = "en"
IDENT = r"[A-Za-z_][A-Za-z0-9_]*"


class ReviewError(Exception):
    pass


# --------------------------------------------------------------------------
# ICU parsing
# --------------------------------------------------------------------------
# A sequence is a list of nodes:
#   ("text", start, end)                      text and simple {placeholders}
#   ("block", arg, kind, [(selector, seq)])   plural / select
# start/end are offsets into the whole message string.


class _Parser:
    def __init__(self, s):
        self.s = s
        self.i = 0

    def fail(self, msg):
        raise ReviewError(f"ICU: {msg} (Position {self.i} in {self.s!r})")

    def ws(self):
        while self.i < len(self.s) and self.s[self.i].isspace():
            self.i += 1

    def ident(self):
        m = re.compile(IDENT).match(self.s, self.i)
        if not m:
            self.fail("Name erwartet")
        self.i = m.end()
        return m.group()

    def seq(self, nested):
        s = self.s
        nodes = []
        start = self.i
        while True:
            if self.i >= len(s):
                if nested:
                    self.fail("'}' fehlt")
                break
            c = s[self.i]
            if c == "'":
                if s.startswith("''", self.i):
                    self.i += 2
                elif self.i + 1 < len(s) and s[self.i + 1] in "{}":
                    j = s.find("'", self.i + 1)
                    if j < 0:
                        self.fail("Anführungszeichen ' vor Klammer nicht geschlossen")
                    self.i = j + 1
                else:
                    self.i += 1
            elif c == "}":
                if nested:
                    break
                self.fail("unerwartetes '}'")
            elif c == "{":
                save = self.i
                self.i += 1
                self.ws()
                name = self.ident()
                self.ws()
                if self.i < len(s) and s[self.i] == "}":
                    self.i += 1  # simple placeholder: stays inside the text run
                    continue
                if self.i >= len(s) or s[self.i] != ",":
                    self.fail("',' oder '}' erwartet")
                self.i += 1
                self.ws()
                kind = self.ident()
                if kind not in ("plural", "select"):
                    self.fail(f"Typ {kind!r} wird nicht unterstützt")
                self.ws()
                if self.i >= len(s) or s[self.i] != ",":
                    self.fail("',' erwartet")
                self.i += 1
                variants = []
                while True:
                    self.ws()
                    if self.i < len(s) and s[self.i] == "}":
                        self.i += 1
                        break
                    m = re.compile(r"[^\s{}]+").match(s, self.i)
                    if not m:
                        self.fail("Variante erwartet")
                    sel = m.group()
                    self.i = m.end()
                    self.ws()
                    if self.i >= len(s) or s[self.i] != "{":
                        self.fail("'{' nach Variante erwartet")
                    self.i += 1
                    sub = self.seq(True)
                    self.i += 1  # closing }
                    variants.append((sel, sub))
                if not variants or variants[-1][0] != "other":
                    self.fail(f"Block {name!r} braucht 'other' als letzte Variante")
                if save > start:
                    nodes.append(("text", start, save))
                nodes.append(("block", name, kind, variants))
                start = self.i
                continue
            else:
                self.i += 1
        if self.i > start:
            nodes.append(("text", start, self.i))
        return nodes


def parse_icu(s):
    p = _Parser(s)
    nodes = p.seq(False)
    return nodes


def skeleton(nodes):
    out = []
    for n in nodes:
        if n[0] == "text":
            out.append("T")
        else:
            out.append((n[1], n[2], tuple((sel, skeleton(sub)) for sel, sub in n[3])))
    return out


def placeholders(text):
    """Multiset (sorted list) of simple {name} placeholders outside quotes."""
    return sorted(re.findall(r"\{\s*(" + IDENT + r")\s*\}", strip_quoted(text)))


def strip_quoted(text):
    out = []
    i = 0
    while i < len(text):
        if text.startswith("''", i):
            i += 2
        elif text[i] == "'" and i + 1 < len(text) and text[i + 1] in "{}":
            j = text.find("'", i + 1)
            i = len(text) if j < 0 else j + 1
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


def unquote(text):
    out = []
    i = 0
    while i < len(text):
        if text.startswith("''", i):
            out.append("'")
            i += 2
        elif text[i] == "'" and i + 1 < len(text) and text[i + 1] in "{}":
            j = text.find("'", i + 1)
            if j < 0:
                out.append(text[i + 1:])
                break
            out.append(text[i + 1:j])
            i = j + 1
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


# --------------------------------------------------------------------------
# Parts
# --------------------------------------------------------------------------


class Part:
    def __init__(self, path, start, end, label, text):
        self.path = path  # e.g. "1/other/0"
        self.start = start
        self.end = end
        self.label = label
        self.text = text


def count_blocks(nodes):
    n = 0
    for node in nodes:
        if node[0] == "block":
            n += 1
            for _, sub in node[3]:
                n += count_blocks(sub)
    return n


def plural_selector_label(sel, arg, tr, show_arg):
    a = f" ({arg})" if show_arg else ""
    if sel.startswith("="):
        return tr["if_eq"].format(n=sel[1:]) + a
    if sel == "other":
        return tr["other"] + a
    return tr["if_cat"].format(cat=sel) + a


def select_selector_label(sel, arg, tr, show_arg):
    if sel == "other":
        return tr["other_sel"] + (f" ({arg})" if show_arg else "")
    return f"{arg} = {sel}"


def collect_parts(s, tr):
    nodes = parse_icu(s)
    show_arg = count_blocks(nodes) > 1
    parts = []

    def walk(seq, prefix, labels):
        has_blocks = any(n[0] == "block" for n in seq)
        seen_block = False
        last_text = max((i for i, n in enumerate(seq) if n[0] == "text"), default=-1)
        for idx, n in enumerate(seq):
            path = prefix + [str(idx)]
            if n[0] == "text":
                raw = s[n[1]:n[2]]
                if not raw.strip():
                    continue
                parts_labels = list(labels)
                if has_blocks:
                    if not seen_block:
                        pos = tr["before"]
                    elif idx == len(seq) - 1:
                        pos = tr["after"]
                    else:
                        pos = tr["between"]
                    parts_labels.append(pos)
                label = " > ".join(parts_labels) if parts_labels else tr["message"]
                parts.append(Part("/".join(path), n[1], n[2], label, raw))
            else:
                seen_block = True
                _, arg, kind, variants = n
                for sel, sub in variants:
                    if kind == "plural":
                        lab = plural_selector_label(sel, arg, tr, show_arg)
                    else:
                        lab = select_selector_label(sel, arg, tr, show_arg)
                    walk(sub, path + [sel], labels + [lab])

    walk(nodes, [], [])
    return parts


# --------------------------------------------------------------------------
# Readable rendering of a whole message
# --------------------------------------------------------------------------

MAX_COMBOS = 24


def plural_example(sel, explicit):
    if sel.startswith("="):
        return int(sel[1:]) if sel[1:].isdigit() else 5
    table = {"zero": 0, "one": 1, "two": 2, "few": 3, "many": 5}
    if sel in table:
        return table[sel]
    n = 5
    while n in explicit:
        n += 1
    return n


def render(s, nodes):
    """List of (labels, text) combinations, capped at MAX_COMBOS."""

    def go(seq, subst):
        results = [([], "")]
        for n in seq:
            if n[0] == "text":
                t = unquote(s[n[1]:n[2]])
                for name, val in subst.items():
                    t = re.sub(r"\{\s*" + re.escape(name) + r"\s*\}", str(val), t)
                results = [(l, x + t) for l, x in results]
            else:
                _, arg, kind, variants = n
                explicit = {int(v[0][1:]) for v in variants if v[0][1:].isdigit() and v[0].startswith("=")}
                new = []
                for labels, text in results:
                    for sel, sub in variants:
                        if kind == "plural":
                            ex = plural_example(sel, explicit)
                            lab = str(ex)
                            sub_subst = dict(subst, **{arg: ex})
                        else:
                            lab = sel if sel != "other" else "…"
                            sub_subst = subst
                        for l2, t2 in go(sub, sub_subst):
                            new.append((labels + [lab] + l2, text + t2))
                            if len(new) >= MAX_COMBOS:
                                break
                        if len(new) >= MAX_COMBOS:
                            break
                    if len(new) >= MAX_COMBOS:
                        break
                results = new
        return results

    return go(nodes, {})


def render_text(s):
    nodes = parse_icu(s)
    combos = render(s, nodes)
    if len(combos) == 1 and not combos[0][0]:
        return combos[0][1]
    lines = [(" / ".join(l) + " → " if l else "") + t for l, t in combos]
    if len(combos) >= MAX_COMBOS:
        lines.append("…")
    return "\n".join(lines)


# --------------------------------------------------------------------------
# Texts in the instruction languages
# --------------------------------------------------------------------------

TR = {
    "fr": dict(
        message="message", before="texte avant", between="texte au milieu", after="texte après",
        if_eq="si = {n}", other="autres nombres", if_cat="catégorie {cat}", other_sel="autres cas",
        cols=["N°", "Domaine", "Allemand", "Anglais", "Indication", "Partie", "Traduction actuelle",
              "Correction", "Remarque", "clé", "chemin"],
        sheet_help="Instructions",
        areas=dict(lesson="Leçons", lessons="Leçons (liste)", profile="Profil", profiles="Profils", admin="Espace parents",
                   global_="Statistiques générales", editor="Éditeur", task="Exercice", assignments="Devoirs",
                   assignment="Devoir", duel="Duel", backup="Sauvegarde", result="Résultat", clock="Horloge",
                   stats="Statistiques", group="Groupes", common="Général", practice="Entraînement", range="Zones de nombres",
                   pin="Code PIN", start="Démarrage", reset="Réinitialisation", deadline="Délai", filter="Filtre",
                   sound="Son", pause="Pause", app="Application", settings="Réglages", leaderboard="Classement",
                   money="Argent", place="Valeur de position", recommend="Recommandation"),
        help=[
            "Relecture de la traduction : Mathe-Trainer",
            "",
            "À quoi sert l'application ? C'est une application de mathématiques pour les enfants de 6 à 10 ans (école primaire), utilisée sur tablette.",
            "",
            "Ce qu'il faut faire :",
            "1. Lisez la colonne « Traduction actuelle » ligne par ligne. Les colonnes « Allemand » et « Anglais » donnent le sens et les exemples.",
            "2. Si tout est bon, ne faites rien : une cellule « Correction » vide signifie « c'est bon ».",
            "3. Si quelque chose ne va pas, écrivez le texte corrigé complet de cette partie dans la colonne « Correction ». Remplissez uniquement cette colonne (et « Remarque »). Les autres colonnes sont protégées.",
            "4. Une question ou un doute ? Écrivez-le dans la colonne « Remarque ».",
            "",
            "Règles :",
            "- Gardez tout ce qui est entre accolades, par exemple {n} ou {name}, exactement tel quel : ce sont des espaces réservés que l'application remplace (nombres, prénoms…). Vous pouvez les déplacer dans la phrase, mais ne les traduisez pas et ne les supprimez pas.",
            "- Un message à plusieurs lignes (« si = 1 », « autres nombres »…) est découpé en parties : corrigez chaque partie séparément. La colonne « Allemand » montre le message entier avec des exemples chiffrés.",
            "- Restez court : l'écran est petit et la police très grande.",
            "- Tutoyez les enfants.",
            "- Pour l'apostrophe, utilisez de préférence l'apostrophe typographique ’ (et non '), surtout avant une accolade.",
        ],
    ),
    "es": dict(
        message="mensaje", before="texto antes", between="texto intermedio", after="texto después",
        if_eq="si = {n}", other="otros números", if_cat="categoría {cat}", other_sel="otros casos",
        cols=["N.º", "Área", "Alemán", "Inglés", "Indicación", "Parte", "Traducción actual",
              "Corrección", "Comentario", "clave", "ruta"],
        sheet_help="Instrucciones",
        areas=dict(lesson="Lecciones", lessons="Lecciones (lista)", profile="Perfil", profiles="Perfiles", admin="Zona de padres",
                   global_="Estadísticas generales", editor="Editor", task="Ejercicio", assignments="Tareas",
                   assignment="Tarea", duel="Duelo", backup="Copia de seguridad", result="Resultado", clock="Reloj",
                   stats="Estadísticas", group="Grupos", common="General", practice="Práctica", range="Rangos de números",
                   pin="PIN", start="Inicio", reset="Restablecer", deadline="Plazo", filter="Filtro",
                   sound="Sonido", pause="Pausa", app="Aplicación", settings="Ajustes", leaderboard="Clasificación",
                   money="Dinero", place="Valor posicional", recommend="Recomendación"),
        help=[
            "Revisión de la traducción: Mathe-Trainer",
            "",
            "¿Para qué sirve la aplicación? Es una aplicación de matemáticas para niños de 6 a 10 años (primaria), para usar en una tableta.",
            "",
            "Qué hay que hacer:",
            "1. Lee la columna «Traducción actual» fila por fila. Las columnas «Alemán» e «Inglés» explican el sentido y dan ejemplos.",
            "2. Si todo está bien, no hagas nada: una celda «Corrección» vacía significa «está bien».",
            "3. Si algo no encaja, escribe en la columna «Corrección» el texto corregido completo de esa parte. Rellena solo esa columna (y «Comentario»). Las demás están protegidas.",
            "4. ¿Una pregunta o una duda? Escríbela en la columna «Comentario».",
            "",
            "Reglas:",
            "- Conserva exactamente todo lo que va entre llaves, por ejemplo {n} o {name}: son marcadores que la aplicación sustituye (números, nombres…). Puedes cambiarlos de sitio en la frase, pero no los traduzcas ni los borres.",
            "- Un mensaje con varias líneas («si = 1», «otros números»…) se divide en partes: corrige cada parte por separado. La columna «Alemán» muestra el mensaje completo con ejemplos numéricos.",
            "- Sé breve: la pantalla es pequeña y la letra muy grande.",
            "- Tutea a los niños.",
            "- Para el apóstrofo, usa mejor el tipográfico ’ (no '), sobre todo antes de una llave.",
        ],
    ),
    "it": dict(
        message="messaggio", before="testo prima", between="testo in mezzo", after="testo dopo",
        if_eq="se = {n}", other="altri numeri", if_cat="categoria {cat}", other_sel="altri casi",
        cols=["N.", "Area", "Tedesco", "Inglese", "Indicazione", "Parte", "Traduzione attuale",
              "Correzione", "Nota", "chiave", "percorso"],
        sheet_help="Istruzioni",
        areas=dict(lesson="Lezioni", lessons="Lezioni (elenco)", profile="Profilo", profiles="Profili", admin="Area genitori",
                   global_="Statistiche generali", editor="Editor", task="Esercizio", assignments="Compiti",
                   assignment="Compito", duel="Sfida", backup="Backup", result="Risultato", clock="Orologio",
                   stats="Statistiche", group="Gruppi", common="Generale", practice="Allenamento", range="Intervalli di numeri",
                   pin="PIN", start="Avvio", reset="Reimpostazione", deadline="Scadenza", filter="Filtro",
                   sound="Suono", pause="Pausa", app="App", settings="Impostazioni", leaderboard="Classifica",
                   money="Denaro", place="Valore posizionale", recommend="Consiglio"),
        help=[
            "Revisione della traduzione: Mathe-Trainer",
            "",
            "A cosa serve l'app? È un'app di matematica per bambini dai 6 ai 10 anni (scuola primaria), da usare su tablet.",
            "",
            "Cosa fare:",
            "1. Leggi la colonna «Traduzione attuale» riga per riga. Le colonne «Tedesco» e «Inglese» spiegano il senso e danno esempi.",
            "2. Se va tutto bene, non fare nulla: una cella «Correzione» vuota significa «va bene».",
            "3. Se qualcosa non va, scrivi nella colonna «Correzione» il testo corretto completo di quella parte. Compila solo quella colonna (e «Nota»). Le altre sono protette.",
            "4. Hai una domanda o un dubbio? Scrivilo nella colonna «Nota».",
            "",
            "Regole:",
            "- Lascia esattamente come sta tutto ciò che è tra parentesi graffe, per esempio {n} o {name}: sono segnaposto che l'app sostituisce (numeri, nomi…). Puoi spostarli nella frase, ma non tradurli e non cancellarli.",
            "- Un messaggio su più righe («se = 1», «altri numeri»…) è diviso in parti: correggi ogni parte separatamente. La colonna «Tedesco» mostra il messaggio intero con esempi numerici.",
            "- Sii breve: lo schermo è piccolo e i caratteri molto grandi.",
            "- Dai del tu ai bambini.",
            "- Per l'apostrofo usa meglio quello tipografico ’ (non '), soprattutto prima di una graffa.",
        ],
    ),
    "en": dict(
        message="message", before="text before", between="text in between", after="text after",
        if_eq="if = {n}", other="other numbers", if_cat="category {cat}", other_sel="other cases",
        cols=["No.", "Area", "German", "English", "Hint", "Part", "Current translation",
              "Correction", "Comment", "key", "path"],
        sheet_help="Instructions",
        areas=dict(lesson="Lessons", lessons="Lessons (list)", profile="Profile", profiles="Profiles", admin="Parents' area",
                   global_="Overall statistics", editor="Editor", task="Exercise", assignments="Assignments",
                   assignment="Assignment", duel="Duel", backup="Backup", result="Result", clock="Clock",
                   stats="Statistics", group="Groups", common="General", practice="Practice", range="Number ranges",
                   pin="PIN", start="Start", reset="Reset", deadline="Deadline", filter="Filter",
                   sound="Sound", pause="Break", app="App", settings="Settings", leaderboard="Leaderboard",
                   money="Money", place="Place value", recommend="Recommendation"),
        help=[
            "Translation review: Mathe-Trainer",
            "",
            "What is the app for? It is a maths app for primary-school children aged 6 to 10, used on a tablet.",
            "",
            "What to do:",
            "1. Read the \"Current translation\" column row by row. The \"German\" and \"English\" columns give the meaning and examples.",
            "2. If it is fine, do nothing: an empty \"Correction\" cell means \"this is fine\".",
            "3. If something is wrong, write the complete corrected text of that part in the \"Correction\" column. Fill in only that column (and \"Comment\"); the others are protected.",
            "4. A question or a doubt? Write it in the \"Comment\" column.",
            "",
            "Rules:",
            "- Keep everything in curly braces, such as {n} or {name}, exactly as it is: these are placeholders the app fills in (numbers, names...). You may move them within the sentence, but do not translate or delete them.",
            "- A message with several lines (\"if = 1\", \"other numbers\"...) is split into parts: correct each part separately. The \"German\" column shows the whole message with numeric examples.",
            "- Keep it short: the screen is small and the type is very large.",
            "- Address the children informally (as \"you\" in the friendly form).",
            "- For the apostrophe, prefer the typographic one (’) rather than ', especially before a curly brace.",
        ],
    ),
}


def tr_for(lang):
    return TR.get(lang.split("_")[0], TR["en"])


def area_name(key, tr):
    m = re.match(r"[a-z0-9]*", key)
    prefix = m.group() if m else key
    if prefix == "global":
        prefix_key = "global_"
    else:
        prefix_key = prefix
    return tr["areas"].get(prefix_key, prefix)


# --------------------------------------------------------------------------
# ARB access
# --------------------------------------------------------------------------


def arb_path(l10n, lang):
    return Path(l10n) / f"app_{lang}.arb"


def dump_arb(data):
    return json.dumps(data, ensure_ascii=False, indent=2) + "\n"


def load_arb(path, strict_format=False):
    if not path.exists():
        raise ReviewError(f"{path} fehlt")
    raw = path.read_text(encoding="utf-8")
    data = json.loads(raw)
    if strict_format and dump_arb(data) != raw:
        raise ReviewError(
            f"{path} ist nicht im Standardformat (2 Leerzeichen, UTF-8, Zeilenumbruch am Ende); "
            "ein Rückschreiben würde die ganze Datei umformatieren.")
    return data, raw


def messages(data):
    return [(k, v) for k, v in data.items() if not k.startswith("@") and isinstance(v, str)]


# --------------------------------------------------------------------------
# Export
# --------------------------------------------------------------------------

HEADER_FILL = PatternFill("solid", fgColor="1F4E79")
CORR_FILL = PatternFill("solid", fgColor="FFF2CC")
NOTE_FILL = PatternFill("solid", fgColor="E2EFDA")
WRAP = Alignment(wrap_text=True, vertical="top")


def export(lang, out, l10n):
    de, _ = load_arb(arb_path(l10n, TEMPLATE_LANG))
    target, _ = load_arb(arb_path(l10n, lang))
    bridge = None
    with_bridge = lang != BRIDGE_LANG
    if with_bridge and arb_path(l10n, BRIDGE_LANG).exists():
        bridge, _ = load_arb(arb_path(l10n, BRIDGE_LANG))
    tr = tr_for(lang)

    wb = Workbook()
    ws = wb.active
    ws.title = "Review"
    cols = list(tr["cols"])
    # Columns: Nr, Area, German, [English], Hint, Part, Translation, Correction, Comment, key, path
    if not with_bridge:
        del cols[3]
    ws.append(cols)
    n_cols = len(cols)
    c_corr, c_note, c_key, c_path = n_cols - 3, n_cols - 2, n_cols - 1, n_cols

    for c in range(1, n_cols + 1):
        cell = ws.cell(row=1, column=c)
        cell.font = Font(bold=True, color="FFFFFF")
        cell.fill = HEADER_FILL
        cell.alignment = Alignment(wrap_text=True, vertical="center")
    ws.freeze_panes = "A2"

    nr = 0
    rows = 0
    for key, value in messages(target):
        if key not in de:
            continue  # stale key, not part of the template
        nr += 1
        de_text = render_text(de[key])
        en_text = render_text(bridge[key]) if bridge and key in bridge else ""
        desc = (de.get("@" + key) or {}).get("description", "")
        area = area_name(key, tr)
        for part in collect_parts(value, tr):
            row = [nr, area, de_text]
            if with_bridge:
                row.append(en_text)
            row += [desc, part.label, part.text, None, None, key, part.path]
            ws.append(row)
            rows += 1
            r = ws.max_row
            for c in range(1, n_cols + 1):
                cell = ws.cell(row=r, column=c)
                v = cell.value
                if isinstance(v, str):
                    cell.data_type = "s"  # never let "=..." become a formula
                cell.alignment = WRAP
                cell.protection = Protection(locked=c not in (c_corr, c_note))
            ws.cell(row=r, column=c_corr).fill = CORR_FILL
            ws.cell(row=r, column=c_note).fill = NOTE_FILL

    widths = {1: 6, 2: 16, 3: 42}
    c = 4
    if with_bridge:
        widths[c] = 42
        c += 1
    widths[c] = 28       # hint
    widths[c + 1] = 18   # part
    widths[c + 2] = 42   # translation
    widths[c + 3] = 42   # correction
    widths[c + 4] = 30   # comment
    for col, w in widths.items():
        ws.column_dimensions[get_column_letter(col)].width = w
    ws.column_dimensions[get_column_letter(c_key)].hidden = True
    ws.column_dimensions[get_column_letter(c_path)].hidden = True

    # Protected without password: Correction/Comment stay editable.
    ws.protection.sheet = True
    ws.protection.formatColumns = False
    ws.protection.formatRows = False
    ws.auto_filter.ref = f"A1:{get_column_letter(n_cols)}{ws.max_row}"

    help_ws = wb.create_sheet("Anleitung")
    help_ws.column_dimensions["A"].width = 110
    for i, line in enumerate(tr["help"], start=1):
        cell = help_ws.cell(row=i, column=1, value=line)
        cell.alignment = Alignment(wrap_text=True, vertical="top")
        cell.data_type = "s"
        if i == 1:
            cell.font = Font(bold=True, size=14)
    help_ws.protection.sheet = True

    out = Path(out)
    out.parent.mkdir(parents=True, exist_ok=True)
    wb.save(out)
    return out, rows, nr


# --------------------------------------------------------------------------
# Import
# --------------------------------------------------------------------------


def read_sheet(xlsx):
    wb = load_workbook(xlsx)
    if "Review" not in wb.sheetnames:
        raise ReviewError("Blatt 'Review' fehlt")
    ws = wb["Review"]
    header = [c.value for c in ws[1]]
    # layout is fixed: ..., Correction, Comment, key, path
    n = len(header)
    c_corr, c_note, c_key, c_path = n - 4, n - 3, n - 2, n - 1  # 0-based
    if n < 9 or ws.column_dimensions[get_column_letter(c_key + 1)].hidden is not True:
        raise ReviewError("Spaltenaufbau unerwartet (versteckte Spalten Schlüssel/Pfad fehlen am Ende)")
    rows = []
    for r in ws.iter_rows(min_row=2, values_only=True):
        if r[c_key] is None:
            continue
        rows.append(dict(
            nr=r[0],
            key=str(r[c_key]),
            path=str(r[c_path]),
            current=r[c_corr - 1],
            correction=r[c_corr],
            note=r[c_note],
        ))
    return rows


def check_correction(old, new):
    """Returns an error text or None."""
    if placeholders(old) != placeholders(new):
        return (f"Platzhalter passen nicht: erwartet {placeholders(old)}, gefunden {placeholders(new)} "
                "(Apostroph direkt vor einer Klammer? dann '' oder ’ verwenden)")
    left = re.sub(r"\{\s*" + IDENT + r"\s*\}", "", strip_quoted(new))
    if "{" in left or "}" in left:
        return "ungepaarte geschweifte Klammer"
    return None


def apply_corrections(data, rows, tr):
    """Returns (new_data, changes, errors, notes). Nothing is written here."""
    errors, changes, notes = [], [], []
    by_key = {}
    new_data = dict(data)
    parsed = {}
    for row in rows:
        label = f"Nr {row['nr']} ({row['key']})"
        if row["note"] not in (None, ""):
            notes.append((row["nr"], row["key"], str(row["note"])))
        corr = row["correction"]
        if corr is None or str(corr).strip() == "":
            continue
        key = row["key"]
        if key not in data or not isinstance(data[key], str):
            errors.append(f"{label}: Schlüssel nicht in der ARB-Datei")
            continue
        if key not in parsed:
            try:
                parts = collect_parts(data[key], tr)
            except ReviewError as e:
                errors.append(f"{label}: ursprüngliche Nachricht nicht lesbar: {e}")
                continue
            parsed[key] = {p.path: p for p in parts}
        part = parsed[key].get(row["path"])
        if part is None:
            errors.append(f"{label}: Teil {row['path']!r} gibt es nicht mehr")
            continue
        if row["current"] is not None and str(row["current"]) != part.text:
            errors.append(f"{label}: die Übersetzung in der ARB hat sich seit dem Export geändert; neu exportieren")
            continue
        text = str(corr).replace("\r\n", "\n")
        lead = part.text[:len(part.text) - len(part.text.lstrip())]
        trail = part.text[len(part.text.rstrip()):]
        text = lead + text.strip() + trail
        if text == part.text:
            continue
        err = check_correction(part.text, text)
        if err:
            errors.append(f"{label}, Teil {part.label!r}: {err}")
            continue
        by_key.setdefault(key, []).append((part, text))

    for key, edits in by_key.items():
        s = data[key]
        for part, text in sorted(edits, key=lambda e: -e[0].start):
            s = s[:part.start] + text + s[part.end:]
        try:
            if skeleton(parse_icu(s)) != skeleton(parse_icu(data[key])):
                raise ReviewError("Struktur der Nachricht hat sich verändert")
        except ReviewError as e:
            errors.append(f"{key}: zusammengesetzte Nachricht ungültig: {e}")
            continue
        new_data[key] = s
        for part, text in edits:
            changes.append((key, part.label, part.text, text))
    return new_data, changes, errors, notes


def do_import(lang, xlsx, l10n, dry_run, quiet=False):
    path = arb_path(l10n, lang)
    data, raw = load_arb(path, strict_format=True)
    rows = read_sheet(xlsx)
    tr = tr_for(lang)
    new_data, changes, errors, notes = apply_corrections(data, rows, tr)
    out = sys.stdout if not quiet else open(os.devnull, "w")
    if errors:
        print("FEHLER - nichts geschrieben:", file=sys.stderr)
        for e in errors:
            print("  " + e, file=sys.stderr)
        return 1, changes, notes
    if changes:
        print(f"{len(changes)} Änderung(en){' (Trockenlauf)' if dry_run else ''}:", file=out)
        for key, label, old, new in changes:
            print(f"  {key} [{label}]\n    alt: {old}\n    neu: {new}", file=out)
    else:
        print("Keine Korrekturen.", file=out)
    if notes:
        print("\nAnmerkungen:", file=out)
        for nr, key, note in notes:
            print(f"  Nr {nr} | {key} | {note}", file=out)
    if not dry_run:
        text = dump_arb(new_data)
        if text != raw:
            path.write_text(text, encoding="utf-8")
        else:
            pass  # untouched
    return 0, changes, notes


# --------------------------------------------------------------------------
# Selftest
# --------------------------------------------------------------------------


def selftest(l10n):
    l10n = Path(l10n)
    langs = sorted(p.stem[4:] for p in l10n.glob("app_*.arb") if p.stem[4:] != TEMPLATE_LANG)
    if not langs:
        print("selftest: keine Sprache ausser de gefunden", file=sys.stderr)
        return 1
    failures = 0
    for lang in langs:
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            work = tmp / "l10n"
            work.mkdir()
            for f in l10n.glob("app_*.arb"):
                shutil.copy(f, work / f.name)
            original = (work / f"app_{lang}.arb").read_bytes()
            xlsx = tmp / "r.xlsx"
            _, rows, nmsg = export(lang, xlsx, work)
            ok = True

            code, ch, _ = do_import(lang, xlsx, work, False, quiet=True)
            same = (work / f"app_{lang}.arb").read_bytes() == original
            print(f"[{lang}] {nmsg} Nachrichten, {rows} Zeilen; Import ohne Korrektur: "
                  f"{'byte-identisch' if same and code == 0 and not ch else 'FEHLER'}")
            ok &= same and code == 0 and not ch

            # simulated correction in a plural variant (fallback: any multi-part message)
            data, _ = load_arb(work / f"app_{lang}.arb")
            tr = tr_for(lang)
            target = None
            for key, value in messages(data):
                if key not in load_arb(arb_path(work, TEMPLATE_LANG))[0]:
                    continue
                if "plural" in value:
                    ps = collect_parts(value, tr)
                    if len(ps) > 1:
                        # prefer a variant (not the first/outer text)
                        target = (key, ps[len(ps) // 2] if len(ps) > 2 else ps[-1])
                        break
            if target is None:
                print(f"[{lang}] keine Plural-Nachricht zum Testen gefunden")
                ok = False
            else:
                key, part = target
                wb = load_workbook(xlsx)
                ws = wb["Review"]
                n = ws.max_column
                hit = False
                for r in range(2, ws.max_row + 1):
                    if ws.cell(r, n - 1).value == key and ws.cell(r, n).value == part.path:
                        ws.cell(r, n - 3).value = "XYZ" + part.text.strip()
                        hit = True
                        break
                wb.save(xlsx)
                code, ch, _ = do_import(lang, xlsx, work, False, quiet=True)
                after, _ = load_arb(work / f"app_{lang}.arb")
                # leading whitespace of the part is kept in front of the correction
                lead = part.text[:len(part.text) - len(part.text.lstrip())]
                expect = (data[key][:part.start] + lead + "XYZ" + data[key][part.start + len(lead):])
                diff = [k for k in data if data[k] != after.get(k)]
                good = hit and code == 0 and diff == [key] and after[key] == expect and len(ch) == 1
                print(f"[{lang}] simulierte Korrektur in {key} [{part.label}]: "
                      f"{'ok' if good else 'FEHLER'}")
                ok &= good

                # a broken correction must be rejected and leave the file alone
                before = (work / f"app_{lang}.arb").read_bytes()
                wb = load_workbook(xlsx)
                ws = wb["Review"]
                for r in range(2, ws.max_row + 1):
                    if ws.cell(r, n - 1).value == key and ws.cell(r, n).value == part.path:
                        ws.cell(r, n - 3).value = "kaputt {"
                wb.save(xlsx)
                code, _, _ = _quiet_stderr(lambda: do_import(lang, xlsx, work, False, quiet=True))
                rejected = code != 0 and (work / f"app_{lang}.arb").read_bytes() == before
                print(f"[{lang}] fehlerhafte Korrektur abgelehnt: {'ok' if rejected else 'FEHLER'}")
                ok &= rejected
            failures += 0 if ok else 1
    print("selftest:", "OK" if not failures else "FEHLGESCHLAGEN")
    return 0 if not failures else 1


def _quiet_stderr(fn):
    old = sys.stderr
    sys.stderr = open(os.devnull, "w")
    try:
        return fn()
    finally:
        sys.stderr.close()
        sys.stderr = old


# --------------------------------------------------------------------------


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name in ("export", "import", "selftest"):
        p = sub.add_parser(name)
        p.add_argument("--l10n-dir", default=str(DEFAULT_L10N))
        if name != "selftest":
            p.add_argument("lang")
        if name == "export":
            p.add_argument("-o", "--output")
        if name == "import":
            p.add_argument("xlsx")
            p.add_argument("--dry-run", action="store_true")
    args = ap.parse_args(argv)
    try:
        if args.cmd == "export":
            out = args.output or DEFAULT_OUT / f"review_{args.lang}.xlsx"
            out, rows, nmsg = export(args.lang, out, args.l10n_dir)
            print(f"{out}: {nmsg} Nachrichten, {rows} Zeilen")
            return 0
        if args.cmd == "import":
            code, _, _ = do_import(args.lang, args.xlsx, args.l10n_dir, args.dry_run)
            return code
        return selftest(args.l10n_dir)
    except ReviewError as e:
        print(f"Fehler: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
