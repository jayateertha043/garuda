import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:velocity_x/velocity_x.dart';

class GarudaTitle extends StatelessWidget {
  const GarudaTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: context.isMobile ? 42 : 12,
      left: 0,
      right: 0,
      child: Center(
        child: PointerInterceptor(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.orange.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.flip(
                  flipX: true,
                  child: Text(
                    '🦅',
                    style: TextStyle(
                      fontSize: context.isMobile ? 16 : 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'GARUDA',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: context.isMobile ? 11 : 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                    letterSpacing: 4,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.orange,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 16,
                        color: Colors.deepOrange,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '🦅',
                  style: TextStyle(
                    fontSize: context.isMobile ? 16 : 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
