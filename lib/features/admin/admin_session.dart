import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// How long the parent area stays open without a touch before it closes
/// itself. See "Der Elternbereich schließt sich selbst" in CLAUDE.md for why
/// it does this at all.
const Duration adminIdleTimeout = Duration(minutes: 3);

/// Watches over a single open parent-area session and closes it - back to
/// whatever screen it was opened from - on either of two signals: nothing
/// touched for [adminIdleTimeout], or the app leaving the foreground.
///
/// [AdminSession.open] is called once, right after the PIN is accepted and
/// before the push that shows the parent area; [close] runs once that push's
/// `await` returns, however the area was actually left (back gesture, a
/// button somewhere inside, or [_expire] itself). That pairing is what keeps
/// this from ever leaving a [Timer] behind - a widget test that pumped past
/// one would fail with "A Timer is still pending", the same failure CLAUDE.md
/// already tells the story of for a different timer.
class AdminSession with WidgetsBindingObserver {
  final NavigatorState _navigator;
  final Route<Object?> _below;

  Timer? _idleTimer;

  /// >0 while a [holdOpen] action is in flight. Both signals are ignored
  /// during that window - see [holdOpen].
  int _holdCount = 0;

  bool _closed = false;

  /// The one session currently open, if any. [holdOpen] reaches it without
  /// every caller having to carry a reference to the session around.
  static AdminSession? _current;

  AdminSession._(this._navigator, this._below);

  /// Starts watching. [below] is the route the screen was still standing on
  /// right before the push - `ModalRoute.of(context)` taken before that push,
  /// by the caller.
  factory AdminSession.open(NavigatorState navigator, Route<Object?> below) {
    final session = AdminSession._(navigator, below);
    _current = session;
    WidgetsBinding.instance.addObserver(session);
    // A global pointer route rather than a listener inside the parent area's
    // own widget tree: it also has to see touches on screens pushed *on top*
    // of it - profile settings, the assignment editor, a confirmation
    // dialog - none of which anything in the parent area wraps. And it needs
    // nothing wired up in app.dart, so a widget test gets it for free too.
    GestureBinding.instance.pointerRouter.addGlobalRoute(session._onPointer);
    session._resetIdleTimer();
    return session;
  }

  void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent) _resetIdleTimer();
  }

  void _resetIdleTimer() {
    // Suspended for the duration of a holdOpen action; restarted once it
    // ends, see holdOpen.
    if (_holdCount > 0) return;
    _idleTimer?.cancel();
    _idleTimer = Timer(adminIdleTimeout, _expire);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_holdCount > 0) return;
    // Only these two mean the app actually left the foreground. `inactive`
    // alone also fires for something as harmless as a pulled-down
    // notification shade, and closing the parent area for that would train
    // a parent to distrust the very thing meant to protect them.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _expire();
    }
  }

  /// Runs [action] with both signals suspended, for the one kind of exit the
  /// parent area triggers itself: sharing a backup, or picking one to import,
  /// both send the app to the background on purpose. Closing the area out
  /// from under that would cut the share sheet off mid-share.
  ///
  /// A counter, not a bool, in case two such actions ever overlap. With no
  /// session open (a test that builds `BackupActions` on its own, say) it
  /// just runs [action].
  static Future<T> holdOpen<T>(Future<T> Function() action) async {
    final session = _current;
    if (session == null) return action();
    session._holdCount++;
    session._idleTimer?.cancel();
    try {
      return await action();
    } finally {
      session._holdCount--;
      // Idle time starts fresh from here, not from before the hold. If the
      // app is still backgrounded when the hold ends - the share sheet has
      // not returned control yet - nothing further happens now; it comes
      // back to the foreground on its own once sharing is done, and no
      // `paused` notification was missed, because none was suppressed that
      // this session still cares about.
      if (!session._closed) session._resetIdleTimer();
    }
  }

  void _expire() {
    if (_closed) return;
    final navigator = _navigator;
    final below = _below;
    // popUntil bypasses PopScope - which is exactly right here. A "discard
    // changes?" dialog in the profile settings behind this would be the
    // open door this is meant to close: nobody is there any more to answer
    // it, so unsaved changes are meant to fall away, silently.
    navigator.popUntil((route) => route == below || route.isFirst);
    close();
    // Only on expiry, never on an ordinary exit - a parent who closed it
    // themselves does not need telling why the profile screen is back.
    ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
      const SnackBar(content: Text('Elternbereich geschlossen.')),
    );
  }

  /// Stops watching. Idempotent, so it is safe to call both from [_expire]
  /// and, immediately afterwards, from the `await navigator.push(...)` in
  /// `AdminScreen.open` that [_expire]'s own popping just completed.
  void close() {
    if (_closed) return;
    _closed = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    WidgetsBinding.instance.removeObserver(this);
    if (identical(_current, this)) _current = null;
  }
}
