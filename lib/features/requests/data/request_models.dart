import 'dart:convert';
import 'package:equatable/equatable.dart';

enum RequestFullStatus {
  /// Approved but vacation has not started yet.
  acceptedNotStarted,

  /// Approved and vacation is currently active.
  acceptedJustStarted,

  /// Submitted, awaiting decision.
  pending,

  /// Vacation ended; employee must return on a specific resume date.
  finishedNeedsResume,

  /// Vacation ended; employee has already resumed work (or no resume date set).
  finishedResumed,

  /// Request rejected.
  rejected,

  /// Request auto-rejected because it expired before completion.
  expired,

  /// Request cancelled.
  cancelled,

  /// Today is the last day of the vacation.
  lastVacationDay,

  /// No additional data available.
  unknown,
}

class RequestType extends Equatable {
  const RequestType({required this.id, required this.name, this.nameAr});

  final int id;
  final String name;
  final String? nameAr;

  factory RequestType.fromJson(Map<String, dynamic> json) {
    final id =
        (json['ReqTypeID'] ?? json['requestTypeId'] ?? json['id'] ?? 0) as int;

    // ReqName is a JSON-encoded string: '{"en":"...","ar":"..."}'
    final rawName =
        json['ReqName'] ?? json['requestTypeName'] ?? json['name'] ?? '';
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
      nameAr =
          json['requestTypeNameAr'] as String? ??
          json['RequestTypeNameAr'] as String?;
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
    this.requestNumber,
    this.requestSummary,
    this.requestSummaryAr,
    this.employeeName,
    this.employeeNameAr,
    this.requestTypeName,
    this.requestTypeNameAr,
    this.requestDate,
    this.status,
    this.statusAr,
    this.additionalData,
    this.raw = const {},
  });

  final int empReqMasterId;
  final int requestId;
  final int? requestNumber;
  final String? requestSummary;
  final String? requestSummaryAr;
  final String? employeeName;
  final String? employeeNameAr;
  final String? requestTypeName;
  final String? requestTypeNameAr;
  final String? requestDate;
  final String? status;
  final String? statusAr;
  final RequestAdditionalData? additionalData;
  final Map<String, dynamic> raw;

  factory RequestListItem.fromJson(Map<String, dynamic> json) {
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse('$value');
    }

    // Parse UserName: may be JSON string {"en":"...","ar":"..."}
    final rawUserName =
        (json['UserName'] ?? json['userName'] ?? json['employeeName'] ?? '')
            as String;
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
        (json['ReqName'] ??
                json['requestTypeName'] ??
                json['RequestTypeName'] ??
                '')
            as String;
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
    final statusRaw =
        json['RequestStatus'] ?? json['requestStatus'] ?? json['status'];
    final statusInt = statusRaw is int
        ? statusRaw
        : int.tryParse('$statusRaw') ?? 0;

    final masterId =
        (json['MasterID'] ??
                json['empReqMasterID'] ??
                json['EmpReqMasterID'] ??
                json['empReqMasterId'] ??
                0)
            as int;
    final reqSummary = _decodeLocalized(
      json['requestSummary'] ?? json['RequestSummary'],
    );

    return RequestListItem(
      empReqMasterId: masterId,
      // ReqTypeID is the only secondary ID available in the list response
      requestId:
          (json['ReqTypeID'] ??
                  json['requestID'] ??
                  json['RequestID'] ??
                  masterId)
              as int,
      requestNumber: _parseInt(
        json['requestNumber'] ??
            json['RequestNumber'] ??
            json['ReqNumber'] ??
            json['ReqNo'] ??
            json['RequestNo'],
      ),
      requestSummary: reqSummary.en.isEmpty ? null : reqSummary.en,
      requestSummaryAr: reqSummary.ar,
      employeeName: employeeName.isEmpty ? null : employeeName,
      employeeNameAr: employeeNameAr,
      requestTypeName: requestTypeName.isEmpty ? null : requestTypeName,
      requestTypeNameAr: requestTypeNameAr,
      requestDate: json['ReqDate'] as String? ?? json['requestDate'] as String?,
      status: _statusLabel(statusInt),
      statusAr: _statusLabelAr(statusInt),
      additionalData: (() {
        final raw = json['AdditionalData'] ?? json['additionalData'];
        if (raw is List && raw.isNotEmpty) {
          return RequestAdditionalData.fromJson(
            raw.first as Map<String, dynamic>,
          );
        }
        return null;
      })(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static String _statusLabel(int s) {
    switch (s) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      case 3:
        return 'Cancelled';
      default:
        return 'Status $s';
    }
  }

  static String _statusLabelAr(int s) {
    switch (s) {
      case 0:
        return 'قيد الانتظار';
      case 1:
        return 'موافق عليه';
      case 2:
        return 'مرفوض';
      case 3:
        return 'ملغي';
      default:
        return 'حالة $s';
    }
  }

  String localizedEmployeeName(String langCode) =>
      langCode == 'ar' && employeeNameAr != null
      ? employeeNameAr!
      : (employeeName ?? '');

  String localizedTypeName(String langCode) =>
      langCode == 'ar' && requestTypeNameAr != null
      ? requestTypeNameAr!
      : (requestTypeName ?? '');

  String localizedSummary(String langCode) =>
      langCode == 'ar' && requestSummaryAr != null
      ? requestSummaryAr!
      : (requestSummary ?? '');

  String localizedStatus(String langCode) =>
      langCode == 'ar' && statusAr != null ? statusAr! : (status ?? '');

  RequestFullStatus get fullStatus {
    final addl = additionalData;
    if (addl == null) return RequestFullStatus.unknown;
    final statusInt = (() {
      final s = raw['RequestStatus'];
      return s is int ? s : int.tryParse('$s') ?? 0;
    })();
    if (statusInt == 2) {
      return addl.isExpired
          ? RequestFullStatus.expired
          : RequestFullStatus.rejected;
    }
    if (addl.isCancelled) return RequestFullStatus.cancelled;
    if (addl.vacationEnded) {
      if (addl.shouldResumeWork) {
        return addl.resumeWorkDate != null
            ? RequestFullStatus.finishedNeedsResume
            : RequestFullStatus.finishedResumed;
      }
      return RequestFullStatus.finishedResumed;
    }
    if (addl.isLastVacationDay) return RequestFullStatus.lastVacationDay;
    if (addl.isVacationActive) return RequestFullStatus.acceptedJustStarted;
    if (addl.isCompleted) return RequestFullStatus.acceptedNotStarted;
    return RequestFullStatus.pending;
  }

  @override
  List<Object?> get props => [empReqMasterId, requestId];
}

