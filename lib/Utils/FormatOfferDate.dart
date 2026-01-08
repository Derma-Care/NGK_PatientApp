String formatOfferDate(String? offerDate) {
  if (offerDate == null || offerDate.isEmpty) return "";

  // ✅ Parse String → DateTime
  DateTime parsedDate;
  try {
    parsedDate = DateTime.parse(offerDate);
  } catch (e) {
    return "";
  }

  // ✅ Today (no time)
  final DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // ✅ Valid date (no time)
  final DateTime validDate = DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
  );

  final int remainingDays = validDate.difference(today).inDays;

  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  final String formattedDate =
      "${validDate.day} ${months[validDate.month - 1]} ${validDate.year}";

  if (remainingDays < 0) {
    return "$formattedDate";
  }

  if (remainingDays == 0) {
    return "Ends today";
  }

  if (remainingDays == 1) {
    return "Ends Tomorrow";
  }

  return "$remainingDays days left";

  // if (remainingDays < 0) {
  //   return "$formattedDate \n (Expired)";
  // }

  // if (remainingDays == 0) {
  //   return "$formattedDate \n(Today)";
  // }

  // if (remainingDays == 1) {
  //   return "$formattedDate \n(Ends Tomorrow)";
  // }

  // return "$remainingDays days left";
}
