
class UnauthorizedVehicle {
  final String? id;
  final String vehicleNumber;
  final DateTime? unauthorizedDate;
  final String reason;
  final String status;

  UnauthorizedVehicle({
    this.id,
    required this.vehicleNumber,
    this.unauthorizedDate,
    required this.reason,
    required this.status,
  });

  factory UnauthorizedVehicle.fromJson(Map<String, dynamic> json) {
    return UnauthorizedVehicle(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      vehicleNumber: json['vehicleNumber'] ?? '',
      unauthorizedDate: json['unauthorizedDate'] != null 
          ? DateTime.tryParse(json['unauthorizedDate']) 
          : null,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Unable to determine',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicleNumber': vehicleNumber,
      // API expects "number" for blocking, but keeping this for general model usage
      'unauthorizedDate': unauthorizedDate?.toIso8601String(),
      'reason': reason,
      'status': status,
      // Helper for the block API
      // 'number': vehicleNumber, 
    };
  }
}
