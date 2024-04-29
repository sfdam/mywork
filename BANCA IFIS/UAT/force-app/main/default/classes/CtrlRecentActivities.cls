public with sharing class CtrlRecentActivities {

  @RemoteAction
  public static SObject[] fetchActivities(String accountId) {
    List<SObject> eventi = (List<SObject>) [SELECT Id,
      toLabel(Subject),
      AssignedTo__c,
      Description,
      toLabel(EsitoLivello1__c),
      toLabel(EsitoLivello2__c),
      toLabel(EsitoLivello3__c),
      toLabel(EsitoLivello4__c),
      toLabel(EsitoLivello5__c),
      ActivityDate,
      TipoAttivita__c,
      CommentiEsito__c FROM Event
      WHERE AccountId = :accountId
      AND EsitoLivello1__c != null
      AND IsDeleted = FALSE
      ALL ROWS
    ];

    Id promemoria = U.getRecordTypes('Task').get('Promemoria').Id;
    List<SObject> operazioni = (List<SObject>) [SELECT Id,
      toLabel(Subject),
      AssignedTo__c,
      Description,
      toLabel(EsitoLivello1__c),
      toLabel(EsitoLivello2__c),
      toLabel(EsitoLivello3__c),
      toLabel(EsitoLivello4__c),
      toLabel(EsitoLivello5__c),
      ActivityDate,
      TipoAttivita__c,
      CommentiEsito__c FROM Task
      WHERE AccountId = :accountId
      AND RecordTypeId != :promemoria
      AND EsitoLivello1__c != null
      AND IsDeleted = FALSE
      ALL ROWS
    ];

    List<SObject> activities = new List<SObject>();
    activities.addAll(eventi);
    activities.addAll(operazioni);

    return activities;

  }
}