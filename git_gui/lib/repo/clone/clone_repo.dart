import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:file_selector/file_selector.dart';

class CloneRepo {
  static Future<List<Repository>> getRepoToken(String token) async {
    Authentication auth = Authentication.withToken(token);

    GitHub mygithub = GitHub(auth: auth);

    List<Repository> myrepos =
        await mygithub.repositories.listRepositories().toList();
    return myrepos;
  }

  static Future showFolderDialog(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 0.5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: const FractionallySizedBox(
                heightFactor: 0.3,
                widthFactor: 0.3,
                child: FittedBox(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        );
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
  }

  static Future showReposDialog(
      BuildContext context, List<Repository> myrepos, String dirpath) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
            child: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 0.5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: Center(
              child: ListView(shrinkWrap: true, children: [
                for (int i = 0; i < myrepos.length; i++)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ElevatedButton(
                              onPressed: () {
                                reposelected(context, myrepos[i], dirpath);
                              },
                              child: Text(myrepos[i].name)),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                  )
              ]),
            ),
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
  }

  static void cloneRepoBtn(BuildContext context) async {
    Future<List<Repository>> myrepos = getRepoToken("");

    //Future clonedialog =
    showFolderDialog(context);

    final String? directoryPath = await getDirectoryPath();
    Navigator.pop(context);
    if (directoryPath == null) {
      return;
    }

    myrepos.then((value) {
      showReposDialog(context, value, directoryPath);
    });
  }

  static void reposelected(
      BuildContext context, Repository repotoclone, String dirpath) {
    print('git clone ${repotoclone.cloneUrl} $dirpath');
    Process.start('git', ['clone', '--progress', repotoclone.cloneUrl, dirpath])
        .then((value) {
      stderr.addStream(value.stderr);
      stdout.addStream(value.stdout);
      Navigator.pop(context);
    });
  }
}
