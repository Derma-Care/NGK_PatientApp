import 'package:cutomer_app/APIs/FetchServices.dart';

 
 
 
import '../Controller/CustomerController.dart';

import 'package:cutomer_app/Dashboard/DashBoardController.dart';

 
 
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/TreatmentAndServices/ServiceSelectionController.dart';
import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
 
import 'package:get/get.dart';

void initializeControllers() {
  // Use lazyPut for safety
 
  Get.lazyPut(() => Dashboardcontroller());
  Get.lazyPut(() => Serviceselectioncontroller());
  Get.lazyPut(() => SelectedServicesController());

 

  Get.lazyPut(() => NotificationController());
  Get.lazyPut(() => ServiceFetcher());
 
 
  Get.lazyPut(() => SubServiceController());
  
}
