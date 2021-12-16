import 'package:flutter/material.dart';
import 'package:flutter_app/conan/conan.dart';
import 'package:flutter_app/weather/weather.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<String> _tabs = [
    '天气',
    '柯南',
  ];

  List<Widget> _tabBarViews = [
    Weather(),
    Conan(),
  ];

  TabController? _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: 0, length: _tabs.length, vsync: this);
    _tabController?.addListener(() {
      if (_tabController?.index == _tabController?.animation?.value) {
        print('home.dart tabIndex ${_tabController?.index}');
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Material(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Theme.of(context).accentColor,
              // isScrollable: true,
              tabs: _tabs.map((_tab) {
                return Tab(
                  text: _tab,
                );
              }).toList(),
              controller: _tabController,
            ),
            elevation: 6.0,
          ),
        ),
      ),
      body: TabBarView(
        children: _tabBarViews,
        controller: _tabController,
      ),
    );
  }
}
