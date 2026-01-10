class StatData {
  final String label;
  final String value;
  final String iconPath;
  final int color; 

  StatData({required this.label, required this.value, required this.iconPath, required this.color});
}

class WeeklyData {
  final String day;
  final int entries;
  final int exits;

  WeeklyData({required this.day, required this.entries, required this.exits});

  factory WeeklyData.fromJson(Map<String, dynamic> json) {
    return WeeklyData(
      day: json['day'] ?? '',
      entries: json['entries'] ?? 0,
      exits: json['exits'] ?? 0,
    );
  }
}

class ActivityLog {
  final String time;
  final String vehicleNo;
  final bool isEntry; 

  ActivityLog({required this.time, required this.vehicleNo, required this.isEntry});

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Assuming API returns something like { "time": "...", "vehicleNumber": "...", "type": "ENTRY"/"EXIT" }
    // Adjust logic based on actual API response
    final type = json['type'] ?? 'ENTRY';
    return ActivityLog(
      time: json['timestamp'] ?? json['time'] ?? '', // Placeholder key
      vehicleNo: json['vehicleNumber'] ?? '',
      isEntry: type == 'ENTRY',
    );
  }
}

class RegisteredVehicle {
  final String vehicleNo;
  final String owner;
  final String type;
  final String flat;
  final String status;
  final String date;

  RegisteredVehicle({
    required this.vehicleNo,
    required this.owner,
    required this.type,
    required this.flat,
    required this.status,
    required this.date,
  });
  
  // Can be mapped from Vehicle model
}
