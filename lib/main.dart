import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(const WeatherApp());
}



class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String city = "Gulfport";
  String state = "FL";
  String country = "US";
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cityController.text = "Gulfport, Florida, US";
    fetchWeatherData();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchCoordinates(String city, String state, String country) async {
    final geocodingUrl = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(city)},${Uri.encodeComponent(state)},${Uri.encodeComponent(country)}&limit=1&appid=87a52fc8e0399ea83a8e829d6ddc978d',
    );

    try {
      final response = await http.get(geocodingUrl);
      debugPrint("Geocoding API response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data.isNotEmpty) {
          return {
            'lat': data[0]['lat'],
            'lon': data[0]['lon'],
          };
        } else {
          debugPrint("Geocoding API returned empty data.");
        }
      } else {
        debugPrint("Geocoding API request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
    return null;
  }

  Future<void> fetchWeatherData() async {
    final location = await fetchCoordinates(city, state, country);
    if (location == null) {
      setState(() {
        _errorMessage = "Failed to fetch coordinates for $city, $state, $country.";
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${location['lat']}&longitude=${location['lon']}&hourly=temperature_2m,precipitation_probability&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&wind_speed_unit=kn&precipitation_unit=inch&timezone=America%2FNew_York',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<String>> fetchCitySuggestions(String input) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(input)}&limit=5&appid=87a52fc8e0399ea83a8e829d6ddc978d');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map<String>(
              (item) =>
                  '${item['name']}, ${item['state'] ?? ''}, ${item['country']}',
            )
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching city suggestions: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      content = Center(child: Text(_errorMessage));
    } else if (_weatherData != null) {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LineChartWidget(weatherData: _weatherData!),
              const SizedBox(height: 20),
              DailyWeatherTable(weatherData: _weatherData!),
            ],
          ),
        ),
      );
    } else {
      content = const Center(child: Text('No data available'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Weather Page'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.water),
              title: const Text('Tide Page'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.70, // Set width to half the screen width
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City/State',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          final parts = value.split(',').map((e) => e.trim()).toList();
                          city = parts[0];
                          state = parts.length > 1 ? parts[1] : '';
                          country = parts.length > 2 ? parts[2] : 'US';
                          _isLoading = true;
                          _weatherData = null;
                          _errorMessage = '';
                        });
                        fetchWeatherData();
                      },
                    ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];
                      return await fetchCitySuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      final parts = suggestion.split(',').map((e) => e.trim()).toList();
                      setState(() {
                        city = parts[0];
                        state = parts.length > 1 ? parts[1] : '';
                        country = parts.length > 2 ? parts[2] : 'US';
                        _cityController.text = suggestion;
                      });
                      fetchWeatherData();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const LineChartWidget({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final times = weatherData['hourly']?['time'] as List<dynamic>? ?? [];
    final temperatures = weatherData['hourly']?['temperature_2m'] as List<dynamic>? ?? [];
    final precipitation = weatherData['hourly']?['precipitation_probability'] as List<dynamic>? ?? [];

    if (times.isEmpty || temperatures.isEmpty || precipitation.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    List<FlSpot> temperatureSpots = [];
    List<FlSpot> precipitationSpots = [];

    for (int i = 0; i < times.length; i++) {
      temperatureSpots.add(FlSpot(i.toDouble(), temperatures[i].toDouble()));
      precipitationSpots.add(FlSpot(i.toDouble(), precipitation[i].toDouble()));
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) => '${value.toInt()}°',
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitles: (value) {
                final index = value.toInt();
                if (index >= 0 && index < times.length) {
                  final timeString = times[index];
                  final hour = timeString.substring(11, 13); // Extract "HH:mm"
                  if (hour == "12") {
                    final dateTime = DateTime.parse(timeString);
                    final formattedDate = DateFormat('MM/dd EEE').format(dateTime);
                    return '$hour\n$formattedDate'; // Display hour and date below
                  } else if (index % 3 == 0) {
                    return hour; // Show hour every 3rd tick
                  }
                }
                return '';
              },
              margin: 10,
            ),
            rightTitles: SideTitles(
              showTitles: true,
              getTitles: (value) => '${value.toInt()}%',
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            // Temperature line
            LineChartBarData(
              spots: temperatureSpots,
              isCurved: true,
              colors: [Colors.blue],
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            // Precipitation line
            LineChartBarData(
              spots: precipitationSpots,
              isCurved: true,
              colors: [Colors.green],
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
          minY: 0,
          maxY: 100,
        ),
      ),
    );
  }
}

