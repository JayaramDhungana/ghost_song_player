import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'secret_message.dart';

class SecretUiToggle extends StatefulWidget {
  final ValueNotifier<bool> visibility;
  final Widget child;

  const SecretUiToggle({
    super.key,
    required this.visibility,
    required this.child,
  });

  @override
  State<SecretUiToggle> createState() => _SecretUiToggleState();
}

class _SecretUiToggleState extends State<SecretUiToggle> {
  Offset? _startPoint;
  Offset? _lastPoint;

  bool _validSwipe = false;
  DateTime? _gestureStart;

  static const Duration _maxGestureDuration = Duration(seconds: 2);
  static const double _minimumSwipeDistance = 45;

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Global keyboard listener.
    //
    // यसले TextField focus भएको बेला पनि
    // Ctrl + Shift + Alt + H सुन्छ।
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SECRET TOGGLE
  // ─────────────────────────────────────────────

  void _toggleUi() {
    widget.visibility.value = !widget.visibility.value;
  }

  // ─────────────────────────────────────────────
  // GLOBAL KEYBOARD
  //
  // Ctrl + Shift + Alt + H
  // ─────────────────────────────────────────────

  bool _handleGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }

    final keyboard = HardwareKeyboard.instance;

    final isShortcut =
        keyboard.isControlPressed &&
        keyboard.isShiftPressed &&
        keyboard.isAltPressed &&
        event.logicalKey == LogicalKeyboardKey.keyH;

    if (!isShortcut) {
      return false;
    }

    _toggleUi();

    // Event consume गर्ने।
    return true;
  }

  // ─────────────────────────────────────────────
  // MOBILE DEVICE
  // ─────────────────────────────────────────────

  bool get _isTouchDevice {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // ─────────────────────────────────────────────
  // MOBILE SECRET GESTURE
  //
  // माथिबाट तल तान्ने
  // ↓
  // ─────────────────────────────────────────────

  void _resetGesture() {
    _startPoint = null;
    _lastPoint = null;
    _validSwipe = false;
    _gestureStart = null;
  }

  void _startGesture(Offset localPosition) {
    if (!_isTouchDevice) {
      return;
    }

    _startPoint = localPosition;
    _lastPoint = localPosition;
    _validSwipe = false;
    _gestureStart = DateTime.now();
  }

  void _updateGesture(Offset localPosition) {
    if (!_isTouchDevice || _startPoint == null) {
      return;
    }

    final current = localPosition;

    final dx = current.dx - _startPoint!.dx;
    final dy = current.dy - _startPoint!.dy;

    // सीधा तलतिर गएको हुनुपर्छ।
    if (dy >= _minimumSwipeDistance && dy.abs() > dx.abs() * 1.5) {
      _validSwipe = true;
    }

    _lastPoint = current;
  }

  void _endGesture() {
    if (!_isTouchDevice ||
        !_validSwipe ||
        _startPoint == null ||
        _lastPoint == null ||
        _gestureStart == null) {
      _resetGesture();
      return;
    }

    final elapsed = DateTime.now().difference(_gestureStart!);

    final dx = _lastPoint!.dx - _startPoint!.dx;
    final dy = _lastPoint!.dy - _startPoint!.dy;

    final isVerticalDownSwipe =
        dy >= _minimumSwipeDistance && dy.abs() > dx.abs() * 1.5;

    if (elapsed <= _maxGestureDuration && isVerticalDownSwipe) {
      _toggleUi();
    }

    _resetGesture();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onScaleStart: (details) {
        if (details.pointerCount == 2) {
          _startGesture(details.localFocalPoint);
        } else {
          _resetGesture();
        }
      },
      onScaleUpdate: (details) {
        if (details.pointerCount == 2) {
          _updateGesture(details.localFocalPoint);
        }
      },
      onScaleEnd: (details) {
        _endGesture();
      },

      child: ValueListenableBuilder<bool>(
        valueListenable: widget.visibility,
        builder: (context, isVisible, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isVisible
                    ? KeyedSubtree(
                        key: const ValueKey('player'),
                        child: widget.child,
                      )
                    : const KeyedSubtree(
                        key: ValueKey('secret-message'),
                        child: SecretMessage(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
