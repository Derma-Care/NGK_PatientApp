import 'package:cutomer_app/NGK/BookingAppointmnet/BookingRequestModel.dart';
import 'package:cutomer_app/NGK/ClinicManagement/clinic_slot_controller.dart';
import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Modals/PriceCalculationModel.dart';
import 'package:cutomer_app/NGK/Service/PriceCalculationService.dart';

import 'package:cutomer_app/Payments/AllPayments.dart';
import 'package:cutomer_app/Utils/Constant.dart';

import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackageBookingSheet extends StatefulWidget {
  final PaymentModal payment;
  final String? info;

  const PackageBookingSheet({
    super.key,
    required this.payment,
    this.info,
  });

  @override
  State<PackageBookingSheet> createState() => _PackageBookingSheetState();
}

class _PackageBookingSheetState extends State<PackageBookingSheet> {
  int? selectedIndex;
  bool useCoins = false;
  final ReferralWalletController walletController =
      Get.find<ReferralWalletController>();
  final ClinicSlotController slotController = Get.put(ClinicSlotController());

  double get coinValue =>
      walletController.walletSummary.value?.totalCredits.toDouble() ?? 0.0;
  final ScrollController _scrollController = ScrollController();
  final customerController = Get.find<CustomerGetController>();
  String? mobile;
  PriceCalculationModel? priceCalc;
  bool priceLoading = false;

// Value of coins
  @override
  void initState() {
    super.initState();
    slotController.fetchSlots(widget.payment.clinicId);

    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    mobile = prefs.getString('mobileNumber');

    if (mobile != null && mobile!.isNotEmpty) {
      customerController.fetchCustomer(mobile!);
    } else {
      showSnackbar("Error", "Mobile number not found", "error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double platformFee = 10;

    double total = widget.payment.finalCost;

    double coinsUsed = 0;

    if (useCoins && coinValue > 0) {
      coinsUsed = coinValue > total ? total : coinValue;
    }

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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Select a Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------- DATE SELECTOR --------------------
            SizedBox(
              height: 85,
              child: Obx(() {
                // 🔹 LOADING STATE
                if (slotController.isLoading.value) {
                  return const Center(
                    child: SpinKitThreeBounce(
                      color: Colors.pink,
                      size: 22,
                    ),
                  );
                }

                // 🔹 EMPTY STATE (after loading)
                if (slotController.slots.isEmpty) {
                  return const Center(
                    child: Text(
                      "No slots available",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                // 🔹 DATA STATE
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: slotController.slots.length,
                  itemBuilder: (_, i) {
                    final slot = slotController.slots[i];
                    final date = DateTime.parse(slot.date);
                    final isDisabled = !slot.workingHours;

                    return Obx(() {
                      final isSelected =
                          slotController.selectedIndex.value == i;

                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () => slotController.selectSlot(i),
                        child: Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDisabled
                                ? Colors.grey.shade300
                                : isSelected
                                    ? mainColor
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: isDisabled
                                ? Border.all(color: Colors.redAccent)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${date.day}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                slot.dayOfWeek.substring(0, 3),
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              if (isDisabled)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    slot.reason ?? "Unavailable",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 25),

            // -------------------- PRICE DETAILS --------------------
            const Text("Payment Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (widget.info != null)
              Text("Note: ${widget.info ?? ""}",
                  style: TextStyle(fontSize: 12, color: mainColor)),

            const SizedBox(height: 12),

            priceRow("Original Price", widget.payment.price, ""),
            priceRow("Consultation", widget.payment.consultationFee, ""),
            priceRow("GST (${widget.payment.gst.toStringAsFixed(0)}%)",
                widget.payment.gstAmount, ""),
            if (widget.payment.taxAmount != 0)
              priceRow(
                  "Tax (${widget.payment.taxPercentage.toStringAsFixed(0)}%)",
                  widget.payment.taxAmount,
                  ""),

            if (widget.payment.totalDiscountPercentage != 0)
              priceRow(
                  "Discount (${widget.payment.totalDiscountPercentage.toStringAsFixed(0)}%)",
                  widget.payment.totalDiscountAmount,
                  "-"),

            priceRow("Platform Fee ", platformFee, ""),

            if (useCoins && priceCalc != null && priceCalc!.appliedPoints > 0)
              priceRow(
                "Coins Applied",
                -priceCalc!.appliedPoints.toDouble(),
                "",
                amountColor: Colors.red,
              ),

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
                  ],
                ),
                Transform.scale(
                  scale: 0.60,
                  child: Switch(
                    activeColor: mainColor,
                    value: useCoins,
                    onChanged: (v) async {
                      setState(() {
                        useCoins = v;
                        priceLoading = true;
                      });

                      final payload = {
                        "customerId":
                            customerController.customer.value!.customerId,
                        "clinicId": widget.payment.clinicId,
                        "serviceId": widget.payment.serviceId,
                        "serviceType": widget.payment.serviceType,
                        if (v)
                          "pointsToRedeem": coinValue.toInt(), // ✅ only when ON
                      };

                      try {
                        priceCalc =
                            await PriceCalculationService.calculatePrice(
                                payload);
                      } catch (e) {
                        showSnackbar("Error", e.toString(), "error");
                        useCoins = false;
                      }

                      setState(() {
                        priceLoading = false;
                      });
                    },
                  ),
                ),

                /// ✅ SHOW ONLY IF BALANCE > 0
                // Obx(() {
                //   final balance = walletController
                //       .walletSummary.value!.totalCredits
                //       .toDouble();

                //   if (balance <= 0) {
                //     return const SizedBox(); // 🔥 hide text
                //   }

                //   return Text(
                //     "-₹ $balance",
                //     style: const TextStyle(
                //       fontSize: 15,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.black, // ⚠️ don't use white unless dark bg
                //     ),
                //   );
                // }),
              ],
            ),
            Text(
              "ℹ️ You have ${walletController.walletSummary.value?.balance} coins. By enabling this option, up to half of your coins will be used for this booking.",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey, // ⚠️ don't use white unless dark bg
              ),
            ),
            const Divider(thickness: 1.2),

            priceRow(
              "Total Payable",
              useCoins && priceCalc != null
                  ? priceCalc!.finalAmount
                  : priceCalc?.originalFinalAmount ?? widget.payment.finalCost,
              "",
              isBold: true,
            ),

            const SizedBox(height: 20),

            // PAY BUTTON
            ElevatedButton(
              onPressed: () {
                if (slotController.selectedIndex.value == -1) {
                  showSnackbar(
                      "Warning", "Please select an available date", "warning");

                  return;
                }
                final customer = customerController.customer.value;

                if (customer == null) {
                  showSnackbar("Error", "Customer data not loaded", "error");
                  return;
                }
                final payload = BookingRequestModel(
                  clinicId: widget.payment.clinicId,
                  customerId: customer.customerId,
                  serviceId: widget.payment.serviceId,
                  serviceType: widget.payment.serviceType,
                  paymentType: "ONLINE",
                  appointmentDate: slotController
                      .slots[slotController.selectedIndex.value].date,

                  // ✅ send ONLY when toggle ON
                  pointsToRedeem:
                      useCoins ? (priceCalc?.appliedPoints ?? 0) : 0,
                );

                print("Booing payload final ${payload.toJson()}");
                final totalAmt = useCoins && priceCalc != null
                    ? priceCalc!.finalAmount
                    : priceCalc?.originalFinalAmount ??
                        widget.payment.finalCost;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RazorpaySubscription(
                          amount: totalAmt,
                          onPaymentInitiated: () {},
                          context: context,
                          mobileNumber: mobile!,
                          bookingData: payload)),
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

  Widget priceRow(
    String title,
    double amount,
    String? op, {
    bool isBold = false,
    Color? amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isBold ? 17 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            "${op} ₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isBold ? 17 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: amountColor ?? Colors.black, // ✅ default
            ),
          ),
        ],
      ),
    );
  }
}
