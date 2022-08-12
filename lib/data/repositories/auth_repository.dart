import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore database;

  AuthRepository(this.auth, this.database);
  Future loginUser({required String email, required String password}) async {
    UserCredential user =
        await auth.signInWithEmailAndPassword(email: email, password: password);

    if (!kIsWeb) {
      FirebaseMessaging.instance.getToken().then((token) {
        FirebaseFirestore.instance
            .collection('tokens')
            .doc(user.user!.uid)
            .set({'deviceToken': token});
      });
    }

    if (user.user != null) {
      return user.user;
    }
    return null;
  }

  static Future<Map<String, dynamic>> currentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? uid = user?.uid;
    String? type;
    String? name;
    // print('uid => $uid');

    if (kIsWeb) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? ud = preferences.getString('authData');
      if (ud != null) {
        Map userJson = jsonDecode(ud);

        var userData = await FirebaseFirestore.instance
            .collection('users')
            .where('user_id', isEqualTo: uid)
            .get();
        if (userData.docs.isNotEmpty) {
          type = userData.docs[0].data()['type'];
          name = userData.docs[0].data()['name'];
        }

        return {
          'user': userJson,
          'type': type,
          'name': name,
        };
      }
      return {};
    } else {
      if (uid != null) {
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .where('user_id', isEqualTo: uid)
            .get();
        if (userData.docs.isNotEmpty) {
          type = userData.docs[0].data()['type'];
          name = userData.docs[0].data()['name'];
        }
      }
      return {
        'user': user,
        'type': type,
        'name': name,
      };
    }
  }

  Future<bool?> logoutUser() async {
    await auth.signOut();
    return true;
  }
}
