class CepEntity {
  final String postalCode;
  final String street;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String? ibgeCode;
  final String? giaCode;
  final String? areaCode;
  final String? siafiCode;

  CepEntity({
    required this.postalCode,
    required this.street,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.ibgeCode,
    this.giaCode,
    this.areaCode,
    this.siafiCode,
  });

  /// Factory to create from ViaCEP JSON
  factory CepEntity.fromJson(Map<String, dynamic> json) {
    return CepEntity(
      postalCode: json['cep'] ?? '',
      street: json['logradouro'] ?? '',
      complement: json['complemento'] ?? '',
      neighborhood: json['bairro'] ?? '',
      city: json['localidade'] ?? '',
      state: json['uf'] ?? '',
      ibgeCode: json['ibge'],
      giaCode: json['gia'],
      areaCode: json['ddd'],
      siafiCode: json['siafi'],
    );
  }

  String get fullAddress {
    final parts = [
      street,
      if (complement.isNotEmpty) complement,
      neighborhood,
      city,
      state,
    ].where((p) => p.isNotEmpty);

    return parts.join(', ');
  }

  /// Validates if the returned CEP is valid
  bool get isValid {
    return postalCode.isNotEmpty &&
        street.isNotEmpty &&
        neighborhood.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty;
  }

  @override
  String toString() {
    return 'CepModel(postalCode: $postalCode, street: $street, neighborhood: $neighborhood, city: $city, state: $state)';
  }
}
