import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Help/HelpSupport.dart';
import 'package:cutomer_app/Screens/ngk_terms_conditions_screen.dart';
import 'package:cutomer_app/Utils/CommonCarouselAds.dart';
import 'package:cutomer_app/Utils/UpperCase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Inputs/CustomInputField.dart';
import '../NetworkCheck/NetworkService.dart';
import '../Utils/Constant.dart';
import '../Utils/CopyRigths.dart';
import '../Utils/ElevatedButtonGredint.dart';
import 'LoginController.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  SiginSignUpController siginSignUpController = SiginSignUpController();
  final dashboardcontroller = Get.find<Dashboardcontroller>();

  @override
  void dispose() {
    NetworkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: CommonCarouselAds(
                media: dashboardcontroller.carouselImages,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),

            // Image.asset(
            //   'assets/ic_launcher.png', // Ensure this path is correct
            //   width: 150,

            //   fit: BoxFit.cover,
            // ),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Neeha's Glow Kart",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Form(
                key: siginSignUpController.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'User Login',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.normal,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    CustomTextField(
                      controller: siginSignUpController.mobileController,
                      labelText: 'Enter Mobile Number',
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) =>
                          siginSignUpController.validateMobileNumber(value),
                    ),
                    Obx(() =>
                        siginSignUpController.errorMessage.value.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  siginSignUpController.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : const SizedBox.shrink()),
                    Text(siginSignUpController.errorMessage.value),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GradientButton(
                        text: siginSignUpController.getOTPButton.value,
                        onPressed: siginSignUpController.isLoading.value
                            ? null
                            : () {
                                siginSignUpController.submitForm(context);
                              },
                        child: Obx(() => Text(
                              siginSignUpController.getOTPButton.value,
                              style: const TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const HelpSupportSheet(),
                );
              },
              child: const Text(
                'Help & Support',
                style: TextStyle(color: mainColor),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Copyrights(
            color: mainColor,
          )),
    );
  }
}
