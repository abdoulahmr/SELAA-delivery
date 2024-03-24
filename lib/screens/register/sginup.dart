import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:selaa_delivery/backend_functions/links.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<SignUp> {
  final PageController _pageController = PageController(initialPage: 0);

  int _currentPage = 0;

  void nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StepOne(nextPage: nextPage),
                StepTwo(nextPage: nextPage, previousPage: previousPage),
                StepThree(nextPage: nextPage, previousPage: previousPage),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}

class StepOne extends StatefulWidget {
  final VoidCallback nextPage;

  const StepOne({super.key, required this.nextPage});

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  bool _isChecked = false;
  Color color = Colors.black;

  void checkInput(){
    bool con = true;
    if(_email.text.isEmpty){
      Fluttertoast.showToast(
        msg: "Email is empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      con = false;
    }
    if(_password.text.isEmpty){
      Fluttertoast.showToast(
        msg: "Password is empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      con = false;
    }
    if(_passwordConfirm.text.isEmpty){
      Fluttertoast.showToast(
        msg: "Password is empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
    if(_password.text != _passwordConfirm.text){
      Fluttertoast.showToast(
        msg: "Password password doesn't match",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.yellow,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      con = false;
    }
    if(_isChecked != true){
      setState(() {
        color = Colors.red;
      });
      con = false;
    }
    else{
      if(con) widget.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 35, left: 30, right: 30),
            child: Text(
              "Hello ! Register and start shopping",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors().primaryColor
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,                        
              controller: _email,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.email),
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: AppColors().borderColor,
                ),  
                hintText: 'ex : selaa@examle.org',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().borderColor),
                  borderRadius: BorderRadius.circular(15.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().borderColor),
                  borderRadius: BorderRadius.circular(15.0)
                )
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,                        
              controller: _password,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.password),
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: AppColors().borderColor,
                ),  
                hintText: '********',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().borderColor),
                  borderRadius: BorderRadius.circular(15.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().borderColor),
                  borderRadius: BorderRadius.circular(15.0)
                )
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,                        
              controller: _passwordConfirm,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.password),
                labelText: 'Confirm password',
                labelStyle: TextStyle(
                  color: AppColors().borderColor,
                ),  
                hintText: '********',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().borderColor),
                  borderRadius: BorderRadius.circular(15.0)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().borderColor),
                  borderRadius: BorderRadius.circular(15.0)
                )
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                key: const Key("checkbox"),
                value: _isChecked,
                activeColor: AppColors().primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value!;
                  });
                },
              ),
              Text(
                key: const Key('Text'),
                'I agree to the terms and conditions',
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
              endIndent: 40,
              indent: 40,
              color: AppColors().borderColor,
            ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: checkInput,
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width*0.85, MediaQuery.of(context).size.height*0.06),
              ),
              backgroundColor:
                MaterialStateProperty.all(AppColors().primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: AppColors().borderColor),
                  ),
                ),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepTwo extends StatelessWidget {
  final VoidCallback nextPage;
  final VoidCallback previousPage;

  StepTwo({super.key, required this.nextPage, required this.previousPage});
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _dLNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left:30,right: 30, bottom: 20),
          child: TextFormField(
            keyboardType: TextInputType.number,                        
            controller: _dLNumber,
            decoration: InputDecoration(
              labelText: 'Firstname',
              labelStyle: TextStyle(
                color: AppColors().borderColor,
              ),  
              hintText: 'selaa',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              )
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left:30,right: 30, bottom: 20),
          child: TextFormField(
            keyboardType: TextInputType.number,                        
            controller: _dLNumber,
            decoration: InputDecoration(
              labelText: 'Lastname',
              labelStyle: TextStyle(
                color: AppColors().borderColor,
              ),  
              hintText: 'delivery',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              )
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left:30,right: 30, bottom: 20),
          child: TextFormField(
            keyboardType: TextInputType.phone,                        
            controller: _phoneNumber,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.phone),
              labelText: 'Phone number',
              labelStyle: TextStyle(
                color: AppColors().borderColor,
              ),  
              hintText: '+213 123 456 789',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              )
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left:30,right: 30, bottom: 20),
          child: Text(
            "Please use your personal phone number to register. We will send you a verification code to verify your account.",
            style: TextStyle(
              fontSize: 10,
              color: AppColors().borderColor
            ),
          )
        ),
        Container(
          margin: const EdgeInsets.only(left:30,right: 30, bottom: 20),
          child: TextFormField(
            keyboardType: TextInputType.number,                        
            controller: _dLNumber,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.numbers),
              labelText: 'Driver license number',
              labelStyle: TextStyle(
                color: AppColors().borderColor,
              ),  
              hintText: 'ex : 1234567890',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors().borderColor),
                borderRadius: BorderRadius.circular(15.0)
              )
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left:30,right: 30, bottom: 20),
          child: Text(
            "By clicking on continue, you agree to our terms and conditions",
            style: TextStyle(
              fontSize: 10,
              color: AppColors().borderColor
            ),
          )
        ),
        Divider(
          endIndent: 40,
          indent: 40,
          color: AppColors().borderColor,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: previousPage,
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(
                    MediaQuery.of(context).size.width*0.4, 
                    MediaQuery.of(context).size.height*0.06
                  ),
                ),
                backgroundColor:
                  MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: AppColors().borderColor),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.arrow_back_ios,color: AppColors().primaryColor),
                  Text('Previous', style: TextStyle(color: AppColors().primaryColor)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: nextPage,
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(
                    MediaQuery.of(context).size.width*0.4, 
                    MediaQuery.of(context).size.height*0.06
                  ),
                ),
                backgroundColor:
                  MaterialStateProperty.all(AppColors().primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(color: AppColors().borderColor),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Next', style: TextStyle(color: Colors.white)),
                  Icon(Icons.arrow_forward_ios,color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StepThree extends StatelessWidget {
  final VoidCallback nextPage;
  final VoidCallback previousPage;

  const StepThree({super.key, required this.nextPage, required this.previousPage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_android, size: 80, color: AppColors().primaryColor),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.only(left: 30 , right: 30),
            child: Text(
              "Enter the verification code sent to your phone number",
              style: TextStyle(
                fontSize: 20,
                color: AppColors().borderColor
              ),
            )
          ),
          Container(
            margin: const EdgeInsets.all(30),
            child: OtpTextField(
                numberOfFields: 5,
                fieldWidth: 45,
                focusedBorderColor: AppColors().primaryColor,
                borderColor: AppColors().borderColor,
                margin: const EdgeInsets.all(10),
                showFieldAsBox: true, 
                onSubmit: (String verificationCode){
                  print("Verification Code is: $verificationCode");
                },
            ),
          ),
          Divider(
            endIndent: 40,
            indent: 40,
            color: AppColors().borderColor,
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.only(left: 30 , right: 30),
            child: Row(
              children: [
                Text(
                  "Didn't receive the code?",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors().borderColor
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    print("Resend code");
                  },
                  child: Text(
                    "Resend code",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors().primaryColor,
                    ),
                  ),
                ),
              ],
            )
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: previousPage,
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width*0.4, 
                      MediaQuery.of(context).size.height*0.06
                    ),
                  ),
                  backgroundColor:
                    MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: AppColors().borderColor),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.arrow_back_ios,color: AppColors().primaryColor),
                    Text('Previous', style: TextStyle(color: AppColors().primaryColor)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: nextPage,
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(
                      MediaQuery.of(context).size.width*0.4, 
                      MediaQuery.of(context).size.height*0.06
                    ),
                  ),
                  backgroundColor:
                    MaterialStateProperty.all(AppColors().primaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: AppColors().borderColor),
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Confirm', style: TextStyle(color: Colors.white)),
                    Icon(Icons.check,color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}