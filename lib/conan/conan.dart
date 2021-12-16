import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/loading.dart';
import 'package:http/http.dart' as http;

class Conan extends StatefulWidget {
  const Conan({Key? key}) : super(key: key);

  @override
  _ConanState createState() => _ConanState();
}

class _ConanState extends State<Conan> with AutomaticKeepAliveClientMixin {
  List _conanList = [];

  ScrollController _scrollController = ScrollController();

  bool isLoadData = false;

  int _page = 1;

  _getConanList(int page) async {
    // http://10.0.2.2:8000是手机模拟器的本地地址
    var url = 'http://10.0.2.2:8000/conan?size=30&page=$page';
    // var url = 'http://localhost:8000/conan?size=30&page=$page';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map result = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        _conanList.addAll(result['epsodelist']);
      });
    } else {
      _conanList = ['获取数据失败'];
    }
  }

  Future<void> _loadMoreData() async {
    await Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
      _getConanList(_page);
      setState(() {
        isLoadData = false;
      });
    });
    return;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getConanList(_page);
    _scrollController.addListener(() {
      if (!isLoadData &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoadData = true;
          _page = _page + 1;
        });
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _conanList.length > 0
        ? ConanList(
            conanList: _conanList,
            scrollController: _scrollController,
          )
        : Loading();
  }
}

/*
  -- 柯南详情列表 --
  @scrollController 滑动控制器 ScrollController
  @conanList: 天气列表 List
**/
class ConanList extends StatelessWidget {
  const ConanList({
    Key? key,
    required ScrollController scrollController,
    required List conanList,
  })  : _scrollController = scrollController,
        _conanList = conanList,
        super(key: key);

  final ScrollController _scrollController;
  final List _conanList;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 1),
        itemCount: _conanList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < _conanList.length) {
            return ConanCard(conanItem: _conanList[index]);
          } else {
            return LoadMoreInfo();
          }
        },
      ),
    );
  }
}

/* 
  -- 柯南每一项详情容器 --
**/
class ConanCard extends StatelessWidget {
  const ConanCard({
    Key? key,
    required Map conanItem,
  })  : _conanItem = conanItem,
        super(key: key);

  final Map _conanItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Image(
            image: AssetImage('asset/images/conan/${_conanItem['image_url']}'),
          ),
          title: Text(
            '${_conanItem['name']} ${_conanItem['subtitle']}',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          subtitle: Container(
            child: Text(
              _conanItem['description'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
          ),
          onLongPress: () {
            print('onLongPress');
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConanDetail(conanItem: _conanItem),
              ),
            );
          },
        ),
        Divider(
          height: 1.0,
          indent: 10.0,
          endIndent: 10.0,
          color: Colors.grey,
        )
      ],
    );
  }
}

/* 
  -- 柯南每集的详情 --
**/
class ConanDetail extends StatelessWidget {
  const ConanDetail({
    Key? key,
    required Map conanItem,
  })  : _conanItem = conanItem,
        super(key: key);

  final Map _conanItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${_conanItem['subtitle']}',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: Text(
                '${_conanItem['name']} ${_conanItem['subtitle']}',
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Image(
              image:
                  AssetImage('asset/images/conan/${_conanItem['image_url']}'),
            ),
            Text(
              '${_conanItem['description']}',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* 
  -- 加载更多的容器 --
**/
class LoadMoreInfo extends StatelessWidget {
  const LoadMoreInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(1.0),
        child: Center(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2),
              ),
              Text(
                '正在加载更多...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}
