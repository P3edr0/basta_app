import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gina/domain/entities/emergency_history_entity.dart';
import 'package:gina/domain/entities/guardian_entity.dart';

import '../../../../data/emergency/fetch_emergency_history_datasource.dart';
import '../../../../data/guardian/delete_guardian_order_datasource.dart';
import '../../../../utils/enums/angel_filter_type.dart';

class EmergencyHistoryController extends ChangeNotifier {
  bool isLoading = false;
  String? exception;
  List<GuardianEntity> allGuardians = [];
  List<GuardianEntity> myGuardians = [];
  List<EmergencyHistoryEntity> historical = [];

  AngelFilterType angelFilterType = AngelFilterType.myGuardians;
  setException(String newException) {
    exception = newException;
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

  setGuardians(List<GuardianEntity> newGuardians) {
    allGuardians = newGuardians;
    myGuardians =
        allGuardians.where((guardian) => guardian.status!.isAccept).toList();
    notifyListeners();
  }

  setAngelFilterType(AngelFilterType newType) {
    angelFilterType = newType;
    notifyListeners();
  }

  Future<void> deleteGuardianOrder({required String orderId}) async {
    final deleteGuardianOrder = DeleteGuardianOrderDatasource();

    final guardiansResponse = await deleteGuardianOrder(orderId);

    return guardiansResponse.fold(
      (newException) {
        exception = newException.message;
        notifyListeners();
      },
      (success) {
        if (success) {
          allGuardians.removeWhere((guardian) => guardian.orderId == orderId);
          final tempList =
              allGuardians
                  .where((guardian) => guardian.status!.isAccept)
                  .toList();

          myGuardians = [...tempList];
          notifyListeners();
        }
      },
    );
  }

  Future<void> fetchEmergencyHistory({
    required String userId,
    required List<String> guardians,
  }) async {
    final fetchEmergencyHistory = FetchEmergencyHistoryDatasource();

    final response = await fetchEmergencyHistory(
      userId: userId,
      guardians: guardians,
    );

    return response.fold(
      (newException) {
        exception = newException.message;
        notifyListeners();
      },
      (newEmergencies) {
        historical = newEmergencies;

        historical =
            newEmergencies.map((emergency) {
              final matchedGuardian = allGuardians.firstWhere(
                (guardian) => guardian.id == emergency.victimId,
                orElse: () => GuardianEntity(id: null, name: "Desconecido"),
              );
              return emergency.copyWith(guardian: matchedGuardian);
            }).toList();
        historical.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      },
    );
  }
}
