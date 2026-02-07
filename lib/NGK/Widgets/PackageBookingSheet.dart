import 'package:cutomer_app/NGK/BookingAppointmnet/BookingRequestModel.dart';
import 'package:cutomer_app/NGK/ClinicManagement/clinic_slot_controller.dart';
import 'package:cutomer_app/NGK/Contoller/customer_controller.dart';
import 'package:cutomer_app/NGK/Contoller/referral_wallet_controller.dart';
import 'package:cutomer_app/NGK/Modals/PaymentModal.dart';
import 'package:cutomer_app/NGK/Modals/PriceCalculationModel.dart';
import 'package:cutomer_app/NGK/service/PriceCalculationService.dart';

import 'package:cutomer_app/Payments/AllPayments.dart';
import 'package:cutomer_app/Utils/Constant.dart';

import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PaymentType {
  FULL_PAYMENT,
  PARTIAL_PAYMENT,
}

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
      Get.isRegistered<ReferralWalletController>()
          ? Get.find<ReferralWalletController>()
          : Get.put(ReferralWalletController());

  final ClinicSlotController slotController = Get.put(ClinicSlotController());

  double get coinValue =>
      walletController.walletSummary.value?.totalCredits.toDouble() ?? 0.0;
  final ScrollController _scrollController = ScrollController();
  final customerController = Get.find<CustomerGetController>();
  String? mobile;
  PriceCalculationModel? priceCalc;
  bool priceLoading = false;
  bool showBillDetails = false;

