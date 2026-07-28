import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gina/domain/entities/guardian_entity.dart';

import '../../../../data/guardian/delete_guardian_order_datasource.dart';
import '../../../../utils/enums/angel_filter_type.dart';

class MyGuardianController extends ChangeNotifier {
  bool isLoading = true;
  String? exception;
  List<GuardianEntity> allGuardians = [];
  List<GuardianEntity> myGuardians = [];
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
}
