import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../dialogs/apartment_payment_dialog.dart';
import '../dialogs/apartment_profile_dialog.dart';

class MyApartmentBanner extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;
  final ValueChanged<int> onTapPay;

  const MyApartmentBanner({
    super.key,
    required this.cubit,
    required this.state,
    required this.month,
    required this.onTapPay,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final myApt = state.myAptNum;
    final closedSet = state.closedAptNums.toSet();
    final maxClosed =
        closedSet.isEmpty ? 0 : closedSet.reduce((a, b) => a > b ? a : b);
    final totalApts = (month.aptsCount + closedSet.length) > maxClosed
        ? (month.aptsCount + closedSet.length)
        : maxClosed;

    if (myApt == null || myApt < 1 || myApt > totalApts) {
      return Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home_outlined,
              size: 18,
              color: AppColors.primaryText(isDark),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                s.pinAptPrompt,
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            PopupMenuButton<int>(
              onSelected: cubit.setMyApt,
              color: AppColors.cardElevated(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              itemBuilder: (_) => List.generate(totalApts, (i) {
                final num = i + 1;
                final isClosedApt = closedSet.contains(num);
                return PopupMenuItem(
                  value: num,
                  child: Text(
                    '${isClosedApt ? '🔒 ' : ''}${state.aptLabel(num)}',
                  ),
                );
              }),
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  s.selectAptBtn,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryText(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isClosedApt = closedSet.contains(myApt);
    final pendingSpecial = state.specialAptFees
        .where((f) => f.aptNum == myApt && !f.isPaid)
        .fold<double>(0, (sum, f) => sum + f.amount)
        .round();
    final isPaid = isClosedApt ? pendingSpecial == 0 : month.payments.containsKey(myApt);
    final isOverdue = !isClosedApt && !isPaid && month.isPastDue;
    final accent = isPaid
        ? AppColors.emerald
        : (isOverdue ? AppColors.danger : (isClosedApt ? AppColors.amber : AppColors.primary));
    final unlockedHere = (state.apartmentHasPasscode[myApt] ?? false) &&
        state.savedAptPass != null &&
        state.savedAptPass!.isNotEmpty;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isPaid
              ? [
                  AppColors.emerald.withValues(alpha: isDark ? 0.14 : 0.08),
                  AppColors.card(isDark),
                ]
              : [
                  accent.withValues(alpha: isDark ? 0.16 : 0.08),
                  AppColors.card(isDark),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: accent.withValues(alpha: isOverdue ? 0.5 : 0.35)),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isPaid
                  ? Icons.verified_rounded
                  : (isOverdue ? Icons.warning_amber_rounded : Icons.home_rounded),
              size: 19,
              color: isPaid
                  ? AppColors.emeraldText(isDark)
                  : (isOverdue ? AppColors.dangerText(isDark) : AppColors.primaryText(isDark)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.myAptPrefix}: ${state.aptLabel(myApt)}',
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                Text(
                  isClosedApt
                      ? (pendingSpecial > 0
                          ? s.closedAptDueLabel(s.currency(pendingSpecial))
                          : s.closedAptClearLabel)
                      : (isPaid
                          ? s.paidBadge
                          : (isOverdue
                              ? '${s.currency(month.dueFor(myApt))} • ${s.overdueBadge}'
                              : s.currency(month.dueFor(myApt)))),
                  style: AppTypography.caption.copyWith(
                    color: isPaid
                        ? AppColors.emeraldText(isDark)
                        : (isOverdue ? AppColors.dangerText(isDark) : AppColors.amber),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (isClosedApt && state.requireAptPassOnOpen && !unlockedHere) ...[
            const SizedBox(width: AppSpacing.xs),
            InkWell(
              onTap: () => showClosedApartmentPasscodeDialog(
                context: context,
                cubit: cubit,
                state: state,
                aptNum: myApt,
              ),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.vpn_key_outlined,
                      size: 14,
                      color: Color(0xFF0F172A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.passcodeLabel,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (!isClosedApt && !isPaid) ...[
            const SizedBox(width: AppSpacing.xs),
            InkWell(
              onTap: () => onTapPay(myApt),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  s.payNowBtn,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          IconButton(
            tooltip: s.myProfileTitle,
            visualDensity: VisualDensity.compact,
            onPressed: () => showApartmentProfileDialog(
              context: context,
              cubit: cubit,
              aptNum: myApt,
            ),
            icon: Icon(
              Icons.manage_accounts_outlined,
              size: 19,
              color: AppColors.primaryText(isDark),
            ),
          ),
          PopupMenuButton<int>(
            tooltip: s.changeAptTooltip,
            onSelected: (val) => cubit.setMyApt(val == -1 ? null : val),
            color: AppColors.cardElevated(isDark),
            icon: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: AppColors.textSecondary(isDark),
            ),
            itemBuilder: (_) => [
              ...List.generate(totalApts, (i) {
                final num = i + 1;
                final isClosedItem = closedSet.contains(num);
                return PopupMenuItem(
                  value: num,
                  child: Text(
                    '${isClosedItem ? '🔒 ' : ''}${state.aptLabel(num)}',
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
