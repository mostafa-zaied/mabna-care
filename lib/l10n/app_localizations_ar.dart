// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MABNA CARE';

  @override
  String get demoBanner =>
      'وضع التجربة المحلي — أضف بيانات Supabase في lib/config.dart للنشر الفعلي';

  @override
  String monthOption(int monthNum, int yearNum) {
    return 'شهر $monthNum ($yearNum)';
  }

  @override
  String get editBtn => 'تعديل';

  @override
  String get closeBtn => 'إغلاق';

  @override
  String billTitle(int monthNum) {
    return 'مصاريف العمارة لشهر $monthNum:';
  }

  @override
  String get copyWhatsAppBtn => 'نسخ للواتساب';

  @override
  String get waterLabel => 'مياه';

  @override
  String get elecLabel => 'كهرباء';

  @override
  String get elevLabel => 'أسانسير';

  @override
  String get cleanLabel => 'منظفات';

  @override
  String totalExpensesLine(int total, int apts) {
    return '• إجمالي المصاريف: $total ج (÷ $apts شقة)';
  }

  @override
  String get sharePerAptLabel => 'نصيب الشقة';

  @override
  String currency(int amount) {
    return '$amount ج';
  }

  @override
  String get copiedTitle => 'الرسالة المنسوخة للواتساب:';

  @override
  String get copiedToast => 'تم نسخ تفاصيل الشهر المحدثة للواتساب';

  @override
  String get aptsCountField => 'عدد الشقق:';

  @override
  String get saveChangesBtn => 'حفظ التعديلات';

  @override
  String get manageAptsBtn => 'أسماء وباسورد الشقق';

  @override
  String get tapAptTitle => 'اضغط على شقتك لتسجيل الدفع';

  @override
  String paidCounter(int paid, int total) {
    return 'دفع $paid من $total';
  }

  @override
  String defaultAptName(int num) {
    return 'شقة $num';
  }

  @override
  String get paidBadge => 'تم الدفع';

  @override
  String get pendingPaymentBadge => 'قيد الانتظار';

  @override
  String get adminLoginTitle => 'دخول المسؤول';

  @override
  String get adminPassHint => 'أدخل كلمة سر المسؤول...';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get login => 'دخول';

  @override
  String get manageAptsTitle => 'إدارة أسماء وكلمات سر الشقق';

  @override
  String get optionalName => 'الاسم (اختياري)';

  @override
  String get passcodeLabel => 'كلمة السر';

  @override
  String get saveAll => 'حفظ الكل';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String fileLabel(String name) {
    return 'الملف: $name';
  }

  @override
  String get cancelPaymentAdmin => 'إلغاء الدفع (المسؤول)';

  @override
  String get enterPassHint => 'اكتب كلمة السر...';

  @override
  String get step2Image => 'إرفاق صورة الإيصال (إجباري)';

  @override
  String get unlockAptSubtitle =>
      'أدخل كلمة سر الشقة لفتح التفاصيل (تُحفظ تلقائياً بعد أول مرة)';

  @override
  String get unlockAptBtn => 'فتح الشقة';

  @override
  String get receiptRequiredNote =>
      'يُرجى إرفاق صورة الإيصال للتحقق من المبلغ المدفوع (سواء كان مطابقاً أو أكثر أو أقل من المطلوب).';

  @override
  String get errReceiptRequired =>
      'برجاء إرفاق صورة الإيصال أولاً قبل تأكيد الدفع.';

  @override
  String get noReceiptAttached => 'تم تأكيد الدفع بدون إرفاق صورة';

  @override
  String get pickImagePrompt => 'اضغط هنا لاختيار صورة الإيصال';

  @override
  String chosenFile(String name) {
    return 'تم اختيار: $name';
  }

  @override
  String get confirmPaymentBtn => 'تأكيد الدفع';

  @override
  String get uploadingBtn => 'جاري الرفع...';

  @override
  String get addApartmentBtn => '+ إضافة شقة جديدة';

  @override
  String get navExpenses => 'المصاريف';

  @override
  String get navEmergency => 'صندوق الطوارئ';

  @override
  String get writeComplaintHint => 'اكتب الشكوى هنا...';

  @override
  String get writeImprovementHint => 'اكتب اقتراحك لتحسين العمارة...';

  @override
  String get postAnonymously => 'إرسال بدون اسم (مجهول)';

  @override
  String get selectApartment => 'اختر الشقة';

  @override
  String get submitPostBtn => 'إرسال';

  @override
  String get anonymousAuthor => 'بدون اسم (مجهول)';

  @override
  String get noPostsYet => 'لا توجد مشاركات بعد';

  @override
  String get postAddedToast => 'تم الإرسال بنجاح';

  @override
  String get deleteTooltip => 'حذف';

  @override
  String errLoadData(String err) {
    return 'تعذر تحميل البيانات: $err';
  }

  @override
  String get monthSavedToast => 'تم حفظ تعديلات الشهر بنجاح';

  @override
  String get paymentCancelledToast => 'تم إلغاء الدفع';

  @override
  String get aptsSavedToast => 'تم حفظ أسماء وكلمات سر الشقق بنجاح';

  @override
  String get errNoMonth => 'لا يوجد شهر محدد';

  @override
  String get errWrongAdminPass => 'كلمة سر المسؤول غير صحيحة';

  @override
  String get errWrongAptPass => 'كلمة سر الشقة غير صحيحة';

  @override
  String errWrongAptPassHint(String hint) {
    return 'كلمة سر الشقة غير صحيحة (جرب $hint)';
  }

  @override
  String get errPaymentFailed => 'تعذر تسجيل الدفع';

  @override
  String get errCancelFailed => 'تعذر إلغاء الدفع';

  @override
  String get errAptLoadFailed => 'تعذر تحميل بيانات الشقق';

  @override
  String get errAptSaveFailed => 'تعذر حفظ بيانات الشقة';

  @override
  String get errEmptyMessage => 'الرسالة فارغة';

  @override
  String get errSubmitFailed => 'تعذر إرسال المشاركة';

  @override
  String get errDeleteFailed => 'تعذر الحذف';

  @override
  String get addNextMonthBtn => 'إضافة الشهر القادم';

  @override
  String get monthAddedToast => 'تم إضافة الشهر القادم بنجاح';

  @override
  String get pinAptPrompt => 'ثبّت رقم شقتك للدفع السريع';

  @override
  String get selectAptBtn => 'اختر شقتك';

  @override
  String get myAptPrefix => 'شقتي';

  @override
  String get payNowBtn => 'ادفع الآن';

  @override
  String get changeAptTooltip => 'تغيير الشقة';

  @override
  String get emergencyLogTitle => 'سجل حركات صندوق الطوارئ';

  @override
  String get emergencyLogEmpty => 'لا توجد مصروفات مسجلة من الصندوق حتى الآن.';

  @override
  String get emergencyAmountHint => 'المبلغ';

  @override
  String get emergencyReasonHint => 'السبب (مثال: صيانة موتور المياه)';

  @override
  String get recordExpenseBtn => 'تسجيل صرف من الطوارئ';

  @override
  String get errEmergencyInput => 'من فضلك اكتب المبلغ والسبب أولاً.';

  @override
  String get errEmergencySave =>
      'تعذر تسجيل الحركة. تأكد من تشغيل supabase_updates.sql';

  @override
  String get pinNoticeBtn => 'تثبيت إعلان';

  @override
  String get noticeDialogTitle => 'تثبيت إعلان أو تنبيه هام';

  @override
  String get noticeDialogHint => 'مثال: صيانة الأسانسير يوم الخميس من 10 لـ 12';

  @override
  String get hideNoticeBtn => 'إخفاء الإعلان';

  @override
  String get adminReplyLabel => 'رد الإدارة:';

  @override
  String get updateStatusTitle => 'تحديث الحالة والرد';

  @override
  String get statusFieldLabel => 'الحالة';

  @override
  String get adminReplyHint => 'رد الإدارة (اختياري)...';

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusInProgress => 'جاري التنفيذ';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get adminLogoutBtn => 'تسجيل خروج المدير';

  @override
  String get emergencyTabWithdraw => 'صرف';

  @override
  String get emergencyTabDeposit => 'إضافة';

  @override
  String get emergencyDepositReasonHint =>
      'السبب (مثال: مساهمة إضافية أو فائض)';

  @override
  String get recordDepositBtn => 'تسجيل إضافة للطوارئ';

  @override
  String get removeMonthBtn => 'حذف الشهر';

  @override
  String get monthDeletedToast => 'تم حذف الشهر بنجاح';

  @override
  String get errCannotDeleteLastMonth => 'لا يمكن حذف آخر شهر متبقي';

  @override
  String get deleteMonthConfirmTitle => 'حذف الشهر الحالي؟';

  @override
  String deleteMonthConfirmBody(int month, int year) {
    return 'سيتم حذف شهر $month ($year) وجميع مدفوعاته نهائياً.';
  }

  @override
  String get splashTagline => 'عمارتك.. مسؤوليتنا.';

  @override
  String get confirmDeleteTitle => 'تأكيد الحذف';

  @override
  String get confirmDeleteBtn => 'حذف';

  @override
  String confirmDeleteAptBody(String apt) {
    return 'هل تريد حذف \"$apt\"؟';
  }

  @override
  String confirmDeleteTxBody(String amount) {
    return 'هل تريد حذف هذه الحركة ($amount)؟';
  }

  @override
  String get confirmDeletePostBody => 'هل تريد حذف هذه المشاركة نهائياً؟';

  @override
  String confirmCancelPaymentBody(String apt) {
    return 'هل تريد إلغاء تسجيل دفع \"$apt\"؟';
  }

  @override
  String get instapayTitle => 'التحويل عبر InstaPay';

  @override
  String get instapaySubtitle => 'حوّل على الرقم التالي ثم ارفع الإيصال';

  @override
  String get openInstapayBtn => 'فتح InstaPay';

  @override
  String get extraChargesBtn => 'رسوم إضافية لشقق';

  @override
  String get extraChargesTitle => 'رسوم إضافية خاصة بشقق';

  @override
  String get selectAptsLabel => 'اختر الشقة أو الشقق:';

  @override
  String get extraAmountHint => 'المبلغ الإضافي لكل شقة';

  @override
  String get extraReasonHint => 'السبب (مثال: تصليح كالون أو محبس)';

  @override
  String get addExtraChargeBtn => 'إضافة الرسوم';

  @override
  String get extraChargesListTitle => 'الرسوم الإضافية المسجلة لهذا الشهر:';

  @override
  String get noExtraChargesYet => 'لا توجد رسوم إضافية مسجلة لهذا الشهر.';

  @override
  String get monthShareLine => 'نصيب الشهر';

  @override
  String get totalDueLabel => 'الإجمالي المطلوب';

  @override
  String confirmDeleteExtraBody(String amount) {
    return 'هل تريد حذف هذا البند الإضافي ($amount)؟';
  }

  @override
  String get extraChargeAddedToast => 'تم إضافة الرسوم الإضافية';

  @override
  String extraBadge(int amount) {
    return '+$amount إضافي';
  }

  @override
  String get settingsBtn => 'الإعدادات (Settings)';

  @override
  String get settingsTitle => 'إعدادات المدير (Settings)';

  @override
  String get settingsShortTitle => 'الإعدادات';

  @override
  String get adminOnlyPageMsg => 'هذه الصفحة متاحة للمدير فقط.';

  @override
  String get requirePassOnOpenTitle => 'طلب كلمة سر الشقة قبل فتح التفاصيل';

  @override
  String get statusEnabled => 'مُفعّل حالياً';

  @override
  String get statusDisabled => 'مُعطّل حالياً';

  @override
  String get requirePassOnOpenDescOn =>
      'عند التفعيل: يُجبر الساكن على إدخال كلمة سر الشقة من الخارج أول مرة قبل رؤية تفاصيل شقته أو الدفع، ولا يمكنه فتح شقق أخرى.';

  @override
  String get requirePassOnOpenDescOff =>
      'عند الإيقاف: تفتح تفاصيل أي شقة مباشرة بدون طلب كلمة سر من الخارج، ويتم إدخال كلمة السر داخل نافذة الدفع فقط.';

  @override
  String get buildingMonthMgmtTitle => 'إدارة العمارة والشهور';

  @override
  String selectedMonthBadge(String monthName, int monthNum, int yearNum) {
    return 'المحدد: $monthName ($monthNum/$yearNum)';
  }

  @override
  String get addNextMonthConfirmTitle => 'إضافة شهر جديد؟';

  @override
  String addNextMonthConfirmBody(String monthName, int monthNum, int yearNum) {
    return 'سيتم إضافة شهر $monthName ($monthNum / $yearNum) إلى قائمة الشهور. هل تريد المتابعة؟';
  }

  @override
  String addNextMonthConfirmBtn(String monthName, int monthNum, int yearNum) {
    return 'إضافة $monthName ($monthNum/$yearNum)';
  }

  @override
  String monthAddedNamedToast(String monthName, int monthNum, int yearNum) {
    return '✅ تم إضافة شهر $monthName ($monthNum/$yearNum) بنجاح';
  }

  @override
  String get adminViewsTitle => 'إحصائيات';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String get viewsStatsLoadingHint =>
      'اضغط تحديث لعرض الإحصائيات (تأكد من تشغيل SQL في Supabase)';

  @override
  String get viewsHeroSubtitle => 'متابعة حية لنشاط وزيارات السكان على التطبيق';

  @override
  String get viewsTotalLabel => 'إجمالي الفتح';

  @override
  String get viewsTotalSubtitle => 'إجمالي مرات فتح التطبيق منذ الإطلاق';

  @override
  String get viewsUniqueLabel => 'زوار فريدون';

  @override
  String get viewsUniqueSubtitle => 'أجهزة مختلفة فتحت التطبيق';

  @override
  String get viewsTodayLabel => 'زيارات اليوم';

  @override
  String get viewsTodaySubtitle => 'مرات الفتح خلال اليوم الحالي';

  @override
  String get viewsAvgPerVisitorLabel => 'متوسط الفتح لكل زائر';

  @override
  String get navFeedback => 'آراء';

  @override
  String get navFeedbackFull => 'الشكاوى والمقترحات';

  @override
  String tabViewAllPosts(int count) {
    return 'عرض المشاركات ($count)';
  }

  @override
  String get tabAddPost => 'إضافة شكوى / مقترح';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterComplaints => '📢 الشكاوى';

  @override
  String get filterSuggestions => '💡 المقترحات';

  @override
  String get postTypeLabel => 'النوع';

  @override
  String get typeComplaint => '📢 شكوى';

  @override
  String get typeSuggestion => '💡 مقترح';

  @override
  String get errEmptyFeedbackMsg => 'يجب إدخال نص الشكوى أو المقترح أولاً';

  @override
  String get viewBillReceiptBtn => 'عرض الفاتورة';

  @override
  String get attachBillAfterPayBtn => 'إرفاق بعد الدفع';

  @override
  String get utilityPendingBadge => 'بانتظار السداد';

  @override
  String utilityBillLabel(String utility) {
    return 'فاتورة $utility';
  }

  @override
  String get waterBillLabel => 'فاتورة المياه';

  @override
  String get elecBillLabel => 'فاتورة الكهرباء';

  @override
  String utilityReceiptDialogTitle(String utility) {
    return 'صورة $utility';
  }

  @override
  String get removeUtilityReceiptBtn => 'حذف الفاتورة';

  @override
  String get utilityReceiptSavedToast => 'تم حفظ صورة الفاتورة بنجاح';

  @override
  String get utilityReceiptRemovedToast => 'تم حذف صورة الفاتورة';

  @override
  String get navContactsFull => 'أرقام الصيانة';

  @override
  String get navContactsShort => 'الصيانة';

  @override
  String get contactsTitle => 'أرقام الصيانة للعمارة';

  @override
  String get contactsSubtitle =>
      'يمكن لأي ساكن إضافة رقم فني أو صيانة معتمد للعمارة.';

  @override
  String get addContactBtn => 'إضافة رقم';

  @override
  String get addContactTitle => 'إضافة رقم صيانة';

  @override
  String get contactNameLabel => 'الاسم / الجهة';

  @override
  String get contactNameHint => 'مثال: م/ خالد — كهربائي';

  @override
  String get contactRoleLabel => 'التخصص / الوصف';

  @override
  String get contactRoleHint => 'مثال: أعطال السلم والموتور';

  @override
  String get contactPhoneLabel => 'رقم الهاتف';

  @override
  String get contactPhoneHint => '01012345678';

  @override
  String get callBtn => 'اتصال';

  @override
  String get whatsappBtn => 'واتساب';

  @override
  String get errContactFields => 'برجاء كتابة الاسم ورقم الهاتف أولاً.';

  @override
  String get contactAddedToast => 'تمت إضافة الرقم بنجاح';

  @override
  String confirmDeleteContactBody(String name) {
    return 'هل تريد حذف \"$name\" من قائمة الأرقام؟';
  }

  @override
  String get noContactsYet => 'لا توجد أرقام مسجلة بعد.';

  @override
  String get deleteAllExtraChargesBtn => 'حذف الكل';

  @override
  String get confirmDeleteAllExtraBody =>
      'هل تريد حذف جميع الرسوم الإضافية المسجلة لهذا الشهر من كل الشقق؟';

  @override
  String get selectAllBtn => 'تحديد الكل';

  @override
  String get deselectAllBtn => 'إلغاء الكل';

  @override
  String get errSelectAtLeastOneApt =>
      'من فضلك اختر شقة على الأقل لإضافة الرسوم.';

  @override
  String get setupAptPassSubtitle => 'تعيين كلمة سر شقتك لأول مرة';

  @override
  String get setupAptPassHint =>
      'اختر كلمة سر خاصة بشقتك (4 أحرف أو أرقام على الأقل). ستُحفظ على جهازك، وإذا نسيتها تواصل مع مدير العمارة.';

  @override
  String get newPasscodeLabel => 'كلمة السر الجديدة';

  @override
  String get confirmPasscodeLabel => 'تأكيد كلمة السر';

  @override
  String get saveAndUnlockBtn => 'حفظ وفتح الشقة';

  @override
  String get errPassTooShort => 'كلمة السر يجب أن تكون 4 أحرف/أرقام على الأقل.';

  @override
  String get errPassMismatch => 'كلمتا السر غير متطابقتين.';

  @override
  String get errPassAlreadySet => 'تم تعيين كلمة سر لهذه الشقة بالفعل.';

  @override
  String get forgotPassHint =>
      'نسيت كلمة السر؟ تواصل مع مدير العمارة لإعادة تعيينها.';

  @override
  String get resetPassBtn => 'إعادة تعيين';

  @override
  String get passNotSetYet => 'لم يُعيّنها الساكن بعد';

  @override
  String get resetAllPasswordsBtn => 'إعادة تعيين كل كلمات السر';

  @override
  String get confirmResetAllPasswordsBody =>
      'هل تريد إعادة تعيين كلمة السر لجميع الشقق؟ سيُطلب من كل ساكن تعيين كلمة سر جديدة.';

  @override
  String get allPasswordsResetToast =>
      'تمت إعادة تعيين كلمات السر لجميع الشقق بنجاح';

  @override
  String get drawerExtraSections => 'أقسام إضافية';

  @override
  String get drawerPreferences => 'تفضيلات التطبيق';

  @override
  String get drawerThemeLabel => 'المظهر';

  @override
  String get drawerThemeDark => 'ليلي';

  @override
  String get drawerThemeLight => 'نهاري';

  @override
  String get drawerLanguageLabel => 'اللغة';

  @override
  String get drawerAdminSection => 'الإدارة';

  @override
  String get drawerAdminLogin => 'دخول المسؤول';

  @override
  String get contactManagerBtn => 'تواصل مع المسؤول';

  @override
  String drawerMyAptLabel(String apt) {
    return 'شقتك: $apt';
  }

  @override
  String get digitalReceiptTitle => 'إيصال الدفع الإلكتروني';

  @override
  String get digitalReceiptBrand => 'MABNA CARE • إيصال سداد معتمد';

  @override
  String get digitalReceiptStatus => 'تم السداد بنجاح';

  @override
  String get receiptAptLabel => 'الشقة';

  @override
  String get receiptMonthLabel => 'عن شهر';

  @override
  String get receiptPaidAtLabel => 'تاريخ السداد';

  @override
  String get receiptTotalPaidLabel => 'الإجمالي المدفوع';

  @override
  String get receiptStampTitle => 'معتمد إلكترونياً';

  @override
  String get receiptSaveImageBtn => 'حفظ كصورة';

  @override
  String get receiptSavedToast => 'تم حفظ صورة الإيصال بنجاح';

  @override
  String get receiptSaveNotSupported =>
      'يمكنك أخذ لقطة شاشة (Screenshot) لحفظ الإيصال';

  @override
  String get viewDigitalReceiptBtn => 'عرض إيصال MABNA CARE الإلكتروني';

  @override
  String get navAnalytics => 'التحليلات';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get analyticsAvgShare => 'متوسط الشقة';

  @override
  String get analyticsCollectionRate => 'نسبة التحصيل';

  @override
  String get analyticsEmergencyBalance => 'رصيد الطوارئ';

  @override
  String get analyticsChartTitle => 'مقارنة مصاريف الشهور';

  @override
  String get analyticsChartHint => 'اضغط على أي شهر لعرض توزيع مصاريفه';

  @override
  String analyticsBreakdownTitle(String month) {
    return 'توزيع مصاريف شهر $month';
  }

  @override
  String analyticsCollectionCardTitle(String month) {
    return 'حالة تحصيل شهر $month';
  }

  @override
  String get analyticsCollectedLabel => 'تم تحصيله';

  @override
  String get analyticsRemainingLabel => 'المتبقي';

  @override
  String analyticsInsightLower(String month, String pct, String diff) {
    return 'مصاريف $month أقل بنسبة $pct% عن الشهر السابق (وفر $diff ج)';
  }

  @override
  String analyticsInsightHigher(String month, String pct, String diff) {
    return 'مصاريف $month أعلى بنسبة $pct% عن الشهر السابق (+$diff ج)';
  }

  @override
  String analyticsInsightSame(String month) {
    return 'مصاريف $month مطابقة تماماً للشهر السابق';
  }

  @override
  String analyticsInsightSingle(
    String month,
    String share,
    int paid,
    int total,
  ) {
    return 'نصيب الشقة في $month: $share ج • دفع $paid من $total';
  }

  @override
  String get analyticsNoData => 'لا توجد بيانات شهور كافية للتحليل بعد.';

  @override
  String get pushCardTitle => 'إرسال إشعار فوري للسكان';

  @override
  String get pushCardSubtitle =>
      'أرسل تنبيهاً مباشراً لكل السكان المسجلين من هنا.';

  @override
  String get pushTitleLabel => 'عنوان الإشعار';

  @override
  String get pushTitleHint => 'مثال: تذكير بمصاريف الشهر أو صيانة الأسانسير';

  @override
  String get pushBodyLabel => 'نص الإشعار';

  @override
  String get pushBodyHint => 'اكتب تفاصيل الإشعار هنا...';

  @override
  String get pushSendAllBtn => 'إرسال لكل السكان 🚀';

  @override
  String get errPushFieldsRequired => 'برجاء كتابة عنوان الإشعار والنص أولاً.';

  @override
  String get pushSentSuccessToast => 'تم إرسال الإشعار بنجاح';

  @override
  String get pushNoDevicesToast => 'لا توجد أجهزة مفعّلة للإشعارات بعد';

  @override
  String get pushNotConfiguredToast =>
      'تم تجهيز الإشعارات — يتبقى فقط إضافة مفتاح Firebase في Supabase';

  @override
  String get pushSendFailedToast => 'تعذر إرسال الإشعار حالياً';

  @override
  String get pushAutoAnnouncementTitle => '📢 إعلان هام من إدارة العمارة';

  @override
  String get pushAutoNewMonthTitle => '🗓️ نزول مصاريف الشهر الجديد';

  @override
  String pushAutoNewMonthBody(String month) {
    return 'تم إضافة مصاريف $month — ادخل على MABNA CARE لمعرفة نصيب شقتك.';
  }

  @override
  String get pushAutoPaymentTitle => '🧾 تم تسجيل دفع جديد';

  @override
  String pushAutoPaymentBody(String apt) {
    return '$apt: تم رفع إيصال سداد مصاريف الشهر';
  }

  @override
  String get pushAutoFeedbackTitle => '💬 مشاركة جديدة من السكان';

  @override
  String get drawerNotificationsLabel => 'الإشعارات';

  @override
  String get pushEnabledBadge => 'مُفعّلة';

  @override
  String get pushEnableAction => 'غير مفعّلة';

  @override
  String get pushEnabledToast => '🔔 تم تفعيل الإشعارات على جهازك بنجاح';

  @override
  String get pushBlockedToast =>
      'تعذر تفعيل الإشعارات (تأكد من السماح للإشعارات من إعدادات المتصفح أو إضافة التطبيق للشاشة الرئيسية في iPhone)';

  @override
  String get pushAudienceAdminOnly => 'للمدير فقط (تجربة)';

  @override
  String get pushAudienceAll => 'لكل السكان';

  @override
  String get pushSendAdminTestBtn => 'إرسال تجربة للمدير 🛡️';

  @override
  String get offlineBannerMsg => 'لا يوجد اتصال بالإنترنت حالياً';

  @override
  String get onlineRestoredToast => 'عاد الاتصال بالإنترنت بنجاح';

  @override
  String get noNetworkTitle => 'تعذر الاتصال بالإنترنت';

  @override
  String get noNetworkSubtitle =>
      'تأكد من اتصالك بالإنترنت ثم اضغط إعادة المحاولة.';

  @override
  String get retryBtn => 'إعادة المحاولة';

  @override
  String get installAppNavLabel => 'طريقة تثبيت التطبيق';

  @override
  String get installAppTitle => 'طريقة تثبيت MABNA CARE كتطبيق';

  @override
  String get installAppSubtitle =>
      'ثبّت التطبيق على شاشة موبايلك الرئيسية ليفتح بضغطة واحدة بدون متصفح ويستقبل الإشعارات الفورية.';

  @override
  String get installAppNowBtn => 'تثبيت التطبيق الآن';

  @override
  String get installAppAlreadyInstalled => 'التطبيق مثبّت بالفعل على جهازك ✅';

  @override
  String get installAndroidTitle => 'طريقة التثبيت على أندرويد (Chrome)';

  @override
  String get installAndroidStep1 =>
      'اضغط على النقاط الثلاث (⋮) أعلى يسار أو يمين متصفح Chrome.';

  @override
  String get installAndroidStep2 =>
      'اختر \"Install app\" أو \"Install and create shortcut\" ثم اختر \"Install\".';

  @override
  String get installAndroidStep3 =>
      'اضغط \"Install\" في النافذة التي ستظهر — وسيُضاف التطبيق بأيقونته على شاشتك الرئيسية.';

  @override
  String get installIosTitle => 'طريقة التثبيت على آيفون (Safari)';

  @override
  String get installIosStep1 => 'تأكد من فتح الرابط في متصفح Safari.';

  @override
  String get installIosStep2 =>
      'اضغط على أيقونة المشاركة (Share) في أسفل الشاشة.';

  @override
  String get installIosStep3 =>
      'اختر \"Add to Home Screen\" (إضافة إلى الشاشة الرئيسية) ثم اضغط \"Add\".';

  @override
  String get notifHistoryTitle => 'سجل الإشعارات';

  @override
  String get notifMarkAllReadBtn => 'تحديد الكل كمقروء ✓';

  @override
  String notifFilterAll(int count) {
    return 'الكل ($count)';
  }

  @override
  String notifFilterUnread(int count) {
    return 'غير مقروء ($count)';
  }

  @override
  String get notifEmptyAll => 'لا توجد إشعارات مرسلة حتى الآن.';

  @override
  String get notifEmptyUnread => 'لا توجد إشعارات غير مقروءة 🎉';

  @override
  String get notifTypeAnnouncement => 'إعلان هام';

  @override
  String get notifTypeNewMonth => 'مصاريف الشهر';

  @override
  String get notifTypePayment => 'سداد شقة';

  @override
  String get notifTypeFeedback => 'شكاوى ومقترحات';

  @override
  String get notifTypeGeneral => 'تنبيه الإدارة';

  @override
  String get confirmDeleteNotifBody => 'هل تريد حذف هذا الإشعار من السجل؟';

  @override
  String get addCustomExpenseBtn => 'إضافة بند مصاريف';

  @override
  String get addCustomExpenseTitle => 'إضافة بند مصاريف جديد';

  @override
  String get customExpenseNameLabel => 'اسم البند';

  @override
  String get customExpenseNameHint => 'مثال: بواب، صيانة موتور، غاز...';

  @override
  String get customExpenseAmountLabel => 'المبلغ (ج)';

  @override
  String get customExpenseAddedToast => 'تم إضافة البند وحسابه ضمن المصاريف';

  @override
  String get customExpenseRemovedToast => 'تم حذف البند وتحديث الحسابات';

  @override
  String get addBtn => 'إضافة';

  @override
  String get deleteOwnReceiptBtn => 'حذف الإيصال وإعادة الرفع';

  @override
  String get confirmDeleteOwnReceiptBody =>
      'هل تريد حذف صورة الإيصال وإعادة الشقة لحالة غير مدفوع لرفع صورة جديدة؟';

  @override
  String get paymentReceiptDeletedToast =>
      'تم حذف الإيصال، يمكنك الآن رفع صورة جديدة';

  @override
  String dueDateBanner(int month, int day) {
    return 'آخر موعد لسداد مصاريف شهر $month هو يوم $day';
  }

  @override
  String dueDatePassedBanner(int month, int day) {
    return 'انتهى موعد سداد مصاريف شهر $month (يوم $day) — يرجى سرعة السداد';
  }

  @override
  String get overdueBadge => 'متأخر عن السداد';

  @override
  String overdueCountPill(int count) {
    return '$count متأخر';
  }

  @override
  String get dueDayField => 'آخر موعد (يوم)';

  @override
  String get pushAudienceSpecificApt => 'لشقة محددة';

  @override
  String get pushAudienceUnpaid => 'للمتأخرين فقط';

  @override
  String get pushSelectAptsHint =>
      'اختر الشقة أو الشقق (🔔 تعني أن الإشعارات مفعّلة لديها):';

  @override
  String pushUnpaidSummary(int count, int month) {
    return 'سيتم الإرسال لـ $count شقة لم تسدد مصاريف شهر $month';
  }

  @override
  String get pushAllPaidHint => 'جميع الشقق سددت مصاريف الشهر الحالي 🎉';

  @override
  String get pushErrSelectApt => 'اختر شقة واحدة على الأقل للإرسال';

  @override
  String pushSendSelectedBtn(int count) {
    return 'إرسال للشقق المختارة ($count)';
  }

  @override
  String pushSendUnpaidBtn(int count) {
    return 'إرسال تذكير للمتأخرين ($count)';
  }

  @override
  String pushDefaultUnpaidTitle(int month) {
    return 'تذكير بسداد مصاريف شهر $month';
  }

  @override
  String pushDefaultUnpaidBody(int month) {
    return 'يرجى التكرم بسداد مصاريف العمارة لشهر $month ورفع صورة الإيصال عبر التطبيق.';
  }

  @override
  String get adminPrankBioTitle => '🔐 نظام الحماية البيومتري';

  @override
  String get adminPrankBioSub =>
      'ضع إصبعك على الماسح للتحقق من بصمة مدير العمارة';

  @override
  String get adminPrankBioPrompt => 'اضغط على البصمة للتحقق...';

  @override
  String get adminPrankBioScanning =>
      'جاري مطابقة البصمة مع ملفات المخابرات... ⏳';

  @override
  String get adminPrankBioSkip => 'دخول بكلمة السر (للمدير)';

  @override
  String get adminPrankCaughtTitle => 'قفشناك يا جار!';

  @override
  String get adminPrankCaughtBody =>
      'تم تسجيل محاولة انقلاب على الإدارة، وهيتضاف 10 جنيه رسوم فضول على شقتك الشهر الجاي!';

  @override
  String get adminPrankCaughtBackBtn => 'خلاص توبت، ارجع للرئيسية';

  @override
  String get adminPrankCaughtRealBtn => 'أنا المدير فعلاً (إدخال كلمة السر)';

  @override
  String get adminPrankRoast1 => 'غلط يا فندم، بتجرب حظك ولا إيه؟';

  @override
  String get adminPrankRoast2 =>
      'غلط للمرة التانية! واضح إنك حافظ طريق زرار الدخول مش كلمة السر.';

  @override
  String adminPrankRoast3(String attempt) {
    return '🚨 قفشناك تاني! واضح إنك مصمم تهكّر العمارة — الباسورد مش $attempt أكيد';
  }

  @override
  String get adminPrankRoast4 =>
      'خلاص يا نجم ارحم الكيبورد، واضح إنك مش المدير فعلاً!';

  @override
  String adminPrankCooldown(int seconds) {
    return 'استنى $seconds ثواني تهدى وترجع لوعيك';
  }

  @override
  String get changeAdminPassTitle => 'تغيير كلمة سر المدير';

  @override
  String get changeAdminPassSubtitle =>
      'حدّث كلمة السر مباشرة من التطبيق بأمان';

  @override
  String get currentAdminPassLabel => 'كلمة السر الحالية';

  @override
  String get newAdminPassLabel => 'كلمة السر الجديدة';

  @override
  String get confirmNewAdminPassLabel => 'تأكيد كلمة السر الجديدة';

  @override
  String get changeAdminPassSecurityNote =>
      'بمجرد الحفظ، يتم تحديث كلمة السر في قاعدة البيانات وتسجيل خروج أي جهاز آخر تلقائياً.';

  @override
  String get changeAdminPassBtn => 'حفظ كلمة السر الجديدة';

  @override
  String get changeAdminPassFieldsRequired =>
      'يرجى إدخال كلمة السر الحالية والجديدة وتأكيدها.';

  @override
  String get changeAdminPassSuccessToast => '✅ تم تغيير كلمة سر المدير بنجاح';

  @override
  String get passStrengthWeak => 'ضعيفة';

  @override
  String get passStrengthMedium => 'متوسطة';

  @override
  String get passStrengthStrong => 'قوية ✓';

  @override
  String get monthlyReportBtn => 'كشف الحساب (صورة)';

  @override
  String get monthlyReportScreenTitle => 'كشف الحساب الشهري';

  @override
  String get reportDocSubtitle => 'كشف الحساب المالي الشهري للعمارة';

  @override
  String reportIssuedLabel(String date) {
    return 'تاريخ الإصدار: $date';
  }

  @override
  String get reportSectionExpenses => 'تفصيل مصاريف الشهر';

  @override
  String get reportSectionApts => 'كشف سداد الشقق';

  @override
  String get reportColApt => 'الشقة';

  @override
  String get reportColDue => 'المطلوب';

  @override
  String get reportColStatus => 'الحالة';

  @override
  String get reportTotalRow => 'الإجمالي';

  @override
  String get reportTotalExpensesKpi => 'إجمالي المصاريف';

  @override
  String get reportEmergencyBalanceTitle => 'رصيد صندوق الطوارئ الحالي';

  @override
  String get reportSavePngBtn => 'حفظ كشف الحساب كصورة للواتساب';

  @override
  String get reportSavedToast => '✅ تم حفظ صورة كشف الحساب بنجاح';

  @override
  String get reportChipExpenses => 'المصاريف';

  @override
  String get reportChipApts => 'الشقق';

  @override
  String get reportChipEmergency => 'الطوارئ';

  @override
  String reportAptsCountUnit(int count) {
    return '$count شقة';
  }

  @override
  String contactAddedByAptLabel(String apt) {
    return 'أضيف بواسطة: $apt';
  }

  @override
  String get contactAddedByAdmin => 'المدير';

  @override
  String get contactSelectYourAptLabel => 'رقم شقتك';

  @override
  String get contactSelectYourAptHint => 'اختر شقتك';

  @override
  String get errContactSelectApt => 'يرجى اختيار رقم شقتك أولاً';

  @override
  String get contactCardPhotoLabel => 'صورة الكارت (اختياري)';

  @override
  String get contactTakePhotoBtn => 'تصوير الكارت';

  @override
  String get contactPickGalleryBtn => 'من المعرض';

  @override
  String get contactPhoneOptionalHint =>
      'أو اتركه فارغاً عند إرفاق صورة الكارت';

  @override
  String get errContactNameOrCardRequired =>
      'يرجى إدخال الاسم مع رقم الهاتف أو صورة الكارت';

  @override
  String get contactTapToZoomHint => 'اضغط لتكبير الكارت';

  @override
  String get contactViewCardBtn => 'عرض الكارت بالحجم الكامل';

  @override
  String get renameExpenseTitle => 'تعديل اسم البند';

  @override
  String get expenseRenamedToast => '✅ تم تعديل اسم البند بنجاح';

  @override
  String get editContactTitle => 'تعديل رقم الصيانة';

  @override
  String get contactUpdatedToast => '✅ تم تعديل رقم الصيانة بنجاح';

  @override
  String get contactDeletedToast => 'تم حذف رقم الصيانة';

  @override
  String get contactsTabNumbers => 'الأرقام';

  @override
  String get contactsTabCards => 'الكروت والصور';

  @override
  String get noContactCardsYet => 'لا توجد كروت أو صور مضافة بعد';

  @override
  String get navPolls => 'تصويتات العمارة';

  @override
  String get pollsTitle => 'تصويتات وقرارات العمارة';

  @override
  String get pollsSubtitle => 'صوت واحد لكل شقة — خيارات مرنة ونتائج فورية';

  @override
  String get pollsTabOpen => 'المفتوحة';

  @override
  String get pollsTabClosed => 'المغلقة والنتائج';

  @override
  String get newPollBtn => 'تصويت جديد';

  @override
  String get createPollTitle => 'إنشاء تصويت جديد';

  @override
  String get pollQuestionLabel => 'سؤال التصويت';

  @override
  String get pollQuestionHint => 'مثال: ما هو الميعاد الأنسب لغسيل الخزان؟';

  @override
  String get pollPresetsLabel => 'قوالب سريعة (اختياري)';

  @override
  String get pollPresetYesNo => 'نعم / لا';

  @override
  String get pollPresetAgree3 => 'موافق / غير موافق / محايد';

  @override
  String get pollPresetDays => 'الجمعة / السبت / الخميس';

  @override
  String get pollPresetBudget => 'من الطوارئ / تقسيم / تأجيل';

  @override
  String get pollOptionsLabel => 'خيارات الإجابة';

  @override
  String pollOptionHint(int num) {
    return 'الخيار رقم $num';
  }

  @override
  String get pollAddOptionBtn => 'إضافة خيار جديد';

  @override
  String get pollAllowMultipleLabel => 'السماح باختيار أكثر من إجابة';

  @override
  String get pollShowVotersLabel => 'إظهار الشقق المصوّتة للجميع';

  @override
  String get pollNotifyResidentsLabel => 'إرسال إشعار لكل السكان عند النشر';

  @override
  String get pollPublishBtn => 'نشر التصويت';

  @override
  String get pollOpenBadge => 'مفتوح للتصويت';

  @override
  String get pollClosedBadge => 'مغلق';

  @override
  String get pollMultiBadge => 'اختيار متعدد';

  @override
  String get pollSingleBadge => 'اختيار واحد';

  @override
  String get pollSecretBadge => 'تصويت سري';

  @override
  String pollOptionsCount(int count) {
    return '$count خيارات';
  }

  @override
  String pollVotesCount(int count) {
    return '$count صوت';
  }

  @override
  String pollParticipation(int voted, int total) {
    return 'شارك $voted / $total شقة';
  }

  @override
  String get pollShowVotersBtn => 'عرض مين صوّت';

  @override
  String get pollHideVotersBtn => 'إخفاء الشقق';

  @override
  String get pollCloseBtn => 'إغلاق';

  @override
  String get pollReopenBtn => 'إعادة فتح';

  @override
  String get pollNoOpenYet => 'لا توجد تصويتات مفتوحة حالياً';

  @override
  String get pollNoClosedYet => 'لا توجد تصويتات مغلقة بعد';

  @override
  String get pollCreatedToast => '✅ تم نشر التصويت بنجاح';

  @override
  String get pollVotedToast => '✅ تم تسجيل صوتك بنجاح';

  @override
  String get pollClosedToast => 'تم إغلاق التصويت واعتماد النتيجة';

  @override
  String get pollReopenedToast => 'تم إعادة فتح التصويت';

  @override
  String get pollDeletedToast => 'تم حذف التصويت';

  @override
  String get errPollQuestionRequired => 'يرجى كتابة سؤال التصويت';

  @override
  String get errPollMinTwoOptions => 'يرجى كتابة خيارين على الأقل';

  @override
  String get errPollLoginAptFirst => 'يرجى تسجيل شقتك أولاً للتصويت';

  @override
  String get confirmDeletePollBody =>
      'هل أنت متأكد من حذف هذا التصويت نهائياً؟';

  @override
  String get pushAutoNewPollTitle => 'تصويت جديد للعمارة';

  @override
  String pushAutoNewPollBody(String question) {
    return 'شارك برأيك الآن: $question';
  }

  @override
  String get getMabnaForBuildingBtn => 'رشّح MABNA CARE لجارك أو قريبك';

  @override
  String get getMabnaFreeMonthBadge => 'شهر مجاني';

  @override
  String get footerGetAppCta =>
      'عاجبك النظام؟ رشّح MABNA CARE لعمارة قريبك أو صاحبك — أول شهر مجاناً';

  @override
  String get referralShareMessage =>
      'شوف النظام اللي شغالين بيه في عمارتنا لتنظيم المصاريف والإيصالات والتصويتات — بصراحة ريّحنا من خناقات جروب الواتساب!\nده لينك عمارتنا خد نظرة فيه:\nhttps://mabna-care.web.app/\n\nوجرّبوه لعمارتكم مجاناً أول شهر من هنا:\nhttps://mabna-care.web.app/landing.html';

  @override
  String get contactPickFromDeviceTooltip => 'اختيار من جهات الاتصال';

  @override
  String get contactPickerUnsupportedHint =>
      'الاختيار المباشر من جهات الاتصال متاح على متصفح Chrome للموبايل (Android) — يمكنك لصق الرقم مباشرة هنا.';

  @override
  String get residentAuthRequiredTitle => 'متاح لسكان العمارة فقط';

  @override
  String get residentAuthRequiredBody =>
      'لحماية العمارة، يرجى فتح شقتك بكلمة السر أولاً من الصفحة الرئيسية للتمكن من إضافة أرقام، شكاوى، مقترحات، أو المشاركة في التصويت.';

  @override
  String get residentAuthGoHomeBtn => 'فتح شقتي من الرئيسية';

  @override
  String get errResidentAuthRequired =>
      'يرجى فتح شقتك بكلمة السر أولاً من الصفحة الرئيسية';

  @override
  String adminPasscodeSetCounter(int setCount, int total) {
    return 'باسورد: $setCount/$total';
  }

  @override
  String get pushAutoAptPassSetTitle => 'تم تعيين كلمة سر شقة';

  @override
  String pushAutoAptPassSetBody(String apt) {
    return '$apt: تم تعيين كلمة السر بنجاح';
  }

  @override
  String get navAppRating => 'تقييم التطبيق';

  @override
  String get ratingScreenTitle => 'تقييم تطبيق MABNA CARE';

  @override
  String get ratingScreenSubtitle =>
      'تقييم حقيقي وموثّق من سكان العمارة المسجّلين فقط';

  @override
  String ratingCountLabel(int count) {
    return '$count تقييم';
  }

  @override
  String ratingParticipationLabel(int rated, int total) {
    return 'شارك $rated / $total شقة';
  }

  @override
  String get ratingFormTitleNew => 'قيّم تجربتك مع التطبيق';

  @override
  String get ratingFormTitleEdit => 'تعديل تقييمك الحالي';

  @override
  String get ratingFormSubtitle =>
      'تقدر تعدّل تقييمك في أي وقت — تقييم واحد لكل شقة';

  @override
  String get ratingPickStarsHint => 'اختر عدد النجوم';

  @override
  String get ratingMood1 => 'ضعيف — محتاج تحسين كبير';

  @override
  String get ratingMood2 => 'مقبول — فيه ملاحظات';

  @override
  String get ratingMood3 => 'جيد — شغال كويس';

  @override
  String get ratingMood4 => 'ممتاز جداً';

  @override
  String get ratingMood5 => 'تحفة! ريّحنا كتير ❤️';

  @override
  String get ratingCommentHint =>
      'اكتب رأيك أو أي ملاحظة تساعدنا نطوّر التطبيق (اختياري)...';

  @override
  String get ratingSubmitBtn => 'حفظ التقييم';

  @override
  String get ratingSavedToast => '✅ تم حفظ تقييم شقتك بنجاح — شكراً لك!';

  @override
  String get ratingReviewsAdminTitle => 'تقييمات كل شقة (لوحة المدير)';

  @override
  String get ratingReviewsPublicTitle => 'آراء سكان العمارة';

  @override
  String get ratingVerifiedResident => 'ساكن موثّق ✓';

  @override
  String get ratingAdminOnlyBadge => 'تفاصيل الشقق للمدير فقط';

  @override
  String get ratingNoReviewsYet =>
      'لا توجد تقييمات بعد — كن أول من يقيّم التطبيق!';

  @override
  String ratingUnratedAptsTitle(int count) {
    return 'شقق لم تقيّم بعد ($count شقة):';
  }

  @override
  String get pushAutoNewRatingTitle => 'تقييم جديد للتطبيق';

  @override
  String pushAutoNewRatingBody(String apt, int stars) {
    return '$apt: تم تقييم التطبيق بـ $stars نجوم';
  }

  @override
  String get emergencyArrearsTitle => 'متأخرات ومستحقات لصالح الصندوق';

  @override
  String get emergencyArrearsPendingKpi => 'متأخرات مستحقة للصندوق';

  @override
  String get emergencyArrearsExpectedKpi => 'المتوقع بعد التحصيل';

  @override
  String get emergencyArrearsAddBtn => 'إضافة متأخرات';

  @override
  String get emergencyArrearsDialogTitle => 'إضافة متأخرات مستحقة للصندوق';

  @override
  String get emergencyArrearsAptLabel => 'الشقة / الاسم';

  @override
  String get emergencyArrearsAptHint => 'مثال: شقة أستاذ خالد (شقة مغلقة)';

  @override
  String get emergencyArrearsAmountLabel => 'المبلغ المستحق (ج.م)';

  @override
  String get emergencyArrearsDetailsLabel => 'التفاصيل والبنود المشمولة';

  @override
  String get emergencyArrearsDetailsHint =>
      'مثال: شامل أعمال الرخام والأسانسير ومفاتيح الكهرباء...';

  @override
  String get emergencyArrearsPendingBadge => 'متأخرات قيد التحصيل';

  @override
  String get emergencyArrearsCollectedBadge => 'تم التحصيل وإيداعه بالصندوق ✓';

  @override
  String get emergencyArrearsAutoNote =>
      'بمجرد السداد يُضاف المبلغ تلقائياً إلى رصيد صندوق الطوارئ';

  @override
  String get emergencyArrearsCollectBtn => 'تم التحصيل ← إضافة للصندوق';

  @override
  String get emergencyArrearsEmpty => 'لا توجد متأخرات مستحقة حالياً';

  @override
  String get emergencyArrearsAddedToast => '✅ تمت إضافة المتأخرات بنجاح';

  @override
  String get emergencyArrearsCollectedToast =>
      '✅ تم التحصيل وإضافة المبلغ لصندوق الطوارئ تلقائياً';

  @override
  String get emergencyArrearsDeletedToast => 'تم حذف بند المتأخرات';

  @override
  String confirmDeleteArrearBody(String title) {
    return 'هل أنت متأكد من حذف بند المتأخرات لـ «$title»؟';
  }

  @override
  String get ratingTabAdd => 'إضافة تقييم';

  @override
  String get ratingTabList => 'التقييمات';

  @override
  String get pushAutoContactAddedTitle => 'رقم صيانة جديد للعمارة';

  @override
  String pushAutoContactAddedBody(String name) {
    return 'تم إضافة «$name» في دليل أرقام وكروت الصيانة';
  }

  @override
  String get pushAutoPollVotedTitle => 'مشاركة جديدة في التصويت';

  @override
  String pushAutoPollVotedBody(String apt) {
    return '$apt: تم التصويت في قرارات العمارة';
  }

  @override
  String get emergencyArrearsEditTitle => 'تعديل المتأخرات';

  @override
  String get emergencyArrearsUpdatedToast => '✅ تم تعديل المتأخرات بنجاح';

  @override
  String get ratingDeletedToast => 'تم حذف التقييم';

  @override
  String confirmDeleteRatingBody(String apt) {
    return 'هل أنت متأكد من حذف تقييم $apt؟';
  }

  @override
  String get aptsTabActive => 'الشقق الساكنة';

  @override
  String get aptsTabClosed => 'الشقق المغلقة';

  @override
  String get closedAptsInfoBanner =>
      'شقق مغلقة (بدون مصاريف شهرية) — يظهر عليها فقط الرسوم الخاصة وأعمال العمارة، وعند السداد يُضاف المبلغ لصندوق الطوارئ تلقائياً.';

  @override
  String closedAptDueLabel(String amount) {
    return 'مستحق عليه: $amount';
  }

  @override
  String get closedAptClearLabel => 'خالص — لا توجد مستحقات ✓';

  @override
  String get specialFeeBtn => 'رسم خاص';

  @override
  String get specialFeeDialogTitle => 'فرض رسم خاص / غير شهري';

  @override
  String get specialFeeNameLabel => 'اسم الرسم / السبب';

  @override
  String get specialFeeNameHint => 'مثال: أعمال رخام ودهان الأسانسير';

  @override
  String get specialFeeTargetLabel => 'الفئة المستهدفة';

  @override
  String specialFeeTargetAll(int count) {
    return 'الكل ($count)';
  }

  @override
  String specialFeeTargetClosed(int count) {
    return 'المغلقة ($count)';
  }

  @override
  String get specialFeeTargetCustom => 'شقق محددة';

  @override
  String get specialFeeModePerApt => 'ثابت لكل شقة';

  @override
  String get specialFeeModeSplit => 'إجمالي يتقسم';

  @override
  String get specialFeeAmountPerAptLabel => 'المبلغ لكل شقة (ج.م)';

  @override
  String get specialFeeAmountTotalLabel => 'إجمالي المبلغ (ج.م)';

  @override
  String specialFeePreviewLine(int perApt, int count, int total) {
    return 'سيُضاف $perApt ج على $count شقة (الإجمالي: $total ج → الطوارئ)';
  }

  @override
  String get specialFeeApplyBtn => 'تطبيق الرسم';

  @override
  String get specialFeeCollectBtn => 'تم التحصيل ✓';

  @override
  String get specialFeePaidTag => 'تم السداد ✓';

  @override
  String get specialFeeAddedToast => '✅ تم فرض الرسم الخاص بنجاح';

  @override
  String get specialFeeCollectedToast =>
      '✅ تم التحصيل وإضافة المبلغ لصندوق الطوارئ تلقائياً';

  @override
  String get specialFeeDeletedToast => 'تم حذف الرسم الخاص';

  @override
  String get aptStatusActive => 'ساكنة';

  @override
  String get aptStatusClosed => 'مغلقة';

  @override
  String get convertToActiveBtn => 'تحويل لساكنة';

  @override
  String get convertToClosedBtn => 'تحويل لمغلقة';

  @override
  String get aptConvertedToActiveToast =>
      '✅ تم تحويل الشقة إلى «ساكنة» وتحديث عدد الشقق النشطة';

  @override
  String get aptConvertedToClosedToast =>
      '✅ تم تحويل الشقة إلى «مغلقة» وتحديث عدد الشقق النشطة';

  @override
  String get myProfileTitle => 'بروفايل شقتي';

  @override
  String get myProfileBtn => 'البروفايل';

  @override
  String get floorLabel => 'الدور';

  @override
  String get floorHint => 'مثال: الدور الثالث';

  @override
  String get phoneNumberLabel => 'رقم التليفون';

  @override
  String get phoneNumberHint => '01012345678';

  @override
  String get showPhoneToNeighborsLabel => 'إظهار رقمي للجيران في دليل العمارة';

  @override
  String get showPhoneToNeighborsSub => 'لو مقفول، يظهر لمدير العمارة فقط';

  @override
  String get saveProfileBtn => 'حفظ بيانات البروفايل';

  @override
  String get profileSavedToast => '✅ تم حفظ بيانات بروفايل الشقة بنجاح';

  @override
  String get profileSelectAptFirst =>
      'اختر شقتك أولاً من الأعلى ثم افتحها بكلمة السر لتعديل البروفايل';

  @override
  String get changeAptPassTitle => 'تغيير كلمة سر الشقة';

  @override
  String get currentPassLabel => 'كلمة السر الحالية';

  @override
  String get newPassLabel => 'كلمة السر الجديدة';

  @override
  String get confirmNewPassLabel => 'تأكيد كلمة السر الجديدة';

  @override
  String get saveNewPassBtn => 'تحديث كلمة السر';

  @override
  String get aptPassChangedToast => '✅ تم تغيير كلمة سر الشقة بنجاح';

  @override
  String get forgotPassSectionTitle => 'نسيت كلمة السر؟';

  @override
  String get forgotPassDesc =>
      'لحماية شقتك من العبث، يمكنك طلب إعادة تعيين كلمة السر من مدير العمارة بضغطة واحدة.';

  @override
  String get requestPassResetBtn => 'طلب إعادة تعيين من المدير';

  @override
  String get whatsappManagerBtn => 'واتساب المدير';

  @override
  String get passResetRequestedToast =>
      '✅ تم إرسال طلب إعادة تعيين كلمة السر للمدير';

  @override
  String get contactCategoryLabel => 'التصنيف / التخصص';

  @override
  String get catAll => 'الكل';

  @override
  String get catPlumbing => 'سباكة';

  @override
  String get catElectric => 'كهرباء';

  @override
  String get catElevator => 'أسانسير';

  @override
  String get catAc => 'تكييف';

  @override
  String get catCarpentry => 'نجارة';

  @override
  String get catOther => 'أخرى';

  @override
  String get exitAppDialogTitle => 'هل تريد الخروج من MABNA CARE؟';

  @override
  String get exitAppDialogBody =>
      'اضغط «البقاء في التطبيق» للاستمرار أو «خروج» لإغلاق التطبيق.';

  @override
  String get stayInAppBtn => 'البقاء في التطبيق';

  @override
  String get exitAppBtn => 'خروج';

  @override
  String get changePhotoBtn => 'تغيير الصورة';

  @override
  String get removePhotoBtn => 'حذف الصورة';

  @override
  String get contactsTabNeighbors => 'الجيران';

  @override
  String get noNeighborsYet =>
      'لم يضف أي جار بيانات الدور أو رقم الهاتف في بروفايل شقته بعد.';

  @override
  String get neighborPhoneHiddenAdminBadge => 'مخفي عن الجيران';
}
