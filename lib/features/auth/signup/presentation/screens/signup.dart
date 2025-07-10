import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/bloc/signup_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/bloc/signup_event.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/bloc/signup_state.dart';
import 'package:nestle_waters_purelife/utils/constants/text_strings.dart';
import 'package:nestle_waters_purelife/utils/widgets/email_text_field.dart';
import 'package:nestle_waters_purelife/utils/widgets/textspan.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<Map<String, String>> countries = [
    {'name': 'UAE', 'code': '+971'},
    {'name': 'SA', 'code': '+966'},
    {'name': 'QA', 'code': '+974'},
    {'name': 'BH', 'code': '+973'},
    {'name': 'JO', 'code': '+962'},
    {'name': 'LB', 'code': '+961'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: NAppBar(),
        body: BlocBuilder<SignupBloc, SignupState>(builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _space(height: 20),
                Text("Create an account in Seconds!",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                    textAlign: TextAlign.left),
                _space(height: 20),
                NTextspan(title: NTexts.firstName),
                _space(height: 10),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    errorText: state.isFullNameValid ? null : 'Enter full name',
                    hintText: 'Your first name and last name',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        borderSide: BorderSide(width: 1, color: Colors.black)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        borderSide: BorderSide(
                          width: 1,
                        )),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        borderSide: BorderSide(width: 1, color: Colors.black)),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.allow(RegExp((r'[a-zA-Z\s]'))),
                  ],
                  keyboardType: TextInputType.text,
                  onChanged: (val) {
                    context.read<SignupBloc>().add(
                          FullNameChanged(val),
                        );
                  },
                ),
                _space(),
                NTextspan(title: NTexts.phonenumber),
                _space(height: 10),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: state.selectedCountryCode,
                          items: countries
                              .map(
                                (country) => DropdownMenuItem(
                                  value: country['code'],
                                  child: Text(
                                      "${country['name']} ${country['code']}"),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            context.read<SignupBloc>().add(
                                  CountryCodeChanged(val ?? '+971'),
                                );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.text,
                            onChanged: (val) {
                              context.read<SignupBloc>().add(
                                    InputChanged(val.trim()),
                                  );
                            },
                            decoration: InputDecoration(
                              hintText: "Enter your mobile Number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                _space(),
                NTextspan(title: NTexts.emailID),
                _space(height: 10),
                _email(),
                _space(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  height: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 65),
                        child: Checkbox(
                            value: state.termsandcondition,
                            onChanged: (_) {
                              context
                                  .read<SignupBloc>()
                                  .add(ToggleTermsandcondition());
                            }),
                      ),
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(text: NTexts.termsandcondition),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                _space(height: 15),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  height: 70,
                  margin: EdgeInsets.only(right: 60),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 45),
                        child: Checkbox(
                            value: state.receiveOffers,
                            onChanged: (_) {
                              context
                                  .read<SignupBloc>()
                                  .add(ToggleReceiveOffers());
                            }),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text:
                                        'I am over 18 years of age and I agree to by Proceeding I agree to Nestale Waters '),
                                TextSpan(
                                    text: 'Privacy Policy,Terms and Conditions',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        //open Policy link
                                      }),
                                // TextSpan(text: ',Terms and Conditions'),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0)),
                    ),
                    backgroundColor: state.isValid &&
                            state.isFullNameValid &&
                            state.receiveOffers &&
                            state.termsandcondition
                        ? Colors.blue
                        : Colors.grey,
                    minimumSize: Size(double.infinity, 40),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {},
                  child: Text('Create Account',
                      selectionColor: Colors.white,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15)),
                ),
                _space(height: 20),
              ],
            ),
          );
        }));
  }

  _space({double height = 16}) {
    return SizedBox(
      height: height,
    );
  }

  _email() {
    return NEmailTextField(
      emailController: emailController,
      showLabel: false,
      borderColor: Colors.black,
    );
  }
}
