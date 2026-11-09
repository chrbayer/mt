# Mathe-Trainer

*Deutsch: [README.md](README.md)*

<https://github.com/chrbayer/mt>

Mental arithmetic app for primary school children on Android tablets. It measures
the time until the right answer is given, and from that it builds personal
learning curves and leaderboards, on which several children on the same tablet
compete against each other. The app runs entirely offline, with no accounts and
no network.

## What it can do

* **83 lessons** in ten groups (First Steps / Up to 10 / Up to 20 /
  Up to 100 / Up to 1000 / With Thousands / Times Tables / Times Tables Backwards /
  Multiply and Divide / Time and Money).
  From 20 up, every group offers plus and minus with and without crossing ten
  (regrouping, above 20), two
  missing-number forms (`34 + ? = 71`), and a mixed lesson. Each lesson has its
  own leaderboard.
* **First Steps** is the gentlest group: counting pictures, reading dice dots
  (all six faces), comparing two groups of dots, the number line forwards and
  backwards, adding bees (up to 10), adding two dice, and working within 6 — as
  plus, as minus, and mixed.
  Counting, comparing, and bees each come in two versions: **in a row** and
  **as a cloud**.
  With a row, you count by moving your finger along it; with a cloud, you have to
  remember what you have already counted. That is a different skill, so it gets
  its own lesson, and the row comes first.
  A number appears next to the pictures only where it is meant to be linked to the
  quantity — when comparing and when adding together. Where counting itself is
  the task, no number gives away the answer.
  Where two numbers appear, they sit **on one line**, and when adding together, a
  **plus sign** stands between them — the same sign that appears between the
  groups of dots. When comparing, there is no sign there: the quantities are
  compared, not added.
  These lessons are **not timed and not scored**: no clock, no leaderboard, and the
  stars are earned for accuracy as everywhere else, and there are no bolts.
  A child who counts five apples should not be racing a sibling.
* **Up to 10** is where the arithmetic problems begin. Nothing there can cross ten,
  so this group has no split into "with" and "without crossing ten." Instead it
  has a shorter set: plus, minus, both missing-number forms, and mixed.
* **Times Tables** as its own group: one lesson per table, in the order they are
  usually learned (2, 5, 10, then 3, 4, 6, 7, 8, 9), plus "All tables mixed."
  Each table is practiced in both directions — `3 · 7` as well as `7 · 3` — and
  has its own leaderboard.
* **Times Tables Backwards**: the same nine tables again, this time divided —
  `12 : 2`, `63 : 7`. It is its own group rather than a corner of "Multiply and
  Divide," because it is learned the same way as the times tables themselves:
  table by table, ideally starting with the one just practiced forwards. At the
  end is "All tables backwards" — the same lesson that used to be called
  "Divide without remainder," and it keeps its leaderboard.
* **Multiply and Divide**: division with remainder, both missing-number forms,
  and everything mixed. "Division with remainder" has two input fields — first the
  result, then the remainder; the active one is outlined.
* At the very front are the **number bonds to 10** — the pairs that add up to 10
  together. They are not posed as a calculation but as a question with a heart in
  between (`3 ♥ ?`), and asked in both directions: from 3 to 7 as well as from 7
  to 3.
* **Each group has its own color**: the tiles sit on a light pastel tone per
  group, so that the catalog breaks into blocks and you can see the seam between
  two groups before reading a heading. The order is not arbitrary — the number
  ranges run from cool mint through sky blue to lavender, and the times tables
  run warm from sunny yellow through apricot to rosé. Rising difficulty thus gets
  a direction instead of nine unconnected colors. A test checks, for every tone,
  that the title, the example, and the small gray line remain readable on it.
* Each lesson can explain itself on request: tapping the question mark in the
  start dialog says what "crossing ten" means. By default the text is collapsed,
  so the screen stays calm for the child.
