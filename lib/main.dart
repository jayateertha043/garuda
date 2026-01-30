import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

//Global Variables
String dateTextStr = "Since (Optional)";
String distanceStr = "Within";
String dateTextStr1 = "Until (Optional)";
String instagramJson = "";
latlng.LatLng myLatlng = const latlng.LatLng(13.0827, 80.2707);
bool isMedia = false;
// Use `instaMarkersProvider` (below) to hold flutter_map markers so UI rebuilds.

//Text Editing Contollers
TextEditingController dateInput = TextEditingController();
TextEditingController dateInput1 = TextEditingController();
TextEditingController searchCntrl = TextEditingController();
TextEditingController latControl = TextEditingController();
TextEditingController lngControl = TextEditingController();
TextEditingController distControl = TextEditingController();

//States
final latLngProvider = StateProvider((ref) => myLatlng);
final instaMarkersProvider = StateProvider((ref) => <Marker>[]);
final MediaProvider = StateProvider((ref) => isMedia);
final distanceProvider = StateProvider((ref) => distanceStr);
final DateTextProvider1 = StateProvider((ref) => dateTextStr);
final DateTextProvider2 = StateProvider((ref) => dateTextStr1);
final SearchProvider = StateProvider((ref) => '');

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garuda',
      debugShowCheckedModeBanner: false,
      // darkTheme: ThemeData.dark(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.orangeAccent,
        textTheme: const TextTheme(
          titleMedium: TextStyle(
              fontSize: 12,
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold), // default TextField input style
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.only(top: 2),
          isCollapsed: true,
          fillColor: Colors.white,
          filled: true,
          hintStyle: TextStyle(
              fontSize: 12,
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold),
        ),
      ),

      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        //alignment: Alignment.topCenter,
        children: [
          Consumer(builder: (context, ref, child) {
            return getMap(ref);
          }),
          Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: context.isMobile ? 55 : 25,
              ),
              Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width * 0.6,
                height: context.isMobile
                    ? MediaQuery.of(context).size.height * 0.04
                    : MediaQuery.of(context).size.height * 0.10,
                child: PointerInterceptor(
                    child: Align(
                  alignment: Alignment.center,
                  child: Container(child: Consumer(
                    builder: (context, ref, child) {
                      return TextField(
                        minLines: null,
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        controller: null,
                        onChanged: (value) {
                          ref.read(SearchProvider.notifier).state = value;
                        },
                        decoration: InputDecoration(
                          //fillColor: Colors.white,
                          hintText: 'Search for tags, words ...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      );
                    },
                  )),
                )),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: context.isMobile
                    ? MediaQuery.of(context).size.height * 0.13
                    : MediaQuery.of(context).size.height * 0.2,
              ),
              Container(
                height: 2,
              ),
              PointerInterceptor(
                  child: SizedBox(
                      width: context.isMobile
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width * 0.1,
                      height: context.isMobile
                          ? MediaQuery.of(context).size.height * 0.04
                          : MediaQuery.of(context).size.height * 0.04,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final LatLngWatcher = ref.watch(latLngProvider);
                          return TextField(
                            minLines: null,
                            maxLines: null,
                            expands: true,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            controller: latControl,
                            onChanged: (value) {
                              num newLat = double.parse(value);
                              num oldLng = LatLngWatcher.longitude;
                              latlng.LatLng newLatLng = latlng.LatLng(newLat as double, oldLng as double);
                              ref.read(latLngProvider.notifier).state =
                                  newLatLng;
                            },
                            decoration: InputDecoration(
                              //fillColor: Colors.white,
                              hintText: LatLngWatcher.latitude.toString(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                        },
                      ))),
              Container(
                height: 2,
              ),
              PointerInterceptor(
                  child: SizedBox(
                      width: context.isMobile
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width * 0.1,
                      height: context.isMobile
                          ? MediaQuery.of(context).size.height * 0.04
                          : MediaQuery.of(context).size.height * 0.04,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final LatLngWatcher = ref.watch(latLngProvider);
                          return TextField(
                            minLines: null,
                            maxLines: null,
                            expands: true,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            controller: lngControl,
                            onChanged: (value) {
                              num newLng = double.parse(value);
                              num oldLat = LatLngWatcher.latitude;
                              latlng.LatLng newLatLng = latlng.LatLng(oldLat as double, newLng as double);
                              ref.read(latLngProvider.notifier).state =
                                  newLatLng;
                            },
                            decoration: InputDecoration(
                              hintText: LatLngWatcher.longitude.toString(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                        },
                      ))),
              Container(
                height: 2,
              ),
              Row(
                children: [
                  PointerInterceptor(child: Consumer(
                    builder: (context, ref, child) {
                      final isMediaWatcher = ref.watch(MediaProvider);
                      return Checkbox(
                        fillColor: WidgetStateProperty.all(Colors.white),
                        checkColor: Colors.orange,
                        value: isMediaWatcher,
                        onChanged: (bool? value) {
                          ref.read(MediaProvider.notifier).state = value!;
                        },
                      );
                    },
                  )),
                  const Text(
                    "Media",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              PointerInterceptor(
                  child: Row(
                children: [
                  SizedBox(
                    width: context.isMobile
                        ? MediaQuery.of(context).size.width * 0.3
                        : MediaQuery.of(context).size.width * 0.1,
                    height: context.isMobile
                        ? MediaQuery.of(context).size.height * 0.04
                        : MediaQuery.of(context).size.height * 0.04,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final date1Watcher = ref.watch(DateTextProvider1);
                        return TextField(
                            minLines: null,
                            maxLines: null,
                            expands: true,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.datetime,
                            controller: dateInput,
                            decoration: InputDecoration(
                                hintText:
                                    DateTime.tryParse(date1Watcher) == null
                                        ? "Since (Optional)"
                                        : date1Watcher.substring(0, 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  builder: (ctx, child) =>
                                      PointerInterceptor(child: child!),
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(
                                      2000), //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime(2101));
                              ref.read(DateTextProvider1.notifier).state = "";
                              ref.read(DateTextProvider1.notifier).state =
                                  pickedDate.toString().substring(0, 10);
                            });
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                  ),
                  PointerInterceptor(
                      child: SizedBox(
                    width: context.isMobile
                        ? MediaQuery.of(context).size.width * 0.3
                        : MediaQuery.of(context).size.width * 0.1,
                    height: context.isMobile
                        ? MediaQuery.of(context).size.height * 0.04
                        : MediaQuery.of(context).size.height * 0.04,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final date2Watcher = ref.watch(DateTextProvider2);
                        return TextField(
                            minLines: null,
                            maxLines: null,
                            expands: true,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.datetime,
                            controller: dateInput1,
                            decoration: InputDecoration(
                                hintText:
                                    DateTime.tryParse(date2Watcher) == null
                                        ? "Until (Optional)"
                                        : date2Watcher.substring(0, 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  builder: (ctx, child) =>
                                      PointerInterceptor(child: child!),
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(
                                      2000), //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime(2101));
                              ref.read(DateTextProvider2.notifier).state =
                                  pickedDate.toString().substring(0, 10);
                            });
                      },
                    ),
                  )),
                  Container(
                    width: 1,
                  ),
                ],
              )),
              Container(
                height: 2,
              ),
              PointerInterceptor(
                  child: SizedBox(
                width: context.isMobile
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.1,
                height: context.isMobile
                    ? MediaQuery.of(context).size.height * 0.04
                    : MediaQuery.of(context).size.height * 0.04,
                child: Consumer(
                  builder: (context, ref, child) {
                    final distanceWatcher = ref.watch(distanceProvider);
                    return TextField(
                      minLines: null,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      controller: distControl,
                      onChanged: (value) {
                        ref.read(distanceProvider.notifier).state = "";
                        ref.read(distanceProvider.notifier).state =
                            int.tryParse(value) == null
                                ? ""
                                : int.parse(value) > 0
                                    ? value
                                    : "5";
                      },
                      decoration: InputDecoration(
                          suffix: const Text("(km)"),
                          hintText: int.tryParse(distanceWatcher) == null &&
                                  distanceWatcher != distanceStr
                              ? distanceWatcher
                              : distanceStr,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                    );
                  },
                ),
              ))
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              final LatLngWatcher = ref.watch(latLngProvider);
              final isMediaWatcher = ref.watch(MediaProvider);
              final distanceWatcher = ref.watch(distanceProvider);
              final date1Watcher = ref.watch(DateTextProvider1);
              final date2Watcher = ref.watch(DateTextProvider2);
              final searchWatcher = ref.watch(SearchProvider);
              return FabCircularMenu(
                fabMargin: const EdgeInsets.all(24),
                fabColor: Colors.transparent,
                ringColor: Colors.transparent,
                fabChild: PointerInterceptor(
                  child: const FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: null,
                    child: FaIcon(FontAwesomeIcons.bars, size: 24),
                  ),
                ),
                alignment: Alignment.bottomCenter,
                //ringWidth: 10,
                ringDiameter: 500,
                children: [
                  PointerInterceptor(
                    child: FloatingActionButton(
                      onPressed: () async {
                        var near = "geocode:";
                        if (searchWatcher != "") {
                          near = " geocode:";
                        }

                        String url =
                          "https://twitter.com/search?q=${searchWatcher}$near${LatLngWatcher.latitude},${LatLngWatcher.longitude}";
                        if (int.tryParse(distanceWatcher) != null) {
                          if (int.parse(distanceWatcher) > 0) {
                            url = "$url,${distanceWatcher}km";
                          } else {
                            url = "$url,5km";
                          }
                        } else {
                          url = "$url,5km";
                        }
                        if (isMediaWatcher) {
                          url = "$url filter:media";
                        }
                        if (DateTime.tryParse(date1Watcher) != null) {
                          url =
                              "$url since:${ref.read(DateTextProvider1.notifier).state}";
                        }
                        if (DateTime.tryParse(date2Watcher) != null) {
                          url =
                              "$url until:${ref.read(DateTextProvider2.notifier).state}";
                        }

                        await launchUrl(Uri.parse(url));
                      },
                      backgroundColor: Colors.blue,
                      child: const FaIcon(FontAwesomeIcons.twitter),
                    ),
                  ),
                  PointerInterceptor(
                    child: FloatingActionButton(
                      onPressed: () async {
                        final url =
                          "https://map.snapchat.com/@${LatLngWatcher.latitude},${LatLngWatcher.longitude},15z";
                        await launchUrl(Uri.parse(url));
                      },
                      backgroundColor: Colors.yellow,
                      child: const FaIcon(FontAwesomeIcons.snapchat),
                    ),
                  ),
                  PointerInterceptor(
                    child: FloatingActionButton(
                      onPressed: () async {
                        String url =
                          "https://www.instagram.com/location_search/?latitude=${LatLngWatcher.latitude}&longitude=${LatLngWatcher.longitude}";
                        _showDialog(context, ref, url);
                      },
                      backgroundColor: Colors.pinkAccent,
                      child: const FaIcon(FontAwesomeIcons.instagram),
                    ),
                  ),
                  PointerInterceptor(
                    child: FloatingActionButton(
                      onPressed: () async {
                        var url =
                          "https://mattw.io/youtube-geofind/location?location=${LatLngWatcher.latitude},${LatLngWatcher.longitude}";
                        if (searchWatcher != "") {
                          url = "$url&keywords=$searchWatcher";
                        }
                        if (int.tryParse(distanceWatcher) != null) {
                          if (int.parse(distanceWatcher) > 0) {
                            url = "$url&radius=$distanceWatcher";
                          } else {
                            url = url = "$url&radius=5";
                          }
                        } else {
                          url = url = "$url&radius=5";
                        }
                        url = "$url&pages=5&doSearch=true";
                        await launchUrl(Uri.parse(url));
                      },
                      backgroundColor: Colors.red,
                      child: const FaIcon(FontAwesomeIcons.youtube),
                    ),
                  ),
                  PointerInterceptor(
                    child: FloatingActionButton(
                      onPressed: () async {
                        var near = "geo:";
                        var tags = isMediaWatcher ? "has_screenshot:true " : "";

                        if (searchWatcher != "") {
                          tags = searchWatcher;
                          near = " geo:";
                        }

                        String url =
                          "https://www.shodan.io/search?query=$tags$near${LatLngWatcher.latitude},${LatLngWatcher.longitude}";
                        if (int.tryParse(distanceWatcher) != null) {
                          if (int.parse(distanceWatcher) > 0) {
                            url = "$url,$distanceWatcher";
                          } else {
                            url = "$url,10";
                          }
                        } else {
                          url = "$url,10";
                        }

                        await launchUrl(Uri.parse(url));
                      },
                      backgroundColor: Colors.black26,
                      child: Image.asset("assets/shodan.png"),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

final MapController mapController = MapController();

Widget getMap(WidgetRef ref) {
  final current = ref.watch(latLngProvider);

  // Build marker widgets: center marker + any instaMarkers from provider
  final markerWatcher = ref.watch(instaMarkersProvider);
  final List<Marker> markers = [
    Marker(
      width: 40,
      height: 40,
      point: latlng.LatLng(current.latitude, current.longitude),
      child: const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 36,
      ),
    ),
    ...markerWatcher,
  ];

  return Stack(
    children: [
      FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: current,
          initialZoom: 8,
          minZoom: 2,
          maxZoom: 20,
          onTap: (tapPosition, point) {
            ref.read(latLngProvider.notifier).state = point;
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      // Zoom controls positioned at top-right
      Positioned(
        top: 16,
        right: 16,
        child: Column(
          children: [
            FloatingActionButton(
              mini: true,
              onPressed: () {
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom + 1,
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              mini: true,
              onPressed: () {
                mapController.move(
                  mapController.camera.center,
                  (mapController.camera.zoom - 1).clamp(2.0, 20.0),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.remove, color: Colors.black),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

Future<void> _showDialog(BuildContext context, WidgetRef ref, String url) {
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
                      onPressed: () async { await _launchInBrowser(Uri.parse(url)); },
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
                                  onTap: () async { if (markerUrl.isNotEmpty) await _launchInBrowser(Uri.parse(markerUrl)); },
                                  child: const Icon(Icons.location_on, color: Colors.pink, size: 30),
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
