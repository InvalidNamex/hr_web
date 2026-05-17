import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _strings = {
    'en': {
      'app_title': 'HR Requests',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'sign_in': 'Sign In',
      'logout': 'Logout',
      'requests': 'Requests',
      'all_requests': 'All Requests',
      'request_details': 'Request Details',
      'execute': 'Execute',
      'undo': 'Undo',
      'execute_success': 'Request approved successfully.',
      'undo_success': 'Approval undone successfully.',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'no_data': 'No data found.',
      'confirm_execute': 'Confirm Execute',
      'confirm_undo': 'Confirm Undo',
      'confirm_execute_msg': 'Are you sure you want to execute this request?',
      'confirm_undo_msg': 'Are you sure you want to undo this request?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'load_more': 'Load more',
      'search_employee': 'Search by employee name...',
      'date_filter': 'Date Range',
      'clear_filters': 'Clear Filters',
      'all': 'All',
      'status_pending': 'Pending',
      'status_approved': 'Approved',
      'status_rejected': 'Rejected',
      'summary_total': 'Total',
      'employee': 'Employee',
      'request_type': 'Request Type',
      'vacation_type': 'Vacation Type',
      'alternate_employee': 'Alternate Employee',
      'exit_reentry_type': 'Exit/Re-entry Type',
      'from_date': 'From',
      'to_date': 'To',
      'days': 'Days',
      'status': 'Status',
      'decline_reason': 'Decline Reason',
      'reason': 'Reason',
      'advance_salary': 'Advance Salary',
      'ticket': 'Ticket',
      'exit_reentry': 'Exit/Re-entry',
      'approval_flow': 'Approval Flow',
      'initiator': 'Initiator',
      'approver': 'Approver',
      'resume_work': 'Resume Work',
      'step_approved': 'Approved',
      'step_rejected': 'Rejected',
      'step_pending': 'Pending',
    },
    'ar': {
      'app_title': 'طلبات الموارد البشرية',
      'login': 'تسجيل الدخول',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'sign_in': 'دخول',
      'logout': 'تسجيل الخروج',
      'requests': 'الطلبات',
      'all_requests': 'جميع الطلبات',
      'request_details': 'تفاصيل الطلب',
      'execute': 'تنفيذ',
      'undo': 'تراجع',
      'execute_success': 'تم اعتماد الطلب بنجاح.',
      'undo_success': 'تم إلغاء الاعتماد بنجاح.',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'retry': 'إعادة المحاولة',
      'no_data': 'لا توجد بيانات.',
      'confirm_execute': 'تأكيد التنفيذ',
      'confirm_undo': 'تأكيد التراجع',
      'confirm_execute_msg': 'هل أنت متأكد من تنفيذ هذا الطلب؟',
      'confirm_undo_msg': 'هل أنت متأكد من التراجع عن هذا الطلب؟',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'language': 'اللغة',
      'load_more': 'تحميل المزيد',
      'search_employee': 'البحث باسم الموظف...',
      'date_filter': 'نطاق التاريخ',
      'clear_filters': 'مسح الفلاتر',
      'all': 'الكل',
      'status_pending': 'قيد الانتظار',
      'status_approved': 'موافق عليه',
      'status_rejected': 'مرفوض',
      'summary_total': 'الإجمالي',
      'employee': 'الموظف',
      'request_type': 'نوع الطلب',
      'vacation_type': 'نوع الإجازة',
      'alternate_employee': 'الموظف البديل',
      'exit_reentry_type': 'نوع الخروج والعودة',
      'from_date': 'من',
      'to_date': 'إلى',
      'days': 'أيام',
      'status': 'الحالة',
      'decline_reason': 'سبب الرفض',
      'reason': 'السبب',
      'advance_salary': 'سلفة راتب',
      'ticket': 'تذكرة سفر',
      'exit_reentry': 'خروج وعودة',
      'approval_flow': 'سير الاعتماد',
      'initiator': 'مقدم الطلب',
      'approver': 'معتمد',
      'resume_work': 'استئناف العمل',
      'step_approved': 'معتمد',
      'step_rejected': 'مرفوض',
      'step_pending': 'قيد الانتظار',
    },
  };

  String get(String key) {
    final langCode = locale.languageCode;
    return _strings[langCode]?[key] ?? _strings['en']![key] ?? key;
  }

  // Convenience getters
  String get appTitle => get('app_title');
  String get login => get('login');
  String get username => get('username');
  String get password => get('password');
  String get signIn => get('sign_in');
  String get logout => get('logout');
  String get requests => get('requests');
  String get allRequests => get('all_requests');
  String get requestDetails => get('request_details');
  String get execute => get('execute');
  String get undo => get('undo');
  String get executeSuccess => get('execute_success');
  String get undoSuccess => get('undo_success');
  String get loading => get('loading');
  String get error => get('error');
  String get retry => get('retry');
  String get noData => get('no_data');
  String get confirmExecute => get('confirm_execute');
  String get confirmUndo => get('confirm_undo');
  String get confirmExecuteMsg => get('confirm_execute_msg');
  String get confirmUndoMsg => get('confirm_undo_msg');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get darkMode => get('dark_mode');
  String get lightMode => get('light_mode');
  String get language => get('language');
  String get employee => get('employee');
  String get requestType => get('request_type');
  String get searchEmployee => get('search_employee');
  String get dateFilter => get('date_filter');
  String get clearFilters => get('clear_filters');
  String get all => get('all');
  String get statusPending => get('status_pending');
  String get statusApproved => get('status_approved');
  String get statusRejected => get('status_rejected');
  String get summaryTotal => get('summary_total');
  String get vacationType => get('vacation_type');
  String get alternateEmployee => get('alternate_employee');
  String get exitReentryType => get('exit_reentry_type');
  String get fromDate => get('from_date');
  String get toDate => get('to_date');
  String get days => get('days');
  String get status => get('status');
  String get declineReason => get('decline_reason');
  String get reason => get('reason');
  String get advanceSalary => get('advance_salary');
  String get ticket => get('ticket');
  String get exitReentry => get('exit_reentry');
  String get approvalFlow => get('approval_flow');
  String get initiator => get('initiator');
  String get approver => get('approver');
  String get resumeWork => get('resume_work');
  String get stepApproved => get('step_approved');
  String get stepRejected => get('step_rejected');
  String get stepPending => get('step_pending');
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
