class LoginWithEmail {
  final String id;
  final String idUser;
  final String email;
  final String hashPassword;

  LoginWithEmail({
    required this.id,
    required this.idUser,
    required this.email,
    required this.hashPassword,
  });

  factory LoginWithEmail.fromJson(Map<String, dynamic> json) {
    return LoginWithEmail(
      id: json['id'],
      idUser: json['iduser'],
      email: json['email'],
      hashPassword: json['hash_password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iduser': idUser,
      'email': email,
      'hash_password': hashPassword,
    };
  }
}
