import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utilis/app_constants.dart';

Widget introWidget(){
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/mask.png'),
            fit: BoxFit.cover
        )
    ),
    height: Get.height*0.6,

    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/redcross.jpg',
          width: 90,
          height: 90,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          AppConstants.appName,
          style: GoogleFonts.poppins(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget introWidgetWithoutLogos({String title = "Profile Settings",String? subtitle}){
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/mask.png'),
            fit: BoxFit.fill
        )
    ),
    height: Get.height*0.3,
    child: Container(
        height: Get.height*0.1,
        width: Get.width,
        margin: EdgeInsets.only(bottom: Get.height*0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,style: GoogleFonts.poppins(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.white),),
            if(subtitle != null) Text(subtitle,style: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.white),),

          ],
        )),

  );
}