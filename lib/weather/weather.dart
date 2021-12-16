import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../loading.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> with AutomaticKeepAliveClientMixin {
  String _city = '';
  List _weather = [];
  String _weatherReminder = '';
  String _nowTemperature = '';
  FToast fToast = FToast();

  _getIPAddress() async {
    var url = 'https://apihut.net/ip';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String result = jsonDecode(response.body)['data']['city'];
      if (!mounted) return;
      setState(() {
        _city = result;
        _getWeather(_city);
      });
    } else {
      _city = '获取IP失败';
    }
  }

  _getWeather(String city) async {
    if (city == '') return;
    String url = 'https://api.vvhan.com/api/weather?city=$city&type=week';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map result = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _city = result['city'] + '市';
        _weather = result['forecast'];
        _weatherReminder = result['ganmao'];
        _nowTemperature = result['wendu'];
      });
    } else {
      _weather = ['获取天气失败'];
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      _getWeather(_city);
      // 自定义弹框
      fToast.showToast(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "刷新成功",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      // 固定样式弹框
      // Fluttertoast.showToast(
      //   msg: '刷新成功',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   backgroundColor: Colors.grey[600], // 灰色背景
      //   fontSize: 16.0,
      // );
    });
    return;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getIPAddress();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _weather.length > 0
        ? RefreshIndicator(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      WeatherInfo(
                        city: _city,
                        nowTemperature: _nowTemperature,
                        weatherReminder: _weatherReminder,
                      ), // 天气信息
                      WeatherList(
                        weather: _weather,
                      ), // 五天天气详情
                    ],
                  ),
                ),
              ],
            ),
            onRefresh: _handleRefresh,
          )
        : Loading();
  }
}

/*
  -- 天气信息 --
  @city: 城市 String
  @nowTemperature: 实时天气 String
  @_weatherReminder: 天气提示 String
**/
class WeatherInfo extends StatelessWidget {
  const WeatherInfo({
    Key? key,
    required String city,
    required String nowTemperature,
    required String weatherReminder,
  })  : _city = city,
        _nowTemperature = nowTemperature,
        _weatherReminder = weatherReminder,
        super(key: key);

  final String _city;
  final String _nowTemperature;
  final String _weatherReminder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          _city,
          style: TextStyle(fontSize: 20),
        ),
        Text(
          _nowTemperature != '' ? _nowTemperature + '℃' : '',
          style: TextStyle(fontSize: 60, fontWeight: FontWeight.w600),
        ),
        Text(
          _weatherReminder,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/*
  -- 五天天气详情 --
  @weather: 天气列表 List
**/
class WeatherList extends StatelessWidget {
  const WeatherList({
    Key? key,
    required List weather,
  })  : _weather = weather,
        super(key: key);

  final List _weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: _weather.map((_weatherItem) {
          return ListTile(
            title: Text('${_weatherItem['date']} / ${_weatherItem['type']}'),
            subtitle: Text('${_weatherItem['low']} - ${_weatherItem['high']}'),
            trailing: Text(
                '${_weatherItem['fengxiang']} - ${_weatherItem['fengli']}'),
          );
        }).toList(),
      ),
    );
    // child:
    // ListView.separated(
    //   shrinkWrap: true,
    //   physics: NeverScrollableScrollPhysics(),
    //   itemBuilder: (BuildContext context, int index) {
    //     Map _weatherItem = _weather[index];
    //     return ListTile(
    //       title: Text('${_weatherItem['date']} / ${_weatherItem['type']}'),
    //       subtitle: Text('${_weatherItem['low']} - ${_weatherItem['high']}'),
    //       trailing:
    //           Text('${_weatherItem['fengxiang']} - ${_weatherItem['fengli']}'),
    //     );
    //   },
    //   separatorBuilder: (BuildContext context, int index) {
    //     return Divider(
    //       color: Colors.red,
    //     );
    //   },
    //   itemCount: _weather.length,
    // );
  }
}
