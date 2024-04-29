/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 10-14-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/
public class WGC_FiloDirettoController {
	
    //Metodo per recuperare tutti i task di filo diretto che vengono mostrati nella tabella
    @AuraEnabled
    public static WrapperResponse getTasks(Integer numPage, Integer limite){
        WrapperResponse wrap = new WrapperResponse();

        Integer off = numPage * limite;

        List<Task> lstT = new List<Task>();
        lstT = [SELECT Id, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId 
                FROM Task 
                WHERE Status='Aperto' AND DiFiloDiretto__c = true 
                AND ( RecordType.DeveloperName = 'ContattoTelefonicoDiretto' OR RecordType.DeveloperName = 'ContattoTelefonicoIndiretto' ) AND WhatId != null ORDER BY ActivityDate ASC LIMIT : limite OFFSET : off];

        Container cont = new Container(lstT, lstT.size());

        if(!lstT.isEmpty()){
            wrap.data.add(cont);
            wrap.message = 'OK';

            return wrap; 
        }
        else{
            wrap.message = 'Nessun task';
            return wrap;
        }
    }

    @AuraEnabled
    public static WrapperResponse getTasks(){
        WrapperResponse wrap = new WrapperResponse();

        List<Task> lstT = new List<Task>();
        lstT = [SELECT Id, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId 
                FROM Task 
                WHERE Status='Aperto' AND DiFiloDiretto__c = true 
                AND (RecordType.DeveloperName = 'ContattoTelefonicoDiretto' OR RecordType.DeveloperName = 'ContattoTelefonicoIndiretto')];

        Container cont = new Container(lstT, lstT.size());

        if(!lstT.isEmpty()){
            wrap.data.add(cont);
            wrap.message = 'OK';

            return wrap; 
        }
        else{
            wrap.message = 'Nessun task';
            return wrap;
        }
    }

    @AuraEnabled
    public static Task getTaskData(String taskId){
        List<Task> listTask = new List<Task>();
        listTask = [SELECT Id, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId, Description, WGC_Sviluppo_in_corso__c
                    FROM Task 
                    WHERE Id =: taskId LIMIT 1];

        if(!listTask.isEmpty()){
            return listTask[0];
        }
        else{
            return null;
        }

    }

    //Metodo per generare un task a partire da "Nuova Chiamata Inbound"
    @AuraEnabled
    public static Task generaTaskInbound(String idContatto){
        System.debug('@@@ idContatto ' + idContatto);

        Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :idContatto];

        System.debug('@@@ UserId ' + UserInfo.getUserId());

        List<RecordType> recordTypes = new List<RecordType>();
        Set<Id> recordTypeIds = new Set<Id>();
        
        recordTypes = [SELECT Id FROM RecordType WHERE DeveloperName IN ('WGC_Diario_Inserimento_Campagna', 'WGC_Diario_Modifica_Qualifica', 'WGC_Diario_Modifica_Rating', 'WGC_Diario_Nuova_Opportunita', 'Promemoria', 'Previsione_Avvio_Rapporto', 'WGC_Segnalazione', 'ContattoTelefonicoIndiretto') AND SObjectType = 'Task'];
        System.debug('@@@ recordTypes '+recordTypes);
        for(RecordType rt : recordTypes) {
            recordTypeIds.add(rt.Id);
        }

        //System.debug('@@@ recordTypeIds '+recordType);

        List<Task> taskAperti = [SELECT Id, WhatId FROM Task WHERE EsitoLivello1__c = null AND WhatId =: c.AccountId AND RecordTypeId NOT IN : recordTypeIds ];
        System.debug('@@@ taskAperti ' + JSON.serialize(taskAperti));

        if(!taskAperti.isEmpty()){
            return null;
        }

        Task t = new Task(
            WhoId = c.Id,
            WhatId = c.AccountId,
            OwnerId = UserInfo.getUserId(),
            Status = 'Aperto',
            Subject = 'Contatto Telefonico',
            ActivityDate = Date.today(),
            RecordTypeId = U.getRecordTypes('Task').get('ContattoTelefonicoDiretto').Id,
            Campagna__c = null
        );

