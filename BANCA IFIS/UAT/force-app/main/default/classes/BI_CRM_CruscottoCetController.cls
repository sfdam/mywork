public with sharing class BI_CRM_CruscottoCetController  {

public BI_CRM_CruscottoCetController() {

    }

    @AuraEnabled
    public static User getCurrentUser() {
        return [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }


	@AuraEnabled
    public static List<WGC_Cruscotto_Cet__c> assegnaRecord(id idRecordCet) {
	    String userName = UserInfo.getName();
		System.debug('@@@A.M. idRecordCet:' + idRecordCet);
	    
	    WGC_Cruscotto_Cet__c[] cetToUpd = [
                   SELECT Id,
                          Operatore__c,
						  Stato_Opportunita__c,
						  Stato_Interno__c
                     FROM WGC_Cruscotto_Cet__c
                    WHERE id = :idRecordCet
					ORDER BY CreatedDate DESC
            ];
	  System.debug('@@@A.M. cetToUpd:' + cetToUpd);
  
	  if (cetToUpd.size() > 0 && cetToUpd[0].Stato_Opportunita__c == 'Nuova' && cetToUpd[0].Operatore__c == null) {
	    WGC_Cruscotto_Cet__c cetUpd = new WGC_Cruscotto_Cet__c(
		    Id = idRecordCet,
			Operatore__c = userName,
			Stato_Opportunita__c = 'In Lavorazione'
		);
		Update cetUpd; 
      }
	  return cetToUpd;
    }

	@AuraEnabled
    public static WGC_Cruscotto_Cet__c recuperaNdgCET(id idRecordCet) {
		WGC_Cruscotto_Cet__c response = new WGC_Cruscotto_Cet__c();
	    System.debug('@@@A.M. idRecordCet:' + idRecordCet);
		if (idRecordCet == null){
		  response.Id = null;
          return response; 
		} else { 
		  return [SELECT Id, NDG_Anagrafica__c FROM WGC_Cruscotto_Cet__c WHERE Id = :idRecordCet LIMIT 1]; 
		}  
    }

	@AuraEnabled
    public static Account datiAnagrafica(id idAccount) {
		Account response = new Account();
	    System.debug('@@@A.M. idAccount:' + idAccount);
		if (idAccount == null){
		  response.Id = null;
          return response; 
		} else { 
		  return [SELECT Id, NDGGruppo__c, PIVA__c, Name FROM Account WHERE Id = :idAccount LIMIT 1]; 
		}  
    }


}