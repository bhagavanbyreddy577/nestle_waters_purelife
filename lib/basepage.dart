import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BasePage extends StatefulWidget {
  final String _pageTitle;
  final Widget _body;
  static bool showIndicator = false;
  final List<Map<String, dynamic>>? _bottomNavigationBarItems;
  final List<Map<String, dynamic>>? _navigationDrawerItems;
  const BasePage(
      {required String pageTitle,
      required body,
      List<Map<String, dynamic>>? bottomNavigationBarItems,
      List<Map<String, dynamic>>? navigationDrawerItems,
      super.key})
      : _pageTitle = pageTitle,
        _body = body,
        _bottomNavigationBarItems = bottomNavigationBarItems,
        _navigationDrawerItems = navigationDrawerItems;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _selectedBottomBarTab = 0;

  void onTabChanged(int index) {
    setState(() {
      _selectedBottomBarTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._pageTitle),
      ),
      drawer: widget._navigationDrawerItems == null
          ? null
          : Drawer(
              child: Column(
                children: widget._navigationDrawerItems!
                    .map((drawerItem) => ListTile(
                          leading: drawerItem['icon'] == null
                              ? null
                              : Icon(drawerItem['icon']),
                          title: Text(drawerItem['label']),
                          onTap: () {},
                        ))
                    .toList(),
              ),
            ),
      bottomNavigationBar: widget._bottomNavigationBarItems == null
          ? null
          : BottomNavigationBar(
              selectedItemColor: Colors.amber,
              unselectedItemColor: Colors.purple,
              currentIndex: _selectedBottomBarTab,
              onTap: onTabChanged,
              items: widget._bottomNavigationBarItems!
                  .map((bottomBarItem) => BottomNavigationBarItem(
                        icon: Icon(bottomBarItem['icon']),
                        label: bottomBarItem['label'],
                      ))
                  .toList(),
            ),
      body: Stack(
        children: [
          widget._body,
          if (BasePage.showIndicator)
            const Positioned(
                child: Align(
              child: CircularIndicator(),
            )),
        ],
      ),
    );
  }

  // void displayIndicator(bool isShown) {
  //   setState(() {
  //     widget.showIndicator = isShown;
  //   });
  // }
}

class CircularIndicator extends StatelessWidget {
  const CircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      backgroundColor: Colors.orangeAccent,
      color: Colors.blueGrey,
    );
  }
}
