import 'dart:typed_data';

class ApartmentInfo {
  final int aptNum;
  String displayName;
  String passcode;

  ApartmentInfo({
    required this.aptNum,
    this.displayName = '',
    this.passcode = '',
  });

  String get label => displayName.trim().isNotEmpty ? displayName.trim() : 'شقة $aptNum';

  factory ApartmentInfo.fromJson(Map<String, dynamic> json) {
    return ApartmentInfo(
      aptNum: json['apt_num'] as int,
      displayName: (json['display_name'] as String?) ?? '',
      passcode: (json['passcode'] as String?) ?? '',
    );
  }
}

class PaymentRecord {
  final int aptNum;
  final String? receiptUrl;
  final Uint8List? localBytes; // Used in local demo mode
  final String fileName;
  final DateTime paidAt;

  PaymentRecord({
    required this.aptNum,
    this.receiptUrl,
    this.localBytes,
    required this.fileName,
    required this.paidAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      aptNum: json['apt_num'] as int,
      receiptUrl: json['receipt_url'] as String?,
      fileName: 'إيصال_التحويل.jpg',
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ApartmentExtraCharge {
  final String id;
  final int monthId;
  final int aptNum;
  final double amount;
  final String reason;
  final DateTime createdAt;

  const ApartmentExtraCharge({
    required this.id,
    required this.monthId,
    required this.aptNum,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  factory ApartmentExtraCharge.fromJson(Map<String, dynamic> json) {
    return ApartmentExtraCharge(
      id: json['id'].toString(),
      monthId: json['month_id'] as int? ?? 0,
      aptNum: json['apt_num'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class CustomExpenseItem {
  final String id;
  String name;
  double amount;

  CustomExpenseItem({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory CustomExpenseItem.fromJson(Map<String, dynamic> json) {
    return CustomExpenseItem(
      id: (json['id']?.toString() ?? '').trim().isNotEmpty
          ? json['id'].toString()
          : 'ce_${DateTime.now().microsecondsSinceEpoch}',
      name: (json['name'] as String?)?.trim() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };
}

class MonthBill {
  final int id;
  final int monthNum;
  final int yearNum;
  double water;
  double elec;
  double elev;
  double clean;
  double forEmerg;
  int aptsCount;
  int dueDay;
  String? waterReceiptUrl;
  Uint8List? waterLocalBytes;
  String? elecReceiptUrl;
  Uint8List? elecLocalBytes;
  final Map<int, PaymentRecord> payments;
  final List<ApartmentExtraCharge> extraCharges;
  final List<CustomExpenseItem> customExpenses;
  final Map<String, String> coreLabels;
  final Set<String> hiddenCoreKeys;

  MonthBill({
    required this.id,
    required this.monthNum,
    required this.yearNum,
    required this.water,
    required this.elec,
    required this.elev,
    required this.clean,
    required this.forEmerg,
    required this.aptsCount,
    this.dueDay = 10,
    this.waterReceiptUrl,
    this.waterLocalBytes,
    this.elecReceiptUrl,
    this.elecLocalBytes,
    Map<int, PaymentRecord>? payments,
    List<ApartmentExtraCharge>? extraCharges,
    List<CustomExpenseItem>? customExpenses,
    Map<String, String>? coreLabels,
    Set<String>? hiddenCoreKeys,
  })  : payments = payments ?? {},
        extraCharges = extraCharges ?? [],
        customExpenses = customExpenses ?? [],
        coreLabels = coreLabels ?? {},
        hiddenCoreKeys = hiddenCoreKeys ?? {};

  static const String coreMetaId = '__core_meta__';

  bool isCoreHidden(String key) => hiddenCoreKeys.contains(key);

  String coreLabel(String key, String fallback) {
    final custom = coreLabels[key]?.trim();
    return (custom != null && custom.isNotEmpty) ? custom : fallback;
  }

  List<Map<String, dynamic>> toCustomExpensesJson() {
    final list = customExpenses.map((e) => e.toJson()).toList();
    if (coreLabels.isNotEmpty || hiddenCoreKeys.isNotEmpty) {
      list.add({
        'id': coreMetaId,
        'name': '',
        'amount': 0,
        'labels': Map<String, String>.from(coreLabels),
        'hidden': hiddenCoreKeys.toList(),
      });
    }
    return list;
  }

  double get customExpensesTotal =>
      customExpenses.fold<double>(0, (sum, item) => sum + item.amount);

  double get totalExpenses =>
      (isCoreHidden('water') ? 0 : water) +
      (isCoreHidden('elec') ? 0 : elec) +
      (isCoreHidden('elev') ? 0 : elev) +
      (isCoreHidden('clean') ? 0 : clean) +
      customExpensesTotal;

  int get sharePerApt {
    if (totalExpenses <= 0 || aptsCount <= 0) return 0;
    return (totalExpenses / aptsCount).ceil();
  }

  List<ApartmentExtraCharge> extraChargesFor(int aptNum) =>
      extraCharges.where((e) => e.aptNum == aptNum).toList();

  int extraTotalFor(int aptNum) => extraCharges
      .where((e) => e.aptNum == aptNum)
      .fold<double>(0, (sum, e) => sum + e.amount)
      .round();

  int dueFor(int aptNum) => sharePerApt + extraTotalFor(aptNum);

  int get totalCollected {
    int sum = 0;
    for (final aptNum in payments.keys) {
      if (aptNum >= 1 && aptNum <= aptsCount) {
        sum += dueFor(aptNum);
      }
    }
    return sum;
  }

  int get totalExpected {
    int sum = 0;
    for (int i = 1; i <= aptsCount; i++) {
      sum += dueFor(i);
    }
    return sum;
  }

  int get totalRemaining => (totalExpected - totalCollected).clamp(0, totalExpected);

  bool get hasDueDate => dueDay >= 1 && dueDay <= 31;

  DateTime? get dueDate {
    if (!hasDueDate) return null;
    final lastDayOfMonth = DateTime(yearNum, monthNum + 1, 0).day;
    final clampedDay = dueDay.clamp(1, lastDayOfMonth);
    return DateTime(yearNum, monthNum, clampedDay);
  }

  bool get isPastDue {
    final due = dueDate;
    if (due == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(due);
  }

  int get unpaidCount {
    int count = 0;
    for (int i = 1; i <= aptsCount; i++) {
      if (!payments.containsKey(i)) count++;
    }
    return count;
  }

  factory MonthBill.fromJson(Map<String, dynamic> json) {
    final rawCustom = json['custom_expenses'];
    final customList = <CustomExpenseItem>[];
    final coreLabels = <String, String>{};
    final hiddenCoreKeys = <String>{};
    if (rawCustom is List) {
      for (final item in rawCustom) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (map['id']?.toString() == coreMetaId) {
            final rawLabels = map['labels'];
            if (rawLabels is Map) {
              for (final entry in rawLabels.entries) {
                final k = entry.key.toString().trim();
                final v = entry.value?.toString().trim() ?? '';
                if (k.isNotEmpty && v.isNotEmpty) {
                  coreLabels[k] = v;
                }
              }
            }
            final rawHidden = map['hidden'];
            if (rawHidden is List) {
              for (final h in rawHidden) {
                final k = h.toString().trim();
                if (k.isNotEmpty) hiddenCoreKeys.add(k);
              }
            }
            continue;
          }
          final parsed = CustomExpenseItem.fromJson(map);
          if (parsed.name.isNotEmpty) {
            customList.add(parsed);
          }
        }
      }
    }
    return MonthBill(
      id: json['id'] as int,
      monthNum: json['month_num'] as int,
      yearNum: json['year_num'] as int? ?? 2026,
      water: (json['water'] as num?)?.toDouble() ?? 0,
      elec: (json['elec'] as num?)?.toDouble() ?? 0,
      elev: (json['elev'] as num?)?.toDouble() ?? 400,
      clean: (json['clean'] as num?)?.toDouble() ?? 240,
      forEmerg: (json['for_emerg'] as num?)?.toDouble() ?? 0,
      aptsCount: json['apts_count'] as int? ?? 13,
      dueDay: (json['due_day'] as num?)?.toInt() ?? 10,
      waterReceiptUrl: (json['water_receipt_url'] as String?)?.trim(),
      elecReceiptUrl: (json['elec_receipt_url'] as String?)?.trim(),
      customExpenses: customList,
      coreLabels: coreLabels,
      hiddenCoreKeys: hiddenCoreKeys,
    );
  }
}

class BuildingContact {
  final String id;
  final String name;
  final String roleDesc;
  final String phone;
  final String category; // plumbing | electric | elevator | ac | carpentry | other
  final int? addedByApt;
  final String? addedByLabel;
  final String? cardImageUrl;
  final Uint8List? localCardBytes;
  final DateTime createdAt;

  const BuildingContact({
    required this.id,
    required this.name,
    required this.roleDesc,
    required this.phone,
    this.category = 'other',
    this.addedByApt,
    this.addedByLabel,
    this.cardImageUrl,
    this.localCardBytes,
    required this.createdAt,
  });

  bool get hasCardImage =>
      localCardBytes != null ||
      (cardImageUrl != null && cardImageUrl!.trim().isNotEmpty);

  bool get hasPhone => phone.trim().isNotEmpty;

  bool get supportsWhatsApp =>
      phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;

  String get whatsappNumber {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) return '2$digits';
    return digits;
  }

  factory BuildingContact.fromJson(Map<String, dynamic> json) {
    final rawCard = (json['card_image_url'] as String?)?.trim();
    final rawCat = (json['category'] as String?)?.trim().toLowerCase() ?? 'other';
    const validCats = {'plumbing', 'electric', 'elevator', 'ac', 'carpentry', 'other'};
    return BuildingContact(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? '',
      roleDesc: (json['role_desc'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      category: validCats.contains(rawCat) ? rawCat : 'other',
      addedByApt: (json['added_by_apt'] as num?)?.toInt(),
      addedByLabel: (json['added_by_label'] as String?)?.trim(),
      cardImageUrl: (rawCard != null && rawCard.isNotEmpty) ? rawCard : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class FeedbackPost {
  final String id;
  final String type; // 'complaint' or 'improvement'
  final String message;
  final String? authorLabel; // null when anonymous
  final String status; // 'pending', 'in_progress', 'resolved'
  final String? adminReply;
  final DateTime createdAt;

  const FeedbackPost({
    required this.id,
    required this.type,
    required this.message,
    this.authorLabel,
    this.status = 'pending',
    this.adminReply,
    required this.createdAt,
  });

  factory FeedbackPost.fromJson(Map<String, dynamic> json) {
    return FeedbackPost(
      id: json['id'].toString(),
      type: (json['type'] as String?) ?? 'complaint',
      message: (json['message'] as String?) ?? '',
      authorLabel: json['author_label'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      adminReply: json['admin_reply'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class EmergencyTransaction {
  final String id;
  final double amount;
  final String reason;
  final DateTime createdAt;

  const EmergencyTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  factory EmergencyTransaction.fromJson(Map<String, dynamic> json) {
    return EmergencyTransaction(
      id: json['id'].toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PageViewStats {
  final int totalViews;
  final int uniqueVisitors;
  final int todayViews;

  const PageViewStats({
    this.totalViews = 0,
    this.uniqueVisitors = 0,
    this.todayViews = 0,
  });

  factory PageViewStats.fromJson(Map<String, dynamic> json) {
    return PageViewStats(
      totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['unique_visitors'] as num?)?.toInt() ?? 0,
      todayViews: (json['today_views'] as num?)?.toInt() ?? 0,
    );
  }
}

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String audience;
  final String eventType;
  final DateTime createdAt;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.audience = 'all',
    this.eventType = 'manual_broadcast',
    required this.createdAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: json['id'].toString(),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      audience: (json['audience'] as String?) ?? 'all',
      eventType: (json['event_type'] as String?) ?? 'manual_broadcast',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PollOption {
  final String id;
  final String text;

  const PollOption({
    required this.id,
    required this.text,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}

class BuildingPoll {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool allowMultiple;
  final bool showVotersPublicly;
  final bool isClosed;
  final DateTime createdAt;
  /// Map of optionId -> list of aptNums who voted for that option
  final Map<String, List<int>> votesByOption;

  const BuildingPoll({
    required this.id,
    required this.question,
    required this.options,
    this.allowMultiple = false,
    this.showVotersPublicly = true,
    this.isClosed = false,
    required this.createdAt,
    this.votesByOption = const {},
  });

  List<int> votersFor(String optionId) => votesByOption[optionId] ?? const [];

  bool hasVoted(int? aptNum, String optionId) =>
      aptNum != null && votersFor(optionId).contains(aptNum);

  Set<int> get uniqueVoters {
    final set = <int>{};
    for (final list in votesByOption.values) {
      set.addAll(list);
    }
    return set;
  }

  int get totalSelections {
    int sum = 0;
    for (final list in votesByOption.values) {
      sum += list.length;
    }
    return sum;
  }

  int get maxOptionVotes {
    int maxV = 0;
    for (final o in options) {
      final len = votersFor(o.id).length;
      if (len > maxV) maxV = len;
    }
    return maxV;
  }

  factory BuildingPoll.fromJson(
    Map<String, dynamic> json, {
    Map<String, List<int>> votesByOption = const {},
  }) {
    final rawOpts = json['options'];
    final parsedOpts = <PollOption>[];
    if (rawOpts is List) {
      for (final item in rawOpts) {
        if (item is Map) {
          final opt = PollOption.fromJson(Map<String, dynamic>.from(item));
          if (opt.id.isNotEmpty && opt.text.trim().isNotEmpty) {
            parsedOpts.add(opt);
          }
        }
      }
    }
    return BuildingPoll(
      id: json['id'].toString(),
      question: (json['question'] as String?) ?? '',
      options: parsedOpts,
      allowMultiple: json['allow_multiple'] == true,
      showVotersPublicly: json['show_voters_publicly'] != false,
      isClosed: json['is_closed'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      votesByOption: votesByOption,
    );
  }
}

class AppRating {
  final String id;
  final int aptNum;
  final int stars;
  final List<String> tags;
  final String comment;
  final DateTime updatedAt;

  const AppRating({
    required this.id,
    required this.aptNum,
    required this.stars,
    this.tags = const [],
    this.comment = '',
    required this.updatedAt,
  });

  factory AppRating.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final parsedTags = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        final s = t?.toString().trim() ?? '';
        if (s.isNotEmpty) parsedTags.add(s);
      }
    }
    return AppRating(
      id: (json['id'] ?? json['apt_num']).toString(),
      aptNum: (json['apt_num'] as num?)?.toInt() ?? 0,
      stars: ((json['stars'] as num?)?.toInt() ?? 5).clamp(1, 5),
      tags: parsedTags,
      comment: (json['comment'] as String?) ?? '',
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}

class EmergencyArrear {
  final String id;
  final String title;
  final double amount;
  final String details;
  final bool isCollected;
  final DateTime createdAt;
  final DateTime? collectedAt;

  const EmergencyArrear({
    required this.id,
    required this.title,
    required this.amount,
    this.details = '',
    this.isCollected = false,
    required this.createdAt,
    this.collectedAt,
  });

  factory EmergencyArrear.fromJson(Map<String, dynamic> json) {
    return EmergencyArrear(
      id: json['id'].toString(),
      title: (json['title'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      details: (json['details'] as String?) ?? '',
      isCollected: json['is_collected'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
      collectedAt: json['collected_at'] != null
          ? DateTime.tryParse(json['collected_at'].toString())
          : null,
    );
  }
}

class SpecialAptFee {
  final String id;
  final int aptNum;
  final String label;
  final double amount;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? paidAt;

  const SpecialAptFee({
    required this.id,
    required this.aptNum,
    required this.label,
    required this.amount,
    this.isPaid = false,
    required this.createdAt,
    this.paidAt,
  });

  factory SpecialAptFee.fromJson(Map<String, dynamic> json) {
    return SpecialAptFee(
      id: json['id'].toString(),
      aptNum: (json['apt_num'] as num?)?.toInt() ?? 0,
      label: (json['label'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      isPaid: json['is_paid'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
    );
  }
}

class ApartmentProfile {
  final int aptNum;
  final String displayName;
  final String floorNum;
  final String phone;
  final bool showPhoneToNeighbors;
  final bool isClosed;
  final String avatarUrl;

  const ApartmentProfile({
    required this.aptNum,
    this.displayName = '',
    this.floorNum = '',
    this.phone = '',
    this.showPhoneToNeighbors = true,
    this.isClosed = false,
    this.avatarUrl = '',
  });

  bool get hasAvatar => avatarUrl.trim().isNotEmpty;
  bool get hasPhone => phone.trim().isNotEmpty;
  bool get supportsWhatsApp =>
      phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;

  String get whatsappNumber {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) return '2$digits';
    return digits;
  }

  factory ApartmentProfile.fromJson(Map<String, dynamic> json) {
    return ApartmentProfile(
      aptNum: (json['apt_num'] as num?)?.toInt() ?? 0,
      displayName: (json['display_name'] as String?)?.trim() ?? '',
      floorNum: (json['floor_num'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      showPhoneToNeighbors: json['show_phone_to_neighbors'] as bool? ?? true,
      isClosed: json['is_closed'] as bool? ?? false,
      avatarUrl: (json['avatar_url'] as String?)?.trim() ?? '',
    );
  }
}

String localizedMonthName(int monthNum, bool isAr) {
  const arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  const enMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  if (monthNum < 1 || monthNum > 12) return '$monthNum';
  return isAr ? arMonths[monthNum - 1] : enMonths[monthNum - 1];
}
