import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/openGoogleCalendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingSuccessScreen extends StatefulWidget {
  final String clinicName;
  final String serviceName;
  final String appointmentDate;
  final String clinicAddress;
  final String mobile;
  final String bookingId;

  const BookingSuccessScreen({
    super.key,
    required this.clinicName,
    required this.serviceName,
    required this.appointmentDate,
    required this.clinicAddress,
    required this.mobile,
    required this.bookingId,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  DateTime getAppointmentStart(String date) {
    final parsed = DateTime.parse(date);
    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
      8, // ✅ 8 AM
      0,
    );
  }

  DateTime getAppointmentEnd(String date) {
    final parsed = DateTime.parse(date);
    return DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
      10, // ✅ 10 AM
      0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _askGoogleCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 DRAG HANDLE
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Text(
                  "Add to Google Calendar?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainColor),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Do you want to save this appointment in your Google Calendar?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 24),

                /// 🔘 BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _goToDashboard();
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: mainColor,
                            side: const BorderSide(
                              color: mainColor,
                            ),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                        child: const Text("No"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          // 🔥 DO NOT await
                          openGoogleCalendar(
                            title: widget.serviceName,
                            description:
                                "Appointment at ${widget.clinicName}\nService: ${widget.serviceName}",
                            location: widget.clinicAddress,
                            startDate:
                                getAppointmentStart(widget.appointmentDate),
                            endDate: getAppointmentEnd(widget.appointmentDate),
                          );

                          // 🔥 Delay navigation
                          Future.delayed(const Duration(milliseconds: 600), () {
                            _goToDashboard();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Yes"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToDashboard() {
    Navigator.popUntil(context, (route) => route.isFirst);
    Get.offAll(() => BottomNavController(
          mobileNumber: widget.mobile,
          index: 1,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF5F9E), Color(0xFFFF8FB3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ✅ Animated Tick
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 70,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Booking Confirmed!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                /// 📄 DETAILS CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _infoRow("Clinic", widget.clinicName),
                      _infoRow("Service", widget.serviceName),
                      _infoRow("Date", widget.appointmentDate),
                      _infoRow("Address", widget.clinicAddress),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔘 GO TO APPOINTMENTS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _askGoogleCalendar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.pink,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Go to Appointments",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mainColor),
                    ),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     openGoogleCalendar(
                //       title: "Test Appointment",
                //       description: "Testing calendar",
                //       location: "Hyderabad",
                //       startDate: DateTime.now().add(const Duration(minutes: 5)),
                //     );
                //   },
                //   child: const Text("Test Calendar"),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
