import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../loading.dart';

class Rank extends StatefulWidget {
  const Rank({Key? key}) : super(key: key);

  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> with SingleTickerProviderStateMixin {
  List<Map> _tabs = [
    {'title': '微博', 'q': 'weibo'},
    {'title': '知乎', 'q': 'zhihu'},
    {'title': 'bilibili', 'q': 'bilibili'},
    {'title': '澎湃新闻', 'q': 'thepaper'},
    {'title': 'IT之家', 'q': 'ithome'},
  ];

  // int _currentTopTabIndex = 0;

  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: 0, length: _tabs.length, vsync: this);
    _tabController?.addListener(() {
      if (_tabController?.index == _tabController?.animation?.value) {
        // print('Rank.dart tabIndex ${_tabController?.index}');
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Material(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Theme.of(context).accentColor,
              isScrollable: true,
              tabs: _tabs.map((_tab) {
                return Tab(
                  text: _tab['title'],
                );
              }).toList(),
              controller: _tabController,
            ),
            elevation: 6.0,
          ),
        ),
      ),
      body: TabBarView(
        children: _tabs.map((_tab) {
          return TabBarViews(
            _tab['q'],
          );
        }).toList(),
        controller: _tabController,
      ),
    );
  }
}

class TabBarViews extends StatefulWidget {
  final String _q;
  const TabBarViews(this._q, {Key? key}) : super(key: key);
  @override
  _TabBarViewsState createState() => _TabBarViewsState();
}

class _TabBarViewsState extends State<TabBarViews>
    with AutomaticKeepAliveClientMixin {
  List _rankList = [];

  String _reportTime = '';

  FToast fToast = FToast();

  _getRank(String q) async {
    var url = 'https://apihut.net/rank/$q';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body)['data'];
      if (!mounted) return;
      setState(() {
        _rankList = result['lists'];
        _reportTime = result['report_time'].split(' ')[1];
      });
    } else {
      _rankList = [
        {'err': '获取$q数据失败'},
      ];
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      _getRank(widget._q);
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
                "更新于$_reportTime",
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
    });
    return;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getRank(widget._q);
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _rankList.length > 0
        ? RefreshIndicator(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 1),
              itemCount: _rankList.length,
              itemBuilder: (BuildContext context, int index) {
                return RankList(
                    rankItem: _rankList[index], index: index, q: widget._q);
              },
            ),
            onRefresh: _handleRefresh,
          )
        : Loading();
  }
}

/*
  -- 热搜详情 --
  @rank: 热搜列表 List
**/
class RankList extends StatelessWidget {
  const RankList({
    Key? key,
    required Map rankItem,
    required int index,
    required String q,
  })  : _rankItem = rankItem,
        _index = index,
        _q = q,
        super(key: key);

  final Map _rankItem;

  final int _index;

  final String _q;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        (_index + 1).toString(),
        style: TextStyle(
          color: _index <= 2 ? Colors.red[(4 - _index) * 100] : null,
          fontStyle: _index <= 2 ? FontStyle.italic : null,
          fontWeight: FontWeight.bold,
          fontSize: _index <= 2 ? 30 : 20,
        ),
      ),
      title: Text('${_rankItem['title']}'),
      subtitle: _rankItem['author'] != null
          ? Text('${_rankItem['author']}')
          : Text(' '),
      trailing: _q != 'zhihu' ? Text('${_rankItem['extra']}') : Text(' '),
      onTap: () {
        print('onTap');
      },
    );
  }
}
