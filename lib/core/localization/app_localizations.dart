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
      'home': 'Home',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'sign_in': 'Sign In',
      'logout': 'Logout',
      'requests': 'Requests',
      'all_requests': 'All Requests',
      'request_details': 'Request Details',
      'workflows': 'Workflow',
      'workflow_details': 'Workflow Details',
      'workflow_id': 'Workflow ID',
      'search_workflows': 'Search workflows by name...',
      'sort_name_asc': 'Sort by name (A-Z)',
      'sort_name_desc': 'Sort by name (Z-A)',
      'creation_date': 'Creation Date',
      'steps_count': 'Steps',
      'workflow_steps': 'Workflow Steps',
      'group_details': 'Group Details',
      'group': 'Group',
      'created_by': 'Created By',
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
      'request_number': 'Request No.',
      'status_approved_not_started': 'Approved \u2013 Not Started',
      'status_approved_active': 'Approved \u2013 Active',
      'status_finished_needs_resume': 'Finished \u2013 Resume by',
      'status_finished_resumed': 'Finished \u2013 Resumed',
      'status_cancelled': 'Cancelled',
      'status_expired': 'Expired',
      'status_last_vacation_day': 'Last Vacation Day',
      'workflow_save_success': 'Workflow saved successfully.',
      'workflow_update_success': 'Workflow updated successfully.',
      'new_workflow': 'New Workflow',
      'edit_workflow': 'Edit Workflow',
      'workflow_name': 'Workflow Name',
      'workflow_name_hint': 'Enter workflow name',
      'workflow_name_required': 'Workflow name is required',
      'select_employee': 'Select employee',
      'select_group': 'Select group',
      'select_request_type': 'Select request type',
      'add_group_binding': 'Add Group',
      'no_group_bindings': 'No group bindings added. Tap + to add.',
      'no_steps_error': 'Add at least one step',
      'incomplete_binding_error': 'Complete all group bindings before saving',
      'save': 'Save',
      'remove': 'Remove',
      'search_group': 'Search groups...',
      'search_request_type': 'Search request types...',
      'no_group_error': 'Select a group before saving',
      'no_request_types_error': 'Select at least one request type',
      'request_types': 'Request Types',
      'status_unknown': 'Unknown',
      'groups_management': 'Groups Management',
      'new_group': 'New Group',
      'edit_group': 'Edit Group',
      'group_name': 'Group Name',
      'group_name_hint': 'Enter group name',
      'group_name_required': 'Group name is required',
      'search_groups': 'Search groups...',
      'delete_group': 'Delete Group',
      'delete_group_confirm': 'Are you sure you want to delete group "{name}"?',
      'group_save_success': 'Group saved successfully.',
      'group_update_success': 'Group updated successfully.',
      'company': 'Business Unit',
      'search_company': 'Search business units...',
      'select_company_error': 'Please select a business unit',
      'employees': 'Employees',
      'delete': 'Delete',
      'selected': 'Selected',
      'group_members': 'Group Members',
    },
    'ar': {
      'app_title': 'طلبات الموارد البشرية',
      'home': 'الرئيسية',
      'login': 'تسجيل الدخول',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'sign_in': 'دخول',
      'logout': 'تسجيل الخروج',
      'requests': 'الطلبات',
      'all_requests': 'جميع الطلبات',
      'request_details': 'تفاصيل الطلب',
      'workflows': 'سلسلة الموافقات',
      'workflow_details': 'تفاصيل سلسلة الموافقات',
      'workflow_id': 'رقم سلسلة الموافقات',
      'search_workflows': 'البحث في سلاسل الموافقات بالاسم...',
      'sort_name_asc': 'ترتيب حسب الاسم (أ-ي)',
      'sort_name_desc': 'ترتيب حسب الاسم (ي-أ)',
      'creation_date': 'تاريخ الإنشاء',
      'steps_count': 'عدد الخطوات',
      'workflow_steps': 'خطوات سلسلة الموافقات',
      'group_details': 'تفاصيل المجموعات',
      'group': 'المجموعة',
      'created_by': 'أنشئ بواسطة',
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
      'request_number': 'رقم الطلب',
      'status_approved_not_started': 'معتمد \u2013 لم يبدأ',
      'status_approved_active': 'معتمد \u2013 جارٍ',
      'status_finished_needs_resume': 'منتهية \u2013 الاستئناف بتاريخ',
      'status_finished_resumed': 'منتهية \u2013 تم الاستئناف',
      'status_cancelled': 'ملغي',
      'status_expired': 'منتهية الصلاحية',
      'status_last_vacation_day': 'آخر يوم إجازة',
      'workflow_save_success': 'تم حفظ سلسلة الموافقات بنجاح.',
      'workflow_update_success': 'تم تحديث سلسلة الموافقات بنجاح.',
      'new_workflow': 'سلسلة موافقات جديدة',
      'edit_workflow': 'تعديل سلسلة الموافقات',
      'workflow_name': 'اسم سلسلة الموافقات',
      'workflow_name_hint': 'أدخل اسم سلسلة الموافقات',
      'workflow_name_required': 'اسم سلسلة الموافقات مطلوب',
      'select_employee': 'اختر الموظف',
      'select_group': 'اختر المجموعة',
      'select_request_type': 'اختر نوع الطلب',
      'add_group_binding': 'إضافة مجموعة',
      'no_group_bindings': 'لا توجد مجموعات مضافة. اضغط + للإضافة.',
      'no_steps_error': 'أضف خطوة واحدة على الأقل',
      'incomplete_binding_error': 'أكمل جميع ربط المجموعات قبل الحفظ',
      'save': 'حفظ',
      'remove': 'حذف',
      'search_group': 'ابحث عن مجموعة...',
      'search_request_type': 'ابحث عن نوع الطلب...',
      'no_group_error': 'اختر مجموعة قبل الحفظ',
      'no_request_types_error': 'اختر نوع طلب واحد على الأقل',
      'request_types': 'أنواع الطلبات',
      'status_unknown': 'غير معروف',
      'groups_management': 'إدارة المجموعات',
      'new_group': 'مجموعة جديدة',
      'edit_group': 'تعديل المجموعة',
      'group_name': 'اسم المجموعة',
      'group_name_hint': 'أدخل اسم المجموعة',
      'group_name_required': 'اسم المجموعة مطلوب',
      'search_groups': 'ابحث عن مجموعة...',
      'delete_group': 'حذف المجموعة',
      'delete_group_confirm': 'هل أنت متأكد من حذف المجموعة "{name}"؟',
      'group_save_success': 'تم حفظ المجموعة بنجاح.',
      'group_update_success': 'تم تحديث المجموعة بنجاح.',
      'company': 'منشأة',
      'search_company': 'ابحث عن منشأة...',
      'select_company_error': 'يرجى اختيار منشأة',
      'employees': 'الموظفون',
      'delete': 'حذف',
      'selected': 'المحدد',
      'group_members': 'أعضاء المجموعة',
    },
  };

  String get(String key) {
    final langCode = locale.languageCode;
    return _strings[langCode]?[key] ?? _strings['en']![key] ?? key;
  }

  // Convenience getters
  String get appTitle => get('app_title');
  String get home => get('home');
  String get login => get('login');
  String get username => get('username');
  String get password => get('password');
  String get signIn => get('sign_in');
  String get logout => get('logout');
  String get requests => get('requests');
  String get allRequests => get('all_requests');
  String get requestDetails => get('request_details');
  String get workflows => get('workflows');
  String get workflowDetails => get('workflow_details');
  String get workflowId => get('workflow_id');
  String get searchWorkflows => get('search_workflows');
  String get sortNameAsc => get('sort_name_asc');
  String get sortNameDesc => get('sort_name_desc');
  String get creationDate => get('creation_date');
  String get stepsCount => get('steps_count');
  String get workflowSteps => get('workflow_steps');
  String get groupDetails => get('group_details');
  String get group => get('group');
  String get createdBy => get('created_by');
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
  String get requestNumber => get('request_number');
  String get statusApprovedNotStarted => get('status_approved_not_started');
  String get statusApprovedActive => get('status_approved_active');
  String get statusFinishedNeedsResume => get('status_finished_needs_resume');
  String get statusFinishedResumed => get('status_finished_resumed');
  String get statusCancelled => get('status_cancelled');
  String get statusExpired => get('status_expired');
  String get statusLastVacationDay => get('status_last_vacation_day');
  String get statusUnknown => get('status_unknown');
  String get workflowSaveSuccess => get('workflow_save_success');
  String get workflowUpdateSuccess => get('workflow_update_success');
  String get newWorkflow => get('new_workflow');
  String get editWorkflow => get('edit_workflow');
  String get workflowName => get('workflow_name');
  String get workflowNameHint => get('workflow_name_hint');
  String get workflowNameRequired => get('workflow_name_required');
  String get selectEmployee => get('select_employee');
  String get selectGroup => get('select_group');
  String get selectRequestType => get('select_request_type');
  String get addGroupBinding => get('add_group_binding');
  String get noGroupBindings => get('no_group_bindings');
  String get noStepsError => get('no_steps_error');
  String get incompleteBindingError => get('incomplete_binding_error');
  String get save => get('save');
  String get remove => get('remove');
  String get searchGroup => get('search_group');
  String get searchRequestType => get('search_request_type');
  String get noGroupError => get('no_group_error');
  String get noRequestTypesError => get('no_request_types_error');
  String get requestTypes => get('request_types');
  String get groupsManagement => get('groups_management');
  String get newGroup => get('new_group');
  String get editGroup => get('edit_group');
  String get groupName => get('group_name');
  String get groupNameHint => get('group_name_hint');
  String get groupNameRequired => get('group_name_required');
  String get searchGroups => get('search_groups');
  String get deleteGroup => get('delete_group');
  String deleteGroupConfirm(String name) =>
      get('delete_group_confirm').replaceAll('{name}', name);
  String get groupSaveSuccess => get('group_save_success');
  String get groupUpdateSuccess => get('group_update_success');
  String get company => get('company');
  String get searchCompany => get('search_company');
  String get selectCompanyError => get('select_company_error');
  String get employees => get('employees');
  String get delete => get('delete');
  String get selected => get('selected');
  String get groupMembers => get('group_members');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
