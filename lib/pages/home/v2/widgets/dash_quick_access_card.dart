import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';

/// Figma feature card: tinted icon box + title/subtitle + chevron.
class DashQuickAccessCard extends StatelessWidget {
  const DashQuickAccessCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final DashQuickAccessItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DashV2Colors.card,
      elevation: 0,
      borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: DashV2Colors.card,
            borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
            boxShadow: DashV2Colors.cardShadow,
          ),
          padding: const EdgeInsets.fromLTRB(10, 12, 6, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DashV2Colors.tint(item.color),
                  borderRadius:
                      BorderRadius.circular(DashV2Colors.iconRadius),
                ),
                alignment: Alignment.center,
                child: item.assetIcon != null
                    ? Image.asset(
                        item.assetIcon!,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      )
                    : Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DashV2Text.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DashV2Text.cardSubtitle,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0B8C4),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
