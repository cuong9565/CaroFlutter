class UserModel {
  final String id;
  final String username;
  final int typeLogin;
  final String? avartarUrl;
  final double rating;
  final int totalMatches;
  final int totalWins;
  final int totalDraws;
  final int totalLosses;

  UserModel({
    required this.id,
    required this.username,
    required this.typeLogin,
    required this.avartarUrl,
    required this.rating,
    required this.totalMatches,
    required this.totalWins,
    required this.totalDraws,
    required this.totalLosses,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      typeLogin: json['type_login'],
      avartarUrl: json['avartar_url'],
      rating: json['rating'],
      totalMatches: json['total_matches'],
      totalWins: json['total_wins'],
      totalDraws: json['total_draws'],
      totalLosses: json['total_losses'],
    );
  }
}
