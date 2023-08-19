import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_weather/model/forecast_result.dart';
import 'package:flutter_weather/model/weather_model.dart';
import 'package:flutter_weather/network/open_weather_map.dart';
import 'package:flutter_weather/state/state.dart';
import 'package:flutter_weather/utils/utils.dart';
import 'package:flutter_weather/widgets/fore_cast_widget.dart';
import 'package:flutter_weather/widgets/info_widget.dart';
import 'package:flutter_weather/widgets/weather_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(MyStateController());
  var location = Location();
  late StreamSubscription listener;
  late PermissionStatus permissionStatus;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await enableLocationListListener();
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Obx(
        () => Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    tileMode: TileMode.clamp,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: [
                  Color.fromRGBO(5, 35, 250, 1),
                  Color.fromRGBO(13, 27, 127, 1)
                ])),
            child: controller.locationData.value.latitude != null
                ? FutureBuilder(
                    future: OpenWeatherMap()
                        .getWeather((controller.locationData.value)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text(
                            'No Data',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        var data = snapshot.data as WeatherRes;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 20,
                            ),
                            WeatherTileWidget(
                                context: context,
                                title: (data.name != null &&
                                        data.name!.isNotEmpty)
                                    ? data.name
                                    : '${data.coord?.lat}/${data.coord?.lon}',
                                titleFontSize: 30.0,
                                subTitle: DateFormat('dd-MMM-yyyy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (data.dt ?? 0) * 1000))),
                            Center(
                              child: CachedNetworkImage(
                                imageUrl:
                                    buildIcon(data.weather?[0]!.icon ?? ''),
                                height: 200,
                                width: 200,
                                fit: BoxFit.fill,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        const CircularProgressIndicator(),
                                errorWidget: (context, url, err) => const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            WeatherTileWidget(
                                context: context,
                                title: '${data.main?.temp}°C',
                                titleFontSize: 60.0,
                                subTitle: '${data.weather?[0].description}'),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.all(15),
                              height: 200,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: FutureBuilder(
                                  future: OpenWeatherMap().getForecast(
                                      controller.locationData.value),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text(
                                          snapshot.error.toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      );
                                    } else if (!snapshot.hasData) {
                                      return const Center(
                                        child: Text(
                                          'No Data',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    } else {
                                      var data =
                                          snapshot.data as ForecastResult;
                                      return ListView.builder(
                                        itemCount: data.list?.length ?? 0,
                                        itemBuilder: (context, index) {
                                          var item = data.list?[index];
                                          return ForeCastTileWidget(
                                              imageUrl: buildIcon(
                                                  item?.weather![0]!.icon ?? '',
                                                  isBigSize: false),
                                              temp: '${item!.main!.temp}°C',
                                              time: DateFormat('HH:mm').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          (item.dt ?? 0) *
                                                              1000)));
                                        },
                                        scrollDirection: Axis.horizontal,
                                      );
                                    }
                                  }),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 8,
                                ),
                                InfoWidget(
                                  icon: FontAwesomeIcons.wind,
                                  text: '${data.wind?.speed}',
                                ),
                                InfoWidget(
                                  icon: FontAwesomeIcons.cloud,
                                  text: '${data.clouds}',
                                ),
                                InfoWidget(
                                  icon: FontAwesomeIcons.snowflake,
                                  text: '${data.snow}',
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 8,
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    })
                : const Center(
                    child: Text(
                      'Waiting...',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          controller.locationData.value = await location.getLocation();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> enableLocationListListener() async {
    controller.isEnableLocation.value = await location.serviceEnabled();
    if (!controller.isEnableLocation.value) {
      controller.isEnableLocation.value = await location.requestService();
      if (!controller.isEnableLocation.value) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    controller.locationData.value = await location.getLocation();
    listener = location.onLocationChanged.listen((event) {});
  }
}
