import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/admin/admin_section_controllers.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/admin_models.dart';
import '../../widget/admin/admin_parts.dart';
import '../../widget/admin/admin_table.dart';

/// E7 — تصنيفات المنتجات (مع تصنيف أب)، E8 — تصنيفات الأنشطة التجارية (بلا أب).
/// نموذج إضافة/تعديل في الأعلى، وجدول تحته. لا حذف: الإيقاف يخفي التصنيف من الاختيار
/// ويُبقي المنتجات والحسابات الحالية عليه.
class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key, required this.kind});

  final CategoryKind kind;

  bool get _product => kind == CategoryKind.product;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminCategoriesController>(
      init: AdminCategoriesController(kind),
      global: false,
      builder: (c) {
        if (c.status == StatusRequest.failure) return ErrorView(onRetry: c.load);
        if (c.status != StatusRequest.success) return const LoadingView();
        final rows = c.ordered;
        return AdminPage(
          onRefresh: c.load,
          children: [
            AdminPageHeader(
              title: (_product ? 'as_productCategories' : 'as_bizCategories').tr,
              subtitle: (_product ? 'adminProductCatsHint' : 'adminBizCatsHint').tr,
            ),
            _Form(c: c, withParent: _product),
            AdminTable(
              columns: [
                AdminColumn((_product ? 'adminColCategory' : 'adminColBizType').tr, flex: 4),
                const AdminColumn('English', flex: 4),
                if (_product) AdminColumn('adminColParent'.tr, flex: 3),
                AdminColumn((_product ? 'adminColProducts' : 'adminColAccounts').tr, flex: 2),
                AdminColumn('adminColStatus'.tr, flex: 2),
                const AdminColumn('', flex: 3),
              ],
              emptyText: 'adminNoResults'.tr,
              rows: [
                for (final cat in rows)
                  [
                    Padding(
                      // الفرعي مزاح للداخل ليظهر تحت أبيه.
                      padding: EdgeInsetsDirectional.only(start: cat.parentId == null ? 0 : 20),
                      child: Text(cat.ar,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cat.active ? AppColor.ink : AppColor.textSecondary,
                          )),
                    ),
                    Text(cat.en,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontSize: 14, color: cat.active ? AppColor.ink : AppColor.textSecondary)),
                    if (_product)
                      Text(cat.parentId == null ? '—' : c.nameOf(cat.parentId),
                          style: const TextStyle(fontSize: 14, color: AppColor.textSecondary)),
                    Text('${cat.count}', style: const TextStyle(fontSize: 14)),
                    AdminChip(
                      label: cat.active ? 'adminEnabled'.tr : 'adminPaused'.tr,
                      fg: cat.active ? AppColor.success : AppColor.textNote,
                      bg: cat.active ? AppColor.successSoft : AppColor.neutralSoft,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Link(label: 'adminEdit'.tr, onTap: () => c.edit(cat)),
                        _Link(
                          label: cat.active ? 'adminPause'.tr : 'adminEnable'.tr,
                          onTap: () => c.toggleActive(cat),
                        ),
                      ],
                    ),
                  ],
              ],
            ),
            Text((_product ? 'adminProductCatsNote' : 'adminBizCatsNote').tr,
                style: const TextStyle(fontSize: 13, height: 1.6, color: AppColor.textSecondary)),
          ],
        );
      },
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColor.orangeDeep,
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );
}

class _Form extends StatelessWidget {
  const _Form({required this.c, required this.withParent});

  final AdminCategoriesController c;
  final bool withParent;

  @override
  Widget build(BuildContext context) {
    final editing = c.editingId != null;
    return AdminBox(
      border: editing ? AppColor.orange : null,
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(width: 240, child: AppTextField(controller: c.ar, label: 'adminNameAr'.tr, maxLength: 60)),
          SizedBox(width: 240, child: AppTextField(controller: c.en, label: 'adminNameEn'.tr, ltr: true, maxLength: 60)),
          if (withParent)
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('adminColParent'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    // المفتاح يعيد بناء الحقل حين نبدأ تعديل تصنيف آخر.
                    key: ValueKey('parent-${c.editingId}'),
                    initialValue: c.parentId,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<String?>(value: null, child: Text('adminNoParent'.tr)),
                      for (final p in c.parentOptions) DropdownMenuItem<String?>(value: p.id, child: Text(p.ar)),
                    ],
                    onChanged: c.setParent,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColor.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColor.border, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColor.ink, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: 170,
            child: AppButton(
              label: editing ? 'adminSaveCategory'.tr : 'adminAddCategory'.tr,
              isLoading: c.saving,
              onPressed: c.canSave ? c.save : null,
            ),
          ),
          if (editing)
            SizedBox(
              width: 120,
              child: AppButton(label: 'undo'.tr, style: AppButtonStyle.secondary, onPressed: c.cancelEdit),
            ),
        ],
      ),
    );
  }
}
