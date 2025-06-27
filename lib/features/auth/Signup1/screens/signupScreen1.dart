import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nestle_waters_purelife/features/auth/Signup1/bloc/register_event.dart';
import 'package:nestle_waters_purelife/features/auth/Signup1/bloc/register_state.dart';
import 'package:nestle_waters_purelife/utils/constants/text_strings.dart';
import 'package:nestle_waters_purelife/utils/widgets/app_bar.dart';
import 'package:nestle_waters_purelife/utils/widgets/email_text_field.dart';
import 'package:nestle_waters_purelife/utils/widgets/password_text_field.dart';
import 'package:nestle_waters_purelife/utils/widgets/phone_input_widget.dart';
import 'package:nestle_waters_purelife/utils/widgets/text.dart';
import 'package:nestle_waters_purelife/utils/widgets/text_field.dart';
import 'package:nestle_waters_purelife/utils/widgets/textspan.dart';

class SignupScreen1 extends StatelessWidget {
  SignupScreen1({super.key});

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _space(height: 20),
            _imagelogo(),
            //_titlelable(),
            _space(),
            Text(NTexts.signupheader,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _space(),
            Text(NTexts.signupsubheader,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            _space(height: 20),
            NTextspan(title: NTexts.firstName),
            _space(height: 8),
            _firstName(),
            _space(),
            NTextspan(title: NTexts.lastName),
            _space(height: 8),
            _lastName(),
            _space(),
            NTextspan(title: NTexts.phoneNo),
            _space(height: 8),
            _phoneNumber(),
            _space(),
            NTextspan(title: NTexts.emailID),
            _space(height: 8),
            _email(),
            _space(),
            NTextspan(title: NTexts.createpassword),
            _space(height: 8),
            _newPassword(),
            _space(),
            NTextspan(title: NTexts.confirmPassword),
            _space(height: 8),
            _confirmPassword(),
            _space(),

            buildTopAlignedCheckbox(
              value: null != null,
              // onChanged: (val) => setState(() => receiveOffers = val!),
              text:
                  NTexts.termsandcondition,
              onChanged: (bool) {},
            ),

            SizedBox(height: 16),
            buildTopAlignedCheckbox(
              textWidget: RichText(
                text: TextSpan(
                  text:
                      NTexts.termsandprivacy,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    TextSpan(
                      text: 'Privacy Notice.*',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              onChanged: (bool) {},
              value: null != null,
            ),

            // CheckboxListTile(
            //         value: null != null,
            //         onChanged: (_) {
            //           //context.read<Bloc>().add(ToggleReceiveOffers());
            //         },
            //         title: Text(
            //           'I would like to receive offers, and be contacted by, or on behalf of NESTLÉ® through phone, SMS, and Email, about NESTLÉ®, its brands, special offers, consumer research and promotions is required.',
            //           style: TextStyle(fontSize: 14),
            //           textAlign: TextAlign.start,
            //         ),
            //         controlAffinity: ListTileControlAffinity.leading,
            // ),

            //       CheckboxListTile(
            //         // value: state.isOver18,
            //         onChanged: (_) {
            //           //context.read<CheckboxBloc>().add(ToggleIsOver18());
            //         },
            //         title: RichText(
            //           text: TextSpan(
            //             text:
            //                 'I am over 18 years of age and I agree to NESTLÉ® processing my personal data in accordance with the NESTLÉ® ',
            //             style: TextStyle(color: Colors.black, fontSize: 14),
            //             children: [
            //               TextSpan(
            //                 text: 'Privacy Notice.',
            //                 style: TextStyle(
            //                   color: Colors.blue,
            //                   decoration: TextDecoration.underline,
            //                 ),
            //               )
            //             ],
            //           ),
            //         ),
            //         controlAffinity: ListTileControlAffinity.leading, value: null,
            //       ),
            SizedBox(height: 24),
            ElevatedButton(
              // onPressed: state.isOver18
              //     ? () {
              //         // Proceed with account creation
              //       }
              //     : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
      ),
    );
  }

  _imagelogo() {
    return Center(
        child: Image.asset(
      "assets/images/nestlelogo.png",
      fit: BoxFit.cover,
      height: 150,
      width: 150,
    ));
  }

  _firstName() {
    return NTextField(
      controller: firstNameController,
      // decoration:InputDecoration(
      // labelText: "Enter your Name",
      // errorText:  "empty name",
      // border: const OutlineInputBorder(),
      // ),
      // onChanged: (value) {
      //   // Context.read<
      // },
      hintText: 'Enter First Name',
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp((r'[a-zA-Z\s]'))),
      ],
      keyboardType: TextInputType.text,
    );
  }

  _lastName() {
    return NTextField(
       hintText: 'Enter Last Name',
       inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp((r'[a-zA-Z\s]'))),
      ],
      keyboardType: TextInputType.name, 
      // decoration: InputDecoration(),
    );
  }

  _space({double height = 16}) {
    return SizedBox(
      height: height,
    );
  }

  _phoneNumber() {
    return NPhoneInputWidget(
      phoneController: phoneController,
      showLabels: false,
    );
  }

  _email() {
    return NEmailTextField(
      emailController: emailController,
      showLabel: false,
    );
  }

  _newPassword() {
    return NTextField(
      //title: 'New Password',
      hintText: 'Enter New Password', 
      //decoration: InputDecoration(),
    );
  }

  _confirmPassword() {
    return NPasswordTextField(
      passwordController: passwordController,
      //label: 'Confirm Password',
      hintText: 'Enter Confirm Password',
      showLeftIcon: false,
      showLabel: false,
    );
  }
}

Widget buildTopAlignedCheckbox({
  required bool value,
  required void Function(bool?) onChanged,
  String? text,
  Widget? textWidget,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Checkbox(
        value: value,
        onChanged: onChanged,
      ),
      Expanded(
        child: textWidget ??
            Text(
              text ?? '',
              style: TextStyle(fontSize: 15),
            ),
      ),
    ],
  );
}
