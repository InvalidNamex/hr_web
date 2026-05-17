import 'dart:convert';
import 'package:equatable/equatable.dart';

class RequestType extends Equatable {
  const RequestType({
    required this.id,
    required this.name,
    this.nameAr,
  });

  final int id;
  final String name;
  final String? nameAr;

  factory RequestType.fromJson(Map<String, dynamic> json) {
    final id = (json['ReqTypeID'] ?? json['requestTypeId'] ?? json['id'] ?? 0) as int;

    // ReqName is a JSON-encoded string: '{"en":"...","ar":"..."}'
    final rawName = json['ReqName'] ?? json['requestTypeName'] ?? json['name'] ?? '';
    String name = rawName as String;
    String? nameAr;

    if (name.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(name) as Map<String, dynamic>;
        name = decoded['en'] as String? ?? name;
        nameAr = decoded['ar'] as String?;
      } catch (_) {
        // leave name as-is if parsing fails
      }
    } else {
      nameAr = json['requestTypeNameAr'] as String? ?? json['RequestTypeNameAr'] as String?;
    }

    return RequestType(id: id, name: name, nameAr: nameAr);
  }

  String localizedName(String langCode) =>
      langCode == 'ar' && nameAr != null ? nameAr! : name;

  @override
  List<Object?> get props => [id, name, nameAr];
}

class RequestListItem extends Equatable {
  const RequestListItem({
    required this.empReqMasterId,
    required this.requestId,
    this.employeeName,
    this.employeeNameAr,
    this.requestTypeName,
    this.requestTypeNameAr,
    this.requestDate,
    this.status,
    this.statusAr,
    this.raw = const {},
  });

  final int empReqMasterId;
  final int requestId;
  final String? employeeName;
  final String? employeeNameAr;
  final String? requestTypeName;
  final String? requestTypeNameAr;
  final String? requestDate;
  final String? status;
  final String? statusAr;
  final Map<String, dynamic> raw;

  factory RequestListItem.fromJson(Map<String, dynamic> json) {
    // Parse UserName: may be JSON string {"en":"...","ar":"..."}
    final rawUserName =
        (json['UserName'] ?? json['userName'] ?? json['employeeName'] ?? '') as String;
    String employeeName = rawUserName;
    String? employeeNameAr;
    if (rawUserName.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(rawUserName) as Map<String, dynamic>;
        employeeName = decoded['en'] as String? ?? rawUserName;
        employeeNameAr = decoded['ar'] as String?;
      } catch (_) {}
    }

    // Parse ReqName: may be JSON string {"en":"...","ar":"..."}
    final rawReqName =
        (json['ReqName'] ?? json['requestTypeName'] ?? json['RequestTypeName'] ?? '') as String;
    String requestTypeName = rawReqName;
    String? requestTypeNameAr;
    if (rawReqName.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(rawReqName) as Map<String, dynamic>;
        requestTypeName = decoded['en'] as String? ?? rawReqName;
        requestTypeNameAr = decoded['ar'] as String?;
      } catch (_) {}
    }

    // RequestStatus is an int; map to label
    final statusRaw = json['RequestStatus'] ?? json['requestStatus'] ?? json['status'];
    final statusInt =
        statusRaw is int ? statusRaw : int.tryParse('$statusRaw') ?? 0;

    final masterId = (json['MasterID'] ??
            json['empReqMasterID'] ??
            json['EmpReqMasterID'] ??
            json['empReqMasterId'] ??
            0) as int;

    return RequestListItem(
      empReqMasterId: masterId,
      // ReqTypeID is the only secondary ID available in the list response
      requestId: (json['ReqTypeID'] ??
              json['requestID'] ??
              json['RequestID'] ??
              masterId) as int,
      employeeName: employeeName.isEmpty ? null : employeeName,
      employeeNameAr: employeeNameAr,
      requestTypeName: requestTypeName.isEmpty ? null : requestTypeName,
      requestTypeNameAr: requestTypeNameAr,
      requestDate: json['ReqDate'] as String? ?? json['requestDate'] as String?,
      status: _statusLabel(statusInt),
      statusAr: _statusLabelAr(statusInt),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static String _statusLabel(int s) {
    switch (s) {
      case 0: return 'Pending';
      case 1: return 'Approved';
      case 2: return 'Rejected';
      case 3: return 'Cancelled';
      default: return 'Status $s';
    }
  }

  static String _statusLabelAr(int s) {
    switch (s) {
      case 0: return 'قيد الانتظار';
      case 1: return 'موافق عليه';
      case 2: return 'مرفوض';
      case 3: return 'ملغي';
      default: return 'حالة $s';
    }
  }

  String localizedEmployeeName(String langCode) =>
      langCode == 'ar' && employeeNameAr != null ? employeeNameAr! : (employeeName ?? '');

  String localizedTypeName(String langCode) =>
      langCode == 'ar' && requestTypeNameAr != null
          ? requestTypeNameAr!
          : (requestTypeName ?? '');

  String localizedStatus(String langCode) =>
      langCode == 'ar' && statusAr != null ? statusAr! : (status ?? '');

  @override
  List<Object?> get props => [empReqMasterId, requestId];
}