class DailyWeatherTable extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const DailyWeatherTable({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final days = weatherData['daily']['time'] as List<dynamic>? ?? [];
    final maxTemps = weatherData['daily']['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTemps = weatherData['daily']['temperature_2m_min'] as List<dynamic>? ?? [];

    if (days.isEmpty || maxTemps.isEmpty || minTemps.isEmpty) {
      return const Center(child: Text('No daily data available'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Hi/Lo')),
        ],
        rows: List.generate(days.length, (index) {
          final parsedDate = DateTime.parse(days[index].toString());
          final formattedDate = DateFormat('MM/dd EEE').format(parsedDate); // Format as "MM/DD DDD"

          final highTemp = "${maxTemps[index].toDouble().round()}"; // Add ° symbol
          final lowTemp = "${minTemps[index].toDouble().round()}°";  // Add ° symbol
          final highLowTemp = "$highTemp/$lowTemp"; // Combine high and low temps

          return DataRow(
            cells: [
              DataCell(Text(formattedDate)),
              DataCell(Text(highLowTemp)),
            ],
          );
        }),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<FlSpot> tideSpots = [];
  List<dynamic> predictions = []; // Add this to store the API predictions
  double minTide = 0;
  double maxTide = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTideData();
  }

  Future<void> fetchTideData() async {
    final now = DateTime.now();
    final beginDate = "${now.year}${_padZero(now.month)}${_padZero(now.day)}";
    final endDate = "${now.add(Duration(days: 6)).year}${_padZero(now.add(Duration(days: 6)).month)}${_padZero(now.add(Duration(days: 6)).day)}";

    final url = Uri.parse(
      "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=$beginDate&end_date=$endDate&station=8726347&product=predictions&datum=MLLW&time_zone=lst_ldt&units=english&interval=h&format=json",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        predictions = data['predictions']; // Store predictions
        if (predictions.isNotEmpty) {
          List<FlSpot> spots = [];
          double localMin = double.infinity;
          double localMax = double.negativeInfinity;

          for (int i = 0; i < predictions.length; i++) {
            final level = double.parse(predictions[i]['v']);
            spots.add(FlSpot(i.toDouble(), level));

            if (level < localMin) localMin = level;
            if (level > localMax) localMax = level;
          }

          setState(() {
            tideSpots = spots;
            minTide = localMin - 0.5; // Add margin
            maxTide = localMax + 0.5;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to load tide data.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  String _padZero(int value) => value < 10 ? '0$value' : value.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Tide Data'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : tideSpots.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              
    bottomTitles: SideTitles(
      showTitles: true,
      reservedSize: 50, // Increase for multi-line labels
      getTitles: (value) {
        int index = value.toInt();
        if (index >= 0 && index < predictions.length) {
          String time = predictions[index]['t'];
          String hour = time.substring(11, 13);
          DateTime dateTime = DateTime.parse(time);

          if (hour == "12") {
            String formattedDate = DateFormat('MM/dd EEE').format(dateTime);
            return '12:00\n$formattedDate';
          } else if (index % 3 == 0) {
            return '$hour';
          }
        }
        return '';
      },
      margin: 10,
    ),
  ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: tideSpots,
                                isCurved: true,
                                colors: [Colors.blue],
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                            minY: minTide,
                            maxY: maxTide,
                            extraLinesData: ExtraLinesData(
                              verticalLines: tideSpots
                                  .where((spot) => spot.x % 24 == 0)
                                  .map((spot) => VerticalLine(
                                        x: spot.x,
                                        color: Colors.black.withOpacity(0.3),
                                        strokeWidth: 1,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(child: Text('No tide data available')),
    );
  }
}
