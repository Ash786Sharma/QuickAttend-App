class Attendance {
  final String employeeId;
  final String date;
  final String status;
  final String location;
  final Map<String, dynamic>? leaveData;
  final Map<String, dynamic>? onDutyData;

  Attendance({required this.employeeId, required this.date, required this.status, required this.location, this.leaveData, this.onDutyData});

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        employeeId: json['employeeId'],
        date: json['date'],
        status: json['status'],
        location: json['location'],
        leaveData: json['leaveData'],
        onDutyData: json['onDutyData'],
      );
}
