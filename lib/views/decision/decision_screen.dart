import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../widget/buttons.dart';
import '../../widget/intro_widget.dart';
import '../driver/driver_login.dart';
import '../driver/profile.dart';
import '../login.dart';

class DecisionScreen extends StatelessWidget {
  DecisionScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            introWidget(),

            const SizedBox(height: 50,),

            DecisionButton(
                'assets/driver.png',
                'Login As Driver',
                    (){

                  Get.to(()=> DriverLoginScreen());
                },
                Get.width*0.8
            ),

            const SizedBox(height: 20,),
            DecisionButton(
                'assets/customer.png',
                'Login As User',
                    (){
                  Get.to(()=> LoginScreen());



                },
                Get.width*0.8
            ),
          ],
        ),
      ),
    );
  }
}