        List<Task> checkTask = [SELECT Id, TipoAttivita__c FROM Task WHERE OwnerId =: UserInfo.getUserId() AND WhatId =: c.AccountId AND WhoId =: c.Id ORDER BY CreatedDate DESC];

        System.debug('@@@ checkTask ' + checkTask);

        try {
            insert t;
            System.debug('@@@ task creato ' + t);
            return t;
        }
        catch(FinalException e){
            throw new FinalException('FINAL ' + e.getMessage());
        }
        catch(Exception e) {
            System.debug('@@@ eccezione ' +  e.getMessage() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getCause());
            throw new Ex.WSException('Errore inserimento task: ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getCause());
        }
    }

    @AuraEnabled
    public static WrapperResponse updateTaskCampaign(String strTaskToUpdate){
        System.debug('@@@ strTaskToUpdate ' + strTaskToUpdate);

        WrapperResponse response = new WrapperResponse();

        try{

            Task taskToUpdate = (Task) JSON.deserialize(strTaskToUpdate, Task.Class);
            // taskToUpdate.Campagna__c = null;
            System.debug('@@@ taskToUpdate ' + taskToUpdate);
            update taskToUpdate;

            response.message = 'Campagna aggiornata sul task corrente';
            return response;
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;

            return response;
        }
    }

    //Metodo per recuperare tutte le campagne attive che verranno mostrate nella picklist come possibile filtro
    // @AuraEnabled
    // public static List<Campaign> getCampaign(Integer numPage, Integer limite){
        
    //     Integer off = numPage * limite;

    //     Set<Id> idCampagneXTask = new Set<Id>();

    //     List<Task> listaGetTask = new List<Task>();
    //     listaGetTask = [SELECT Id, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId 
    //                     FROM Task 
    //                     WHERE Status='Aperto' AND DiFiloDiretto__c = true AND RecordType.DeveloperName = 'ContattoTelefonicoDiretto' AND WhatId != null];

    //     for(Task t : listaGetTask){
    //         idCampagneXTask.add(t.Campagna__c);
    //     }

    //     System.debug('@@@ idCampagneXTask ' + idCampagneXTask);

    //     List<Campaign> lstC = new List<Campaign>();
    //     //Status = 'In Progress' AND
    //     lstC = [SELECT Id, Name FROM Campaign WHERE IsActive = true AND Id IN: idCampagneXTask ORDER BY Name ASC];

    //     if(!lstC.isEmpty()){
    //         return lstC;
    //     }
    //     else{
    //         return null;
    //     }
    // }

    //Metodo per recuperare tutte le campagne attive che verranno mostrate nella picklist come possibile filtro
    @AuraEnabled
    public static List<Campaign> getCampaign(){

        //WrapperResponse tasks = new WrapperResponse();
        //tasks = getTasks();

        Set<Id> idCampagneXTask = new Set<Id>();

        //List<Task> listaGetTask = new List<Task>();

        //String tmp = JSON.serialize(tasks.data);

        //listaGetTask = (List<Task>)JSON.deserialize(tmp, List<Task>.Class);

        List<Task> listaGetTask = new List<Task>();
        listaGetTask = [SELECT Id, Subject, Campagna__r.Name, Owner.Name, What.Id, What.Name, WhoId, ActivityDate, DataRicontatto__c, Status, RecordTypeId FROM Task WHERE Status='Aperto' AND DiFiloDiretto__c = true AND RecordType.DeveloperName = 'ContattoTelefonicoDiretto' AND WhatId != null];

        for(Task t : listaGetTask){
            idCampagneXTask.add(t.Campagna__c);
        }

        System.debug('@@@ idCampagneXTask ' + idCampagneXTask);

        List<Campaign> lstC = new List<Campaign>();
        //Status = 'In Progress' AND
        lstC = [SELECT Id, Name FROM Campaign WHERE IsActive = true AND Id IN: idCampagneXTask ORDER BY Name ASC];

        if(!lstC.isEmpty()){
            return lstC;
        }
        else{
            return null;
        }
    }

