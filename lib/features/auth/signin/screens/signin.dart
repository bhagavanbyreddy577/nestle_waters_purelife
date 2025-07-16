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
                // SizedBox(height: 2),
                // Text("Sign In If you already have an account with us",
                //     style: TextStyle(
                //         fontWeight: FontWeight.w400,
                //         fontSize: 12,
                //         color: Colors.black),
                //     textAlign: TextAlign.left),
                SizedBox(height: 24),
                Text("Enter your email or phone number for\nOTP",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    textAlign: TextAlign.left),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //if (!state.isEmail) // Country Code Picker only for phone
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.0),
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

                    state.isValid
                        ? Container(
                            decoration: BoxDecoration(color: Colors.white),
                            height: 42,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 22),
                                  child: Checkbox(
                                      side: BorderSide(
                                      color: Color(0xFF0055A5), width: 2.0),
                                      focusColor: const Color(0xFF0055A5),
                                      activeColor: const Color(0xFF0055A5),
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
                          )
                        : SizedBox(),

                    state.isValid ? SizedBox(height: 25) : SizedBox(),

                    Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SignInContinuebutton(
                            isEnabled: state.isValid && state.receiveOffers,
                            onPressed: () {
                              //Navigate to OTP Screen
                            },
                          )
                        ]),
                    //state.isValid && state.receiveOffers)
                    // ElevatedButton(
                    //   clipBehavior: Clip.antiAlias,
                    //   style: ElevatedButton.styleFrom(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.only(
                    //           topRight: Radius.circular(10.0),
                    //           topLeft: Radius.circular(10.0),
                    //           bottomLeft: Radius.circular(10.0),
                    //           bottomRight: Radius.circular(10.0)),
                    //     ),
                    //     backgroundColor: state.isValid && state.receiveOffers
                    //         ? Colors.blue
                    //         : Colors.grey,
                    //     minimumSize: Size(double.infinity, 40),
                    //     textStyle: TextStyle(fontSize: 16),
                    //   ),
                    //   onPressed: () {},
                    //   child: Text('Continue',
                    //       selectionColor: Colors.white,
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.w500,
                    //           fontSize: 15)),
                    // ),
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

//Created the Custome

class SignInContinuebutton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const SignInContinuebutton(
      {super.key, required this.isEnabled, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: CustomPaint(
          painter: isEnabled ? StateValid() : StateInValid(),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(34)),
            height: 40, //32,
            width: 135,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 9.0, bottom: 2),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: isEnabled ? Colors.white : const Color(0xFFC5C5C5),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 35),
                Icon(
                  size: 20,
                  Icons.arrow_forward,
                  color: isEnabled ? Colors.white : const Color(0xFFC5C5C5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StateValid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFFDA2188); // Pink
    final paint2 = Paint()..color = const Color(0xFF00386D); // Navy

    final path1 = Path()
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.70, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(size.width * 0.75, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.70, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StateInValid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFFFFFFFF); // Pink
    final paint2 = Paint()..color = const Color(0xFFFFFFFF); // Navy

    final path1 = Path()
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.70, size.height)
      ..lineTo(0, size.height)
      ..close();

    final path2 = Path()
      ..moveTo(size.width * 0.75, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.70, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
