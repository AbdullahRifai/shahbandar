import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/supplier/product_form_controller.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/functions/first_where_or_null.dart';
import '../../../core/functions/format_money.dart';
import '../../../core/shared/app_button.dart';
import '../../../core/shared/app_image.dart';
import '../../../core/shared/app_select_field.dart';
import '../../../core/shared/app_text_field.dart';
import '../../../core/shared/max_width.dart';
import '../../../core/shared/state_views.dart';
import '../../../data/model/product_model.dart';
import '../../widget/trader/trader_parts.dart';

/// C8 — إضافة منتج، C9 — تعديل منتج.
/// من الأعلى: الصور (حتى 5، الأولى غلاف)، الاسم، التصنيف، الوصف، السعر والعملة،
/// المخزون والحد الأدنى، و(في التعديل) مفتاح النشر.
class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductFormController>(
      init: ProductFormController(productId),
      global: false,
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text(c.isEdit ? 'editProduct'.tr : 'addProduct'.tr)),
        body: switch (c.status) {
          StatusRequest.failure => ErrorView(onRetry: c.load),
          StatusRequest.success => _Form(c: c),
          _ => const LoadingView(),
        },
        bottomNavigationBar: c.status == StatusRequest.success ? _Bar(c: c) : null,
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.c});

  final ProductFormController c;

  @override
  Widget build(BuildContext context) {
    final category = firstWhereOrNull(c.categories, (o) => o.id == c.categoryId);
    return MaxWidth(
      maxWidth: 600,
      child: Form(
        autovalidateMode: c.submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _Images(c: c),
            const SizedBox(height: 20),
            AppTextField(
              controller: c.name,
              label: 'productName'.tr,
              hint: 'productNameHint'.tr,
              textInputAction: TextInputAction.next,
              maxLength: 120,
              validator: (_) => c.nameError,
            ),
            const SizedBox(height: 16),
            AppSelectField(
              label: 'category'.tr,
              options: c.categories,
              value: category,
              onChanged: (o) => c.setCategory(o.id),
              errorText: c.submitted && c.categoryId == null ? 'fieldRequired'.tr : null,
            ),
            const SizedBox(height: 16),
            _Description(c: c),
            const SizedBox(height: 16),
            _Price(c: c),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: c.stock,
                    label: 'stockAvailableLabel'.tr,
                    keyboardType: TextInputType.number,
                    ltr: true,
                    validator: (_) => c.stockError,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: c.moq,
                    label: '${'moq'.tr} ${'optional'.tr}',
                    hint: '1',
                    keyboardType: TextInputType.number,
                    ltr: true,
                    validator: (_) => c.moqError,
                  ),
                ),
              ],
            ),
            if (c.isEdit) ...[
              const SizedBox(height: 16),
              SurfaceCard(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.active ? 'published'.tr : 'paused'.tr,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text('pauseHint'.tr,
                              style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                        ],
                      ),
                    ),
                    Semantics(
                      label: 'publishProduct'.tr,
                      child: Switch(
                        value: c.active,
                        onChanged: c.setActive,
                        activeTrackColor: AppColor.ink,
                        inactiveTrackColor: AppColor.border,
                        inactiveThumbColor: AppColor.surface,
                        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// الصور: الغلاف أولاً، ثم البقية، ثم زر الإضافة. الضغط على صورة يعرض خياراتها.
class _Images extends StatelessWidget {
  const _Images({required this.c});

  final ProductFormController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('images'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              'imagesCount'.trParams({'n': '${c.images.length}', 'max': '${ProductFormController.maxImages}'}),
              style: const TextStyle(fontSize: 13, color: AppColor.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < c.images.length; i++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: _ImageTile(c: c, img: c.images[i], cover: i == 0, index: i),
                ),
              if (c.canAddImage)
                _AddTile(onTap: c.addImage),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // بلا صور: نوضّح لماذا زر النشر معطّل.
        Text(
          c.images.isEmpty ? 'needImageToPublish'.tr : 'imagesHint'.tr,
          style: const TextStyle(fontSize: 13, height: 1.5, color: AppColor.textSecondary),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.c, required this.img, required this.cover, required this.index});

  final ProductFormController c;
  final FormImage img;
  final bool cover;
  final int index;

  @override
  Widget build(BuildContext context) {
    final percent = (img.progress * 100).round();
    return Semantics(
      button: !img.uploading,
      label: img.uploading
          ? 'imageUploading'.trParams({'p': '$percent'})
          : (cover ? 'coverImage'.tr : 'imageN'.trParams({'n': '${index + 1}'})),
      excludeSemantics: true,
      child: Material(
        color: AppColor.note,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: img.uploading ? null : () => _options(context),
          child: SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                // الصورة الحقيقية التي اختارها المستخدم.
                if (img.preview != null)
                  Image.memory(img.preview!, fit: BoxFit.cover, gaplessPlayback: true)
                else
                  AppImage(
                    url: img.url,
                    placeholder: const Icon(Icons.image_outlined, size: 36, color: AppColor.textSecondary),
                  ),
                if (img.uploading)
                  ColoredBox(
                    color: const Color(0x8017202E),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 44,
                          child: CircularProgressIndicator(
                            value: img.progress,
                            strokeWidth: 3,
                            color: AppColor.surface,
                            backgroundColor: const Color(0x55FFFFFF),
                          ),
                        ),
                        Text('$percent%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.surface)),
                      ],
                    ),
                  ),
                if (cover && !img.uploading)
                  PositionedDirectional(
                    bottom: 6,
                    start: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColor.ink, borderRadius: BorderRadius.circular(8)),
                      child: Text('cover'.tr,
                          style: const TextStyle(color: AppColor.surface, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _options(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      backgroundColor: AppColor.surface,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!cover)
              ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.star_outline_rounded),
                title: Text('makeCover'.tr),
                onTap: () {
                  Navigator.pop(sheet);
                  c.makeCover(img);
                },
              ),
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.delete_outline_rounded, color: AppColor.danger),
              title: Text('removeImage'.tr, style: const TextStyle(color: AppColor.danger)),
              onTap: () {
                Navigator.pop(sheet);
                c.removeImage(img);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColor.borderStrong, width: 1.5),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined, color: AppColor.ink),
              const SizedBox(height: 4),
              Text('add'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.c});

  final ProductFormController c;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${'description'.tr} ${'optional'.tr}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: c.description,
          minLines: 3,
          maxLines: 6,
          maxLength: ProductFormController.maxDescription,
          style: const TextStyle(fontSize: 16, height: 1.5),
          decoration: InputDecoration(
            hintText: 'descriptionHint'.tr,
            hintStyle: const TextStyle(color: AppColor.textSecondary),
            filled: true,
            fillColor: AppColor.surface,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: border(AppColor.border, 1.5),
            focusedBorder: border(AppColor.ink, 2),
          ),
        ),
      ],
    );
  }
}

