import 'package:flutter/material.dart';

class My extends StatefulWidget {
  const My({Key? key}) : super(key: key);

  @override
  _MyState createState() => _MyState();
}

class _MyState extends State<My> {
  List<Map> _list = [];

  bool isLike = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 100; i++) {
      _list.add({'text': (i + 1), 'isLike': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              '第${_list[index]['text']}项',
            ),
            trailing: Icon(
              _list[index]['isLike'] ? Icons.favorite : Icons.favorite_border,
              color: _list[index]['isLike'] ? Colors.red : null,
            ),
            onTap: () {
              setState(() {
                _list[index]['isLike'] = !_list[index]['isLike'];
              });
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            indent: 15.0,
            endIndent: 15.0,
            color: Colors.grey,
          );
        },
        itemCount: _list.length,
      ),
    );
  }
}
