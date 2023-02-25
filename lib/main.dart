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
final latLngProvider = StateProvider((ref) => myLatlng);
final MediaProvider = StateProvider((ref) => isMedia);
final distanceProvider = StateProvider((ref) => distanceStr);
final DateTextProvider1 = StateProvider((ref) => dateTextStr);
final DateTextProvider2 = StateProvider((ref) => dateTextStr1);
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
    return Material(
      child: Stack(
        children: [
          getMap(ref),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    String url = "https://twitter.com/search?q=" +
                        tags +
                        "near:" +
                        LatLngWatcher.lat.toString() +
                        "," +
                        LatLngWatcher.lng.toString();
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
                    if (int.tryParse(distanceWatcher) != null) {
                      if (int.parse(distanceWatcher) > 0) {
                        url = url + " within:" + distanceWatcher + "km";
                      }
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
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget getMap(WidgetRef ref) {
  String htmlId = "7";

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
    final mapOptions = new MapOptions()
      ..zoom = 8
      ..center = myLatlng;

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
