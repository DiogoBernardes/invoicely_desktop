class ClientUpdateDTO {
  final String? name;
  final String? nif;
  final String? email;
  final String? phone;
  final String? address;

  const ClientUpdateDTO(
      {this.name, this.nif, this.email, this.phone, this.address});

  Map<String, dynamic> toJson() => {
        if (name != null) "name": name,
        if (nif != null) "nif": nif,
        if (email != null) "email": email,
        if (phone != null) "phone": phone,
        if (address != null) "address": address,
      };
}
