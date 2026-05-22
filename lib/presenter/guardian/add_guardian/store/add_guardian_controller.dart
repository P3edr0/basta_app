import 'package:flutter/material.dart';
import 'package:gina/data/guardian/create_guardian_order_datasource.dart';
import 'package:gina/data/user/update_user_datasource.dart';
import 'package:gina/domain/entities/guardian_entity.dart';
import 'package:gina/domain/entities/guardian_order_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/utils/enums/guardian_filter_type.dart';
import 'package:gina/utils/enums/guardian_status.dart';

import '../../../../data/guardian/update_guardian_order_datasource.dart';

class AddGuardianController extends ChangeNotifier {
  String? exception;
  TextEditingController searchController = TextEditingController();
  List<GuardianEntity> allGuardians = [];
  List<GuardianEntity> filteredGuardians = [];
  List<GuardianOrderEntity> orders = [];

  GuardianFilterType guardianFilterType = GuardianFilterType.addAngel;
  bool isLoading = false;
  UserEntity? user;
  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }

  setUser(UserEntity newUser) {
    user = newUser;
    notifyListeners();
  }

  startPage() {
    guardianFilterType = GuardianFilterType.addAngel;
    searchController.clear();
    searchFilter();
    notifyListeners();
  }

  setOrders(List<GuardianOrderEntity> newOrders) {
    orders = newOrders;
    notifyListeners();
  }

  setGuardians(List<GuardianEntity> newGuardians) {
    allGuardians = newGuardians;
    filteredGuardians = [];
    notifyListeners();
  }

  setGuardianFilterType(GuardianFilterType newFilter) {
    guardianFilterType = newFilter;
    if (guardianFilterType.isAddAngel) {
      searchFilter();
    } else {
      filteredGuardians =
          allGuardians
              .where(
                (guardian) =>
                    guardian.status!.isWaiting ||
                    guardian.status!.isRefused ||
                    guardian.status!.isInvited,
              )
              .toList();
    }

    notifyListeners();
  }

  void searchFilter([String? content]) {
    final contentRef = content ?? searchController.text;
    final handledContent = contentRef.toLowerCase();
    if (handledContent.isEmpty) {
      filteredGuardians = [];
      notifyListeners();
      return;
    }
    final handledAllList =
        allGuardians.where((guardian) => guardian.status!.isNone).toList();
    final newListItems =
        handledAllList
            .where(
              (guardian) =>
                  guardian.name.toLowerCase().contains(handledContent) ||
                  guardian.addressResume!.toLowerCase().contains(
                    handledContent,
                  ),
            )
            .toList();
    filteredGuardians = [...newListItems];
    notifyListeners();
  }

  Future<void> addGuardian({required String receiverId}) async {
    final createGuardianOrder = CreateGuardianOrderDatasource();

    final order = GuardianOrderEntity(
      applicantId: user!.id!,
      receiverId: receiverId,
      sendAt: DateTime.now(),
    );
    final guardiansResponse = await createGuardianOrder(order);

    return guardiansResponse.fold(
      (newException) {
        exception = newException.message;
        notifyListeners();
      },
      (success) {
        if (success) {
          final tempList = [...allGuardians];
          final changeditem = tempList.firstWhere(
            (item) => item.id == receiverId,
          );
          final allIndex = tempList.indexWhere((item) => item.id == receiverId);
          final filteredIndex = filteredGuardians.indexWhere(
            (item) => item.id == receiverId,
          );
          final newItem = changeditem.copyWith(status: GuardianStatus.waiting);

          tempList[allIndex] = newItem;
          allGuardians = [...tempList];
          filteredGuardians[filteredIndex] = newItem;
          notifyListeners();
        }
      },
    );
  }

  Future<void> updateGuardianOrder({
    required String orderId,
    required GuardianStatus newStatus,
  }) async {
    final updateGuardianOrder = UpdateGuardianOrderDatasource();
    final updateUser = UpdateUserDatasource();

    final order = orders.firstWhere((order) => order.id == orderId);
    final newOrder = order.copyWith(answer: newStatus.isAccept);

    if (newStatus.isAccept) {
      final newMyGuardians = [...?user!.myGuardians, order.applicantId];
      user = user!.copyWith(myGuardians: newMyGuardians);
      final userResponse = await updateUser(user!);
      userResponse.fold(
        (newException) {
          exception = newException.message;
          notifyListeners();
          return;
        },
        (success) {
          exception = null;
          notifyListeners();
        },
      );
    }
    final guardiansResponse = await updateGuardianOrder(newOrder);

    return guardiansResponse.fold(
      (newException) {
        exception = newException.message;
        notifyListeners();
      },
      (success) {
        if (success) {
          final tempList = [...allGuardians];
          final orderOwnerId = order.applicantId;

          final changeditem = tempList.firstWhere(
            (item) => item.id == orderOwnerId,
          );
          final allIndex = tempList.indexWhere(
            (item) => item.id == orderOwnerId,
          );
          final filteredIndex = filteredGuardians.indexWhere(
            (item) => item.id == orderOwnerId,
          );
          final newItem = changeditem.copyWith(status: newStatus);

          tempList[allIndex] = newItem;
          allGuardians = [...tempList];
          filteredGuardians[filteredIndex] = newItem;
          notifyListeners();
        }
      },
    );
  }
}
