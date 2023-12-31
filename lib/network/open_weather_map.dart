import 'dart:convert';

import 'package:flutter_weather/const.dart';
import 'package:flutter_weather/model/forecast_result.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../model/weather_model.dart';

class OpenWeatherMap {
  Future<WeatherRes> getWeather(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/weather?lat=${locationData.latitude}&lon=${locationData.longitude}&units=metric&appid=$apiKey'));
      if (res.statusCode == 200) {
        return WeatherRes.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Bad Requests');
      }
    } else {
      throw Exception('Wrong Location');
    }
  }

  Future<ForecastResult> getForecast(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/forecast?lat=${locationData.latitude}&lon=${locationData.longitude}&units=metric&appid=$apiKey'));
      if (res.statusCode == 200) {
        return ForecastResult.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Bad Requests');
      }
    } else {
      throw Exception('Wrong Location');
    }
  }
}