    //Metodo per recuperare le info del contatto legato al task
    @AuraEnabled
    public static Contact getContactInformation(String taskId){
        System.debug('@@@ taskId ' + taskId);

        //recupero il task con l'id preso come parametro
        Task parentTask = [SELECT Id, Subject, WhoId, OwnerId FROM Task WHERE Id =: taskId];

        System.debug('@@@ parent Task ' + parentTask);

        //recupero le info del contatto
        List<Contact> lstC = new List<Contact>();
        lstC = [SELECT Id,FirstName,LastName,Email,Phone,OtherPhone,Ruolo__c,Account.Id,Account.Name,Account.Fatturato__c,Account.BillingStreet,
                    Account.BillingCity,Account.BillingPostalCode,Account.BillingCountry,Account.BillingState,Account.PIVA__c  FROM Contact WHERE Id =: parentTask.WhoId LIMIT 1];

        System.debug('@@@ lista di contatti ' + lstC);
        if(!lstC.isEmpty()){
            return lstC.get(0);
        }
        else{
            return null;
        }
        
    }

    //Metodo che richiama le REST API per recuperare tutte le informazioni dell'oggetto task in base al record type
    @AuraEnabled
    public static String getPicklistValues(String rtId){
        //Named Credential 1
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setEndpoint('callout:TestNamedCredential/services/data/v44.0/sobjects/Task/describe/layouts/'+rtId+'?format=json');
        resp = h.send(req);
        System.debug('@@@@ response ' + resp.getBody());
        String responseValue = resp.getBody();

        return responseValue;
    }

    // UTILITY - METHOD TO GET OBJECT FIELDS' LABELS
    @AuraEnabled
    public static Map<String, String> getObjectLabels(String objectName){
        return WizardOpportunityController.getObjectLabels(objectName);
    }

    //Metodo per recuperare i possibili assegnatari in base al Comune selezionato
    @AuraEnabled
    public static Map<String,User[]> getAssegnatari(String accountId, String comuneId){
        System.debug('@@@ accountId ' + accountId);
        Map<String,User[]> owners = new Map<String,User[]>();
        if(String.isBlank(comuneId)) return owners;
        // titolare dell'account
        Account a = new Account();
        a = [SELECT
            WGC_Specialista_Factoring__c,
            WGC_Specialista_Factoring__r.FirstName,
            WGC_Specialista_Factoring__r.LastName,
            OwnerId,
            Owner.FirstName,
            Owner.LastName,
            RecordTypeId,
            ShippingPostalCode FROM Account WHERE Id = :accountId
        ];
        if(a != null){
            owners.put('Titolari', new List<User>{a.WGC_Specialista_Factoring__r});
        }
        

        // assegnazione territoriale in base al CAP

        List<AssegnazioneAnagrafica__c> assegnazioni = [SELECT
        Utente__c,
        Utente__r.FirstName,
        Utente__r.LastName,
        CAP__c
        FROM AssegnazioneAnagrafica__c
        WHERE Comune__c = :comuneId
        AND FiloDiretto__c = false
        AND WGC_Crediti_Erariali__c = false
        ];

        Set<User> atSet = new Set<User>();
        for(AssegnazioneAnagrafica__c aa : assegnazioni) {
        atSet.add(aa.Utente__r);
        }
        List<User> atList = new List<User>();
        atList.addAll(atSet);
        if(atList.size() > 0) owners.put('Assegnazione territoriale', atList);


        return owners;
    }

    //Metodo per recuperare il calendario visite in base agli utenti
    @AuraEnabled
    public static List<Event> getVisite(DateTime EndDate, String utenti){
        
        List<User> uList = new List<User>();
        uList = (List<User>) JSON.deserialize(utenti, List<User>.class);

        Map<Id, User> mapU = new Map<Id, User>(uList);
        //Conversione datetime to date
        Date myDate = date.newinstance(EndDate.year(), EndDate.month(), EndDate.day());

        //Date ddate = Date.parse(dateString);
        Datetime d = Datetime.newInstance(myDate, Time.newInstance(0, 0, 0, 0));

        Datetime d1 = d.addDays(1);
        
        List<Event> eventList = [SELECT Id, Subject, Location, StartDateTime, EndDateTime FROM Event WHERE Owner.Id =: mapU.keySet() AND ((EndDateTime < :d1 AND EndDateTime > :d) OR (StartDateTime > :d AND StartDateTime < :d1))];

        System.debug('@@@ eventList ' + eventList);
        return eventList;
    }

