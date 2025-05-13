import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/core/app_state/app_state_data.dart';

class AppStateWidget extends StatefulWidget {
  final Widget child;
  const AppStateWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _AppStateWidgetState createState() => _AppStateWidgetState();
}

class _AppStateWidgetState extends State<AppStateWidget> {
  AppStateData appStateData = AppStateData();

  void setRegion(String region) {
    final newAppStateData = appStateData.copyWith(region: region);
    setState(() => appStateData = newAppStateData);
  }

  void setCountry(String country) {
    final newAppStateData = appStateData.copyWith(country: country);
    setState(() => appStateData = newAppStateData);
  }

  @override
  Widget build(BuildContext context) => StateInheritedWidget(
    child: widget.child,
    appStateData: appStateData,
    appStateWidget: this,
  );
}



class StateInheritedWidget extends InheritedWidget {

  final AppStateData appStateData;
  final _AppStateWidgetState appStateWidget;

  const StateInheritedWidget({
    Key? key,
    required Widget child,
    required this.appStateData,
    required this.appStateWidget,
  }) : super(key: key, child: child);

  static _AppStateWidgetState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StateInheritedWidget>()
        ?.appStateWidget;
  }

  @override
  bool updateShouldNotify(StateInheritedWidget oldWidget) =>
      oldWidget.appStateData != appStateData;
}

/// TODO: Usage example (Need to remove in production)
/* // To access the data from top level inherited widget
* final appStateData = StateInheritedWidget.of(context).appStateData;
*
* // To modify the data in top level inherited widget
* final provider = StateInheritedWidget.of(context);
      provider.setCountry("United Arab Emirates");
* */