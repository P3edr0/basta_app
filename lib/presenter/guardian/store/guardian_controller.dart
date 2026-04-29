import 'package:flutter/material.dart';
import 'package:gina/domain/entities/guardian_order_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/presenter/guardian/add_guardian/store/add_guardian_controller.dart';
import 'package:gina/presenter/guardian/my_guardians/store/my_guardian_controller.dart';

import '../../../data/guardian/fetch_all_guardians_datasource.dart';
import '../../../data/guardian/fetch_all_guardians_orders_datasource.dart';
import '../../../domain/entities/guardian_entity.dart';

class GuardianController extends ChangeNotifier {
  GuardianController({
    required this.addGuardianController,
    required this.myGuardianController,
  });
  AddGuardianController addGuardianController;
  MyGuardianController myGuardianController;
  List<GuardianEntity> allGuardians = [];
  List<GuardianOrderEntity> allOrders = [];
  String? exception;
  UserEntity? user;

  bool get hasError => exception != null;
  Future<void> startPage() async {
    myGuardianController.setIsLoading(true);
    final calls = [fetchAllGuardians(), fetchAllOrders()];
    await Future.wait(calls);
    if (!hasError) {
      addGuardianController.setGuardians(allGuardians);
      addGuardianController.setOrders(allOrders);
      addGuardianController.setUser(user!);
      myGuardianController.setGuardians(allGuardians);
      myGuardianController.setIsLoading(false);
    } else {
      myGuardianController.setException(exception!);
      myGuardianController.setIsLoading(false);
    }
  }

  Future<void> fetchAllGuardians() async {
    final fetchAllGuardians = FetchAllGuardiansDatasource();

    final guardiansResponse = await fetchAllGuardians(userId: user!.id!);

    return guardiansResponse.fold(
      (newException) {
        exception = newException.message;
      },
      (newGuardians) {
        allGuardians =
            newGuardians.where((guardian) => guardian.id != user!.id).toList();
      },
    );
  }

  Future<void> fetchAllOrders() async {
    final fetchOrders = FetchAllGuardiansOrdersDatasource();

    final ordersResponse = await fetchOrders(userId: user!.id!);

    return ordersResponse.fold(
      (newException) {
        exception = newException.message;
      },
      (newOrders) {
        allOrders = [...newOrders];
      },
    );
  }

  setUserId(UserEntity newUser) {
    user = newUser;
    notifyListeners();
  }
}
