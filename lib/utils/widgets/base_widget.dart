import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NBaseWidget extends StatefulWidget {
  final String pageTitle;
  final Widget body;
  static bool showIndicator = false;
  final List<Map<String, dynamic>>? bottomNavigationBarItems;
  final List<Map<String, dynamic>>? navigationDrawerItems;
  const NBaseWidget(
      {required this.pageTitle,
      required this.body,
      this.bottomNavigationBarItems,
      this.navigationDrawerItems,
      super.key});

  @override
  State<NBaseWidget> createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<NBaseWidget> {
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
        title: Text(widget.pageTitle),
      ),
      drawer: widget.navigationDrawerItems == null
          ? null
          : Drawer(
              child: Column(
                children: widget.navigationDrawerItems!
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
      bottomNavigationBar: widget.bottomNavigationBarItems == null
          ? null
          : BottomNavigationBar(
              selectedItemColor: Colors.amber,
              unselectedItemColor: Colors.purple,
              currentIndex: _selectedBottomBarTab,
              onTap: onTabChanged,
              items: widget.bottomNavigationBarItems!
                  .map((bottomBarItem) => BottomNavigationBarItem(
                        icon: Icon(bottomBarItem['icon']),
                        label: bottomBarItem['label'],
                      ))
                  .toList(),
            ),
      body: Stack(
        children: [
          widget.body,
          if (NBaseWidget.showIndicator)
            const Positioned(
                child: Align(
              child: CircularIndicator(),
            )),
        ],
      ),
    );
  }
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
