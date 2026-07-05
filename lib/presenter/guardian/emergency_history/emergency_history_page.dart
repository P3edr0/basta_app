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
      controller.setUser(user);
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
              final isEmptyContent = controller.historical.isEmpty;
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
                      "Emergências do meu círculo",
                      style: BasFontStyle.h4BoldSec.copyWith(color: darkGrey),
                    ),
                    Text(
                      "Estas são todas as emergências suas e dos seus anjos",
                      style: BasFontStyle.bodyLargeBold.copyWith(color: grey),
                    ),
                    SizedBox(height: Responsive.getSize(30)),

                    if (isEmptyContent)
                      BasEmptyAnimation(
                        content: "Sua lista de emergências está vazia",
                      ),

                    ...controller.historical.map((emergency) {
                      final isUser =
                          emergency.guardian?.id == controller.user?.id;

                      return EmergencyHistoryCard(
                        title: isUser ? 'Você' : emergency.guardian!.name,
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
                      );
                    }),
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