class RequestSummary {
  const RequestSummary({
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
    this.cancelledCount = 0,
  });

  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int cancelledCount;

  factory RequestSummary.fromJson(Map<String, dynamic> json) {
    return RequestSummary(
      pendingCount: (json['PendingCount'] ?? json['pendingCount'] ?? 0) as int,
      approvedCount:
          (json['ApprovedCount'] ?? json['approvedCount'] ?? 0) as int,
      rejectedCount:
          (json['RejectedCount'] ?? json['rejectedCount'] ?? 0) as int,
      cancelledCount:
          (json['CancelledCount'] ?? json['cancelledCount'] ?? 0) as int,
    );
  }
}

class RequestListResponse {
  const RequestListResponse({
    required this.items,
    required this.totalCount,
    this.summary,
  });

  final List<RequestListItem> items;
  final int totalCount;
  final RequestSummary? summary;

  factory RequestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<dynamic> rawItems = [];

    // API returns data as a List directly; dataCount is at root level
    if (data is List) {
      rawItems = data;
    } else if (data is Map<String, dynamic>) {
      rawItems =
          (data['items'] ?? data['Items'] ?? data['list'] ?? data['List'] ?? [])
              as List;
    }

    final int total =
        (json['dataCount'] ??
                json['totalCount'] ??
                json['TotalCount'] ??
                rawItems.length)
            as int;

    final rawSummary = json['body'];
    final summary = rawSummary is Map<String, dynamic>
        ? RequestSummary.fromJson(rawSummary)
        : null;

    return RequestListResponse(
      items: rawItems
          .map((e) => RequestListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: total,
      summary: summary,
    );
  }
}

