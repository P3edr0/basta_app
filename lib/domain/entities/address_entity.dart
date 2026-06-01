import 'dart:convert';

class AddressEntity {
  final String? postalCode;
  final String street;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String number;
  final String? ibgeCode;

  AddressEntity({
    this.postalCode,
    required this.street,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.number,
    this.ibgeCode,
  });

  AddressEntity copyWith({
    String? postalCode,
    String? street,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? number,
    String? ibgeCode,
  }) {
    return AddressEntity(
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      number: number ?? this.number,
      ibgeCode: ibgeCode ?? this.ibgeCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'street': street,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'number': number,
    };
  }

  factory AddressEntity.fromMap(Map<String, dynamic> map) {
    return AddressEntity(
      postalCode: map['postalCode'],
      street: map['street'] as String,
      complement:
          map['complement'] != null ? map['complement'] as String : null,
      neighborhood: map['neighborhood'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      number: map['number'] as String,
      ibgeCode: map['ibgeCode'] != null ? map['ibgeCode'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddressEntity.fromJson(String source) =>
      AddressEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AddressEntity(postalCode: $postalCode, street: $street, complement: $complement, neighborhood: $neighborhood, city: $city, state: $state, number: $number, ibgeCode: $ibgeCode)';
  }

  @override
  bool operator ==(covariant AddressEntity other) {
    if (identical(this, other)) return true;

    return other.postalCode == postalCode &&
        other.street == street &&
        other.complement == complement &&
        other.neighborhood == neighborhood &&
        other.city == city &&
        other.state == state &&
        other.number == number &&
        other.ibgeCode == ibgeCode;
  }
}
