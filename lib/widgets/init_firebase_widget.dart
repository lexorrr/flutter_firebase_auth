import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/models/auth/email.dart';
import 'package:google_sign_in/google_sign_in.dart';

class InitFirebaseWidget extends StatefulWidget {
  const InitFirebaseWidget();

  @override
  _InitFirebaseWidgetState createState() => _InitFirebaseWidgetState();
}

class _InitFirebaseWidgetState extends State<InitFirebaseWidget> {
  late final Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();

    _initialization = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error initializing firebase'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {

          try {
            final provider = EmailUser(
              email: 'roxelrollmendoza@gmail.com',
              password: '12345678'
            );

            // _register(provider);
            _login(provider);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('Error: weak password');
            }
            if (e.code == 'email-already-in-use') {
              print('Error: email already in use');
            }
          } catch (e) {
            print("Whoops, something's gone wrong :(");
          }

          FirebaseAuth.instance
              .authStateChanges()
              .listen(_handleUser);

          return const Center(
            child: Text('Initialization success!'),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _register(EmailUser user) async {
    // await user.register();
    final auth = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: user.email,
          password: user.password
        );
    await auth.user!.sendEmailVerification();
  }

  void _login(EmailUser user) async {
    await user.signIn();
  }

  void _handleUser(User? user) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (!user.emailVerified) {
        print('please verify email.');
        user.sendEmailVerification();
      } else {
        print('logged in: $user');
      }
    } else {

    }
  }

  Future<void> validateUser(String code) async {
    try {
      await FirebaseAuth.instance.checkActionCode(code);
      await FirebaseAuth.instance.applyActionCode(code);

      if (FirebaseAuth.instance.currentUser != null) {
        FirebaseAuth.instance.currentUser!.reload();
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-action-code') {
        // wrong code...
      }
    }
  }

  Future<void> authenticateViaGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;

    // Creation of credential object for Firebase
    final googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );

    // Sign in
    final credentials = await FirebaseAuth.instance
        .signInWithCredential(googleCredential);

  }
}