import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/push_notifications.dart';
import '../models/building_models.dart';
import '../services/building_service.dart';
import 'building_state.dart';

class BuildingCubit extends Cubit<BuildingState> {
  final BuildingService _service;
  bool _viewRecordedThisSession = false;
  String _visitorId = '';
  RealtimeChannel? _liveChannel;
  Timer? _realtimeDebounce;
  bool _refreshingSilently = false;

  BuildingCubit(this._service) : super(const BuildingState());

  void _ensureLiveSubscription() {
    if (_liveChannel != null) return;
    _liveChannel = _service.subscribeToLiveUpdates(() {
      if (isClosed) return;
      _realtimeDebounce?.cancel();
      _realtimeDebounce = Timer(const Duration(milliseconds: 1200), () {
        if (!isClosed && !state.busy && !state.isAdminOpen) {
          unawaited(refreshData(fromRealtime: true));
        }
      });
    });
  }

  @override
  Future<void> close() async {
    _realtimeDebounce?.cancel();
    await _service.unsubscribeLiveUpdates(_liveChannel);
    _liveChannel = null;
    return super.close();
  }

  Future<T> _withBusy<T>(Future<T> Function() action) async {
    emit(state.copyWith(busy: true));
    try {
      return await action();
    } finally {
      emit(state.copyWith(busy: false));
    }
  }

  Future<void> loadData({int? preserveMonthIndex}) async {
    emit(state.copyWith(loading: true));
    try {
      late final BuildingDataState data;
      try {
        data = await _service.fetchAll().timeout(const Duration(seconds: 15));
      } catch (_) {
        // Silent 1-time auto-retry for transient server/DNS blips
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        data = await _service.fetchAll().timeout(const Duration(seconds: 15));
      }
      final posts = await _service.fetchFeedbackPosts().timeout(const Duration(seconds: 12));
      int targetIdx = preserveMonthIndex ?? state.selectedMonthIndex;
      if (preserveMonthIndex == null && state.months.isEmpty) {
        final novIndex = data.months.indexWhere((m) => m.monthNum == 11);
        targetIdx = novIndex >= 0
            ? novIndex
            : (data.months.isNotEmpty ? data.months.length - 1 : 0);
      }
      if (targetIdx >= data.months.length) {
        targetIdx = data.months.isNotEmpty ? data.months.length - 1 : 0;
      }

      int? savedAptNum = state.myAptNum;
      String? savedAptPass = state.savedAptPass;
      bool isAdminAuthed = state.isAdminAuthenticated;
      String adminPass = state.adminPass;
      String visitorId = _visitorId;
      Set<String> readNotifIds = state.readNotificationIds;
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(milliseconds: 250),
        );
        savedAptNum = prefs.getInt('my_apt_num');
        savedAptPass = savedAptNum != null ? prefs.getString('my_apt_pass') : null;
        final savedRead = prefs.getStringList('read_notif_ids');
        if (savedRead != null) {
          readNotifIds = savedRead.toSet();
        }
        visitorId = prefs.getString('visitor_id') ?? '';
        if (visitorId.isEmpty) {
          final rnd = Random().nextInt(999999);
          visitorId = 'v_${DateTime.now().microsecondsSinceEpoch}_$rnd';
          await prefs.setString('visitor_id', visitorId);
        }
        final savedAdminPass = prefs.getString('admin_pass');
        if (savedAdminPass != null && savedAdminPass.isNotEmpty) {
          isAdminAuthed = true;
          adminPass = savedAdminPass;
          try {
            final err = await _service
                .verifyAdminPass(savedAdminPass)
                .timeout(const Duration(seconds: 6), onTimeout: () => null);
            if (err == 'err_wrong_admin_pass' ||
                err == 'كلمة سر المدير غير صحيحة' ||
                err == 'كلمة سر المسؤول غير صحيحة') {
              await prefs.remove('admin_pass');
              isAdminAuthed = false;
              adminPass = '';
            }
          } catch (_) {}
        }
      } catch (_) {}

      _visitorId = visitorId.isNotEmpty
          ? visitorId
          : 'v_${DateTime.now().microsecondsSinceEpoch}';
      if (!_viewRecordedThisSession) {
        _viewRecordedThisSession = true;
        unawaited(_service.recordPageView(_visitorId));
      }