* **Number of problems selectable** — 5, 10, 20, 30, or 50 problems per round, so
  the app works both for quick checks and for longer practice. The **5** is set
  apart in color in the start dialog: below it, a round does not count, and that
  should be visible on the tile, not only in the sentence beneath it. The color is
  warm, not red — five problems is a legitimate way to practice, not a mistake.
  The most specific setting always applies: **what was last chosen for this
  lesson**, otherwise the **profile's default**, otherwise the **default for
  everyone** (10). The child sets the profile default in their own settings, or a
  parent sets it in the parent area; the **default for everyone** is only found
  there. If a child chooses something different when starting a lesson, that
  changes only this one lesson — not the sibling's, and not all the other lessons.
* **Own large number keypad**, confirmed with the green check mark. Correct →
  a brief green flash, then it moves on automatically. Wrong → red, the field
  clears, and the clock keeps running.
* **Sign-in by profile tile** (avatar + first name, no password). Whoever is
  signed in is shown on every screen where results are produced — during practice
  at the top left, and afterwards in the heading ("Well done, Mia!"). On a shared
  tablet, that is the difference between a personal best and a corrupted
  leaderboard entry.
* **Statistics** for each child: best time, average time, and error rate per
  lesson, the learning curve as a chart, and the problems that take the longest.
* **All results** — from the start screen, without signing in, with two tabs:
  * *Overview*: one card per child (rounds, practice time, error rate, last
    active), and a bar chart of the last 30 days.
  * *Leaderboards*: every lesson that has something to rank, with the podium at a
    glance; most recently practiced first. A tap opens the full list. Lessons
    without results do not appear at all — there are 42 of them, and at the start
    almost all are empty.
* **Parent area**, protected by a PIN: the complete practice log (when, which
  child, which lesson, time, errors, finished or abandoned), deleting individual
  rounds, creating, renaming, and deleting profiles, resetting statistics, and
  changing the PIN. At the very top is **"Practiced today"** — for each profile,
  today's time, and where a daily limit applies, right beside it ("45 min of 60
  min"), so it is clear at a glance who has practiced how much. It is counted
  exactly the way the limit counts, abandoned rounds included — and there are the
  **settings for everyone**: the clock during practice, vibration, and the default
  for the length of a round. A child can change only the length of their own rounds
  in their own settings.
* **Time and Money**: a drawn clock for reading the time (full and half hours,
  quarter hours, five-minute steps), plus adding and subtracting amounts of money.
  Both ask for two numbers — hours and minutes, euros and cents — using the same
  two fields as "Division with remainder." The keypad stays the same everywhere;
  there is no decimal-point key.
* **Time with 24 hours**: the same drawn clock, but the question asks for counting
  up to 23. Below the clock face is the time of day — morning, midday, afternoon,
  evening — because the hands look the same at 10 a.m. as at 10 p.m.
* **Telling the time**: saying the time in words. Instead of digits, the keypad
  shows the eleven spoken forms (`five past`, `quarter past`, `twenty-five to`,
  `half past`, `quarter to`, …). Then the hour is typed in, **the hour that is
  named with it**. That is exactly where the task lies: 2:30 is „halb 3“
  (German, literally "half 3," meaning half past 2), not „halb 2“ (which means 1:30).
* **Make an amount**: an amount has to be laid out with coins and notes. The keypad
  shows the nine pieces from 5 ct to €20; pieces you tap appear as a pile, and the
  backspace key removes the last one — holding it down clears the whole pile.
  There are many correct ways to do it — in the end the amount has to be exactly
  right.
* **Change**: something costs an odd amount, you pay with a round note or coin,
  and you need to work out the change.
* **Duel**: two or more children get exactly the same round (same random seed),
  take turns on the same tablet, and then see the ranking. Only lessons unlocked
  for everyone taking part are offered.
* **Hard problems come back**: a quarter of every round consists of the problems
  that took this child a long time or went wrong last time. Can be switched off per
  profile in the parent area; on by default. For lessons that go through their
  full set of items — number bonds to 10, telling the time — the hard problems
  move to the front instead: a round shorter than the full set would otherwise
  skip them by chance.
* **Recommendation**: above the catalog there is a suggestion — first a shaky
  lesson, otherwise something new, otherwise something not practiced for a long
  time.
