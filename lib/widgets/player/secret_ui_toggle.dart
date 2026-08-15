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
  late final FocusNode _focusNode;

  Offset? _startPoint;
  Offset? _lastPoint;

  int _stroke = 0;
  DateTime? _gestureStart;

  static const Duration _maxGestureDuration = Duration(seconds: 2);

  static const double _minimumStrokeDistance = 45;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleUi() {
    widget.visibility.value = !widget.visibility.value;
  }

  bool get _isTouchDevice {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // ─────────────────────────────────────────────
  // Z GESTURE
  // ─────────────────────────────────────────────

  void _resetGesture() {
    _startPoint = null;
    _lastPoint = null;
    _stroke = 0;
    _gestureStart = null;
  }

  void _startGesture(DragStartDetails details) {
    if (!_isTouchDevice) {
      return;
    }

    _startPoint = details.localPosition;
    _lastPoint = details.localPosition;
    _stroke = 0;
    _gestureStart = DateTime.now();
  }

  void _updateGesture(DragUpdateDetails details) {
    if (!_isTouchDevice || _lastPoint == null) {
      return;
    }

    final current = details.localPosition;

    final dx = current.dx - _lastPoint!.dx;
    final dy = current.dy - _lastPoint!.dy;

    if (dx.abs() < 5 && dy.abs() < 5) {
      return;
    }

    final horizontal = dx.abs() > dy.abs();

    // ─────────────────────────────
    // Stroke 1: →
    // ─────────────────────────────

    if (_stroke == 0 &&
        dx > 0 &&
        horizontal &&
        dx.abs() >= _minimumStrokeDistance) {
      _stroke = 1;
    }
    // ─────────────────────────────
    // Stroke 2: ↙
    // ─────────────────────────────
    else if (_stroke == 1 && dx < 0 && dy > 0 && dx.abs() > 5 && dy.abs() > 5) {
      _stroke = 2;
    }
    // ─────────────────────────────
    // Stroke 3: ←
    // ─────────────────────────────
    else if (_stroke == 2 &&
        dx < 0 &&
        horizontal &&
        dx.abs() >= _minimumStrokeDistance) {
      _stroke = 3;
    }

    _lastPoint = current;
  }

  void _endGesture(DragEndDetails details) {
    if (!_isTouchDevice ||
        _startPoint == null ||
        _lastPoint == null ||
        _gestureStart == null) {
      _resetGesture();
      return;
    }

    final elapsed = DateTime.now().difference(_gestureStart!);

    final totalDistance = (_lastPoint! - _startPoint!).distance;

    if (elapsed <= _maxGestureDuration &&
        _stroke == 3 &&
        totalDistance >= _minimumStrokeDistance) {
      _toggleUi();
    }

    _resetGesture();
  }

  // ─────────────────────────────────────────────
  // KEYBOARD SHORTCUT
  // Ctrl + Shift + Alt + H
  // ─────────────────────────────────────────────

  bool _isSecretKeyboardShortcut(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }

    return HardwareKeyboard.instance.isControlPressed &&
        HardwareKeyboard.instance.isShiftPressed &&
        HardwareKeyboard.instance.isAltPressed &&
        event.logicalKey == LogicalKeyboardKey.keyH;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (_isSecretKeyboardShortcut(event)) {
          _toggleUi();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _startGesture,
        onPanUpdate: _updateGesture,
        onPanEnd: _endGesture,
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

                // Secret gesture capture layer.
                //
                // Transparent छ, त्यसैले screen देखिँदैन।
                // IgnorePointer राखिएको छ ताकि Player UI को
                // normal interactions block नहोस्।
                if (!kIsWeb || _isTouchDevice)
                  const Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: ColoredBox(color: Colors.transparent),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