    //Metodo per salvare il task esitato
    @AuraEnabled
    public static WrapperResponse saveTask(Task objTask){

        WrapperResponse wrap = new WrapperResponse();
        
        System.debug('@@@ objTask ' + JSON.serialize(objTask) );

        try {
            /*
            String str = JSON.serialize(objTask);
            System.debug('@@@ strT ' + str);
            Task t = new Task();
            t = (Task) JSON.deserialize(str, Task.Class);
            System.debug('@@@ t ' + JSON.serialize(t));
			*/
            // setto il boolean sul trigger in modo che non giri la validazione per l'obbligo della data ricontatto
            TrgActivity.disabilitaCheckDataRicontatto = true;
            TrgActivity.disabilitaCheckVisita = true;
            // chiudo il task
            
            Task t = objTask;
            t.Status = 'Chiuso';
            //t.Data_Inizio__c = t.CreatedDate;
            //t.Data_Fine__c = System.Now();

            if (t.GiaCliente__c) t.EsitoLivello1__c = 'Cliente già sviluppato';

            if (t.WGC_Sviluppo_in_corso__c) {
                t.EsitoLivello1__c = 'Utente in corso di sviluppo';
            }

            update t;

            //CR - LOTTO 3.1 -- se sto esitando un task di un collega, io divento in automatico specialista filo diretto dell'anagrafica associata al task
            try{
                Account accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c FROM Account WHERE Id =: t.WhatId ];
                System.debug('@@@ test account ' + JSON.serialize(accAssociato));

                // Account accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c FROM Account WHERE Id =: t.WhatId AND WGC_Specialista_Filo_Diretto__c !=: UserInfo.getUserId()];
                // System.debug('@@@ accAssociato ' + JSON.serialize(accAssociato));

                if(accAssociato.WGC_Specialista_Filo_Diretto__c != UserInfo.getUserId()){
                    accAssociato.WGC_Specialista_Filo_Diretto__c = UserInfo.getUserId();
                    accAssociato.WGC_Factoring_Attivo__c = true;

                    //CR Lotto 4.1 336 e -- commentato per permettere l'abilitazione del referente all'esitazione del task
                    //if(t.EsitoLivello1__c == 'Fissata Visita'){
                        //accAssociato.WGC_Filo_Diretto_Attivo__c = true;
                    //}
                }

                //CR Lotto 4.1 336 e -- commentato per permettere l'abilitazione del referente all'esitazione del task
                if(accAssociato.WGC_Specialista_Filo_Diretto__c != null && accAssociato.WGC_Filo_Diretto_Attivo__c == false){
                    accAssociato.WGC_Filo_Diretto_Attivo__c = true;
                }

                if(t.GiaCliente__c){
                    accAssociato.WGC_Filo_Diretto_Attivo__c = false;
                }

                //Aggiorno l'anagrafica
                update accAssociato;

                
                Funzionalita__c f = Funzionalita__c.getInstance();
                f.DisabilitaTriggerActivities__c = true;

            }
            catch(QueryException e){
                System.debug('@@@ nessuna anagrafica trovata, non aggiorno referente ' + e.getMessage() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString());
            }

            wrap.message = 'OK';
            return wrap;

        } 
        catch(Exception e) {
            wrap.message = e.getMessage();
            wrap.success = false;

            return wrap;
        }