* **Stars**: each lesson tile shows its three stars — filled in as many as the best
  round reached, otherwise empty. Scoring starts only **at 10 problems**: five quick
  problems are a warm-up, not a result. This is stated where it matters — in the
  start dialog beneath the selection, in a duel, and again in the result, when the
  stars stayed empty for that reason. For **First Steps this does not apply** —
  there, persistence is the achievement, and five problems is a perfectly good
  length. Three empty stars mean "not practiced yet," without that having to be
  written out. At the top, the overall total runs along with it ("24 of 150"), and
  it counts **once per lesson, using the best result** — otherwise it would pay
  more to repeat the easiest lesson than to start a new one. Stars also appear in
  the result, in the personal statistics, in the overview of all children, and in
  the practice log.

  The status line shows both totals side by side, but **not as equals**: the stars
  with their maximum ("143 of 225"), the bolts as a number alone. This says what
  the goal is — accuracy has a mark to reach, and speed is a bonus.

  **Give back a group's stars**: in the parent area, per profile, so that a child
  can earn them again. Only **the stars** are reset — best times, bolts, learning
  curve, and leaderboards stay as they were. That is why, since version 2.3.0, stars
  have been saved individually rather than calculated from the times; on update, the
  level reached was carried over once.

  Both totals depend **only** on which areas are unlocked. If you hide finished
  lessons, the list is tidied up and no stars are given back; the maximum changes
  only when a parent unlocks or locks a group.
* **Bolts**: the second measure alongside stars. Stars stand for accuracy, bolts
  for speed — someone who takes their time and stays error-free gets three stars and
  no bolts. Every lesson has its **own target time per problem**, because 6 seconds
  means something different for `47 + 38` than for `646 + ? = 949`. At or under this
  time you get three bolts; at one and a half times the target, two; at 2.2 times,
  one; anything slower, none. The start dialog states the target time **before** the
  round, and the result screen says what the next bolt would cost after it. First
  Steps have no bolts — nothing is measured there.
