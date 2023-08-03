import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:github/github.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 13, 58, 164)),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.red,
            selectionColor: Color.fromARGB(255, 51, 45, 43),
            selectionHandleColor: Colors.black,
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String currentToken = "";
  bool tokenokReg = false,
      loading = false,
      gettingrepos = false,
      gotrepos = false;

  List<Repository> myrepos = List.empty(growable: true);

  void setloading(bool value) {
    loading = value;
    notifyListeners();
  }

  void settokenReg(bool value, String token) {
    if (gettingrepos) return;

    tokenokReg = value;
    currentToken = value ? token : "";
    notifyListeners();

    if (value) {
      getrepositories();
      gettingrepos = true;
    }
  }

  void getrepositories() async {
    if (gotrepos) return;
    if (currentToken == "") return;

    gettingrepos = true;
    notifyListeners();
    try {
      Authentication auth = Authentication.withToken(currentToken);

      GitHub mygithub = GitHub(auth: auth);

      myrepos = await mygithub.repositories.listRepositories().toList();
      print(myrepos);
      gotrepos = true;
      notifyListeners();
    } catch (e) {
      const AlertDialog();
    }
  }

  void repoSelected(int i, BuildContext context) async {
    print(myrepos[i].cloneUrl);

    String? pathtodir = await getDirectoryPath();

    if (pathtodir == null) return;

    Process gitclone = await Process.start(
        'git', ['clone', '--progress', myrepos[i].cloneUrl, pathtodir]);

    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
            child: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 0.5,
          child: Column(
            children: [
              SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40)),
                  child: StreamBuilder<String>(
                    stream: gitclone.stderr.transform(utf8.decoder),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(snapshot.data ?? "process Running"),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("close"))
            ],
          ),
        ));
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );

    var myexitcode = await gitclone.exitCode;
    print(myexitcode);
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var regExp = RegExp(r'^ghp_[a-zA-Z0-9]{36}$');

    ColorScheme themeColor = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: themeColor.primary,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(60, 0, 60, 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      "Git Clone",
                                      style: TextStyle(),
                                    ),
                                  ))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: "Github Token",
                                hintStyle:
                                    TextStyle(color: themeColor.onPrimary)),
                            onFieldSubmitted: (value) {
                              if (regExp.hasMatch(value)) {
                                appState.getrepositories();
                              }
                            },
                            onChanged: (value) {
                              if (regExp.hasMatch(value)) {
                                appState.currentToken = value;
                              }
                            },
                          ))
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: () {
                            appState.getrepositories();
                          },
                          child: const Text("Submit")),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    "Made By Abhinav Ojha",
                                    style: TextStyle(),
                                  ),
                                ))),
                      ],
                    ),
                  )
                ],
              )),
              Expanded(
                  flex: 2,
                  child: appState.myrepos.isEmpty
                      ? Center(
                          child: appState.gettingrepos
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.amber,
                                )
                              : const Text("Please Enter Github Token"))
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < appState.myrepos.length; i++)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        appState.repoSelected(i, context);
                                      },
                                      child: Text(appState.myrepos[i].name)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: Text(
                                          appState.myrepos[i].description == ""
                                              ? "No Description available."
                                              : appState
                                                  .myrepos[i].description)),
                                ]),
                              )
                          ],
                        )),
            ],
          ),
        ));
  }

  List<Widget> mainpage(var themeColor, var appState, var regExp) {
    return [
      const Flexible(
          child: FractionallySizedBox(
        heightFactor: 0.08,
      )),
      SizedBox.expand(
          child: FractionallySizedBox(
        widthFactor: 0.5,
        child: SizedBox.expand(
          child: Column(
            children: [
              Text(
                "Hello World input github token",
                style: TextStyle(color: themeColor.onPrimary),
              ),
              TextField(
                style: TextStyle(color: themeColor.onPrimary),
                cursorColor: themeColor.onPrimary,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(),
                  hintText: 'Github Token Here.',
                  hintStyle: TextStyle(color: themeColor.onSurface),
                ),
                onChanged: (value) {
                  appState.settokenReg(regExp.hasMatch(value), value);
                },
              ),
              appState.tokenokReg
                  ? appState.gotrepos
                      ? Column(children: [
                          ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: appState.myrepos.length,
                              itemBuilder: (buildcontext, index) {
                                print(appState.myrepos[index]);
                                return Text(
                                    "Hllo World ${appState.myrepos[index].name}");
                              }),
                        ])
                      : CircularProgressIndicator(
                          color: themeColor.onPrimary,
                        )
                  : Text(
                      "Please provide Github Token",
                      style: TextStyle(color: themeColor.onPrimary),
                    ),
            ],
          ),
        ),
      ))
    ];
  }
}
