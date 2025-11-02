class ClientCreateDTO {
  final String name;
  final String nif;
  final String email;
  final String phone;
  final String address;

  const ClientCreateDTO({
    required this.name,
    required this.nif,
    required this.email,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "nif": nif,
        "email": email,
        "phone": phone,
        "address": address,
        "type": "CLIENTE",
      };
}
