import 'package:cutomer_app/APIs/FetchServices.dart';

 
 
 
 

import 'package:cutomer_app/Dashboard/DashBoardController.dart';

 
 
import 'package:cutomer_app/Notification/NotificationController.dart';
 
 
 
import 'package:get/get.dart';

void initializeControllers() {
  // Use lazyPut for safety
 
  Get.lazyPut(() => Dashboardcontroller());
 
 

 

  Get.lazyPut(() => NotificationController());
  Get.lazyPut(() => ServiceFetcher());
 
 
  
}
