import 'package:github/github.dart';
import 'package:flutter/material.dart';

class MainClone {
  void cloneRepoDialog(String token) async {
    try {
      Authentication auth = Authentication.withToken(token);

      GitHub mygithub = GitHub(auth: auth);

      List<Repository> myrepos =
          await mygithub.repositories.listRepositories().toList();
      print(myrepos);
    } catch (e) {
      const AlertDialog();
    }
    //loading = false;
  }
}
