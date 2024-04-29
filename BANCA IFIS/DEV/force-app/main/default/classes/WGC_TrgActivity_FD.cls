public class WGC_TrgActivity_FD {

    //Metodo che aggiorna il campo CT_Actual__c sul record andamentale dell'operatore di Filo Diretto che ha esitato il task
	//A.M. SDHDFNZ-113701 - Apportando una modifica ad un Task già Chiso si conteggia erroneamente +1 nell'andamentale dei contatti Filo Diretto.
	// Modificata la firma per recuperare anche la situazione precedente alla modifica
    //public static void update_CT_Actual(List<Task> tasks){
	public static void update_CT_Actual(T tu){
		List<Task> tasks = tu.triggerNew;
		Map<Id, SObject> oldMap = tu.oldMap;

		System.debug('@@@ triggers tasks ' + JSON.serialize(tasks));
        //Set utilizzato per recuperare tutti i record di andamentale che hanno come operatore gli owners dei task (In modo da ridurre i risultati sulla query)
        //TODO : Ottimizzare query
        // RecordType.DeveloperName NON è DISPONIBILE COME CAMPO QUINDI NON FUNZIONA (DA MODIFICARE)
        Set<Id> owners = new Set<Id>();
        //Lista utilizzata per filtrare solo i task di Filo Diretto con il particolare RT
        List<Task> tasksToConsider = new List<Task>();
        List<WGC_Andamentale__c> andamentaliTotal = new List<WGC_Andamentale__c>();
        //Lista utilizzata per effettuare update sui record interessati in cambiamenti
        Set<WGC_Andamentale__c> andamentaliToUpdate = new Set<WGC_Andamentale__c>();

        for(Task t : tasks){
		//A.M. SDHDFNZ-113701 - Apportando una modifica ad un Task già Chiso si conteggia erroneamente +1 nell'andamentale dei contatti Filo Diretto.
		// Aggiunta condizione oldMap.get(t.Id).get('Status') != 'Chiuso' per evitare di considerare i task modificati ma già chiusi
            if(t.DiFiloDiretto__c && (t.RecordTypeDevName__c == 'ContattoTelefonicoDiretto' || t.RecordTypeDevName__c == 'ContattoTelefonicoIndiretto')  && t.Status == 'Chiuso' && t.WhatId != null && oldMap.get(t.Id).get('Status') != 'Chiuso'){
                owners.add(t.OwnerId);
                tasksToConsider.add(t);
            }
        }

        System.debug('@@@ owners ' + JSON.serialize(owners));
        System.debug('@@@ tasksToConsider ' + JSON.serialize(tasksToConsider));

        andamentaliTotal = [SELECT Id, Operatore__c, Data__c, CT_Actual__c FROM WGC_Andamentale__c WHERE Operatore__c IN : owners];

        System.debug('@@@ andamentaliTotal ' + JSON.serialize(andamentaliTotal));

        for(WGC_Andamentale__c andamento : andamentaliTotal){
            for(Task t : tasksToConsider){
                //Se l'operatore dell'andamento è uguale all'owner del task && la data di esitazione del task è uguale al record dell'andamentale
                //Allora aggiorno il il valore dei Contatti Telefonici effettuati dall'operatore in tal data
                //In seguito aggiungo i soli record da aggiornare in una lista aggiuntiva
                if(andamento.Operatore__c == t.OwnerId && andamento.Data__c == t.DataOraEsitazione__c.date()){
                    System.debug('@@@ andamento ' + andamento);
                    andamento.CT_Actual__c = andamento.CT_Actual__c != null ? andamento.CT_Actual__c + 1 : 1;

                    andamentaliToUpdate.add(andamento);
                }
            }
        }

        System.debug('@@@ andamentaliTotal ' + JSON.serialize(andamentaliToUpdate));

        List<WGC_Andamentale__c> andamentaliToUpdateLst = new List<WGC_Andamentale__c>(andamentaliToUpdate);

        update andamentaliToUpdateLst;

    }

    //Metodo che aggiorna il campo VC_Actual__c sul record andamentale dell'operatore di Filo Diretto che ha creato la visita commerciale
    public static void update_VC_Actual(List<Event> events){
        System.debug('@@@ events ' + JSON.serialize(events));
        //Set utilizzato per recuperare tutti i record di andamentale che hanno come operatore i creatori degli eventi (In modo da ridurre i risultati sulla query)
        //TODO : Ottimizzare query
        Set<Id> creators = new Set<Id>();
        //Lista utilizzata per filtrare solo i task di Filo Diretto con il particolare RT
        List<Event> eventsToConsider = new List<Event>();
        List<WGC_Andamentale__c> andamentaliTotal = new List<WGC_Andamentale__c>();
        //Lista utilizzata per effettuare update sui record interessati in cambiamenti
        Set<WGC_Andamentale__c> andamentaliToUpdate = new Set<WGC_Andamentale__c>();

        for(Event e : events){
            if(e.CreatoDaFiloDiretto__c && e.RecordTypeDevName__c == 'VisitaCommerciale' && e.WhatId != null){
                creators.add(e.CreatedById);
                eventsToConsider.add(e);
            }
        }

        System.debug('@@@ creators ' + JSON.serialize(creators));
        System.debug('@@@ eventsToConsider ' + JSON.serialize(eventsToConsider));

        andamentaliTotal = [SELECT Id, Operatore__c, Data__c, VC_Actual__c FROM WGC_Andamentale__c WHERE Operatore__c IN : creators];

        System.debug('@@@ andamentaliTotal ' + JSON.serialize(andamentaliTotal));


        for(WGC_Andamentale__c andamento : andamentaliTotal){
            for(Event e : eventsToConsider){
                //Se l'operatore dell'andamento è uguale all'owner del task && la data di esitazione del task è uguale al record dell'andamentale
                //Allora aggiorno il il valore dei Contatti Telefonici effettuati dall'operatore in tal data
                //In seguito aggiungo i soli record da aggiornare in una lista aggiuntiva
                if(andamento.Operatore__c == e.CreatedById && andamento.Data__c == e.CreatedDate.Date()){
                    andamento.VC_Actual__c = andamento.VC_Actual__c != null ? andamento.VC_Actual__c + 1 : 1;

                    andamentaliToUpdate.add(andamento);
                }
            }
        }

        System.debug('@@@ andamentaliToUpdate ' + JSON.serialize(andamentaliToUpdate));

        List<WGC_Andamentale__c> andamentaliToUpdateLst = new List<WGC_Andamentale__c>(andamentaliToUpdate);

        Update andamentaliToUpdateLst;
    }

    public static void updatePrevAvvRapportoDT(Map<Id,Sobject> tasks){

        Map<Id,Task> tasksToConsider = new Map<Id,Task>();
        Set<Id> accountIds = new Set<Id>();
        List<WGC_Dettaglio_Visite__c> dtListUpd = new List<WGC_Dettaglio_Visite__c>();

        System.debug('@@@ tasks ' + JSON.serialize(tasks));

        for(Sobject sobj : tasks.values()){
            if(String.valueOf(sobj.get('RecordTypeDevName__c')) == 'Previsione_Avvio_Rapporto' /*&& String.valueOf(sobj.get('Status')) != 'Chiuso'*/){ 
                tasksToConsider.put((Id)sobj.get('Id'), (Task)sobj);
                accountIds.add((Id)sobj.get('WhatId'));
            }
        }

        System.debug('@@@ accountIds ' + accountIds);

        List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Ragione_Sociale__c, Previsione_Avvio_Rapporto__c, Data_di_Creazione__c FROM WGC_Dettaglio_Visite__c WHERE Ragione_Sociale__c IN : accountIds AND RecordType.DeveloperName = 'Dettaglio_Visita' ORDER BY Data_di_Creazione__c DESC]);

        System.debug('@@@ dtList ' + dtList);

        for(Task t : tasksToConsider.values()){
            for(WGC_Dettaglio_Visite__c dt : dtList){
                if(dt.Ragione_Sociale__c == t.WhatId && !dtListUpd.contains(dt)){
                    System.debug('@@@ task ' + JSON.serialize(t));
                    System.debug('@@@ dettaglio visite ' + JSON.serialize(dt));
                    dt.Previsione_Avvio_Rapporto__c = t.Previsione_avvio_entro__c;
                    dtListUpd.add(dt);
                }
            }
        }

        if(!dtListUpd.isEmpty()) Update dtListUpd;
    }

    public static void updateEsitoVisitaDT(Map<Id,Sobject> events){
        Map<Id,Id> accIdXevId = new Map<Id,Id>();
        List<WGC_Dettaglio_Visite__c> dtListUpd = new List<WGC_Dettaglio_Visite__c>();

        for(Sobject sobj : events.values()){
            if(Boolean.valueOf(sobj.get('CreatoDaFiloDiretto__c')) == true && String.isNotBlank(String.valueOf(sobj.get('EsitoLivello1__c')))) accIdXevId.put((Id)sobj.get('WhatId'),(Id)sobj.get('Id'));
        }

        System.debug('@@@ accIdXevId ' + accIdXevId);

        Map<Id,WGC_Dettaglio_Visite__c> dtMap = new Map<Id,WGC_Dettaglio_Visite__c>([SELECT Id, Name, Ragione_Sociale__c, Esito_Visita__c, Id_Visita__c  FROM WGC_Dettaglio_Visite__c WHERE Id_Visita__c IN: accIdXevId.values() AND Ragione_Sociale__c IN: accIdXevId.keySet() AND RecordType.DeveloperName = 'Dettaglio_Visita']);

        System.debug('@@@ dtMap ' + JSON.serialize(dtMap));

        for(Sobject sobj : events.values()){
            for(WGC_Dettaglio_Visite__c dt : dtMap.values()){
                if(String.valueOf(sobj.get('Id')) == dt.Id_Visita__c && (Id)sobj.get('WhatId') == dt.Ragione_Sociale__c && !dtListUpd.contains(dt)){
                    System.debug('@@@ dt ' + JSON.serialize(dt));
                    if(sobj.get('EsitoLivello1__c') != null && sobj.get('EsitoLivello2__c') != null){
                        dt.Esito_Visita__c = String.valueOf(sobj.get('EsitoLivello1__c')) + ' - ' + String.valueOf(sobj.get('EsitoLivello2__c'));
                    } else if(sobj.get('EsitoLivello1__c') != null){
                        dt.Esito_Visita__c = String.valueOf(sobj.get('EsitoLivello1__c'));
                    }
                    dtListUpd.add(dt);
                }
            }
        }
        
        System.debug('@@@ dtListUpd ' + JSON.serialize(dtListUpd));
        if(!dtListUpd.isEmpty()) Update dtListUpd;
    }

    public static void insertSegnalazioneDT(Map<Id,Sobject> tasks){
        Set<Id> accId = new Set<Id>();
        Map<Id,WGC_Dettaglio_Visite__c> accIdXDT = new Map<Id,WGC_Dettaglio_Visite__c>();
        List<Task> tasksToConsider = new List<Task>();
        List<WGC_Dettaglio_Visite__c> dtListUpd = new List<WGC_Dettaglio_Visite__c>();

        System.debug('@@@ tasks map ' + JSON.serialize(tasks));
        System.debug('@@@ tasks map ' + JSON.serialize(tasks.values()));

        for(Sobject sobj : tasks.values()){
            System.debug('@@@ sobj ' + JSON.serialize(sobj));
            if(String.valueOf(sobj.get('RecordTypeDevName__c')) == 'WGC_Segnalazione' && String.valueOf(sobj.get('Status')) == 'Aperto'){
                accId.add((Id)sobj.get('WhatId'));
                tasksToConsider.add((Task)sobj);
            }
        }

        List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Id_Segnalazione__c, Segnalazione__c, Status_Segnalazione__c, Data_Segnalazione__c, Ragione_Sociale__c, Ragione_Sociale__r.Name, Data_di_Creazione__c FROM WGC_Dettaglio_Visite__c WHERE Ragione_Sociale__c IN: accId AND RecordType.DeveloperName = 'Dettaglio_Visita' ORDER BY Data_di_Creazione__c DESC]);

        for(WGC_Dettaglio_Visite__c dt : dtList){
            for(Sobject sobj : tasks.values()){
                if(sobj.get('WhatId') != null && (Id)sobj.get('WhatId') == dt.Ragione_Sociale__c && !accIdXDT.keySet().contains((Id)sobj.get('WhatId'))){
                    accIdXDT.put((Id)sobj.get('WhatId'), dt);
                }
            }
        }

        for(Task t : tasksToConsider){
            for(WGC_Dettaglio_Visite__c dt : accIdXDT.values()){
                if(t.WhatId == dt.Ragione_Sociale__c && dt.Data_Segnalazione__c == null && !dtListUpd.contains(dt)){
                    dt.Id_Segnalazione__c = t.Id;
                    dt.Data_Segnalazione__c = t.ActivityDate;
                    dt.Data_Esito_Segnalazione__c = String.isNotEmpty(t.WGC_Esito_Segnalazione__c) ? System.Today() : null;
                    dt.Segnalazione__c = t.WGC_Segnalazione__c;
                    dt.Status_Segnalazione__c = t.WGC_Esito_Segnalazione__c;

                    dtListUpd.add(dt);
                }
            }
        }

        if(!dtListUpd.isEmpty()) Update dtListUpd;
    }

    public static void updateSegnalazioneDT(Map<Id,Sobject> tasks){
        Set<Id> taskIds = new Set<Id>();
        List<Task> tasksToConsider = new List<Task>();
        List<WGC_Dettaglio_Visite__c> dtListUpd = new List<WGC_Dettaglio_Visite__c>();

        for(Sobject sobj : tasks.values()){
            if(String.valueOf(sobj.get('RecordTypeDevName__c')) == 'WGC_Segnalazione' && String.valueOf(sobj.get('Status')) == 'Chiuso'){
                tasksToConsider.add((Task)sobj);
                taskIds.add((Id)sobj.get('Id'));
            }
        }

        List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Id_Segnalazione__c, Segnalazione__c, Status_Segnalazione__c, Data_Segnalazione__c, Ragione_Sociale__c, Ragione_Sociale__r.Name, Data_di_Creazione__c FROM WGC_Dettaglio_Visite__c WHERE Id_Segnalazione__c IN: taskIds AND RecordType.DeveloperName = 'Dettaglio_Visita' ORDER BY Data_di_Creazione__c DESC]);

        for(Task t : tasksToConsider){
            for(WGC_Dettaglio_Visite__c dt : dtList){
                if(t.WhatId == dt.Ragione_Sociale__c && dt.Id_Segnalazione__c == t.Id && !dtListUpd.contains(dt)){
                    // dt.Status_Segnalazione__c = t.EsitoLivello1__c;
                    dt.Data_Segnalazione__c = t.ActivityDate;
                    dt.Data_Esito_Segnalazione__c = String.isNotEmpty(t.WGC_Esito_Segnalazione__c) ? System.Today() : null;
                    dt.Segnalazione__c = t.WGC_Segnalazione__c;
                    dt.Status_Segnalazione__c = t.WGC_Esito_Segnalazione__c;


                    dtListUpd.add(dt);
                }
            }
        }

        if(!dtListUpd.isEmpty()) Update dtListUpd;
    }

    public static void popolaCampiSegnalazione(List<Task> tasks){
        // List<Task> toUpd = new List<Task>();
        Set<Id> accIds = new Set<Id>();

        for(Task sobj : tasks){
            if(sobj.WhatId != null){
                accIds.add(sobj.WhatId);
            }
        }

        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Name, CF__c, PIVA__c, WGC_Numero_telefono_cellulare__c, Email__c, NDGGruppo__c, Phone FROM Account WHERE Id IN: accIds]);

        for(Task sobj : tasks){
            if(sobj.RecordTypeDevName__c == 'WGC_Segnalazione'){
                for(Account a : accountMap.values()){
                    if(sobj.WhatId != null && a.Id == sobj.WhatId){
                        sobj.WGC_Ragione_Sociale__c = a.Name ;
                        sobj.WGC_CF_PIVA__c = a.CF__c;
                        sobj.WGC_PIVA_Azienda__c = a.PIVA__c;
                        sobj.WGC_NDG_Azienda__c = a.NDGGruppo__c;
                        sobj.WGC_Contatto_telefonico_Azienda__c = a.Phone;
                        sobj.WGC_Email_Azienda__c = a.Email__c;

                        // toUpd.add(sobj);
                    }
                }
            }
        }

        // if(!toUpd.isEmpty()) Update toUpd;
    }
}