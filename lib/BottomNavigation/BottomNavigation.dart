import 'package:cutomer_app/BottomNavigation/Profile/Profile.dart';
import 'package:cutomer_app/ConfirmBooking/Consultations.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Appoinments/Appoinments.dart';

import 'Profile/Profiles.dart';

class BottomNavController extends StatefulWidget {
  final String mobileNumber;

  final int index;

  const BottomNavController({
    Key? key,
    required this.mobileNumber,
    required this.index,
  }) : super(key: key);

  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  late int _selectedIndex;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    print("doctorController.mobileNumber ${widget.mobileNumber}");

    _selectedIndex = widget.index;

    // Initialize pages
    _pages = [
      ConsultationsType(
        mobileNumber: widget.mobileNumber,
      ),
      BookingListScreen(),
      CustomerProfilePage(
        mobileNumber: widget.mobileNumber,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, secondaryColor],
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 1, 17, 61),
          unselectedItemColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              label: 'Appointment',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_2_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
