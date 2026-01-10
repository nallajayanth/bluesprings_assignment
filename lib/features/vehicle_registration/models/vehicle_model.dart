class Vehicle {
  final String? id; // Changed to String as MongoDB usually uses string ObjectIds
  final String vehicleNumber;
  final String ownerName;
  final String vehicleType;
  final String flatNumber;
  final String? fastTagId;
  final String status;
  final String residentType;
  final String blockName;
  final String parkingSlot;
  final bool isBlocked;
  final String? reason;

  Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.ownerName,
    required this.vehicleType,
    required this.flatNumber,
    this.fastTagId,
    required this.status,
    required this.residentType,
    required this.blockName,
    required this.parkingSlot,
    this.isBlocked = false,
    this.reason,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? json['_id']?.toString(), // Handle both id and _id
      vehicleNumber: json['vehicleNumber'] ?? '',
      ownerName: json['ownerName'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      flatNumber: json['flatNumber'] ?? '',
      fastTagId: json['fastTagId'],
      status: json['status'] ?? 'Active',
      residentType: json['residentType'] ?? 'Owner',
      blockName: json['blockName'] ?? '',
      parkingSlot: json['parkingSlot'] ?? '',
      isBlocked: json['isBlocked'] ?? false,
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicleNumber': vehicleNumber,
      'ownerName': ownerName,
      'vehicleType': vehicleType,
      'flatNumber': flatNumber,
      'fastTagId': fastTagId,
      'status': status,
      'residentType': residentType,
      'blockName': blockName,
      'parkingSlot': parkingSlot,
      'isBlocked': isBlocked,
      'reason': reason,
    };
  }
}
