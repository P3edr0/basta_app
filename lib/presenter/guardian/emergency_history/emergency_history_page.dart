import 'package:flutter/material.dart';
import 'package:gina/presenter/core/widgets/bottom_navigation_bar.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/app_bar/app_bar.dart';
import '../../../components/cards/emergency_history_card.dart';
import '../../../components/loadings/loading.dart';
import '../../../components/shines/empty_list_animation.dart';
import '../../../theme/colors.dart';
import '../../../utils/formatters/date_formatter.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../../utils/routes/app_routes.dart';
import '../../auth/store/auth_controller.dart';
import '../emergency_details/store/emergency_details_controller.dart';
import 'store/emergency_history_controller.dart';

class EmergencyHistoryPage extends StatefulWidget {
  const EmergencyHistoryPage({super.key});

  @override
  State<EmergencyHistoryPage> createState() => EmergencyHistoryPageState();
}

class EmergencyHistoryPageState extends State<EmergencyHistoryPage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = context.read<AuthController>();
      final controller = context.read<EmergencyHistoryController>();
      final user = authController.user!;
      await controller.fetchEmergencyHistory(
        userId: user.id!,
        guardians: user.myGuardians!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      bottomNavigationBar: BasBottomNavigationBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<EmergencyHistoryController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return DashPageLoading();
              }
              final isEmptyContent = controller.myGuardians.isEmpty;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getSize(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GiAppBar.secondary(title: "Histórico de Emergências"),

                    SizedBox(height: Responsive.getSize(16)),

                    Text(
                      "Círculo de Proteção",
                      style: BasFontStyle.h4BoldSec.copyWith(color: darkGrey),
                    ),
                    Text(
                      "Estas são as pessoas que receberão um alerta em caso de emergência",
                      style: BasFontStyle.bodyLargeBold.copyWith(color: grey),
                    ),
                    SizedBox(height: Responsive.getSize(30)),

                    if (isEmptyContent)
                      BasEmptyAnimation(
                        content: "Sua lista de anjos guardiões está vazia",
                      ),

                    ...controller.historical.map(
                      (emergency) => EmergencyHistoryCard(
                        title: emergency.guardian!.name,
                        content: BasDateFormat.notificationFormat(
                          emergency.date,
                        ),
                        image: emergency.guardian!.image,
                        onTap: () {
                          final emergencyDetails =
                              context.read<EmergencyDetailsController>();
                          emergencyDetails.startPage(emergency);
                          navigator.goto(GiRoutes.emergencyDetails);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
