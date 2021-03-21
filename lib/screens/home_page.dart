import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:notesy/services/authentication.dart';
import 'package:notesy/widgets/text_field.dart';
import 'package:notesy/widgets/custom_button.dart';
import 'package:notesy/models/home_model.dart';
import 'package:notesy/widgets/wave_widget.dart';
import 'package:provider/provider.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';

String email = "";
String password = "";

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emailModel = Provider.of<HomeModel>(context);
    final size = MediaQuery.of(context).size;
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: size.height - 200,
            color: Colors.blue,
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
            top: keyboardOpen ? -size.height / 4.0 : 0.0,
            child: WaveWidget(
              size: size,
              yOffset: size.height / 3.0,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notesy',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Log in or Sign Up to use Notesy',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: size.height / 20,
                ),
                TextFieldWidget(
                  hintText: "Email",
                  obscureText: false,
                  prefixIconData: Icons.mail_outline,
                  suffixIconData: !emailModel.isValid ? Icons.clear : Icons.check,
                  onChanged: (value) {
                    print(value);
                    print("Email is $email");
                    emailModel.isEmailValid(value);
                    email = value;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFieldWidget(
                  hintText: "Password",
                  obscureText: !emailModel.ifVisible,
                  prefixIconData: Icons.lock_outline,
                  suffixIconData: emailModel.ifVisible ? Icons.visibility : Icons.visibility_off,
                  onChanged: (value) {
                    password = value;
                  },
                ),
                SizedBox(
                  height: 40.0,
                ),
                CustomButton(
                  text: "Log In",
                  hasBorders: false,
                  onPressed: () async {
                    final FocusScopeNode currentScope = FocusScope.of(context);
                    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    final res = await context
                        .read<AuthenticationService>()
                        .signIn(email: email, password: password);
                    print(res);
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                CustomButton(
                  text: "Sign Up",
                  hasBorders: true,
                  onPressed: () async {
                    final FocusScopeNode currentScope = FocusScope.of(context);
                    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    final res = await context
                        .read<AuthenticationService>()
                        .signUp(email: email, password: password);
                    print(res);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
