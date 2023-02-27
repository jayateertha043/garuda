import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps/google_maps.dart';
import 'dart:ui' as ui;
import 'dart:html';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

LatLng myLatlng = new LatLng(13.0827, 80.2707);
bool isMedia = false;
String dateTextStr = "Since (Optional)";
String distanceStr = "Within";
String dateTextStr1 = "Until (Optional)";
TextEditingController dateInput = new TextEditingController();
TextEditingController dateInput1 = new TextEditingController();
TextEditingController searchCntrl = new TextEditingController();
List<Marker> instaMarkers = <Marker>[];
final latLngProvider = StateProvider((ref) => myLatlng);
final instaMarkersProvider = StateProvider((ref) => <Marker>[]);
final MediaProvider = StateProvider((ref) => isMedia);
final distanceProvider = StateProvider((ref) => distanceStr);
final DateTextProvider1 = StateProvider((ref) => dateTextStr);
final DateTextProvider2 = StateProvider((ref) => dateTextStr1);
final SearchProvider = StateProvider((ref) => '');
String instagramJson = "";
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garuda',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme:
              InputDecorationTheme(fillColor: Colors.white, filled: true)),
      home: const Home(),
    );
  }
}

final latControl = new TextEditingController();

final lngControl = new TextEditingController();
final distControl = new TextEditingController();

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LatLngWatcher = ref.watch(latLngProvider);
    final isMediaWatcher = ref.watch(MediaProvider);
    final distanceWatcher = ref.watch(distanceProvider);
    final date1Watcher = ref.watch(DateTextProvider1);
    final date2Watcher = ref.watch(DateTextProvider2);
    final searchWatcher = ref.watch(SearchProvider);
    final instaMarkerWatcher = ref.watch(instaMarkersProvider);
    return Material(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          getMap(ref),
          Column(
            children: [
              Container(
                height: 25,
              ),
              Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.025,
                child: PointerInterceptor(
                    child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: TextField(
                    controller: null,
                    onChanged: (value) {
                      ref.read(SearchProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Search for tags, words ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
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
                height: MediaQuery.of(context).size.width * 0.065,
              ),
              Container(
                height: 2,
              ),
              PointerInterceptor(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.025,
                      child: TextField(
                        controller: latControl,
                        onChanged: (value) {
                          num newLat = double.parse(value);
                          num oldLng = LatLngWatcher.lng;
                          LatLng newLatLng = new LatLng(newLat, oldLng);
                          ref.read(latLngProvider.notifier).state = newLatLng;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: LatLngWatcher.lat.toString(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ))),
              Container(
                height: 2,
              ),
              PointerInterceptor(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.025,
                      child: TextField(
                        controller: lngControl,
                        onChanged: (value) {
                          num newLng = double.parse(value);
                          num oldLat = LatLngWatcher.lat;
                          LatLng newLatLng = new LatLng(oldLat, newLng);
                          ref.read(latLngProvider.notifier).state = newLatLng;
                        },
                        decoration: InputDecoration(
                          hintText: LatLngWatcher.lng.toString(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ))),
              Container(
                height: 2,
              ),
              Row(
                children: [
                  PointerInterceptor(
                      child: Checkbox(
                    value: isMediaWatcher,
                    onChanged: (bool? value) {
                      ref.read(MediaProvider.notifier).state = value!;
                    },
                  )),
                  Text(
                    "Media",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              PointerInterceptor(
                  child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.025,
                    child: TextField(
                        keyboardType: TextInputType.datetime,
                        controller: dateInput,
                        decoration: InputDecoration(
                            hintText: DateTime.tryParse(date1Watcher) == null
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
                          print(pickedDate);
                          print(date1Watcher);
                          ;
                        }),
                  ),
                  Container(
                    width: 1,
                  ),
                  PointerInterceptor(
                      child: Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.025,
                    child: TextField(
                        keyboardType: TextInputType.datetime,
                        controller: dateInput1,
                        decoration: InputDecoration(
                            hintText: DateTime.tryParse(date2Watcher) == null
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
                          print(pickedDate);
                          print(date2Watcher);
                        }),
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
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.025,
                child: TextField(
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
                      suffix: Text("(km)"),
                      hintText: int.tryParse(distanceWatcher) == null &&
                              distanceWatcher != distanceStr
                          ? distanceWatcher
                          : distanceStr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                ),
              ))
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PointerInterceptor(
                    child: FloatingActionButton(
                  onPressed: () async {
                    String tags = "";
                    String near = "geocode:";
                    bool tagSet = false;
                    if (searchWatcher != "" && searchWatcher != null) {
                      tags = searchWatcher;
                      near = " geocode:";
                    }

                    String url = "https://twitter.com/search?q=" +
                        tags +
                        near +
                        LatLngWatcher.lat.toString() +
                        "," +
                        LatLngWatcher.lng.toString();
                    if (int.tryParse(distanceWatcher) != null) {
                      if (int.parse(distanceWatcher) > 0) {
                        url = url + "," + distanceWatcher + "km";
                      } else {
                        url = url + "," + "5" + "km";
                      }
                    } else {
                      url = url + "," + "5" + "km";
                    }
                    if (isMediaWatcher) {
                      url = url + " filter:media";
                    }
                    if (DateTime.tryParse(date1Watcher) != null) {
                      url = url +
                          " since:" +
                          ref.read(DateTextProvider1.notifier).state;
                    }
                    if (DateTime.tryParse(date2Watcher) != null) {
                      url = url +
                          " until:" +
                          ref.read(DateTextProvider2.notifier).state;
                    }

                    await launchUrl(Uri.parse(url));
                    print("clicked");
                  },
                  backgroundColor: Colors.blue,
                  child: const FaIcon(FontAwesomeIcons.twitter),
                )),
                Container(
                  width: 2,
                ),
                PointerInterceptor(
                    child: FloatingActionButton(
                  onPressed: () async {
                    String tags = "";
                    String url = "https://map.snapchat.com/@" +
                        LatLngWatcher.lat.toString() +
                        "," +
                        LatLngWatcher.lng.toString() +
                        ",15z";
                    await launchUrl(Uri.parse(url));
                    print("clicked");
                  },
                  backgroundColor: Colors.yellow,
                  child: const FaIcon(FontAwesomeIcons.snapchat),
                )),
                Container(
                  width: 2,
                ),
                PointerInterceptor(
                    child: FloatingActionButton(
                  onPressed: () async {
                    String url =
                        "https://www.instagram.com/location_search/?latitude=" +
                            LatLngWatcher.lat.toString() +
                            "&longitude=" +
                            LatLngWatcher.lng.toString();
                    _showDialog(context, ref, url);
                    String tags = "";

                    //await launchUrl(Uri.parse(url));
                    print("clicked");
                  },
                  backgroundColor: Colors.pinkAccent,
                  child: const FaIcon(FontAwesomeIcons.instagram),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

final mapOptions = new MapOptions()
  ..zoom = 8
  ..center = myLatlng;

String htmlId = "7";

final elem = DivElement()
  ..id = htmlId
  ..style.width = "100%"
  ..style.height = "100%"
  ..style.border = 'none';
final map = GMap(elem, mapOptions);

Marker marker = Marker(MarkerOptions()
  ..position = myLatlng
  ..map = map
  ..title = 'Hello World!');
Widget getMap(WidgetRef ref) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
    map.onClick.listen((mapsMouseEvent) {
      myLatlng = mapsMouseEvent.latLng!;
      ref.read(latLngProvider.notifier).state = mapsMouseEvent.latLng!;
      marker.position = myLatlng;
    });

    return elem;
  });

  return HtmlElementView(viewType: htmlId);
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
            contentPadding: EdgeInsets.zero,
            title: Text('Instagram Nearby Search'),
            content: Container(
                margin: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("1. You need to be signed in to instagram"),
                    Text("2. Click instagram icon to open instagram."),
                    Text(
                        "3. Copy the json text from the instagram page opened in new tab."),
                    Text("3. Click the Below Paste Button."),
                    Text("4. Click Generate Markers"),
                    Container(
                      height: 5,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await _launchInBrowser(Uri.parse(url));
                            },
                            child: FaIcon(FontAwesomeIcons.instagram)),
                        Container(
                          width: 2,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              FlutterClipboard.paste().then((value) {
                                // Do what ever you want with the value.
                                instagramJson = value;
                                print(instagramJson);
                              });
                            },
                            child: Text("Paste")),
                        Container(
                          width: 2,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.greenAccent,
                            ),
                            onPressed: () {
                              instaMarkers.clear();
                              dynamic data = jsonDecode(instagramJson);
                              if (data["status"] == "ok") {
                                List<dynamic> venues = data["venues"];
                                for (dynamic venue in venues) {
                                  double? lat = venue["lat"];
                                  double? lng = venue["lng"];
                                  if (lat != null && lng != null) {
                                    LatLng instaLatLng = LatLng(lat, lng);
                                    String title = "";
                                    String markerUrl = "";
                                    if (venue["external_id_source"] ==
                                        "facebook_places") {
                                      markerUrl =
                                          "https://www.instagram.com/explore/locations/" +
                                              venue["external_id"].toString() +
                                              "/";
                                      Marker instaMarker =
                                          new Marker(MarkerOptions()
                                            ..position = instaLatLng
                                            ..icon =
                                                "http://maps.google.com/mapfiles/ms/icons/pink-pushpin.png"
                                            ..map = map);
                                      instaMarker.onClick.listen((event) async {
                                        await _launchInBrowser(
                                            Uri.parse(markerUrl));
                                      });
                                      instaMarker.set("url", markerUrl);

                                      String venueName = venue["name"] != null
                                          ? venue["name"]
                                          : "";
                                      String venueAddress =
                                          venue["address"] != null
                                              ? venue["address"]
                                              : "";
                                      instaMarker.title =
                                          venueName + "\n\n" + venueAddress;
                                      instaMarkers.add(instaMarker);
                                    }
                                  }
                                }
                              }
                              Navigator.of(context).maybePop();
                            },
                            child: Text("Generate Markers")),
                        Container(
                          width: 2,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              for (Marker m in instaMarkers) {
                                m.map = null;
                              }
                              instaMarkers.clear();
                              //instaMarkers.length = 0;
                              Navigator.of(context).maybePop();
                            },
                            child: Text("Clear Markers"))
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent,
                        ),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                        child: Text("Close"))
                  ],
                )),
          ),
        );
      });
}