* **Practice time**: two limits, by default **20 minutes in a row** and **1 hour
  per day**. Both apply to everyone at first and can be changed in the parent area;
  for an individual child, a separate setting sits beside them and replaces the
  general one. "No limit" is a deliberate choice and is different from "same as
  everyone."
  * **In a row**: after the set time there is a break. Only once the break has been
    fully observed does the count start again from zero. The notice states the time
    when practice resumes, and disappears by itself — nobody has to tap anything.
  * **Per day in total**: counts all rounds of the day together, breaks or not. Once
    the time is used up, a break no longer helps; the screen then says "That's enough
    for today!" instead of giving a time the app could not keep.

  Before the start, the screen shows how much time is left ("7 minutes left, then a
  break"), and below five minutes more prominently — with four minutes left, you
  do not start a round of 50 problems.

  A **round in progress is never cut off** — only the next start is blocked. During
  a break a child may still look at lessons and leaderboards, just not start one;
  duels are also blocked, otherwise they would be a way around the limit.
* **Sound**: a short, friendly two-note chime for a correct answer, and a lower
  single tone for a wrong one. Together with color and vibration, it is the third
  channel of feedback — a child looking at the keypad rather than the answer field
  would otherwise get only one of them, and a tablet lying flat swallows the
  vibration. In addition, there is a **quiet click under every key**, but only when
  the input was actually accepted: a fourth digit that no longer fits in the field,
  and backspace in an empty field, stay silent. The green check mark does not click
  — the other two tones already say more there.
  Can be switched off in the parent area. The sounds are generated by
  `tool/make_sounds.py`, not downloaded: a few lines of mathematics, 30 kB in total.
  On the desktop, the click starts with 45 ms of silence — a real sound card needs a
  moment after a pause before it plays sound again, and a click without this lead-in
  fell entirely into that start-up. On Android this does not happen, and the click
  comes without delay.
* **Scored rounds per lesson and day**: repeating the same easy lesson until the
  time is right brings nothing from the fourth time onward. It may still be
  practiced — it counts toward practice time and appears in the log — but it no
  longer sets a best time and gives no stars or bolts. The app says so in advance in
  the start dialog and afterwards on the result screen. Can be set in the parent
  area, for everyone or per child.
* **Lock a profile temporarily**: a child can be paused for a while. The tile then
  cannot be opened and cannot be invited to a duel, but it says what is going on —
  and **nothing is lost**: stars, bolts, and best times are unchanged when it is
  unlocked.
* **Tidy up in the parent area**: abandoned rounds can be cleared from the log with
  one button — for everyone or only for the selected child. Deleting costs stars,
  bolts, and leaderboard places, **but never the practice time**: otherwise the daily
  limit would have a delete button beside it.
* **Hide finished lessons**: with 83 lessons the list is long, and most of what a
  child scrolls past is long since mastered. The filter at the top of the catalog
  trims it in two steps — **at 3 stars**, whatever runs error-free disappears; **only
  at 3 stars and 3 bolts** is the stricter filter, and it keeps whatever is correct
  but still slow. Stored per profile, can be changed by the child, and set up in the
  parent area. First Steps are also hidden once they are done — the stars can be
  given back in the parent area if the group is meant to come back. With the stricter
  setting, they stay: where nothing is measured, there are no bolts to earn.
* **Streak**: days in a row, on the result screen and in the overview.
* **Backup**: the entire data set as a JSON file, sent out through the app's share
  function, and restorable in the same way.
* **Unlock areas per child** — also in the parent area. A first-grader sees "Up to 10"
  and "Up to 20" and does not have to scroll past four number ranges and the times
  tables. Hidden areas disappear only from the practice screen; recorded results and
  leaderboard entries are kept.

In the bottom right of the start screen, in small type, is the **version number** —
in case you want to know which build is on a tablet. It comes from `pubspec.yaml`
via the build scripts into the app; a build that did not run through the scripts
shows nothing at all, rather than a possibly wrong number.

## Who may do what

Children sign in with a tap on their tile, and they may change the picture and color
on their own profile. **Giving names, creating and deleting profiles, and resetting
results** are in the parent area behind the PIN — otherwise a sibling could delete
the best times. The same applies to everything that is **for everyone**: a child who
can switch the clock off or set every round to five problems has the wrong control
in their hands. Creating a profile means giving it a name, so creating one is also
behind the PIN.

The PIN is set the first time the parent area is opened; there is no default PIN. It
is stored salted and hashed, never in plain text. Forgotten it? Then the only option
is to clear the app data in the Android settings — and that also removes all results.

## Two design decisions

**The clock is hidden by default** (can be switched on in the parent area).
Timing still happens all the time — visible time pressure makes primary school
children slower, not faster.

**There is only one time figure**, and it contains the time penalty:
`(calculation time + 3 s per wrong attempt) / number of problems`. It appears on the
result screen, in the learning curve, and in the leaderboards — the same everywhere.
The penalty prevents fast guessing from winning; because the time is normalized per
problem, rounds of 10 and of 50 problems stay fairly comparable. If there were wrong
attempts, the result screen shows how much penalty is in the total time. Only
completed rounds with at least 10 problems make it onto the leaderboards.

## Structure

```
lib/
  domain/      Business logic, with no Flutter imports at all, fully tested
    lesson.dart          Lesson catalog as constants with stable IDs
    task.dart            A problem and the result of a problem
    task_generator.dart  Deterministic generation from a seed
    scoring.dart         Time per problem, stars, bolts, time formatting
    practice_limit.dart  Practice time in a row, and breaks
  data/
    db/          Drift schema (users, sessions, attempts, app_settings)
    repositories/ Data access and SQL aggregates for the statistics
  features/    one directory per screen
  theme/       Colors, type scale, avatar selection
  providers.dart  Riverpod wiring
```

## Development

```bash
flutter pub get
dart run build_runner build          # after changes to the Drift schema
flutter run -d linux                 # quick iteration on the desktop
flutter run -d <android-device>      # the real target: tablet in landscape
```

## Building and delivering

```bash
./build_android.sh              # release APK, then rsync to the server
./build_android.sh --debug      # debug APK
./build_android.sh --no-upload  # build only
./build_client.sh --run         # start the Linux build
```

The APK carries the version in its file name: `mt-1.0.1.apk`, or `mt-1.0.1-debug.apk`
for the debug build. That way a file lying on a tablet months later still says which
version it is. Locally, it sits alongside the unchanged `app-release.apk` that Flutter
itself writes.

The **Linux build requires GStreamer development packages**, because the sound plugin
depends on them — without them, CMake fails with "required package not found:
gstreamer-1.0" before anything is compiled at all:

```bash
sudo dnf install gstreamer1-devel gstreamer1-plugins-base-devel
```

Both scripts read the version from `pubspec.yaml`, which holds both parts, e.g.
`version: 2.16.0+21600`: the part before the `+` is the **build name** and ends up in
the app as the Android `versionName`; the part after it is the **`versionCode`**,
following the rule `2.4.1` → `20401` (a test keeps the two in step, and F-Droid reads
the code from exactly this line). Nobody sees this number, but Android uses it to decide whether an APK is an update. If it were
left at 1, as it once was, two different builds would present the same version to the
package manager — and installing one over the other can leave the app half replaced,
so that it no longer starts. Conversely, this means an older version cannot be
installed over a newer one without uninstalling first.

`build_android.sh` uploads the APK under the same name to `/srv/http/main_ssl/mt` and
reports the URL `https://criby.de/mt/mt-1.0.1.apk`. Because the file name contains
the version, the link changes with every release. A web version of the app is not
planned — the directory serves only as APK output. Target, user, and directory can be
overridden with `MT_DEPLOY_HOST`, `MT_DEPLOY_USER`, `MT_DEPLOY_DIR`, and
`MT_DEPLOY_ROOT`. For a signed release, set `MT_KEYSTORE_PATH`, `MT_KEYSTORE_ALIAS`,
and `MT_KEYSTORE_PASS` — without these, the build is signed with the debug key.

## Creating profiles

The editor asks in two steps: first the name, then the picture and color. The keyboard
is needed only for the name, and in landscape it covers half the screen — a dialog with
a text field, sixteen pictures, and eight colors does not fit beside it. On narrow
devices, the first step shrinks to a single line. The keyboard's Enter key moves on, so
the button never has to be dragged out from behind it.

## Icon

The source is `assets/icon/icon.svg`: a plus sign over a minus sign — exactly what the
app practices. The minus is colored warm, so that the icon at 48 dp does not look like
any ordinary calculator symbol. The adaptive-icon foreground and the monochrome layer
for Android 13 come from the same source.

## Proofreading translations

Native speakers without programming skills proofread a translation in a spreadsheet
(Python 3 and `openpyxl` are needed). This applies to every language except German —
first to French, Spanish, and Italian, which were created without native speakers
(`export fr`, `export es`, `export it`):

```bash
python3 tool/translation_review.py export fr      # build/translation_review/review_fr.xlsx
# send the file; the person fills in only "Correction" (and "Comment")
python3 tool/translation_review.py import fr review_fr.xlsx --dry-run   # look first
python3 tool/translation_review.py import fr review_fr.xlsx
flutter gen-l10n
flutter analyze
flutter test
```

Each message is split into parts that can be edited (text before the block, each
plural/select variant, text after it). The "German" and "English" columns show the
whole message with example numbers. The import checks that the `{placeholders}` of each
part are preserved and that the message remains valid; if there is an error, nothing is
written. The import prints the **comments** at the end — please read them, because
that is where the follow-up questions are. An empty "Correction" means: it's fine.
`python3 tool/translation_review.py selftest` checks the round trip (the ARB stays
byte-identical without corrections); `--l10n-dir` points to a directory other than
`lib/l10n`.

## Testing

```bash
flutter analyze
flutter test
```

The tests cover the risky parts: the invariants of the problem generator across many
seeds (number range, carry rule, distance between repeats, determinism), scoring, the
leaderboard and statistics SQL against an in-memory database, the timing rules of the
practice controller, and a complete round through the real interface.

## Store texts and screenshots

Under `fastlane/metadata/android/` are the titles, descriptions, change notes, and
images, in the form that F-Droid reads directly from the repository.

The screenshots come from the app itself, not from an emulator:

```bash
flutter test tool/screenshots_test.dart --update-goldens
```

The run reports an error, and that is expected — sound playback finds no plugin in a
widget test. The images are still all written.

The store icon next to them comes from the SVG like all the others:

```bash
rsvg-convert -w 512 -h 512 assets/icon/icon.svg \
  -o fastlane/metadata/android/de-DE/images/icon.png
```

The English version carries the same images, even though the screenshots are in
German: the description says the app speaks five languages. French, Spanish, and
Italian also carry copies (`fr-FR`, `es-ES`, `it-IT`); their change notes are created
only at release time.

## Translating

The app speaks German, English, French, Spanish, and Italian, and follows the language
of the device; any other language shows English. French, Spanish, and Italian are
**new translations** and are grateful for improvements — especially from native
speakers. Another language (or better wording) requires no programming skills:

* All texts are in **one file per language**: `lib/l10n/app_<language>.arb`, for
  example `app_fr.arb`. The German `app_de.arb` is the template; every other file has
  the same keys, only different texts.
* The text to translate is to the right of the colon. The key on the left stays
  unchanged.
* What is in **curly braces** is a placeholder (`{name}`, `{count}`, `{time}`) and
  must stay exactly as it is. The app inserts names, numbers, and times there. It may
  move to a different place in the sentence.
* Where `plural` appears (`{count, plural, =1{1 Tag} other{{count} Tage}}`), there is
  one text for the singular and one for the plural; only what is inside the inner
  braces is translated.
* What is meant is explained by the `@` entries in `app_de.arb`
  (`"@key": { "description": … }`), in English: where the text appears and what goes
  into a placeholder.
* The texts are for children aged 6 to 10 and their parents: short sentences, no
  technical terms.

You can send the file in two ways: as a pull request, or by attaching it to a GitHub
issue — the rest is up to the developer.

**This part the developer cannot leave to the translator:** how the time is spoken.
"Viertel vor 4" (de), "quarter to 4" (en), "4 h moins le quart" (fr), "4 menos cuarto"
(es), and "4 meno un quarto" (it) differ not only in the words, but in *which hour* is
named and whether it comes first or last. This is stated as a rule in
`lib/domain/clock_speech.dart`, and for a new language it is recorded there; the words
(`clockPhrase05` … `clockPhrase55`), however, come from the file. Anyone translating a
new language, please say how the clock is spoken there.

To check the file, run `flutter gen-l10n` and `flutter test test/l10n` — if a key or a
placeholder is missing, the test says which one.

## Publishing

How a new version is created and reaches criby.de, GitHub, and F-Droid is described
step by step in [RELEASE.md](RELEASE.md).

The F-Droid build recipe and the notes on inclusion are in [fdroid/](fdroid/). F-Droid
finds new versions by itself via the tags; the recipe does not need to be touched for
that.

## License

GNU General Public License, version 3 or later — the full text is in
[LICENSE](LICENSE).

The choice is deliberate, not accidental: this app has no advertising, no tracking, and
no account, and that is half its purpose. Under a more permissive license, someone could
take exactly this version, add advertising, and distribute the result as closed source.
The GPL requires that every distributed modification come with its source code.

## Privacy

The app sends nothing and requests no permission that accesses data, sensors, or the
network — in particular, no internet access. The only entry in the permission list is a
permission limited to the app's own signature, which an Android library generates so
that an internal receiver remains unreachable for other apps. The details are in
[DATENSCHUTZ.md](DATENSCHUTZ.md); the same file can serve as a privacy policy once it is
published at a public address — on GitHub, for example, at
<https://github.com/chrbayer/mt/blob/master/DATENSCHUTZ.md>.