        //return 'ok';
    }

    //Metodo per salvare la visita commerciale (Evento)
    @AuraEnabled
    public static WrapperResponse saveVisita(String visitaObj, Task taskAssociato){
        System.debug('@@@ esita visita commerciale ' + visitaObj);
        System.debug('@@@ taskAssociato ' + taskAssociato);

        WrapperResponse wrap = new WrapperResponse();
        
        try{
            Event e = new Event();
            e = (Event) JSON.deserialize(visitaObj, Event.Class);
            e.Data_Inizio__c = e.StartDateTime;
            e.Data_Fine__c = e.EndDateTime;

            System.debug('@@@ event ' + e);

			// INTEGRAZIONE DEI CAMPI DI FORM PER EVENTUALE USO SUCCESSIVO

			Task actualTask = [SELECT id, IFISForm__c, BI_IFISFormPriority__c from Task where id = :taskAssociato.Id];

            System.debug('@@@ actualTask ' + actualTask);

			e.IFISForm__c = actualTask.IFISForm__c;
			e.BI_IFISFormPriority__c = actualTask.BI_IFISFormPriority__c;

            //e.Campagna__c = Impostazioni__c.getInstance().IdCampagnaWeb__c;

            //CR - LOTTO 3.1 -- Se l'assegnatario della visita commerciale non è specialista dell'anagrafica, lo setto in automatico come specialista dell'anagrafica
            WGC_FiloDirettoController.updateSpecialistiVisitaComm(e);

            Insert e;

            //Metodo per creare il record di dettaglio visite
            WGC_FiloDirettoController.creaDettaglioVisite(e, taskAssociato);
            
            inviaMail(e);

            wrap.data.add(e);
            wrap.message = 'OK';
            
            return wrap;
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;

            return wrap;
        }

        //return 'ok';
      
    }

    @AuraEnabled 
    public static void creaDettaglioVisite(Event ev, Task t){

        System.debug('@@@ task t ' + JSON.serialize(t));
        System.debug('@@@ event e ' + JSON.serialize(ev));

        try{
            // Account anagrafica = [SELECT Id, Name, Qualifica_Corporate__c FROM Account WHERE Id =: ev.WhatId];
            WGC_Dettaglio_Visite__c newDt;
            List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Ragione_Sociale__c, Ragione_Sociale__r.WGC_Qualifica_Corporate__c, Ragione_Sociale__r.WGC_Qualifica_Corporate_FD__c, Ragione_Sociale__r.WGC_Giorni_Ex_cliente_SvilCommFiliali__c, Primo_Prodotto__c, Data_di_Creazione__c FROM WGC_Dettaglio_Visite__c WHERE Ragione_Sociale__c =: ev.WhatId AND RecordType.DeveloperName = 'Dettaglio_Visita' ORDER BY Data_di_Creazione__c DESC]);

            String nomeCampagna = t.Campagna__c != null ? [SELECT Name FROM Campaign WHERE Id =: t.Campagna__c ].Name : '';

            Account a = [SELECT Name, WGC_Qualifica_Corporate__c, WGC_Iniziativa__c, WGC_Esiste_Record_DV__c, WGC_Qualifica_Corporate_FD__c FROM Account WHERE Id =: ev.WhatId ];

            String rtId = [SELECT Id, DeveloperName FROM RecordType WHERE  SobjectType = 'WGC_Dettaglio_Visite__c' AND DeveloperName = 'Dettaglio_Visita' LIMIT 1 ].Id;

            if(!dtList.isEmpty()){
                System.debug('@@@ dtList[0] ' + JSON.serialize(dtList[0]));
                if(((dtList[0].Ragione_Sociale__r.WGC_Qualifica_Corporate__c == 'Prospect') || (dtList[0].Ragione_Sociale__r.WGC_Qualifica_Corporate__c == 'Ex Cliente' && dtList[0].Ragione_Sociale__r.WGC_Giorni_Ex_cliente_SvilCommFiliali__c > 730)) && String.isNotBlank(dtList[0].Primo_Prodotto__c)){
                    newDt = new WGC_Dettaglio_Visite__c(Ragione_Sociale__c=ev.WhatId, Data_Contatto_Telefonico__c = Date.today(), Data_Visita_Commerciale__c=ev.StartDateTime.Date(), Operatore_Filo_Diretto__c=t.OwnerId, Settorista__c=ev.OwnerId, Campagna_Aggiornata__c=nomeCampagna, Id_Visita__c=ev.Id, Qualifica_Corporate__c=a.WGC_Qualifica_Corporate_FD__c, Iniziativa__c=a.WGC_Iniziativa__c, RecordTypeId = rtId);
                    Insert newDt;

                    a.WGC_Esiste_Record_DV__c = true;
                    Update a;
                }
            } else {
                newDt = new WGC_Dettaglio_Visite__c(Ragione_Sociale__c=ev.WhatId, Data_Contatto_Telefonico__c = Date.today(), Data_Visita_Commerciale__c=ev.StartDateTime.Date(), Operatore_Filo_Diretto__c=t.OwnerId, Settorista__c=ev.OwnerId, Campagna_Aggiornata__c=nomeCampagna, Id_Visita__c=ev.Id, Qualifica_Corporate__c=a.WGC_Qualifica_Corporate_FD__c, Iniziativa__c=a.WGC_Iniziativa__c, RecordTypeId = rtId);
                Insert newDt;

                System.debug('@@@ newDt ' + newDt);

                a.WGC_Esiste_Record_DV__c = true;
                Update a;
            }

            System.debug('@@@ dettaglio visite ' + JSON.serialize(newDt));

        } catch(exception e){
            System.debug('@@@ errore ' + e.getMessage() + ' -- ' + e.getLineNumber());
        }
    }
    
    @TestVisible
    private static void inviaMail(Event e) {

        User u = [SELECT Id, Name, Email, ManagerId, Manager.Email FROM User WHERE Id = :e.OwnerId];
        List<String> to = new String[]{};
        to.add(u.Email);

        // se è solo un commerciale (e non un responsabile, metto in cc il suo manager)
        List<String> cc = new String[]{};
        if(CU.isCommerciale(u.Id) && !CU.isResponsabileFiliale(u.Id) && String.isNotBlank(u.Manager.Email)) {
        cc.add(u.Manager.Email);
        }
		
		if(String.isNotBlank(Impostazioni__c.getInstance().MailFiloDiretto__c)) {
		cc.add(Impostazioni__c.getInstance().MailFiloDiretto__c);
		}
		
        //Persone in ccn
        List<String> ccn = new String[]{};
        if(String.isNotBlank(Impostazioni__c.getInstance().MailCCNFiloDiretto__c)) {
        ccn.add(Impostazioni__c.getInstance().MailCCNFiloDiretto__c);
        }

        Map<String,String> sostituzioni = new Map<String,String>();
        Event ev = [SELECT CreatedBy.Name, What.Name, Account.NDGGruppo__c, ActivityDate, Location, Description FROM Event WHERE Id = :e.Id];
        sostituzioni.put('$$CREATEDBY$$', ev.CreatedBy.Name);
        sostituzioni.put('$$WHAT$$', ev.What.Name);
        sostituzioni.put('$$ACTIVITYDATE$$', ev.ActivityDate.format());
        sostituzioni.put('$$LOCATION$$', ev.Location);
        sostituzioni.put('$$DESCRIPTION$$', ev.Description);
        sostituzioni.put('$$USERNAME$$', u.Name);
		sostituzioni.put('$$NDG$$', ev.Account.NDGGruppo__c);

		System.debug('Invio mail prima parte');
        MailUtils.inviaMailApexHTML('MailNotificaVisitaCommerciale', ' VISITA COMMERCIALE PIANIFICATA DA FILO DIRETTO', to, cc, ccn, sostituzioni);
    }

    @AuraEnabled
    public static Integer numeroTaskFD(Boolean OwnerFilter, Boolean OverdueFilter, String CampaignFilter, String TextFilter, String TabFilter){
        List<Task> tasks = new List<Task>();

        String txtF = '%'+TextFilter+'%';
        String txtCampaign = String.isBlank(CampaignFilter) ? null : '%'+CampaignFilter+'%';

        
        String subjectToSearch = TabFilter.contains('CT') ? 'Contatto Telefonico%' : TabFilter.contains('RT') ? 'Ricontatto Telefonico%' : '';
        Boolean overdue = TabFilter.contains('Oggi') ? false : TabFilter.contains('Scaduti') ? true : (TabFilter.contains('All') && !OverdueFilter) ? false : true;

        String soql = QueryBuilder.newInstance('Task', new String[]{
                'Id', 
                'Subject', 
                'Campagna__r.Name', 
                'Owner.Name', 
                'What.Id', 
                'What.Name', 
                'WhoId', 
                'ActivityDate', 
                'DataRicontatto__c', 
                'Status', 
                'RecordTypeId'
            }).beginFilter()
                .add('Status', QBOp.QEQUAL, 'Aperto')
                .add('DiFiloDiretto__c', QBOp.QEQUAL, true)
                .beginOr()
                .add('RecordType.DeveloperName', QBOp.QEQUAL, 'ContattoTelefonicoDiretto')
                .add('RecordType.DeveloperName', QBOp.QEQUAL, 'ContattoTelefonicoIndiretto')
                .end()
                .add('WhatId', QBOp.QNOT_EQUAL, null, true)
                .add('Campagna__r.Name', QBOp.QLIKE, txtCampaign, txtCampaign != null)
                .add('OwnerId', QBOp.QEQUAL, UserInfo.getUserId(), OwnerFilter)
                .add('ActivityDate', !overdue && TabFilter.contains('Oggi') ? QBOp.QEQUAL : overdue && TabFilter.contains('Scaduti') ? QBOp.QLT : TabFilter.contains('All') && OverdueFilter ? QBOp.QGTE : QBOp.QEQUAL, System.Today(), (TabFilter.contains('All') && OverdueFilter || !overdue && TabFilter.contains('Oggi') || overdue && TabFilter.contains('Scaduti')) )
                .add('Subject', QBOp.QLIKE, subjectToSearch, String.isNotBlank(subjectToSearch))
                .beginOr()
                    .add('Subject', QBOp.QLIKE, txtF, !String.isBlank(TextFilter))
                    .add('What.Name', QBOp.QLIKE, txtF, !String.isBlank(TextFilter))
                    .add('Owner.Name', QBOp.QLIKE, txtF, !String.isBlank(TextFilter))
                .end()
            .endFilter()
            .orderBy(new String[]{'ActivityDate ASC'})
            .getQuery();

            System.debug('@@@ soql ' + soql);

            tasks = Database.query(soql);

            return tasks.size();
    }

    @AuraEnabled
    public static WrapperResponse filterTask(Boolean OwnerFilter, Boolean OverdueFilter, String CampaignFilter, String TextFilter, String TabFilter, Integer numPage, Integer limite){
        WrapperResponse response = new WrapperResponse();
        List<Task> tasks = new List<Task>();

        System.debug('@@@ OwnerFilter ' + OwnerFilter);
        // System.debug('@@@ OverdueFilter ' + OverdueFilter);
        System.debug('@@@ CampaignFilter ' + CampaignFilter);
        System.debug('@@@ TextFilter ' + TextFilter);
        System.debug('@@@ TabFilter ' + TabFilter);

        String txtF = '%'+TextFilter+'%';
        String txtCampaign = String.isBlank(CampaignFilter) ? null : '%'+CampaignFilter+'%';
        //Controllo sull'ownership
        //String uId = OwnerFilter ? UserInfo.getUserId() : null;

        String subjectToSearch = TabFilter.contains('CT') ? 'Contatto Telefonico%' : TabFilter.contains('RT') ? 'Ricontatto Telefonico%' : '';
        Boolean overdue = TabFilter.contains('Oggi') ? false : TabFilter.contains('Scaduti') ? true : (TabFilter.contains('All') && !OverdueFilter) ? false : true;

        Integer off = numPage * limite;

        try{
            String soql = QueryBuilder.newInstance('Task', new String[]{
                'Id', 
                'Subject', 
                'Campagna__r.Name', 
				'Originator_di_dettaglio__c',
                'Owner.Name', 
                'What.Id', 
                'What.Name', 
                'WhoId', 
                'ActivityDate', 
                'DataRicontatto__c', 
                'Status', 
                'RecordTypeId'
            }).beginFilter()
                .add('Status', QBOp.QEQUAL, 'Aperto')
                .add('DiFiloDiretto__c', QBOp.QEQUAL, true)
                .beginOr()
                .add('RecordType.DeveloperName', QBOp.QEQUAL, 'ContattoTelefonicoDiretto')
                .add('RecordType.DeveloperName', QBOp.QEQUAL, 'ContattoTelefonicoIndiretto')
                .end()
                .add('WhatId', QBOp.QNOT_EQUAL, null, true)
                .add('Campagna__r.Name', QBOp.QLIKE, txtCampaign, txtCampaign != null)
                .add('OwnerId', QBOp.QEQUAL, UserInfo.getUserId(), OwnerFilter)
                .add('ActivityDate', !overdue && TabFilter.contains('Oggi') ? QBOp.QEQUAL : overdue && TabFilter.contains('Scaduti') ? QBOp.QLT : TabFilter.contains('All') && OverdueFilter ? QBOp.QGTE : QBOp.QEQUAL, System.today(), (TabFilter.contains('All') && OverdueFilter || !overdue && TabFilter.contains('Oggi') || overdue && TabFilter.contains('Scaduti')))
                .add('Subject', QBOp.QLIKE, subjectToSearch, String.isNotBlank(subjectToSearch))
                .beginOr()
                    .add('Subject', QBOp.QLIKE, txtF, !String.isBlank(TextFilter))
                    .add('What.Name', QBOp.QLIKE, txtF, !String.isBlank(TextFilter))
                    .add('Owner.Name', QBOp.QLIKE, txtF, !String.isBlank(TextFilter))
                .end()
            .endFilter()
            .orderBy(new String[]{'ActivityDate ASC'})
            .setLimit(limite)
            .getQuery();

            System.debug(soql);

            soql = soql + ' OFFSET '+ off;

            System.debug('@@@ soql ' + soql);
            System.debug('@@@ today ' + System.today() );

            tasks = Database.query(soql);
            System.debug(tasks);


            Container cont = new Container(tasks, tasks.size());
            response.data.add(cont);
            //}
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @TestVisible
    private static string updateSpecialistiVisitaComm(Event e){
        
        try{
            User commerciale = [SELECT Id, Name, Qualifica_Utente__c FROM User WHERE Id =: e.OwnerId ];
            Account accAssociato;

            switch on commerciale.Qualifica_Utente__c {
                when 'Sviluppo_Commerciale_Filiali' {
                    //FACTORY SV -- Aggiunta campo Specialista_assegnato_FD__c in query
                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Factoring__c, WGC_Presentatore_non_modificabile__c, Specialista_assegnato_FD__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_Factoring__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_Factoring__c = e.OwnerId;
                    accAssociato.WGC_Factoring_Attivo__c = true;
                    //FACTORY SV -- Aggiunta valorizzazione campo Specialista_assegnato_FD__c con data odierna
                    accAssociato.Specialista_assegnato_FD__c = Date.today();

                    if(!accAssociato.WGC_Presentatore_non_modificabile__c){
                        accAssociato.Presentatore__c = e.OwnerId;
                    }
                }

                when 'Crediti Erariali' {
                    
                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Crediti_Erariali__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_Crediti_Erariali__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_Crediti_Erariali__c = e.OwnerId;
                }

                when 'Leasing EF' {

                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Leasing__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_Leasing__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_Leasing__c = e.OwnerId;
                }

                when 'Leasing TR' {

                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Leasing_TR__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_Leasing_TR__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_Leasing_TR__c = e.OwnerId;
                }

                when 'IFIS_International' {

                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_IFIS_International__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_IFIS_International__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_IFIS_International__c = e.OwnerId;
                }

                when 'Finanza Strutturata' {

                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_Finanza_Strutturata__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_Finanza_Strutturata__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_Finanza_Strutturata__c = e.OwnerId;
                }

                when 'IFIS Finance' {

                    accAssociato = [SELECT Id, Name, OwnerId, WGC_Specialista_IFIS_Finance__c FROM Account WHERE Id =: e.WhatId AND WGC_Specialista_IFIS_Finance__c !=: e.OwnerId  ];
                    accAssociato.WGC_Specialista_IFIS_Finance__c = e.OwnerId;
                }
                
            }

            System.debug('@@@ accAssociato ' + JSON.serialize(accAssociato));

            // Aggiorno l'anagrafica
            if(accAssociato != null){
            	update accAssociato;
            }

            return 'account aggiornato';
        }
        catch(QueryException ex){
            System.debug('@@@ nessuna anagrafica trovata, non aggiorno referente ' + ex.getMessage() + ' -- ' + ex.getLineNumber() + ' -- ' + ex.getStackTraceString());
            return 'nessuna anagrafica trovata, non aggiorno referente ' + ex.getMessage() + ' -- ' + ex.getLineNumber() + ' -- ' + ex.getStackTraceString();
        }
    }

    public class Container{
        @AuraEnabled
        public List<Task> lista;
        @AuraEnabled
        public Integer conteggio;

        public Container(List<Task> tasks, Integer conteggio){
            this.lista = tasks;
            this.conteggio = conteggio;
        }
    }

    public class WrapperResponse{
        @AuraEnabled
        public List<Object> data;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }
}