class RequestListResponse {
  const RequestListResponse({
    required this.items,
    required this.totalCount,
  });

  final List<RequestListItem> items;
  final int totalCount;

  factory RequestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<dynamic> rawItems = [];

    // API returns data as a List directly; dataCount is at root level
    if (data is List) {
      rawItems = data;
    } else if (data is Map<String, dynamic>) {
      rawItems = (data['items'] ?? data['Items'] ?? data['list'] ?? data['List'] ?? []) as List;
    }

    final int total = (json['dataCount'] ??
            json['totalCount'] ??
            json['TotalCount'] ??
            rawItems.length) as int;

    return RequestListResponse(
      items: rawItems
          .map((e) => RequestListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: total,
    );
  }
}

// Helper: decode JSON-encoded localized string {"en":"...","ar":"..."}
({String en, String? ar}) _decodeLocalized(dynamic raw) {
  if (raw == null) return (en: '', ar: null);
  final s = raw as String;
  if (s.trim().startsWith('{')) {
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return (en: m['en'] as String? ?? s, ar: m['ar'] as String?);
    } catch (_) {}
  }
  return (en: s, ar: null);
}

class WorkflowUserDetail extends Equatable {
  const WorkflowUserDetail({
    required this.subRequestId,
    this.userName,
    this.userNameAr,
    this.reqDate,
    this.declineReason,
    this.approveState,
  });

  final int subRequestId;
  final String? userName;
  final String? userNameAr;
  final String? reqDate;
  final String? declineReason;
  /// Only present on workflow steps (not on initiator/resumeWork).
  final int? approveState;

  factory WorkflowUserDetail.fromJson(Map<String, dynamic> json) {
    final name = _decodeLocalized(json['userName']);
    return WorkflowUserDetail(
      subRequestId: (json['subRequestId'] ?? 0) as int,
      userName:     name.en.isEmpty ? null : name.en,
      userNameAr:   name.ar,
      reqDate:      json['reqDate'] as String?,
      declineReason: json['declineReason'] as String?,
      approveState:  json['approveState'] as int?,
    );
  }

  String localizedUserName(String langCode) =>
      langCode == 'ar' && userNameAr != null ? userNameAr! : (userName ?? '');

  @override
  List<Object?> get props => [subRequestId, userName, reqDate];
}

class RequestUserDetails extends Equatable {
  const RequestUserDetails({
    this.initiatorDetails,
    this.requestWorkFlowDetails = const [],
    this.subRequests = const [],
    this.resumeWorkDetails,
  });

  final WorkflowUserDetail? initiatorDetails;
  final List<WorkflowUserDetail> requestWorkFlowDetails;
  final List<WorkflowUserDetail> subRequests;
  final WorkflowUserDetail? resumeWorkDetails;

  factory RequestUserDetails.fromJson(Map<String, dynamic> json) {
    WorkflowUserDetail? _parseDetail(dynamic v) =>
        v is Map<String, dynamic> ? WorkflowUserDetail.fromJson(v) : null;

    List<WorkflowUserDetail> _parseList(dynamic v) => v is List
        ? v
            .whereType<Map<String, dynamic>>()
            .map(WorkflowUserDetail.fromJson)
            .toList()
        : [];

    return RequestUserDetails(
      initiatorDetails:        _parseDetail(json['initiatorDetails']),
      requestWorkFlowDetails:  _parseList(json['requestWorkFlowDetails']),
      subRequests:             _parseList(json['subRequests']),
      resumeWorkDetails:       _parseDetail(json['resumeWorkDetails']),
    );
  }

