import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final VoidCallback onRCVehicleDataTap;

  const DrawerMenu({
    super.key,
    required this.onRCVehicleDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.flip(
                    flipX: true,
                    child: const Text(
                      '🦅',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'GARUDA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.orange),
              title: const Text(
                'RC Vehicle Data',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onRCVehicleDataTap,
            ),
            const Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
