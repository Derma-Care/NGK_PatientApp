class ProcedureModel {
  final String procedureName;
  final int noOfSittings;

  ProcedureModel({
    required this.procedureName,
    required this.noOfSittings,
  });
}

class PackageModel {
  final int packageId;
  final String packageName;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String clinicRating;
  final int price; // total price of package
  final int discountPercentage; // discount on whole package
  final int finalPrice; // total after discount
  final String distance;

  final List<ProcedureModel> procedures;

  PackageModel({
    required this.packageId,
    required this.packageName,
    required this.clinicId,
    required this.clinicName,
    required this.price,
    required this.discountPercentage,
    required this.finalPrice,
    required this.procedures,
    required this.clinicAddress,
    required this.clinicRating,
    required this.distance,
  });
}
