public with sharing class CtrlListeHp {
  @RemoteAction
  public static Task[] fetchMyTasks() {
    Map<String, SObject> rtMap = U.getRecordTypes('Task');
    Set<Id> rts = new Set<Id>{
      rtMap.get('ContattoTelefonicoDiretto').Id,
      rtMap.get('ContattoTelefonicoIndiretto').Id,
      rtMap.get('ContattoTelefonicoLeasing').Id,
      rtMap.get('ContattoTelefonicoCommLending').Id,
      rtMap.get('ContattoTelefonicoFinanzaStrutturata').Id,
      rtMap.get('ContattoTelefonicoFinance').Id,
      rtMap.get('ContattoTelefonicoFastFinance').Id
    };

    return [SELECT
      Id,
      Subject,
      Account.Name,
      Who.Name
      FROM Task
      WHERE IsClosed = FALSE
      AND ActivityDate = TODAY
      AND OwnerId = :UserInfo.getUserId()
      AND RecordTypeId IN :rts
      AND WhatId != NULL
      ORDER BY ActivityDate DESC
      LIMIT 20
    ];
  }

  @RemoteAction
  public static Event[] fetchMyEvents() {

    Map<String, SObject> rtMap = U.getRecordTypes('Event');
    Set<Id> rts = new Set<Id> {
      rtMap.get('VisitaCommerciale').Id,
      rtMap.get('VisitaLeasing').Id,
      rtMap.get('VisitaCommLending').Id,
      rtMap.get('VisitaFinanzaStrutturata').Id,
      rtMap.get('VisitaPoland').Id,
      rtMap.get('VisitaFastFinance').Id
    };

    return [SELECT
      Id,
      Subject,
      Account.Name,
      StartDateTime,
      EndDateTime,
      Location
      FROM Event
      WHERE DAY_ONLY(StartDateTime) = TODAY
      AND OwnerId = :UserInfo.getUserId()
      AND RecordTypeId IN :rts
      AND EsitoLivello1__c = NULL
      AND WhatId != NULL
      ORDER BY StartDateTime ASC
      LIMIT 20
    ];
  }
}