import 'package:flutter/material.dart';
import 'package:nestle_waters_purelife/utils/widgets/app_bar.dart';
import 'package:nestle_waters_purelife/utils/widgets/check_box.dart';
import 'package:nestle_waters_purelife/utils/widgets/date_picker.dart';
import 'package:nestle_waters_purelife/utils/widgets/drop_down.dart';
import 'package:nestle_waters_purelife/utils/widgets/elevated_button.dart';
import 'package:nestle_waters_purelife/utils/widgets/email_text_field.dart';
import 'package:nestle_waters_purelife/utils/widgets/password_text_field.dart';
import 'package:nestle_waters_purelife/utils/widgets/phone_input_widget.dart';
import 'package:nestle_waters_purelife/utils/widgets/radio_button.dart';
import 'package:nestle_waters_purelife/utils/widgets/text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            NPhoneInputWidget(
              phoneController: _phoneController,
              enabled: true,
            ),
            SizedBox(
              height: 16,
            ),
            NEmailTextField(
              emailController: _emailController,
            ),
            SizedBox(
              height: 16,
            ),
            NTextField(
              title: 'First name',
              hintText: 'Enter First Name',
            ),
            SizedBox(
              height: 16,
            ),
            NTextField(
              title: 'Last Name',
              hintText: 'Enter Last Name',
            ),
            SizedBox(
              height: 16,
            ),
            NDatePicker(
              title: 'Date Of Birth',
              hintText: 'Select Date Of Birth',
            ),
            SizedBox(
              height: 16,
            ),
            NDropdown(
              title: 'Gender',
              hint: Text('Select Gender'),
              value: _selectedGender,
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
            ),
            SizedBox(
              height: 16,
            ),
            NTextField(
              title: 'New Password',
              hintText: 'Enter New Password',
            ),
            SizedBox(
              height: 16,
            ),
            NPasswordTextField(
              passwordController: _passwordController,
              label: 'Confirm Password',
              hintText: 'Enter Confirm Password',
              showLeftIcon: false,
            ),
            SizedBox(
              height: 16,
            ),
            NRadioGroup(
              items: ['Residential', 'Business'],
              labelBuilder: (item) => item,
              onChanged: (String value) {  },
              direction: Axis.horizontal,
            ),
            SizedBox(
              height: 16,
            ),
            NCheckbox(
              value: false,
              onChanged: (bool value) {
              }, title: 'WhatsApp/SMS',
            ),
            SizedBox(
              height: 6,
            ),
            NCheckbox(
              value: false,
              onChanged: (bool value) {
              },
              title: 'Email',
            ),
            SizedBox(
              height: 20,
            ),
            NElevatedButton(
              text: 'Create Account',
              onPressed: () {
              },
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
