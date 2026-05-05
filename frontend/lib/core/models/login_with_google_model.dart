class LoginWithGoogle {
  final String id;
  final String idUser;
  final String email;

  LoginWithGoogle({
    required this.id,
    required this.idUser,
    required this.email,
  });

  factory LoginWithGoogle.fromJson(Map<String, dynamic> json) {
    return LoginWithGoogle(
      id: json['id'],
      idUser: json['iduser'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'iduser': idUser, 'email': email};
  }
}
