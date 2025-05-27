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
            _phoneNumber(),
            _space(),
            _email(),
            _space(),
            _firstName(),
            _space(),
            _lastName(),
            _space(),
            _dateOfBirth(),
            _space(),
            _gender(),
            _space(),
            _newPassword(),
            _space(),
            _confirmPassword(),
            _space(),
            _accountType(),
            _space(),
            _communicationType(),
            _space(height: 20),
            _createAccount(),
            _space(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  _space({double height = 16}){
    return SizedBox(
      height: height,
    );
  }

  _phoneNumber() {
    return NPhoneInputWidget(
      phoneController: _phoneController,
    );
  }

  _email() {
    return NEmailTextField(
      emailController: _emailController,
    );
  }

  _firstName() {
    return NTextField(
      title: 'First name',
      hintText: 'Enter First Name',
    );
  }

  _lastName() {
    return NTextField(
      title: 'Last Name',
      hintText: 'Enter Last Name',
    );
  }

  _dateOfBirth() {
    return NDatePicker(
      title: 'Date Of Birth',
      hintText: 'Select Date Of Birth',
    );
  }

  _gender() {
    return NDropdown(
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
    );
  }

  _newPassword() {
    return NTextField(
      title: 'New Password',
      hintText: 'Enter New Password',
    );
  }

  _confirmPassword() {
    return NPasswordTextField(
      passwordController: _passwordController,
      label: 'Confirm Password',
      hintText: 'Enter Confirm Password',
      showLeftIcon: false,
    );
  }

  _accountType() {
    return NRadioGroup(
      items: ['Residential', 'Business'],
      labelBuilder: (item) => item,
      onChanged: (String value) {},
      direction: Axis.horizontal,
    );
  }

  _communicationType() {
    return Column(
      children: [
        NCheckbox(
          value: false,
          onChanged: (bool value) {}, title: 'WhatsApp/SMS',
        ),
        _space(),
        NCheckbox(
          value: false,
          onChanged: (bool value) {},
          title: 'Email',
        )
      ],
    );
  }

  _createAccount() {
    return NElevatedButton(
      text: 'Create Account',
      onPressed: () {},
    );
  }

}


