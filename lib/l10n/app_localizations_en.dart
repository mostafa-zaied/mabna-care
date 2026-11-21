// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MABNA CARE';

  @override
  String get demoBanner =>
      'Local Demo Mode — Add Supabase keys in lib/config.dart for live deployment';

  @override
  String monthOption(int monthNum, int yearNum) {
    return 'Month $monthNum ($yearNum)';
  }

  @override
  String get editBtn => 'Edit';

  @override
  String get closeBtn => 'Close';

  @override
  String billTitle(int monthNum) {
    return 'Building Expenses — Month $monthNum:';
  }

  @override
  String get copyWhatsAppBtn => 'Copy for WhatsApp';

  @override
  String get waterLabel => 'Water';

  @override
  String get elecLabel => 'Elec';

  @override
  String get elevLabel => 'Elevator';

  @override
  String get cleanLabel => 'Cleaning';

  @override
  String totalExpensesLine(int total, int apts) {
    return '• Total Expenses: $total EGP (÷ $apts apts)';
  }

  @override
  String get sharePerAptLabel => 'Per Apt';

  @override
  String currency(int amount) {
    return '$amount EGP';
  }

  @override
  String get copiedTitle => 'Copied for WhatsApp:';

  @override
  String get copiedToast => 'Updated monthly report copied for WhatsApp';

  @override
  String get aptsCountField => 'Apts:';

  @override
  String get saveChangesBtn => 'Save Changes';

  @override
  String get manageAptsBtn => 'Apts & Passwords';

  @override
  String get tapAptTitle => 'Tap your apartment to record payment';

  @override
  String paidCounter(int paid, int total) {
    return 'Paid $paid of $total';
  }

  @override
  String defaultAptName(int num) {
    return 'Apt $num';
  }

  @override
  String get paidBadge => 'Paid';

  @override
  String get pendingPaymentBadge => 'Pending';

  @override
  String get adminLoginTitle => 'Admin Login';

  @override
  String get adminPassHint => 'Enter admin password...';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get login => 'Login';

  @override
  String get manageAptsTitle => 'Manage Apartment Names & Passwords';

  @override
  String get optionalName => 'Name (optional)';

  @override
  String get passcodeLabel => 'Passcode';

  @override
  String get saveAll => 'Save All';

  @override
  String get saving => 'Saving...';

  @override
  String fileLabel(String name) {
    return 'File: $name';
  }

  @override
  String get cancelPaymentAdmin => 'Cancel Payment (Admin)';

  @override
  String get enterPassHint => 'Enter passcode...';

  @override
  String get step2Image => 'Transfer Screenshot (Required)';

  @override
  String get unlockAptSubtitle =>
      'Enter apartment passcode to open details (saved after first time)';

  @override
  String get unlockAptBtn => 'Unlock Apartment';

  @override
  String get receiptRequiredNote =>
      'Please attach the receipt screenshot to verify the paid amount (whether exact, higher, or lower).';

  @override
  String get errReceiptRequired =>
      'Please attach the receipt screenshot before confirming payment.';

  @override
  String get noReceiptAttached => 'Confirmed without receipt image';

  @override
  String get pickImagePrompt => 'Tap here to select receipt image';

  @override
  String chosenFile(String name) {
    return 'Selected: $name';
  }

  @override
  String get confirmPaymentBtn => 'Confirm Payment';

  @override
  String get uploadingBtn => 'Uploading...';

  @override
  String get addApartmentBtn => '+ Add Apartment';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navEmergency => 'Emergency';

  @override
  String get writeComplaintHint => 'Write your complaint clearly...';

  @override
  String get writeImprovementHint =>
      'Share your suggestion to improve the building...';

  @override
  String get postAnonymously => 'Post anonymously (hide apartment name)';

  @override
  String get selectApartment => 'Apartment';

  @override
  String get submitPostBtn => 'Submit';

  @override
  String get anonymousAuthor => 'Anonymous';

  @override
  String get noPostsYet => 'No entries yet';

  @override
  String get postAddedToast => 'Submitted successfully';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String errLoadData(String err) {
    return 'Failed to load data: $err';
  }

  @override
  String get monthSavedToast => 'Month changes saved successfully';

  @override
  String get paymentCancelledToast => 'Payment cancelled';

  @override
  String get aptsSavedToast => 'Apartment names & passwords saved';

  @override
  String get errNoMonth => 'No month selected';

  @override
  String get errWrongAdminPass => 'Incorrect admin password';

  @override
  String get errWrongAptPass => 'Incorrect apartment passcode';

  @override
  String errWrongAptPassHint(String hint) {
    return 'Incorrect apartment passcode (try $hint)';
  }

  @override
  String get errPaymentFailed => 'Could not record payment';

  @override
  String get errCancelFailed => 'Could not cancel payment';

  @override
  String get errAptLoadFailed => 'Could not load apartments';

  @override
  String get errAptSaveFailed => 'Could not save apartment';

  @override
  String get errEmptyMessage => 'Message cannot be empty';

  @override
  String get errSubmitFailed => 'Could not submit post';

  @override
  String get errDeleteFailed => 'Could not delete post';

  @override
  String get addNextMonthBtn => 'Next Month';

  @override
  String get monthAddedToast => 'Next month added';

  @override
  String get pinAptPrompt => 'Pin your apartment for quick payment';

  @override
  String get selectAptBtn => 'Select Apt';

  @override
  String get myAptPrefix => 'My Apt';

  @override
  String get payNowBtn => 'Pay Now';

  @override
  String get changeAptTooltip => 'Change apartment';

  @override
  String get emergencyLogTitle => 'Emergency Fund Log';

  @override
  String get emergencyLogEmpty => 'No withdrawals recorded yet.';

  @override
  String get emergencyAmountHint => 'Amount';

  @override
  String get emergencyReasonHint => 'Reason (e.g. water pump repair)';

  @override
  String get recordExpenseBtn => 'Record Expense';

  @override
  String get errEmergencyInput => 'Please enter a valid amount and reason.';

  @override
  String get errEmergencySave => 'Failed to save transaction.';

  @override
  String get pinNoticeBtn => 'Pin Notice';

  @override
  String get noticeDialogTitle => 'Important Building Notice';

  @override
  String get noticeDialogHint => 'e.g. Elevator maintenance on Thursday 10–12';

  @override
  String get hideNoticeBtn => 'Hide';

  @override
  String get adminReplyLabel => 'Admin Reply:';

  @override
  String get updateStatusTitle => 'Update Status & Reply';

  @override
  String get statusFieldLabel => 'Status';

  @override
  String get adminReplyHint => 'Short admin reply (optional)...';

  @override
  String get statusPending => 'Under Review';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get adminLogoutBtn => 'Admin Logout';

  @override
  String get emergencyTabWithdraw => 'Withdraw';

  @override
  String get emergencyTabDeposit => 'Deposit';

  @override
  String get emergencyDepositReasonHint =>
      'Reason (e.g. extra contribution or surplus)';

  @override
  String get recordDepositBtn => 'Record Deposit';

  @override
  String get removeMonthBtn => 'Remove Month';

  @override
  String get monthDeletedToast => 'Month removed successfully';

  @override
  String get errCannotDeleteLastMonth =>
      'Cannot remove the last remaining month';

  @override
  String get deleteMonthConfirmTitle => 'Remove Current Month?';

  @override
  String deleteMonthConfirmBody(int month, int year) {
    return 'Month $month ($year) and all its payments will be permanently deleted.';
  }

  @override
  String get splashTagline => 'Your Building, Our Care.';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteBtn => 'Delete';

  @override
  String confirmDeleteAptBody(String apt) {
    return 'Do you want to delete \"$apt\"?';
  }

  @override
  String confirmDeleteTxBody(String amount) {
    return 'Do you want to delete this transaction ($amount)?';
  }

  @override
  String get confirmDeletePostBody =>
      'Do you want to permanently delete this post?';

  @override
  String confirmCancelPaymentBody(String apt) {
    return 'Do you want to cancel the payment for \"$apt\"?';
  }

  @override
  String get instapayTitle => 'InstaPay Transfer';

  @override
  String get instapaySubtitle => 'Transfer to this number, then upload receipt';

  @override
  String get openInstapayBtn => 'Open InstaPay';

  @override
  String get extraChargesBtn => 'Extra Apt Charges';

  @override
  String get extraChargesTitle => 'Extra Apartment Charges';

  @override
  String get selectAptsLabel => 'Select apartment(s):';

  @override
  String get extraAmountHint => 'Extra amount per apartment';

  @override
  String get extraReasonHint => 'Reason (e.g. lock or valve repair)';

  @override
  String get addExtraChargeBtn => 'Add Charge';

  @override
  String get extraChargesListTitle => 'Recorded extra charges this month:';

  @override
  String get noExtraChargesYet => 'No extra charges recorded for this month.';

  @override
  String get monthShareLine => 'Monthly Share';

  @override
  String get totalDueLabel => 'Total Due';

  @override
  String confirmDeleteExtraBody(String amount) {
    return 'Do you want to delete this extra charge ($amount)?';
  }

  @override
  String get extraChargeAddedToast => 'Extra charge added';

  @override
  String extraBadge(int amount) {
    return '+$amount extra';
  }

  @override
  String get settingsBtn => 'Settings';

  @override
  String get settingsTitle => 'Admin Settings';

  @override
  String get settingsShortTitle => 'Settings';

  @override
  String get adminOnlyPageMsg => 'Admin access only.';

  @override
  String get requirePassOnOpenTitle =>
      'Require Apartment Passcode Before Opening';

  @override
  String get statusEnabled => 'Currently Enabled';

  @override
  String get statusDisabled => 'Currently Disabled';

  @override
  String get requirePassOnOpenDescOn =>
      'When enabled: Residents must enter their apartment passcode from outside before viewing details or paying.';

  @override
  String get requirePassOnOpenDescOff =>
      'When disabled: Apartment details open directly, and the passcode is entered inside the payment dialog.';

  @override
  String get buildingMonthMgmtTitle => 'Building & Month Management';

  @override
  String selectedMonthBadge(String monthName, int monthNum, int yearNum) {
    return 'Selected: $monthName ($monthNum/$yearNum)';
  }

  @override
  String get addNextMonthConfirmTitle => 'Add Next Month?';

  @override
  String addNextMonthConfirmBody(String monthName, int monthNum, int yearNum) {
    return 'Month $monthName ($monthNum/$yearNum) will be added. Do you want to continue?';
  }

  @override
  String addNextMonthConfirmBtn(String monthName, int monthNum, int yearNum) {
    return 'Add $monthName ($monthNum/$yearNum)';
  }

  @override
  String monthAddedNamedToast(String monthName, int monthNum, int yearNum) {
    return '✅ Added $monthName ($monthNum/$yearNum)';
  }

  @override
  String get adminViewsTitle => 'Statistics';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get viewsStatsLoadingHint =>
      'Tap refresh to load stats (ensure Supabase SQL is applied)';

  @override
  String get viewsHeroSubtitle =>
      'Live overview of resident visits and app activity';

  @override
  String get viewsTotalLabel => 'Total Opens';

  @override
  String get viewsTotalSubtitle => 'Total app launches since release';

  @override
  String get viewsUniqueLabel => 'Unique Visitors';

  @override
  String get viewsUniqueSubtitle => 'Distinct devices that opened the app';

  @override
  String get viewsTodayLabel => 'Today\'s Visits';

  @override
  String get viewsTodaySubtitle => 'Launches recorded today';

  @override
  String get viewsAvgPerVisitorLabel => 'Average Opens per Visitor';

  @override
  String get navFeedback => 'Opinions';

  @override
  String get navFeedbackFull => 'Complaints & Suggestions';

  @override
  String tabViewAllPosts(int count) {
    return 'View Posts ($count)';
  }

  @override
  String get tabAddPost => 'Add Post';

  @override
  String get filterAll => 'All';

  @override
  String get filterComplaints => '📢 Complaints';

  @override
  String get filterSuggestions => '💡 Suggestions';

  @override
  String get postTypeLabel => 'Type';

  @override
  String get typeComplaint => '📢 Complaint';

  @override
  String get typeSuggestion => '💡 Suggestion';

  @override
  String get errEmptyFeedbackMsg =>
      'Please enter your complaint or suggestion first';

  @override
  String get viewBillReceiptBtn => 'View Receipt';

  @override
  String get attachBillAfterPayBtn => 'Attach Receipt';

  @override
  String get utilityPendingBadge => 'Pending';

  @override
  String utilityBillLabel(String utility) {
    return '$utility Bill';
  }

  @override
  String get waterBillLabel => 'Water Bill';

  @override
  String get elecBillLabel => 'Electricity Bill';

  @override
  String utilityReceiptDialogTitle(String utility) {
    return '$utility Receipt';
  }

  @override
  String get removeUtilityReceiptBtn => 'Remove Receipt';

  @override
  String get utilityReceiptSavedToast => 'Utility receipt saved';

  @override
  String get utilityReceiptRemovedToast => 'Utility receipt removed';

  @override
  String get navContactsFull => 'Maintenance Contacts';

  @override
  String get navContactsShort => 'Contacts';

  @override
  String get contactsTitle => 'Building Maintenance Numbers';

  @override
  String get contactsSubtitle =>
      'Any resident can add a trusted technician or maintenance number.';

  @override
  String get addContactBtn => 'Add Number';

  @override
  String get addContactTitle => 'Add Maintenance Number';

  @override
  String get contactNameLabel => 'Name / Service';

  @override
  String get contactNameHint => 'e.g. Eng. Khaled — Electrician';

  @override
  String get contactRoleLabel => 'Role / Description';

  @override
  String get contactRoleHint => 'e.g. Staircase & motor repair';

  @override
  String get contactPhoneLabel => 'Phone Number';

  @override
  String get contactPhoneHint => '01012345678';

  @override
  String get callBtn => 'Call';

  @override
  String get whatsappBtn => 'WhatsApp';

  @override
  String get errContactFields => 'Please enter name and phone number.';

  @override
  String get contactAddedToast => 'Contact added';

  @override
  String confirmDeleteContactBody(String name) {
    return 'Do you want to delete \"$name\" from contacts?';
  }

  @override
  String get noContactsYet => 'No contacts added yet.';

  @override
  String get deleteAllExtraChargesBtn => 'Delete All';

  @override
  String get confirmDeleteAllExtraBody =>
      'Do you want to delete all extra charges for this month from all apartments?';

  @override
  String get selectAllBtn => 'Select All';

  @override
  String get deselectAllBtn => 'Deselect All';

  @override
  String get errSelectAtLeastOneApt =>
      'Please select at least one apartment to add the charge.';

  @override
  String get setupAptPassSubtitle =>
      'Set your apartment passcode for the first time';

  @override
  String get setupAptPassHint =>
      'Choose a passcode for your apartment (at least 4 characters). It will be saved on your device; contact the admin if forgotten.';

  @override
  String get newPasscodeLabel => 'New Passcode';

  @override
  String get confirmPasscodeLabel => 'Confirm Passcode';

  @override
  String get saveAndUnlockBtn => 'Save & Unlock';

  @override
  String get errPassTooShort => 'Passcode must be at least 4 characters.';

  @override
  String get errPassMismatch => 'Passcodes do not match.';

  @override
  String get errPassAlreadySet =>
      'A passcode is already set for this apartment.';

  @override
  String get forgotPassHint =>
      'Forgot passcode? Contact the building admin to reset it.';

  @override
  String get resetPassBtn => 'Reset';

  @override
  String get passNotSetYet => 'Not set yet';

  @override
  String get resetAllPasswordsBtn => 'Reset All Passwords';

  @override
  String get confirmResetAllPasswordsBody =>
      'Do you want to reset passwords for all apartments? Each resident will be asked to set a new passcode.';

  @override
  String get allPasswordsResetToast =>
      'All apartment passwords have been reset';

  @override
  String get drawerExtraSections => 'More Sections';

  @override
  String get drawerPreferences => 'App Preferences';

  @override
  String get drawerThemeLabel => 'Theme';

  @override
  String get drawerThemeDark => 'Dark';

  @override
  String get drawerThemeLight => 'Light';

  @override
  String get drawerLanguageLabel => 'Language';

  @override
  String get drawerAdminSection => 'Administration';

  @override
  String get drawerAdminLogin => 'Admin Login';

  @override
  String get contactManagerBtn => 'Contact Manager';

  @override
  String drawerMyAptLabel(String apt) {
    return 'Your Apt: $apt';
  }

  @override
  String get digitalReceiptTitle => 'Digital Payment Receipt';

  @override
  String get digitalReceiptBrand => 'MABNA CARE • Verified Receipt';

  @override
  String get digitalReceiptStatus => 'Payment Confirmed';

  @override
  String get receiptAptLabel => 'Apartment';

  @override
  String get receiptMonthLabel => 'Billing Month';

  @override
  String get receiptPaidAtLabel => 'Paid At';

  @override
  String get receiptTotalPaidLabel => 'Total Paid';

  @override
  String get receiptStampTitle => 'Electronically Verified';

  @override
  String get receiptSaveImageBtn => 'Save Image';

  @override
  String get receiptSavedToast => 'Receipt image saved successfully';

  @override
  String get receiptSaveNotSupported =>
      'Take a screenshot to save this receipt';

  @override
  String get viewDigitalReceiptBtn => 'View MABNA CARE Digital Receipt';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsAvgShare => 'Avg / Apt';

  @override
  String get analyticsCollectionRate => 'Collected';

  @override
  String get analyticsEmergencyBalance => 'Emergency';

  @override
  String get analyticsChartTitle => 'Monthly Expenses Comparison';

  @override
  String get analyticsChartHint => 'Tap any month to inspect its breakdown';

  @override
  String analyticsBreakdownTitle(String month) {
    return 'Expenses Breakdown — $month';
  }

  @override
  String analyticsCollectionCardTitle(String month) {
    return 'Collection Status — $month';
  }

  @override
  String get analyticsCollectedLabel => 'Collected';

  @override
  String get analyticsRemainingLabel => 'Remaining';

  @override
  String analyticsInsightLower(String month, String pct, String diff) {
    return '$month expenses are $pct% lower than the previous month (saved $diff EGP)';
  }

  @override
  String analyticsInsightHigher(String month, String pct, String diff) {
    return '$month expenses are $pct% higher than the previous month (+$diff EGP)';
  }

  @override
  String analyticsInsightSame(String month) {
    return '$month expenses match the previous month exactly';
  }

  @override
  String analyticsInsightSingle(
    String month,
    String share,
    int paid,
    int total,
  ) {
    return '$month share: $share EGP • $paid of $total paid';
  }

  @override
  String get analyticsNoData => 'Not enough monthly data to analyze yet.';

  @override
  String get pushCardTitle => 'Send Push Notification';

  @override
  String get pushCardSubtitle =>
      'Send an instant alert directly to all subscribed residents.';

  @override
  String get pushTitleLabel => 'Notification Title';

  @override
  String get pushTitleHint =>
      'e.g., Monthly dues reminder or elevator maintenance';

  @override
  String get pushBodyLabel => 'Notification Message';

  @override
  String get pushBodyHint => 'Write your notification details here...';

  @override
  String get pushSendAllBtn => 'Send to All Residents 🚀';

  @override
  String get errPushFieldsRequired =>
      'Please enter both a title and message first.';

  @override
  String get pushSentSuccessToast => 'Notification sent successfully';

  @override
  String get pushNoDevicesToast => 'No devices subscribed to notifications yet';

  @override
  String get pushNotConfiguredToast =>
      'Push system ready — only the Firebase key in Supabase is pending';

  @override
  String get pushSendFailedToast => 'Could not send notification right now';

  @override
  String get pushAutoAnnouncementTitle => '📢 Important Building Announcement';

  @override
  String get pushAutoNewMonthTitle => '🗓️ New Monthly Bill Available';

  @override
  String pushAutoNewMonthBody(String month) {
    return 'Expenses for $month are now live on MABNA CARE.';
  }

  @override
  String get pushAutoPaymentTitle => '🧾 New Payment Uploaded';

  @override
  String pushAutoPaymentBody(String apt) {
    return '$apt: Monthly payment receipt uploaded';
  }

  @override
  String get pushAutoFeedbackTitle => '💬 New Resident Feedback';

  @override
  String get drawerNotificationsLabel => 'Notifications';

  @override
  String get pushEnabledBadge => 'Enabled';

  @override
  String get pushEnableAction => 'Off';

  @override
  String get pushEnabledToast => '🔔 Push notifications enabled on this device';

  @override
  String get pushBlockedToast =>
      'Could not enable notifications (allow notifications in browser settings, or Add to Home Screen on iPhone)';

  @override
  String get pushAudienceAdminOnly => 'Admin Only (Test)';

  @override
  String get pushAudienceAll => 'All Residents';

  @override
  String get pushSendAdminTestBtn => 'Send Test to Admin 🛡️';

  @override
  String get offlineBannerMsg => 'No internet connection';

  @override
  String get onlineRestoredToast => 'Back online — connection restored';

  @override
  String get noNetworkTitle => 'No Internet Connection';

  @override
  String get noNetworkSubtitle =>
      'Check your connection and tap Retry to reload.';

  @override
  String get retryBtn => 'Retry';

  @override
  String get installAppNavLabel => 'How to Install App';

  @override
  String get installAppTitle => 'How to Install MABNA CARE';

  @override
  String get installAppSubtitle =>
      'Install the app on your home screen for 1-tap access without a browser bar and instant notifications.';

  @override
  String get installAppNowBtn => 'Install App Now';

  @override
  String get installAppAlreadyInstalled =>
      'App is already installed on your device ✅';

  @override
  String get installAndroidTitle => 'How to install on Android (Chrome)';

  @override
  String get installAndroidStep1 =>
      'Tap the three dots menu (⋮) at the top corner of Chrome.';

  @override
  String get installAndroidStep2 =>
      'Select \"Install app\" or \"Install and create shortcut\" → \"Install\".';

  @override
  String get installAndroidStep3 =>
      'Tap \"Install\" on the confirmation popup — the app icon will appear on your home screen.';

  @override
  String get installIosTitle => 'How to install on iPhone (Safari)';

  @override
  String get installIosStep1 => 'Make sure you open the link in Safari.';

  @override
  String get installIosStep2 =>
      'Tap the Share icon at the bottom of the screen.';

  @override
  String get installIosStep3 =>
      'Select \"Add to Home Screen\" and then tap \"Add\".';

  @override
  String get notifHistoryTitle => 'Notifications';

  @override
  String get notifMarkAllReadBtn => 'Mark all read ✓';

  @override
  String notifFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String notifFilterUnread(int count) {
    return 'Unread ($count)';
  }

  @override
  String get notifEmptyAll => 'No notifications sent yet.';

  @override
  String get notifEmptyUnread => 'No unread notifications 🎉';

  @override
  String get notifTypeAnnouncement => 'Announcement';

  @override
  String get notifTypeNewMonth => 'Monthly Bill';

  @override
  String get notifTypePayment => 'Payment Alert';

  @override
  String get notifTypeFeedback => 'Resident Feedback';

  @override
  String get notifTypeGeneral => 'Admin Alert';

  @override
  String get confirmDeleteNotifBody =>
      'Do you want to delete this notification from history?';

  @override
  String get addCustomExpenseBtn => 'Add Expense Field';

  @override
  String get addCustomExpenseTitle => 'Add New Expense Field';

  @override
  String get customExpenseNameLabel => 'Field Name';

  @override
  String get customExpenseNameHint => 'e.g. Doorman, Motor Repair, Gas...';

  @override
  String get customExpenseAmountLabel => 'Amount (EGP)';

  @override
  String get customExpenseAddedToast => 'Expense field added & calculated';

  @override
  String get customExpenseRemovedToast =>
      'Expense field removed & recalculated';

  @override
  String get addBtn => 'Add';

  @override
  String get deleteOwnReceiptBtn => 'Delete Receipt & Re-upload';

  @override
  String get confirmDeleteOwnReceiptBody =>
      'Delete this receipt image and reset payment status so you can upload a new one?';

  @override
  String get paymentReceiptDeletedToast =>
      'Receipt deleted — you can now upload a new one';

  @override
  String dueDateBanner(int month, int day) {
    return 'Payment deadline for month $month is day $day';
  }

  @override
  String dueDatePassedBanner(int month, int day) {
    return 'Payment deadline for month $month (day $day) has passed';
  }

  @override
  String get overdueBadge => 'Overdue';

  @override
  String overdueCountPill(int count) {
    return '$count overdue';
  }

  @override
  String get dueDayField => 'Due Day';

  @override
  String get pushAudienceSpecificApt => 'Specific Apt';

  @override
  String get pushAudienceUnpaid => 'Unpaid Only';

  @override
  String get pushSelectAptsHint =>
      'Select apartment(s) (🔔 = notifications enabled):';

  @override
  String pushUnpaidSummary(int count, int month) {
    return 'Will send to $count unpaid apartment(s) for month $month';
  }

  @override
  String get pushAllPaidHint => 'All apartments have paid for this month 🎉';

  @override
  String get pushErrSelectApt => 'Please select at least one apartment';

  @override
  String pushSendSelectedBtn(int count) {
    return 'Send to Selected ($count)';
  }

  @override
  String pushSendUnpaidBtn(int count) {
    return 'Remind Unpaid ($count)';
  }

  @override
  String pushDefaultUnpaidTitle(int month) {
    return 'Payment Reminder — Month $month';
  }

  @override
  String pushDefaultUnpaidBody(int month) {
    return 'Kindly settle your building expenses for month $month and upload the receipt in the app.';
  }

  @override
  String get adminPrankBioTitle => '🔐 Biometric Security Check';

  @override
  String get adminPrankBioSub =>
      'Place your finger on the scanner to verify the Building Admin fingerprint';

  @override
  String get adminPrankBioPrompt => 'Tap the fingerprint to verify...';

  @override
  String get adminPrankBioScanning =>
      'Matching fingerprint with building HQ... ⏳';

  @override
  String get adminPrankBioSkip => 'Admin Password Login';

  @override
  String get adminPrankCaughtTitle => 'Caught You, Neighbor!';

  @override
  String get adminPrankCaughtBody =>
      'Coup attempt logged! Adding a 10 EGP curiosity fee to your apartment next month!';

  @override
  String get adminPrankCaughtBackBtn => 'Okay I surrender, Back Home';

  @override
  String get adminPrankCaughtRealBtn =>
      'I really am the Admin (Enter Password)';

  @override
  String get adminPrankRoast1 => 'Nope! Just trying your luck today?';

  @override
  String get adminPrankRoast2 =>
      'Wrong a second time! Looks like you memorized the Login button, not the password.';

  @override
  String adminPrankRoast3(String attempt) {
    return '🚨 Caught again! Definitely not $attempt';
  }

  @override
  String get adminPrankRoast4 =>
      'Give the keyboard a break, you are definitely not the admin!';

  @override
  String adminPrankCooldown(int seconds) {
    return 'Cool down for ${seconds}s before trying again';
  }

  @override
  String get changeAdminPassTitle => 'Change Admin Password';

  @override
  String get changeAdminPassSubtitle =>
      'Update your admin passcode securely right from the app';

  @override
  String get currentAdminPassLabel => 'Current Password';

  @override
  String get newAdminPassLabel => 'New Password';

  @override
  String get confirmNewAdminPassLabel => 'Confirm New Password';

  @override
  String get changeAdminPassSecurityNote =>
      'Once saved, the password is updated in the database and any other logged-in admin devices will be signed out automatically.';

  @override
  String get changeAdminPassBtn => 'Save New Password';

  @override
  String get changeAdminPassFieldsRequired =>
      'Please fill in the current, new, and confirmation passwords.';

  @override
  String get changeAdminPassSuccessToast =>
      '✅ Admin password updated successfully';

  @override
  String get passStrengthWeak => 'Weak';

  @override
  String get passStrengthMedium => 'Medium';

  @override
  String get passStrengthStrong => 'Strong ✓';

  @override
  String get monthlyReportBtn => 'Statement (Image)';

  @override
  String get monthlyReportScreenTitle => 'Monthly Statement';

  @override
  String get reportDocSubtitle => 'Monthly Building Financial Statement';

  @override
  String reportIssuedLabel(String date) {
    return 'Issued: $date';
  }

  @override
  String get reportSectionExpenses => 'Monthly Expenses Breakdown';

  @override
  String get reportSectionApts => 'Apartments Payment Status';

  @override
  String get reportColApt => 'Apartment';

  @override
  String get reportColDue => 'Due';

  @override
  String get reportColStatus => 'Status';

  @override
  String get reportTotalRow => 'Total';

  @override
  String get reportTotalExpensesKpi => 'Total Expenses';

  @override
  String get reportEmergencyBalanceTitle => 'Current Emergency Fund Balance';

  @override
  String get reportSavePngBtn => 'Save Statement Image for WhatsApp';

  @override
  String get reportSavedToast => '✅ Statement image saved successfully';

  @override
  String get reportChipExpenses => 'Expenses';

  @override
  String get reportChipApts => 'Apartments';

  @override
  String get reportChipEmergency => 'Emergency';

  @override
  String reportAptsCountUnit(int count) {
    return '$count apts';
  }

  @override
  String contactAddedByAptLabel(String apt) {
    return 'Added by: $apt';
  }

  @override
  String get contactAddedByAdmin => 'Admin';

  @override
  String get contactSelectYourAptLabel => 'Your Apartment';

  @override
  String get contactSelectYourAptHint => 'Select your apartment';

  @override
  String get errContactSelectApt => 'Please select your apartment first';

  @override
  String get contactCardPhotoLabel => 'Business Card Photo (Optional)';

  @override
  String get contactTakePhotoBtn => 'Take Photo';

  @override
  String get contactPickGalleryBtn => 'From Gallery';

  @override
  String get contactPhoneOptionalHint => 'Optional if card photo is attached';

  @override
  String get errContactNameOrCardRequired =>
      'Please enter a name and either a phone number or a card photo';

  @override
  String get contactTapToZoomHint => 'Tap to zoom card';

  @override
  String get contactViewCardBtn => 'View Full Card';

  @override
  String get renameExpenseTitle => 'Rename Expense Field';

  @override
  String get expenseRenamedToast => '✅ Expense name updated';

  @override
  String get editContactTitle => 'Edit Maintenance Contact';

  @override
  String get contactUpdatedToast => '✅ Maintenance contact updated';

  @override
  String get contactDeletedToast => 'Maintenance contact deleted';

  @override
  String get contactsTabNumbers => 'Numbers';

  @override
  String get contactsTabCards => 'Cards & Photos';

  @override
  String get noContactCardsYet => 'No cards or photos added yet';

  @override
  String get navPolls => 'Building Polls';

  @override
  String get pollsTitle => 'Building Polls & Decisions';

  @override
  String get pollsSubtitle =>
      'One vote per apartment — flexible choices & live results';

  @override
  String get pollsTabOpen => 'Open';

  @override
  String get pollsTabClosed => 'Closed & Results';

  @override
  String get newPollBtn => 'New Poll';

  @override
  String get createPollTitle => 'Create New Poll';

  @override
  String get pollQuestionLabel => 'Poll Question';

  @override
  String get pollQuestionHint => 'e.g. Best time for water tank cleaning?';

  @override
  String get pollPresetsLabel => 'Quick Presets (Optional)';

  @override
  String get pollPresetYesNo => 'Yes / No';

  @override
  String get pollPresetAgree3 => 'Agree / Disagree / Neutral';

  @override
  String get pollPresetDays => 'Friday / Saturday / Thursday';

  @override
  String get pollPresetBudget => 'Emergency Fund / Split / Postpone';

  @override
  String get pollOptionsLabel => 'Answer Options';

  @override
  String pollOptionHint(int num) {
    return 'Option #$num';
  }

  @override
  String get pollAddOptionBtn => 'Add Another Option';

  @override
  String get pollAllowMultipleLabel => 'Allow selecting multiple options';

  @override
  String get pollShowVotersLabel => 'Show voting apartments publicly';

  @override
  String get pollNotifyResidentsLabel =>
      'Send push notification to all residents';

  @override
  String get pollPublishBtn => 'Publish Poll';

  @override
  String get pollOpenBadge => 'Open';

  @override
  String get pollClosedBadge => 'Closed';

  @override
  String get pollMultiBadge => 'Multi-Select';

  @override
  String get pollSingleBadge => 'Single Choice';

  @override
  String get pollSecretBadge => 'Anonymous';

  @override
  String pollOptionsCount(int count) {
    return '$count options';
  }

  @override
  String pollVotesCount(int count) {
    return '$count votes';
  }

  @override
  String pollParticipation(int voted, int total) {
    return '$voted / $total apts voted';
  }

  @override
  String get pollShowVotersBtn => 'Show Voters';

  @override
  String get pollHideVotersBtn => 'Hide Voters';

  @override
  String get pollCloseBtn => 'Close';

  @override
  String get pollReopenBtn => 'Reopen';

  @override
  String get pollNoOpenYet => 'No open polls right now';

  @override
  String get pollNoClosedYet => 'No closed polls yet';

  @override
  String get pollCreatedToast => '✅ Poll published successfully';

  @override
  String get pollVotedToast => '✅ Your vote has been recorded';

  @override
  String get pollClosedToast => 'Poll closed and results finalized';

  @override
  String get pollReopenedToast => 'Poll reopened';

  @override
  String get pollDeletedToast => 'Poll deleted';

  @override
  String get errPollQuestionRequired => 'Please enter a poll question';

  @override
  String get errPollMinTwoOptions => 'Please add at least 2 options';

  @override
  String get errPollLoginAptFirst =>
      'Please sign in with your apartment first to vote';

  @override
  String get confirmDeletePollBody =>
      'Are you sure you want to delete this poll?';

  @override
  String get pushAutoNewPollTitle => 'New Building Poll';

  @override
  String pushAutoNewPollBody(String question) {
    return 'Cast your vote now: $question';
  }

  @override
  String get getMabnaForBuildingBtn => 'Refer MABNA CARE to a Friend';

  @override
  String get getMabnaFreeMonthBadge => '1st Month Free';

  @override
  String get footerGetAppCta =>
      'Loving MABNA CARE? Refer it to a friend\'s building — 1st month free';

  @override
  String get referralShareMessage =>
      'Check out MABNA CARE — we use it in our building for expenses, receipts, and voting, and it saved us from WhatsApp group chaos!\nTake a look at our building here:\nhttps://mabna-care.web.app/\n\nAnd try it free for your building for 1 month:\nhttps://mabna-care.web.app/landing.html';

  @override
  String get contactPickFromDeviceTooltip => 'Pick from phone contacts';

  @override
  String get contactPickerUnsupportedHint =>
      'Picking from device contacts is supported on mobile Chrome (Android) — you can paste the number directly here.';

  @override
  String get residentAuthRequiredTitle => 'Building Residents Only';

  @override
  String get residentAuthRequiredBody =>
      'To protect the building, please unlock your apartment with its passcode on the Home screen first to add contacts, submit feedback, or vote.';

  @override
  String get residentAuthGoHomeBtn => 'Unlock My Apartment';

  @override
  String get errResidentAuthRequired =>
      'Please unlock your apartment with its passcode first';

  @override
  String adminPasscodeSetCounter(int setCount, int total) {
    return 'Passcodes: $setCount/$total';
  }

  @override
  String get pushAutoAptPassSetTitle => 'Apartment Passcode Set';

  @override
  String pushAutoAptPassSetBody(String apt) {
    return '$apt: Apartment passcode set successfully';
  }

  @override
  String get navAppRating => 'Rate the App';

  @override
  String get ratingScreenTitle => 'Rate MABNA CARE';

  @override
  String get ratingScreenSubtitle =>
      'Verified ratings from registered building residents only';

  @override
  String ratingCountLabel(int count) {
    return '$count ratings';
  }

  @override
  String ratingParticipationLabel(int rated, int total) {
    return '$rated / $total apts rated';
  }

  @override
  String get ratingFormTitleNew => 'Rate your experience';

  @override
  String get ratingFormTitleEdit => 'Update your rating';

  @override
  String get ratingFormSubtitle =>
      'You can update your rating anytime — one rating per apartment';

  @override
  String get ratingPickStarsHint => 'Tap to select stars';

  @override
  String get ratingMood1 => 'Poor — needs big improvements';

  @override
  String get ratingMood2 => 'Fair — has some issues';

  @override
  String get ratingMood3 => 'Good — works well';

  @override
  String get ratingMood4 => 'Very Good';

  @override
  String get ratingMood5 => 'Awesome! Saved us so much hassle ❤️';

  @override
  String get ratingCommentHint =>
      'Share any thoughts or suggestions to help us improve (optional)...';

  @override
  String get ratingSubmitBtn => 'Save Rating';

  @override
  String get ratingSavedToast =>
      '✅ Your apartment\'s rating has been saved — thank you!';

  @override
  String get ratingReviewsAdminTitle => 'Ratings by Apartment (Admin)';

  @override
  String get ratingReviewsPublicTitle => 'Resident Reviews';

  @override
  String get ratingVerifiedResident => 'Verified Resident ✓';

  @override
  String get ratingAdminOnlyBadge => 'Apartment details visible to Admin only';

  @override
  String get ratingNoReviewsYet => 'No ratings yet — be the first to rate!';

  @override
  String ratingUnratedAptsTitle(int count) {
    return 'Apartments that haven\'t rated yet ($count):';
  }

  @override
  String get pushAutoNewRatingTitle => 'New App Rating';

  @override
  String pushAutoNewRatingBody(String apt, int stars) {
    return '$apt: Rated the app $stars stars';
  }

  @override
  String get emergencyArrearsTitle => 'Pending Dues & Arrears for Fund';

  @override
  String get emergencyArrearsPendingKpi => 'Pending Dues';

  @override
  String get emergencyArrearsExpectedKpi => 'Expected After Collection';

  @override
  String get emergencyArrearsAddBtn => 'Add Arrear';

  @override
  String get emergencyArrearsDialogTitle => 'Add Pending Due for Fund';

  @override
  String get emergencyArrearsAptLabel => 'Apartment / Name';

  @override
  String get emergencyArrearsAptHint => 'e.g. Mr. Khaled\'s Apt (Closed)';

  @override
  String get emergencyArrearsAmountLabel => 'Amount Due (EGP)';

  @override
  String get emergencyArrearsDetailsLabel => 'Details & Included Items';

  @override
  String get emergencyArrearsDetailsHint =>
      'e.g. Marble work, elevator, electrical switches...';

  @override
  String get emergencyArrearsPendingBadge => 'Pending Collection';

  @override
  String get emergencyArrearsCollectedBadge => 'Collected & Added to Fund ✓';

  @override
  String get emergencyArrearsAutoNote =>
      'Once paid, this amount is automatically added to the emergency fund balance';

  @override
  String get emergencyArrearsCollectBtn => 'Mark Collected → Add to Fund';

  @override
  String get emergencyArrearsEmpty => 'No pending arrears right now';

  @override
  String get emergencyArrearsAddedToast => '✅ Arrear added successfully';

  @override
  String get emergencyArrearsCollectedToast =>
      '✅ Collected and added to emergency fund automatically';

  @override
  String get emergencyArrearsDeletedToast => 'Arrear deleted';

  @override
  String confirmDeleteArrearBody(String title) {
    return 'Are you sure you want to delete the arrear for \"$title\"?';
  }

  @override
  String get ratingTabAdd => 'Add Rating';

  @override
  String get ratingTabList => 'Reviews';

  @override
  String get pushAutoContactAddedTitle => 'New Maintenance Contact Added';

  @override
  String pushAutoContactAddedBody(String name) {
    return '\"$name\" was added to the building maintenance directory';
  }

  @override
  String get pushAutoPollVotedTitle => 'New Poll Vote';

  @override
  String pushAutoPollVotedBody(String apt) {
    return '$apt: Voted in building polls';
  }

  @override
  String get emergencyArrearsEditTitle => 'Edit Arrear';

  @override
  String get emergencyArrearsUpdatedToast => '✅ Arrear updated successfully';

  @override
  String get ratingDeletedToast => 'Rating deleted';

  @override
  String confirmDeleteRatingBody(String apt) {
    return 'Are you sure you want to delete $apt\'s rating?';
  }

  @override
  String get aptsTabActive => 'Active Apts';

  @override
  String get aptsTabClosed => 'Closed Apts';

  @override
  String get closedAptsInfoBanner =>
      'Closed/unoccupied apartments (no monthly bills) — only special building fees appear here, and collected amounts go straight to the Emergency Fund.';

  @override
  String closedAptDueLabel(String amount) {
    return 'Due: $amount';
  }

  @override
  String get closedAptClearLabel => 'Clear — no dues ✓';

  @override
  String get specialFeeBtn => 'Special Fee';

  @override
  String get specialFeeDialogTitle => 'Add Special / Non-Monthly Fee';

  @override
  String get specialFeeNameLabel => 'Fee Title / Reason';

  @override
  String get specialFeeNameHint => 'e.g. Marble work & elevator painting';

  @override
  String get specialFeeTargetLabel => 'Target Apartments';

  @override
  String specialFeeTargetAll(int count) {
    return 'All ($count)';
  }

  @override
  String specialFeeTargetClosed(int count) {
    return 'Closed ($count)';
  }

  @override
  String get specialFeeTargetCustom => 'Select Apts';

  @override
  String get specialFeeModePerApt => 'Fixed per apt';

  @override
  String get specialFeeModeSplit => 'Split total';

  @override
  String get specialFeeAmountPerAptLabel => 'Amount per apartment (EGP)';

  @override
  String get specialFeeAmountTotalLabel => 'Total amount to split (EGP)';

  @override
  String specialFeePreviewLine(int perApt, int count, int total) {
    return 'Adds $perApt EGP to $count apts (Total: $total EGP → Emergency)';
  }

  @override
  String get specialFeeApplyBtn => 'Apply Fee';

  @override
  String get specialFeeCollectBtn => 'Collected ✓';

  @override
  String get specialFeePaidTag => 'Paid ✓';

  @override
  String get specialFeeAddedToast => '✅ Special fee applied successfully';

  @override
  String get specialFeeCollectedToast =>
      '✅ Collected and added to Emergency Fund automatically';

  @override
  String get specialFeeDeletedToast => 'Special fee deleted';

  @override
  String get aptStatusActive => 'Active';

  @override
  String get aptStatusClosed => 'Closed';

  @override
  String get convertToActiveBtn => 'Set Active';

  @override
  String get convertToClosedBtn => 'Set Closed';

  @override
  String get aptConvertedToActiveToast =>
      '✅ Apartment switched to Active and monthly count updated';

  @override
  String get aptConvertedToClosedToast =>
      '✅ Apartment switched to Closed and monthly count updated';

  @override
  String get myProfileTitle => 'My Apartment Profile';

  @override
  String get myProfileBtn => 'Profile';

  @override
  String get floorLabel => 'Floor';

  @override
  String get floorHint => 'e.g. 3rd Floor';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get phoneNumberHint => '01012345678';

  @override
  String get showPhoneToNeighborsLabel => 'Show my phone to neighbors';

  @override
  String get showPhoneToNeighborsSub =>
      'If off, only the building manager can see it';

  @override
  String get saveProfileBtn => 'Save Profile';

  @override
  String get profileSavedToast => '✅ Apartment profile saved successfully';

  @override
  String get profileSelectAptFirst =>
      'Select your apartment above and unlock it with its passcode to edit your profile';

  @override
  String get changeAptPassTitle => 'Change Apartment Passcode';

  @override
  String get currentPassLabel => 'Current Passcode';

  @override
  String get newPassLabel => 'New Passcode';

  @override
  String get confirmNewPassLabel => 'Confirm New Passcode';

  @override
  String get saveNewPassBtn => 'Update Passcode';

  @override
  String get aptPassChangedToast => '✅ Apartment passcode updated successfully';

  @override
  String get forgotPassSectionTitle => 'Forgot Passcode?';

  @override
  String get forgotPassDesc =>
      'To protect your apartment, you can request a passcode reset from the building manager in one tap.';

  @override
  String get requestPassResetBtn => 'Request Reset from Manager';

  @override
  String get whatsappManagerBtn => 'WhatsApp Manager';

  @override
  String get passResetRequestedToast =>
      '✅ Passcode reset request sent to manager';

  @override
  String get contactCategoryLabel => 'Category / Specialty';

  @override
  String get catAll => 'All';

  @override
  String get catPlumbing => 'Plumbing';

  @override
  String get catElectric => 'Electricity';

  @override
  String get catElevator => 'Elevator';

  @override
  String get catAc => 'AC';

  @override
  String get catCarpentry => 'Carpentry';

  @override
  String get catOther => 'Other';

  @override
  String get exitAppDialogTitle => 'Exit MABNA CARE?';

  @override
  String get exitAppDialogBody =>
      'Tap Stay to continue or Exit to close the app.';

  @override
  String get stayInAppBtn => 'Stay in App';

  @override
  String get exitAppBtn => 'Exit';

  @override
  String get changePhotoBtn => 'Change Photo';

  @override
  String get removePhotoBtn => 'Remove Photo';

  @override
  String get contactsTabNeighbors => 'Neighbors';

  @override
  String get noNeighborsYet =>
      'No neighbors have added their floor or phone number to their profile yet.';

  @override
  String get neighborPhoneHiddenAdminBadge => 'Hidden from neighbors';
}
