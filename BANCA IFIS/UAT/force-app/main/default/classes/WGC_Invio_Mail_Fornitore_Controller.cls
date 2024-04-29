public class WGC_Invio_Mail_Fornitore_Controller {
	@AuraEnabled
    public static String updateFlagAccount (String accountId, String recordId) {
        
        List<RecordType> recordTypes = new List<RecordType>();
        List<Id> recordTypeIds = new List<Id>();
        
        recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('WGC_Diario_Inserimento_Campagna', 'WGC_Diario_Modifica_Qualifica', 'WGC_Diario_Modifica_Rating', 'WGC_Diario_Nuova_Opportunita', 'Promemoria', 'Previsione_Avvio_Rapporto', 'WGC_Segnalazione') AND SObjectType = 'Task'];
        System.debug('@@@ recordTypes '+ JSON.serialize(recordTypes));
        for(RecordType rt : recordTypes) {
            recordTypeIds.add(rt.Id);
        }
        System.debug('@@@ recordTypeIds '+recordTypeIds);
        
        Account fornitore = [SELECT Id, WGC_Specialista_Factoring__c, WGC_Specialista_Factoring__r.Email FROM Account WHERE Id = :recordId][0];
        System.debug('@@@ fornitore ' + fornitore);
        List<Task> taskAperti = [SELECT Id, WhatId, AccountId, Status, Esito__c, EsitoLivello1__c FROM Task WHERE (WhatId = : fornitore.Id AND Status = 'Aperto' AND RecordTypeId NOT IN : recordTypeIds AND OwnerId =: UserInfo.getUserId())];
        if(taskAperti.size() == 0) {
	        WGC_Soggetti_Collegati__c fornitoreToUpd = [SELECT Id , WGC_Email_Referente_Fornitore__c, WGC_Invio_Mail_Fornitore__c, Anagrafica__c, Anagrafica_Collegata__c, Anagrafica_Collegata__r.Name, Anagrafica_Collegata__r.WGC_Specialista_Factoring__r.Email, toLabel(Anagrafica__r.Filiale__c), Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.WGC_Specialista_Filo_Diretto__c, Anagrafica__r.WGC_Filo_Diretto_Attivo__c FROM WGC_Soggetti_Collegati__c WHERE Anagrafica_Collegata__c = :accountId AND Anagrafica__c = :recordId][0];
	        System.debug('@@@ fornitoreToUpd ' + fornitoreToUpd);
	        //if(fornitore != null && fornitore.WGC_Specialista_Factoring__c!= null) {
	        if(fornitoreToUpd != null && fornitoreToUpd.Anagrafica_Collegata__c != null) {
	            //WGC_Soggetti_Collegati__c fornitoreToUpd = [SELECT Id , WGC_Email_Referente_Fornitore__c, WGC_Invio_Mail_Fornitore__c, Anagrafica__c, Anagrafica_Collegata__c FROM WGC_Soggetti_Collegati__c WHERE Anagrafica_Collegata__c = :accountId AND Anagrafica__c = :recordId][0];
	            //if(fornitoreToUpd != null){
	            	fornitoreToUpd.WGC_Invio_Mail_Fornitore__c = true;  
	                fornitoreToUpd.WGC_Email_Referente_Fornitore__c = fornitore.WGC_Specialista_Factoring__r.Email;
	                System.debug('@@@ account after update '+ fornitoreToUpd);
					update fornitoreToUpd;
					
					//SM - TEN CR 425
					//Se non è attivo filo diretto allora invio task
					//Inoltre aggiorno team ifis con il nuovo operatore
					//TENAM-250 spostata logica nel process builder Sviluppa Fornitore
					// if(!fornitoreToUpd.Anagrafica__r.WGC_Factoring_Attivo__c && (fornitoreToUpd.Anagrafica__r.WGC_Specialista_Filo_Diretto__c == null || (fornitoreToUpd.Anagrafica__r.WGC_Specialista_Filo_Diretto__c != null && !fornitoreToUpd.Anagrafica__r.WGC_Filo_Diretto_Attivo__c))){
					// 	Task taskFornitore = new Task(ActivityDate = System.Today(), Data_Inizio__c = System.Now(), Data_Fine__c = System.Now(), Originator__c = 'Sviluppo Indiretto', Originator_Di_Dettaglio__c = fornitoreToUpd.Anagrafica_Collegata__r.Name, /*OwnerId = fornitoreToUpd.Anagrafica_Collegata__r.WGC_Specialista_Filo_Diretto__c,*/ Priority = 'Media', RecordTypeId = Label.WGC_Tipo_di_record_task, Status = 'Aperto', WhatId = fornitoreToUpd.Anagrafica__c,  Subject = 'Sviluppo Fornitore', WGC_Ragione_Sociale__c = fornitoreToUpd.Anagrafica__c);
					// 	//OwnerId da assegnare tramite assegnazione territoriale
					// 	List<AssegnazioneAnagrafica__c> AssAnagOwnerId = new List<AssegnazioneAnagrafica__c>([SELECT Id, Name, Filiale__c, Utente__c FROM AssegnazioneAnagrafica__c WHERE Filiale__c =: fornitoreToUpd.Anagrafica__r.Filiale__c AND FiloDiretto__c = true LIMIT 1]);

					// 	if(!AssAnagOwnerId.isEmpty())
					// 		taskFornitore.OwnerId = AssAnagOwnerId.get(0).Utente__c;
						
					// 	Insert taskFornitore;

					// 	if(!AssAnagOwnerId.isEmpty()){
					// 		Account anagraficaFornitore = [SELECT Id, Name, WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c FROM Account WHERE Id =: fornitoreToUpd.Anagrafica__c];
					// 		anagraficaFornitore.WGC_Specialista_Filo_Diretto__c = AssAnagOwnerId.get(0).Utente__c;
					// 		anagraficaFornitore.WGC_Filo_Diretto_Attivo__c = true;
					// 		update anagraficaFornitore;
					// 	}
					// }

	            	return 'OK';
	            /*} else {
	                System.debug('@@@ ko ');
	            	return 'KO';
	            }*/
	        } else {
	            System.debug('@@@ ko ');
	            return 'KO';
	        }
        } else {
        	return 'KO Task Aperti';
        }

    }

	// public class Requests {
	// 	@InvocableVariable(label='Soggetto Collegato Input' description='' required=true)
	// 	public List<SObject> inputCollection;
	// }
	   
	// public class Results {
	// 	@InvocableVariable(label='Result' description='Risultato' required=true)
	// 	public String result;
	// }

	@InvocableMethod(label='Crea Task FD')
  	public static void creaTaskFDAssegnazione (List<Id> id) {
		
		// WGC_Soggetti_Collegati__c fornitore = (WGC_Soggetti_Collegati__c)requestList[0];
		WGC_Soggetti_Collegati__c fornitore = [SELECT Id, Name, Anagrafica_Collegata__r.Name, Anagrafica__c, Anagrafica__r.Filiale__c, Anagrafica__r.BillingPostalCode FROM WGC_Soggetti_Collegati__c WHERE Id =: id.get(0) LIMIT 1];

		String result = 'OK';

		try{
			Task taskFornitore = new Task(
				ActivityDate = System.Today(),
				Data_Inizio__c = System.Now(),
				Data_Fine__c = System.Now(),
				Originator__c = 'Sviluppo Indiretto',
				Originator_Di_Dettaglio__c = fornitore.Anagrafica_Collegata__r.Name, 
				Priority = 'Media',
				RecordTypeId = Label.WGC_Tipo_di_record_task,
				Status = 'Aperto',
				WhatId = fornitore.Anagrafica__c,
				Subject = 'Sviluppo Fornitore',
				WGC_Ragione_Sociale__c = fornitore.Anagrafica__c
			);

			List<AssegnazioneAnagrafica__c> AssAnagOwnerId;

			if(fornitore.Anagrafica__r.BillingPostalCode != null){
				AssAnagOwnerId = new List<AssegnazioneAnagrafica__c>([SELECT Id, Name, Filiale__c, Utente__c FROM AssegnazioneAnagrafica__c WHERE CAP__c =: fornitore.Anagrafica__r.BillingPostalCode AND FiloDiretto__c = true LIMIT 1]);
			}

			if(AssAnagOwnerId.isEmpty()){
				String CAP = fornitore.Anagrafica__r.BillingPostalCode;
				if (!String.isEmpty(CAP) && CAP.length()==5){
					List<Comune__c> AComuni = [SELECT  Id, Name, Cap__c FROM Comune__c WHERE Cap__c = :CAP AND FlagStorico__c = false];
					if (AComuni.isEmpty()){    
						string CAP3 = CAP.substring(0, 3);
						CAP = CAP3.rightPad(5, '0');
					}
				}

				AssAnagOwnerId = new List<AssegnazioneAnagrafica__c>([SELECT Id, Name, Filiale__c, Utente__c FROM AssegnazioneAnagrafica__c WHERE CAP__c =: CAP AND FiloDiretto__c = true LIMIT 1]);
			}
			//OwnerId da assegnare tramite assegnazione territoriale
			//List<AssegnazioneAnagrafica__c> AssAnagOwnerId = new List<AssegnazioneAnagrafica__c>([SELECT Id, Name, Filiale__c, Utente__c FROM AssegnazioneAnagrafica__c WHERE Filiale__c =: fornitore.Anagrafica__r.Filiale__c AND FiloDiretto__c = true LIMIT 1]);
			System.debug('@@@ AssAnagOwnerId ' + JSON.serialize(AssAnagOwnerId));
			if(AssAnagOwnerId != null && !AssAnagOwnerId.isEmpty())
				taskFornitore.OwnerId = AssAnagOwnerId.get(0).Utente__c;
			
			Insert taskFornitore;

			if(!AssAnagOwnerId.isEmpty()){
				Account anagraficaFornitore = [SELECT Id, Name, WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c FROM Account WHERE Id =: fornitore.Anagrafica__c];
				anagraficaFornitore.WGC_Specialista_Filo_Diretto__c = AssAnagOwnerId.get(0).Utente__c;
				anagraficaFornitore.WGC_Filo_Diretto_Attivo__c = true;
				update anagraficaFornitore;
			}

		} catch(Exception e){
			System.debug('@@@ e ' + e.getMessage() + ' -- ' + e.getLineNumber());
			result = 'KO';
		}

		// return new List<String>{result};
	}
}