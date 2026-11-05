import 'package:flutter/material.dart';

import '../../../core/constant/app_color.dart';

/// بطاقة اختيار دور في A6: خانة اختيار + عنوان + وصف + أيقونة.
/// المحددة بحدّ برتقالي، وغير المحددة بحدّ رمادي.
class RoleOptionCard extends StatelessWidget {
  const RoleOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: AppColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? AppColor.orange : AppColor.divider,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: selected ? AppColor.orange : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selected ? null : Border.all(color: AppColor.borderStrong, width: 2),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 18, color: AppColor.ink)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, size: 30, color: AppColor.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
