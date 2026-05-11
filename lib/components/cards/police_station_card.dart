import 'package:flutter/material.dart';
import 'package:gina/domain/entities/police_station_entity.dart';
import 'package:provider/provider.dart';

import '../../responsiveness/gi_font_style.dart';
import '../../responsiveness/responsive.dart';
import '../../services/url_launcher_service.dart/url_launcher_service.dart';
import '../../theme/colors.dart';
import '../../theme/icons.dart';
import '../buttons/rounded_button.dart';

class PoliceCard extends StatelessWidget {
  const PoliceCard({
    super.key,
    required this.policeStation,
    required this.onTap,
  });
  final PoliceStationEntity policeStation;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: Responsive.getSize(16),
        horizontal: Responsive.getSize(12),
      ),
      padding: EdgeInsets.all(Responsive.getSize(16)),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            offset: const Offset(2, -2),
            blurRadius: 6,
            spreadRadius: 2,
            color: grey.withValues(alpha: 0.3),
          ),
          BoxShadow(
            offset: const Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 2,
            color: grey.withValues(alpha: 0.3),
          ),
        ],
      ),
      // O IntrinsicHeight é a chave para o spaceBetween da coluna da direita funcionar
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone Lateral Esquerdo
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.2),
              ),
              padding: EdgeInsets.all(Responsive.getSize(4)),
              child: const Icon(
                Icons.shield_moon_outlined,
                color: primaryColor,
              ),
            ),
            SizedBox(width: Responsive.getSize(10)),

            // Conteúdo Central (Expandido para ocupar o espaço e permitir quebra de linha)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policeStation.name,
                    style: BasFontStyle.bodyLargeBoldSec.copyWith(
                      color: darkGrey,
                    ),
                  ),
                  SizedBox(height: Responsive.getSize(5)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: Responsive.getSize(2)),
                        child: Icon(
                          BasIcons.pin,
                          color: grey,
                          size: Responsive.getSize(16),
                        ),
                      ),
                      SizedBox(width: Responsive.getSize(4)),
                      Expanded(
                        child: Text(
                          policeStation.address,
                          style: BasFontStyle.body.copyWith(color: grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.getSize(12)),
                  DashRoundedButton(
                    height: Responsive.getSize(48),
                    onTap: onTap,
                    child: Text(
                      "Como Chegar",
                      style: BasFontStyle.bodyLargeBold.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.getSize(10)),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getSize(8),
                    vertical: Responsive.getSize(2),
                  ),
                  child: Text(
                    '${policeStation.distance.toStringAsFixed(1)}\nkm',
                    textAlign: TextAlign.center,
                    style: BasFontStyle.verySmallBold.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
                if (policeStation.phone != null)
                  InkWell(
                    onTap: () async {
                      final urlLauncherService =
                          context.read<IUrlLauncherService>();

                      final phone = policeStation.phone!;
                      await urlLauncherService.makePhoneCall(phone);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.2),
                      ),
                      padding: EdgeInsets.all(Responsive.getSize(4)),
                      child: const Icon(Icons.call, color: primaryColor),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
