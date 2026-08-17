class UserModel {
  final String id;
  final String nama;
  final String username;
  final String nomorTelepon;
  final String kendaraan;

  const UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.nomorTelepon,
    required this.kendaraan,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        nama: json['nama'] as String,
        username: json['username'] as String,
        nomorTelepon: json['nomor_telepon'] as String,
        kendaraan: json['kendaraan'] as String,
      );
}