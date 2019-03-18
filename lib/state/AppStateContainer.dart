import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:pebrapp/database/models/PreferenceAssessment.dart';
import 'package:pebrapp/state/AppState.dart';

// code from https://flutterbyexample.com/set-up-inherited-widget-app-state/
// see also  https://stackoverflow.com/a/49492495/6586631
// and       https://gist.github.com/ericwindmill/f790bd2456e6489b1ab97eba246fd4c6
@deprecated
class AppStateContainer extends StatefulWidget {
  // This widget is simply the root of the tree,
  // so it has to have a child!
  final Widget child;

  AppStateContainer({
    @required this.child,
  });

  // This creates a method on the AppState that's just like 'of'
  // On MediaQueries, Theme, etc
  // This is the secret to accessing your AppState all over your app
  static _AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
    as _InheritedStateContainer).data;
  }

  @override
  _AppStateContainerState createState() => new _AppStateContainerState();
}

class _AppStateContainerState extends State<AppStateContainer> {
  // Just padding the state through so we don't have to
  // manipulate it with widget.state.
  AppState state = AppState();

  @override
  void initState() {
    // You'll almost certainly want to do some logic
    // in InitState of your AppStateContainer. In this example, we'll eventually
    // write the methods to check the local state
    // for existing users and all that.
    updateState();
    super.initState();
  }

  /// Call this method to reload the latest data from the database
  void updateState() {
    this.state.isLoading = true;
    setState(() {});
    _fetchDataFromDatabaseAndUpdateState(this.state).then((void _) {
      this.state.isLoading = false;
      setState(() {});
    });
  }

  Future<void> _fetchDataFromDatabaseAndUpdateState(AppState state) async {
    final List<Patient> _patientList = await DatabaseProvider().retrieveLatestPatients();
    final Map<Patient, PreferenceAssessment> _map = Map<Patient, PreferenceAssessment>();
    for (Patient p in _patientList) {
      final pa = await DatabaseProvider().retrieveLatestPreferenceAssessmentForPatient(p.artNumber);
      _map[p] = pa;
      this.state.patientsPreferenceAssessmentJoined = _map;
    }
//    await Future.delayed(Duration(seconds: 5));
  }

  // So the WidgetTree is actually
  // AppStateContainer --> InheritedStateContainer --> The rest of your app.
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

// This is likely all your InheritedWidget will ever need.
class _InheritedStateContainer extends InheritedWidget {
  // The data is whatever this widget is passing down.
  final _AppStateContainerState data;

  // InheritedWidgets are always just wrappers.
  // So there has to be a child,
  // Although Flutter just knows to build the Widget thats passed to it
  // So you don't have have a build method or anything.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // This is a better way to do this, which you'll see later.
  // But basically, Flutter automatically calls this method when any data
  // in this widget is changed.
  // You can use this method to make sure that flutter actually should
  // repaint the tree, or do nothing.
  // It helps with performance.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