// Helper: decode localized data from object/list or JSON-encoded string.
({String en, String? ar}) _decodeLocalized(dynamic raw) {
  if (raw == null) return (en: '', ar: null);

  ({String en, String? ar}) fromMap(Map<String, dynamic> m) {
    final en = (m['en'] ?? m['En'] ?? m['EN'] ?? '').toString();
    final arRaw = m['ar'] ?? m['Ar'] ?? m['AR'];
    final ar = arRaw == null ? null : arRaw.toString();
    return (en: en, ar: ar);
  }

  if (raw is Map<String, dynamic>) {
    return fromMap(raw);
  }

  if (raw is List && raw.isNotEmpty) {
    final first = raw.first;
    if (first is Map<String, dynamic>) {
      return fromMap(first);
    }
  }

  final s = raw.toString();
  final trimmed = s.trim();

  try {
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final loc = fromMap(decoded);
        if (loc.en.isNotEmpty || (loc.ar?.isNotEmpty ?? false)) return loc;
      }
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          final loc = fromMap(first);
          if (loc.en.isNotEmpty || (loc.ar?.isNotEmpty ?? false)) return loc;
        }
      }
    }
  } catch (_) {
    // Fallback to raw string when payload is not JSON.
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
      userName: name.en.isEmpty ? null : name.en,
      userNameAr: name.ar,
      reqDate: json['reqDate'] as String?,
      declineReason: json['declineReason'] as String?,
      approveState: json['approveState'] as int?,
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
      initiatorDetails: _parseDetail(json['initiatorDetails']),
      requestWorkFlowDetails: _parseList(json['requestWorkFlowDetails']),
      subRequests: _parseList(json['subRequests']),
      resumeWorkDetails: _parseDetail(json['resumeWorkDetails']),
    );
  }

  @override
  List<Object?> get props => [
    initiatorDetails,
    requestWorkFlowDetails,
    subRequests,
    resumeWorkDetails,
  ];
}

/// Parsed representation of a single entry in the API's [AdditionalData] array,
/// present on both list and detail responses.
class RequestAdditionalData {
  const RequestAdditionalData({
    this.isCompleted = false,
    this.shouldResumeWork = false,
    this.vacationEnded = false,
    this.isVacationActive = false,
    this.isLastVacationDay = false,
    this.isCancelled = false,
    this.isExpired = false,
    this.resumeWorkDate,
  });

  final bool isCompleted;
  final bool shouldResumeWork;
  final bool vacationEnded;
  final bool isVacationActive;
  final bool isLastVacationDay;
  final bool isCancelled;
  final bool isExpired;
  final String? resumeWorkDate;

  factory RequestAdditionalData.fromJson(Map<String, dynamic> json) {
    return RequestAdditionalData(
      isCompleted:
          (json['IsCompleted'] ?? json['isCompleted'] ?? false) as bool,
      shouldResumeWork:
          (json['ShouldResumeWork'] ?? json['shouldResumeWork'] ?? false)
              as bool,
      vacationEnded:
          (json['VacationEnded'] ?? json['vacationEnded'] ?? false) as bool,
      isVacationActive:
          (json['IsVacationActive'] ?? json['isVacationActive'] ?? false)
              as bool,
      isLastVacationDay:
          (json['IsLastVacationDay'] ?? json['isLastVacationDay'] ?? false)
              as bool,
      isCancelled:
          (json['IsCancelled'] ?? json['isCancelled'] ?? false) as bool,
      isExpired: (json['IsExpired'] ?? json['isExpired'] ?? false) as bool,
      resumeWorkDate:
          json['ResumeWorkDate'] as String? ??
          json['resumeWorkDate'] as String?,
    );
  }
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
    this.requestSummary,
    this.requestSummaryAr,
    this.vacReason,
    this.attachPath,
    this.declineReason,
    this.processingDate,
    this.processingStatus,
    this.processingReason,
    this.reqTypeId = 0,
    this.processedReqName,
    this.requestStatus = 0,
    this.isExecuted = false,
    this.stepNo = 0,
    this.isProcessed = false,
    this.isCompleted = false,
    this.isCancelled = false,
    this.subRequestExists = false,
    this.hasActiveSubRequest = false,
    this.shouldResumeWork = false,
    this.isVacationEnded = false,
    this.isExpired = false,
    this.isLastVacationDay = false,
    this.isVacationActive = false,
    this.resumeWorkDate,
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
  final String? requestSummary;
  final String? requestSummaryAr;
  final String? vacReason;
  final String? attachPath;
  final String? declineReason;
  final String? processingDate;
  final String? processingStatus;
  final String? processingReason;
  final int reqTypeId;
  final String? processedReqName;
  final int requestStatus;
  final bool isExecuted;
  final int stepNo;
  final bool isProcessed;
  final bool isCompleted;
  final bool isCancelled;
  final bool subRequestExists;
  final bool hasActiveSubRequest;
  final bool shouldResumeWork;
  final bool isVacationEnded;
  final bool isExpired;
  final bool isLastVacationDay;
  final bool isVacationActive;
  final String? resumeWorkDate;
  final String? visaDate;
  final int exitRentryCostTypeId;
  final String? exitRentryCostTypeName;
  final RequestUserDetails? requestUserDetails;
  final Map<String, dynamic> raw;

