import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const apikey = '533dd69a70a2439276cafd3cc87a3d02';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String city = "delhi,India";
  final TextEditingController textEditingController = TextEditingController();

  Future<Map<String, dynamic>> getCurrWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$apikey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "An unexpected Error Occured";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;
          final currTemp = data['list'][0]['main']['temp'];
          final currSky = data['list'][0]['weather'][0]['main'];
          final weatherIcon = data['list'][0]['weather'][0]['icon'];
          final currPress = data['list'][0]['main']['pressure'];
          final currWind = data['list'][0]['wind']['speed'];
          final currHumidity = data['list'][0]['main']['humidity'];
          return Padding(
            padding: const EdgeInsets.all(12.0),

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),

                  child: TextField(
                    controller: textEditingController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Enter the city, country",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.location_city),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          city = textEditingController.text;
                          FocusScope.of(context).unfocus();
                          setState(() {});
                        },
                      ),
                      border:
                          InputBorder
                              .none, // ⬅️ Important to remove default border
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                "${(currTemp - 273).toStringAsFixed(1)} °C",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // SizedBox(height: 1),
                              Image.network(
                                "http://openweathermap.org/img/wn/$weatherIcon@2x.png",
                                width: 100,
                                height: 100,
                              ),
                              // SizedBox(height: 1),
                              Text("$currSky", style: TextStyle(fontSize: 28)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hourly Forecast",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForecast(
                //           time: data['list'][i + 1]['dt_txt'].toString(),
                //           icon: Image.network(
                //             "http://openweathermap.org/img/wn/${data['list'][i+1]['weather'][0]['icon']}@2x.png",
                //           ),
                //           temp: data['list'][i+1]['weather'][0]['main'],
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final hourlytemp =
                          data['list'][index + 1]['main']['temp'];
                      final time = DateTime.parse(
                        data['list'][index + 1]['dt_txt'],
                      );
                      return HourlyForecast(
                        time: DateFormat.j().format(time),
                        icon: Image.network(
                          "http://openweathermap.org/img/wn/${data['list'][index + 1]['weather'][0]['icon']}@2x.png",
                          width: 70,
                        ),
                        temp: "${(hourlytemp - 273).toStringAsFixed(1)}",
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformation(
                      conditon: "Humidity",
                      icon: Icons.water_drop,
                      value: "$currHumidity %",
                    ),

                    AdditionalInformation(
                      conditon: "Wind Speed",
                      icon: Icons.air,
                      value: "$currWind m/s",
                    ),
                    AdditionalInformation(
                      conditon: "Pressure",
                      icon: Icons.speed,
                      value: "${currPress / 100} Pa",
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HourlyForecast extends StatelessWidget {
  final String time;
  final Widget icon;
  final String temp;
  const HourlyForecast({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(7.5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              "$time ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1),
            Card(color: const Color.fromARGB(255, 199, 227, 250), child: icon),
            SizedBox(height: 1),
            Text("$temp ℃"),
          ],
        ),
      ),
    );
  }
}

class AdditionalInformation extends StatelessWidget {
  final String conditon;
  final String value;
  final IconData icon;

  const AdditionalInformation({
    super.key,
    required this.conditon,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 60),
        Text(
          conditon,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
