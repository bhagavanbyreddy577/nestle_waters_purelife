import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signin/presentation/bloc/signin_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signin/presentation/bloc/signin_event.dart';
import 'package:nestle_waters_purelife/features/auth/signin/presentation/bloc/signin_state.dart';

class Signin extends StatelessWidget {
  final List<Map<String, String>> countries = [
    {'name': 'UAE', 'code': '+971'},
    {'name': 'SA', 'code': '+966'},
    {'name': 'QA', 'code': '+974'},
    {'name': 'BH', 'code': '+973'},
    {'name': 'JO', 'code': '+962'},
    {'name': 'LB', 'code': '+961'},
  ];

  Signin({super.key});
  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SigninBloc, SigninState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Hello!",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 2),
                Text("Sign In If you already have an account with us",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black),
                    textAlign: TextAlign.left),
                SizedBox(height: 20),
                Text("Enter your email or phone number for OTP",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.left),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //if (!state.isEmail) // Country Code Picker only for phone
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
                            if (state.showCountryDropdown && state.showClear)
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
                                  context.read<SigninBloc>().add(
                                        CountryCodeChanged(val ?? '+971'),
                                      );
                                },
                              ),
                            Expanded(
                              child: TextField(
                                controller: inputController,
                                keyboardType: TextInputType.text,
                                onChanged: (val) {
                                  context.read<SigninBloc>().add(
                                        InputChanged(val.trim()),
                                      );
                                },
                                decoration: InputDecoration(
                                  hintText: "Your Email / mobile Number",
                                  suffixIcon: state.showClear
                                      ? IconButton(
                                          onPressed: () {
                                            context
                                                .read<SigninBloc>()
                                                .add(InputChanged(''));
                                          },
                                          icon: const Icon(Icons.clear))
                                      : null,
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
                          "Enter your Valid Email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      height: 42,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 22),
                            child: Checkbox(
                                value: state.receiveOffers,
                                onChanged: (_) {
                                  context
                                      .read<SigninBloc>()
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
                                            'By Continuing I agree to Nestle Waters '),
                                    TextSpan(
                                        text:
                                            'Privacy Policy,Terms and Conditions',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline),
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
                    SizedBox(height: 25),

                    ElevatedButton(
                      clipBehavior: Clip.antiAlias,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),
                        ),
                        backgroundColor: state.isValid && state.receiveOffers
                            ? Colors.blue
                            : Colors.grey,
                        minimumSize: Size(double.infinity, 40),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {},
                      child: Text('Continue',
                          selectionColor: Colors.white,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
