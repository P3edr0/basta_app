import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gina/domain/entities/guardian_order_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/presenter/guardian/add_guardian/store/add_guardian_controller.dart';
import 'package:gina/presenter/guardian/my_guardians/store/my_guardian_controller.dart';

import '../../../data/guardian/fetch_all_guardians_datasource.dart';
import '../../../data/guardian/fetch_all_guardians_orders_datasource.dart';
import '../../../data/user/update_user_datasource.dart';
import '../../../domain/entities/guardian_entity.dart';
import '../emergency_history/store/emergency_history_controller.dart';

class GuardianController extends ChangeNotifier {
  GuardianController({
    required this.addGuardianController,
    required this.myGuardianController,
    required this.emergencyHistoryController,
  });
  EmergencyHistoryController emergencyHistoryController;
  AddGuardianController addGuardianController;
  MyGuardianController myGuardianController;
  List<GuardianEntity> allGuardians = [];
  List<GuardianEntity> guardiansWithoutUser = [];
  List<GuardianOrderEntity> allOrders = [];
  String? exception;
  UserEntity? user;
  bool emergencyActivated = false;

  void setEmergencyActivated(bool value) {
    emergencyActivated = value;
    notifyListeners();
  }

  bool get hasError => exception != null;
  Future<void> startPage() async {
    myGuardianController.setIsLoading(true);
    final calls = [fetchAllGuardians(), fetchAllOrders()];
    await Future.wait(calls);
    if (!hasError) {
      addGuardianController.setGuardians(guardiansWithoutUser);
      addGuardianController.setOrders(allOrders);
      addGuardianController.setUser(user!);
      emergencyHistoryController.setGuardians(allGuardians);

      myGuardianController.setGuardians(guardiansWithoutUser);
      myGuardianController.setIsLoading(false);
    } else {
      myGuardianController.setException(exception!);
      myGuardianController.setIsLoading(false);
    }
  }

  Future<void> fetchAllGuardians([UserEntity? newUser]) async {
    final fetchAllGuardians = FetchAllGuardiansDatasource();
    final handledUser = user ?? newUser;
    final guardiansResponse = await fetchAllGuardians(userId: handledUser!.id!);

    return guardiansResponse.fold(
      (newException) {
        exception = newException.message;
      },
      (newGuardians) {
        allGuardians = newGuardians;
        guardiansWithoutUser =
            newGuardians
                .where((guardian) => guardian.id != handledUser.id)
                .toList();
      },
    );
  }

  Future<void> fetchAllOrders([UserEntity? newUser]) async {
    final fetchOrders = FetchAllGuardiansOrdersDatasource();
    final handledUser = user ?? newUser;
    final ordersResponse = await fetchOrders(userId: handledUser!.id!);

    return ordersResponse.fold(
      (newException) {
        exception = newException.message;
      },
      (newOrders) {
        allOrders = [...newOrders];
      },
    );
  }

  Future<UserEntity> refreshNewGuardian(UserEntity newUser) async {
    await fetchAllGuardians(newUser);
    final myGuardians =
        allGuardians.where((guardian) => guardian.status!.isAccept).toList();
    final hasChanges = myGuardians.length != (newUser.myGuardians ?? []).length;

    final updateUser = UpdateUserDatasource();

    if (hasChanges) {
      final guardiansId = myGuardians.map((guardian) => guardian.id!).toList();

      newUser = newUser.copyWith(myGuardians: guardiansId);
      final userResponse = await updateUser(newUser);
      userResponse.fold(
        (newException) {
          log("Falha ao atualizar guardiões do usuário");

          return;
        },
        (success) {
          exception = null;
          log("Guardiões do usuário atualizado com sucesso");
        },
      );
    }
    return newUser;
  }

  setUserId(UserEntity newUser) {
    user = newUser;
    notifyListeners();
  }
}
