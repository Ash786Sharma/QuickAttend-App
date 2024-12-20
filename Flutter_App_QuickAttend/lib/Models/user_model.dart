class User {
  final String id;
  final String name;
  final String employeeId;
  final String role;
  final String timezone;

  User({required this.id, required this.name, required this.employeeId, required this.role, required this.timezone});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'],
        name: json['name'],
        employeeId: json['employeeId'],
        role: json['role'],
        timezone: json['timezone'],
      );
}