/// سعر الوحدة + العملة. السعر بأرقام لاتينية من اليسار.
class _Price extends StatelessWidget {
  const _Price({required this.c});

  final ProductFormController c;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppTextField(
            controller: c.price,
            label: 'unitPriceLabel'.tr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ltr: true,
            validator: (_) => c.priceError,
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          // يحاذي الأزرار مع الحقل حتى حين يظهر خطأ تحته.
          padding: EdgeInsets.only(bottom: c.priceError != null ? 26 : 0),
          child: SegmentedButton<Currency>(
            segments: [
              for (final cur in Currency.values) ButtonSegment(value: cur, label: Text(currencyName(cur))),
            ],
            selected: {c.currency},
            showSelectedIcon: false,
            onSelectionChanged: (s) => c.setCurrency(s.first),
            style: SegmentedButton.styleFrom(
              minimumSize: const Size(0, 50),
              selectedBackgroundColor: AppColor.ink,
              selectedForegroundColor: AppColor.surface,
              backgroundColor: AppColor.surface,
              side: const BorderSide(color: AppColor.border, width: 1.5),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// الشريط السفلي: سبب تعطيل النشر (إن وجد) ثم الأزرار.
class _Bar extends StatelessWidget {
  const _Bar({required this.c});

  final ProductFormController c;

  @override
  Widget build(BuildContext context) {
    final String? note = c.uploading
        ? 'publishAfterUpload'.tr
        : c.isEdit
            ? 'editPriceNote'.tr
            : null;

    return BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (note != null) ...[
            Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  Icon(c.uploading ? Icons.cloud_upload_outlined : Icons.info_outline_rounded,
                      size: 18, color: AppColor.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(note, style: const TextStyle(fontSize: 13, color: AppColor.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (c.isEdit)
            AppButton(
              label: 'saveChanges'.tr,
              isLoading: c.saving,
              onPressed: c.canSave ? () => c.save() : null,
            )
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'saveAsPaused'.tr,
                    style: AppButtonStyle.secondary,
                    onPressed: c.canSave ? () => c.save(publish: false) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'publishProduct'.tr,
                    isLoading: c.saving,
                    onPressed: c.canPublish ? () => c.save(publish: true) : null,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
