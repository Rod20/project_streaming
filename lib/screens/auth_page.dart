import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream/core/api/api_firebase.dart';
import 'package:flutter_stream/core/utils/user_preferences.dart';
import 'package:flutter_stream/res/custom_colors.dart';
import 'package:flutter_stream/screens/home_page.dart';
import 'package:flutter_stream/widgets/login_button.dart';
import 'package:flutter_stream/widgets/streaming_header.dart';


class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  UserPreferences prefs = new UserPreferences();

  bool isLoggedIn = false; // Facebook Login

  //Google Login
  final ApiFirebase apiFirebase = ApiFirebase();
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iniciar Sesión"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: CustomColors.muxPinkLight,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _notNowButton(context),
            StreamingHeader.medium(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: googleSignIn(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notNowButton(BuildContext context) {
    return Container(
      child: FlatButton(
        child: Text(
          "Ahora No",
          style: TextStyle(
              color: Colors.grey
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage())
          );
        },
      ),
    );
  }

  Widget googleSignIn(BuildContext context) {
    return LoginButton(
      iconButton: Image.asset("assets/images/google_icon.png"),
      textButton: "Continuar con Google",
      onPressed: () async {
        Flushbar(
          title:  "Cargando",
          message:  "Espere un momento mientras procesamos la solicitud",
          duration:  Duration(seconds: 3),
          backgroundColor: Colors.green,
        )..show(context);
        var user =  await apiFirebase.signInWithGoogle();
        if(user  != null){
          prefs.userEmail = user.email;
          prefs.userName = user.displayName;
          prefs.userPhotoUrl = user.photoURL;
          prefs.userFirebaseId = user.uid;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage())
          );
        }else{
          Flushbar(
            title:  "Error",
            message:  "Ocurrio un error al procesar tu solicitud",
            duration:  Duration(seconds: 3),
            backgroundColor: Colors.red,
          )..show(context);
        }
      },
    );
  }

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }
}