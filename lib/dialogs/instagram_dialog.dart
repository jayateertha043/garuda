import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';

Future<void> launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

Future<void> showInstagramDialog(BuildContext context, WidgetRef ref, String url) {
  return showDialog(
    context: context,
    builder: (builder) {
      return PointerInterceptor(
        child: AlertDialog(
          title: const Text('Instagram Nearby Search'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("1. You need to be signed in to instagram"),
                const Text("2. Click instagram icon to open instagram."),
                const Text("3. Copy the json text from the instagram page opened in new tab."),
                const Text("4. Click the Below Paste Button."),
                const Text("5. Click Submit"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () async { await launchInBrowser(Uri.parse(url)); },
                      child: const FaIcon(FontAwesomeIcons.instagram),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                      onPressed: () {
                        FlutterClipboard.paste().then((value) { instagramJson = value; });
                      },
                      child: const Text("Paste"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        final List<Marker> newMarkers = [];
                        dynamic data;
                        try { data = jsonDecode(instagramJson); } catch (_) { data = null; }
                        if (data != null && data["status"] == "ok") {
                          final List<dynamic> venues = data["venues"];
                          for (final venue in venues) {
                            final double? lat = (venue["lat"] is num) ? (venue["lat"] as num).toDouble() : null;
                            final double? lng = (venue["lng"] is num) ? (venue["lng"] as num).toDouble() : null;
                            if (lat != null && lng != null && venue["external_id_source"] == "facebook_places") {
                              final instaLatLng = latlng.LatLng(lat, lng);
                              final markerUrl = "https://www.instagram.com/explore/locations/${venue["external_id"]}/";
                              final instaMarker = Marker(
                                width: 36,
                                height: 36,
                                point: instaLatLng,
                                child: GestureDetector(
                                  onTap: () async { if (markerUrl.isNotEmpty) await launchInBrowser(Uri.parse(markerUrl)); },
                                  child: Transform.flip(
                                    flipX: true,
                                    child: const Text(
                                      '🦅',
                                      style: TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                              );
                              newMarkers.add(instaMarker);
                            }
                          }
                        }
                        ref.read(instaMarkersProvider.notifier).state = newMarkers;
                        Navigator.of(context).maybePop();
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        ref.read(instaMarkersProvider.notifier).state = [];
                        Navigator.of(context).maybePop();
                      },
                      child: const Text("Clear Markers"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () { Navigator.of(context).maybePop(); },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
