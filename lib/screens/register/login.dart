import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selaa_delivery/backend_functions/auth.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/screens/register/pre_auth.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isClicked = false;

  void checkInputs(BuildContext context) {
    if(_isClicked==true){
      if (_email.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email'),
          ),
        );
      } else if (_password.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your password'),
          ),
        );
      } else {
        loginWithEmailPassword(_email.text, _password.text, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 50, left: 30),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PreAuth()));
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 50, left: 30, right: 30),
                child: Text(
                  "Welcome back! Glad to see you, Again !",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors().borderColor
                  ),
                )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 50, left: 30, right: 30),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Enter your email',
                          hintText: 'ex : selaa@examle.org',
                          labelStyle: TextStyle(
                            color: AppColors().borderColor
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: AppColors().primaryColor
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(
                          hintText: '********',
                          labelText: 'Enter your password',
                          labelStyle: TextStyle(
                            color: AppColors().borderColor
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(
                              color: AppColors().primaryColor
                            )
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          checkInputs(context);
                          setState(() {
                            _isClicked = true;
                          });
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(
                            Size(MediaQuery.of(context).size.width*0.85, MediaQuery.of(context).size.height*0.06),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(AppColors().primaryColor),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(color: AppColors().primaryColor),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}