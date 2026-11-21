import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../models/building_models.dart';

class BuildingDataState {
  final double baseEmergencyFund;
  final List<MonthBill> months;
  final Map<int, String> apartmentNames;
  final String announcement;
  final List<EmergencyTransaction> emergencyTransactions;
  final bool requireAptPassOnOpen;
  final List<BuildingContact> buildingContacts;
  final Map<int, bool> apartmentHasPasscode;

  BuildingDataState({
    required this.baseEmergencyFund,
    required this.months,
    required this.apartmentNames,
    this.announcement = '',
    this.emergencyTransactions = const [],
    this.requireAptPassOnOpen = true,
    this.buildingContacts = const [],
    this.apartmentHasPasscode = const {},
  });
}

class BuildingService {
  bool get _useSupabase {
    if (!AppConfig.isSupabaseConfigured) return false;
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  RealtimeChannel? subscribeToLiveUpdates(void Function() onRemoteChange) {
    if (!_useSupabase) return null;
    try {
      final client = Supabase.instance.client;
      final channel = client.channel('mabna_live_sync');
      const tables = [
        'months',
        'payments',
        'emergency_transactions',
        'feedback_posts',
        'building_contacts',
        'apartment_extra_charges',
      ];
      for (final table in tables) {
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (_) => onRemoteChange(),
        );
      }
      channel.subscribe();
      return channel;
    } catch (_) {
      return null;
    }
  }

  Future<void> unsubscribeLiveUpdates(RealtimeChannel? channel) async {
    if (!_useSupabase || channel == null) return;
    try {
      await Supabase.instance.client.removeChannel(channel);
    } catch (_) {}
  }

  // Local Demo state (used when Supabase keys are not yet configured or in tests)
  static double _demoBaseEmergency = 2550;
  static String _demoAnnouncement = '';
  static bool _demoRequireAptPassOnOpen = true;
  static final List<EmergencyTransaction> _demoEmergencyTx = [];
  static final List<FeedbackPost> _demoFeedbackPosts = [];
  static final List<({String visitorId, DateTime createdAt})> _demoPageViews = [];
  static final List<AppNotificationItem> _demoNotifications = [];
  static final List<BuildingContact> _demoContacts = [
    BuildingContact(
      id: '1',
      name: 'طوارئ الغاز الطبيعي',
      roleDesc: 'الخط الساخن 24 ساعة',
      phone: '129',
      createdAt: DateTime(2026, 11, 1),
    ),
    BuildingContact(
      id: '2',
      name: 'طوارئ الكهرباء',
      roleDesc: 'الخط الساخن للأعطال',
      phone: '121',
      createdAt: DateTime(2026, 11, 1),
    ),
  ];
  static const List<String> _defaultResidentNames = [
    'أستاذ حازم',
    'د. أبو بكر',
    'أستاذ مصطفى بركة',
    'أستاذ محمد مجدي',
    'أستاذ مروان',
    'أستاذة مروة',
    'أستاذ علاء',
    'د. أحمد خطاب',
    'أستاذ أحمد ياسر',
    'م. مصطفى',
    'أستاذ محمد جمال',
    'م. شيماء',
    'أستاذ معتز',
  ];

  static final Map<int, ApartmentInfo> _demoApartments = {
    for (int i = 1; i <= 30; i++)
      i: ApartmentInfo(
        aptNum: i,
        displayName: i <= _defaultResidentNames.length ? _defaultResidentNames[i - 1] : '',
        passcode: '${1000 + i}',
      ),
  };
  static final List<MonthBill> _demoMonths = [
    MonthBill(id: 7, monthNum: 7, yearNum: 2026, water: 1080, elec: 1500, elev: 400, clean: 240, forEmerg: 0, aptsCount: 13, payments: _archivedPayments(7)),
    MonthBill(id: 8, monthNum: 8, yearNum: 2026, water: 1100, elec: 1590, elev: 400, clean: 240, forEmerg: 50, aptsCount: 13, payments: _archivedPayments(8)),
    MonthBill(id: 9, monthNum: 9, yearNum: 2026, water: 1150, elec: 1620, elev: 400, clean: 240, forEmerg: 100, aptsCount: 13, payments: _archivedPayments(9)),
    MonthBill(id: 10, monthNum: 10, yearNum: 2026, water: 1210, elec: 1700, elev: 400, clean: 240, forEmerg: 90, aptsCount: 13, payments: _archivedPayments(10)),
    MonthBill(
      id: 11,
      monthNum: 11,
      yearNum: 2026,
      water: 1281,
      elec: 1803,
      elev: 400,
      clean: 240,
      forEmerg: 176,
      aptsCount: 13,
      payments: {
        1: PaymentRecord(aptNum: 1, fileName: 'InstaPay_Apt1.jpg', paidAt: DateTime(2026, 11, 14, 20, 15)),
        3: PaymentRecord(aptNum: 3, fileName: 'InstaPay_Apt3.jpg', paidAt: DateTime(2026, 11, 15, 18, 40)),
      },
    ),
    MonthBill(id: 12, monthNum: 12, yearNum: 2026, water: 0, elec: 0, elev: 400, clean: 240, forEmerg: 0, aptsCount: 13),
  ];

  static Map<int, PaymentRecord> _archivedPayments(int monthNum) {
    return {
      for (int i = 1; i <= 13; i++)
        i: PaymentRecord(aptNum: i, fileName: 'مؤرشف.jpg', paidAt: DateTime(2026, monthNum, 10)),
    };
  }

