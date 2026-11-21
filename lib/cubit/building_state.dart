import 'dart:ui';

import '../l10n/app_localizations.dart';
import '../models/building_models.dart';

class BuildingState {
  final bool loading;
  final bool busy;
  final bool isAdminAuthenticated;
  final bool isAdminOpen;
  final String adminPass;
  final double baseEmergency;
  final List<MonthBill> months;
  final Map<int, String> apartmentNames;
  final int selectedMonthIndex;
  final String? highlightedKey;
  final String? copiedPreview;
  final String? feedbackMessage;
  final bool feedbackIsError;
  final String localeCode;
  final bool isDarkMode;
  final int selectedNavIndex;
  final List<FeedbackPost> feedbackPosts;
  final int? myAptNum;
  final String? savedAptPass;
  final String announcement;
  final List<EmergencyTransaction> emergencyTransactions;
  final PageViewStats? pageViewStats;
  final bool requireAptPassOnOpen;
  final List<BuildingContact> buildingContacts;
  final Map<int, bool> apartmentHasPasscode;
  final List<AppNotificationItem> notifications;
  final Set<String> readNotificationIds;
  final List<BuildingPoll> buildingPolls;
  final List<AppRating> appRatings;
  final List<EmergencyArrear> emergencyArrears;
  final List<int> closedAptNums;
  final List<SpecialAptFee> specialAptFees;
  final Map<int, ApartmentProfile> apartmentProfiles;

  const BuildingState({
    this.loading = true,
    this.busy = false,
    this.isAdminAuthenticated = false,
    this.isAdminOpen = false,
    this.adminPass = 'admin123',
    this.baseEmergency = 2550,
    this.months = const [],
    this.apartmentNames = const {},
    this.selectedMonthIndex = 0,
    this.highlightedKey,
    this.copiedPreview,
    this.feedbackMessage,
    this.feedbackIsError = false,
    this.localeCode = 'ar',
    this.isDarkMode = true,
    this.selectedNavIndex = 0,
    this.feedbackPosts = const [],
    this.myAptNum,
    this.savedAptPass,
    this.announcement = '',
    this.emergencyTransactions = const [],
    this.pageViewStats,
    this.requireAptPassOnOpen = true,
    this.buildingContacts = const [],
    this.apartmentHasPasscode = const {},
    this.notifications = const [],
    this.readNotificationIds = const {},
    this.buildingPolls = const [],
    this.appRatings = const [],
    this.emergencyArrears = const [],
    this.closedAptNums = const [14, 15, 16, 17, 18],
    this.specialAptFees = const [],
    this.apartmentProfiles = const {},
  });

  AppLocalizations get s => lookupAppLocalizations(Locale(localeCode));

  double get pendingEmergencyArrearsTotal => emergencyArrears
      .where((a) => !a.isCollected)
      .fold<double>(0, (sum, a) => sum + a.amount);

  int get unreadNotificationsCount =>
      notifications.where((n) => !readNotificationIds.contains(n.id)).length;

  int get openPollsCount => buildingPolls.where((p) => !p.isClosed).length;

  /// True when the current user is allowed to perform resident write actions
  /// (add maintenance contacts, submit complaints/suggestions, vote in polls).
  /// When `requireAptPassOnOpen` is enabled, unverified visitors (e.g. external
  /// demo links) remain strictly read-only until they unlock their apartment
  /// with its passcode or sign in as Admin.
  bool get canResidentMutate {
    if (isAdminAuthenticated) return true;
    if (!requireAptPassOnOpen) return true;
    return myAptNum != null && (savedAptPass ?? '').trim().isNotEmpty;
  }

  MonthBill? get currentMonth =>
      months.isEmpty || selectedMonthIndex >= months.length
          ? null
          : months[selectedMonthIndex];

  String aptLabel(int aptNum) => apartmentNames[aptNum] ?? s.defaultAptName(aptNum);

  BuildingState copyWith({
    bool? loading,
    bool? busy,
    bool? isAdminAuthenticated,
    bool? isAdminOpen,
    String? adminPass,
    double? baseEmergency,
    List<MonthBill>? months,
    Map<int, String>? apartmentNames,
    int? selectedMonthIndex,
    String? Function()? highlightedKey,
    String? Function()? copiedPreview,
    String? Function()? feedbackMessage,
    bool? feedbackIsError,
    String? localeCode,
    bool? isDarkMode,
    int? selectedNavIndex,
    List<FeedbackPost>? feedbackPosts,
    int? Function()? myAptNum,
    String? Function()? savedAptPass,
    String? announcement,
    List<EmergencyTransaction>? emergencyTransactions,
    PageViewStats? Function()? pageViewStats,
    bool? requireAptPassOnOpen,
    List<BuildingContact>? buildingContacts,
    Map<int, bool>? apartmentHasPasscode,
    List<AppNotificationItem>? notifications,
    Set<String>? readNotificationIds,
    List<BuildingPoll>? buildingPolls,
    List<AppRating>? appRatings,
    List<EmergencyArrear>? emergencyArrears,
    List<int>? closedAptNums,
    List<SpecialAptFee>? specialAptFees,
    Map<int, ApartmentProfile>? apartmentProfiles,
  }) {
    return BuildingState(
      loading: loading ?? this.loading,
      busy: busy ?? this.busy,
      isAdminAuthenticated: isAdminAuthenticated ?? this.isAdminAuthenticated,
      isAdminOpen: isAdminOpen ?? this.isAdminOpen,
      adminPass: adminPass ?? this.adminPass,
      baseEmergency: baseEmergency ?? this.baseEmergency,
      months: months ?? this.months,
      apartmentNames: apartmentNames ?? this.apartmentNames,
      selectedMonthIndex: selectedMonthIndex ?? this.selectedMonthIndex,
      highlightedKey: highlightedKey != null ? highlightedKey() : this.highlightedKey,
      copiedPreview: copiedPreview != null ? copiedPreview() : this.copiedPreview,
      feedbackMessage: feedbackMessage != null ? feedbackMessage() : this.feedbackMessage,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      localeCode: localeCode ?? this.localeCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      feedbackPosts: feedbackPosts ?? this.feedbackPosts,
      myAptNum: myAptNum != null ? myAptNum() : this.myAptNum,
      savedAptPass: savedAptPass != null ? savedAptPass() : this.savedAptPass,
      announcement: announcement ?? this.announcement,
      emergencyTransactions: emergencyTransactions ?? this.emergencyTransactions,
      pageViewStats: pageViewStats != null ? pageViewStats() : this.pageViewStats,
      requireAptPassOnOpen: requireAptPassOnOpen ?? this.requireAptPassOnOpen,
      buildingContacts: buildingContacts ?? this.buildingContacts,
      apartmentHasPasscode: apartmentHasPasscode ?? this.apartmentHasPasscode,
      notifications: notifications ?? this.notifications,
      readNotificationIds: readNotificationIds ?? this.readNotificationIds,
      buildingPolls: buildingPolls ?? this.buildingPolls,
      appRatings: appRatings ?? this.appRatings,
      emergencyArrears: emergencyArrears ?? this.emergencyArrears,
      closedAptNums: closedAptNums ?? this.closedAptNums,
      specialAptFees: specialAptFees ?? this.specialAptFees,
      apartmentProfiles: apartmentProfiles ?? this.apartmentProfiles,
    );
  }
}
