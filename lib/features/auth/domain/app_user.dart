/// Authenticated user, as returned by the backend after login/register/OTP/Google.
class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String role;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'staff',
    );
  }
}
