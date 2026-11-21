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
import '../../screens/notifications_screen.dart';
import '../dialogs/admin_login_dialog.dart';
import '../dialogs/apartment_profile_dialog.dart';
import '../dialogs/manage_apartments_dialog.dart';

class DesktopSidebar extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final bool extended;

  const DesktopSidebar({
    super.key,
    required this.cubit,
    required this.state,
    required this.extended,
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

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final isGranted = getPushPermissionStatus() == 'granted';

    return Container(
      width: extended ? 256 : 78,
      color: AppColors.surface(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand Header
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              extended ? AppSpacing.lg : AppSpacing.sm,
              AppSpacing.lg,
              extended ? AppSpacing.lg : AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment:
                  extended ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment:
                      extended ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.emerald],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    if (extended) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.appTitle,
                              style: AppTypography.title.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                            Text(
                              s.splashTagline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (extended) ...[
                  const SizedBox(height: AppSpacing.md),
                  Builder(
                    builder: (_) {
                      final myApt = state.myAptNum;
                      final profile =
                          myApt != null ? state.apartmentProfiles[myApt] : null;
                      final label = myApt != null
                          ? s.drawerMyAptLabel(state.aptLabel(myApt))
                          : s.myProfileTitle;
                      return Tooltip(
                        message: s.myProfileTitle,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => showApartmentProfileDialog(
                              context: context,
                              cubit: cubit,
                              aptNum: myApt,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 7,
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
                                      size: 22,
                                      borderRadius: 99,
                                    )
                                  else
                                    Icon(
                                      Icons.home_rounded,
                                      size: 15,
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
                                        fontWeight: FontWeight.w700,
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
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.border(isDark)),
          ),

          // Scrollable Navigation + Preferences + Admin
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.all(
                extended ? AppSpacing.md : AppSpacing.sm,
              ),
              children: [
                // Primary Tabs
                _tile(
                  icon: state.selectedNavIndex == 0
                      ? Icons.account_balance_wallet_rounded
                      : Icons.account_balance_wallet_outlined,
                  label: s.navExpenses,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 0,
                  onTap: () => cubit.selectNav(0),
                ),
                _tile(
                  icon: state.selectedNavIndex == 1
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  label: s.navEmergency,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 1,
                  onTap: () => cubit.selectNav(1),
                ),
                _tile(
                  icon: Icons.bar_chart_rounded,
                  label: s.navAnalytics,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 4,
                  onTap: () => cubit.selectNav(4),
                ),
                _tile(
                  icon: state.unreadNotificationsCount > 0
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  label: s.notifHistoryTitle,
                  isDark: isDark,
                  trailing: state.unreadNotificationsCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${state.unreadNotificationsCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                _tile(
                  icon: state.selectedNavIndex == 6
                      ? Icons.how_to_vote_rounded
                      : Icons.how_to_vote_outlined,
                  label: s.navPolls,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 6,
                  trailing: state.openPollsCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${state.openPollsCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => cubit.selectNav(6),
                ),
                _tile(
                  icon: state.selectedNavIndex == 2
                      ? Icons.contact_phone_rounded
                      : Icons.contact_phone_outlined,
                  label: s.navContactsFull,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 2,
                  onTap: () => cubit.selectNav(2),
                ),
                _tile(
                  icon: state.selectedNavIndex == 3
                      ? Icons.forum_rounded
                      : Icons.forum_outlined,
                  label: s.navFeedbackFull,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 3,
                  onTap: () => cubit.selectNav(3),
                ),
                _tile(
                  icon: state.selectedNavIndex == 8
                      ? Icons.groups_rounded
                      : Icons.groups_outlined,
                  label: s.contactsTabNeighbors,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 8,
                  accentColor: AppColors.emeraldText(isDark),
                  onTap: () => cubit.selectNav(8),
                ),
                _tile(
                  icon: state.selectedNavIndex == 7
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  label: s.navAppRating,
                  isDark: isDark,
                  selected: state.selectedNavIndex == 7,
                  accentColor: AppColors.amber,
                  onTap: () => cubit.selectNav(7),
                ),

                const SizedBox(height: AppSpacing.sm),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.sm),

                // Preferences (exact same clean style as tabs!)
                if (extended) _sectionHeader(s.drawerPreferences, isDark),
                _tile(
                  icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  label: s.drawerThemeLabel,
                  isDark: isDark,
                  trailing: _pillBadge(
                    isDark ? s.drawerThemeDark : s.drawerThemeLight,
                    isDark,
                  ),
                  onTap: cubit.toggleTheme,
                ),
                _tile(
                  icon: Icons.language_rounded,
                  label: s.drawerLanguageLabel,
                  isDark: isDark,
                  trailing: _pillBadge(
                    state.localeCode == 'ar' ? 'العربية' : 'English',
                    isDark,
                  ),
                  onTap: () => cubit.setLocale(state.localeCode == 'ar' ? 'en' : 'ar'),
                ),
                _tile(
                  icon: isGranted
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  label: s.drawerNotificationsLabel,
                  isDark: isDark,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isGranted
                          ? AppColors.emerald.withValues(alpha: 0.16)
                          : AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isGranted
                            ? AppColors.emerald.withValues(alpha: 0.4)
                            : AppColors.border(isDark),
                      ),
                    ),
                    child: Text(
                      isGranted ? s.pushEnabledBadge : s.pushEnableAction,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isGranted
                            ? AppColors.emeraldText(isDark)
                            : AppColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                  onTap: cubit.enablePushNotifications,
                ),
                _tile(
                  icon: Icons.install_mobile_rounded,
                  label: s.installAppNavLabel,
                  isDark: isDark,
                  accentColor: AppColors.emeraldText(isDark),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InstallAppScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.sm),

                // Administration
                if (extended) _sectionHeader(s.drawerAdminSection, isDark),
                if (!state.isAdminAuthenticated)
                  _tile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: s.drawerAdminLogin,
                    isDark: isDark,
                    accentColor: AppColors.primaryText(isDark),
                    onTap: () async {
                      if (!AppConfig.isSupabaseConfigured) {
                        await cubit.openAdmin('admin123');
                        return;
                      }
                      await showAdminLoginDialog(
                        context,
                        s,
                        startWithBiometric: true,
                        onVerifyPassword: (pass) =>
                            cubit.openAdmin(pass, showErrorToast: false),
                      );
                    },
                  )
                else ...[
                  _tile(
                    icon: Icons.settings_outlined,
                    label: s.settingsBtn,
                    isDark: isDark,
                    accentColor: AppColors.primaryText(isDark),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (settingsCtx) => AdminSettingsScreen(
                          onOpenManageApts: () => showManageApartmentsDialog(
                            context: settingsCtx,
                            cubit: cubit,
                            state: cubit.state,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _tile(
                    icon: Icons.visibility_outlined,
                    label: s.adminViewsTitle,
                    isDark: isDark,
                    selected: state.selectedNavIndex == 5,
                    accentColor: AppColors.primaryText(isDark),
                    onTap: () {
                      cubit.selectNav(5);
                      cubit.refreshPageViewStats(showBusy: false);
                    },
                  ),
                  _tile(
                    icon: Icons.logout_rounded,
                    label: s.adminLogoutBtn,
                    isDark: isDark,
                    accentColor: AppColors.dangerText(isDark),
                    onTap: cubit.logoutAdmin,
                  ),
                ],
              ],
            ),
          ),

          // Footer: Get MABNA CARE + Contact Manager
          Padding(
            padding: EdgeInsetsDirectional.all(extended ? AppSpacing.md : AppSpacing.sm),
            child: extended
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.isAdminAuthenticated) ...[
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _shareReferral(s.referralShareMessage),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                                    AppColors.emerald.withValues(alpha: isDark ? 0.18 : 0.10),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.rocket_launch_outlined,
                                    size: 15,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      s.getMabnaForBuildingBtn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textPrimary(isDark),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: isDark ? 0.14 : 0.09),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.emerald.withValues(alpha: isDark ? 0.28 : 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _contactManager,
                              icon: Icon(
                                Icons.chat_rounded,
                                size: 16,
                                color: AppColors.emeraldText(isDark),
                              ),
                              label: Text(
                                s.contactManagerBtn,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                              child: Text(
                                'v1.0',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.isAdminAuthenticated)
                        Tooltip(
                          message: s.getMabnaForBuildingBtn,
                          child: IconButton(
                            onPressed: () => _shareReferral(s.referralShareMessage),
                            icon: Icon(
                              Icons.rocket_launch_outlined,
                              color: AppColors.primaryText(isDark),
                            ),
                          ),
                        ),
                      Tooltip(
                        message: s.contactManagerBtn,
                        child: IconButton(
                          onPressed: _contactManager,
                          icon: Icon(
                            Icons.chat_rounded,
                            color: AppColors.emeraldText(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pillBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(isDark),
        ),
      ),
    );
  }

  Widget _tile({
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

    final child = Material(
      color: selected
          ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: extended ? AppSpacing.md : AppSpacing.sm,
            vertical: 11,
          ),
          child: extended
              ? Row(
                  children: [
                    Icon(icon, size: 19, color: fg),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                )
              : Center(child: Icon(icon, size: 21, color: fg)),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: extended ? child : Tooltip(message: label, child: child),
    );
  }
}
