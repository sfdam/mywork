/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
public with sharing class AggiornamentoEsitazioneInvocaWS {

    public static String userId{get;set;}

    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c,applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c, Name, Profile.Name
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }

    /**
    * @description metodo di invocazione del ws
    * @author simone.viglianti@tengroup.it | 10-27-2021 
    * @param apiRequestName 
    * @param campaignMemberList 
    * @param stato 
    * @param note 
    * @param certificationName 
    * @param disableLog 
    * @param ruAsUserId 
    * @return Boolean 
    **/
    public static Boolean makeResponse(String apiRequestName, List<CampaignMember> campaignMemberList, String stato, String note, String certificationName, Boolean disableLog, String ruAsUserId, Boolean affinamentoMassivo, Boolean isRollback){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### stato: '+stato);
        System.debug(LoggingLevel.DEBUG,'### note: '+note);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+disableLog);
        System.debug(LoggingLevel.DEBUG,'### campaignMemberList: '+campaignMemberList);
        System.debug(LoggingLevel.DEBUG,'### ruAsUserId: '+ruAsUserId);
        System.debug(LoggingLevel.DEBUG,'### affinamentoMassivo: '+affinamentoMassivo);
        System.debug(LoggingLevel.DEBUG,'### isRollback: '+isRollback);

        Boolean esito = false;
        Map<String,String> headersReq= new Map<String,String>();

        userId = !String.isBlank(ruAsUserId) ? ruAsUserId : UserInfo.getUserId();

        WsRestInput restInput =  new WsRestInput(currentUser, null);
        Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);

        //Recuperare dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;

        HttpRequest req = new HttpRequest();

        for(String key: testataMap.keySet()){
            system.debug('Testata '+key+': '+testataMap.get(key) );

            if(testataMap.get(key) != null){
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
            }
        }
		System.debug(LoggingLevel.DEBUG,'### testata: '+testataMap);
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        System.debug('headersReq: '+headersReq);
        if(certificationName != null) req.setClientCertificateName(certificationName);
        String body = getRequestBody(stato,note,campaignMemberList,affinamentoMassivo, isRollback);
        req.setBody(body);

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.toString(); 

        System.debug(LoggingLevel.DEBUG,'### response: '+res);
        System.debug(LoggingLevel.DEBUG,'### response: '+res.getBody());
        System.debug(LoggingLevel.DEBUG,'### responseStatusCode: '+res.getStatusCode());
        if(res.getStatusCode() == 204){
            esito = true;
        }

        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,res.getHeader(s));
        }

        if(disableLog == null){
            
            disableLog = false;
        }
        if(!disableLog){
            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getBody(),
                JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return esito;
    }

    /**
    * @description metodo di costruione del body request
    * @author simone.viglianti@tengroup.it | 10-27-2021 
    * @param stato 
    * @param note 
    * @param recordList 
    * @return String 
    **/
    private static String getRequestBody(String stato, String note,List<CampaignMember> recordList, Boolean affinamentoMassivo, Boolean isRollback){
        List<TargetNec> targetNecList = new List<TargetNec>();
        Map<String,String> mapMMDSCode = New Map<String,String>{'PRIVATE'=>'1',	'FAMILY'=>'2',	'CORPORATE'=>'3',	'LARGE CORPORATE'=>'4',	'PERSONAL'=>'5',	'SMALL BUSINESS'=>'6',	'BUSINESS ALTRI'=>'7',	'CONTROPARTI ISTITUZIONALI'=>'8',	'ASSENTE'=>'9',	'RESIDUALE'=>'10',	'LARGE CORPORATE'=>'11',	/*'CORPORATE'=>'12',*/	'POE'=>'13',	'CONSULENTI FINANZIARI'=>'14',	'KEY CLIENT PRIVATI'=>'15',	'ENTI E TESORERIE'=>'50',	'NON PORTAFOGLIATI'=>'99'};
            List<String> listMMDSPOOL = New List<String>{'Family', 'POE', 'Assente', 'Residuale','Non Portafogliati'};
        Map<String,String> mapMotivoCode = New Map<String,String>{'Profilo non adatto'=>'2','Dati non Aggiornati'=>'3',	'Numerosità elevata'=>'1'};
            String recordTypeId = '';
            String tipoCampagna ='';
        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        String recordTypeTopDownMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Multistep').getRecordTypeId();
        String recordTypeTriggerBasedMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Monostep').getRecordTypeId();
        String recordTypeTriggerBaseMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Multistep').getRecordTypeId();
        system.debug('test: '+recordList.size());
        for(CampaignMember cmp : recordList){
            TargetNec trg = new TargetNec();
            trg.statoAzione = cmp.campaign.CRM_StatoFormula__c;
            trg.nota = note;
            trg.banca = cmp.Contact.Account.PTF_ABICED__c;
            trg.ndg = cmp.CRM_AccNDG__c;
            recordTypeId = cmp.Campaign.RecordTypeId;
            trg.nomeAzione = cmp.campaign.Name;
            System.debug('recordTypeId: '+recordTypeId);
            if(cmp.Campaign.CRM_OwnerSystem__c=='FSC' && (recordTypeId == recordTypeTopDownMono || recordTypeId == recordTypeTopDownMulti)){
                if(cmp.Campaign.CRM_TipologiaCampagnaStep__c=='Monostep'){
                    trg.motivo = 'Campagna FSC';
                } else if(cmp.Campaign.CRM_TipologiaCampagnaStep__c=='Multistep'){
                    trg.motivo = 'Campagna FSC || || multistep';
                    trg.nomeAzione = cmp.campaign.Name +' ||-|| ';
                }
                
                trg.codiceAzione = 'FSC-'+cmp.Campaign.CRM_Progressivo__c; 
                trg.codiceAzioneUtente = 'FSC-'+cmp.Campaign.CRM_Progressivo__c; 
            }else if(recordTypeId == recordTypeTopDownMono || recordTypeId == recordTypeTopDownMulti){
            	trg.codiceAzione = cmp.Campaign.Codice_Campagna__c; 
                trg.codiceAzioneUtente = cmp.Campaign.Codice_Azione_Utente__c;
                trg.motivo = /*cmp.Motivo_Affinamento__c;'Altra proposta gestionale';*/cmp.Campaign.CRM_SottotipologiaCampagna__c +' '+ String.valueOf(cmp.Campaign.CRM_TipologiaCampagna__c).toLowerCase();
            }else{
                trg.codiceAzione = 'CTB-'+cmp.Campaign.CRM_Progressivo__c; 
                trg.codiceAzioneUtente = 'CTB-'+cmp.Campaign.CRM_Progressivo__c; 
               
                if(cmp.Campaign.CRM_TipologiaCampagnaStep__c=='Monostep'){
                    trg.motivo = 'Campagna trigger based';
                } else if(cmp.Campaign.CRM_TipologiaCampagnaStep__c=='Multistep'){
                    trg.motivo = 'Campagna trigger based || || multistep';
                    trg.nomeAzione = cmp.campaign.Name+' ||-|| ';
                }
                
            }
            /*String dataFine = String.valueOf(cmp.Campaign.CRM_EndDateFormula__c); 
            dataFine = dataFine.replace('-','');
            trg.dataFineAzione = '20220131 23:50:00';*///dataFine+' 00:00:00';//'20221209 00:00:00';
            
            //'APG SIT'
            trg.esito = stato;
            Date dt = Date.today();
            String dateToday = String.valueOf(dt);
            dateToday = dateToday.replace('-','');
            //trg.dataEsitazione = dateToday;//'20220117';
            trg.matricolaAutore = (currentUser.FederationIdentifier!=null ? 'U'+currentUser.FederationIdentifier : 'U0000'); //;
            trg.autore = ((currentUser!=null) ? currentUser.LastName+' '+currentUser.FirstName : '');//cmp.CRM_Assegnatario__r.LastName+cmp.CRM_Assegnatario__r.FirstName;//'Cristian Nicosia';
            if(cmp.Motivo_Affinamento__c!=null && affinamentoMassivo)
            	trg.motivoEliminazione = (mapMotivoCode.containsKey(cmp.Motivo_Affinamento__c) ? mapMotivoCode.get(cmp.Motivo_Affinamento__c):'');
            if(cmp.Motivo_Affinamento__c!=null && !affinamentoMassivo)
            	trg.motivoEliminazione = cmp.Motivo_Affinamento__c;
            if(cmp.CRM_AccMDS__c!=null){
                trg.mds = (mapMMDSCode.containsKey(String.valueOf(cmp.CRM_AccMDS__c).toUpperCase()) ? mapMMDSCode.get(String.valueOf(cmp.CRM_AccMDS__c).toUpperCase()):'');
                trg.descrizioneMds = String.valueOf(cmp.CRM_AccMDS__c).toUpperCase();
            }
            if(listMMDSPOOL.contains(cmp.CRM_AccMDS__c)){
                trg.matricolaReferente =(cmp.CRM_Assegnatario__c!=null ? 'U'+cmp.CRM_Assegnatario__r.FederationIdentifier : '');//'U7617';//cmp.CRM_Assegnatario__r.FederationIdentifier;//'U7617';
            	trg.referente = (cmp.CRM_Assegnatario__c!=null ? cmp.CRM_Assegnatario__r.LastName+' '+cmp.CRM_Assegnatario__r.FirstName : '');
            }else{
                trg.matricolaReferente =(cmp.Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c!=null ? 'U'+cmp.Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c : '');
            	trg.referente = (cmp.Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__c!=null ? cmp.Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName+' '+cmp.Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '');

            }
            
            trg.microportafoglio = cmp.CRM_AccPTF__c;
            if(currentUser.Profile.Name.contains('NEC_'))
            	trg.unitaOrganizzativa = 'Rete';
            else
            	trg.unitaOrganizzativa ='Contact Center';
            targetNecList.add(trg);
            recordTypeId = cmp.Campaign.RecordTypeId;
            tipoCampagna = cmp.Campaign.CRM_OwnerSystem__c;
            
            DateTime dt1 = DateTime.now();
            DateTime dtGMT = DateTime.newInstanceGmt(dt1.date(), dt1.time());
            String dateEsitazione = String.valueOf(dt1);
            if(String.isNotBlank(dateEsitazione)){
                dateEsitazione = dateEsitazione.replace(' ','T');
                trg.dataEsitazione = dateEsitazione;
            }
            
            String dataFine1 = String.valueOf(cmp.Campaign.Data_FineFormula__c);
            if(String.isNotBlank(dataFine1)){
                dataFine1 = dataFine1.replace(' ','T');
                trg.dataFineAzione = dataFine1;
            }
            /*+'T03:00:00';//2022-02-01T00:50:00';//dataFine1;
            trg.dataFineAzione = '2022-11-14T00:59:00';*///';//dataFine1;
            //13/11/2022  23:59:00
            
        }

        ListaTarget lTarget = new ListaTarget();
        lTarget.targetNec = targetNecList;
        Request req = new Request();
        req.listaTarget = lTarget;
        if (isRollback){
			req.tipoEsitazione = 'AFF_RIPRISTINO';            
        }else{
            if(!affinamentoMassivo){
            if(tipoCampagna=='FSC'&& (recordTypeId == recordTypeTopDownMono || recordTypeId == recordTypeTopDownMulti)){
                req.tipoEsitazione = 'CAMP_FSC';
            }else if(recordTypeId == recordTypeTopDownMono || recordTypeId == recordTypeTopDownMulti){
                req.tipoEsitazione = 'CAMP_TOP_DOWN';
            }else {
                req.tipoEsitazione = 'CAMP_TRIGGER_BASED';
            }
        }else {
            req.tipoEsitazione = 'AFF_ELIMINAZIONE';
        }
        }
        
        String body = JSON.serialize(req);
        System.debug(LoggingLevel.DEBUG,'### body: '+body);
        return body;
    }

    public class Request {
        String tipoEsitazione;
        ListaTarget listaTarget;
    }

    public class ListaTarget {
        List<TargetNec> targetNec;
    }

    public class TargetNec {
        String statoAzione;
        String nota;
        String banca;
        String ndg;
        String codiceAzione;
        String codiceAzioneUtente;
        String dataFineAzione;
        String motivo;
        String nomeAzione;
        String esito;
        String dataEsitazione;
        String matricolaAutore;
        String autore;
        String motivoEliminazione;
        String unitaOrganizzativa;
        String mds='';
        String descrizioneMds='';
        String matricolaReferente;
        String referente;
        String microportafoglio;
        String origineAzione;
    }
   /* 
    private static String codifyMDS(String descrizioneMMDS){
        switch on descrizioneMMDS {
            when 'PRIVATE' {
                return '1';
            }	
            when 'FAMILY' {
                return '2';
            }
            when 'CORPORATE' {
                return '3';
            }
            when 'LARGE CORPORATE' {
                return '4';
            }	
            when 'PERSONAL' {
                return '5';
            }
            when 'SMALL BUSINESS' {
                return '6';
            }
            when 'BUSINESS ALTRI' {	
                return '7';
            }	
            when 'CONTROPARTI ISTITUZIONALI' {	
                return '8';
            }
            when 'ASSENTE' {
                return '9';
            }
            when 'RESIDUALE' {
                return '10';
            }	
            when 'LARGE CORPORATE' {	
                return '11';
            }
            when 'CORPORATE' {	
                return '12';
            }
            when 'POE' {
                return '13';
            }	
            when 'CONSULENTI FINANZIARI' {
                return '14';
            }
            when 'KEY CLIENT PRIVATI' {	
                return '15';
            }
            when 'ENTI E TESORERIE' {	
                return '50';
            }	
            when 'NON PORTAFOGLIATI' {	
                return '99';
            }
            when else {		
                return '';
            }
        }
    }*/
    
        /**
    * @description metodo di invocazione del ws
    * @author simone.viglianti@tengroup.it | 10-27-2021 
    * @param apiRequestName 
    * @param campaignMemberList 
    * @param stato 
    * @param note 
    * @param certificationName 
    * @param disableLog 
    * @param ruAsUserId 
    * @return Boolean 
    **/
    public static Boolean makeResponseIngaggioAgente(String apiRequestName, Account accRecord, String stato, String note, String certificationName, Boolean disableLog, String ruAsUserId, Boolean affinamentoMassivo, Boolean isRollback, String motivoEliminazione){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### stato: '+stato);
        System.debug(LoggingLevel.DEBUG,'### note: '+note);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+disableLog);
        System.debug(LoggingLevel.DEBUG,'### accountId: '+accRecord);
        System.debug(LoggingLevel.DEBUG,'### ruAsUserId: '+ruAsUserId);
        System.debug(LoggingLevel.DEBUG,'### affinamentoMassivo: '+affinamentoMassivo);
        System.debug(LoggingLevel.DEBUG,'### isRollback: '+isRollback);

        Boolean esito = false;
        Map<String,String> headersReq= new Map<String,String>();

        userId = !String.isBlank(ruAsUserId) ? ruAsUserId : UserInfo.getUserId();

        WsRestInput restInput =  new WsRestInput(currentUser, null);
        Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);

        //Recuperare dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;

        HttpRequest req = new HttpRequest();

        for(String key: testataMap.keySet()){
            system.debug('Testata '+key+': '+testataMap.get(key) );

            if(testataMap.get(key) != null){
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
            }
        }
		System.debug(LoggingLevel.DEBUG,'### testata: '+testataMap);
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        System.debug('headersReq: '+headersReq);
        if(certificationName != null) req.setClientCertificateName(certificationName);
        String body = getRequestBodyIngaggioAgente(stato,note,accRecord,affinamentoMassivo, isRollback, motivoEliminazione);
        req.setBody(body);

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.toString(); 

        System.debug(LoggingLevel.DEBUG,'### response: '+res);
        System.debug(LoggingLevel.DEBUG,'### response: '+res.getBody());
        System.debug(LoggingLevel.DEBUG,'### responseStatusCode: '+res.getStatusCode());
        if(res.getStatusCode() == 204){
            esito = true;
        }

        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,res.getHeader(s));
        }

        if(disableLog == null){
            
            disableLog = false;
        }
        if(!disableLog){
            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getBody(),
                JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return esito;
    }

    /**
    * @description metodo di costruione del body request
    * @author simone.viglianti@tengroup.it | 10-27-2021 
    * @param stato 
    * @param note 
    * @param recordList 
    * @return String 
    **/
    private static String getRequestBodyIngaggioAgente(String stato, String note,Account accRecord, Boolean affinamentoMassivo, Boolean isRollback, String motivoEliminazione){
        List<TargetNec> targetNecList = new List<TargetNec>();
        Map<String,String> mapMMDSCode = New Map<String,String>{'PRIVATE'=>'1',	'FAMILY'=>'2',	'CORPORATE'=>'3',	'LARGE CORPORATE'=>'4',	'PERSONAL'=>'5',	'SMALL BUSINESS'=>'6',	'BUSINESS ALTRI'=>'7',	'CONTROPARTI ISTITUZIONALI'=>'8',	'ASSENTE'=>'9',	'RESIDUALE'=>'10',	'LARGE CORPORATE'=>'11',	'CORPORATE'=>'12',	'POE'=>'13',	'CONSULENTI FINANZIARI'=>'14',	'KEY CLIENT PRIVATI'=>'15',	'ENTI E TESORERIE'=>'50',	'NON PORTAFOGLIATI'=>'99'};
            List<String> listMMDSPOOL = New List<String>{'Family', 'POE', 'Assente', 'Residuale','Non Portafogliati'};
        Map<String,String> mapMotivoCode = New Map<String,String>{'Profilo non adatto'=>'2','Dati non Aggiornati'=>'3',	'Numerosità elevata'=>'1'};
            String recordTypeId = '';
            String tipoCampagna ='';
        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        String recordTypeTopDownMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Multistep').getRecordTypeId();
        String recordTypeTriggerBasedMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Monostep').getRecordTypeId();
        String recordTypeTriggerBaseMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Multistep').getRecordTypeId();
      	



        TargetNec trg = new TargetNec();
        
        
        trg.banca = accRecord.FinServ__BankNumber__c;
        trg.ndg = accRecord.CRM_NDG__c;
        trg.codiceAzione = 'NO_REL_AZ';
        trg.codiceAzioneUtente = 'NO_REL_AZ';
        trg.motivo = 'Proposta Cessione del Quinto';
        trg.esito = stato;
        trg.nota = note;
        DateTime dt1 = DateTime.now();
        DateTime dtGMT = DateTime.newInstanceGmt(dt1.date(), dt1.time());
        String dateEsitazione = String.valueOf(dt1);
        if(String.isNotBlank(dateEsitazione)){
            dateEsitazione = dateEsitazione.replace(' ','T');
            trg.dataEsitazione = dateEsitazione;
        }
        trg.dataFineAzione = '9999-12-31T00:00:00';
        trg.matricolaAutore = (currentUser.FederationIdentifier!=null ? 'U'+currentUser.FederationIdentifier : 'U0000');
        trg.autore = ((currentUser!=null) ? currentUser.LastName+' '+currentUser.FirstName : '');
        trg.mds = (mapMMDSCode.containsKey(String.valueOf(accRecord.ModelloDiServizio__c).toUpperCase()) ? mapMMDSCode.get(String.valueOf(accRecord.ModelloDiServizio__c).toUpperCase()):'');
        trg.descrizioneMds = String.valueOf(accRecord.ModelloDiServizio__c).toUpperCase();
       	trg.matricolaReferente =(accRecord.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c!=null ? 'U'+accRecord.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c : '');
        trg.referente = (accRecord.PTF_Portafoglio__r.CRM_ReferentePortafoglio__c!=null ? accRecord.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName+' '+accRecord.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName : '');
        trg.microportafoglio = accRecord.PTF_Portafoglio__r.Name;
		trg.motivoEliminazione =motivoEliminazione;

        targetNecList.add(trg);
        
        ListaTarget lTarget = new ListaTarget();
        lTarget.targetNec = targetNecList;
        Request req = new Request();
        req.listaTarget = lTarget;
        req.tipoEsitazione = 'INGAGGIO_AGENTE_REATTIVA';
        String body = JSON.serialize(req);
        System.debug(LoggingLevel.DEBUG,'### body: '+body);
        return body;
    }

}