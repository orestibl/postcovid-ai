/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of context;

/// A [Datum] that holds weather information collected through OpenWeatherMap.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class WeatherDatum extends Datum {
  DataFormat get format =>
      DataFormat.fromString(ContextSamplingPackage.WEATHER);

  String country, areaName, weatherMain, weatherDescription;
  DateTime date, sunrise, sunset;
  var latitude,
      longitude,
      pressure,
      windSpeed,
      windDegree,
      humidity,
      cloudiness,
      rainLastHour,
      rainLast3Hours,
      snowLastHour,
      snowLast3Hours,
      temperature,
      tempMin,
      tempMax;

  WeatherDatum() : super();

  factory WeatherDatum.fromJson(Map<String, dynamic> json) =>
      _$WeatherDatumFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDatumToJson(this);

  String toString() =>
      super.toString() +
      ',place: $areaName ($country), '
      'date: $date, '
      'weather: $weatherMain, $weatherDescription, '
      'temp: $temperature, temp (min): $tempMin, temp (max): $tempMax, '
      'sunrise: $sunrise, sunset: $sunset';
}
