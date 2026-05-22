import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gina/data/local/save_credential.dart';
import 'package:gina/domain/entities/address_entity.dart';
import 'package:gina/domain/entities/attacker_entity.dart';
import 'package:gina/domain/entities/cep_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';

import '../../../../data/local/delete_credential.dart';
import '../../../../data/user/update_user_datasource.dart';
import '../../../../services/cep_service/cep_service.dart';

class UpdateUserController extends ChangeNotifier {
  UpdateUserController({required this.cepService});
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
  UserEntity? user;
  bool isLoading = false;
  bool isLogoutLoading = false;
  CepEntity? cepContent;
  String? exception;
  String selectedState = 'SP';
  bool showAddress = true;
  bool showRiskInfo = true;
  String? networkProfileImage;
  Uint8List? attackerImage;
  Uint8List? profileImage;
  String? networkAttackerImage;
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

  setUser(UserEntity? newUser) {
    user = newUser;
    updateAllControllers();
    notifyListeners();
  }

  updateAllControllers() {
    nameController.text = user!.name;
    documentController.text = user!.cpf ?? "";
    phoneController.text = user!.phone;
    emailController.text = user!.email;
    postalCodeController.text = "";
    streetController.text = user!.address.street;
    complementController.text = user!.address.complement ?? "";
    numberController.text = user!.address.number;
    neighborhoodController.text = user!.address.neighborhood;
    cityController.text = user!.address.city;
    attackerNameController.text = user!.attacker?.name ?? "";
    protectionIdController.text = user!.attacker?.protectionId ?? "";
    selectedState = user!.address.state;
    if (user!.image != null) {
      networkProfileImage = user!.image!;
    }
    if (user!.attacker?.image != null) {
      networkAttackerImage = user!.attacker!.image!;
    }
    notifyListeners();
  }

  setShowAddress() {
    showAddress = !showAddress;
    notifyListeners();
  }

  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }

  setIsLogoutLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLogoutLoading = !isLogoutLoading;
    } else {
      isLogoutLoading = newLoading;
    }
    notifyListeners();
  }

  setShowRiskInfo() {
    showRiskInfo = !showRiskInfo;
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
        updateAddressControllers();
      },
    );
  }

  void updateAddressControllers() {
    streetController.text = cepContent!.street;
    cityController.text = cepContent!.city;
    selectedState = states.firstWhere((state) => state == cepContent!.state);
    neighborhoodController.text = cepContent!.neighborhood;
    notifyListeners();
  }

  Future<bool> updateUser() async {
    setIsLoading(true);

    final datasource = UpdateUserDatasource();

    final name = nameController.text;
    final userImage = networkProfileImage;
    final newProfileImage = profileImage!;
    final cpf = documentController.text;
    final phone = phoneController.text;
    final email = emailController.text;
    final street = streetController.text;
    final number = numberController.text;
    final neighborhood = neighborhoodController.text;
    final city = cityController.text;
    final state = selectedState;

    final address = AddressEntity(
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      number: number,
    );

    final attackerName = attackerNameController.text;
    final protectionId = protectionIdController.text;
    final attackerUserImage = networkAttackerImage;
    final newAttackerUserImage = attackerImage;

    final attacker = AttackerEntity(
      name: attackerName,
      image: attackerUserImage,
      protectionId: protectionId,
      imageFile: newAttackerUserImage,
    );

    final newUser = UserEntity(
      id: user!.id,
      image: userImage,
      imageFile: newProfileImage,
      name: name,
      cpf: cpf,
      phone: phone,
      email: email,
      address: address,
      attacker: attacker,
    );

    final response = await datasource.call(newUser);

    return response.fold(
      (newException) {
        exception = newException.message;
        log("Erro ao atualizar usuário: ${newException.message}");
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

  Future<bool> logout() async {
    log("usuário criado com sucesso");
    final deleteCredential = SecureStorageDeleteCredential();
    final saveCredentialResponse = await deleteCredential();

    return saveCredentialResponse.fold(
      (newException) {
        exception = newException.message;

        return false;
      },
      (r) {
        exception = null;
        setIsLoading(false);

        return true;
      },
    );
  }
}
