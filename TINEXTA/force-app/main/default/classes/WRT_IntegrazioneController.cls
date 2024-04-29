public class WRT_IntegrazioneController {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @future (callout = true)
    public static void opportunityIntegration(Set<String> objIdList){

        Boolean disabilitaIntegrazione = Funzionalita__c.getInstance().Disabilita_Integrazione__c;
        if(disabilitaIntegrazione){
            System.debug('SV DISABILITA INTEGRAZIONE TRUE');
            return;
        }

        User currUser = [ SELECT Id, Societa__c, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId() ];

        List<Log__c> logList = new List<Log__c>();
        List<Opportunity> oppList = [SELECT Id, Name, Numero_offerta_Infostore__c, Documenti_oppotunita_warranthub__c FROM Opportunity WHERE id IN: objIdList];

        if(oppList[0].Documenti_oppotunita_warranthub__c == null){
            logList.add(opportunityIntegration_SharePoint(oppList));            
        }

        String idNotAuthorizzed = EndpointServizi__c.getInstance().WRN_Id_IntegrazioneInfoStore__c;
        if(currUser.Id != idNotAuthorizzed){
            logList.add(opportunityIntegration_InfoStore(oppList));
        } else {
            System.debug('SV NON ESEGUO LA CHIAMATA UTENTE NON AUTORIZZATO');
        }

        if(logList.size() > 0){
            insert logList;
            Boolean success = true;
            for(Log__c l : logList){
                if(!l.Success__c) success = false;
            }
            if(success) update oppList;
        }
    }

    @future (callout = true)
    public static Void accountIntegration(List<Id> objIdList){

        Boolean disabilitaIntegrazione = Funzionalita__c.getInstance().Disabilita_Integrazione__c;
        if(disabilitaIntegrazione){
            System.debug('SV DISABILITA INTEGRAZIONE TRUE');
            return;
        }

        List<Log__c> logList = new List<Log__c>();
        List<Account> accList = [SELECT Id, Name, Codice_Unico_Tinexta__c, link_warrant__c, WRT_Codice_SharePoint__c FROM Account WHERE id IN: objIdList];
        System.debug('SV link_warrant__c: ' + accList[0].link_warrant__c);

        if(accList[0].link_warrant__c == null){
            logList.add(accountIntegration_SharePoint(accList));
        }

        if(logList.size() > 0){
            insert logList;
            Boolean success = true;
            for(Log__c l : logList){
                if(!l.Success__c) success = false;
            }
            if(success) update accList;
        }
    }

    @future (callout = true)
    public static void workorderIntegration(List<id> objIdList)
    {
        Boolean disabilitaIntegrazione = Funzionalita__c.getInstance().Disabilita_Integrazione__c;
        if(disabilitaIntegrazione){
            System.debug('SV DISABILITA INTEGRAZIONE TRUE');
            return;
        }

        User currUser = [ SELECT Id, Societa__c, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
        //List<workorder> wokList = [SELECT Id FROM workorder WHERE id IN: objIdList];
        
        Log__c logList;

        String idNotAuthorizzed = EndpointServizi__c.getInstance().WRN_Id_IntegrazioneInfoStore__c;
        if(currUser.Id != idNotAuthorizzed){
            logList = (workorderIntegration_HDR(objIdList));
        } else {
            System.debug('SV NON ESEGUO LA CHIAMATA UTENTE NON AUTORIZZATO');
        }

        if(logList != null){
            insert logList;
            /*Boolean success = true;
            if(!logList.Success__c) success = false;*/
        }
    }

    public static Log__c opportunityIntegration_InfoStore(List<Opportunity> oppList){
        date myDate  = date.today();
        String month = String.valueOf(myDate.month());
        String year  = String.valueOf(myDate.year());
        String day   = String.valueOf(myDate.day());

        Boolean success = false;
        String msg = '';
        Integer statusCode = null;
        String response = '';
        String jsonString = '';
        List<Object> data = new List<Object>();

        try { 

            if(oppList.size() > 1){
                throw new OtherException('Non si può eseguire l\'integrazione su InfoStore con più opportunità');
            }

            Set<String> fieldNamesOpp = Opportunity.sObjectType.getDescribe().fields.getMap().keyset();
            List<String> queryFieldsOpp = new List<String>();
            queryFieldsOpp.addAll(fieldNamesOpp);
            String queryStringOpp = String.join(queryFieldsOpp, ',');

            Set<String> fieldNamesOppLineItems = OpportunityLineItem.sObjectType.getDescribe().fields.getMap().keyset();
            List<String> queryFieldsOppLineItems = new List<String>();
            queryFieldsOppLineItems.addAll(fieldNamesOppLineItems);
            String queryStringOppLineItems = String.join(queryFieldsOppLineItems, ',');

            Set<Id> objIdList = new Set<Id>();
            for(Opportunity opp : oppList) {
                objIdList.add(opp.Id);
            }
            List<Opportunity> opps = Database.query('SELECT ' + queryStringOpp + ', (SELECT ' + queryStringOppLineItems + ' FROM OpportunityLineItems), (SELECT Id, IsDeleted, ParentId, RecordType, Title, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, FileType, ContentSize, FileExtension, ContentUrl, ExternalDataSourceName, ExternalDataSourceType, SharingOption FROM CombinedAttachments), (SELECT Id, FileType, FileExtension, Title, TextPreview, LinkedEntityId, ContentSize, ContentDocumentId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM AttachedContentNotes), Owner.Email, Owner.Name, Account.Id, Account.Name, Account.Codice_Unico_Tinexta__c, Account.WRT_NomeLegaleRappresentante__c, Account.WRT_CognomeLegaleRappresentante__c, Account.link_warrant__c, Account.Codice_Azienda_Warrant__c FROM Opportunity WHERE id IN: objIdList');

            
            // for(Opportunity o : opps){
            //     System.debug('SV opp: ' + o);
            //     for(sObject note : o.AttachedContentNotes){
            //         System.debug('SV note: ' + note);

            //     }
            // }

            // List<ContentNote> cnList = [SELECT Id, Content FROM ContentNote WHERE Id = '0691X000000z0KIQAY'];
            // System.debug('SV cnList: ' + cnList);

            Boolean existObject = Utilities.isObjectExist('WorkOrder');
            System.debug('SV EXIST OBJ WORKORDER: ' + existObject);
            // Map<ID, WorkOrder> mWO = new Map<ID, WorkOrder>();
            // if(existObject){
            //     Set<String> fieldNamesWO = WorkOrder.sObjectType.getDescribe().fields.getMap().keyset();
            //     List<String> queryFieldsWO = new List<String>();
            //     queryFieldsWO.addAll(fieldNamesWO);
            //     String queryStringWO = String.join(queryFieldsWO, ',');

            //     List<WorkOrder> wos = Database.query('SELECT ' + queryStringWO + ' FROM WorkOrder WHERE Opportunita__c IN: objIdList');
            //     for(WorkOrder wo : wos){
            //         mWO.put(wo.Id, wo);
            //     }
            // }

            PayLoadInfoStore pay = new PayLoadInfoStore();
            pay.PayLoad = opps;

            System.debug('PAYLOAD: ' + pay);
            jsonString = JSON.serialize(pay);
            // for (ID idKey : mWO.keyset()) {
            //     jsonString = jsonString.replace('"' + idKey + '"', JSON.serialize(mWO.get(idKey)));
            // }
            // jsonString = jsonString.replaceAll('Work_Order__c', 'WorkOrder');
            System.debug('JSON.serialize: ' + jsonString);

            // Set<String> oppFieldList = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().keySet();
            // List<String> queryFields = new List<String>();
            // queryFields.addAll(oppFieldList);
            // system.debug('SELECT ' + queryFields + ' FROM Opportunity WHERE id IN ' + objIdList);
            //List<Opportunity> opps = Database.query('SELECT ' + queryFields + ' FROM Opportunity WHERE id IN ' + objIdList);

            // sm3llsl1k3t33nsp1r1t
            String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
            String endPointIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Url_IntegrazioneInfoStore__c;

            System.debug('SV keyIntegrazioneInfoStore: ' + keyIntegrazioneInfoStore + + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day));
            String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
            System.debug('SV keyIntegrazioneInfoStore Encode: ' + output);

            JWT jwt = new JWT('HS256'); 
            jwt.userEmail = UserInfo.getUserEmail();
            
            jwt.privateKey = output; 
            // jwt.iss = 'your issuer'; 
            // jwt.sub = 'some subject'; 
            // jwt.aud = 'some audience'; 
            String token = jwt.issue();        
            system.debug ('token: '+ token);

            HttpRequest req = new HttpRequest();                            
            req.setEndpoint(endPointIntegrazioneInfoStore);
            // req.setEndpoint('https://putsreq.com/XTQn7WDyrHzb0uSXneQm'); // https://salesforce-test.warranthub.it/api/test	
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setBody(jsonString);

            //Execute web service call here 
            Http http = new Http();               
            HTTPResponse res = http.send(req);

            //Helpful debug messages 
            System.debug(res.toString()); 
            System.debug('STATUS: '+res.getStatus()); 
            System.debug('STATUS_CODE: '+res.getStatusCode()); 
            System.debug ('HTTPResponse Body: '+ res.getBody());

            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            success = (Boolean)resBody.get('success'); 
            msg = (String)resBody.get('message');
            response = res.getBody();

            data.add(resBody.get('data'));
            statusCode = res.getStatusCode();
            System.debug('Success: '+ success);
            System.debug('msg: '+ msg);
            System.debug('data: '+ data);

            if(success){

                Map<String, Object> responseOpp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resBody.get('data')));
                responseOpp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseOpp.get('Opportunity')));
                System.debug('responseOpp: '+ responseOpp);
                
                oppList[0].Numero_offerta_Infostore__c = String.valueOf(responseOpp.get('Numero_offerta_Infostore__c'));
                oppList[0].WRT_Link_offerta_Infostore__c = String.valueOf(responseOpp.get('WRT_Link_offerta_Infostore__c'));
            }

            if(Test.isRunningTest())
                throw new CalloutException('TestException');

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            success = false; 
            msg = e.getMessage();   
 
        } catch (BaseException e) {  
            // This catches the OtherException
            success = false; 
            msg = e.getMessage();
        } 

        if(success){
            oppList[0].WRT_LastRequestSuccess_Infostore__c = 'true';
        } else {
            oppList[0].WRT_LastRequestSuccess_Infostore__c = 'false';
        }

        return new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneInfoStore',
            Nome_Classe__c = 'WRT_IntegrazioneController',
            ID_Record__c = oppList[0].id,
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = response
        );


    }

    // @future(callout=true)
    public static String opportunityIntegration_InfoStore_CPQ(Id quoteId){
        SBQQ.TriggerControl.disable();

        date myDate  = date.today();
        String month = String.valueOf(myDate.month());
        String year  = String.valueOf(myDate.year());
        String day   = String.valueOf(myDate.day());

        Boolean success = false;
        String msg = '';
        Integer statusCode = null;
        String response = '';
        String jsonString = '';
        List<Object> data = new List<Object>();
        // Id oppId;

        try { 

            Set<String> genericLookupIds = new Set<String>();
            List<SObject> sobjs = new List<SObject>();

            //Utilizzate per memorizzare la lista di quote
            List<Map<string,object>> quotesObj = new List<Map<string,object>>();

            /**
                * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
                * @param objectApiName: nome API oggetto su cui eseguire la query
                * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
                */ 
            //reperisco tutti i campi dell'oggetto
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get('SBQQ__Quote__c').getDescribe().fields.getMap();
            list<string> list_field = new list<string>(fieldMap.keyset());
        
            //SELECT con tutti i campi dell'oggetto
            string qrSelect = 'select '+string.join(list_field , ',')+ ', CreatedBy.Id, CreatedBy.Name, CreatedBy.Email '
                                                                    +', CreatedBy.Username, LastModifiedBy.Id, LastModifiedBy.Email, '
                                                                    +'LastModifiedBy.Username, LastModifiedBy.Name, '
                                                                    +'SBQQ__Account__r.Codice_Azienda_Warrant__c, '
                                                                    +'SBQQ__Account__r.Codice_Unico_Tinexta__c, '
                                                                    +'SBQQ__Account__r.Name' ;
            string qrFrom = ' from SBQQ__Quote__c';//FROM oggetto
            string qrWhere = ' where Id =: quoteId'; //WHERE filtri query
            string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
            
            //creo una variabile di tipo "Tipo lista<Oggetto>"
            //System.Type listType = System.Type.forName('List<'+objectApiName+'>');
            //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
            //List<SObject> result = (List<SObject>)listType.newInstance();
        
        
            //aggiungere where/order se correttamente valorizzati nelle variabili
            //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
            //Recupero le quote legate all'opportunità
            //qrSelect + qrFrom + qrWhere + qrOrder
            sobjs = Database.query(qrSelect + qrFrom + qrWhere);
            Map<String,SBQQ__Quote__c> quotes = (Map<String,SBQQ__Quote__c>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(sobjs, 'Id'), false), Map<String,SBQQ__Quote__c>.Class);

            //Popolo il set dei lookupId dell'oggetto padre
            genericLookupIds = quotes.keySet();

            System.debug('@@@ genericLookupIds ' + genericLookupIds);
 

            //Recupero tutte le quote line legate all'opportunità
            sobjs = Database.query('SELECT Id, Name, Numero_offerta_Infostore__c, WRT_Link_Offerta_Infostore__c,Codice_di_raggruppamento_QL__c, Valore_del_pagamento_in_euro_Prodotto__c, WRT_Agente3__c, WRT_AccountPerFatturazione__c, SBQQ__Product__c, WH_Sottoprogetto__c, WRT_esercizio__c, Titolare_Account_formula__c,  Documenti_oppotunita_warranthub__c, WH_Note_Infostore__c, Azienda_WarrantCPQ__c, Divisione_WarrantCPQ__c, WRT_Modalita_pagamento__c, LastModifiedDate, CreatedBy.Id, CreatedBy.Name, CreatedBy.Email, CreatedBy.Username, LastModifiedBy.Id, LastModifiedBy.Email, LastModifiedBy.Username, LastModifiedBy.Name, WRT_data_conclusa__c, WRT_conclusa_motivo__c, Tipo_Mandato__c, WRT_Rinnovare_FORM__c, Numero_di_Rinnovi__c, Anno_del_Mandato_FORM__c, WRT_Disdetta__c, Data_disdetta__c, Motivo_disdetta__c, WRT_Modalita_ricezione_disdetta__c, WRT_Gruppo2__c, WRT_data__c, WRT_inizio_validita__c, WRT_fine_validita__c, WRT_scadenza__c, WRT_codice_ordine_cliente__c, WRT_ordine_cliente__c, WRT_cig__c, WRT_cup__c, WRT_WB_codice__c, WRT_Codice_Offerta__c, WRT_Codice_Ordine__c, WRT_Validita_offerta__c, WRT_ID_Workorder_SALES_FORCE__c, Tipo_domanda__c, WRT_Perizia_giurata_anno_2012__c, WRT_Perizia_giurata_anno_2013__c, WRT_Perizia_giurata_anno_2014__c, WRT_Iper_Nettosuper__c, WRT_Iper_NuovoMandato__c, WRT_Iper_PeriziaEsercizio__c, WRT_Iper_PeriziaCompetenza__c, WRT_TipoNuovo__c, WRT_TipoOpportunita__c, WRT_Opzione_Ricostruzione__c, Stato_pagamento_dellopportunita_vinta__c, WRT_StatoFatturazioneOpportunita__c, WRT_Totale_beneficio_cliente__c, Nome_Quote_Line__c, Rinnovo_FORM__c, WRT_ID_Quote_Line_Item_SALES_FORCE__c, Account_Name_FORM__c, SBQQ__Quote__c, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__Product__r.Description, SBQQ__Product__r.Codice_SAP_w__c, SBQQ__Product__r.Business_Area_w__c, SBQQ__Product__r.WRT_Business_Line__c, SBQQ__Product__r.Lead_Time_w__c, CreatedDate, WRT_Valore_investimento__c, QuoteLineRinnovata__c, Una_perizia_per_ciascun_esercizio_di_com__c, Calcolo_particolare_del_beneficio__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: genericLookupIds');
            Map<string,SBQQ__QuoteLine__c> quoteLines = (Map<string,SBQQ__QuoteLine__c>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(sobjs, 'Id'), false), Map<String,SBQQ__QuoteLine__c>.Class);
            System.debug('@@@ quotelines ' + JSON.serialize(sobjs, true));
            //Raggruppo le quote line alla singola quote dell'opportunità
            Map<string,List<SBQQ__QuoteLine__c>> quoteLinesMap = (Map<string,List<SBQQ__QuoteLine__c>>) Utilities.groupBy(quoteLines.values(), 'SBQQ__Quote__c');
            // for(String s : quoteLinesMap)
            //Serve per salvare associazione tra quote line e condizioni
            Map<string, List<Map<string,object>>> qlXcondizioni = new Map<string, List<Map<string,object>>>();

            // queryFieldsGeneric.clear();
            // queryFieldsGeneric.addAll(fieldNamesCondizioni);
            // queryStringGeneric = String.join(queryFieldsGeneric, ',');
            genericLookupIds = quoteLines.keySet();

            //Recupero tutte le condizioni delle quote line
            // sobjs = Database.query('SELECT ' + queryStringGeneric + ' FROM Condizioni__c WHERE Quote_Line__c IN: genericLookupIds');
            sobjs = Database.query('SELECT Id, Tipo_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM__c, Percentuale_WarrantCPQ__c, Fisso_WarrantCPQ__c, Minimo_WarrantCPQ__c, Massimo_WarrantCPQ__c, Limite_WarrantCPQ__c, Min_garantito_WarrantCPQ__c, Valore_max_WarrantCPQ__c, Importo_Appoggio__c, Stima_Appoggio__c, Finanziamento__c, Quote_Line__c, Quote_Line__r.SBQQ__Quote__c, Name, WRT_Tipologia_Finanziamento_FORM_Servizi__c, FF_WarrantCPQ_FORM__c FROM Condizioni__c WHERE Quote_Line__c IN: genericLookupIds AND Quote_Line__r.Non_allineare_valore_OPT_con_Pricing__c	= false');
            Map<string,Condizioni__c> condizioni = (Map<string,Condizioni__c>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(sobjs, 'Id'), false), Map<String,Condizioni__c>.Class);

            genericLookupIds = condizioni.keySet();

            //Recupero tutte le condizioni opzionali legate alla condizione padre
            sobjs = Database.query('SELECT Id, Formula_Quote_Line__c, CondizionePadre_WarrantCPQ__c, CondizionePadre_WarrantCPQ__r.Name, CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__c, Name, Tipo_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM__c, Percentuale_WarrantCPQ__c, Fisso_WarrantCPQ__c, Minimo_WarrantCPQ__c, Massimo_WarrantCPQ__c, Limite_WarrantCPQ__c, Min_garantito_WarrantCPQ__c, Valore_max_WarrantCPQ__c, Formula_Importo_WarrantCPQ__c, Formula_Stima_WarrantCPQ__c, WRT_Tipologia_Finanziamento_FORM_Servizi__c, FF_WarrantCPQ_FORM__c FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__c IN: genericLookupIds AND CondizionePadre_WarrantCPQ__r.Quote_Line__r.Non_allineare_valore_OPT_con_Pricing__c = false ORDER BY Minimo_WarrantCPQ__c ASC');
            Map<string,Condizione_Opzionale__c> condizioniOpzionali = (Map<string,Condizione_Opzionale__c>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(sobjs, 'Id'), false), Map<String,Condizione_Opzionale__c>.Class);

            //Raggruppo le condizioni opzionali per condizione padre
            Map<string, List<Condizione_Opzionale__c>> condizioniOpzionaliMap = (Map<string,List<Condizione_Opzionale__c>>) Utilities.groupBy(condizioniOpzionali.values(), 'CondizionePadre_WarrantCPQ__c');
            
            genericLookupIds = quoteLines.keySet();

            //Recupero tutti i finanziamenti
            sobjs = Database.query('SELECT Id, Tipologia_Finanziamento_WarrantCPQ__c, Importo_WarrantCPQ__c, Stima_WarrantCPQ__c, Fattura_WarrantCPQ__c, Quote_Line__c, Quote_Line__r.SBQQ__Quote__c, Name FROM Finanziamenti__c WHERE Quote_Line__c IN: genericLookupIds AND Quote_Line__r.Non_allineare_valore_OPT_con_Pricing__c	= false');
            Map<string,Finanziamenti__c> finanziamenti = (Map<string,Finanziamenti__c>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(sobjs, 'Id'), false), Map<String,Finanziamenti__c>.Class);

            //Raggruppo i finanziamenti per quote line
            Map<string, List<Finanziamenti__c>> finanziamentiMap = (Map<string, List<Finanziamenti__c>>) Utilities.groupBy(finanziamenti.values(), 'Quote_Line__c');
            
            genericLookupIds = quoteLines.keySet();
            
            //Recupero tutti i pagamenti legati alla quote line
            sobjs = Database.query('SELECT Id, Percentuale_WarrantCPQ__c, Formula_Importo_WarrantCPQ__c, Scadenza_WarrantCPQ__c, Parte_WarrantCPQ__c, Probabilita_WarrantCPQ__c, Opzione_WarrantCPQ__c, Azienda_WarrantCPQ_FORM_Servizi__c, Divisione_WarrantCPQ_FORM_Servizi__c, Stampa_Fattura_WarrantCPQ__c, Formula_Stima_WarrantCPQ__c, Tipo_pagamento_WarrantCPQ__c, Codice_Ordine_Cliente_WarrantCPQ__c, WRT_Stato_pagamento__c, Anno_nuovo_ordine_WarrantCPQ__c, FatturaCheck_WarrantCPQ__c, Descrizione_fattura_WarrantCPQ__c, Procedimento_pagamento__c, Procedimento_pagamento__r.RecordType.DeveloperName, Procedimento_pagamento__r.Descrizione__c, Procedimento_pagamento__r.Codice__c, Condizione_WarrantCPQ__c, Quote_Line__c, Quote_Line__r.SBQQ__Quote__c, Name, Blocco_riga_pagamento__c, Formula_Numero_e_data_fattura__c, Numero_Fattura__c, Data_Fattura__c, WRT_cig__c, WRT_cup__c, WRT_Stato_fatturazione__c, Data_Ordine_Cliente__c, Condizione_WarrantCPQ__r.Name FROM Pagamenti__c WHERE Quote_Line__c IN: genericLookupIds AND Condizione_WarrantCPQ__r.Quote_Line__r.Non_allineare_valore_OPT_con_Pricing__c = false');
            Map<string,Pagamenti__c> pagamenti = (Map<string,Pagamenti__c>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(sobjs, 'Id'), false), Map<String,Pagamenti__c>.Class);

            //Raggruppo i pagamenti per quote line
            Map<string, List<Pagamenti__c>> pagamentiMap = (Map<string, List<Pagamenti__c>>) Utilities.groupBy(pagamenti.values(), 'Quote_Line__c');

            //Associo la lista di condizioni opzionali alla corretta condizione
            //Creo anche una mappa in cui associo la quote line alla lista di condizioni
            for(Id condId : condizioni.keySet()){
                Map<string,object> condizioneObj = (Map<string,object>)JSON.deserializeUntyped(JSON.serialize(condizioni.get(condId), false));
                condizioneObj.put('Condizioni_Opzionali', (object)condizioniOpzionaliMap.get(condId));               
                //Se esiste già una quote line con condizioni associate la recupero temporaneamente e aggiungo la condizione appena generata
                //Altrimenti l'aggiungo con la nuova condizione, questo per evitare di perdere dati
                if(qlXcondizioni.containsKey(condizioni.get(condId).Quote_Line__c)){
                    List<Map<string,object>> tmpcondizioni = qlXcondizioni.get(String.valueOf(condizioni.get(condId).Quote_Line__c));
                    tmpcondizioni.add(condizioneObj);
                    qlXcondizioni.put(condizioni.get(condId).Quote_Line__c, tmpcondizioni);
                } else {
                    qlXcondizioni.put(condizioni.get(condId).Quote_Line__c, new List<Map<string,object>>{condizioneObj});
                }
            }

            //Mappa utilizzata per salvare quote con la lista di quote line con associati gli altri oggetti(Finanziamenti, Pagamenti, Condizioni)
            Map<string, List<Map<string,object>>> qlMap = new Map<string, List<Map<string,object>>>();
            //Associo quote line a finanziamenti, pagamenti e condizioni
            System.debug('@@@ qlXCondizioni ' + JSON.serialize(qlXCondizioni));
            if(qlXCondizioni.keySet().size() > 0){
                for(String qlId : qlXcondizioni.keySet()){
                    Map<string,object> qlObj = (Map<string,object>)JSON.deserializeUntyped(JSON.serialize(quoteLines.get(qlId), false));
                    qlObj.put('Condizioni', (object)qlXcondizioni.get(qlId));
                    qlObj.put('Finanziamenti', (object) finanziamentiMap.get(qlId));
                    qlObj.put('Pagamenti', (object) pagamentiMap.get(qlId));
                    //Controllo per evitare di sovrascrivere i dati in modo da non perderli
                    if(qlMap.containsKey(String.valueOf(qlObj.get('SBQQ__Quote__c')))){
                        List<Map<string,object>> tmpqllist = qlMap.get(String.valueOf(qlObj.get('SBQQ__Quote__c')));
                        tmpqllist.add(qlObj);
                        qlMap.put(String.valueOf(qlObj.get('SBQQ__Quote__c')), tmpqllist);
                    } else {
                        qlMap.put(String.valueOf(qlObj.get('SBQQ__Quote__c')), new List<Map<string,object>>{qlObj});
                    }
                }
            } else {
                for(String qlId : quoteLines.keySet()){
                    Map<string,object> qlObj = (Map<string,object>)JSON.deserializeUntyped(JSON.serialize(quoteLines.get(qlId), false));
                    qlObj.put('Condizioni', (object) new List<Map<String,Object>>());
                    qlObj.put('Finanziamenti', finanziamentiMap.get(qlId) != null ? (object) finanziamentiMap.get(qlId) : (object) new List<Map<String,Object>>());
                    qlObj.put('Pagamenti', pagamentiMap.get(qlId) != null ? (object) pagamentiMap.get(qlId) : (object) new List<Map<String,Object>>());

                    if(qlMap.containsKey(String.valueOf(qlObj.get('SBQQ__Quote__c')))){
                        List<Map<string,object>> tmpqllist = qlMap.get(String.valueOf(qlObj.get('SBQQ__Quote__c')));
                        tmpqllist.add(qlObj);
                        qlMap.put(String.valueOf(qlObj.get('SBQQ__Quote__c')), tmpqllist);
                    } else {
                        qlMap.put(String.valueOf(qlObj.get('SBQQ__Quote__c')), new List<Map<string,object>>{qlObj});
                    }
                }
            }

            //Associo lista di quote line alla quote corretta
            for(Id qId : quotes.keySet()){
                Map<string,object> quoteObj = (Map<string,object>)JSON.deserializeUntyped(JSON.serialize(quotes.get(qId), false));
                if(qlMap.get(qId) != null)
                    quoteObj.put('LineItems', (object) qlMap.get(qId));
                else
                    quoteObj.put('LineItems', (object) quoteLines.values());
                quotesObj.add(quoteObj);
            }
            
            //Associo all'opportunità la quote
            // Sobject oppsObj = (Sobject)JSON.deserializeStrict(JSON.serialize(opps[0]), Sobject.Class);
            // Map<string,object> mapSingleOpp = (Map<string,object>) JSON.deserializeUntyped(JSON.serialize(oppsObj));
            // mapSingleOpp.put('Quotes', (object) quotesObj);
            // List<Object> oppListObj = new List<Object>{mapSingleOpp};

            // List<Map<String,Object>> payload = new List<Map<String,Object>>();
            // payload.add((Map<String,Object>)quotesObj);

            // List<Object> oppListObj = new List<Object>{quotesObj};

            Boolean existObject = Utilities.isObjectExist('WorkOrder');
            System.debug('SV EXIST OBJ WORKORDER: ' + existObject);

            PayLoadInfoStore pay = new PayLoadInfoStore();
            pay.PayLoad = quotesObj;

            jsonString = JSON.serialize(pay, false);
            System.debug('@@@ payload ' + jsonString);

            // sm3llsl1k3t33nsp1r1t
            String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
            String endPointIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRT_Create_CPQ_Infostore__c;
            // String endPointIntegrazioneInfostore = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';

            System.debug('SV keyIntegrazioneInfoStore: ' + keyIntegrazioneInfoStore + + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day));
            String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
            System.debug('SV keyIntegrazioneInfoStore Encode: ' + output);

            JWT jwt = new JWT('HS256'); 
            jwt.userEmail = UserInfo.getUserEmail();
            
            jwt.privateKey = output; 
            String token = jwt.issue();        
            system.debug ('token: '+ token);

            HttpRequest req = new HttpRequest();                            
            req.setEndpoint(endPointIntegrazioneInfoStore);
            // req.setEndpoint('https://putsreq.com/XTQn7WDyrHzb0uSXneQm'); // https://salesforce-test.warranthub.it/api/test	
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setBody(jsonString);
            req.setTimeout(120000);

            //Execute web service call here 
            Http http = new Http();
            HTTPResponse res = http.send(req);

            //Helpful debug messages 
            System.debug(res.toString()); 
            System.debug('STATUS: '+res.getStatus()); 
            System.debug('STATUS_CODE: '+res.getStatusCode()); 
            System.debug ('HTTPResponse Body: '+ res.getBody());

            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Map<String,Object> resBody = (Map<String,Object>) JSON.deserializeUntyped('{"success": true,"message": "ok","data": {"Quote": {"Numero_offerta_Infostore__c": "123-456","LineItems": [{"Id": "a1p1x000004XefzAAC","Numero_offerta_Infostore__c": "123","WRT_Link_offerta_Infostore__c": "http://test.it"},{"Id": "a1p1x000004Xeg0AAC","Numero_offerta_Infostore__c": "456","WRT_Link_offerta_Infostore__c": "http://test.it"}]}}}');
            success = (Boolean)resBody.get('success'); 
            msg = (String)resBody.get('message');
            response = JSON.serializePretty(resBody);
            // response = JSON.serializePretty(resBody);

            // data.add(resBody.get('data'));
            // statusCode = res.getStatusCode();
            statusCode = 200;
            System.debug('Success: '+ success);
            System.debug('msg: '+ msg);
            // System.debug('data: '+ data);

            SBQQ__Quote__c quote = [SELECT Id, Risposta_Ultimo_Invio_Infostore__c, SBQQ__Opportunity2__c, Numero_offerta_Infostore__c, Ultimo_invio_a_Infostore__c FROM SBQQ__Quote__c WHERE Id =: quoteId];

            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();

            system.debug('Actual Time as String ' + dt.format());
            system.debug('Offset ' + tz.getOffset(dt)/1000);
            system.debug('Formatted Time ' + dt.addSeconds((tz.getOffset(dt)/1000)));

            if(success){
                Map<String,Object> dataMap = (Map<String,Object>)resBody.get('data');
                System.debug('@@@ dataMap ' + dataMap);

                Map<String,Object> quoteMapTmp = (Map<String,Object>) dataMap.get('Quote');
                quote.Numero_offerta_Infostore__c = String.valueOf(quoteMapTmp.get('Numero_offerta_Infostore__c'));
                System.debug('@@@ offerta ' + String.valueOf(quoteMapTmp.get('Numero_offerta_Infostore__c')));

                // update quote;
                Map<Id, SBQQ__QuoteLine__c> quoteLinesUpd = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, Risposta_Ultimo_Invio_IS_Data_ORA__c, Numero_offerta_Infostore__c, WRT_Link_offerta_Infostore__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id]);
                
                List<Object> tmpLineItems = (List<Object>) quoteMapTmp.get('LineItems');
                List<Map<String,Object>> tmpQl = new List<Map<String,Object>>();
                for(Object o : tmpLineItems){
                    Map<String,Object> tmpQlObj = (Map<String,Object>) o;
                    tmpQl.add(tmpQlObj);
                }

                for(Map<String,Object> tmpSingleQl : tmpQl){
                    quoteLinesUpd.get((Id)tmpSingleQl.get('Id')).Numero_offerta_Infostore__c = String.valueOf(tmpSingleQl.get('Numero_offerta_Infostore__c'));
                    quoteLinesUpd.get((Id)tmpSingleQl.get('Id')).WRT_Link_offerta_Infostore__c = String.valueOf(tmpSingleQl.get('WRT_Link_offerta_Infostore__c'));

                    // quoteLinesUpd.get((Id)tmpSingleQl.get('Id')).Risposta_Ultimo_Invio_IS_Data_ORA__c = System.Now();
                    DateTime dtQl = Datetime.now();
                    quoteLinesUpd.get((Id)tmpSingleQl.get('Id')).Risposta_Ultimo_Invio_IS_Data_ORA__c = dtQl.addSeconds((tz.getOffset(dtQl)/1000));                }

                update quoteLinesUpd.values();                
            }

            // SBQQ__Quote__c quote = [SELECT Id, Risposta_Ultimo_Invio_Infostore__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: oppList[0].Id];
            quote.Risposta_Ultimo_Invio_Infostore__c = msg.length() >= 255 ? msg.substring(0,255) : msg;
            DateTime dtQ = Datetime.now();
            quote.Ultimo_invio_a_Infostore__c = dtQ.addSeconds((tz.getOffset(dtQ)/1000));//System.Now();
            update quote;

            System.debug('@@@ quote ' + quote);

            if(success)
            {
                workorder[] recordId = [select id from workOrder where WRT_Opportunity__c = :quote.SBQQ__Opportunity2__c order by createddate desc limit 1];
                if(recordId.size() > 0)
                {
                    /*Log__c logList = WRT_IntegrazioneController.workOrderIntegration_HDR(new list<id>{recordId});
                    if(logList != null)
                    {
                        System.debug('*************if(logList != null)****************'+logList != null);
                        insert logList;
                    }*/
                    WRT_IntegrazioneController.workorderIntegration(new list<id>{recordId[0].id});
                }
            }

        // } catch(System.CalloutException e) { 
        //     //Exception handling goes here.... retry the call, whatever 
        //     success = false; 
        //     msg = e.getMessage();
        //     SBQQ__Quote__c quote = [SELECT Id, Risposta_Ultimo_Invio_Infostore__c, Ultimo_Invio_a_Infostore__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        //     quote.Risposta_Ultimo_Invio_Infostore__c = e.getMessage().length() >= 255 ? e.getMessage().substring(0,255) : e.getMessage();
        //     quote.Ultimo_invio_a_Infostore__c = System.Now();
        //     update quote;
        //     System.debug('@@@ ecc1 ' + e.getMessage() + ' ' + e.getLineNumber());
        } catch (Exception e){
            success = false;
            msg = e.getMessage() + ' ' + e.getLineNumber();
            SBQQ__Quote__c quote = [SELECT Id, Risposta_Ultimo_Invio_Infostore__c, Ultimo_invio_a_Infostore__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
            quote.Risposta_Ultimo_Invio_Infostore__c = e.getMessage().length() >= 255 ? e.getMessage().substring(0,255) : e.getMessage();
            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();

            system.debug('Actual Time as String ' + dt.format());
            system.debug('Offset ' + tz.getOffset(dt)/1000);
            system.debug('Formatted Time ' + dt.addSeconds((tz.getOffset(dt)/1000)));

            quote.Ultimo_invio_a_Infostore__c = dt.addSeconds((tz.getOffset(dt)/1000));
            update quote;
            System.debug('@@@ ecc3 ' + e.getMessage() + ' ' + e.getLineNumber());
        }

        insert new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneInfoStore',
            Nome_Classe__c = 'WRT_IntegrazioneController',
            ID_Record__c = quoteId,
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = response
        );

        return msg.toUpperCase();
    }


    public static Log__c accountIntegration_SharePoint(List<Account> accList){

        String endPointAuth = EndpointServizi__c.getInstance().WRN_URL_SharePoint_Auth__c;
        String endPointCreateFolder = EndpointServizi__c.getInstance().WRT_SharePoint_Create_Folder_Account__c;
        List<String> accFolders = EndpointServizi__c.getInstance().WRT_SharePoint_Folders_Account__c == null ? new List<String>() : EndpointServizi__c.getInstance().WRT_SharePoint_Folders_Account__c.split(',');

        Boolean success = true;
        String msg = '';
        Integer statusCode = null;
        String response = '';
        String jsonString = '';
        List<Object> data = new List<Object>();

        try { 

            if(accList.size() > 1){
                throw new OtherException('Non si può eseguire l\'integrazione su SharePoint con più account');
            }

            PayLoadSharePoint pay = new PayLoadSharePoint();
            pay.CustomerId = accList[0].Codice_Unico_Tinexta__c;
            pay.CustomerName = accList[0].Codice_Unico_Tinexta__c + '-' + accList[0].Name;
            pay.DocLibUrl = '';
            pay.Folders = accFolders;

            System.debug('PAYLOAD: ' + pay);
            jsonString = JSON.serialize(pay);

            String payLoadAuth = 'grant_type=password' 
                        + '&username=' + EncodingUtil.urlEncode('warranthubapi','UTF-8') 
                        + '&password=' + EncodingUtil.urlEncode('warranthubapi', 'UTF-8');
        
            HttpRequest reqAuth = new HttpRequest();                            
            reqAuth.setEndpoint(endPointAuth);
            reqAuth.setMethod('POST');
            reqAuth.setHeader('Content-Type','application/x-www-form-urlencoded');
            reqAuth.setBody(payLoadAuth);

            HttpRequest reqCreateFolder = new HttpRequest();                            
            // reqCreateFolder.setEndpoint('https://putsreq.com/XTQn7WDyrHzb0uSXneQm');
            reqCreateFolder.setEndpoint(endPointCreateFolder);
            reqCreateFolder.setMethod('POST');
            reqCreateFolder.setHeader( 'Content-Type', 'application/json' );    
            reqCreateFolder.setTimeout(90000);    

            //Execute web service call here 
            Http http = new Http();               
            HTTPResponse resAuth = http.send(reqAuth);

            //Helpful debug messages 
            System.debug('--- SV AUTH ---'); 

            System.debug(resAuth.toString()); 
            System.debug('STATUS: ' + resAuth.getStatus()); 
            System.debug('STATUS_CODE: ' + resAuth.getStatusCode()); 
            System.debug ('HTTPResponse Body: ' + resAuth.getBody());

            Map<String, Object> resAuthBody = (Map<String, Object>) JSON.deserializeUntyped(resAuth.getBody());
            System.debug('access_token: ' + resAuthBody.get('access_token'));
            System.debug('token_type: ' + resAuthBody.get('token_type'));

            reqCreateFolder.setHeader( 'Authorization', 'Bearer ' + resAuthBody.get('access_token'));  
            reqCreateFolder.setBody(jsonString);


            http = new Http();               
            HTTPResponse resCreateFolder = http.send(reqCreateFolder);    

            //Helpful debug messages 
            System.debug('--- SV CREATE FOLDER ---'); 

            System.debug(resCreateFolder.toString()); 
            System.debug('STATUS: ' + resCreateFolder.getStatus()); 
            System.debug('STATUS_CODE: ' + resCreateFolder.getStatusCode()); 
            System.debug ('HTTPResponse Body: ' + resCreateFolder.getBody());  

            response = resCreateFolder.getBody();
            statusCode = resCreateFolder.getStatusCode();

            if(statusCode == 200){
                Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(response);
                String x = String.valueof(resBody.get('CreatedFolders'));
                String url = x.removeStart('(').removeEnd(')').split(',')[0];
                List<String> parts = url.split('/');
                String filename = parts[parts.size()-1];
                String codSharePoint = parts[parts.size()-2];
                System.debug('SV SV FOLDER URL: ' + url.removeEnd(filename));

                accList[0].link_warrant__c = url.removeEnd(filename).replaceAll('CUSTOMER/', '');
                accList[0].WRT_Codice_SharePoint__c = codSharePoint;
                
            }

            if(Test.isRunningTest())
                throw new CalloutException('Test exception');

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            success = false; 
            msg = e.getMessage();   
 
        } catch (BaseException e) {  
            // This catches the OtherException
            success = false; 
            msg = e.getMessage();
        } catch (Exception e){
            success = false;
            msg = e.getStackTraceString();
        }

        return new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneSharePoint',
            Nome_Classe__c = 'WRT_IntegrazioneController',
            ID_Record__c = accList[0].id,
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = response
        );
    
    }

    public static Log__c opportunityIntegration_SharePoint(List<Opportunity> oppList){

        String endPointAuth = EndpointServizi__c.getInstance().WRN_URL_SharePoint_Auth__c;
        String endPointCreateFolder = EndpointServizi__c.getInstance().WRT_SharePoint_Create_Folder_Opportunity__c;

        List<String> oppFolders = EndpointServizi__c.getInstance().WRT_SharePoint_Folders_Opportunity__c == null ? new List<String>() : EndpointServizi__c.getInstance().WRT_SharePoint_Folders_Opportunity__c.split(',');
        
        Boolean success = true;
        String msg = '';
        Integer statusCode = null;
        String response = '';
        String jsonString = '';
        List<Object> data = new List<Object>();

        try { 

            if(oppList.size() > 1){
                throw new OtherException('Non si può eseguire l\'integrazione su SharePoint con più opportunità');
            }

            Set<Id> objIdList = new Set<Id>();
            for(Opportunity opp : oppList) {
                objIdList.add(opp.Id);
            }
            List<OpportunityLineItem> prodList = Database.query('SELECT Id, OpportunityId, Product2Id, Name, Quantity, TotalPrice, ProductName__c, Opportunity.AccountId, Opportunity.OpportunityNumber__c, Opportunity.Anno_di_competenza__c FROM OpportunityLineItem WHERE OpportunityId IN: objIdList');
            
            if(prodList.size() <= 0){
                throw new OtherException('Non si può eseguire l\'integrazione su SharePoint di un\'opportunità senza un prodotto');
            }
            
            Set<Id> accIdList = new Set<Id>();
            List<String> concatOppFolders = new List<String>();
            for(OpportunityLineItem pr : prodList) {
                accIdList.add(pr.Opportunity.AccountId);
                // NUOVA RICHIESTA MAIL 06.04
                if(oppFolders.size() > 0){
                    for(String folder: oppFolders){
                        concatOppFolders.add(pr.Opportunity.OpportunityNumber__c + '/' + folder);
                    }
                } else {
                    //oppFolders.add(pr.OpportunityId + '-' + pr.ProductName__c + '-' + pr.Opportunity.Anno_di_competenza__c);
                    // AGGIORNATO DOPO LA CALL CATELLANI (PER EVITARE ERRORI INTERNI MEGLIO MAPPARE SOLO ID)
                    concatOppFolders.add(pr.Opportunity.OpportunityNumber__c);
                }
            }
            List<Account> accList = Database.query('SELECT Id, Name, Codice_Unico_Tinexta__c, Link_Warrant__c FROM Account WHERE id IN: accIdList');

            PayLoadSharePoint pay = new PayLoadSharePoint();
            // pay.CustomerId = accList[0].Id;
            // pay.CustomerName = accList[0].Codice_Unico_Tinexta__c + '-' + accList[0].Name;
            // pay.Folders = concatOppFolders;
            pay.CustomerId = accList[0].Codice_Unico_Tinexta__c;
            pay.CustomerName = accList[0].Codice_Unico_Tinexta__c + '-' + accList[0].Name;
            pay.DocLibUrl = accList[0].link_warrant__c;
            pay.Folders = concatOppFolders;

            System.debug('PAYLOAD: ' + pay);
            jsonString = JSON.serialize(pay);

            String payLoadAuth = 'grant_type=password' 
                        + '&username=' + EncodingUtil.urlEncode('warranthubapi','UTF-8') 
                        + '&password=' + EncodingUtil.urlEncode('warranthubapi', 'UTF-8');
        
            HttpRequest reqAuth = new HttpRequest();                            
            reqAuth.setEndpoint(endPointAuth);
            reqAuth.setMethod('POST');
            reqAuth.setHeader('Content-Type','application/x-www-form-urlencoded');
            reqAuth.setBody(payLoadAuth);

            HttpRequest reqCreateFolder = new HttpRequest();                            
            // reqCreateFolder.setEndpoint('https://putsreq.com/XTQn7WDyrHzb0uSXneQm');
            reqCreateFolder.setEndpoint(endPointCreateFolder);
            reqCreateFolder.setMethod('POST');
            reqCreateFolder.setHeader( 'Content-Type', 'application/json' );
            reqCreateFolder.setTimeout(90000);    

            //Execute web service call here 
            Http http = new Http();               
            HTTPResponse resAuth = http.send(reqAuth);

            //Helpful debug messages 
            System.debug('--- SV AUTH ---'); 

            System.debug(resAuth.toString()); 
            System.debug('STATUS: ' + resAuth.getStatus()); 
            System.debug('STATUS_CODE: ' + resAuth.getStatusCode()); 
            System.debug ('HTTPResponse Body: ' + resAuth.getBody());

            Map<String, Object> resAuthBody = (Map<String, Object>) JSON.deserializeUntyped(resAuth.getBody());
            System.debug('access_token: ' + resAuthBody.get('access_token'));
            System.debug('token_type: ' + resAuthBody.get('token_type'));

            reqCreateFolder.setHeader( 'Authorization', 'Bearer ' + resAuthBody.get('access_token'));  
            reqCreateFolder.setBody(jsonString);


            http = new Http();               
            HTTPResponse resCreateFolder = http.send(reqCreateFolder);    

            //Helpful debug messages 
            System.debug('--- SV CREATE FOLDER ---'); 

            System.debug(resCreateFolder.toString()); 
            System.debug('STATUS: ' + resCreateFolder.getStatus()); 
            System.debug('STATUS_CODE: ' + resCreateFolder.getStatusCode()); 
            System.debug ('HTTPResponse Body: ' + resCreateFolder.getBody());  

            response = resCreateFolder.getBody();
            statusCode = resCreateFolder.getStatusCode();

            if(statusCode == 200){
                Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(response);

                String x = String.valueof(resBody.get('CreatedFolders'));
                String url = x.removeStart('(').removeEnd(')').split(',')[0];

                if(oppFolders.size() > 0){
                    List<String> parts = url.split('/');
                    String filename = parts[parts.size()-1];
                    url =  url.removeEnd(filename);
                    oppList[0].Documenti_oppotunita_warranthub__c = url;

                } else {
                    oppList[0].Documenti_oppotunita_warranthub__c = url;
                }

                System.debug('SV FOLDER URL: ' + url);
            }

            //update oppList[0];

            if(Test.isRunningTest())
                throw new OtherException('Test exception');

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            success = false; 
            msg = e.getMessage();   
 
        } catch (BaseException e) {  
            // This catches the OtherException
            success = false; 
            msg = e.getMessage();
        } 

        return new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneSharePoint',
            Nome_Classe__c = 'WRT_IntegrazioneController',
            ID_Record__c = oppList[0].id,
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = response
        );
    }

    public static Log__c workOrderIntegration_HDR(list<Id> workorderId)
    {
        date myDate  = date.today();
        String month = String.valueOf(myDate.month());
        String year  = String.valueOf(myDate.year());
        String day   = String.valueOf(myDate.day());

        Boolean success = false;
        String msg = '';
        Integer statusCode = null;
        string status = '';
        String response = '';
        String jsonString = '';
        String jsonPretty = '';
        List<Object> data = new List<Object>();
        list<workorder> workList = new list<workorder>();
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        string idRecordLog = '';

        try 
        { 
            List<SObject> sobjs = new List<SObject>();
            
            //query sui WorkOrder
            Map<String, Schema.SObjectType> schemaMapWo = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMapWo = schemaMapWo.get('WorkOrder').getDescribe().fields.getMap();
            list<string> list_fieldWo = new list<string>(fieldMapWo.keyset());

            string qrSelectWo = 'select '+string.join(list_fieldWo , ',');//SELECT con tutti i campi dell'oggetto
            string qrFromWo = ' from WorkOrder';//FROM oggetto
            string qrWhereWo = ' where Id in :workorderId'; //WHERE filtri query
            string qrOrderWo = ' order by '; //ORDER BY ordinamento risultati query
            
            //creo una variabile di tipo "Tipo lista<Oggetto>"
            System.Type listTypeWo = System.Type.forName('List<WorkOrder>');
            //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
            List<SObject> resultWo = (List<SObject>)listTypeWo.newInstance();
        
            Id woliRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();
            //query sui WorkOrderLineItems
            Map<String, Schema.SObjectType> schemaMapWoli = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMapWoli = schemaMapWoli.get('WorkOrderLineItem').getDescribe().fields.getMap();
            list<string> list_fieldWoli = new list<string>(fieldMapWoli.keyset());

            //filtro su recordtype = task?
            string qrSelectWoli = 'select '+string.join(list_fieldWoli , ',');//SELECT con tutti i campi dell'oggetto
            string qrFromWoli = ' from WorkOrderLineItems';//FROM oggetto
            //string qrWhereWoli = ' where recordtypeId = :'; //WHERE filtri query
            //string qrOrderWoli = ' order by '; //ORDER BY ordinamento risultati query
            
            //creo una variabile di tipo "Tipo lista<Oggetto>"
            System.Type listTypeWoli = System.Type.forName('List<WorkOrderLineItem>');
            //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
            List<SObject> resultWoli = (List<SObject>)listTypeWoli.newInstance();
        
            //aggiungere where/order se correttamente valorizzati nelle variabili
            //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
            //resultWoli = database.query(qrSelectWoli + qrFromWoli /*+ qrWhere + qrOrder*/);

            //aggiungere where/order se correttamente valorizzati nelle variabili
            //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
            resultWo = database.query(qrSelectWo +',('+qrSelectWoli + qrFromWoli +')'+ qrFromWo + qrWhereWo /*+ qrOrder*/);

            //query dinamica allfields
            //sobjs = Database.query('SELECT Id,subject,startdate, (SELECT Id, status, workorderid FROM WorkOrderLineItems) FROM WorkOrder WHERE Id in :workorderId');
            Map<String,WorkOrder> workorders = (Map<String,WorkOrder>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(resultWo, 'Id'), true), Map<String,WorkOrder>.Class);

            /*sobjs = Database.query('SELECT Id, status, workorderid FROM WorkOrderLineItem WHERE workorderId in :workorderId');
            Map<String,list<WorkOrderlineitem>> workordersLine = (Map<String,list<WorkOrderlineitem>>) JSON.deserializeStrict(JSON.serialize(Utilities.GroupBy(sobjs, 'WorkorderId'), true), Map<String,list<WorkOrderlineitem>>.Class);
            */
            system.debug('workorders '+workorders);
            //system.debug('workordersLine '+workordersLine);

            /*{"WorkOrders": [
                  {
                    "id": "0WO9E000001ShgYWAS",
                    "Subject": "TestUpdated",
                    "WorkOrderLineItems": [
                      {
                        "id": "1WL9E000000Z5M6WAK",
                        "WorkOrderId": ""
                      },
                      {
                        "id": "1WL9E000000Z25YWAS",
                        "WorkOrderId": ""
                      }
                    ]
                  }
                  ]
                }*/ 
                //lista workorder --> campi + lista woli

            //trovare modo di creare json con liste correlate
            Map<string, List<object>> qlMap = new Map<string, List<object>>();

            list<object> woList = (list<object>) workorders.values();
            workList = workorders.values();

            PayLoadWorkOrder pay = new PayLoadWorkOrder();
            pay.WorkOrders = woList;
            
            system.debug('pay '+pay);
            
            jsonString = JSON.serialize(pay, true);
            System.debug('@@@ payload ' + jsonString);
            jsonPretty = JSON.serializePretty(pay, true);
            
            String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
            String endPointIntegrazioneHDR = EndpointServizi__c.getInstance().WRT_URL_Integrazione_HdR__c;

            System.debug('SV keyIntegrazioneInfoStore: ' + keyIntegrazioneInfoStore + + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day));
            String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
            System.debug('SV keyIntegrazioneInfoStore Encode: ' + output);

            JWT jwt = new JWT('HS256'); 
            jwt.userEmail = UserInfo.getUserEmail();
            
            jwt.privateKey = output; 
            // jwt.iss = 'your issuer'; 
            // jwt.sub = 'some subject'; 
            // jwt.aud = 'some audience'; 
            String token = jwt.issue();        
            system.debug ('token: '+ token);

            HttpRequest req = new HttpRequest();            
            req.setEndpoint(endPointIntegrazioneHDR);
            //req.setEndpoint('https://salesforce-test.warranthub.it/api/v1/Wh/WorkOrder'); // https://salesforce-test.warranthub.it/api/test	
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setBody(jsonString);
            req.setTimeout(120000);

            //Execute web service call here 
            Http http = new Http();
            HTTPResponse res = http.send(req);

            //Helpful debug messages 
            System.debug(res.toString()); 
            System.debug('STATUS: '+res.getStatus()); 
            System.debug('STATUS_CODE: '+res.getStatusCode()); 
            System.debug ('HTTPResponse Body: '+ res.getBody());
            
            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Map<String,Object> resBody = (Map<String,Object>) JSON.deserializeUntyped('{"success": true,"message": "ok","data": {"Quote": {"Numero_offerta_Infostore__c": "123-456","LineItems": [{"Id": "a1p1x000004XefzAAC","Numero_offerta_Infostore__c": "123","WRT_Link_offerta_Infostore__c": "http://test.it"},{"Id": "a1p1x000004Xeg0AAC","Numero_offerta_Infostore__c": "456","WRT_Link_offerta_Infostore__c": "http://test.it"}]}}}');
            success = (Boolean)resBody.get('success'); 
            msg = (String)resBody.get('message');
            response = JSON.serializePretty(resBody);
            status = res.getStatus();

            data.add(resBody.get('data'));
            statusCode = res.getStatusCode();
            System.debug('Success: '+ success);
            System.debug('msg: '+ msg);
            System.debug('data: '+ data);

            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();

            if(status == 'OK')
            {
                workList = new List<WorkOrder>();
                success = true;
                //Map<String, Object> responseOpp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resBody.get('data')));
                list<object> wokRes = (list<object>)JSON.deserializeUntyped(JSON.serialize(resBody.get('WorkOrders')));
                System.debug('wokRes: '+ wokRes);
                map<string, object> woliRes = new map<string, object>();
                for(object okj : wokRes)
                {
                    woliRes = (map<string, object>) okj;

                    System.debug('woliRes: '+ woliRes);
                    //leggo responde per aggiornare id esterni dei woli
                    //aggiorno woli e flag invio infostoresu wo
                    //list<object> woliResList = (list<object>) woliRes.remove('WorkOrderLineItems');
                    
                    /*for(object jdj : woliResList)
                    {
                        map<string, object> woliMap = (map<string, object>) jdj;
                        workorderlineitem woliUp = new workorderlineitem();
                        woliUp.Id = (woliMap.get('Id') != null)? String.valueOf(woliMap.get('Id')) : null;
                        woliUp.id_external_system__c = (woliMap.get('ID_External_System__c') != null)? String.valueOf(woliMap.get('ID_External_System__c')) : null;
                        woliList.add(woliUp);
                    }*/
                    //workList = .values();
                    woliList.addAll((List<WorkOrderLineItem>)JSON.deserializeStrict(JSON.serialize(woliRes.remove('WorkOrderLineItems'), true), List<WorkOrderLineItem>.Class));
                    workorder wo = (workorder) JSON.deserializeStrict(JSON.serialize(woliRes, true), workorder.Class);
                    workList.add(wo);
                }

            }
            for(workorder wokr : workList)
            {
                wokr.Send_WO_and_Task__c = false;
                wokr.WRT_Risposta_Ultimo_Invio_Infostore__c = /*msg.length() >= 255 ? msg.substring(0,255) : msg/*/status;
                DateTime dtQ = Datetime.now();
                wokr.WRT_Ultimo_invio_a_Infostore__c = dtQ.addSeconds((tz.getOffset(dtQ)/1000));//System.Now();
                //wkr.ID_External_System__c = 
                system.debug('WRT_Opportunity_Product__c '+wokr.WRT_Opportunity_Product__c);
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;
            OnWorkOrderLineItemTriggerHandler.disableWorkOrderLineItemTrigger = true;*/
            update workList;
            update woliList;
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = false;
            OnWorkOrderLineItemTriggerHandler.disableWorkOrderLineItemTrigger = false;*/
        }
        catch(System.CalloutException e) 
        { 
            //Exception handling goes here.... retry the call, whatever 
            success = false; 
            msg = e.getMessage();   
            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();
            for(workorder wokr : workList)
            {
                wokr.Send_WO_and_Task__c = false;
                wokr.WRT_Risposta_Ultimo_Invio_Infostore__c = msg.length() >= 255 ? msg.substring(0,255) : msg/*status*/;
                DateTime dtQ = Datetime.now();
                wokr.WRT_Ultimo_invio_a_Infostore__c = dtQ.addSeconds((tz.getOffset(dtQ)/1000));//System.Now();
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;*/
            update workList;
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = false;*/
        } 
        catch (BaseException e) 
        {  
            // This catches the OtherException
            success = false; 
            msg = e.getMessage();
            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();
            for(workorder wokr : workList)
            {
                wokr.WRT_Risposta_Ultimo_Invio_Infostore__c = msg.length() >= 255 ? msg.substring(0,255) : msg/*status*/;
                DateTime dtQ = Datetime.now();
                wokr.WRT_Ultimo_invio_a_Infostore__c = dtQ.addSeconds((tz.getOffset(dtQ)/1000));//System.Now();
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;*/
            update workList;
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = false;*/
        } 
        catch (system.dmlexception e)
        {
            success = false; 
            msg = e.getMessage();   
            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();
            for(workorder wokr : workList)
            {
                wokr.Send_WO_and_Task__c = false;
                wokr.WRT_Risposta_Ultimo_Invio_Infostore__c = msg.length() >= 255 ? msg.substring(0,255) : msg/*status*/;
                DateTime dtQ = Datetime.now();
                wokr.WRT_Ultimo_invio_a_Infostore__c = dtQ.addSeconds((tz.getOffset(dtQ)/1000));//System.Now();
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;*/
            update workList;
            /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = false;*/
        }

        return new Log__c(
            Success__c = success,
            Status__c = status,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneHDR',
            ErrorMessage__c = msg,
            ID_Record__c = idRecordLog,
            Nome_Classe__c = 'WRT_IntegrazioneController',
            InputPayload__c = jsonPretty,
            OutputPayload__c = response
        );
    }

    @future(callout=true)
    public static void QuoteLineIntegration_SharePoint(Set<Id> quoteLineIds){

        Funzionalita__c f = Funzionalita__c.getInstance();
        if (f.Disabilita_Integrazione__c)return;

        SBQQ.TriggerControl.disable();

        String endPointAuth = EndpointServizi__c.getInstance().WRN_URL_SharePoint_Auth__c;
        // if(endPointAuth == null)return;
        String endPointCreateFolder = EndpointServizi__c.getInstance().WRT_SharePoint_Create_Folder_Opportunity__c;
    
        List<String> quoteFolders = EndpointServizi__c.getInstance().WRT_SharePoint_Folders_Opportunity__c == null ? new List<String>() : EndpointServizi__c.getInstance().WRT_SharePoint_Folders_Opportunity__c.split(',');
        
        Boolean success = true;
        String msg = '';
        Integer statusCode = null;
        String response = '';
        String jsonString = '';
        List<Object> data = new List<Object>();

        // List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>([SELECT Id, Name, SBQQ__Account__c, Documenti_oppotunita_warranthub__c FROM SBQQ__Quote__c WHERE Id IN: quoteIds AND RecordType.DeveloperName = 'Warrant']);
        List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>([SELECT Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Documenti_oppotunita_warranthub__c, Documenti_oppotunita_warranthub__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineIds AND RecordType.DeveloperName = 'Warrant']);
        // SBQQ__Quote__c quote = [SELECT Id, Name, SBQQ__Opportunity2__r.Documenti_oppotunita_warranthub__c, Documenti_oppotunita_warranthub__c FROM SBQQ__Quote__c WHERE Id =: quotelines[0].SBQQ__Quote__c];
        String urlQuote;

        try { 
    
            // if(quotelines.size() > 1){
            //     throw new OtherException('Non si può eseguire l\'integrazione su SharePoint con più Quote');
            // }
    
            SBQQ__QuoteLine__c quoteline = quotelines.get(0);
            // SBQQ__Quote__c quote = quotes.get(0);
            // List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__r.Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id ]);

            if(quoteline.Documenti_oppotunita_warranthub__c != null){
                return;
            }

            List<String> concatQuoteFolders = new List<String>();
            for(SBQQ__QuoteLine__c ql : quotelines){
                if(quoteFolders.size() > 0){
                    for(String folder : quoteFolders)
                        concatQuoteFolders.add(ql.Name + '/' + folder);
                } else
                    concatQuoteFolders.add(ql.Name);
            }

            // for(SBQQ__QuoteLine__c ql : quotelines){
            //     concatQuoteFolders.add(ql.SBQQ__Quote__r.Name + '/' + ql.Name);
            // }
            
            // if(quote.Documenti_oppotunita_warranthub__c != null)
            //     return;

            Account acc = [SELECT Id, Name, Codice_Unico_Tinexta__c, link_warrant__c FROM Account WHERE Id =: quoteline.SBQQ__Quote__r.SBQQ__Account__c];
            PayLoadSharePoint pay = new PayLoadSharePoint();
            // pay.CustomerId = accList[0].Id;
            // pay.CustomerName = accList[0].Codice_Unico_Tinexta__c + '-' + accList[0].Name;
            // pay.Folders = concatOppFolders;
            pay.CustomerId = acc.Codice_Unico_Tinexta__c;
            pay.CustomerName = acc.Codice_Unico_Tinexta__c + '-' + acc.Name;
            pay.DocLibUrl = acc.link_warrant__c;
            pay.Folders = concatQuoteFolders;
    
            System.debug('PAYLOAD: ' + JSON.serialize(pay));
            jsonString = JSON.serialize(pay);
    
            String payLoadAuth = 'grant_type=password' 
                        + '&username=' + EncodingUtil.urlEncode('warranthubapi','UTF-8') 
                        + '&password=' + EncodingUtil.urlEncode('warranthubapi', 'UTF-8');
        
            HttpRequest reqAuth = new HttpRequest();                            
            reqAuth.setEndpoint(endPointAuth);
            reqAuth.setMethod('POST');
            reqAuth.setHeader('Content-Type','application/x-www-form-urlencoded');
            reqAuth.setBody(payLoadAuth);
    
            HttpRequest reqCreateFolder = new HttpRequest();                            
            // reqCreateFolder.setEndpoint('https://putsreq.com/XTQn7WDyrHzb0uSXneQm');
            reqCreateFolder.setEndpoint(endPointCreateFolder);
            reqCreateFolder.setMethod('POST');
            reqCreateFolder.setHeader( 'Content-Type', 'application/json' );
            reqCreateFolder.setTimeout(90000);    
    
            //Execute web service call here 
            Http http = new Http();               
            HTTPResponse resAuth = http.send(reqAuth);
    
            //Helpful debug messages 
            System.debug('--- SV AUTH ---'); 
    
            System.debug(resAuth.toString()); 
            System.debug('STATUS: ' + resAuth.getStatus()); 
            System.debug('STATUS_CODE: ' + resAuth.getStatusCode()); 
            System.debug ('HTTPResponse Body: ' + resAuth.getBody());
    
            Map<String, Object> resAuthBody = (Map<String, Object>) JSON.deserializeUntyped(resAuth.getBody());
            System.debug('access_token: ' + resAuthBody.get('access_token'));
            System.debug('token_type: ' + resAuthBody.get('token_type'));
    
            reqCreateFolder.setHeader( 'Authorization', 'Bearer ' + resAuthBody.get('access_token'));  
            reqCreateFolder.setBody(jsonString);
    
    
            http = new Http();               
            HTTPResponse resCreateFolder = http.send(reqCreateFolder);    
    
            //Helpful debug messages 
            System.debug('--- SV CREATE FOLDER ---'); 
    
            System.debug(resCreateFolder.toString()); 
            System.debug('STATUS: ' + resCreateFolder.getStatus()); 
            System.debug('STATUS_CODE: ' + resCreateFolder.getStatusCode()); 
            System.debug ('HTTPResponse Body: ' + resCreateFolder.getBody());  
    
            response = resCreateFolder.getBody();
            statusCode = resCreateFolder.getStatusCode();
    
            if(statusCode == 200){
                Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(response);
    
                List<Object> tmpCreatedFolders = (List<Object>)resBody.get('CreatedFolders');
                // List<String> CreatedFolders = (List<String>)resBody.get('CreatedFolders');
                List<String> CreatedFolders = new List<String>();

                for(Object o : tmpCreatedFolders){
                    String str = String.valueOf(o);
                    // System.debug('@@@ str ' + str);
                    CreatedFolders.add(str);
                }

                for(SBQQ__QuoteLine__c ql : quoteLines){
                    for(String url : CreatedFolders){
                        if(url.contains(ql.Name) || Test.isRunningTest()){
                            String urlQuoteLine;
                            //Gestisco url per quote line
                            List<String> parts = url.split('/');
                            // System.debug('@@@ parts ' + parts);
                            String filename = '/'+parts[parts.size()-1];
                            // System.debug('@@@ filename ' + filename);
                            urlQuoteLine =  url.removeEnd(filename);
                            ql.Documenti_oppotunita_warranthub__c = urlQuoteLine;
                        }
                    }
                }

                // String x = String.valueof(resBody.get('CreatedFolders'));
                // String url = x.removeStart('(').removeEnd(')').split(',')[0];

                // if(quoteFolders.size() > 0){
                //     List<String> parts = url.split('/');
                //     String filename = parts[parts.size()-1];
                //     url =  url.removeEnd(filename);
                //     quote.Documenti_oppotunita_warranthub__c = url;
                // } else 
                //     quote.Documenti_oppotunita_warranthub__c = url;
    
                System.debug('SV FOLDER URL: ' + CreatedFolders);
    
            } else
                success = false;
    
    
        // } catch(System.CalloutException e) { 
        //     //Exception handling goes here.... retry the call, whatever 
        //     success = false; 
        //     msg = e.getMessage();
        } catch (Exception e){
            success = false;
            msg = e.getMessage();
        }
    
        insert new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneSharePoint_Quote',
            Nome_Classe__c = 'WRT_IntegrazioneController',
            ErrorMessage__c = msg,
            InputPayload__c = jsonString,
            OutputPayload__c = response
        );

        // if(success)
        //     update quotes;
        if(success){
            // if(String.isBlank(quote.Documenti_oppotunita_WarrantHub__c)){
            //     quote.Documenti_oppotunita_WarrantHub__c = urlQuote;
            //     update quote;
            // }
            update quotelines;
        }
    
        //SBQQ.TriggerControl.enable();
    }

    @future(callout=true)
    public static void saIntegration(set<id> idServList)
    {
        // inserisco qua query per recuperare info evento collegato, così da gestire i campi null
        Set<Id> setId = idservList;
        system.debug('setId '+ setId);
        system.debug('idservList ' + idservList);

        string jsonString = '';
        String jsonPretty = '';
        date myDate  = date.today();
        String month = String.valueOf(myDate.month());
        String year  = String.valueOf(myDate.year());
        String day   = String.valueOf(myDate.day());
        string response = 'fail';
        Boolean success = false;
        String msg = '';
        Integer statusCode = null;
        string status = '';
        //String response = '';
        List<Object> data = new List<Object>();
        WRT_Warrant_FSL_Settings__c sett = WRT_Warrant_FSL_Settings__c.getInstance();
        Map<String,Event> workorders;
        string idRecordLog = '';
        /*map<id, event> eventMap = new map<id, event>([select id from event where id in :idEventList]);*/
        /*for(event eve : [idEventList])
        {
            Event event = (Event) JSON.deserializeStrict(JSON.serialize(eve, true), Event.Class);

            PayLoadEvent pay = new PayLoadEvent();
            pay.Event = eve;
            
            system.debug('pay '+pay);
            
            jsonString = JSON.serialize(pay, true);
            System.debug('@@@ payload ' + jsonString);
            jsonPretty = JSON.serializePretty(eve, true);
            System.debug('@@@ payloadPretty ' + jsonPretty);

        }*/
        try 
        { 

            Map<String, Schema.SObjectType> schemaMapWo = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMapWo = schemaMapWo.get('Event').getDescribe().fields.getMap();
            list<string> list_fieldWo = new list<string>(fieldMapWo.keyset());

            //subject, email, startdate, id, whatid
            string qrSelectWo = 'select '+ sett.Wrt_Event_Field__c;/*string.join(list_fieldWo , ',');*/ //SELECT con tutti i campi dell'oggetto
            string qrFromWo = ' from Event';//FROM oggetto
            string qrWhereWo = ' where whatid in :setId and IsChild = false'; //WHERE filtri query
            string qrOrderWo = ' order by '; //ORDER BY ordinamento risultati query
            
            //creo una variabile di tipo "Tipo lista<Oggetto>"
            System.Type listTypeWo = System.Type.forName('List<Event>');
            //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
            List<SObject> resultWo = (List<SObject>)listTypeWo.newInstance();

            resultWo = database.query(qrSelectWo + qrFromWo + qrWhereWo /*+ qrOrder*/);

            workorders = (Map<String,Event>) JSON.deserializeStrict(JSON.serialize(Utilities.keyBy(resultWo, 'Id'), true), Map<String,Event>.Class);

            list<object> woList = (list<object>) workorders.values();
            //workList = workorders.values();

            PayLoadEvent pay = new PayLoadEvent();
            pay.Event = woList;
            
            system.debug('pay '+pay);
            
            jsonString = JSON.serialize(pay, true);
            System.debug('@@@ payload ' + jsonString);
            jsonPretty = JSON.serializePretty(pay, true);
            System.debug('@@@ payloadPretty ' + jsonPretty);

            String keyIntegrazioneInfoStore = EndpointServizi__c.getInstance().WRN_Key_IntegrazioneInfoStore__c;
            String endPointIntegrazioneTeams = EndpointServizi__c.getInstance().WRT_URL_Integrazione_Teams__c;

            System.debug('SV keyIntegrazioneInfoStore: ' + keyIntegrazioneInfoStore + + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day));
            String output = encodingUtil.base64Encode(Blob.valueof(keyIntegrazioneInfoStore + year + (month.length() <= 1 ? ('0' + month) : month) + (day.length() <= 1 ? ('0' + day) : day)));
            System.debug('SV keyIntegrazioneInfoStore Encode: ' + output);

            JWT jwt = new JWT('HS256'); 
            jwt.userEmail = UserInfo.getUserEmail();
            
            jwt.privateKey = output; 
            // jwt.iss = 'your issuer'; 
            // jwt.sub = 'some subject'; 
            // jwt.aud = 'some audience'; 
            String token = jwt.issue();        
            system.debug ('token: '+ token);

            HttpRequest req = new HttpRequest();            
            req.setEndpoint(endPointIntegrazioneTeams);
            //req.setEndpoint('https://salesforce-test.warranthub.it/api/v1/Wh/WorkOrder'); // https://salesforce-test.warranthub.it/api/test	
            req.setMethod('POST');
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setBody(jsonString);
            req.setTimeout(120000);

            //Execute web service call here 
            Http http = new Http();
            HTTPResponse res = http.send(req);

            //Helpful debug messages 
            System.debug(res.toString()); 
            System.debug('STATUS: '+res.getStatus()); 
            System.debug('STATUS_CODE: '+res.getStatusCode()); 
            System.debug ('HTTPResponse Body: '+ res.getBody());
            
            Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Map<String,Object> resBody = (Map<String,Object>) JSON.deserializeUntyped('{"success": true,"message": "ok","data": {"Quote": {"Numero_offerta_Infostore__c": "123-456","LineItems": [{"Id": "a1p1x000004XefzAAC","Numero_offerta_Infostore__c": "123","WRT_Link_offerta_Infostore__c": "http://test.it"},{"Id": "a1p1x000004Xeg0AAC","Numero_offerta_Infostore__c": "456","WRT_Link_offerta_Infostore__c": "http://test.it"}]}}}');
            success = (Boolean)resBody.get('success'); 
            msg = (String)resBody.get('message');
            response = JSON.serializePretty(resBody);
            status = res.getStatus();

            data.add(resBody.get('data'));
            statusCode = res.getStatusCode();
            System.debug('Success: '+ success);
            System.debug('msg: '+ msg);
            System.debug('data: '+ data);

            TimeZone tz = UserInfo.getTimeZone();
            DateTime dt = Datetime.now();

            if(success) //success
            {
                //success = true;
                //Map<String, Object> responseOpp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resBody.get('data')));
                /*list<object> dataRes = (list<object>)JSON.deserializeUntyped(JSON.serialize(resBody.get('data')));
                System.debug('dataRes: '+ dataRes);
                for(object okd : dataRes)
                {
                    system.debug(okd);
                    
                }*/

                map<string, object> woliRes = new map<string, object>();

                //return result = 'success';
            }
            for(event wokr : workorders.values())
            {
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
        }
        catch(System.CalloutException e) 
        { 
            success = false; 
            msg = e.getMessage();   
            for(event wokr : workorders.values())
            {
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
        }
        catch (BaseException e) 
        {  
            success = false; 
            msg = e.getMessage();   
            for(event wokr : workorders.values())
            {
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
            
        } 
        catch (system.dmlexception e)
        {
            success = false; 
            msg = e.getMessage();   
            for(event wokr : workorders.values())
            {
                idRecordLog += wokr.id + ',';
            }
            idRecordLog.removeEnd(',');
        }

        insert new Log__c(
            Success__c = success,
            Status__c = status,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneTeams',
            ID_Record__c = idRecordLog,
            ErrorMessage__c = msg,
            Nome_Classe__c = 'WRT_IntegrazioneController',
            InputPayload__c = jsonPretty,
            OutputPayload__c = response
        );
    }
    @invocableMethod
    public static void serviceAppointmentIntegration(list<ServiceAppointment> idServList)
    {
        Set<Id> setId = (new Map<Id,SObject>(idServList)).keySet();
        saIntegration(setId);
    }
    public static String urlEncode(Map<String, String> vals) {
        String result = '';
        for(String thisKey : vals.keySet()) {
            result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
        }
        return result.removeEnd('&');    
    }    



    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/

    class PayLoadInfoStore {
        List<Object> PayLoad;
    }

    class PayLoadWorkOrder {
        List<Object> WorkOrders;
        private list<object> add(List<Object> woli)
        {
            this.WorkOrders.addAll(woli);
            return this.WorkOrders;
        }
    }
    class PayLoadWorkOrderLineItem {
        list<object> WorkOrderLineItems;
    }
    class PayLoadEvent {
        List<Object> Event;
    }
    class PayLoadSharePoint {
        public String CustomerId;
        public String CustomerName;
        public String DocLibUrl;
        public List<String> Folders;
    }

    // class PayLoadSharePointWarrantCPQ{
    //     public String CustomerId;
    //     public String CustomerName;
    //     public String Folders;
    // }

    // class ReturnForUpdate {
    //     public List<Log__c> logList;
    //     public Account account;
    //     public Opportunity opportunity;

    //     public ReturnForUpdate(){
    //         logList = new List<Log__c>();
    //         opportunity = null;
    //         account = null;
    //     }
    // }

}

//WRT_IntegrazioneController.workorderIntegration_HDR(new list<id>{'0WO9E000001T2mvWAC'});