  factory RequestInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final empName = _decodeLocalized(data['empName']);
    final reqName = _decodeLocalized(data['requestName']);
    final alterName = _decodeLocalized(data['alterEmpName']);
    final exitType = _decodeLocalized(data['exitRentryTypeName']);
    final vacType = _decodeLocalized(data['vacTypeName']);
    final reqSummary = _decodeLocalized(
      data['requestSummary'] ?? data['RequestSummary'],
    );

    final rawUserDetails = data['requestUserDetails'];
    final userDetails = rawUserDetails is Map<String, dynamic>
        ? RequestUserDetails.fromJson(rawUserDetails)
        : null;

    // Parse AdditionalData array; take the first element for field overrides.
    final rawAddl = data['AdditionalData'] ?? data['additionalData'];
    final Map<String, dynamic>? addlData = rawAddl is List && rawAddl.isNotEmpty
        ? rawAddl.first as Map<String, dynamic>?
        : rawAddl is Map<String, dynamic>
        ? rawAddl
        : null;
    bool _addlBool(String addlKey, String fallback) =>
        (addlData?[addlKey] ?? data[fallback] ?? false) as bool;

    return RequestInfo(
      empReqMasterId:
          (data['empReqMasterID'] ?? data['empReqMasterId'] ?? 0) as int,
      vacReqDetailId:
          (data['vacReqDetailID'] ?? data['vacReqDetailId'] ?? 0) as int,
      employeeId:
          (data['empID'] ?? data['empId'] ?? data['employeeId'] ?? 0) as int,
      employeeName: empName.en.isEmpty ? null : empName.en,
      employeeNameAr: empName.ar,
      requestTypeName: reqName.en.isEmpty ? null : reqName.en,
      requestTypeNameAr: reqName.ar,
      requestNumber: data['requestNumber'] as int?,
      alterEmpName: alterName.en.isEmpty ? null : alterName.en,
      alterEmpNameAr: alterName.ar,
      exitRentryTypeName: exitType.en.isEmpty ? null : exitType.en,
      exitRentryTypeNameAr: exitType.ar,
      vacTypeName: vacType.en.isEmpty ? null : vacType.en,
      vacTypeNameAr: vacType.ar,
      fromDate: _nonEmpty(data['fromDate']),
      toDate: _nonEmpty(data['toDate']),
      toDateOriginal: _nonEmpty(data['toDateOriginal']),
      departingDate: _nonEmpty(data['departingDate']),
      returningDate: _nonEmpty(data['returningDate']),
      daysNum: data['daysNum'] as int?,
      visaDuration: (data['visaDuration'] as int?) ?? 0,
      advSal: (data['advSal'] as bool?) ?? false,
      ticket: (data['ticket'] as bool?) ?? false,
      exitRentry: (data['exitRentry'] as bool?) ?? false,
      tickAttach: _nonEmpty(data['tickAttach']),
      requestSummary: _nonEmpty(reqSummary.en),
      requestSummaryAr: _nonEmpty(reqSummary.ar),
      vacReason: _nonEmpty(data['vacReason']),
      attachPath: _nonEmpty(data['attachPath']),
      declineReason: _nonEmpty(data['declineReason']),
      processingDate: _nonEmpty(data['processingDate']),
      processingStatus: data['processingStatus'] as String?,
      processingReason: _nonEmpty(data['processingReason']),
      reqTypeId: (data['reqTypeId'] as int?) ?? 0,
      processedReqName: _nonEmpty(data['processedReqName']),
      requestStatus: (data['requestStatus'] as int?) ?? 0,
      isExecuted: (data['isExecuted'] as bool?) ?? false,
      stepNo: (data['stepNo'] as int?) ?? 0,
      isProcessed: (data['isProcessed'] as bool?) ?? false,
      isCompleted: _addlBool('IsCompleted', 'isCompleted'),
      isCancelled: _addlBool('IsCancelled', 'isCancelled'),
      subRequestExists: (data['subRequestExists'] as bool?) ?? false,
      hasActiveSubRequest: (data['hasActiveSubRequest'] as bool?) ?? false,
      shouldResumeWork: _addlBool('ShouldResumeWork', 'shouldResumeWork'),
      isVacationEnded: _addlBool('VacationEnded', 'isVacationEnded'),
      isExpired: _addlBool('IsExpired', 'isExpired'),
      isLastVacationDay: _addlBool('IsLastVacationDay', 'isLastVacationDay'),
      isVacationActive: _addlBool('IsVacationActive', 'isVacationActive'),
      resumeWorkDate:
          addlData?['ResumeWorkDate'] as String? ??
          data['resumeWorkDate'] as String?,
      visaDate: _nonEmpty(data['visaDate']),
      exitRentryCostTypeId: (data['exitRentryCostTypeId'] as int?) ?? 0,
      exitRentryCostTypeName: data['exitRentryCostTypeName'] as String?,
      requestUserDetails: userDetails,
      raw: Map<String, dynamic>.from(data),
    );
  }

  static String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty || s == '01/01/1900' ? null : s;
  }

  String localizedEmployeeName(String langCode) =>
      langCode == 'ar' && employeeNameAr != null
      ? employeeNameAr!
      : (employeeName ?? '');

  String localizedRequestType(String langCode) =>
      langCode == 'ar' && requestTypeNameAr != null
      ? requestTypeNameAr!
      : (requestTypeName ?? '');

  String localizedReason(String langCode) {
    final summary = langCode == 'ar'
        ? (requestSummaryAr ?? requestSummary)
        : requestSummary;
    if (summary != null && summary.isNotEmpty) return summary;
    return vacReason ?? '';
  }

  String get statusLabel => RequestListItem._statusLabel(requestStatus);
  String get statusLabelAr => RequestListItem._statusLabelAr(requestStatus);
  String localizedStatus(String langCode) =>
      langCode == 'ar' ? statusLabelAr : statusLabel;

  /// Resolves the granular [RequestFullStatus] using all available fields.
  RequestFullStatus get fullStatus {
    if (requestStatus == 2) {
      return isExpired ? RequestFullStatus.expired : RequestFullStatus.rejected;
    }
    if (isCancelled) return RequestFullStatus.cancelled;
    if (isVacationEnded) {
      if (shouldResumeWork) {
        return resumeWorkDate != null
            ? RequestFullStatus.finishedNeedsResume
            : RequestFullStatus.finishedResumed;
      }
      return RequestFullStatus.finishedResumed;
    }
    if (isLastVacationDay) return RequestFullStatus.lastVacationDay;
    if (isVacationActive) return RequestFullStatus.acceptedJustStarted;
    if (isCompleted) return RequestFullStatus.acceptedNotStarted;
    return RequestFullStatus.pending;
  }

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

