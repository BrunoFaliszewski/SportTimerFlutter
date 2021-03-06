import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../training_data/current_training_data.dart';
import 'home_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({ Key? key, required CurrentTrainingData? currentTrainingData, required User user})
    : _currentTrainingData = currentTrainingData, _user = user,
      super(key: key);

  final CurrentTrainingData? _currentTrainingData;
  final User _user;

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> with SingleTickerProviderStateMixin {
  CurrentTrainingData? _currentTrainingData;
  late User _user;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  Timer? timer;
  AnimationController? animationController;
  static AudioPlayer advancedPlayer = AudioPlayer();
  static AudioCache player = AudioCache(fixedPlayer: advancedPlayer);
  late StreamSubscription _soundStream;

  String exercise = "";
  String time = "";
  int exerciseIndex = 0;
  int timeIndex = 0;
  double progressValue = 0.0;
  double animationBegin = 0.0;
  late bool isFirst;
  late bool isSound;
  bool iconPressed = true;
  late Color currentBackgroundColor;
  late Map<String, int> sortedExercisesMap;

  void updateTime() {
    if (exerciseIndex < sortedExercisesMap.length) {
      setState(() {
        time = timeIndex.toString();
        progressValue = (sortedExercisesMap.values.elementAt(exerciseIndex) - timeIndex) / sortedExercisesMap.values.elementAt(exerciseIndex);
        if (isSound == true) {
          if (time == "3") {
            play("three.mp3");
          } else if (time == "2") {
            play("two.mp3");
          } else if (time == "1") {
            play("one.mp3");
          }
        }
        exercise = sortedExercisesMap.keys.elementAt(exerciseIndex).substring(4);
        if (isFirst) {
          if (exercise != "Rest") {
            currentBackgroundColor = Colors.green;
            if (isSound == true) {
              play("work.mp3");
            }
            isFirst = false;
          } else {
            currentBackgroundColor = Colors.red;
            if (isSound == true) {
              play("rest.mp3");
            }
            isFirst = false;
          }
        }
      });

      timeIndex--;

      if (timeIndex == 0) {
        exerciseIndex++;
        isFirst = true;

        if (exerciseIndex < sortedExercisesMap.length) {
          timeIndex = sortedExercisesMap.values.elementAt(exerciseIndex);
        }
      }
    } else {
      timer?.cancel();

      setState(() {
        exercise = "";
        time = "Finish";
        progressValue = 1.0;
        if (isFirst) {
          if (isSound == true) {
            play("finish.mp3");
          }
          isFirst = false;
        }
      });
    }
  }

  void play(String path) {
    player.play(path);
  }

  @override
  void initState() {
    _currentTrainingData = widget._currentTrainingData;
    _user = widget._user;
    iconPressed = true;
    isFirst = true;
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    currentBackgroundColor = Colors.green;
    

    _soundStream = _database.child(_user.uid).child("sound").onValue.listen((event) {
      if (event.snapshot.value != null) {
        if (event.snapshot.value == "true") {
          isSound = true;
        } else {
          isSound = false;
        }
      } else {
        isSound = true;
      }
    });

    _database.child(_user.uid).child("prepareTime").once().then((DataSnapshot snapshot) {
      final value = snapshot.value;
      if (value is int) {
        _currentTrainingData!.exercises.addAll({"!000Prepare" : value});
      }
    });

    final List sortedExercisesList = _currentTrainingData!.exercises.keys.toList();
    sortedExercisesList.sort();
    sortedExercisesMap = {};
    for (var i = 0; i < sortedExercisesList.length; i++) {
      sortedExercisesMap[sortedExercisesList[i].toString()] = _currentTrainingData!.exercises[sortedExercisesList[i].toString()]!;
    }

    timeIndex = sortedExercisesMap.values.elementAt(0);
    exerciseIndex = 0;

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _soundStream.cancel();

    timer?.cancel();
  }

  Route _routeToHomePageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(user: _user, currentTrainingData: _currentTrainingData),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppBar appbar = AppBar(
      title: const Text("Sport Timer"),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(_routeToHomePageScreen());
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (iconPressed == true) {
                animationController!.forward();
                timer?.cancel();
                iconPressed = false;
              } else {
                animationController!.reverse();
                timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());
                iconPressed = true;
              }
            });
          },
          icon: AnimatedIcon(
            progress: animationController!,
            icon: AnimatedIcons.pause_play,
          )
        )
      ]
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appbar,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * progressValue,
              color: currentBackgroundColor,
            )
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, appbar.preferredSize.height + 70, 0, 0),
              child: Text(
                exercise,
                style: const TextStyle(
                  fontSize: 40
                ),
              ),
            )
          ),
          Center(
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 140
              )
            )
          )
        ]
      )
    );
  }
}
