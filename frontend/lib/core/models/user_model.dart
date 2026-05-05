class UserModel {
  final String id;
  final String username;
  final int typeLogin;
  final String? avatarUrl;
  final double rating;
  final int totalMatches;
  final int totalWins;
  final int totalDraws;
  final int totalLosses;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.username,
    required this.typeLogin,
    required this.avatarUrl,
    required this.rating,
    required this.totalMatches,
    required this.totalWins,
    required this.totalDraws,
    required this.totalLosses,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      typeLogin: json['type_login'],
      avatarUrl: json['avatar_url'],
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      totalMatches: json['total_matches'] ?? 0,
      totalWins: json['total_wins'] ?? 0,
      totalDraws: json['total_draws'] ?? 0,
      totalLosses: json['total_losses'] ?? 0,
      isOnline: json['online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'type_login': typeLogin,
      'avatar_url': avatarUrl,
      'rating': rating,
      'total_matches': totalMatches,
      'total_wins': totalWins,
      'total_draws': totalDraws,
      'total_losses': totalLosses,
      'isOnline': isOnline,
    };
  }
}