  @override
  List<Object?> get props =>
      [initiatorDetails, requestWorkFlowDetails, subRequests, resumeWorkDetails];
}

class RequestInfo extends Equatable {
  const RequestInfo({
    required this.empReqMasterId,
    required this.vacReqDetailId,
    required this.employeeId,
    this.employeeName,
    this.employeeNameAr,
    this.requestTypeName,
    this.requestTypeNameAr,
    this.requestNumber,
    this.alterEmpName,
    this.alterEmpNameAr,
    this.exitRentryTypeName,
    this.exitRentryTypeNameAr,
    this.vacTypeName,
    this.vacTypeNameAr,
    this.fromDate,
    this.toDate,
    this.toDateOriginal,
    this.departingDate,
    this.returningDate,
    this.daysNum,
    this.visaDuration = 0,
    this.advSal = false,
    this.ticket = false,
    this.exitRentry = false,
    this.tickAttach,
    this.vacReason,
    this.attachPath,
    this.declineReason,
    this.processingDate,
    this.processingStatus,
    this.processingReason,
    this.reqTypeId = 0,
    this.processedReqName,
    this.requestStatus = 0,
    this.stepNo = 0,
    this.isProcessed = false,
    this.isCompleted = false,
    this.isCancelled = false,
    this.subRequestExists = false,
    this.hasActiveSubRequest = false,
    this.shouldResumeWork = false,
    this.isVacationEnded = false,
    this.visaDate,
    this.exitRentryCostTypeId = 0,
    this.exitRentryCostTypeName,
    this.requestUserDetails,
    this.raw = const {},
  });

  final int empReqMasterId;
  final int vacReqDetailId;
  final int employeeId;
  final String? employeeName;
  final String? employeeNameAr;
  final String? requestTypeName;
  final String? requestTypeNameAr;
  final int? requestNumber;
  final String? alterEmpName;
  final String? alterEmpNameAr;
  final String? exitRentryTypeName;
  final String? exitRentryTypeNameAr;
  final String? vacTypeName;
  final String? vacTypeNameAr;
  final String? fromDate;
  final String? toDate;
  final String? toDateOriginal;
  final String? departingDate;
  final String? returningDate;
  final int? daysNum;
  final int visaDuration;
  final bool advSal;
  final bool ticket;
  final bool exitRentry;
  final String? tickAttach;
  final String? vacReason;
  final String? attachPath;
  final String? declineReason;
  final String? processingDate;
  final String? processingStatus;
  final String? processingReason;
  final int reqTypeId;
  final String? processedReqName;
  final int requestStatus;
  final int stepNo;
  final bool isProcessed;
  final bool isCompleted;
  final bool isCancelled;
  final bool subRequestExists;
  final bool hasActiveSubRequest;
  final bool shouldResumeWork;
  final bool isVacationEnded;
  final String? visaDate;
  final int exitRentryCostTypeId;
  final String? exitRentryCostTypeName;
  final RequestUserDetails? requestUserDetails;
  final Map<String, dynamic> raw;

