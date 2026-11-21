import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/apartment_avatar.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/dialogs/apartment_profile_dialog.dart';

class NeighborsScreen extends StatelessWidget {
  const NeighborsScreen({super.key});

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _launchWhatsApp(String waNumber) async {
    final uri = Uri.parse('https://wa.me/$waNumber');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final neighborProfiles = state.apartmentProfiles.values
            .where((p) => p.hasPhone || p.floorNum.isNotEmpty || p.hasAvatar)
            .toList()
          ..sort((a, b) => a.aptNum.compareTo(b.aptNum));

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
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
                                s.contactsTabNeighbors,
                                style: AppTypography.headline.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${neighborProfiles.length}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppPrimaryButton(
                          label: s.myProfileBtn,
                          icon: Icons.account_circle_outlined,
                          backgroundColor: AppColors.primaryActionBg(isDark),
                          foregroundColor: AppColors.onPrimaryAction(isDark),
                          onPressed: () => showApartmentProfileDialog(
                            context: context,
                            cubit: cubit,
                            aptNum: state.myAptNum,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: cubit.refreshData,
                      color: AppColors.primary,
                      child: neighborProfiles.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: AppCard(
                                    padding: const EdgeInsetsDirectional.all(
                                      AppSpacing.xxxl,
                                    ),
                                    child: Text(
                                      s.noNeighborsYet,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsetsDirectional.only(bottom: 90),
                              itemCount: neighborProfiles.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final p = neighborProfiles[index];
                                return AppCard(
                                  padding: const EdgeInsetsDirectional.all(
                                    AppSpacing.md,
                                  ),
                                  child: Row(
                                    children: [
                                      ApartmentAvatar(
                                        aptNum: p.aptNum,
                                        avatarUrl: p.hasAvatar ? p.avatarUrl : null,
                                        size: 46,
                                        borderRadius: AppRadius.md,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state.aptLabel(p.aptNum),
                                              style: AppTypography.title.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            if (p.floorNum.isNotEmpty)
                                              Text(
                                                p.floorNum,
                                                style: AppTypography.caption.copyWith(
                                                  color:
                                                      AppColors.textSecondary(isDark),
                                                ),
                                              ),
                                            if (p.hasPhone)
                                              Text(
                                                p.phone,
                                                textDirection: TextDirection.ltr,
                                                style: AppTypography.caption.copyWith(
                                                  color:
                                                      AppColors.primaryText(isDark),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            if (state.isAdminAuthenticated &&
                                                !p.showPhoneToNeighbors &&
                                                p.hasPhone)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 3),
                                                child: Text(
                                                  '🔒 ${s.neighborPhoneHiddenAdminBadge}',
                                                  style:
                                                      AppTypography.caption.copyWith(
                                                    fontSize: 10.5,
                                                    color: AppColors.amber,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (p.hasPhone) ...[
                                        IconButton(
                                          tooltip: s.callBtn,
                                          onPressed: () => _launchPhone(p.phone),
                                          icon: Icon(
                                            Icons.call_rounded,
                                            color: AppColors.emeraldText(isDark),
                                          ),
                                        ),
                                        if (p.supportsWhatsApp)
                                          IconButton(
                                            tooltip: 'WhatsApp',
                                            onPressed: () =>
                                                _launchWhatsApp(p.whatsappNumber),
                                            icon: Icon(
                                              Icons.chat_rounded,
                                              color: AppColors.emeraldText(isDark),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