class WorkflowListItem extends Equatable {
  const WorkflowListItem({
    required this.id,
    required this.name,
    this.creationDate,
    required this.stepsCount,
  });

  final int id;
  final String name;
  final DateTime? creationDate;
  final int stepsCount;

  factory WorkflowListItem.fromJson(Map<String, dynamic> json) {
    final idRaw = json['ID'] ?? json['id'] ?? 0;
    final stepsRaw = json['StepsCount'] ?? json['stepsCount'] ?? 0;

    return WorkflowListItem(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0,
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      creationDate: DateTime.tryParse(
        (json['CreationDate'] ?? json['creationDate'] ?? '').toString(),
      ),
      stepsCount: stepsRaw is int ? stepsRaw : int.tryParse('$stepsRaw') ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, creationDate, stepsCount];
}

class WorkflowStep extends Equatable {
  const WorkflowStep({
    required this.stepNo,
    required this.empId,
    this.username,
    this.usernameAr,
  });

  final int stepNo;
  final int empId;
  final String? username;
  final String? usernameAr;

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    final userName = _decodeLocalized(json['username']);
    final stepRaw = json['stepNo'] ?? json['StepNo'] ?? 0;
    final empIdRaw = json['empId'] ?? json['EmpId'] ?? 0;

    return WorkflowStep(
      stepNo: stepRaw is int ? stepRaw : int.tryParse('$stepRaw') ?? 0,
      empId: empIdRaw is int ? empIdRaw : int.tryParse('$empIdRaw') ?? 0,
      username: userName.en.isEmpty ? null : userName.en,
      usernameAr: userName.ar,
    );
  }