  factory RequestInfo.fromJson(Map<String, dynamic> json) {
    final data =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final empName    = _decodeLocalized(data['empName']);
    final reqName    = _decodeLocalized(data['requestName']);
    final alterName  = _decodeLocalized(data['alterEmpName']);
    final exitType   = _decodeLocalized(data['exitRentryTypeName']);
    final vacType    = _decodeLocalized(data['vacTypeName']);

    final rawUserDetails = data['requestUserDetails'];
    final userDetails = rawUserDetails is Map<String, dynamic>
        ? RequestUserDetails.fromJson(rawUserDetails)
        : null;

    return RequestInfo(
      empReqMasterId: (data['empReqMasterID'] ?? data['empReqMasterId'] ?? 0) as int,
      vacReqDetailId: (data['vacReqDetailID'] ?? data['vacReqDetailId'] ?? 0) as int,
      employeeId:     (data['empID'] ?? data['empId'] ?? data['employeeId'] ?? 0) as int,
      employeeName:         empName.en.isEmpty   ? null : empName.en,
      employeeNameAr:       empName.ar,
      requestTypeName:      reqName.en.isEmpty   ? null : reqName.en,
      requestTypeNameAr:    reqName.ar,
      requestNumber:        data['requestNumber'] as int?,
      alterEmpName:         alterName.en.isEmpty ? null : alterName.en,
      alterEmpNameAr:       alterName.ar,
      exitRentryTypeName:   exitType.en.isEmpty  ? null : exitType.en,
      exitRentryTypeNameAr: exitType.ar,
      vacTypeName:          vacType.en.isEmpty   ? null : vacType.en,
      vacTypeNameAr:        vacType.ar,
      fromDate:             _nonEmpty(data['fromDate']),
      toDate:               _nonEmpty(data['toDate']),
      toDateOriginal:       _nonEmpty(data['toDateOriginal']),
      departingDate:        _nonEmpty(data['departingDate']),
      returningDate:        _nonEmpty(data['returningDate']),
      daysNum:              data['daysNum'] as int?,
      visaDuration:         (data['visaDuration'] as int?) ?? 0,
      advSal:               (data['advSal'] as bool?) ?? false,
      ticket:               (data['ticket'] as bool?) ?? false,
      exitRentry:           (data['exitRentry'] as bool?) ?? false,
      tickAttach:           _nonEmpty(data['tickAttach']),
      vacReason:            _nonEmpty(data['vacReason']),
      attachPath:           _nonEmpty(data['attachPath']),
      declineReason:        _nonEmpty(data['declineReason']),
      processingDate:       _nonEmpty(data['processingDate']),
      processingStatus:     data['processingStatus'] as String?,
      processingReason:     _nonEmpty(data['processingReason']),
      reqTypeId:            (data['reqTypeId'] as int?) ?? 0,
      processedReqName:     _nonEmpty(data['processedReqName']),
      requestStatus:        (data['requestStatus'] as int?) ?? 0,
      stepNo:               (data['stepNo'] as int?) ?? 0,
      isProcessed:          (data['isProcessed'] as bool?) ?? false,
      isCompleted:          (data['isCompleted'] as bool?) ?? false,
      isCancelled:          (data['isCancelled'] as bool?) ?? false,
      subRequestExists:     (data['subRequestExists'] as bool?) ?? false,
      hasActiveSubRequest:  (data['hasActiveSubRequest'] as bool?) ?? false,
      shouldResumeWork:     (data['shouldResumeWork'] as bool?) ?? false,
      isVacationEnded:      (data['isVacationEnded'] as bool?) ?? false,
      visaDate:             _nonEmpty(data['visaDate']),
      exitRentryCostTypeId: (data['exitRentryCostTypeId'] as int?) ?? 0,
      exitRentryCostTypeName: data['exitRentryCostTypeName'] as String?,
      requestUserDetails:   userDetails,
      raw: Map<String, dynamic>.from(data),
    );
  }

  static String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty || s == '01/01/1900' ? null : s;
  }

  String localizedEmployeeName(String langCode) =>
      langCode == 'ar' && employeeNameAr != null ? employeeNameAr! : (employeeName ?? '');

  String localizedRequestType(String langCode) =>
      langCode == 'ar' && requestTypeNameAr != null ? requestTypeNameAr! : (requestTypeName ?? '');

  String get statusLabel => RequestListItem._statusLabel(requestStatus);
  String get statusLabelAr => RequestListItem._statusLabelAr(requestStatus);
  String localizedStatus(String langCode) =>
      langCode == 'ar' ? statusLabelAr : statusLabel;

  @override
  List<Object?> get props => [empReqMasterId, vacReqDetailId];
}

class ExecuteVacationRequest extends Equatable {
  const ExecuteVacationRequest({
    required this.empReqMasterId,
    required this.vacReqDetailId,
    required this.empId,
  });

  final int empReqMasterId;
  final int vacReqDetailId;
  final int empId;

  Map<String, dynamic> toJson() => {
        'empReqMasterID': empReqMasterId,
        'vacReqDetailID': vacReqDetailId,
        'empId': empId,
      };

  @override
  List<Object?> get props => [empReqMasterId, vacReqDetailId, empId];
}
