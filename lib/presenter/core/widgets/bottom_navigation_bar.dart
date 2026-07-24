import 'package:flutter/material.dart';
import 'package:gina/presenter/core/store/core_controller.dart';
import 'package:gina/theme/icons.dart';
import 'package:gina/utils/routes/app_navigator.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../components/dialogs/info_dialog.dart';
import '../../../responsiveness/gi_font_style.dart';
import '../../../responsiveness/responsive.dart';
import '../../../theme/colors.dart';
import '../../../utils/routes/route_observer.dart';
import '../../auth/store/auth_controller.dart';
import '../../auth/update_user/store/update_user_controller.dart';

class BasBottomNavigationBar extends StatelessWidget {
  BasBottomNavigationBar({super.key});
  final _navigator = AppNavigator();
  final routeObserver = RouteStackObserver.instance();

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreController>(
      builder: (context, controller, child) {
        return Container(
          height: Responsive.getSize(80),
          padding: EdgeInsets.symmetric(vertical: Responsive.getSize(8)),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(2, -2),
                blurRadius: 6,
                spreadRadius: 2,
                color: primaryColor.withValues(alpha: 0.3),
              ),
              BoxShadow(
                offset: Offset(-2, -2),
                blurRadius: 6,
                spreadRadius: 2,

                color: primaryColor.withValues(alpha: 0.3),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: secondaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavigationItem(
                title: "Psicólogo",

                icon: BasIcons.psychology,
                isSelected: routeObserver.currentPageindex == 0,
                onTap:
                    () => InfoDialog.closeAuto(
                      "Em breve...",
                      "Estamos desenvolvendo esta funcionalidade.",
                      context,
                    ),
              ),
              BottomNavigationItem(
                title: "Delegacias",

                icon: BasIcons.policy,
                isSelected: routeObserver.currentPageindex == 1,
                onTap: () {
                  if (routeObserver.currentRoute != BasRoutes.policeStation) {
                    _navigator.goto(BasRoutes.policeStation);
                  }
                },
              ),
              BottomNavigationItem(
                title: "Início",

                icon: BasIcons.home,
                isSelected: routeObserver.currentPageindex == 2,
                onTap: () {
                  if (routeObserver.currentRoute != BasRoutes.home) {
                    _navigator.goto(BasRoutes.home);
                  }
                },
              ),
              BottomNavigationItem(
                title: "Anjos",

                icon: BasIcons.angel,
                isSelected: routeObserver.currentPageindex == 3,
                onTap: () {
                  // routeObserver.changeCurrentPage(3);

                  if (routeObserver.currentRoute != BasRoutes.guardian) {
                    _navigator.goto(BasRoutes.guardian);
                  }
                },
              ),
              BottomNavigationItem(
                title: "Perfil",

                icon: BasIcons.profile,
                isSelected: routeObserver.currentPageindex == 4,
                onTap: () {
                  // routeObserver.changeCurrentPage(4);
                  final authController = context.read<AuthController>();
                  final updateUserController =
                      context.read<UpdateUserController>();
                  final user = authController.user;
                  updateUserController.setUser(user);
                  if (routeObserver.currentRoute != BasRoutes.updateUser) {
                    _navigator.goto(BasRoutes.updateUser);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });
  final String title;
  final IconData icon;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? primaryColor : transparent;
    final contentColor = isSelected ? secondaryColor : grey;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: Responsive.getSize(76),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.getSize(4),
          // horizontal: Responsive.getSize(16),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: contentColor, size: Responsive.getSize(24)),
            Text(
              title,
              style: BasFontStyle.smallBold.copyWith(color: contentColor),
            ),
          ],
        ),
      ),
    );
  }
}
