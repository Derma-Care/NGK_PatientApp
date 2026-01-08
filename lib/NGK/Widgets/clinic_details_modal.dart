import 'dart:convert';
import 'package:cutomer_app/NGK/ClinicManagement/ClinicModelWithLocation.dart';
import 'package:flutter/material.dart';
import '../Modals/clinic_model.dart';

class ClinicDetailsModal extends StatelessWidget {
  final ClinicModelWithLocation clinic;

  const ClinicDetailsModal({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- DRAG HANDLE ----------------
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // ---------------- LOGO + STATUS ----------------
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: clinic.hospitalLogo.startsWith("data:image")
                        ? Image.memory(
                            base64Decode(clinic.hospitalLogo.split(',').last),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.local_hospital, size: 40),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.circle,
                        //       size: 10,
                        //       color: clinic. ? Colors.green : Colors.grey,
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       clinic.online ? "Online" : "Offline",
                        //       style: TextStyle(
                        //         color:
                        //             clinic.online ? Colors.green : Colors.grey,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---------------- ADDRESS ----------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      clinic.address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---------------- RATING & DISTANCE ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        clinic.hospitalOverallRating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.map, size: 18),
                      const SizedBox(width: 4),
                      Text("${clinic.distanceInKm} KM"),
                    ],
                  ),
                ],
              ),

              const Divider(height: 32),

              // ---------------- TIMINGS ----------------
              const Text(
                "Clinic Timings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text("🕘 09:00 AM - 07:00 PM"),

              const Divider(height: 32),

              // ---------------- DOCTORS ----------------
              const Text(
                "Doctors Available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _doctorTile("Dr. Anil", "General Physician"),
              _doctorTile("Dr. Ravi Teja", "Orthopedic Surgeon"),

              const SizedBox(height: 24),

              // ---------------- ACTION BUTTONS ----------------
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 👉 Navigate to ServicesTabScreen
                      },
                      child: const Text("View Services"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      // call action
                    },
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.whatsapp, color: Colors.green),
                  //   onPressed: () {
                  //     // whatsapp action
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- DOCTOR TILE ----------------
  Widget _doctorTile(String name, String specialization) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$name – $specialization",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
