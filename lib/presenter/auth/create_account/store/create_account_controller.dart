import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gina/data/local/save_credential.dart';
import 'package:gina/domain/entities/address_entity.dart';
import 'package:gina/domain/entities/attacker_entity.dart';
import 'package:gina/domain/entities/cep_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';

import '../../../../data/user/create_user_datasource.dart';
import '../../../../services/cep_service/cep_service.dart';

class CreateAccountController extends ChangeNotifier {
  CreateAccountController({required this.cepService});
  final ICepService cepService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController complementController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController attackerNameController = TextEditingController();
  final TextEditingController protectionIdController = TextEditingController();
  bool isLoading = false;
  bool termsAccepted = false;
  CepEntity? cepContent;
  String? exception;
  String selectedState = 'SP';

  Uint8List? profileImage;
  Uint8List? attackerImage;
  final states = [
    "AC",
    "AL",
    "AP",
    "AM",
    "BA",
    "CE",
    "DF",
    "ES",
    "GO",
    "MA",
    "MT",
    "MS",
    "MG",
    "PA",
    "PB",
    "PR",
    "PE",
    "PI",
    "RJ",
    "RN",
    "RS",
    "RO",
    "RR",
    "SC",
    "SP",
    "SE",
    "TO",
  ];

  /////////////////////////////////// GETS
  bool get hasError => exception != null;

  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }

  setTermsAccepted() {
    termsAccepted = !termsAccepted;
    notifyListeners();
  }

  setProfileImage(Uint8List? newImage) {
    profileImage = newImage;
    notifyListeners();
  }

  setAttackerImage(Uint8List? newImage) {
    attackerImage = newImage;
    notifyListeners();
  }

  setSelectedState(String newState) {
    selectedState = newState;
    notifyListeners();
  }

  Future<void> getCep(String newCep) async {
    final response = await cepService.getCep(newCep);
    response.fold(
      (newException) {
        log('Erro CEP: ${newException.message}');
      },
      (newCepContent) {
        cepContent = newCepContent;
        updateControllers();
      },
    );
  }

  void updateControllers() {
    streetController.text = cepContent!.street;
    cityController.text = cepContent!.city;
    selectedState = states.firstWhere((state) => state == cepContent!.state);
    neighborhoodController.text = cepContent!.neighborhood;
    notifyListeners();
  }

  void clearFormData() {
    exception = null;
    selectedState = 'SP';

    profileImage = null;
    attackerImage = null;
    nameController.clear();
    documentController.clear();
    phoneController.clear();
    emailController.clear();
    postalCodeController.clear();
    streetController.clear();
    complementController.clear();
    numberController.clear();
    neighborhoodController.clear();
    cityController.clear();
    attackerNameController.clear();
    protectionIdController.clear();
    notifyListeners();
  }

  Future<bool> createUser(String notifyToken) async {
    setIsLoading(true);

    final datasource = CreateUserDatasource();

    final name = nameController.text;
    final userImage = profileImage!;
    final cpf = documentController.text;
    final phone = phoneController.text;
    final email = emailController.text;
    final street = streetController.text;
    final number = numberController.text;
    final neighborhood = neighborhoodController.text;
    final complement = complementController.text;
    final city = cityController.text;
    final state = selectedState;

    final address = AddressEntity(
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      number: number,
      complement: complement,
      postalCode: postalCodeController.text,
    );

    final attackerName = attackerNameController.text;
    final protectionId = protectionIdController.text;
    final attackerUserImage = attackerImage;

    AttackerEntity? attacker = AttackerEntity(
      name: attackerName.isEmpty ? null : attackerName,
      imageFile: attackerUserImage,
      protectionId: protectionId.isEmpty ? null : protectionId,
    );

    if (attackerName.isEmpty &&
        protectionId.isEmpty &&
        attackerUserImage == null) {
      attacker = null;
    }
    final newUser = UserEntity(
      imageFile: userImage,
      name: name,
      cpf: cpf,
      phone: phone,
      email: email,
      address: address,
      attacker: attacker,
      notificationToken: notifyToken,
    );

    final response = await datasource.createUser(newUser);

    return response.fold(
      (newException) {
        exception = newException.message;

        setIsLoading(false);

        return false;
      },
      (success) async {
        log("usuário criado com sucesso");
        final saveCredential = SecureStorageCreateCredential();
        final saveCredentialResponse = await saveCredential(email);

        return saveCredentialResponse.fold(
          (newException) {
            exception = newException.message;

            setIsLoading(false);

            return false;
          },
          (r) {
            exception = null;
            setIsLoading(false);

            return true;
          },
        );
      },
    );
  }
}
