public with sharing class TrgContentVersion {

  public static void collegaOpportunita(T tu) {
    ContentVersion[] cvs = tu.triggerNew;
    for (ContentVersion cv : cvs) {
      if (String.isNotBlank(cv.Description)) {
        Pattern myPattern = Pattern.compile('\\{([\\d\\w]+-)+[\\d\\w]+\\}_([0-9]+/)+[0-9]+_[\\d\\w]+');
        Matcher myMatcher = myPattern.matcher(cv.Description);
        if (myMatcher.matches()) {
          try {
            String[] tmp = cv.Description.split('_');
            if (tmp.size() == 2) {
              String idDocumento = tmp[0];
              String idCartella = tmp[1];
              String docDevName = tmp[2];

              Opportunity[] opps = [SELECT Id
                                    FROM Opportunity
                                    WHERE IdCartella__c = :idCartella];

              if (!opps.isEmpty()) {
                Opportunity opp = opps[0];

                Allegato__c all = new Allegato__c(IdDocumentale__c = idDocumento, Opportunita__c = opp.Id, Tipo__c = docDevName);
                all.DataUltimaGenerazione__c = Datetime.now();
                insert all;

                insert new ContentDocumentLink(
                  ContentDocumentId = cv.ContentDocumentId,
                  LinkedEntityId = all.Id,
                  ShareType = 'V'
                );
              }
            }
          } catch (Exception e) {
            insert new Log__c(
              Source__c = 'GetDocThroughTalend',
              ErorrMessage__c = 'Errore nel recupero documenti da filenet: ' + e.getMessage(),
              InputPayload__c = cv.Description
            );
          }
        }
      }
    }
  }
}