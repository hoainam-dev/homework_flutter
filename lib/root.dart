import 'package:database_test/view/GiangVien.dart';
import 'package:database_test/view/LopHoc.dart';
import 'package:database_test/view/MonHoc.dart';
import 'package:database_test/view/SinhVien.dart';
import 'package:flutter/material.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: getFooter(),
      body: getBody(),
    );
  }

  Widget getFooter() {
    List icons = [Icons.account_circle, Icons.account_circle_outlined, Icons.class_, Icons.subject];
    List texts = ["Sinh vien", "Giang vien", "Lop hoc", "Mon hoc"];

    return Container(
      padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
      height: 50,
      decoration: BoxDecoration(color: Color(0xfffafafa)),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    activeTab = index;
                  });
                },
                child: Column(
                  children: [
                    Icon( icons[index],
                      color: activeTab == index
                          ? Color(0xffd43c3b)
                          : Color(0xff7e7e7e),
                      size: 25,
                    ),
                    Text(texts[index],
                        style: TextStyle(color: Color(0xff7e7e7e), fontSize: 12)),
                  ],
                ));
          } // 1 mang chua items.length phan tu icon
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: activeTab,
      children: [
        SinhVien(),
        GiangVien(),
        LopHoc(),
        MonHoc()
      ],
    );
  }
}
