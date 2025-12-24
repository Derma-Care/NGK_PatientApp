import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Packges/PackageModel.dart';
import 'package:cutomer_app/Payments/AllPayments.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackageBookingSheet extends StatefulWidget {
  final PaymentModal payment;

  const PackageBookingSheet({
    super.key,
    required this.payment,
  });

  @override
  State<PackageBookingSheet> createState() => _PackageBookingSheetState();
}

class _PackageBookingSheetState extends State<PackageBookingSheet> {
  int? selectedIndex;
  bool useCoins = false;
  final ReferralWalletController walletController =
      Get.find<ReferralWalletController>();
  double get coinValue => walletController.walletBalance.toDouble();
// Value of coins
  List<DateTime> next15days = List.generate(
    15,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  Widget build(BuildContext context) {
    double discountAmount =
        widget.payment.price * (widget.payment.discountPercentage / 100);
    double discountedPrice = widget.payment.price - discountAmount;

    double tax = 18;
    double platformFee = 25;

    double taxAmount = discountedPrice * tax / 100;

    double total = discountedPrice + taxAmount + platformFee;

    // apply coins
    double finalPayable = useCoins ? (total - coinValue) : total;
    if (finalPayable < 0) finalPayable = 0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Center(
              child: Container(
                width: 50,
                height: 6,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text("Select a Date",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            // -------------------- DATE SELECTOR --------------------
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: next15days.length,
                itemBuilder: (_, i) {
                  DateTime date = next15days[i];
                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = i),
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: selectedIndex == i
                            ? mainColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              color: selectedIndex == i
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            [
                              "Sun",
                              "Mon",
                              "Tue",
                              "Wed",
                              "Thu",
                              "Fri",
                              "Sat"
                            ][date.weekday % 7],
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedIndex == i
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // -------------------- PRICE DETAILS --------------------
            const Text("Payment Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            priceRow("Original Price", widget.payment.price),
            priceRow(
                "Discount (${widget.payment.discountPercentage.toInt()}%)",
                -widget.payment.price *
                    widget.payment.discountPercentage /
                    100),
            priceRow("Tax (18%)", taxAmount),
            priceRow("Platform Fee", platformFee),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Use Coins",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Transform.scale(
                      scale: 0.60,
                      child: Switch(
                        activeColor: mainColor,
                        value: useCoins,
                        onChanged: (v) {
                          setState(() {
                            useCoins = v;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                /// ✅ SHOW ONLY IF BALANCE > 0
                Obx(() {
                  final balance = walletController.walletBalance;

                  if (balance <= 0) {
                    return const SizedBox(); // 🔥 hide text
                  }

                  return Text(
                    "-₹ $balance",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // ⚠️ don't use white unless dark bg
                    ),
                  );
                }),
              ],
            ),

            const Divider(thickness: 1.2),

            priceRow("Total Payable", finalPayable, isBold: true),

            const SizedBox(height: 20),

            // PAY BUTTON
            ElevatedButton(
              onPressed: () {
                if (selectedIndex == null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: const Text(
                          "Alert",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text("Please select a date"),
                      );
                    },
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RazorpaySubscription(
                            amount: finalPayable.toString(),
                            onPaymentInitiated: () {},
                            context: context,
                            mobileNumber: '',
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Pay Now",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget priceRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: isBold ? 17 : 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
          Text("₹${amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: isBold ? 17 : 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
