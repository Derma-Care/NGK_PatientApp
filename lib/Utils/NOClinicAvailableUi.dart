import 'package:flutter/material.dart';

noClinicAvailableUI() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_hospital_outlined,
          size: 80,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        const Text(
          "No Clinics Available",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        // const Text(
        //   "This service is not available near your location",
        //   textAlign: TextAlign.center,
        //   style: TextStyle(
        //     fontSize: 13,
        //     color: Colors.black45,
        //   ),
        // ),
      ],
    ),
  );
}

noServiceAvailableUI(IconData  icon, String serviceName) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 80,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
          Text(
          "${serviceName} Not Available",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        // const Text(
        //   "This service is not available near your location",
        //   textAlign: TextAlign.center,
        //   style: TextStyle(
        //     fontSize: 13,
        //     color: Colors.black45,
        //   ),
        // ),
      ],
    ),
  );
}