  String localizedUsername(String langCode) =>
      langCode == 'ar' && usernameAr != null ? usernameAr! : (username ?? '');

  @override
  List<Object?> get props => [stepNo, empId, username, usernameAr];
}

class WorkflowGroupDetail extends Equatable {
  const WorkflowGroupDetail({
    required this.groupId,
    required this.requestTypeId,
    required this.groupName,
    this.requestTypeName,
    this.requestTypeNameAr,
  });

  final int groupId;
  final int requestTypeId;
  final String groupName;
  final String? requestTypeName;
  final String? requestTypeNameAr;

  factory WorkflowGroupDetail.fromJson(Map<String, dynamic> json) {
    final requestTypeName = _decodeLocalized(json['requestTypeName']);
    final groupIdRaw = json['groupId'] ?? json['GroupId'] ?? 0;
    final requestTypeIdRaw =
        json['requestTypeId'] ?? json['RequestTypeId'] ?? 0;

    return WorkflowGroupDetail(
      groupId: groupIdRaw is int
          ? groupIdRaw
          : int.tryParse('$groupIdRaw') ?? 0,
      requestTypeId: requestTypeIdRaw is int
          ? requestTypeIdRaw
          : int.tryParse('$requestTypeIdRaw') ?? 0,
      groupName: (json['groupName'] ?? json['GroupName'] ?? '').toString(),
      requestTypeName: requestTypeName.en.isEmpty ? null : requestTypeName.en,
      requestTypeNameAr: requestTypeName.ar,
    );
  }

  String localizedRequestTypeName(String langCode) =>
      langCode == 'ar' && requestTypeNameAr != null
      ? requestTypeNameAr!
      : (requestTypeName ?? '');

  @override
  List<Object?> get props => [
    groupId,
    requestTypeId,
    groupName,
    requestTypeName,
    requestTypeNameAr,
  ];
}

class WorkflowDetails extends Equatable {
  const WorkflowDetails({
    required this.workflowId,
    required this.name,
    this.creationDate,
    this.empCreatedId,
    this.steps = const [],
    this.groupDetails = const [],
  });

  final int workflowId;
  final String name;
  final DateTime? creationDate;
  final int? empCreatedId;
  final List<WorkflowStep> steps;
  final List<WorkflowGroupDetail> groupDetails;

  factory WorkflowDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final workflowIdRaw = data['workflowId'] ?? data['WorkflowId'] ?? 0;
    final empCreatedIdRaw = data['empCreatedID'] ?? data['empCreatedId'];

    final rawSteps = data['steps'];
    final rawGroupDetails = data['groupDetails'];

    return WorkflowDetails(
      workflowId: workflowIdRaw is int
          ? workflowIdRaw
          : int.tryParse('$workflowIdRaw') ?? 0,
      name: (data['name'] ?? data['Name'] ?? '').toString(),
      creationDate: DateTime.tryParse(
        (data['creationDate'] ?? data['CreationDate'] ?? '').toString(),
      ),
      empCreatedId: empCreatedIdRaw is int
          ? empCreatedIdRaw
          : int.tryParse('$empCreatedIdRaw'),
      steps: rawSteps is List
          ? rawSteps
                .whereType<Map<String, dynamic>>()
                .map(WorkflowStep.fromJson)
                .toList()
          : const [],
      groupDetails: rawGroupDetails is List
          ? rawGroupDetails
                .whereType<Map<String, dynamic>>()
                .map(WorkflowGroupDetail.fromJson)
                .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
    workflowId,
    name,
    creationDate,
    empCreatedId,
    steps,
    groupDetails,
  ];
}

// ── Workflow dropdown models ──────────────────────────────────────────────────

class WorkflowDropdownUser extends Equatable {
  const WorkflowDropdownUser({required this.id, this.name, this.nameAr});

  final int id;
  final String? name;
  final String? nameAr;

  factory WorkflowDropdownUser.fromJson(Map<String, dynamic> json) {
    final parsed = _decodeLocalized(json['name']);
    final idRaw = json['id'] ?? json['Id'] ?? 0;
    return WorkflowDropdownUser(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0,
      name: parsed.en.isEmpty ? null : parsed.en,
      nameAr: parsed.ar,
    );
  }

  String localizedName(String langCode) =>
      langCode == 'ar' && nameAr != null ? nameAr! : (name ?? '');

