import 'package:flutter/material.dart';
import 'package:todo_app/layout/home_layout.dart';
import 'package:todo_app/shared/bloc_observ.dart';
import 'package:bloc/bloc.dart';


void main() {
  BlocOverrides.runZoned(
    () {
      // Use blocs...
    },
    blocObserver: MyBlocObserver(),
  );
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeLayout(),
  ));
}