      PageViewStats? viewStats = state.pageViewStats;
      if (isAdminAuthed) {
        viewStats = await _service.fetchPageViewStatsAsAdmin(adminPass);
      }
      final notifs = await _service
          .fetchAppNotifications(
            adminPass: isAdminAuthed ? adminPass : null,
            aptNum: savedAptNum,
          )
          .timeout(const Duration(seconds: 10), onTimeout: () => state.notifications);
      final polls = await _service
          .fetchBuildingPolls()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.buildingPolls);
      final ratings = await _service
          .fetchAppRatings()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.appRatings);
      final arrears = await _service
          .fetchEmergencyArrears()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.emergencyArrears);
      final closedAptNums = await _service
          .fetchClosedAptNums()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.closedAptNums);
      final specialFees = await _service
          .fetchSpecialAptFees()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.specialAptFees);
      final profiles = await _service
          .fetchApartmentProfiles(
            adminPass: isAdminAuthed ? adminPass : null,
            aptNum: savedAptNum,
            passcode: savedAptPass,
          )
          .timeout(const Duration(seconds: 10), onTimeout: () => state.apartmentProfiles);

      emit(state.copyWith(
        loading: false,
        isAdminAuthenticated: isAdminAuthed,
        adminPass: adminPass,
        baseEmergency: data.baseEmergencyFund,
        months: data.months,
        apartmentNames: data.apartmentNames,
        selectedMonthIndex: targetIdx,
        feedbackPosts: posts,
        myAptNum: () => savedAptNum,
        savedAptPass: () => savedAptPass,
        announcement: data.announcement,
        emergencyTransactions: data.emergencyTransactions,
        pageViewStats: () => viewStats,
        requireAptPassOnOpen: data.requireAptPassOnOpen,
        buildingContacts: data.buildingContacts,
        apartmentHasPasscode: data.apartmentHasPasscode,
        notifications: notifs,
        readNotificationIds: readNotifIds,
        buildingPolls: polls,
        appRatings: ratings,
        emergencyArrears: arrears,
        closedAptNums: closedAptNums,
        specialAptFees: specialFees,
        apartmentProfiles: profiles,
      ));
      _ensureLiveSubscription();
      unawaited(syncPushTokenIfGranted());
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        feedbackMessage: () => state.s.errLoadData('$e'),
        feedbackIsError: true,
      ));
    }
  }

  /// Smooth silent refresh used by Pull-to-Refresh and Supabase Realtime live sync.
  Future<void> refreshData({bool fromRealtime = false}) async {
    if (_refreshingSilently || isClosed) return;
    if (fromRealtime && (state.loading || state.busy || state.isAdminOpen)) return;
    _refreshingSilently = true;
    try {
      final data = await _service.fetchAll().timeout(const Duration(seconds: 15));
      final posts = await _service
          .fetchFeedbackPosts()
          .timeout(const Duration(seconds: 12), onTimeout: () => state.feedbackPosts);
      final notifs = await _service
          .fetchAppNotifications(
            adminPass: state.isAdminAuthenticated ? state.adminPass : null,
            aptNum: state.myAptNum,
          )
          .timeout(const Duration(seconds: 10), onTimeout: () => state.notifications);
      final polls = await _service
          .fetchBuildingPolls()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.buildingPolls);
      final ratings = await _service
          .fetchAppRatings()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.appRatings);
      final arrears = await _service
          .fetchEmergencyArrears()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.emergencyArrears);
      final closedAptNums = await _service
          .fetchClosedAptNums()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.closedAptNums);
      final specialFees = await _service
          .fetchSpecialAptFees()
          .timeout(const Duration(seconds: 10), onTimeout: () => state.specialAptFees);
      final profiles = await _service
          .fetchApartmentProfiles(
            adminPass: state.isAdminAuthenticated ? state.adminPass : null,
            aptNum: state.myAptNum,
            passcode: state.savedAptPass,
          )
          .timeout(const Duration(seconds: 10), onTimeout: () => state.apartmentProfiles);
      if (isClosed) return;

      final targetIdx = data.months.isEmpty
          ? 0
          : state.selectedMonthIndex.clamp(0, data.months.length - 1);

      emit(state.copyWith(
        baseEmergency: data.baseEmergencyFund,
        months: data.months,
        apartmentNames: data.apartmentNames,
        selectedMonthIndex: targetIdx,
        feedbackPosts: posts,
        announcement: data.announcement,
        emergencyTransactions: data.emergencyTransactions,
        requireAptPassOnOpen: data.requireAptPassOnOpen,
        buildingContacts: data.buildingContacts,
        apartmentHasPasscode: data.apartmentHasPasscode,
        notifications: notifs,
        buildingPolls: polls,
        appRatings: ratings,
        emergencyArrears: arrears,
        closedAptNums: closedAptNums,
        specialAptFees: specialFees,
        apartmentProfiles: profiles,
      ));
    } catch (_) {
      // Keep existing UI state smoothly on transient background refresh error
    } finally {
      _refreshingSilently = false;
    }
  }

  String _localizeError(String err) {
    final s = state.s;
    if (err.startsWith('err_wrong_apt_pass_hint:')) {
      final hint = err.substring('err_wrong_apt_pass_hint:'.length);
      return s.errWrongAptPassHint(hint);
    }
    switch (err) {
      case 'err_wrong_admin_pass':
      case 'كلمة سر المدير غير صحيحة':
      case 'كلمة سر المسؤول غير صحيحة':
        return s.errWrongAdminPass;
      case 'err_wrong_apt_pass':
      case 'كلمة سر الشقة غير صحيحة':
        return s.errWrongAptPass;
      case 'err_payment_failed':
        return s.errPaymentFailed;
      case 'err_cancel_failed':
        return s.errCancelFailed;
      case 'err_apt_load_failed':
        return s.errAptLoadFailed;
      case 'err_apt_save_failed':
        return s.errAptSaveFailed;
      case 'err_empty_message':
        return s.errEmptyMessage;
      case 'err_submit_failed':
        return s.errSubmitFailed;
      case 'err_delete_failed':
        return s.errDeleteFailed;
      case 'err_cannot_delete_last_month':
        return s.errCannotDeleteLastMonth;
      case 'err_pass_too_short':
        return s.errPassTooShort;
      case 'err_pass_already_set':
        return s.errPassAlreadySet;
      default:
        return err;
    }
  }

  void selectMonth(int index) {
    emit(state.copyWith(
      selectedMonthIndex: index,
      copiedPreview: () => null,
    ));
  }

  void selectNav(int index) {
    emit(state.copyWith(selectedNavIndex: index));
  }

  Future<bool> submitFeedbackPost({
    required String type,
    required String message,
    int? aptNum,
    String? passcode,
  }) async {
    if (!state.canResidentMutate) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errResidentAuthRequired}',
        feedbackIsError: true,
      ));
      return false;
    }
    final authorLabel = aptNum != null ? state.aptLabel(aptNum) : null;
    final err = await _service.submitFeedbackPost(
      type: type,
      message: message,
      aptNum: aptNum,
      passcode: passcode,
      authorLabel: authorLabel,
      authAptNum: state.myAptNum,
      authPasscode: state.savedAptPass,
      adminPass: state.isAdminAuthenticated ? state.adminPass : null,
    );
    if (err != null) {
      if (aptNum != null &&
          aptNum == state.myAptNum &&
          (err == 'err_wrong_apt_pass' || err.startsWith('err_wrong_apt_pass_hint:'))) {
        await _clearSavedAptPass();
      }
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    if (aptNum != null && passcode != null && passcode.trim().isNotEmpty) {
      await _saveAptSession(aptNum, passcode.trim());
    }
    final posts = await _service.fetchFeedbackPosts();
    emit(state.copyWith(
      feedbackPosts: posts,
      feedbackMessage: () => state.s.postAddedToast,
      feedbackIsError: false,
    ));
    // Auto-notify all residents (fire-and-forget)
    final preview = message.trim();
    final senderPrefix = authorLabel != null ? '$authorLabel: ' : '';
    _triggerAutoPush(
      title: state.s.pushAutoFeedbackTitle,
      body: '$senderPrefix$preview',
      audience: 'all',
      eventType: 'feedback_submitted',
    );
    return true;
  }

  Future<void> deleteFeedbackPost(String id) async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.deleteFeedbackPost(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final posts = await _service.fetchFeedbackPosts();
      emit(state.copyWith(feedbackPosts: posts));
    });
  }

  Future<bool> openAdmin(String pass, {bool showErrorToast = true}) async {
    bool ok = false;
    await _withBusy(() async {
      final clean = pass.trim();
      final err = await _service.verifyAdminPass(clean);
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: showErrorToast ? () => '❌ ${_localizeError(err)}' : null,
          feedbackIsError: showErrorToast ? true : state.feedbackIsError,
          isAdminOpen: false,
        ));
        return;
      }
      ok = true;
      emit(state.copyWith(
        adminPass: clean,
        isAdminAuthenticated: true,
        isAdminOpen: true,
        selectedNavIndex: 0,
      ));
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_pass', clean);
      } catch (_) {}
      unawaited(() async {
        final viewStats = await _service.fetchPageViewStatsAsAdmin(clean);
        final notifs = await _service.fetchAppNotifications(
          adminPass: clean,
          aptNum: state.myAptNum,
        );
        emit(state.copyWith(
          pageViewStats: () => viewStats,
          notifications: notifs,
        ));
      }());
      unawaited(syncPushTokenIfGranted());
    });
    return ok;
  }

  void toggleAdminEditMode() {
    if (!state.isAdminAuthenticated) return;
    final nextOpen = !state.isAdminOpen;
    emit(state.copyWith(isAdminOpen: nextOpen));
    if (nextOpen) {
      unawaited(refreshPageViewStats(showBusy: false));
    }
  }

  Future<void> refreshPageViewStats({bool showBusy = true}) async {
    if (!state.isAdminAuthenticated) return;
    Future<void> run() async {
      final stats = await _service.fetchPageViewStatsAsAdmin(state.adminPass);
      if (stats != null) {
        emit(state.copyWith(pageViewStats: () => stats));
      }
    }

    if (showBusy) {
      await _withBusy(run);
    } else {
      await run();
    }
  }

  Future<void> setRequireAptPassOnOpen(bool enabled) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final prev = state.requireAptPassOnOpen;
      emit(state.copyWith(requireAptPassOnOpen: enabled));
      final err = await _service.setRequireAptPassOnOpenAsAdmin(
        adminPass: state.adminPass,
        enabled: enabled,
      );
      if (err != null) {
        emit(state.copyWith(
          requireAptPassOnOpen: prev,
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
      }
    });
  }

  Future<void> logoutAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_pass');
    } catch (_) {}
    final notifs = await _service.fetchAppNotifications(aptNum: state.myAptNum);
    emit(state.copyWith(
      isAdminAuthenticated: false,
      isAdminOpen: false,
      selectedNavIndex: state.selectedNavIndex == 5 ? 0 : state.selectedNavIndex,
      pageViewStats: () => null,
      notifications: notifs,
    ));
  }

  Future<String?> changeAdminPassword({
    required String currentPass,
    required String newPass,
  }) async {
    if (!state.isAdminAuthenticated) return state.s.errWrongAdminPass;
    final cleanCur = currentPass.trim();
    final cleanNew = newPass.trim();
    if (cleanNew.length < 4) return state.s.errPassTooShort;

    String? localizedErr;
    await _withBusy(() async {
      final err = await _service.changeAdminPassword(
        currentPass: cleanCur,
        newPass: cleanNew,
      );
      if (err != null) {
        localizedErr = _localizeError(err);
        return;
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_pass', cleanNew);
      } catch (_) {}
      emit(state.copyWith(
        adminPass: cleanNew,
        feedbackMessage: () => state.s.changeAdminPassSuccessToast,
        feedbackIsError: false,
      ));
    });
    return localizedErr;
  }

  void setHighlight(String? key) {
    emit(state.copyWith(highlightedKey: () => key));
  }

  void setLocale(String localeCode) {
    emit(state.copyWith(localeCode: localeCode, copiedPreview: () => null));
  }

  void toggleTheme() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void clearFeedback() {
    emit(state.copyWith(feedbackMessage: () => null));
  }

  void setCopiedPreview(String? text) {
    emit(state.copyWith(
      copiedPreview: () => text,
      feedbackMessage: text != null ? () => state.s.copiedToast : null,
      feedbackIsError: false,
    ));
  }

  void updateCurrentMonthFields({
    required double water,
    required double elec,
    required double elev,
    required double clean,
    required int aptsCount,
    double? forEmerg,
    double? baseEmergency,
    int? dueDay,
  }) {
    final m = state.currentMonth;
    if (m == null) return;
    m.water = water;
    m.elec = elec;
    m.elev = elev;
    m.clean = clean;
    if (forEmerg != null) {
      m.forEmerg = forEmerg;
    }
    m.aptsCount = aptsCount.clamp(1, 50);
    if (dueDay != null) {
      m.dueDay = dueDay.clamp(0, 31);
    }

    emit(state.copyWith(
      baseEmergency: baseEmergency ?? state.baseEmergency,
      months: List<MonthBill>.from(state.months),
    ));
  }

  Future<void> saveAdminChanges() async {
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      emit(state.copyWith(
        feedbackMessage: () => err != null ? '❌ ${_localizeError(err)}' : state.s.monthSavedToast,
        feedbackIsError: err != null,
      ));
    });
  }

  Future<void> addCustomExpense({
    required String name,
    required double amount,
  }) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    final cleanName = name.trim();
    if (m == null || cleanName.isEmpty) return;

    final item = CustomExpenseItem(
      id: 'ce_${DateTime.now().microsecondsSinceEpoch}',
      name: cleanName,
      amount: amount < 0 ? 0 : amount,
    );
    m.customExpenses.add(item);
    emit(state.copyWith(months: List<MonthBill>.from(state.months)));

    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      if (err != null) {
        m.customExpenses.removeWhere((e) => e.id == item.id);
        emit(state.copyWith(
          months: List<MonthBill>.from(state.months),
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () => state.s.customExpenseAddedToast,
        feedbackIsError: false,
      ));
    });
  }

  void updateCustomExpenseAmount(String id, double amount) {
    final m = state.currentMonth;
    if (m == null) return;
    for (final item in m.customExpenses) {
      if (item.id == id) {
        item.amount = amount < 0 ? 0 : amount;
        break;
      }
    }
    emit(state.copyWith(months: List<MonthBill>.from(state.months)));
  }

  Future<void> removeCustomExpense(String id) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    final idx = m.customExpenses.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final removed = m.customExpenses.removeAt(idx);
    emit(state.copyWith(months: List<MonthBill>.from(state.months)));

    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      if (err != null) {
        m.customExpenses.insert(idx, removed);
        emit(state.copyWith(
          months: List<MonthBill>.from(state.months),
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () => state.s.customExpenseRemovedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> renameCustomExpense(String id, String newName) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    final cleanName = newName.trim();
    if (m == null || cleanName.isEmpty) return;
    final idx = m.customExpenses.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final prevName = m.customExpenses[idx].name;
    m.customExpenses[idx].name = cleanName;
    emit(state.copyWith(months: List<MonthBill>.from(state.months)));

    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      if (err != null) {
        m.customExpenses[idx].name = prevName;
        emit(state.copyWith(
          months: List<MonthBill>.from(state.months),
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () => state.s.expenseRenamedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> renameCoreExpense(String key, String newName) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    final cleanName = newName.trim();
    if (m == null || cleanName.isEmpty) return;
    final prevLabel = m.coreLabels[key];
    m.coreLabels[key] = cleanName;
    emit(state.copyWith(months: List<MonthBill>.from(state.months)));

    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      if (err != null) {
        if (prevLabel == null) {
          m.coreLabels.remove(key);
        } else {
          m.coreLabels[key] = prevLabel;
        }
        emit(state.copyWith(
          months: List<MonthBill>.from(state.months),
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () => state.s.expenseRenamedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> removeCoreExpense(String key) async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    final prevAmount = switch (key) {
      'water' => m.water,
      'elec' => m.elec,
      'elev' => m.elev,
      'clean' => m.clean,
      _ => 0.0,
    };
    switch (key) {
      case 'water':
        m.water = 0;
      case 'elec':
        m.elec = 0;
      case 'elev':
        m.elev = 0;
      case 'clean':
        m.clean = 0;
    }
    m.hiddenCoreKeys.add(key);
    emit(state.copyWith(months: List<MonthBill>.from(state.months)));

    await _withBusy(() async {
      final err = await _service.updateMonthAsAdmin(
        adminPass: state.adminPass,
        month: m,
        baseEmergency: state.baseEmergency,
      );
      if (err != null) {
        m.hiddenCoreKeys.remove(key);
        switch (key) {
          case 'water':
            m.water = prevAmount;
          case 'elec':
            m.elec = prevAmount;
          case 'elev':
            m.elev = prevAmount;
          case 'clean':
            m.clean = prevAmount;
        }
        emit(state.copyWith(
          months: List<MonthBill>.from(state.months),
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () => state.s.customExpenseRemovedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> addNextMonth() async {
    if (!state.isAdminOpen) return;
    await _withBusy(() async {
      final err = await _service.addNextMonthAsAdmin(state.adminPass);
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.months.length);
      final added = state.currentMonth;
      final msg = added != null
          ? state.s.monthAddedNamedToast(
              localizedMonthName(added.monthNum, state.localeCode == 'ar'),
              added.monthNum,
              added.yearNum,
            )
          : state.s.monthAddedToast;
      emit(state.copyWith(
        feedbackMessage: () => msg,
        feedbackIsError: false,
      ));
      if (added != null) {
        final monthLabel =
            '${localizedMonthName(added.monthNum, state.localeCode == 'ar')} (${added.monthNum}/${added.yearNum})';
        _triggerAutoPush(
          title: state.s.pushAutoNewMonthTitle,
          body: state.s.pushAutoNewMonthBody(monthLabel),
          audience: 'all',
          adminPass: state.adminPass,
          eventType: 'new_month',
        );
      }
    });
  }

  Future<void> deleteCurrentMonth() async {
    if (!state.isAdminOpen) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.deleteMonthAsAdmin(
        adminPass: state.adminPass,
        monthId: m.id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final nextIdx = state.selectedMonthIndex > 0 ? state.selectedMonthIndex - 1 : 0;
      await loadData(preserveMonthIndex: nextIdx);
      emit(state.copyWith(
        feedbackMessage: () => state.s.monthDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<String?> submitPayment({
    required int aptNum,
    required String passcode,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    final m = state.currentMonth;
    if (m == null) return state.s.errNoMonth;
    final err = await _service.submitApartmentPayment(
      month: m,
      aptNum: aptNum,
      passcode: passcode,
      imageBytes: imageBytes,
      fileName: fileName,
    );
    if (err == null) {
      await _saveAptSession(aptNum, passcode.trim());
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      // Auto-notify all residents that an apartment paid
      _triggerAutoPush(
        title: state.s.pushAutoPaymentTitle,
        body: state.s.pushAutoPaymentBody(state.aptLabel(aptNum)),
        audience: 'all',
        eventType: 'payment_uploaded',
      );
      return null;
    }
    if (aptNum == state.myAptNum &&
        (err == 'err_wrong_apt_pass' || err.startsWith('err_wrong_apt_pass_hint:'))) {
      await _clearSavedAptPass();
    }
    return _localizeError(err);
  }

  Future<void> cancelPayment(int aptNum) async {
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.cancelPaymentAsAdmin(
        adminPass: state.adminPass,
        month: m,
        aptNum: aptNum,
      );
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () => err != null ? '❌ ${_localizeError(err)}' : state.s.paymentCancelledToast,
        feedbackIsError: err != null,
      ));
    });
  }

  Future<bool> cancelOwnPayment(int aptNum) async {
    final m = state.currentMonth;
    if (m == null) return false;
    bool ok = false;
    await _withBusy(() async {
      final err = await _service.cancelPaymentAsResident(
        month: m,
        aptNum: aptNum,
        passcode: state.savedAptPass ?? '',
      );
      ok = err == null;
      emit(state.copyWith(
        months: List<MonthBill>.from(state.months),
        feedbackMessage: () =>
            err != null ? '❌ ${_localizeError(err)}' : state.s.paymentReceiptDeletedToast,
        feedbackIsError: err != null,
      ));
    });
    return ok;
  }

  Future<({List<ApartmentInfo>? apartments, String? error})> fetchAdminApartments() async {
    final m = state.currentMonth;
    if (m == null) {
      return (apartments: null, error: state.s.errNoMonth);
    }
    final closed = state.closedAptNums;
    final maxClosed =
        closed.isEmpty ? 0 : closed.reduce((a, b) => a > b ? a : b);
    final totalApts = (m.aptsCount + closed.length) > maxClosed
        ? (m.aptsCount + closed.length)
        : maxClosed;
    final res = await _service.fetchAdminApartments(
      adminPass: state.adminPass,
      aptsCount: totalApts,
    );
    return (
      apartments: res.apartments,
      error: res.error != null ? _localizeError(res.error!) : null,
    );
  }

  Future<void> saveAllApartments({
    required List<ApartmentInfo> apts,
    required Map<int, String> names,
    required Map<int, String> passcodes,
  }) async {
    String? firstErr;
    for (final a in apts) {
      final err = await _service.updateApartmentAsAdmin(
        adminPass: state.adminPass,
        aptNum: a.aptNum,
        displayName: names[a.aptNum] ?? '',
        passcode: passcodes[a.aptNum] ?? '',
      );
      if (err != null) {
        firstErr = err;
        break;
      }
    }
    await loadData(preserveMonthIndex: state.selectedMonthIndex);
    emit(state.copyWith(
      feedbackMessage: () => firstErr != null ? '❌ ${_localizeError(firstErr)}' : state.s.aptsSavedToast,
      feedbackIsError: firstErr != null,
    ));
  }

  String buildWhatsAppMessage() {
    final m = state.currentMonth;
    if (m == null) return '';

    final closedSet = state.closedAptNums.toSet();
    final maxClosed =
        closedSet.isEmpty ? 0 : closedSet.reduce((a, b) => a > b ? a : b);
    final totalApts = (m.aptsCount + closedSet.length) > maxClosed
        ? (m.aptsCount + closedSet.length)
        : maxClosed;
    final paidList = <int>[];
    final unpaidList = <int>[];
    for (int i = 1; i <= totalApts; i++) {
      if (closedSet.contains(i)) continue;
      if (m.payments.containsKey(i)) {
        paidList.add(i);
      } else {
        unpaidList.add(i);
      }
    }
    final pendingSpecialFees =
        state.specialAptFees.where((f) => !f.isPaid).toList()
          ..sort((a, b) => a.aptNum.compareTo(b.aptNum));

    if (state.localeCode == 'en') {
      final lines = <String>[
        'Building Expenses — Month ${m.monthNum}:',
        '------------------',
        '✅ Paid (${paidList.length}/${m.aptsCount}): ${paidList.isEmpty ? 'None yet' : paidList.map(state.aptLabel).join(', ')}',
      ];
      if (unpaidList.isNotEmpty) {
        lines.add('⏳ Remaining (${unpaidList.length}): ${unpaidList.map(state.aptLabel).join(', ')}');
      }
      if (m.extraCharges.isNotEmpty) {
        lines.add('➕ Extra charges:');
        for (final e in m.extraCharges) {
          lines.add('• ${state.aptLabel(e.aptNum)}: +${e.amount.toInt()} EGP (${e.reason})');
        }
      }
      if (pendingSpecialFees.isNotEmpty) {
        lines.add('⚡ Special fees due:');
        for (final f in pendingSpecialFees) {
          final closedTag = closedSet.contains(f.aptNum) ? ' [Closed]' : '';
          lines.add('• ${state.aptLabel(f.aptNum)}$closedTag: ${f.amount.round()} EGP (${f.label})');
        }
      }
      return lines.join('\n');
    }

    final lines = <String>[
      'مصاريف العمارة لشهر ${m.monthNum}:',
      '------------------',
      '✅ تم السداد (${paidList.length} من ${m.aptsCount} شقة): ${paidList.isEmpty ? 'لا يوجد بعد' : paidList.map(state.aptLabel).join('، ')}',
    ];
    if (unpaidList.isNotEmpty) {
      lines.add('⏳ متبقي (${unpaidList.length} شقة): ${unpaidList.map(state.aptLabel).join('، ')}');
    }
    if (m.extraCharges.isNotEmpty) {
      lines.add('➕ رسوم إضافية:');
      for (final e in m.extraCharges) {
        lines.add('• ${state.aptLabel(e.aptNum)}: +${e.amount.toInt()} ج (${e.reason})');
      }
    }
    if (pendingSpecialFees.isNotEmpty) {
      lines.add('⚡ رسوم خاصة مطلوبة:');
      for (final f in pendingSpecialFees) {
        final closedTag = closedSet.contains(f.aptNum) ? ' (شقة مغلقة)' : '';
        lines.add('• ${state.aptLabel(f.aptNum)}$closedTag: ${f.amount.round()} ج (${f.label})');
      }
    }
    return lines.join('\n');
  }

  Future<String?> unlockApartment(int aptNum, String passcode) async {
    final err = await _service.verifyApartmentPasscode(aptNum, passcode);
    if (err != null) {
      return _localizeError(err);
    }
    await _saveAptSession(aptNum, passcode.trim());
    return null;
  }

  Future<String?> setInitialApartmentPasscode(int aptNum, String passcode) async {
    final err = await _service.setInitialApartmentPasscode(aptNum, passcode);
    if (err != null) {
      return _localizeError(err);
    }
    final nextMap = Map<int, bool>.from(state.apartmentHasPasscode);
    nextMap[aptNum] = true;
    emit(state.copyWith(apartmentHasPasscode: nextMap));
    await _saveAptSession(aptNum, passcode.trim());
    _triggerAutoPush(
      title: state.s.pushAutoAptPassSetTitle,
      body: state.s.pushAutoAptPassSetBody(state.aptLabel(aptNum)),
      audience: 'admins',
      eventType: 'apt_passcode_set',
    );
    return null;
  }

  Future<bool> resetAllApartmentPasscodes() async {
    if (!state.isAdminAuthenticated) return false;
    return _withBusy(() async {
      final err = await _service.resetAllApartmentPasscodesAsAdmin(
        state.adminPass,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      await _clearSavedAptPass();
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.allPasswordsResetToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<void> _saveAptSession(int aptNum, String passcode) async {
    emit(state.copyWith(
      myAptNum: () => aptNum,
      savedAptPass: () => passcode,
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('my_apt_num', aptNum);
      await prefs.setString('my_apt_pass', passcode);
    } catch (_) {}
  }

  Future<void> _clearSavedAptPass() async {
    emit(state.copyWith(savedAptPass: () => null));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('my_apt_pass');
    } catch (_) {}
  }

  Future<void> setMyApt(int? aptNum) async {
    final changed = aptNum != state.myAptNum;
    emit(state.copyWith(
      myAptNum: () => aptNum,
      savedAptPass: changed ? () => null : null,
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      if (aptNum == null) {
        await prefs.remove('my_apt_num');
        await prefs.remove('my_apt_pass');
      } else {
        await prefs.setInt('my_apt_num', aptNum);
        if (changed) {
          await prefs.remove('my_apt_pass');
        }
      }
    } catch (_) {}
  }

  Future<void> saveAnnouncement(String text) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.saveAnnouncement(
        adminPass: state.adminPass,
        announcement: text,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      emit(state.copyWith(
        announcement: text.trim(),
        feedbackMessage: () => state.s.monthSavedToast,
        feedbackIsError: false,
      ));
      if (text.trim().isNotEmpty) {
        _triggerAutoPush(
          title: state.s.pushAutoAnnouncementTitle,
          body: text.trim(),
          audience: 'all',
          adminPass: state.adminPass,
          eventType: 'announcement',
        );
      }
    });
  }

  /// Requests browser push notification permission and registers the FCM token.
  Future<bool> enablePushNotifications() async {
    var ok = false;
    await _withBusy(() async {
      final token = await requestPushToken(silentOnly: false);
      if (token == null || token.isEmpty) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${state.s.pushBlockedToast}',
          feedbackIsError: true,
        ));
        return;
      }
      final saved = await _service.registerPushToken(
        token: token,
        aptNum: state.myAptNum,
        isAdmin: state.isAdminAuthenticated,
      );
      ok = saved;
      emit(state.copyWith(
        feedbackMessage: () => saved
            ? state.s.pushEnabledToast
            : '❌ ${state.s.pushBlockedToast}',
        feedbackIsError: !saved,
      ));
    });
    return ok;
  }

  /// Automatically requests push permission on app open (or syncs if already granted)
  /// and registers the device token in Supabase.
  Future<void> syncPushTokenIfGranted() async {
    try {
      final token = await autoPromptPushTokenOnOpen();
      if (token == null || token.isEmpty) return;
      await _service.registerPushToken(
        token: token,
        aptNum: state.myAptNum,
        isAdmin: state.isAdminAuthenticated,
      );
      if (!isClosed) {
        emit(state.copyWith());
      }
    } catch (_) {}
  }

  /// Fire-and-forget automatic push notification trigger.
  void _triggerAutoPush({
    required String title,
    required String body,
    required String audience,
    String? adminPass,
    String? eventType,
  }) {
    _service
        .sendPushNotification(
          title: title,
          body: body,
          audience: audience,
          adminPass: adminPass ??
              (state.isAdminAuthenticated ? state.adminPass : null),
          aptNum: state.myAptNum,
          aptPasscode: state.savedAptPass,
          eventType: eventType,
        )
        .then((_) => refreshNotifications())
        .catchError((_) {});
  }

  Future<void> refreshNotifications() async {
    try {
      final notifs = await _service.fetchAppNotifications(
        adminPass: state.isAdminAuthenticated ? state.adminPass : null,
        aptNum: state.myAptNum,
      );
      if (!isClosed) {
        emit(state.copyWith(notifications: notifs));
      }
    } catch (_) {}
  }

  Future<void> markNotificationRead(String id) async {
    if (state.readNotificationIds.contains(id)) return;
    final updated = {...state.readNotificationIds, id};
    emit(state.copyWith(readNotificationIds: updated));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notif_ids', updated.toList());
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    if (state.notifications.isEmpty) return;
    final updated = {
      ...state.readNotificationIds,
      ...state.notifications.map((n) => n.id),
    };
    emit(state.copyWith(readNotificationIds: updated));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notif_ids', updated.toList());
    } catch (_) {}
  }

  Future<bool> deleteAppNotification(String id) async {
    if (!state.isAdminAuthenticated) return false;
    final err = await _service.deleteAppNotificationAsAdmin(
      adminPass: state.adminPass,
      id: id,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    final notifs = await _service.fetchAppNotifications(
      adminPass: state.adminPass,
    );
    emit(state.copyWith(notifications: notifs));
    return true;
  }

  Future<Set<int>> fetchPushRegisteredApts() async {
    if (!state.isAdminAuthenticated) return const {};
    return _service.fetchPushRegisteredApts(state.adminPass);
  }

  /// Sends a manual broadcast notification from Admin Settings.
  /// Supports `audience`: `'admins'` (default test), `'all'`, or `'apartments'` with `targetAptNums`.
  Future<bool> sendManualPushNotification({
    required String title,
    required String body,
    String audience = 'admins',
    List<int>? targetAptNums,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    final cleanTitle = title.trim();
    final cleanBody = body.trim();
    if (cleanTitle.isEmpty || cleanBody.isEmpty) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errPushFieldsRequired}',
        feedbackIsError: true,
      ));
      return false;
    }

    var success = false;
    await _withBusy(() async {
      final res = await _service.sendPushNotification(
        title: cleanTitle,
        body: cleanBody,
        audience: audience,
        targetAptNums: targetAptNums,
        adminPass: state.adminPass,
        eventType: audience == 'admins'
            ? 'admin_test'
            : (audience == 'apartments' ? 'payment_reminder' : 'manual_broadcast'),
      );
      if (res.notConfigured) {
        emit(state.copyWith(
          feedbackMessage: () => 'ℹ️ ${state.s.pushNotConfiguredToast}',
          feedbackIsError: false,
        ));
        return;
      }
      if (!res.ok) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${state.s.pushSendFailedToast}',
          feedbackIsError: true,
        ));
        return;
      }
      success = true;
      final notifs = await _service.fetchAppNotifications(
        adminPass: state.adminPass,
        aptNum: state.myAptNum,
      );
      emit(state.copyWith(
        notifications: notifs,
        feedbackMessage: () => res.hasRecipients
            ? state.s.pushSentSuccessToast
            : state.s.pushNoDevicesToast,
        feedbackIsError: false,
      ));
    });
    return success;
  }

  Future<bool> addEmergencyTransaction(double amount, String reason) async {
    if (!state.isAdminAuthenticated) return false;
    final err = await _service.addEmergencyTransaction(
      adminPass: state.adminPass,
      amount: amount,
      reason: reason,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    await loadData(preserveMonthIndex: state.selectedMonthIndex);
    return true;
  }

  Future<void> deleteEmergencyTransaction(String id) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.deleteEmergencyTransaction(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }

  Future<bool> updateFeedbackStatus({
    required String id,
    required String status,
    String? adminReply,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    return _withBusy(() async {
      final err = await _service.updateFeedbackPostStatus(
        adminPass: state.adminPass,
        id: id,
        status: status,
        adminReply: adminReply,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      final posts = await _service.fetchFeedbackPosts();
      emit(state.copyWith(
        feedbackPosts: posts,
        feedbackMessage: () => state.s.monthSavedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<bool> addExtraCharges({
    required List<int> aptNums,
    required double amount,
    required String reason,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    final m = state.currentMonth;
    if (m == null) return false;
    final err = await _service.addExtraChargesAsAdmin(
      adminPass: state.adminPass,
      monthId: m.id,
      aptNums: aptNums,
      amount: amount,
      reason: reason,
    );
    if (err != null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${_localizeError(err)}',
        feedbackIsError: true,
      ));
      return false;
    }
    await loadData(preserveMonthIndex: state.selectedMonthIndex);
    emit(state.copyWith(
      feedbackMessage: () => state.s.extraChargeAddedToast,
      feedbackIsError: false,
    ));
    return true;
  }

  Future<void> deleteExtraCharge(String id) async {
    if (!state.isAdminAuthenticated) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.deleteExtraChargeAsAdmin(
        adminPass: state.adminPass,
        monthId: m.id,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }

  Future<void> setUtilityReceipt({
    required String utility,
    Uint8List? imageBytes,
  }) async {
    if (!state.isAdminAuthenticated) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.setUtilityReceiptAsAdmin(
        adminPass: state.adminPass,
        month: m,
        utility: utility,
        imageBytes: imageBytes,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => imageBytes != null
            ? state.s.utilityReceiptSavedToast
            : state.s.utilityReceiptRemovedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<bool> addBuildingContact({
    required String name,
    required String roleDesc,
    required String phone,
    String category = 'other',
    int? addedByApt,
    String? addedByLabel,
    Uint8List? cardImageBytes,
  }) async {
    if (!state.canResidentMutate) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errResidentAuthRequired}',
        feedbackIsError: true,
      ));
      return false;
    }
    return _withBusy(() async {
      final err = await _service.addBuildingContact(
        name: name,
        roleDesc: roleDesc,
        phone: phone,
        category: category,
        addedByApt: addedByApt,
        addedByLabel: addedByLabel,
        cardImageBytes: cardImageBytes,
        passcode: state.savedAptPass,
        adminPass: state.isAdminAuthenticated ? state.adminPass : null,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.contactAddedToast,
        feedbackIsError: false,
      ));
      _triggerAutoPush(
        title: state.s.pushAutoContactAddedTitle,
        body: state.s.pushAutoContactAddedBody(name.trim()),
        audience: 'all',
        eventType: 'contact_added',
      );
      return true;
    });
  }

  Future<bool> updateBuildingContact({
    required String id,
    required String name,
    required String roleDesc,
    required String phone,
    String? category,
    Uint8List? newCardImageBytes,
    bool removeCardImage = false,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    return _withBusy(() async {
      final err = await _service.updateBuildingContactAsAdmin(
        adminPass: state.adminPass,
        id: id,
        name: name,
        roleDesc: roleDesc,
        phone: phone,
        category: category,
        newCardImageBytes: newCardImageBytes,
        removeCardImage: removeCardImage,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.contactUpdatedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<void> deleteBuildingContact(String id) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.deleteBuildingContactAsAdmin(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.contactDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> deleteAllExtraCharges() async {
    if (!state.isAdminAuthenticated) return;
    final m = state.currentMonth;
    if (m == null) return;
    await _withBusy(() async {
      final err = await _service.deleteAllExtraChargesAsAdmin(
        adminPass: state.adminPass,
        monthId: m.id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
    });
  }

  Future<bool> createBuildingPoll({
    required String question,
    required List<String> optionTexts,
    bool allowMultiple = false,
    bool showVotersPublicly = true,
    bool notifyResidents = true,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    final cleanQ = question.trim();
    final cleanTexts =
        optionTexts.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    if (cleanQ.isEmpty || cleanTexts.length < 2) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final options = [
      for (int i = 0; i < cleanTexts.length; i++)
        PollOption(id: 'opt_${now}_$i', text: cleanTexts[i]),
    ];

    return _withBusy(() async {
      final err = await _service.createBuildingPollAsAdmin(
        adminPass: state.adminPass,
        question: cleanQ,
        options: options,
        allowMultiple: allowMultiple,
        showVotersPublicly: showVotersPublicly,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      final polls = await _service.fetchBuildingPolls();
      emit(state.copyWith(
        buildingPolls: polls,
        feedbackMessage: () => state.s.pollCreatedToast,
        feedbackIsError: false,
      ));
      if (notifyResidents) {
        _triggerAutoPush(
          title: state.s.pushAutoNewPollTitle,
          body: state.s.pushAutoNewPollBody(cleanQ),
          audience: 'all',
          adminPass: state.adminPass,
          eventType: 'new_poll',
        );
      }
      return true;
    });
  }

  Future<void> togglePollClosed(String pollId, bool isClosed) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.togglePollClosedAsAdmin(
        adminPass: state.adminPass,
        pollId: pollId,
        isClosed: isClosed,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final polls = await _service.fetchBuildingPolls();
      emit(state.copyWith(
        buildingPolls: polls,
        feedbackMessage: () =>
            isClosed ? state.s.pollClosedToast : state.s.pollReopenedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> deleteBuildingPoll(String pollId) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.deleteBuildingPollAsAdmin(
        adminPass: state.adminPass,
        pollId: pollId,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final polls = await _service.fetchBuildingPolls();
      emit(state.copyWith(
        buildingPolls: polls,
        feedbackMessage: () => state.s.pollDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> castPollVote({
    required String pollId,
    required String optionId,
  }) async {
    if (!state.canResidentMutate) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errResidentAuthRequired}',
        feedbackIsError: true,
      ));
      return;
    }
    final aptNum = state.myAptNum;
    if (aptNum == null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errPollLoginAptFirst}',
        feedbackIsError: true,
      ));
      return;
    }
    await _withBusy(() async {
      final err = await _service.castPollVote(
        pollId: pollId,
        aptNum: aptNum,
        optionId: optionId,
        passcode: state.savedAptPass,
        adminPass: state.isAdminAuthenticated ? state.adminPass : null,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final polls = await _service.fetchBuildingPolls();
      emit(state.copyWith(
        buildingPolls: polls,
        feedbackMessage: () => state.s.pollVotedToast,
        feedbackIsError: false,
      ));
      _triggerAutoPush(
        title: state.s.pushAutoPollVotedTitle,
        body: state.s.pushAutoPollVotedBody(state.aptLabel(aptNum)),
        audience: 'all',
        eventType: 'poll_voted',
      );
    });
  }

  Future<bool> submitAppRating({
    required int stars,
    required List<String> tags,
    required String comment,
  }) async {
    if (!state.canResidentMutate) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errResidentAuthRequired}',
        feedbackIsError: true,
      ));
      return false;
    }
    final aptNum = state.myAptNum;
    if (aptNum == null) {
      emit(state.copyWith(
        feedbackMessage: () => '❌ ${state.s.errResidentAuthRequired}',
        feedbackIsError: true,
      ));
      return false;
    }
    return _withBusy(() async {
      final err = await _service.submitAppRating(
        aptNum: aptNum,
        stars: stars,
        tags: tags,
        comment: comment,
        passcode: state.savedAptPass,
        adminPass: state.isAdminAuthenticated ? state.adminPass : null,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      final ratings = await _service.fetchAppRatings();
      emit(state.copyWith(
        appRatings: ratings,
        feedbackMessage: () => state.s.ratingSavedToast,
        feedbackIsError: false,
      ));
      _triggerAutoPush(
        title: state.s.pushAutoNewRatingTitle,
        body: state.s.pushAutoNewRatingBody(state.aptLabel(aptNum), stars),
        audience: 'all',
        eventType: 'app_rating',
      );
      return true;
    });
  }

  Future<void> deleteAppRating(int aptNum) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.deleteAppRatingAsAdmin(
        adminPass: state.adminPass,
        aptNum: aptNum,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final ratings = await _service.fetchAppRatings();
      emit(state.copyWith(
        appRatings: ratings,
        feedbackMessage: () => state.s.ratingDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<bool> addEmergencyArrear({
    required String title,
    required double amount,
    required String details,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    return _withBusy(() async {
      final err = await _service.addEmergencyArrearAsAdmin(
        adminPass: state.adminPass,
        title: title,
        amount: amount,
        details: details,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      final arrears = await _service.fetchEmergencyArrears();
      emit(state.copyWith(
        emergencyArrears: arrears,
        feedbackMessage: () => state.s.emergencyArrearsAddedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<bool> updateEmergencyArrear({
    required String id,
    required String title,
    required double amount,
    required String details,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    return _withBusy(() async {
      final err = await _service.updateEmergencyArrearAsAdmin(
        adminPass: state.adminPass,
        id: id,
        title: title,
        amount: amount,
        details: details,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      final arrears = await _service.fetchEmergencyArrears();
      emit(state.copyWith(
        emergencyArrears: arrears,
        feedbackMessage: () => state.s.emergencyArrearsUpdatedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<void> collectEmergencyArrear(String id) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.collectEmergencyArrearAsAdmin(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.emergencyArrearsCollectedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> deleteEmergencyArrear(String id) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.deleteEmergencyArrearAsAdmin(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final arrears = await _service.fetchEmergencyArrears();
      emit(state.copyWith(
        emergencyArrears: arrears,
        feedbackMessage: () => state.s.emergencyArrearsDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<bool> addSpecialAptFees({
    required List<int> aptNums,
    required String label,
    required double amount,
  }) async {
    if (!state.isAdminAuthenticated) return false;
    return _withBusy(() async {
      final err = await _service.addSpecialAptFeesAsAdmin(
        adminPass: state.adminPass,
        aptNums: aptNums,
        label: label,
        amount: amount,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      final fees = await _service.fetchSpecialAptFees();
      emit(state.copyWith(
        specialAptFees: fees,
        feedbackMessage: () => state.s.specialFeeAddedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<void> collectSpecialAptFee(String id) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.collectSpecialAptFeeAsAdmin(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.specialFeeCollectedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> deleteSpecialAptFee(String id) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.deleteSpecialAptFeeAsAdmin(
        adminPass: state.adminPass,
        id: id,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final fees = await _service.fetchSpecialAptFees();
      emit(state.copyWith(
        specialAptFees: fees,
        feedbackMessage: () => state.s.specialFeeDeletedToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<void> setApartmentClosed(int aptNum, bool isClosed) async {
    if (!state.isAdminAuthenticated) return;
    await _withBusy(() async {
      final err = await _service.setApartmentClosedAsAdmin(
        adminPass: state.adminPass,
        aptNum: aptNum,
        isClosed: isClosed,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return;
      }
      final nextClosed = await _service.fetchClosedAptNums();
      final m = state.currentMonth;
      if (m != null) {
        final maxClosed = nextClosed.isEmpty
            ? 0
            : nextClosed.reduce((a, b) => a > b ? a : b);
        final totalApts =
            [m.aptsCount + state.closedAptNums.length, maxClosed, aptNum]
                .reduce((a, b) => a > b ? a : b);
        final nextActiveCount =
            (totalApts - nextClosed.length).clamp(1, totalApts);
        if (nextActiveCount != m.aptsCount) {
          m.aptsCount = nextActiveCount;
          await _service.updateMonthAsAdmin(
            adminPass: state.adminPass,
            month: m,
            baseEmergency: state.baseEmergency,
          );
        }
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        closedAptNums: nextClosed,
        feedbackMessage: () => isClosed
            ? state.s.aptConvertedToClosedToast
            : state.s.aptConvertedToActiveToast,
        feedbackIsError: false,
      ));
    });
  }

  Future<bool> updateOwnApartmentProfile({
    required int aptNum,
    String? displayName,
    required String floorNum,
    required String phone,
    required bool showPhoneToNeighbors,
    Uint8List? avatarBytes,
    bool removeAvatar = false,
  }) async {
    return _withBusy(() async {
      final err = await _service.updateOwnApartmentProfile(
        aptNum: aptNum,
        passcode: state.savedAptPass ?? '',
        displayName: displayName,
        floorNum: floorNum,
        phone: phone,
        showPhoneToNeighbors: showPhoneToNeighbors,
        adminPass: state.isAdminAuthenticated ? state.adminPass : null,
        avatarBytes: avatarBytes,
        removeAvatar: removeAvatar,
      );
      if (err != null) {
        emit(state.copyWith(
          feedbackMessage: () => '❌ ${_localizeError(err)}',
          feedbackIsError: true,
        ));
        return false;
      }
      await loadData(preserveMonthIndex: state.selectedMonthIndex);
      emit(state.copyWith(
        feedbackMessage: () => state.s.profileSavedToast,
        feedbackIsError: false,
      ));
      return true;
    });
  }

  Future<String?> changeOwnApartmentPasscode({
    required int aptNum,
    required String oldPasscode,
    required String newPasscode,
  }) async {
    String? outErr;
    await _withBusy(() async {
      final err = await _service.changeApartmentPasscode(
        aptNum: aptNum,
        oldPasscode: oldPasscode,
        newPasscode: newPasscode,
      );
      if (err != null) {
        outErr = _localizeError(err);
        return;
      }
      await _saveAptSession(aptNum, newPasscode.trim());
      emit(state.copyWith(
        feedbackMessage: () => state.s.aptPassChangedToast,
        feedbackIsError: false,
      ));
    });
    return outErr;
  }
}