  @override
  List<Object?> get props => [id, name, nameAr];
}

class WorkflowDropdownGroup extends Equatable {
  const WorkflowDropdownGroup({required this.id, required this.name});

  final int id;
  final String name;

  factory WorkflowDropdownGroup.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['Id'] ?? 0;
    return WorkflowDropdownGroup(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class WorkflowDropdownRequestType extends Equatable {
  const WorkflowDropdownRequestType({required this.id, this.name, this.nameAr});

  final int id;
  final String? name;
  final String? nameAr;

  factory WorkflowDropdownRequestType.fromJson(Map<String, dynamic> json) {
    final parsed = _decodeLocalized(json['name']);
    final idRaw = json['id'] ?? json['Id'] ?? 0;
    return WorkflowDropdownRequestType(
      id: idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0,
      name: parsed.en.isEmpty ? null : parsed.en,
      nameAr: parsed.ar,
    );
  }

  String localizedName(String langCode) =>
      langCode == 'ar' && nameAr != null ? nameAr! : (name ?? '');

  @override
  List<Object?> get props => [id, name, nameAr];
}

class WorkflowDropdowns extends Equatable {
  const WorkflowDropdowns({
    required this.users,
    required this.groups,
    required this.requestTypes,
  });

  final List<WorkflowDropdownUser> users;
  final List<WorkflowDropdownGroup> groups;
  final List<WorkflowDropdownRequestType> requestTypes;

  factory WorkflowDropdowns.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<T> _parseList<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      if (raw is! List) return const [];
      return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }

    // De-duplicate request types by id (API may return duplicates)
    final rawTypes = _parseList(
      data['requestTypes'],
      WorkflowDropdownRequestType.fromJson,
    );
    final seen = <int>{};
    final deduped = rawTypes.where((rt) => seen.add(rt.id)).toList();

    return WorkflowDropdowns(
      users: _parseList(data['users'], WorkflowDropdownUser.fromJson),
      groups: _parseList(data['groups'], WorkflowDropdownGroup.fromJson),
      requestTypes: deduped,
    );
  }

  @override
  List<Object?> get props => [users, groups, requestTypes];
}

// ── Save workflow models ──────────────────────────────────────────────────────

class SaveWorkflowStep extends Equatable {
  const SaveWorkflowStep({required this.stepNo, required this.empId});

  final int stepNo;
  final int empId;

  Map<String, dynamic> toJson() => {'StepNo': stepNo, 'EmpId': empId};

  @override
  List<Object?> get props => [stepNo, empId];
}

class SaveWorkflowGroupDetail extends Equatable {
  const SaveWorkflowGroupDetail({
    required this.groupId,
    required this.requestTypeId,
  });

  final int groupId;
  final int requestTypeId;

  Map<String, dynamic> toJson() => {
    'GroupId': groupId,
    'RequestTypeId': requestTypeId,
  };

  @override
  List<Object?> get props => [groupId, requestTypeId];
}

class SaveWorkflowRequest extends Equatable {
  const SaveWorkflowRequest({
    required this.name,
    required this.loggedInUserId,
    required this.groupDetails,
    required this.steps,
  });

  final String name;
  final int loggedInUserId;
  final List<SaveWorkflowGroupDetail> groupDetails;
  final List<SaveWorkflowStep> steps;

  Map<String, dynamic> toJson() => {
    'Name': name,
    'LoggedInUserId': loggedInUserId,
    'GroupDetails': groupDetails.map((g) => g.toJson()).toList(),
    'Steps': steps.map((s) => s.toJson()).toList(),
  };

  @override
  List<Object?> get props => [name, loggedInUserId, groupDetails, steps];
}

class UpdateWorkflowRequest extends Equatable {
  const UpdateWorkflowRequest({
    required this.workflowId,
    required this.name,
    required this.loggedInUserId,
    required this.groupDetails,
    required this.steps,
  });

  final int workflowId;
  final String name;
  final int loggedInUserId;
  final List<SaveWorkflowGroupDetail> groupDetails;
  final List<SaveWorkflowStep> steps;

  Map<String, dynamic> toJson() => {
    'WorkflowId': workflowId,
    'Name': name,
    'LoggedInUserId': loggedInUserId,
    'GroupDetails': groupDetails.map((g) => g.toJson()).toList(),
    'Steps': steps.map((s) => s.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    workflowId,
    name,
    loggedInUserId,
    groupDetails,
    steps,
  ];
}
