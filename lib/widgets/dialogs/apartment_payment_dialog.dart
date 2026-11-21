import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/image_compressor.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';
import '../common/busy_overlay.dart';
import 'confirm_delete_dialog.dart';
import 'digital_receipt_screen.dart';

/// Opens the passcode setup or unlock dialog for a closed/non-monthly apartment
/// so its owner can set a passcode or unlock their apartment without converting
/// it to an active monthly apartment.
Future<void> showClosedApartmentPasscodeDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
  required int aptNum,
}) async {
  final hasPass = state.apartmentHasPasscode[aptNum] ?? false;
  final unlockedHere = hasPass &&
      state.myAptNum == aptNum &&
      state.savedAptPass != null &&
      state.savedAptPass!.isNotEmpty;
  if (unlockedHere) return;
  if (hasPass) {
    await _showUnlockApartmentDialog(
      context: context,
      cubit: cubit,
      state: state,
      aptNum: aptNum,
    );
  } else {
    await _showSetupApartmentPasscodeDialog(
      context: context,
      cubit: cubit,
      state: state,
      aptNum: aptNum,
    );
  }
}

Future<void> showApartmentPaymentDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
  required MonthBill month,
  required int aptNum,
  required ImagePicker picker,
}) async {
  final s = state.s;
  final isDark = state.isDarkMode;

  final hasPass = state.apartmentHasPasscode[aptNum] ?? false;
  final isUnlocked = !state.requireAptPassOnOpen ||
      state.isAdminOpen ||
      (hasPass &&
          state.myAptNum == aptNum &&
          state.savedAptPass != null &&
          state.savedAptPass!.isNotEmpty);

  if (!isUnlocked) {
    final unlocked = hasPass
        ? await _showUnlockApartmentDialog(
            context: context,
            cubit: cubit,
            state: state,
            aptNum: aptNum,
          )
        : await _showSetupApartmentPasscodeDialog(
            context: context,
            cubit: cubit,
            state: state,
            aptNum: aptNum,
          );
    if (!unlocked || !context.mounted) return;
  }

  final existing = month.payments[aptNum];
  if (existing != null) {
    bool cancelling = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setCancelState) => BusyOverlay(
          busy: cancelling,
          isDark: isDark,
          child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 20,
                        color: AppColors.emeraldText(isDark),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.aptLabel(aptNum),
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            s.paidBadge,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.emeraldText(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Column(
                    children: [
                      if (existing.localBytes != null) ...[
                        Text(
                          s.fileLabel(existing.fileName),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.memory(
                            existing.localBytes!,
                            height: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ] else if (existing.receiptUrl != null && existing.receiptUrl!.isNotEmpty) ...[
                        Text(
                          s.fileLabel(existing.fileName),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.network(
                            existing.receiptUrl!,
                            height: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.emeraldText(isDark),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                s.noReceiptAttached,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: s.viewDigitalReceiptBtn,
                  icon: Icons.receipt_long_rounded,
                  onPressed: () {
                    Navigator.pop(ctx);
                    showDigitalReceiptScreen(
                      context: context,
                      state: cubit.state,
                      month: month,
                      aptNum: aptNum,
                      payment: existing,
                    );
                  },
                ),
                if (state.isAdminOpen) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    label: s.cancelPaymentAdmin,
                    accentColor: AppColors.danger,
                    onPressed: () async {
                      final ok = await showConfirmDeleteDialog(
                        context: ctx,
                        s: s,
                        isDark: isDark,
                        message: s.confirmCancelPaymentBody(state.aptLabel(aptNum)),
                        onConfirm: () => cubit.cancelPayment(aptNum),
                      );
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    label: s.deleteOwnReceiptBtn,
                    icon: Icons.delete_outline_rounded,
                    accentColor: AppColors.danger,
                    onPressed: () async {
                      final ok = await showConfirmDeleteDialog(
                        context: ctx,
                        s: s,
                        isDark: isDark,
                        message: s.confirmDeleteOwnReceiptBody,
                        onConfirm: () async {
                          await cubit.cancelOwnPayment(aptNum);
                        },
                      );
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
    return;
  }

  Uint8List? pickedBytes;
  String? pickedName;
  String? errMsg;
  bool submitting = false;
  bool pickingImage = false;
  const instaPayPhone = '01021950445';

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.86,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Icon + Apt Name + Amount pill + Close
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.aptLabel(aptNum),
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.currency(month.dueFor(aptNum)),
                            style: AppTypography.statAmount.copyWith(
                              fontSize: 14,
                              color: AppColors.primaryText(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (month.extraChargesFor(aptNum).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.amber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.monthShareLine,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                            Text(
                              s.currency(month.sharePerApt),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        ...month.extraChargesFor(aptNum).map(
                          (e) => Padding(
                            padding: const EdgeInsetsDirectional.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '+ ${e.reason}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.warningText(isDark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '+${s.currency(e.amount.toInt())}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.warningText(isDark),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
                          child: Divider(height: 1, color: AppColors.border(isDark)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.totalDueLabel,
                              style: AppTypography.label.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              s.currency(month.dueFor(aptNum)),
                              style: AppTypography.title.copyWith(
                                color: AppColors.primaryText(isDark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.md),

                // InstaPay Transfer Card
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primaryText(isDark).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: AppColors.primaryText(isDark),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              s.instapayTitle,
                              style: AppTypography.label.copyWith(
                                color: AppColors.primaryText(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              instaPayPhone,
                              style: AppTypography.title.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.instapaySubtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final instaPayUri = Uri.parse(
                            'https://ipn.eg/S/mostafazaied/instapay/6nvhpw',
                          );
                          try {
                            await launchUrl(
                              instaPayUri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: Text(
                          s.openInstapayBtn,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onPrimaryAction(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryActionBg(isDark),
                          foregroundColor: AppColors.onPrimaryAction(isDark),
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Mandatory receipt image
                Text(
                  s.step2Image,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.receiptRequiredNote,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(isDark),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: (pickingImage || submitting)
                      ? null
                      : () async {
                          final XFile? file = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1400,
                            maxHeight: 1400,
                            imageQuality: 72,
                          );
                          if (file == null) return;
                          if (ctx.mounted) {
                            setModalState(() {
                              pickingImage = true;
                              errMsg = null;
                            });
                          }
                          try {
                            final rawBytes = await file.readAsBytes();
                            final bytes = await compressReceiptImage(rawBytes);
                            if (ctx.mounted) {
                              setModalState(() {
                                pickedBytes = bytes;
                                pickedName = file.name.endsWith('.png')
                                    ? file.name.replaceAll('.png', '.jpg')
                                    : file.name;
                                errMsg = null;
                              });
                            }
                          } finally {
                            if (ctx.mounted) {
                              setModalState(() => pickingImage = false);
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: pickingImage
                            ? AppColors.primary.withValues(alpha: 0.65)
                            : (pickedBytes != null
                                ? AppColors.emerald.withValues(alpha: 0.65)
                                : AppColors.border(isDark)),
                      ),
                    ),
                    child: pickingImage
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  s.uploadingBtn,
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.primaryText(isDark),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : (pickedBytes == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 19,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Flexible(
                                    child: Text(
                                      s.pickImagePrompt.replaceAll('📸', '').trim(),
                                      textAlign: TextAlign.center,
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(
                                    s.chosenFile(pickedName ?? ''),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.emeraldText(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    child: Image.memory(
                                      pickedBytes!,
                                      height: 110,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              )),
                  ),
                ),

                if (errMsg != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      errMsg!,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Action Row: Cancel + Confirm Payment
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: submitting ? null : () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          s.cancel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: submitting
                            ? s.uploadingBtn
                            : s.confirmPaymentBtn.replaceAll('✅', '').trim(),
                        icon: Icons.check_rounded,
                        loading: submitting,
                        onPressed: (submitting || pickingImage)
                            ? null
                            : () async {
                                if (pickedBytes == null) {
                                  setModalState(() {
                                    errMsg = s.errReceiptRequired;
                                  });
                                  return;
                                }
                                setModalState(() => submitting = true);
                                final resErr = await cubit.submitPayment(
                                  aptNum: aptNum,
                                  passcode: cubit.state.savedAptPass ?? '',
                                  imageBytes: pickedBytes,
                                  fileName: pickedName,
                                );
                                if (resErr != null) {
                                  setModalState(() {
                                    submitting = false;
                                    errMsg = resErr;
                                  });
                                  return;
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  final latestState = cubit.state;
                                  final updatedMonth =
                                      latestState.currentMonth ?? month;
                                  final newPayment =
                                      updatedMonth.payments[aptNum] ??
                                          PaymentRecord(
                                            aptNum: aptNum,
                                            fileName: pickedName ?? 'receipt.jpg',
                                            paidAt: DateTime.now(),
                                          );
                                  showDigitalReceiptScreen(
                                    context: context,
                                    state: latestState,
                                    month: updatedMonth,
                                    aptNum: aptNum,
                                    payment: newPayment,
                                    celebrate: true,
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<bool> _showUnlockApartmentDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
  required int aptNum,
}) async {
  final s = state.s;
  final isDark = state.isDarkMode;
  final passCtrl = TextEditingController();
  String? errMsg;
  bool checking = false;
  bool unlocked = false;

  Future<void> submit(
    BuildContext ctx,
    void Function(VoidCallback) setModalState,
  ) async {
    setModalState(() {
      checking = true;
      errMsg = null;
    });
    final err = await cubit.unlockApartment(aptNum, passCtrl.text);
    if (err != null) {
      setModalState(() {
        checking = false;
        errMsg = err;
      });
      return;
    }
    unlocked = true;
    if (ctx.mounted) Navigator.pop(ctx);
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.aptLabel(aptNum),
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.unlockAptSubtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  autofocus: true,
                  onSubmitted: checking ? null : (_) => submit(ctx, setModalState),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    hintText: s.enterPassHint,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: Icon(
                      Icons.vpn_key_outlined,
                      size: 18,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
                if (errMsg != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    errMsg!,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.forgotPassHint,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: checking ? null : () => Navigator.pop(ctx),
                        child: Text(
                          s.cancel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: s.unlockAptBtn,
                        icon: Icons.lock_open_rounded,
                        loading: checking,
                        onPressed: checking ? null : () => submit(ctx, setModalState),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Future.delayed(const Duration(milliseconds: 350), passCtrl.dispose);
  return unlocked;
}


Future<bool> _showSetupApartmentPasscodeDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
  required int aptNum,
}) async {
  final s = state.s;
  final isDark = state.isDarkMode;
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? errMsg;
  bool saving = false;
  bool saved = false;

  Future<void> submit(
    BuildContext ctx,
    void Function(VoidCallback) setModalState,
  ) async {
    final p1 = passCtrl.text.trim();
    final p2 = confirmCtrl.text.trim();
    if (p1.length < 4) {
      setModalState(() => errMsg = s.errPassTooShort);
      return;
    }
    if (p1 != p2) {
      setModalState(() => errMsg = s.errPassMismatch);
      return;
    }
    setModalState(() {
      saving = true;
      errMsg = null;
    });
    final err = await cubit.setInitialApartmentPasscode(aptNum, p1);
    if (err != null) {
      setModalState(() {
        saving = false;
        errMsg = err;
      });
      return;
    }
    saved = true;
    if (ctx.mounted) Navigator.pop(ctx);
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.vpn_key_outlined,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.aptLabel(aptNum),
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.setupAptPassSubtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Text(
                    s.setupAptPassHint,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(isDark),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  autofocus: true,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    labelText: s.newPasscodeLabel,
                    hintText: s.enterPassHint,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  onSubmitted: saving ? null : (_) => submit(ctx, setModalState),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    labelText: s.confirmPasscodeLabel,
                    hintText: s.enterPassHint,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
                if (errMsg != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    errMsg!,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: saving ? null : () => Navigator.pop(ctx),
                        child: Text(
                          s.cancel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: s.saveAndUnlockBtn,
                        icon: Icons.check_rounded,
                        loading: saving,
                        onPressed: saving ? null : () => submit(ctx, setModalState),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Future.delayed(const Duration(milliseconds: 350), () {
    passCtrl.dispose();
    confirmCtrl.dispose();
  });
  return saved;
}