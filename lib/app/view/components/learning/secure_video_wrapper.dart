import 'dart:math';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:get/get.dart';

class SecureVideoWrapper extends StatefulWidget {
  final Widget child;

  const SecureVideoWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<SecureVideoWrapper> createState() => _SecureVideoWrapperState();
}

class _SecureVideoWrapperState extends State<SecureVideoWrapper> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _animationController;
  final Random _random = Random();
  
  // Watermark positioning
  double _xPos = 0;
  double _yPos = 0;
  double _targetX = 0;
  double _targetY = 0;

  @override
  void initState() {
    super.initState();
    _initScreenProtection();
    
    // Animation for moving watermark
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(() {
        setState(() {
          // Slowly interpolate towards target
          _xPos += (_targetX - _xPos) * 0.005;
          _yPos += (_targetY - _yPos) * 0.005;
          
          // If close enough, pick new target
          if ((_targetX - _xPos).abs() < 5 && (_targetY - _yPos).abs() < 5) {
            _pickNewTarget();
          }
        });
      });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickNewTarget();
      _xPos = _targetX;
      _yPos = _targetY;
      _animationController.repeat();
    });
  }
  
  void _pickNewTarget() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    // Keep it within reasonable bounds of the video player
    final maxWidth = size.width > 200 ? size.width - 150 : 50.0;
    final maxHeight = size.height > 150 ? size.height - 100 : 50.0;
    
    _targetX = _random.nextDouble() * maxWidth; 
    _targetY = _random.nextDouble() * maxHeight; 
  }

  void _initScreenProtection() async {
    await ScreenProtector.preventScreenshotOn();
    
    ScreenProtector.addListener(
      () {
        // Screenshot taken callback (iOS)
        _setRecordingState(true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _setRecordingState(false);
        });
      },
      (bool isRecording) {
        // Screen recording state changed
        _setRecordingState(isRecording);
      }
    );
    
    // Initial check
    final isRecording = await ScreenProtector.isRecording();
    _setRecordingState(isRecording);
  }
  
  void _setRecordingState(bool isRecording) {
    if (mounted) {
      setState(() {
        _isRecording = isRecording;
      });
    }
  }

  @override
  void dispose() {
    ScreenProtector.removeListener();
    ScreenProtector.preventScreenshotOff();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String watermarkText = "Protected Content";
    try {
      final sessionStore = Get.find<SessionStore>();
      final userInfo = sessionStore.userInfo;
      if (userInfo != null) {
        final name = "${userInfo.first_name ?? ''} ${userInfo.last_name ?? ''}".trim();
        final email = userInfo.email ?? '';
        final id = userInfo.id != null ? "ID: ${userInfo.id}" : "";
        watermarkText = [if (name.isNotEmpty) name, if (email.isNotEmpty) email, if (id.isNotEmpty) id].join("\n");
        if (watermarkText.isEmpty) watermarkText = "Protected Content";
      }
    } catch (_) {
      // Ignore if store not found
    }

    // Dynamic scale for watermark (Disabled)
    // final scale = 0.8 + (_random.nextDouble() * 0.4);

    return Stack(
      children: [
        // The actual video content
        widget.child,
        
        // Moving Watermark Overlay (Disabled as requested)
        /*
        if (!_isRecording)
          Positioned(
            left: _xPos,
            top: _yPos,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: 0.35 + (_random.nextDouble() * 0.1),
                child: Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: -0.15, // slight diagonal tilt
                    child: Text(
                      watermarkText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 3.0,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        */
          
        // Blur / Block Overlay if Recording
        if (_isRecording)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.95),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, color: Colors.redAccent, size: 50),
                    SizedBox(height: 16),
                    Text(
                      "Screen Recording Detected",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Playback is paused to protect content.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