// Value of coins
  @override
  void initState() {
    super.initState();
    if (widget.payment.clinicId != null) {
      slotController.fetchSlots(widget.payment.clinicId!);
    } else {
      debugPrint("❌ clinicId is null for ${widget.payment.serviceType}");
    }

// ✅ Force FULL_PAYMENT if partial is not valid
    if ((widget.payment.partialPaymentPercentage ?? 0) <= 0) {
      _paymentType = PaymentType.FULL_PAYMENT;
    }
    _loadCustomer();
    debugPrint("Wallet controller registered: "
        "${Get.isRegistered<ReferralWalletController>()}");
  }

  double get payableAmount {
    final double fullAmount =
        priceCalc?.originalFinalAmount ?? widget.payment.finalCost ?? 0;

    final double coinsReducedAmount =
        (useCoins && priceCalc != null) ? priceCalc!.finalAmount : fullAmount;

    final double partialPercent = widget.payment.partialPaymentPercentage ?? 0;

    // ✅ FULL PAYMENT → coins apply normally
    if (_paymentType == PaymentType.FULL_PAYMENT) {
      return coinsReducedAmount;
    }

    // ✅ PARTIAL PAYMENT
    // ❗ Coins same as full payment
    // ❗ Percentage applies ONLY on FULL amount
    if (_paymentType == PaymentType.PARTIAL_PAYMENT && partialPercent > 0) {
      final partialBase = fullAmount * (partialPercent / 100);

      // subtract coins ONLY once
      final payable =
          partialBase - (useCoins ? (fullAmount - coinsReducedAmount) : 0);

      return payable < 0 ? 0 : payable;
    }

    return fullAmount;
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

  PaymentType _paymentType = PaymentType.FULL_PAYMENT;

  String get paymentTypeString {
    return _paymentType == PaymentType.FULL_PAYMENT
        ? "FULL_PAYMENT"
        : "PARTIAL_PAYMENT";
  }

  @override
  Widget build(BuildContext context) {
    double platformFee = widget.payment.platformFee ?? 0;
    // double platformFee = 0;

    double total = widget.payment.finalCost ?? 0;

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
                    final date = DateTime.tryParse(slot.date);
                    if (date == null) return const SizedBox();

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

            if ((widget.payment.partialPaymentPercentage ?? 0) > 0) ...[
              const Text(
                "Payment Type",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  paymentTab(
                    title: "Full Payment",
                    value: PaymentType.FULL_PAYMENT,
                  ),
                  const SizedBox(width: 12),
                  paymentTab(
                    title:
                        "Partial Payment (${(widget.payment.partialPaymentPercentage ?? 0).toStringAsFixed(0)}%)",
                    value: PaymentType.PARTIAL_PAYMENT,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            // -------------------- PRICE DETAILS --------------------
            const Text("Payment Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  showBillDetails = !showBillDetails;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    showBillDetails ? "Hide Bill Details" : "View Bill Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Icon(
                    showBillDetails
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: mainColor,
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            // if (widget.info != null)
            //   Text("Note: ${widget.info ?? ""}",
            //       style: TextStyle(fontSize: 12, color: mainColor)),

            // const SizedBox(height: 12),

            // priceRow(
            //   "Original Price",
            //   widget.payment.price,
            //   "",
            // ),

            // priceRow("Consultation", widget.payment.consultationFee, ""),
            // priceRow("GST (${widget.payment.gst.toStringAsFixed(0)}%)",
            //     widget.payment.gstAmount, ""),
            // if (widget.payment.taxAmount != 0)
            //   priceRow(
            //       "Tax (${widget.payment.taxPercentage.toStringAsFixed(0)}%)",
            //       widget.payment.taxAmount,
            //       ""),

            // if (widget.payment.totalDiscountPercentage != 0)
            //   priceRow(
            //       "Discount (${widget.payment.totalDiscountPercentage.toStringAsFixed(0)}%)",
            //       widget.payment.totalDiscountAmount,
            //       "-"),

            // priceRow(
            //     // "Platform Fee (${widget.payment.platformFeePercentage?.toStringAsFixed(0)}%) ",
            //     "Platform Fee ",
            //     platformFee,
            //     ""),

            // if (useCoins && priceCalc != null && priceCalc!.appliedPoints > 0)
            //   priceRow(
            //     "Coins Applied",
            //     -priceCalc!.appliedPoints.toDouble(),
            //     "",
            //     amountColor: Colors.red,
            //   ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: showBillDetails
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  if (widget.info != null)
                    Text(
                      "Note: ${widget.info ?? ""}",
                      style: TextStyle(fontSize: 12, color: mainColor),
                    ),
                  const SizedBox(height: 8),
                  priceRow("Original Price", widget.payment.price ?? 0, ""),
                  priceRow(
                    "Consultation",
                    widget.payment.consultationFee ?? 0,
                    "",
                  ),
                  priceRow(
                    "GST (${(widget.payment.gst ?? 0).toStringAsFixed(0)}%)",
                    widget.payment.gstAmount,
                    "",
                  ),
                  if ((widget.payment.taxAmount ?? 0) > 0)
                    priceRow(
                      "Tax (${(widget.payment.taxPercentage ?? 0).toStringAsFixed(0)}%)",
                      widget.payment.taxAmount ?? 0,
                      "",
                    ),
                  if ((widget.payment.totalDiscountPercentage ?? 0) != 0)
                    priceRow(
                      "Discount (${widget.payment.totalDiscountPercentage.toStringAsFixed(0)}%)",
                      widget.payment.totalDiscountAmount,
                      "-",
                    ),
                  priceRow("Platform Fee", widget.payment.platformFee ?? 0, ""),
                  if (useCoins &&
                      priceCalc != null &&
                      priceCalc!.appliedPoints > 0)
                    priceRow(
                      "Coins Applied",
                      -priceCalc!.appliedPoints.toDouble(),
                      "",
                      amountColor: Colors.red,
                    ),
                  const Divider(thickness: 1.2),
                ],
              ),
              secondChild: const SizedBox.shrink(),
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

                      final customer = customerController.customer.value;
                      if (customer == null) {
                        showSnackbar(
                            "Error", "Customer data not loaded yet", "error");
                        setState(() {
                          useCoins = false;
                          priceLoading = false;
                        });
                        return;
                      }

                      final payload = {
                        "customerId": customer.customerId,
                        "clinicId": widget.payment.clinicId,
                        "serviceId": widget.payment.serviceId,
                        "serviceType": widget.payment.serviceType,
                        if (v) "pointsToRedeem": coinValue.toInt(),
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
              payableAmount,
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

                if (mobile == null || mobile!.isEmpty) {
                  showSnackbar("Error", "Mobile number not available", "error");
                  return;
                }

                if (slotController.selectedIndex.value >=
                    slotController.slots.length) {
                  showSnackbar("Error", "Invalid slot selected", "error");
                  return;
                }

                final payload = BookingRequestModel(
                  clinicId: widget.payment.clinicId,
                  customerId: customer.customerId,
                  serviceId: widget.payment.serviceId,
                  serviceType: widget.payment.serviceType,
                  paymentType: _paymentType == PaymentType.FULL_PAYMENT
                      ? "FULL_PAYMENT"
                      : "PARTIAL_PAYMENT",
                  appointmentDate: slotController
                      .slots[slotController.selectedIndex.value].date,
                  pointsToRedeem:
                      useCoins ? (priceCalc?.appliedPoints ?? 0) : 0,
                  paymentMode: "ONLINE",
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RazorpaySubscription(
                      amount: payableAmount,
                      onPaymentInitiated: () {},
                      context: context,
                      mobileNumber: mobile!,
                      bookingData: payload,
                    ),
                  ),
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

  Widget paymentTab({
    required String title,
    required PaymentType value,
  }) {
    final isSelected = _paymentType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            "${op} ₹${amount.toStringAsFixed(0)}",
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
