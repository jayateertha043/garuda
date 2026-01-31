import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlng;

// Global Variables
String dateTextStr = "Since (Optional)";
String distanceStr = "Within";
String dateTextStr1 = "Until (Optional)";
String instagramJson = "";
latlng.LatLng myLatlng = const latlng.LatLng(13.0827, 80.2707);
bool isMedia = false;

// State Providers
final latLngProvider = StateProvider((ref) => myLatlng);
final instaMarkersProvider = StateProvider((ref) => <Marker>[]);
final mediaProvider = StateProvider((ref) => isMedia);
final distanceProvider = StateProvider((ref) => distanceStr);
final dateTextProvider1 = StateProvider((ref) => dateTextStr);
final dateTextProvider2 = StateProvider((ref) => dateTextStr1);
final searchProvider = StateProvider((ref) => '');
