import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive_tasks/archive_tasks_screan.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screan.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screan.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());

   static AppCubit get(context)=> BlocProvider.of(context);


   int currentIndex=0;
  List<Widget> screans=[
    NewTasksScrean(),
    DoneTasksScrean(),
    ArchiveTasksScrean(),
  ];
  List<String> titles =[
    'New Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];

  void changeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

    late Database database;
     List<Map> newTasks = [];
      List<Map> doneTasks = [];
       List<Map> archivedTasks = [];

  void createDatabase()
  {
       openDatabase(
       'todo.db',
       version: 1,
       onCreate:(database,version) 
       {
         print('database created');
         database.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)').then((value) 
         {print('table created');}
         ).catchError((error){
           print('error when creating table ${error.toString()}');
         });
       },
       onOpen: (database)
       {
         getDataFromDatabase(database);
          print('database opened');
       }
       ).then((value) {
         database = value;
         emit(AppCreateDatabaseState());
       });
  }


  insertToDatabase({required String title,
  required String time,required String date})async
  {
   await database.transaction((txn) {
     return txn.rawInsert('INSERT INTO tasks(title,date,time,status)VALUES("$title","$date","$time","new")'
     )
     .then((value) {
       print('$value inserted  successfully');
       emit(AppInsertDatabaseState());

       getDataFromDatabase(database);
     }).catchError((error){
       print('error when inserting new record ${error.toString()}');
     });
      
    });
  }

  void getDataFromDatabase(database)
  {
    newTasks =[];
    doneTasks =[];
    archivedTasks =[];

    emit(AppGetDatabaseLoadingState());
   database.rawQuery('SELECT * FROM tasks').then((value) {
        
            
              value.forEach((element) {
                if(element['status'] == 'new')
                newTasks.add(element);
                else  if(element['status'] == 'done')
                doneTasks.add(element);
                else archivedTasks.add(element);
               });
         emit(AppGetDatabaseState());
          

         });
  }

  void ubdateData({
    required String status,
    required int id
  })async
  {
     database.rawUpdate(
     'UPDATE tasks SET status = ?  WHERE id = ?',
  ['$status', id]).then((value) 
  {
      getDataFromDatabase(database);
      emit(AppUbdateDatabaseState());
  });
  }


  void deleteData({
   
    required int id
  })
  {
     database.rawDelete(
     'DELETE FROM tasks WHERE id = ?', [id],
 ).then((value) 
  {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
  });
  }



   bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon
  })
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetBarState());


  }
}