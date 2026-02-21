import 'dart:convert';

import 'package:cutomer_app/NGK/ClinicManagement/AboutClinicScreen.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:cutomer_app/NGK/Packges/PackageListScreen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

Widget buildClinicCard(ClinicModelWithLocation clinic) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () {
      Get.to(() => PackageListScreen(
            clinicData: clinic,
          ));
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 LEFT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade200,
              child: clinic.hospitalLogo.isNotEmpty
                  ? Image.memory(
                      base64Decode(
                        clinic.hospitalLogo.contains(',')
                            ? clinic.hospitalLogo.split(',').last
                            : clinic.hospitalLogo,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_hospital,
                          size: 40,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons.local_hospital,
                      size: 40,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          /// 🔹 RIGHT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 CLINIC NAME
                    Expanded(
                      child: Text(
                        clinic.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    /// 🔹 VIEW ICON BUTTON
                    GestureDetector(
                      onTap: () {
                        Get.to(() => AboutClinicScreen(
                              distanceInKm: clinic.distanceInKm ?? "",
                              clinicId: clinic.clinicId,
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: mainColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// DISTANCE + RATING + OFFER
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.red),
                    const SizedBox(width: 3),
                    Text(clinic.distanceInKm ?? ""),
                    const SizedBox(width: 10),
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 3),
                    Text(
                      clinic.hospitalOverallRating.toStringAsFixed(1),
                    ),
                    const SizedBox(width: 10),
                    if ((clinic.maxOfferPercentage ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "upto ${clinic.maxOfferPercentage!.toStringAsFixed(0)}% OFF",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                /// ADDRESS
                Text(
                  clinic.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                /// CITY
                Text(
                  clinic.city,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 6),

                /// ABOUT BUTTON
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: SizedBox(
                //     height: 28,
                //     child: OutlinedButton(
                //       onPressed: () {
                //         Get.to(() => AboutClinicScreen(
                //               distanceInKm: clinic.distanceInKm ?? "",
                //               clinicId: clinic.clinicId, // ✅ SEND FULL OBJECT
                //             ));
                //       },
                //       style: OutlinedButton.styleFrom(
                //         padding: const EdgeInsets.symmetric(horizontal: 12),
                //         side: const BorderSide(color: Colors.deepOrange),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(6),
                //         ),
                //       ),
                //       child: const Text(
                //         "About",
                //         style: TextStyle(
                //           fontSize: 12,
                //           fontWeight: FontWeight.w600,
                //           color: Colors.deepOrange,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
