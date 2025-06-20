import 'package:flutter/material.dart';
import 'package:my_weather/weather_material_page.dart';

void main() {
  runApp(const Weather());
}

class Weather extends StatelessWidget {
  const Weather({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weather App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),

      home: WeatherPage(),
    );
  }
}
