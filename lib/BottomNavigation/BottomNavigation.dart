import 'package:cutomer_app/BottomNavigation/Appoinments/Appoinments.dart';
import 'package:flutter/material.dart';

import 'package:cutomer_app/ConfirmBooking/Dashboard.dart';

import 'package:cutomer_app/BottomNavigation/Profile/Profile.dart';
import 'package:cutomer_app/Utils/Constant.dart';

class BottomNavController extends StatefulWidget {
  final String mobileNumber;
  final int index;
  final int? appointmentTabIndex;

  const BottomNavController({
    super.key,
    required this.mobileNumber,
    required this.index,
    this.appointmentTabIndex,
  });

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;

    _pages = [
      ConsultationsType(mobileNumber: widget.mobileNumber),
      BookingListScreen(initialTabIndex: widget.appointmentTabIndex ?? 0),
      CustomerProfilePage(mobileNumber: widget.mobileNumber),
    ];
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  // 🔹 Side icon
  Widget _sideIcon(IconData icon, int index) {
    final bool active = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: SizedBox(
        height: 60, // ✅ constraint to avoid overflow
        width: 60,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, active ? -25 : 0, 0),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Active background circle
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: active ? 1 : 0,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Icon
              Icon(
                icon,
                size: 26,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Center floating button
  Widget _centerButton() {
    final bool active = _selectedIndex == 1;

    return GestureDetector(
      onTap: () => _onTap(1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, active ? -12 : -8, 0),
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: mainColor.withOpacity(0.4),
            )
          ],
        ),
        child: const Icon(
          Icons.eco_outlined, // 🌿 center icon
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 60, // ✅ increased height
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: mainColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, -6),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _sideIcon(Icons.calendar_month_outlined, 1),
            _sideIcon(Icons.home_outlined, 0),
            _sideIcon(Icons.person_pin_rounded, 2),
          ],
        ),
      ),
    );
  }
}
