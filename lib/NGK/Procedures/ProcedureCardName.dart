import 'dart:math';

import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicLactionScreen.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureListScreen.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureScreenName.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';

class ProcedureCard extends StatelessWidget {
  final ProcedureOffer procedure;

  ProcedureCard({super.key, required this.procedure});

  /// ✅ Static gradients (shared for all cards)
  static const List<List<Color>> gradientColors = [
    [Color(0xFFff9a9e), Color(0xFFfad0c4)],
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
    [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
    [Color(0xFF84fab0), Color(0xFF8fd3f4)],
    [Color(0xFFfccb90), Color(0xFFd57eeb)],
    [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
  ];

  /// ✅ Random gradient (works now)
  final List<Color> gradient =
      gradientColors[Random().nextInt(gradientColors.length)];

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // ✅ CREATE MODEL CORRECTLY
        final ProcedureOffer procedureModel = ProcedureOffer(
          procedureId: procedure.procedureId,
          name: procedure.name,
          minOffer: 0,
          maxOffer: 0,
        );

        // ✅ NAVIGATE WITH MODEL
        // Get.to(() => SubServiceListScreen(
        //       mainProcedures: procedureModel,
        //     ));

        Get.to(
          () => const ClinicListLocationScreen(),
          arguments: {
            "procedureId": procedureModel.procedureId,
            "procedureName": procedureModel.name
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Procedure Name
              Text(
                procedure.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              // Offer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${procedure.minOffer}% - ${procedure.maxOffer}%",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "OFF",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
