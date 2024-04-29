public with sharing class CmpProcessiApprovativi {
   @AuraEnabled
   public static List<ProcessInstanceWorkitem> getPendingItems() {
    return [SELECT
      Id,
      ActorId,
      ProcessInstanceId,
      CreatedDate,
      ProcessInstance.TargetObject.Name,
      ProcessInstance.SubmittedBy.Name,
      ProcessInstance.Status
      FROM ProcessInstanceWorkitem
      WHERE ProcessInstance.IsDeleted = false
      AND ActorId = :UserInfo.getUserId()
      AND ProcessInstance.Status = 'Pending'
      ORDER BY Createddate ASC
    ];
  }
}