import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/apartment_avatar.dart';
import '../../core/utils/push_notifications.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../screens/admin_settings_screen.dart';
import '../../screens/install_app_screen.dart';
import '../dialogs/admin_login_dialog.dart';
import '../dialogs/apartment_profile_dialog.dart';
import '../dialogs/manage_apartments_dialog.dart';

class AppSideMenu extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final VoidCallback? onClose;

  const AppSideMenu({
    super.key,
    required this.cubit,
    required this.state,
    this.onClose,
  });

  static const String _managerWhatsApp = '201021950445';

  Future<void> _contactManager() async {
    final uri = Uri.parse('https://wa.me/$_managerWhatsApp');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareReferral(String message) async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _close(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final isPushGranted = getPushPermissionStatus() == 'granted';

    final headerSubtitle = state.isAdminAuthenticated
        ? '${s.splashTagline} • ${s.contactAddedByAdmin}'
        : s.splashTagline;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 140 || constraints.maxHeight < 220) {
              return const SizedBox.shrink();
            }
            return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Brand Header + Clickable Apartment Profile Pill
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.emerald],
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.appTitle,
                              style: AppTypography.title.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w900,
                                fontSize: 15.5,
                              ),
                            ),
                            Text(
                              headerSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: s.close,
                        onPressed: () => _close(context),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 19,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Builder(
                    builder: (_) {
                      final myApt = state.myAptNum;
                      final profile =
                          myApt != null ? state.apartmentProfiles[myApt] : null;
                      final label = myApt != null
                          ? s.drawerMyAptLabel(state.aptLabel(myApt))
                          : s.myProfileTitle;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _close(context);
                              showApartmentProfileDialog(
                                context: context,
                                cubit: cubit,
                                aptNum: myApt,
                              );
                            },
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: isDark ? 0.16 : 0.10),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: isDark ? 0.28 : 0.20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (myApt != null)
                                    ApartmentAvatar(
                                      aptNum: myApt,
                                      avatarUrl: (profile != null && profile.hasAvatar)
                                          ? profile.avatarUrl
                                          : null,
                                      size: 24,
                                      borderRadius: 99,
                                    )
                                  else
                                    Icon(
                                      Icons.home_rounded,
                                      size: 16,
                                      color: AppColors.primaryText(isDark),
                                    ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textPrimary(isDark),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary(isDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Grouped iOS-Style Menu Body
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                children: [
                  // Group 1: Building Services
                  _sectionHeader(s.drawerExtraSections, isDark),
                  _groupCard(
                    isDark: isDark,
                    children: [
                      _groupRow(
                        icon: Icons.groups_outlined,
                        label: s.contactsTabNeighbors,
                        isDark: isDark,
                        selected: state.selectedNavIndex == 8,
                        accentColor: AppColors.emeraldText(isDark),
                        trailing: _chevron(isDark),
                        onTap: () {
                          _close(context);
                          cubit.selectNav(8);
                        },
                      ),
                      _groupRow(
                        icon: Icons.how_to_vote_outlined,
                        label: s.navPolls,
                        isDark: isDark,
                        selected: state.selectedNavIndex == 6,
                        accentColor: AppColors.emeraldText(isDark),
                        trailing: state.openPollsCount > 0
                            ? _pillChip(
                                '${state.openPollsCount}',
                                isDark: isDark,
                                highlighted: true,
                              )
                            : _chevron(isDark),
                        onTap: () {
                          _close(context);
                          cubit.selectNav(6);
                        },
                      ),
                      _groupRow(
                        icon: Icons.bar_chart_rounded,
                        label: s.navAnalytics,
                        isDark: isDark,
                        selected: state.selectedNavIndex == 4,
                        accentColor: AppColors.primaryText(isDark),
                        trailing: _chevron(isDark),
                        onTap: () {
                          _close(context);
                          cubit.selectNav(4);
                        },
                      ),
                      _groupRow(
                        icon: Icons.star_outline_rounded,
                        label: s.navAppRating,
                        isDark: isDark,
                        selected: state.selectedNavIndex == 7,
                        accentColor: AppColors.amber,
                        trailing: _chevron(isDark),
                        onTap: () {
                          _close(context);
                          cubit.selectNav(7);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Group 2: App Preferences
                  _sectionHeader(s.drawerPreferences, isDark),
                  _groupCard(
                    isDark: isDark,
                    children: [
                      _groupRow(
                        icon: isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        label: s.drawerThemeLabel,
                        isDark: isDark,
                        trailing: _pillChip(
                          isDark ? s.drawerThemeDark : s.drawerThemeLight,
                          isDark: isDark,
                        ),
                        onTap: cubit.toggleTheme,
                      ),
                      _groupRow(
                        icon: Icons.language_rounded,
                        label: s.drawerLanguageLabel,
                        isDark: isDark,
                        trailing: _pillChip(
                          state.localeCode == 'ar' ? 'العربية' : 'English',
                          isDark: isDark,
                        ),
                        onTap: () => cubit.setLocale(
                          state.localeCode == 'ar' ? 'en' : 'ar',
                        ),
                      ),
                      _groupRow(
                        icon: isPushGranted
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        label: s.drawerNotificationsLabel,
                        isDark: isDark,
                        trailing: _pillChip(
                          isPushGranted
                              ? s.pushEnabledBadge
                              : s.pushEnableAction,
                          isDark: isDark,
                          highlighted: isPushGranted,
                        ),
                        onTap: () async {
                          _close(context);
                          await cubit.enablePushNotifications();
                        },
                      ),
                      _groupRow(
                        icon: Icons.install_mobile_rounded,
                        label: s.installAppNavLabel,
                        isDark: isDark,
                        accentColor: AppColors.emeraldText(isDark),
                        trailing: _chevron(isDark),
                        onTap: () {
                          _close(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const InstallAppScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Group 3: Administration
                  _sectionHeader(s.drawerAdminSection, isDark),
                  _groupCard(
                    isDark: isDark,
                    children: !state.isAdminAuthenticated
                        ? [
                            _groupRow(
                              icon: Icons.admin_panel_settings_outlined,
                              label: s.drawerAdminLogin,
                              isDark: isDark,
                              accentColor: AppColors.primaryText(isDark),
                              trailing: _chevron(isDark),
                              onTap: () async {
                                _close(context);
                                if (!AppConfig.isSupabaseConfigured) {
                                  await cubit.openAdmin('admin123');
                                  return;
                                }
                                await showAdminLoginDialog(
                                  context,
                                  s,
                                  startWithBiometric: true,
                                  onVerifyPassword: (pass) => cubit.openAdmin(
                                    pass,
                                    showErrorToast: false,
                                  ),
                                );
                              },
                            ),
                          ]
                        : [
                            _groupRow(
                              icon: Icons.settings_outlined,
                              label: s.settingsBtn,
                              isDark: isDark,
                              accentColor: AppColors.primaryText(isDark),
                              trailing: _chevron(isDark),
                              onTap: () {
                                _close(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (settingsCtx) =>
                                        AdminSettingsScreen(
                                      onOpenManageApts: () =>
                                          showManageApartmentsDialog(
                                        context: settingsCtx,
                                        cubit: cubit,
                                        state: cubit.state,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            _groupRow(
                              icon: Icons.visibility_outlined,
                              label: s.adminViewsTitle,
                              isDark: isDark,
                              selected: state.selectedNavIndex == 5,
                              accentColor: AppColors.primaryText(isDark),
                              trailing: _chevron(isDark),
                              onTap: () {
                                _close(context);
                                cubit.selectNav(5);
                                cubit.refreshPageViewStats(showBusy: false);
                              },
                            ),
                            _groupRow(
                              icon: Icons.logout_rounded,
                              label: s.adminLogoutBtn,
                              isDark: isDark,
                              accentColor: AppColors.dangerText(isDark),
                              onTap: () async {
                                _close(context);
                                await cubit.logoutAdmin();
                              },
                            ),
                          ],
                  ),
                ],
              ),
            ),

            // Stacked Footer: Referral + Contact Manager
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.isAdminAuthenticated) ...[
                    _footerButton(
                      icon: Icons.rocket_launch_outlined,
                      label: s.getMabnaForBuildingBtn,
                      fg: AppColors.primaryText(isDark),
                      bg: AppColors.primary
                          .withValues(alpha: isDark ? 0.16 : 0.10),
                      border: AppColors.primary.withValues(alpha: 0.35),
                      onTap: () {
                        _close(context);
                        _shareReferral(s.referralShareMessage);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  _footerButton(
                    icon: Icons.chat_rounded,
                    label: s.contactManagerBtn,
                    fg: AppColors.emeraldText(isDark),
                    bg: AppColors.emerald
                        .withValues(alpha: isDark ? 0.16 : 0.10),
                    border: AppColors.emerald.withValues(alpha: 0.35),
                    onTap: _contactManager,
                  ),
                ],
              ),
            ),
          ],
        );
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xs,
        0,
        AppSpacing.xs,
        6,
      ),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          color: AppColors.textSecondary(isDark),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _groupCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 42,
                color: AppColors.border(isDark),
              ),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _groupRow({
    required IconData icon,
    required String label,
    required bool isDark,
    bool selected = false,
    Color? accentColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final fg = selected
        ? AppColors.primaryText(isDark)
        : (accentColor ?? AppColors.textPrimary(isDark));

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillChip(
    String text, {
    required bool isDark,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.emerald.withValues(alpha: 0.16)
            : AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: highlighted
              ? AppColors.emerald.withValues(alpha: 0.4)
              : AppColors.border(isDark),
        ),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: highlighted
              ? AppColors.emeraldText(isDark)
              : AppColors.textSecondary(isDark),
        ),
      ),
    );
  }

  Widget _chevron(bool isDark) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 17,
      color: AppColors.textSecondary(isDark).withValues(alpha: 0.65),
    );
  }

  Widget _footerButton({
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