  Future<BuildingDataState> fetchAll() async {
    if (!_useSupabase) {
      return BuildingDataState(
        baseEmergencyFund: _demoBaseEmergency,
        months: _demoMonths,
        apartmentNames: {
          for (final entry in _demoApartments.entries)
            if (entry.value.displayName.trim().isNotEmpty)
              entry.key: entry.value.displayName.trim(),
        },
        announcement: _demoAnnouncement,
        emergencyTransactions: List<EmergencyTransaction>.from(_demoEmergencyTx),
        requireAptPassOnOpen: _demoRequireAptPassOnOpen,
        buildingContacts: List<BuildingContact>.from(_demoContacts),
        apartmentHasPasscode: {
          for (final entry in _demoApartments.entries)
            entry.key: entry.value.passcode.trim().isNotEmpty,
        },
      );
    }

    final client = Supabase.instance.client;
    try {
      await client.rpc('ensure_current_month');
    } catch (_) {
      // Ignore if function not yet deployed
    }
    final baseEmergResp = await client.rpc('get_base_emergency_fund');
    final baseEmerg = (baseEmergResp as num?)?.toDouble() ?? 2550;

    final aptNamesMap = <int, String>{};
    try {
      final aptRows = await client.rpc('get_apartment_names');
      if (aptRows is List) {
        for (final r in aptRows) {
          final num = r['apt_num'] as int;
          final name = (r['display_name'] as String?)?.trim() ?? '';
          if (name.isNotEmpty) {
            aptNamesMap[num] = name;
          }
        }
      }
    } catch (_) {
      // Fallback gracefully if get_apartment_names RPC hasn't been created yet
    }

    final monthsRows = await client
        .from('months')
        .select()
        .order('year_num', ascending: true)
        .order('month_num', ascending: true);

    final paymentRows = await client
        .from('payments')
        .select()
        .eq('is_cancelled', false);

    final monthsMap = <int, MonthBill>{};
    for (final row in monthsRows) {
      final bill = MonthBill.fromJson(row);
      monthsMap[bill.id] = bill;
    }

    for (final pRow in paymentRows) {
      final monthId = pRow['month_id'] as int;
      final record = PaymentRecord.fromJson(pRow);
      monthsMap[monthId]?.payments[record.aptNum] = record;
    }

    String announcement = '';
    try {
      final annResp = await client.rpc('get_announcement');
      announcement = (annResp as String?) ?? '';
    } catch (_) {
      try {
        final settingsRows = await client.from('building_settings').select('announcement').limit(1);
        if (settingsRows.isNotEmpty) {
          announcement = (settingsRows.first['announcement'] as String?) ?? '';
        }
      } catch (_) {}
    }

    var emergencyTx = <EmergencyTransaction>[];
    try {
      final txRows = await client
          .from('emergency_transactions')
          .select()
          .order('created_at', ascending: false);
      emergencyTx = (txRows as List)
          .map((r) => EmergencyTransaction.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      // Fallback if emergency_transactions table hasn't been created yet
    }

    try {
      final extraRows = await client
          .from('apartment_extra_charges')
          .select()
          .order('created_at', ascending: false);
      for (final row in (extraRows as List)) {
        final charge = ApartmentExtraCharge.fromJson(Map<String, dynamic>.from(row as Map));
        monthsMap[charge.monthId]?.extraCharges.add(charge);
      }
    } catch (_) {}

    bool requireAptPassOnOpen = true;
    try {
      final resp = await client.rpc('get_require_apt_pass_on_open');
      if (resp is bool) {
        requireAptPassOnOpen = resp;
      }
    } catch (_) {}

    var contactsList = <BuildingContact>[];
    try {
      final cRows = await client
          .from('building_contacts')
          .select()
          .order('created_at', ascending: false);
      contactsList = (cRows as List)
          .map((r) => BuildingContact.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {}

    final aptHasPassMap = <int, bool>{};
    try {
      final passRows = await client.rpc('get_apartments_passcode_status');
      if (passRows is List) {
        for (final r in passRows) {
          final num = r['apt_num'] as int;
          aptHasPassMap[num] = r['has_passcode'] == true;
        }
      }
    } catch (_) {}

    return BuildingDataState(
      baseEmergencyFund: baseEmerg,
      months: monthsMap.values.toList(),
      apartmentNames: aptNamesMap,
      announcement: announcement,
      emergencyTransactions: emergencyTx,
      requireAptPassOnOpen: requireAptPassOnOpen,
      buildingContacts: contactsList,
      apartmentHasPasscode: aptHasPassMap,
    );
  }

  Future<String?> submitApartmentPayment({
    required MonthBill month,
    required int aptNum,
    required String passcode,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    if (!_useSupabase) {
      if (_demoRequireAptPassOnOpen) {
        final expected = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
        if (passcode.trim() != expected) {
          return 'err_wrong_apt_pass_hint:$expected';
        }
      }
      month.payments[aptNum] = PaymentRecord(
        aptNum: aptNum,
        localBytes: imageBytes,
        fileName: fileName ?? '',
        paidAt: DateTime.now(),
      );
      return null;
    }

    final client = Supabase.instance.client;
    String? publicUrl;
    if (imageBytes != null) {
      final safeName = fileName ?? 'receipt.jpg';
      final ext = safeName.split('.').last.toLowerCase();
      final storagePath = '${month.yearNum}_${month.monthNum}/apt_${aptNum}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from('receipts').uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      publicUrl = client.storage.from('receipts').getPublicUrl(storagePath);
    }

    final res = await client.rpc('verify_apt_and_record_payment', params: {
      'p_month_id': month.id,
      'p_apt_num': aptNum,
      'p_passcode': passcode.trim(),
      'p_receipt_url': publicUrl,
    });

    if (res is Map && res['ok'] == true) {
      return null;
    }
    return (res is Map ? res['error']?.toString() : null) ?? 'err_payment_failed';
  }

  Future<String?> updateMonthAsAdmin({
    required String adminPass,
    required MonthBill month,
    required double baseEmergency,
  }) async {
    if (!_useSupabase) {
      _demoBaseEmergency = baseEmergency;
      return null;
    }

    final client = Supabase.instance.client;
    final res = await client.rpc('admin_update_month', params: {
      'p_admin_pass': adminPass,
      'p_month_id': month.id,
      'p_water': month.water,
      'p_elec': month.elec,
      'p_elev': month.elev,
      'p_clean': month.clean,
      'p_for_emerg': month.forEmerg,
      'p_apts_count': month.aptsCount,
      'p_base_emerg': baseEmergency,
      'p_custom_expenses': month.toCustomExpensesJson(),
      'p_due_day': month.dueDay,
    });

    if (res is Map && res['ok'] == true) return null;
    return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
  }

  Future<String?> cancelPaymentAsAdmin({
    required String adminPass,
    required MonthBill month,
    required int aptNum,
  }) async {
    if (!_useSupabase) {
      month.payments.remove(aptNum);
      return null;
    }

    final client = Supabase.instance.client;
    final res = await client.rpc('admin_cancel_payment', params: {
      'p_admin_pass': adminPass,
      'p_month_id': month.id,
      'p_apt_num': aptNum,
    });

    if (res is Map && res['ok'] == true) {
      month.payments.remove(aptNum);
      return null;
    }
    return (res is Map ? res['error']?.toString() : null) ?? 'err_cancel_failed';
  }

  Future<String?> cancelPaymentAsResident({
    required MonthBill month,
    required int aptNum,
    required String passcode,
  }) async {
    if (!_useSupabase) {
      if (_demoRequireAptPassOnOpen) {
        final expected = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
        if (passcode.trim() != expected) {
          return 'err_wrong_apt_pass_hint:$expected';
        }
      }
      month.payments.remove(aptNum);
      return null;
    }

    final client = Supabase.instance.client;
    final res = await client.rpc('verify_apt_and_cancel_payment', params: {
      'p_month_id': month.id,
      'p_apt_num': aptNum,
      'p_passcode': passcode.trim(),
    });

    if (res is Map && res['ok'] == true) {
      final oldUrl = res['receipt_url']?.toString() ?? '';
      const marker = '/object/public/receipts/';
      final idx = oldUrl.indexOf(marker);
      if (idx != -1) {
        final path = Uri.decodeComponent(oldUrl.substring(idx + marker.length));
        if (path.isNotEmpty) {
          try {
            await client.storage.from('receipts').remove([path]);
          } catch (_) {}
        }
      }
      month.payments.remove(aptNum);
      return null;
    }
    return (res is Map ? res['error']?.toString() : null) ?? 'err_cancel_failed';
  }

  static String _demoAdminPass = '7777';

  Future<String?> verifyAdminPass(String adminPass) async {
    final clean = adminPass.trim();
    if (!_useSupabase) {
      if (clean == _demoAdminPass || clean == 'admin123') return null;
      return 'err_wrong_admin_pass';
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_get_apartments', params: {
        'p_admin_pass': clean,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
    } catch (e) {
      return 'err_wrong_admin_pass';
    }
  }

  Future<String?> changeAdminPassword({
    required String currentPass,
    required String newPass,
  }) async {
    final cleanCur = currentPass.trim();
    final cleanNew = newPass.trim();
    if (cleanNew.length < 4) return 'err_pass_too_short';

    if (!_useSupabase) {
      if (cleanCur != _demoAdminPass && cleanCur != 'admin123') {
        return 'err_wrong_admin_pass';
      }
      _demoAdminPass = cleanNew;
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_change_password', params: {
        'p_current_pass': cleanCur,
        'p_new_pass': cleanNew,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<({List<ApartmentInfo>? apartments, String? error})> fetchAdminApartments({
    required String adminPass,
    required int aptsCount,
  }) async {
    if (!_useSupabase) {
      final list = <ApartmentInfo>[];
      for (int i = 1; i <= aptsCount; i++) {
        list.add(_demoApartments[i] ?? ApartmentInfo(aptNum: i, passcode: '${1000 + i}'));
      }
      return (apartments: list, error: null);
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_get_apartments', params: {
        'p_admin_pass': adminPass,
      });

      if (res is Map && res['ok'] == true) {
        final rawList = (res['apartments'] as List?) ?? [];
        final byNum = <int, ApartmentInfo>{};
        for (final item in rawList) {
          final info = ApartmentInfo.fromJson(Map<String, dynamic>.from(item as Map));
          byNum[info.aptNum] = info;
        }
        final result = <ApartmentInfo>[];
        for (int i = 1; i <= aptsCount; i++) {
          result.add(byNum[i] ?? ApartmentInfo(aptNum: i, passcode: '${1000 + i}'));
        }
        return (apartments: result, error: null);
      }

      return (
        apartments: null,
        error: (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass',
      );
    } catch (e) {
      return (apartments: null, error: 'err_apt_load_failed');
    }
  }

  Future<String?> updateApartmentAsAdmin({
    required String adminPass,
    required int aptNum,
    required String displayName,
    required String passcode,
  }) async {
    if (!_useSupabase) {
      _demoApartments[aptNum] = ApartmentInfo(
        aptNum: aptNum,
        displayName: displayName.trim(),
        passcode: passcode.trim(),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_update_apartment', params: {
        'p_admin_pass': adminPass,
        'p_apt_num': aptNum,
        'p_display_name': displayName.trim(),
        'p_passcode': passcode.trim(),
      });

      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_apt_save_failed';
    } catch (e) {
      return 'err_apt_save_failed';
    }
  }

  Future<List<FeedbackPost>> fetchFeedbackPosts() async {
    if (!_useSupabase) {
      return List<FeedbackPost>.from(_demoFeedbackPosts);
    }
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('feedback_posts')
          .select()
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => FeedbackPost.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> submitFeedbackPost({
    required String type,
    required String message,
    int? aptNum,
    String? passcode,
    String? authorLabel,
    int? authAptNum,
    String? authPasscode,
    String? adminPass,
  }) async {
    final cleanMsg = message.trim();
    if (cleanMsg.isEmpty) return 'err_empty_message';

    if (!_useSupabase) {
      if (aptNum != null) {
        final expectedPass = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
        if ((passcode ?? '').trim() != expectedPass) {
          return 'err_wrong_apt_pass';
        }
      }
      _demoFeedbackPosts.insert(
        0,
        FeedbackPost(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          type: type,
          message: cleanMsg,
          authorLabel: aptNum != null ? authorLabel : null,
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final isAnonymous = aptNum == null;
      final res = await client.rpc('submit_feedback_authenticated', params: {
        'p_type': type,
        'p_message': cleanMsg,
        'p_is_anonymous': isAnonymous,
        'p_auth_apt_num': aptNum ?? authAptNum,
        'p_auth_passcode': (passcode ?? authPasscode ?? '').trim(),
        'p_admin_pass': adminPass,
        'p_author_label': authorLabel,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_apt_pass';
    } catch (e) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteFeedbackPost({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoFeedbackPosts.removeWhere((p) => p.id == id);
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_feedback', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (e) {
      return 'err_delete_failed';
    }
  }

  Future<String?> addNextMonthAsAdmin(String adminPass) async {
    if (!_useSupabase) {
      final last = _demoMonths.last;
      final nextMonth = last.monthNum == 12 ? 1 : last.monthNum + 1;
      final nextYear = last.monthNum == 12 ? last.yearNum + 1 : last.yearNum;
      _demoMonths.add(MonthBill(
        id: last.id + 1,
        monthNum: nextMonth,
        yearNum: nextYear,
        water: 0,
        elec: 0,
        elev: 400,
        clean: 240,
        forEmerg: 0,
        aptsCount: last.aptsCount,
      ));
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_add_next_month', params: {
        'p_admin_pass': adminPass,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_admin_pass';
    } catch (e) {
      return 'err_apt_save_failed';
    }
  }

  Future<String?> deleteMonthAsAdmin({
    required String adminPass,
    required int monthId,
  }) async {
    if (!_useSupabase) {
      if (_demoMonths.length <= 1) return 'err_cannot_delete_last_month';
      _demoMonths.removeWhere((m) => m.id == monthId);
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_month', params: {
        'p_admin_pass': adminPass,
        'p_month_id': monthId,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (e) {
      return 'err_delete_failed';
    }
  }

  Future<String?> saveAnnouncement({
    required String adminPass,
    required String announcement,
  }) async {
    final clean = announcement.trim();
    if (!_useSupabase) {
      _demoAnnouncement = clean;
      return null;
    }
    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_set_announcement', params: {
        'p_admin_pass': adminPass,
        'p_announcement': clean,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_apt_save_failed';
    } catch (e) {
      return 'err_apt_save_failed';
    }
  }

  Future<String?> addEmergencyTransaction({
    required String adminPass,
    required double amount,
    required String reason,
  }) async {
    final cleanReason = reason.trim();
    if (amount == 0 || cleanReason.isEmpty) return 'err_empty_message';

    if (!_useSupabase) {
      _demoBaseEmergency = (_demoBaseEmergency - amount).clamp(0, double.infinity);
      _demoEmergencyTx.insert(
        0,
        EmergencyTransaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          reason: cleanReason,
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_add_emergency_tx', params: {
        'p_admin_pass': adminPass,
        'p_amount': amount,
        'p_reason': cleanReason,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (e) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteEmergencyTransaction({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      final idx = _demoEmergencyTx.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        _demoBaseEmergency += _demoEmergencyTx[idx].amount;
        _demoEmergencyTx.removeAt(idx);
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_emergency_tx', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (e) {
      return 'err_delete_failed';
    }
  }

  Future<String?> updateFeedbackPostStatus({
    required String adminPass,
    required String id,
    required String status,
    String? adminReply,
  }) async {
    final cleanReply = (adminReply ?? '').trim();
    if (!_useSupabase) {
      final idx = _demoFeedbackPosts.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        final old = _demoFeedbackPosts[idx];
        _demoFeedbackPosts[idx] = FeedbackPost(
          id: old.id,
          type: old.type,
          message: old.message,
          authorLabel: old.authorLabel,
          status: status,
          adminReply: cleanReply.isEmpty ? null : cleanReply,
          createdAt: old.createdAt,
        );
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_update_feedback_status', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
        'p_status': status,
        'p_admin_reply': cleanReply.isEmpty ? null : cleanReply,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (e) {
      return 'err_submit_failed';
    }
  }

  Future<String?> addExtraChargesAsAdmin({
    required String adminPass,
    required int monthId,
    required List<int> aptNums,
    required double amount,
    required String reason,
  }) async {
    final cleanReason = reason.trim();
    if (aptNums.isEmpty || amount <= 0 || cleanReason.isEmpty) {
      return 'err_empty_message';
    }

    if (!_useSupabase) {
      final idx = _demoMonths.indexWhere((m) => m.id == monthId);
      if (idx >= 0) {
        final now = DateTime.now();
        for (final apt in aptNums) {
          _demoMonths[idx].extraCharges.insert(
            0,
            ApartmentExtraCharge(
              id: '${now.microsecondsSinceEpoch}_$apt',
              monthId: monthId,
              aptNum: apt,
              amount: amount,
              reason: cleanReason,
              createdAt: now,
            ),
          );
        }
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_add_extra_charge', params: {
        'p_admin_pass': adminPass,
        'p_month_id': monthId,
        'p_apt_nums': aptNums,
        'p_amount': amount,
        'p_reason': cleanReason,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteExtraChargeAsAdmin({
    required String adminPass,
    required int monthId,
    required String id,
  }) async {
    if (!_useSupabase) {
      final idx = _demoMonths.indexWhere((m) => m.id == monthId);
      if (idx >= 0) {
        _demoMonths[idx].extraCharges.removeWhere((e) => e.id == id);
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      final res = await client.rpc('admin_delete_extra_charge', params: {
        'p_admin_pass': adminPass,
        'p_id': int.tryParse(id) ?? 0,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<void> recordPageView(String visitorId) async {
    final clean = visitorId.trim();
    if (clean.isEmpty) return;

    if (!_useSupabase) {
      _demoPageViews.add((visitorId: clean, createdAt: DateTime.now()));
      return;
    }

    try {
      await Supabase.instance.client.rpc('record_page_view', params: {
        'p_visitor_id': clean,
      });
    } catch (_) {
      // Ignore silently if analytics RPC isn't deployed yet
    }
  }

  Future<PageViewStats?> fetchPageViewStatsAsAdmin(String adminPass) async {
    if (!_useSupabase) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final unique = _demoPageViews.map((e) => e.visitorId).toSet().length;
      final today = _demoPageViews.where((e) => !e.createdAt.isBefore(todayStart)).length;
      return PageViewStats(
        totalViews: _demoPageViews.length,
        uniqueVisitors: unique,
        todayViews: today,
      );
    }

    try {
      final res = await Supabase.instance.client.rpc('admin_get_page_view_stats', params: {
        'p_admin_pass': adminPass,
      });
      if (res is Map && res['ok'] == true) {
        return PageViewStats.fromJson(Map<String, dynamic>.from(res));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> verifyApartmentPasscode(int aptNum, String passcode) async {
    final clean = passcode.trim();
    if (!_useSupabase) {
      final expected = _demoApartments[aptNum]?.passcode ?? '${1000 + aptNum}';
      if (clean != expected) return 'err_wrong_apt_pass';
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc('verify_apartment_passcode', params: {
        'p_apt_num': aptNum,
        'p_passcode': clean,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_apt_pass';
    } catch (_) {
      return 'err_wrong_apt_pass';
    }
  }

  Future<String?> setRequireAptPassOnOpenAsAdmin({
    required String adminPass,
    required bool enabled,
  }) async {
    if (!_useSupabase) {
      _demoRequireAptPassOnOpen = enabled;
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_set_require_apt_pass_on_open',
        params: {
          'p_admin_pass': adminPass,
          'p_enabled': enabled,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> setUtilityReceiptAsAdmin({
    required String adminPass,
    required MonthBill month,
    required String utility,
    Uint8List? imageBytes,
  }) async {
    if (!_useSupabase) {
      if (utility == 'water') {
        month.waterLocalBytes = imageBytes;
        month.waterReceiptUrl = imageBytes != null ? 'local' : null;
      } else {
        month.elecLocalBytes = imageBytes;
        month.elecReceiptUrl = imageBytes != null ? 'local' : null;
      }
      return null;
    }

    try {
      final client = Supabase.instance.client;
      String publicUrl = '';
      if (imageBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'utility_${month.id}_${utility}_$ts.jpg';
        await client.storage.from('receipts').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        publicUrl = client.storage.from('receipts').getPublicUrl(storagePath);
      }

      final res = await client.rpc('admin_set_utility_receipt', params: {
        'p_admin_pass': adminPass,
        'p_month_id': month.id,
        'p_utility': utility,
        'p_receipt_url': publicUrl,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> addBuildingContact({
    required String name,
    required String roleDesc,
    required String phone,
    String category = 'other',
    int? addedByApt,
    String? addedByLabel,
    Uint8List? cardImageBytes,
    String? passcode,
    String? adminPass,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    if (cleanName.isEmpty || (cleanPhone.isEmpty && cardImageBytes == null)) {
      return 'err_submit_failed';
    }

    if (!_useSupabase) {
      _demoContacts.insert(
        0,
        BuildingContact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: cleanName,
          roleDesc: roleDesc.trim(),
          phone: cleanPhone,
          category: category,
          addedByApt: addedByApt,
          addedByLabel: addedByLabel?.trim(),
          localCardBytes: cardImageBytes,
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      String cardUrl = '';
      if (cardImageBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'contacts/card_$ts.jpg';
        await client.storage.from('receipts').uploadBinary(
              storagePath,
              cardImageBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        cardUrl = client.storage.from('receipts').getPublicUrl(storagePath);
      }

      final res = await client.rpc('add_building_contact', params: {
        'p_name': cleanName,
        'p_role_desc': roleDesc.trim(),
        'p_phone': cleanPhone,
        'p_added_by_apt': addedByApt,
        'p_added_by_label': addedByLabel?.trim(),
        'p_card_image_url': cardUrl,
        'p_passcode': passcode,
        'p_admin_pass': adminPass,
        'p_category': category,
      });
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> updateBuildingContactAsAdmin({
    required String adminPass,
    required String id,
    required String name,
    required String roleDesc,
    required String phone,
    String? category,
    Uint8List? newCardImageBytes,
    bool removeCardImage = false,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    if (cleanName.isEmpty) {
      return 'err_submit_failed';
    }

    if (!_useSupabase) {
      final idx = _demoContacts.indexWhere((c) => c.id == id);
      if (idx < 0) return 'err_submit_failed';
      final prev = _demoContacts[idx];
      final hasCardAfter = newCardImageBytes != null || (!removeCardImage && prev.hasCardImage);
      if (cleanPhone.isEmpty && !hasCardAfter) return 'err_submit_failed';
      _demoContacts[idx] = BuildingContact(
        id: prev.id,
        name: cleanName,
        roleDesc: roleDesc.trim(),
        phone: cleanPhone,
        category: category ?? prev.category,
        addedByApt: prev.addedByApt,
        addedByLabel: prev.addedByLabel,
        cardImageUrl: removeCardImage ? null : prev.cardImageUrl,
        localCardBytes: removeCardImage ? null : (newCardImageBytes ?? prev.localCardBytes),
        createdAt: prev.createdAt,
      );
      return null;
    }

    try {
      final client = Supabase.instance.client;
      String? cardUrlParam;
      if (newCardImageBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'contacts/card_$ts.jpg';
        await client.storage.from('receipts').uploadBinary(
              storagePath,
              newCardImageBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        cardUrlParam = client.storage.from('receipts').getPublicUrl(storagePath);
      } else if (removeCardImage) {
        cardUrlParam = '';
      }

      final res = await client.rpc(
        'admin_update_building_contact',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
          'p_name': cleanName,
          'p_role_desc': roleDesc.trim(),
          'p_phone': cleanPhone,
          'p_card_image_url': cardUrlParam,
          'p_category': category,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteBuildingContactAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoContacts.removeWhere((c) => c.id == id);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_delete_building_contact',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<String?> deleteAllExtraChargesAsAdmin({
    required String adminPass,
    required int monthId,
  }) async {
    if (!_useSupabase) {
      final idx = _demoMonths.indexWhere((m) => m.id == monthId);
      if (idx >= 0) {
        _demoMonths[idx].extraCharges.clear();
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_delete_all_extra_charges',
        params: {
          'p_admin_pass': adminPass,
          'p_month_id': monthId,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<String?> setInitialApartmentPasscode(int aptNum, String passcode) async {
    final clean = passcode.trim();
    if (clean.length < 4) return 'err_pass_too_short';

    if (!_useSupabase) {
      final existing = _demoApartments[aptNum]?.passcode.trim() ?? '';
      if (existing.isNotEmpty) return 'err_pass_already_set';
      final prev = _demoApartments[aptNum];
      _demoApartments[aptNum] = ApartmentInfo(
        aptNum: aptNum,
        displayName: prev?.displayName ?? '',
        passcode: clean,
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'set_initial_apartment_passcode',
        params: {
          'p_apt_num': aptNum,
          'p_passcode': clean,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> resetAllApartmentPasscodesAsAdmin(String adminPass) async {
    if (!_useSupabase) {
      for (final key in _demoApartments.keys.toList()) {
        final prev = _demoApartments[key]!;
        _demoApartments[key] = ApartmentInfo(
          aptNum: prev.aptNum,
          displayName: prev.displayName,
          passcode: '',
        );
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_reset_all_apartment_passcodes',
        params: {
          'p_admin_pass': adminPass,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  /// Registers or updates an FCM web push token in Supabase `push_tokens`.
  Future<bool> registerPushToken({
    required String token,
    int? aptNum,
    bool isAdmin = false,
  }) async {
    final clean = token.trim();
    if (clean.isEmpty) return false;
    if (!_useSupabase) return true;

    try {
      await Supabase.instance.client.rpc('register_push_token', params: {
        'p_token': clean,
        'p_apt_num': aptNum,
        'p_is_admin': isAdmin,
        'p_platform': 'web',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Invokes the Supabase `send-push` Edge Function.
  /// Returns `(ok, hasRecipients, notConfigured, error)`.
  Future<({bool ok, bool hasRecipients, bool notConfigured, String? error})> sendPushNotification({
    required String title,
    required String body,
    String audience = 'all',
    List<int>? targetAptNums,
    String? adminPass,
    int? aptNum,
    String? aptPasscode,
    String? eventType,
  }) async {
    if (!_useSupabase) {
      _demoNotifications.insert(
        0,
        AppNotificationItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title.trim(),
          body: body.trim(),
          audience: audience,
          eventType: eventType ?? 'manual_broadcast',
          createdAt: DateTime.now(),
        ),
      );
      return (ok: true, hasRecipients: true, notConfigured: false, error: null);
    }

    try {
      final resp = await Supabase.instance.client.functions.invoke(
        'send-push',
        body: {
          'title': title.trim(),
          'body': body.trim(),
          'audience': audience,
          if (targetAptNums != null && targetAptNums.isNotEmpty)
            'target_apt_nums': targetAptNums,
          if (adminPass != null && adminPass.isNotEmpty) 'admin_pass': adminPass,
          'apt_num': ?aptNum,
          if (aptPasscode != null && aptPasscode.isNotEmpty)
            'apt_passcode': aptPasscode,
          'event_type': ?eventType,
        },
      );
      final data = resp.data;
      if (data is Map) {
        if (data['not_configured'] == true) {
          return (ok: false, hasRecipients: false, notConfigured: true, error: null);
        }
        if (data['ok'] == true) {
          final sent = (data['sent'] as num?)?.toInt() ?? 0;
          return (ok: true, hasRecipients: sent > 0, notConfigured: false, error: null);
        }
        return (
          ok: false,
          hasRecipients: false,
          notConfigured: false,
          error: data['error']?.toString() ?? 'err_submit_failed',
        );
      }
      return (ok: false, hasRecipients: false, notConfigured: false, error: 'err_submit_failed');
    } catch (_) {
      return (ok: false, hasRecipients: false, notConfigured: false, error: 'err_submit_failed');
    }
  }

  Future<List<AppNotificationItem>> fetchAppNotifications({
    String? adminPass,
    int? aptNum,
  }) async {
    if (!_useSupabase) {
      final isAdmin = adminPass != null && adminPass.isNotEmpty;
      return _demoNotifications
          .where((n) => isAdmin || n.audience == 'all')
          .toList();
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'get_app_notifications',
        params: {
          'p_admin_pass': (adminPass != null && adminPass.isNotEmpty) ? adminPass : null,
          'p_apt_num': aptNum,
        },
      );
      if (res is List) {
        return res
            .whereType<Map>()
            .map((e) => AppNotificationItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<Set<int>> fetchPushRegisteredApts(String adminPass) async {
    if (!_useSupabase) return {1, 2, 3};
    try {
      final res = await Supabase.instance.client.rpc(
        'admin_get_push_apt_nums',
        params: {'p_admin_pass': adminPass},
      );
      if (res is List) {
        return res.whereType<num>().map((e) => e.toInt()).toSet();
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  Future<String?> deleteAppNotificationAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoNotifications.removeWhere((n) => n.id == id);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_delete_app_notification',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  static final List<BuildingPoll> _demoPolls = [];

  Future<List<BuildingPoll>> fetchBuildingPolls() async {
    if (!_useSupabase) {
      return List<BuildingPoll>.from(_demoPolls);
    }

    try {
      final client = Supabase.instance.client;
      final pollRows = await client
          .from('building_polls')
          .select()
          .order('created_at', ascending: false);

      final voteRows = await client
          .from('building_poll_votes')
          .select('poll_id, apt_num, option_id');

      final votesMap = <String, Map<String, List<int>>>{};
      for (final r in (voteRows as List)) {
        final pid = r['poll_id'].toString();
        final optId = (r['option_id'] ?? '').toString();
        final aptNum = (r['apt_num'] as num?)?.toInt();
        if (optId.isEmpty || aptNum == null) continue;
        votesMap.putIfAbsent(pid, () => {});
        votesMap[pid]!.putIfAbsent(optId, () => []);
        if (!votesMap[pid]![optId]!.contains(aptNum)) {
          votesMap[pid]![optId]!.add(aptNum);
        }
      }

      for (final perPoll in votesMap.values) {
        for (final aptList in perPoll.values) {
          aptList.sort();
        }
      }

      return (pollRows as List).map((r) {
        final map = Map<String, dynamic>.from(r as Map);
        final pid = map['id'].toString();
        return BuildingPoll.fromJson(
          map,
          votesByOption: votesMap[pid] ?? const {},
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<String?> createBuildingPollAsAdmin({
    required String adminPass,
    required String question,
    required List<PollOption> options,
    bool allowMultiple = false,
    bool showVotersPublicly = true,
  }) async {
    final cleanQ = question.trim();
    if (cleanQ.isEmpty || options.length < 2) return 'err_submit_failed';

    if (!_useSupabase) {
      _demoPolls.insert(
        0,
        BuildingPoll(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: cleanQ,
          options: options,
          allowMultiple: allowMultiple,
          showVotersPublicly: showVotersPublicly,
          createdAt: DateTime.now(),
          votesByOption: {},
        ),
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_create_building_poll',
        params: {
          'p_admin_pass': adminPass,
          'p_question': cleanQ,
          'p_options': options.map((o) => o.toJson()).toList(),
          'p_allow_multiple': allowMultiple,
          'p_show_voters_publicly': showVotersPublicly,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> togglePollClosedAsAdmin({
    required String adminPass,
    required String pollId,
    required bool isClosed,
  }) async {
    if (!_useSupabase) {
      final idx = _demoPolls.indexWhere((p) => p.id == pollId);
      if (idx < 0) return 'err_submit_failed';
      final p = _demoPolls[idx];
      _demoPolls[idx] = BuildingPoll(
        id: p.id,
        question: p.question,
        options: p.options,
        allowMultiple: p.allowMultiple,
        showVotersPublicly: p.showVotersPublicly,
        isClosed: isClosed,
        createdAt: p.createdAt,
        votesByOption: p.votesByOption,
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_toggle_poll_closed',
        params: {
          'p_admin_pass': adminPass,
          'p_poll_id': int.tryParse(pollId) ?? 0,
          'p_is_closed': isClosed,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteBuildingPollAsAdmin({
    required String adminPass,
    required String pollId,
  }) async {
    if (!_useSupabase) {
      _demoPolls.removeWhere((p) => p.id == pollId);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_archive_building_poll',
        params: {
          'p_admin_pass': adminPass,
          'p_poll_id': int.tryParse(pollId) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  Future<String?> castPollVote({
    required String pollId,
    required int aptNum,
    required String optionId,
    String? passcode,
    String? adminPass,
  }) async {
    if (!_useSupabase) {
      final idx = _demoPolls.indexWhere((p) => p.id == pollId);
      if (idx < 0) return 'err_submit_failed';
      final p = _demoPolls[idx];
      if (p.isClosed) return 'err_submit_failed';
      final updated = <String, List<int>>{
        for (final entry in p.votesByOption.entries)
          entry.key: List<int>.from(entry.value),
      };
      final already = (updated[optionId] ?? const []).contains(aptNum);
      if (p.allowMultiple) {
        updated.putIfAbsent(optionId, () => []);
        if (already) {
          updated[optionId]!.remove(aptNum);
        } else {
          updated[optionId]!.add(aptNum);
        }
      } else {
        for (final list in updated.values) {
          list.remove(aptNum);
        }
        if (!already) {
          updated.putIfAbsent(optionId, () => []);
          updated[optionId]!.add(aptNum);
        }
      }
      _demoPolls[idx] = BuildingPoll(
        id: p.id,
        question: p.question,
        options: p.options,
        allowMultiple: p.allowMultiple,
        showVotersPublicly: p.showVotersPublicly,
        isClosed: p.isClosed,
        createdAt: p.createdAt,
        votesByOption: updated,
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'cast_building_poll_vote',
        params: {
          'p_poll_id': int.tryParse(pollId) ?? 0,
          'p_apt_num': aptNum,
          'p_option_id': optionId,
          'p_passcode': passcode,
          'p_admin_pass': adminPass,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  static final List<AppRating> _demoRatings = [];

  Future<List<AppRating>> fetchAppRatings() async {
    if (!_useSupabase) {
      return List<AppRating>.from(_demoRatings);
    }

    try {
      final rows = await Supabase.instance.client
          .from('app_ratings')
          .select()
          .order('updated_at', ascending: false);
      return (rows as List)
          .map((r) => AppRating.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<String?> submitAppRating({
    required int aptNum,
    required int stars,
    required List<String> tags,
    required String comment,
    String? passcode,
    String? adminPass,
  }) async {
    if (stars < 1 || stars > 5) return 'err_submit_failed';

    if (!_useSupabase) {
      _demoRatings.removeWhere((r) => r.aptNum == aptNum);
      _demoRatings.insert(
        0,
        AppRating(
          id: aptNum.toString(),
          aptNum: aptNum,
          stars: stars,
          tags: List<String>.from(tags),
          comment: comment.trim(),
          updatedAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'submit_app_rating',
        params: {
          'p_apt_num': aptNum,
          'p_passcode': (passcode ?? '').trim(),
          'p_stars': stars,
          'p_tags': tags,
          'p_comment': comment.trim(),
          'p_admin_pass': adminPass,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteAppRatingAsAdmin({
    required String adminPass,
    required int aptNum,
  }) async {
    if (!_useSupabase) {
      _demoRatings.removeWhere((r) => r.aptNum == aptNum);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_archive_app_rating',
        params: {
          'p_admin_pass': adminPass,
          'p_apt_num': aptNum,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  static final List<EmergencyArrear> _demoArrears = [];

  Future<List<EmergencyArrear>> fetchEmergencyArrears() async {
    if (!_useSupabase) {
      return List<EmergencyArrear>.from(_demoArrears);
    }

    try {
      final rows = await Supabase.instance.client
          .from('emergency_arrears')
          .select()
          .order('is_collected', ascending: true)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => EmergencyArrear.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<String?> addEmergencyArrearAsAdmin({
    required String adminPass,
    required String title,
    required double amount,
    required String details,
  }) async {
    if (title.trim().isEmpty || amount <= 0) return 'err_submit_failed';

    if (!_useSupabase) {
      _demoArrears.insert(
        0,
        EmergencyArrear(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
          amount: amount,
          details: details.trim(),
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_add_emergency_arrear',
        params: {
          'p_admin_pass': adminPass,
          'p_title': title.trim(),
          'p_amount': amount,
          'p_details': details.trim(),
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> updateEmergencyArrearAsAdmin({
    required String adminPass,
    required String id,
    required String title,
    required double amount,
    required String details,
  }) async {
    if (title.trim().isEmpty || amount <= 0) return 'err_submit_failed';

    if (!_useSupabase) {
      final idx = _demoArrears.indexWhere((a) => a.id == id);
      if (idx < 0 || _demoArrears[idx].isCollected) return 'err_submit_failed';
      final prev = _demoArrears[idx];
      _demoArrears[idx] = EmergencyArrear(
        id: prev.id,
        title: title.trim(),
        amount: amount,
        details: details.trim(),
        isCollected: prev.isCollected,
        createdAt: prev.createdAt,
        collectedAt: prev.collectedAt,
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_update_emergency_arrear',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
          'p_title': title.trim(),
          'p_amount': amount,
          'p_details': details.trim(),
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> collectEmergencyArrearAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      final idx = _demoArrears.indexWhere((a) => a.id == id);
      if (idx < 0 || _demoArrears[idx].isCollected) return 'err_submit_failed';
      final item = _demoArrears[idx];
      _demoArrears[idx] = EmergencyArrear(
        id: item.id,
        title: item.title,
        amount: item.amount,
        details: item.details,
        isCollected: true,
        createdAt: item.createdAt,
        collectedAt: DateTime.now(),
      );
      _demoBaseEmergency += item.amount;
      _demoEmergencyTx.insert(
        0,
        EmergencyTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: -item.amount,
          reason: 'تحصيل متأخرات: ${item.title}',
          createdAt: DateTime.now(),
        ),
      );
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_collect_emergency_arrear',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteEmergencyArrearAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoArrears.removeWhere((a) => a.id == id);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_archive_emergency_arrear',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  static final Set<int> _demoClosedApts = {14, 15, 16, 17, 18};
  static final List<SpecialAptFee> _demoSpecialFees = [];

  Future<List<int>> fetchClosedAptNums() async {
    if (!_useSupabase) return _demoClosedApts.toList()..sort();
    try {
      final res = await Supabase.instance.client.rpc('get_closed_apartments');
      if (res is List) {
        final nums = res
            .whereType<Map>()
            .map((e) => (e['apt_num'] as num?)?.toInt())
            .whereType<int>()
            .toList()
          ..sort();
        return nums;
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<String?> setApartmentClosedAsAdmin({
    required String adminPass,
    required int aptNum,
    required bool isClosed,
  }) async {
    if (!_useSupabase) {
      if (isClosed) {
        _demoClosedApts.add(aptNum);
      } else {
        _demoClosedApts.remove(aptNum);
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_set_apartment_closed',
        params: {
          'p_admin_pass': adminPass,
          'p_apt_num': aptNum,
          'p_is_closed': isClosed,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<List<SpecialAptFee>> fetchSpecialAptFees() async {
    if (!_useSupabase) {
      return List<SpecialAptFee>.from(_demoSpecialFees);
    }
    try {
      final rows = await Supabase.instance.client
          .from('special_apt_fees')
          .select()
          .order('is_paid', ascending: true)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => SpecialAptFee.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<String?> addSpecialAptFeesAsAdmin({
    required String adminPass,
    required List<int> aptNums,
    required String label,
    required double amount,
  }) async {
    if (label.trim().isEmpty || amount <= 0 || aptNums.isEmpty) {
      return 'err_submit_failed';
    }
    if (!_useSupabase) {
      for (final apt in aptNums) {
        _demoSpecialFees.insert(
          0,
          SpecialAptFee(
            id: '${DateTime.now().microsecondsSinceEpoch}_$apt',
            aptNum: apt,
            label: label.trim(),
            amount: amount,
            createdAt: DateTime.now(),
          ),
        );
      }
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_add_special_apt_fees',
        params: {
          'p_admin_pass': adminPass,
          'p_apt_nums': aptNums,
          'p_label': label.trim(),
          'p_amount': amount,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> collectSpecialAptFeeAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      final idx = _demoSpecialFees.indexWhere((f) => f.id == id);
      if (idx < 0 || _demoSpecialFees[idx].isPaid) return 'err_submit_failed';
      final f = _demoSpecialFees[idx];
      _demoSpecialFees[idx] = SpecialAptFee(
        id: f.id,
        aptNum: f.aptNum,
        label: f.label,
        amount: f.amount,
        isPaid: true,
        createdAt: f.createdAt,
        paidAt: DateTime.now(),
      );
      _demoBaseEmergency += f.amount;
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_collect_special_apt_fee',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> deleteSpecialAptFeeAsAdmin({
    required String adminPass,
    required String id,
  }) async {
    if (!_useSupabase) {
      _demoSpecialFees.removeWhere((f) => f.id == id);
      return null;
    }

    try {
      final res = await Supabase.instance.client.rpc(
        'admin_archive_special_apt_fee',
        params: {
          'p_admin_pass': adminPass,
          'p_id': int.tryParse(id) ?? 0,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_delete_failed';
    } catch (_) {
      return 'err_delete_failed';
    }
  }

  final Map<int, ApartmentProfile> _demoProfiles = {};

  Future<Map<int, ApartmentProfile>> fetchApartmentProfiles({
    String? adminPass,
    int? aptNum,
    String? passcode,
  }) async {
    if (!_useSupabase) {
      return Map<int, ApartmentProfile>.from(_demoProfiles);
    }
    try {
      final res = await Supabase.instance.client.rpc(
        'get_apartment_profiles',
        params: {
          'p_admin_pass': adminPass,
          'p_apt_num': aptNum,
          'p_passcode': passcode,
        },
      );
      if (res is List) {
        final out = <int, ApartmentProfile>{};
        for (final row in res) {
          if (row is Map) {
            final p = ApartmentProfile.fromJson(Map<String, dynamic>.from(row));
            if (p.aptNum > 0) out[p.aptNum] = p;
          }
        }
        return out;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<String?> updateOwnApartmentProfile({
    required int aptNum,
    required String passcode,
    String? displayName,
    required String floorNum,
    required String phone,
    required bool showPhoneToNeighbors,
    String? adminPass,
    Uint8List? avatarBytes,
    bool removeAvatar = false,
  }) async {
    if (!_useSupabase) {
      final prev = _demoProfiles[aptNum];
      _demoProfiles[aptNum] = ApartmentProfile(
        aptNum: aptNum,
        displayName: displayName?.trim() ?? '',
        floorNum: floorNum.trim(),
        phone: phone.trim(),
        showPhoneToNeighbors: showPhoneToNeighbors,
        isClosed: _demoClosedApts.contains(aptNum),
        avatarUrl: removeAvatar ? '' : (prev?.avatarUrl ?? ''),
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        final prevApt = _demoApartments[aptNum];
        _demoApartments[aptNum] = ApartmentInfo(
          aptNum: aptNum,
          displayName: displayName.trim(),
          passcode: prevApt?.passcode ?? '${1000 + aptNum}',
        );
      }
      return null;
    }
    try {
      final client = Supabase.instance.client;
      String? avatarUrlParam;
      if (avatarBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'avatars/apt_${aptNum}_$ts.jpg';
        await client.storage.from('receipts').uploadBinary(
              storagePath,
              avatarBytes,
              fileOptions: const FileOptions(upsert: true),
            );
        avatarUrlParam = client.storage.from('receipts').getPublicUrl(storagePath);
      } else if (removeAvatar) {
        avatarUrlParam = '';
      }
      final res = await client.rpc(
        'update_own_apartment_profile',
        params: {
          'p_apt_num': aptNum,
          'p_passcode': passcode,
          'p_display_name': displayName,
          'p_floor_num': floorNum.trim(),
          'p_phone': phone.trim(),
          'p_show_phone_to_neighbors': showPhoneToNeighbors,
          'p_admin_pass': adminPass,
          'p_avatar_url': avatarUrlParam,
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_submit_failed';
    } catch (_) {
      return 'err_submit_failed';
    }
  }

  Future<String?> changeApartmentPasscode({
    required int aptNum,
    required String oldPasscode,
    required String newPasscode,
  }) async {
    if (newPasscode.trim().length < 4) return 'err_pass_too_short';
    if (!_useSupabase) {
      final prev = _demoApartments[aptNum];
      _demoApartments[aptNum] = ApartmentInfo(
        aptNum: aptNum,
        displayName: prev?.displayName ?? '',
        passcode: newPasscode.trim(),
      );
      return null;
    }
    try {
      final res = await Supabase.instance.client.rpc(
        'change_apartment_passcode',
        params: {
          'p_apt_num': aptNum,
          'p_old_passcode': oldPasscode.trim(),
          'p_new_passcode': newPasscode.trim(),
        },
      );
      if (res is Map && res['ok'] == true) return null;
      return (res is Map ? res['error']?.toString() : null) ?? 'err_wrong_apt_pass';
    } catch (_) {
      return 'err_wrong_apt_pass';
    }
  }
}
