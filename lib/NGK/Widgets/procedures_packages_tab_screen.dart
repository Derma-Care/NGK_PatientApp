import 'package:cutomer_app/NGK/Packges/PackageListScreen.dart';
import 'package:cutomer_app/NGK/Procedures/ProcedureListScreen.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

class ServicesTabScreen extends StatefulWidget {
  final bool isClinic;

  const ServicesTabScreen({super.key, this.isClinic = false});
  @override
  State<ServicesTabScreen> createState() => _ServicesTabScreenState();
}

class _ServicesTabScreenState extends State<ServicesTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: "Services"),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              labelColor: Colors.pink,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.pink,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Procedures"),
                Tab(text: "Packages"),
              ],
            ),
          ),

          // ---------------- CONTENT TABS ----------------
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                SubServiceListScreen(
                  hideHeader: true,
                  isClinic: widget.isClinic,
                ),
                PackageListScreen(
                  hideHeader: true,
                  isClinic: widget.isClinic,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
