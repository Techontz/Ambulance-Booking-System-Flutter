import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utilis/app_colors.dart';
import '../../widget/intro_widget.dart';

class DriverProfileSetup extends StatefulWidget {
  const DriverProfileSetup({Key? key}) : super(key: key);

  @override
  State<DriverProfileSetup> createState() => _DriverProfileSetupState();
}

class _DriverProfileSetupState extends State<DriverProfileSetup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  introWidgetWithoutLogos(
                    title: 'Let’s Get Started as driver',
                    subtitle: 'Complete the profile Details',
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        getImage(ImageSource.camera);
                      },
                      child: selectedImage == null
                          ? Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      )
                          : Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(selectedImage!),
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    textFieldWidget(
                      'User Name',
                      Icons.person_outlined,
                      nameController,
                          (String? input) {
                        if (input!.isEmpty) {
                          return 'User name is required!';
                        }
                        if (input.length < 5) {
                          return 'Please enter a valid name!';
                        }
                        return null;
                      },
                      onTap: () {},
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    textFieldWidget(
                      'Email',
                      Icons.email,
                      emailController,
                          (String? input) {
                        if (input!.isEmpty) {
                          return 'Email is required!';
                        }
                        if (!input.isEmail) {
                          return 'Enter a valid email.';
                        }
                        return null;
                      },
                      onTap: () async {},
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    textFieldWidget(
                      'License ID Number',
                      Icons.card_membership,
                      licenseController,
                          (String? input) {
                        if (input!.isEmpty) {
                          return 'License ID is required!';
                        }
                        return null;
                      },
                      onTap: () {},
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    textFieldWidget(
                      'Phone Number',
                      Icons.phone,
                      phoneController,
                          (String? input) {
                        if (input!.isEmpty) {
                          return 'Phone number is required!';
                        }
                        if (!RegExp(r'^0\d{9}$').hasMatch(input)) {
                          return 'Phone number must start with 0 and be exactly 10 digits';
                        }
                        return null;
                      },
                      onTap: () {},
                      readOnly: false,
                    ),
                    SizedBox(height: 30),
                    greenButton('Submit', () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      if (selectedImage == null) {
                        Get.snackbar('Warning', 'Please add your image');
                        return;
                      }
                      // Perform profile submission logic here
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textFieldWidget(
      String title,
      IconData iconData,
      TextEditingController controller,
      Function validator, {
        Function? onTap,
        bool readOnly = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xffA7A7A7),
          ),
        ),
        SizedBox(height: 6),
        Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            readOnly: readOnly,
            onTap: () => onTap!(),
            validator: (input) => validator(input),
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  iconData,
                  color: AppColors.greenColor,
                ),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget greenButton(String title, Function onPressed) {
    return MaterialButton(
      minWidth: Get.width,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: AppColors.greenColor,
      onPressed: () => onPressed(),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
