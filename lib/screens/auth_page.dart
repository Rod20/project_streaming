/*
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:servisurusers/core/api/api_firebase.dart';
import 'package:servisurusers/core/utils/user_preferences.dart';
import 'package:servisurusers/ui/resources/app_colors.dart';
import 'package:servisurusers/ui/screens/home/home_screen.dart';
import 'package:servisurusers/ui/widgets/login_button.dart';
import 'package:servisurusers/ui/widgets/servisur_header.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';


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
        backgroundColor: lightPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _notNowButton(context),
            ServisurHeader.medium(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: googleSignIn(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: facebookSignIn(context),
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
              MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
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
              MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
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

  Widget facebookSignIn(BuildContext context) {
    return LoginButton(
      iconButton: Image.asset("assets/images/facebook_icon.png"),
      textButton: "Continuar con Facebook",
      onPressed: () {
        initiateFacebookLogin();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen())
        );
      },
    );
  }

  void initiateFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        onLoginStatusChanged(true);
        break;
    }
  }

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }
}*/