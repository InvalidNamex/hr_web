enum RequestFullStatus {
  acceptedNotStarted,
  acceptedJustStarted,
  pending,
  fineshedNeedsResume,
  fineshedResumed,
  rejected,
  expired,
  cancelled,
  lastVacationDay,
  unKnown,
}

import 'package:flutter/material.dart';
import 'package:hr_requests/core/utils/enums.dart';
import 'package:hr_requests/features/requests/domain/entities/request_additional_data.dart';

RequestFullStatus requestFullStatus({
  required BuildContext context,
  required RequestAdditionalDataEntity? requestAdditionalDataEntity,
}) {
  if (requestAdditionalDataEntity != null) {
    if (requestAdditionalDataEntity.requestStatus == 2) {
      if (requestAdditionalDataEntity.isExpired == true) {
        return RequestFullStatus.expired;
      } else {
        return RequestFullStatus.rejected;
      }
    } else {
      if (requestAdditionalDataEntity.isCancelled == true) {
        return RequestFullStatus.cancelled;
      }
      if (requestAdditionalDataEntity.vacationEnded == true) {
        if (requestAdditionalDataEntity.shouldResumeWork == true) {
          if (requestAdditionalDataEntity.resumeWorkDate != null) {
            return RequestFullStatus.fineshedNeedsResume;
          } else {
            return RequestFullStatus.fineshedResumed;
          }
        } else {
          return RequestFullStatus.fineshedResumed;
        }
      }
      if (requestAdditionalDataEntity.isLastVacationDay == true) {
        return RequestFullStatus.lastVacationDay;
      }
      if (requestAdditionalDataEntity.isVacationActive == true) {
        return RequestFullStatus.acceptedJustStarted;
      }
      if (requestAdditionalDataEntity.isCompleted == true) {
        return RequestFullStatus.acceptedNotStarted;
      }
      return RequestFullStatus.pending;
    }
  } else {
    return RequestFullStatus.unKnown;
  }
}

Widget buildRequestFullStatusWidget({
  required BuildContext context,
  required RequestAdditionalDataEntity? requestAdditionalDataEntity,
}) {
  RequestFullStatus status = requestFullStatus(
    context: context,
    requestAdditionalDataEntity: requestAdditionalDataEntity,
  );
  if (status == RequestFullStatus.fineshedNeedsResume) {
    return ColuredContainer(
      color: AppColors.brown,
      child: Text(
        '${'needResumtion'.tr(context)} ${'at'.tr(context)} ${viewDateFormat.format(requestAdditionalDataEntity!.resumeWorkDate!)}',
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  } else if (status == RequestFullStatus.lastVacationDay) {
    return ColuredContainer(
      color: AppColors.lightGreen,
      child: Text(
        'lasVacationDay'.tr(context),
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  } else if (status == RequestFullStatus.fineshedResumed) {
    return ColuredContainer(
      color: AppColors.lightGreen,
      child: Text(
        'resumed'.tr(context),
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  } else if (status == RequestFullStatus.acceptedNotStarted) {
    return ColuredContainer(
      color: AppColors.lightGreen,
      child: Text(
        '${'approved'.tr(context)} - ${'notStarted'.tr(context)}',
        overflow: TextOverflow.visible,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  } else if (status == RequestFullStatus.acceptedJustStarted) {
    return ColuredContainer(
      color: AppColors.lightGreen,
      child: Text(
        '${'approved'.tr(context)} - ${'started'.tr(context)}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  } else if (status == RequestFullStatus.rejected) {
    return ColuredContainer(
      color: AppColors.red,
      child: Text('rejected'.tr(context), overflow: TextOverflow.ellipsis),
    );
  } else if (status == RequestFullStatus.cancelled) {
    return ColuredContainer(
      color: AppColors.red,
      child: Text('cancelled'.tr(context), overflow: TextOverflow.ellipsis),
    );
  } else if (status == RequestFullStatus.expired) {
    return ColuredContainer(
      color: AppColors.red,
      child: Text('expired'.tr(context), overflow: TextOverflow.ellipsis),
    );
  } else if (status == RequestFullStatus.pending) {
    return ColuredContainer(
      color: AppColors.grey,
      child: Text('submitted'.tr(context)),
    );
  } else if (status == RequestFullStatus.unKnown) {
    return ColuredContainer(
      color: AppColors.grey,
      child: Text('unKnown'.tr(context)),
    );
  } else {
    return ColuredContainer(
      color: AppColors.grey,
      child: Text('unDetermined'.tr(context)),
    );
  }
}