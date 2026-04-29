import 'dart:convert';

import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gina/presenter/auth/store/auth_controller.dart';
import 'package:gina/presenter/auth/update_user/store/update_user_controller.dart';
import 'package:gina/presenter/home/home/store/home_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
import 'package:gina/theme/icons.dart';
import 'package:gina/utils/handler/name_handler.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../../responsiveness/responsive.dart';
import '../../../components/cards/home_card.dart';
import '../../../components/dialogs/quit_app_dialog.dart';
import '../../../theme/colors.dart';
import '../../../utils/assets/app_assets.dart';
import '../../../utils/routes/app_navigator.dart';
import '../../core/widgets/bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BasBottomNavigationBar(),
      backgroundColor: primaryColor,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }

          bool shouldPop = await QuitAppDialog.show(
            'Sair do BASTA?',
            "Deseja sair do BASTA?",
            context,
          );
          if (shouldPop) {
            SystemNavigator.pop();
          }
        },

        child: SafeArea(
          child: SingleChildScrollView(
            child: Consumer<HomeController>(
              builder: (context, controller, child) {
                final bool hasImage = controller.user?.image != null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getSize(24),
                        vertical: Responsive.getSize(8),
                      ),
                      color: secondaryColor,
                      child: Row(
                        children: [
                          Icon(Icons.menu, size: Responsive.getSize(30)),
                          SizedBox(width: Responsive.getSize(5)),
                          Text(
                            "BASTA",
                            style: GiFontStyle.titleBoldSec.copyWith(
                              color: primaryColor,
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              final authController =
                                  context.read<AuthController>();
                              final updateUserController =
                                  context.read<UpdateUserController>();
                              final user = authController.user;
                              updateUserController.setUser(user);
                              navigator.goto(GiRoutes.updateUser);
                            },

                            child: CircleAvatar(
                              radius: Responsive.getSize(20),
                              backgroundColor: primaryFocusColor,
                              backgroundImage:
                                  hasImage
                                      ? MemoryImage(
                                        base64Decode(controller.user!.image!),
                                      )
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getSize(80),
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          left: Responsive.getSize(24),
                          top: Responsive.getSize(16),
                        ),
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              right: Responsive.getSize(10),
                            ),
                            padding: EdgeInsets.all(Responsive.getSize(18)),
                            decoration: BoxDecoration(
                              color: secondaryColor,

                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FeatherIcons.map,
                              size: Responsive.getSize(26),
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getSize(24),
                        vertical: Responsive.getSize(16),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Responsive.getSize(16)),
                          Text(
                            "Olá, ${NameHandler.firstName(controller.user?.name ?? "Usuária")}",
                            style: GiFontStyle.h4BoldSec.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                          Text(
                            "Você está em um lugar seguro",
                            style: GiFontStyle.bodyLargeBold.copyWith(
                              color: lightGrey,
                            ),
                          ),
                          SizedBox(height: Responsive.getSize(40)),

                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () async {},
                              child: CircleAvatar(
                                backgroundColor: accentColor.withValues(
                                  alpha: 0.1,
                                ),
                                radius: Responsive.getSize(120),

                                child: CircleAvatar(
                                  radius: Responsive.getSize(100),
                                  backgroundColor: accentColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: accentColor,

                                    radius: Responsive.getSize(80),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(GiAppAssets.emergency),
                                        SizedBox(height: Responsive.getSize(8)),

                                        Text(
                                          "EMERGÊNCIA",
                                          style: GiFontStyle.titleBoldSec
                                              .copyWith(color: secondaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.getSize(40)),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GiHomeCard(
                                title: "Delegacia mais próxima",
                                content:
                                    "Veja a localização da delegacia da mulher mais próxima de você.",
                                icon: GiAppAssets.shield,
                              ),

                              SizedBox(width: Responsive.getSize(24)),

                              GiHomeCard(
                                title: "Anjo Guardião",
                                content:
                                    "Adicione pessoas de segurança que serão alertadas.",
                                icon: GiAppAssets.angel,
                                onTap: () {
                                  navigator.goto(GiRoutes.guardian);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.getSize(24)),

                          Container(
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                    Responsive.getSize(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sua localização atual',
                                        style: GiFontStyle.bodyLargeBoldSec
                                            .copyWith(color: darkGrey),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            BasIcons.pin,
                                            color: grey,
                                            size: Responsive.getSize(16),
                                          ),
                                          Text(
                                            'Av.Paulista São Paulo - SP',
                                            style: GiFontStyle.body.copyWith(
                                              color: grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  child: Image.asset(
                                    GiAppAssets.map,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: Responsive.getSize(24)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
