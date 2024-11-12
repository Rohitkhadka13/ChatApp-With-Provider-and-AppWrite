// ignore_for_file: use_build_context_synchronously

part of 'login_import.dart';


class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  String countryCode = "+61";

  void handleOtpSubmit(String userId, BuildContext context) {
    if (_formKey1.currentState!.validate()) {
      loginWithOtp(userId: userId, otp: _otpController.text).then((value) {
        if (value) {
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserId(userId);
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserPhone(countryCode +_phoneController.text);
          Navigator.pushNamedAndRemoveUntil(
              context, "/update", (route) => false,
              arguments: {"title": "add"});
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Login Failed")));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Image.asset(
                  "assets/chat.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome To ChitChat ",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Enter Your Phone Number To Continue"),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Your Phone Number";
                        } else if (value.length != 10) {
                          return "Please Enter valid Phone Number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: CountryCodePicker(
                            onChanged: (value) {
                              countryCode = value.dialCode!;
                            },
                            initialSelection: "AU",
                          ),
                          labelText: "Enter your Phone Number",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createPhoneSession(
                                    phone: countryCode + _phoneController.text)
                                .then((value) {
                              if (value != "login_error") {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("OTP Verification"),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                                "Enter the 6 digit Code"),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Form(
                                                key: _formKey1,
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value!.length != 6) {
                                                      return " Enter Valid OTP";
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: _otpController,
                                                  decoration: InputDecoration(
                                                    labelText: "Enter the OTP",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              handleOtpSubmit(value, context);
                                            },
                                            child: const Text("Submit"),
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Failed to send otp")));
                              }
                            });
                          }
                        },
                        child: const Text("Send OTP")),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
