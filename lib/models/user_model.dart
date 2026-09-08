class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? username;
  final String? pin;
  final String? profilePicture;
  final String? ktpPicture;
  final bool? isVerified;
  final String? cardNumber;
  final int? balance;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.username,
    this.pin,
    this.profilePicture,
    this.ktpPicture,
    this.isVerified,
    this.cardNumber,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic>? walletJson}) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      pin: json['pin'],
      profilePicture: json['profile_picture'],
      ktpPicture: json['ktp_picture'],
      isVerified: json['is_verified'] ?? false,
      cardNumber: (walletJson?['card_number'] ?? json['card_number'])?.toString(),
      balance: walletJson?['balance'] is int
          ? walletJson!['balance']
          : (walletJson?['balance'] as num?)?.toInt() ?? 0,
    );
  }

  UserModel copyWith({
    String? name,
    String? username,
    String? pin,
    String? profilePicture,
    String? ktpPicture,
    bool? isVerified,
    String? cardNumber,
    int? balance,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      username: username ?? this.username,
      pin: pin ?? this.pin,
      profilePicture: profilePicture ?? this.profilePicture,
      ktpPicture: ktpPicture ?? this.ktpPicture,
      isVerified: isVerified ?? this.isVerified,
      cardNumber: cardNumber ?? this.cardNumber,
      balance: balance ?? this.balance,
    );
  }
}
