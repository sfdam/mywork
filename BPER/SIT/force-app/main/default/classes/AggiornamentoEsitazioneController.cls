/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 12-02-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
public with sharing class AggiornamentoEsitazioneController {

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
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }

    /**
    * @description Metodo per effettuare retrieve dei valori di una picklist
    * @author simone.viglianti@tengroup.it | 10-14-2021 
    * @param objApiName 
    * @param fieldName 
    * @return List<Map<String, String>> 
    **/
    @AuraEnabled
    public static List<Map<String,String>> getPickListValues(String objApiName, String fieldName) {
        System.debug(LoggingLevel.DEBUG,'*** START -- getPicklistValues Method ***');
        System.debug(LoggingLevel.DEBUG,'### objName: '+objApiName);
        System.debug(LoggingLevel.DEBUG,'### fieldName: '+fieldName);
        List<Map<String,String>> options = new List<Map<String,String>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String,Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        System.debug(LoggingLevel.DEBUG,'### fieldMap: '+fieldMap);
        List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map<String,String> values = new Map<String,String> {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            options.add(values);
        }
        System.debug(LoggingLevel.DEBUG,'### Options List: '+options);
        System.debug(LoggingLevel.DEBUG,'*** END -- getPicklistValue Method');
        return options;
    }

    /**
    * @description Metodo per recuperare la label di un campo
    * @author simone.viglianti@tengroup.it | 10-14-2021 
    * @param objApiName 
    * @param fieldName 
    * @return String 
    **/
    @AuraEnabled
    public static Map<String,String> getFieldName(String objApiName, String stato, String note){
        System.debug(LoggingLevel.DEBUG,'*** START -- getFieldName Method ***');
        System.debug(LoggingLevel.DEBUG,'### objApiName: '+objApiName);
        System.debug(LoggingLevel.DEBUG,'### stato: '+stato);
        System.debug(LoggingLevel.DEBUG,'### note: '+note);

        String fieldLabelStato = '';
        String fieldLabelNote = '';
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType != null) {
            Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
            Map<String,Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
            System.debug(LoggingLevel.DEBUG,'### fieldMap: '+fieldMap);
            if(fieldMap != null && fieldMap.get(stato) != null && fieldMap.get(note) != null){
                fieldLabelStato = fieldMap.get(stato).getDescribe().getLabel();
                System.debug(LoggingLevel.DEBUG,'### fieldLabelStato: '+fieldLabelStato);
                fieldLabelNote = fieldMap.get(note).getDescribe().getLabel();
                System.debug(LoggingLevel.DEBUG,'### fieldLabelNote: '+fieldLabelNote);
            }
        } 
        Map<String,String> fieldLabelMap = new Map<String,String>();
        fieldLabelMap.put('stato',fieldLabelStato);
        fieldLabelMap.put('note',fieldLabelNote);
        System.debug(LoggingLevel.DEBUG,'### fieldLabelMap: '+fieldLabelMap);
        System.debug(LoggingLevel.DEBUG,'*** END -- getFieldName Method ***');  
        return fieldLabelMap;
    }

    /**
    * @description metodo per update sull'esitazione e invocazione al ws
    * @author simone.viglianti@tengroup.it | 10-14-2021 
    * @param recordId 
    * @param stato 
    * @param note 
    * @param selectedOption 
    * @param noteValue 
    * @param oggetto 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean updateRecord(String recordId, String stato, String note, String selectedOption, String noteValue, String oggetto, String apiRequestName, String certificationName, Boolean disableLog, String runAsUserId, String jsonParam){
        System.debug(LoggingLevel.DEBUG,'*** START -- updateRecord Method');
        System.debug(LoggingLevel.DEBUG,'### recordId: '+recordId);
        System.debug(LoggingLevel.DEBUG,'### object: '+oggetto);
        System.debug(LoggingLevel.DEBUG,'### stato: '+stato);
        System.debug(LoggingLevel.DEBUG,'### selectedOption: '+selectedOption);
        System.debug(LoggingLevel.DEBUG,'### note: '+note);
        System.debug(LoggingLevel.DEBUG,'### noteValue: '+noteValue);
        System.debug(LoggingLevel.DEBUG,'### jsonParam: '+jsonParam);

        Boolean esito = false;
        try{
            Map<String,String> fieldMap = (Map<String,String>)JSON.deserialize(jsonParam, Map<String,String>.class);
            System.debug(LoggingLevel.DEBUG,'### fieldMap: '+fieldMap);
            String params = '';
            for(String key : fieldMap.keySet()){
                String param = fieldMap.get(key);
                if(param != null && !String.isBlank(param)){
                    params = params+param+',';
                }
            }
            params = params.removeEnd(',');
            String query = '';
            if(oggetto.equals('CampaignMember')){
                query = 'SELECT Id,'+String.escapeSingleQuotes(params)+',CRM_CampaignRecordType__c FROM CampaignMember WHERE Id =: recordId';
            }else if(oggetto.equals('Opportunity')){
                query = 'SELECT Id,'+String.escapeSingleQuotes(params)+',CRM_Oggetto__c,CRM_CategoriaProdotto__c,CRM_Bisogno__c FROM Opportunity WHERE Id =: recordId';
            }else {
                query = 'SELECT Id,'+String.escapeSingleQuotes(params)+' FROM '+String.escapeSingleQuotes(oggetto)+' WHERE Id =: recordId';
            }
            System.debug(LoggingLevel.DEBUG,'#### query: '+query);
            List<SObject> recordList = Database.query(query);
            System.debug(LoggingLevel.DEBUG,'### recordList: '+recordList);

            List<SObject> toUpdate;
            Boolean esitoWS = makeRequest(apiRequestName, selectedOption, noteValue, certificationName, disableLog, runAsUserId,recordList,fieldMap,oggetto);
            if(!recordList.isEmpty() && esitoWS){
                toUpdate = (List<sObject>)Type.forName('List<'+oggetto+'>').newInstance();
                for(SObject obj : recordList){
                    obj = (sObject)Type.forName(oggetto).newInstance();
                    obj.put('Id',recordId);
                    if(selectedOption != null){
                        obj.put(stato,selectedOption);
                    }
                    if(noteValue != null){
                        obj.put(note,noteValue);
                    }
                    toUpdate.add(obj);
                }
                System.debug(LoggingLevel.DEBUG,'### updateList: '+toUpdate);
                if(selectedOption != null || noteValue != null){
                    update toUpdate;
                    esito = true;
                }
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'AggiornamentoEsitazioneController exception: ' + e.getMessage()+' al line: '+e.getLineNumber());
            return false;
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- updateRecord Method');
        return esito;
    }

    /**
    * @description metodo di invocazione del ws
    * @author simone.viglianti@tengroup.it | 10-22-2021 
    * @param apiRequestName 
    * @param stato 
    * @param note 
    * @param certificationName 
    * @param disableLog 
    * @return Boolean 
    **/
    public static Boolean makeRequest(String apiRequestName, String stato, String note, String certificationName, Boolean disableLog, String runAsUserId, List<sObject> recordList,Map<String,String> fieldMap, String oggetto){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### stato: '+stato);
        System.debug(LoggingLevel.DEBUG,'### note: '+note);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+disableLog);
        System.debug(LoggingLevel.DEBUG,'### recordList: '+recordList);
        System.debug(LoggingLevel.DEBUG,'### fieldMap: '+fieldMap);
        Boolean esito = false;
        Map<String,String> headersReq= new Map<String,String>();
        userId = !String.isBlank(runAsUserId) ? runAsUserId : UserInfo.getUserId();

        WsRestInput restInput = new WsRestInput(currentUser, null);
        Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
        //Map<String, String> securityMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.bindingInfo), Map<String, String>.class);

        //Recuperare dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;
       
        HttpRequest req = new HttpRequest();

        for(String key: testataMap.keySet()){

            if(testataMap.get(key) != null){
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
            }
        }
        
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        if(certificationName != null) req.setClientCertificateName(certificationName);
        String body = getRequestBody(stato,note,recordList,fieldMap,oggetto);
        req.setBody(body);

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.toString();
        //Ma<String,Object> respo = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        System.debug(LoggingLevel.DEBUG,'### response: '+res.toString());
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
                res.getStatus(),
                JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
                headersReq,
                headersRes,
                endpoint,
                ''
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return esito;
    }

    /**
    * @description Wrapper body request
    * @author simone.viglianti@tengroup.it | 10-27-2021 
    * @param stato 
    * @param note 
    * @param recordList 
    * @param fieldMap 
    * @param oggetto 
    * @return String 
    **/
    private static String getRequestBody(String stato, String note,List<sObject> recordList,Map<String,String> fieldMap,String oggetto){
        List<TargetNec> targetNecList = new List<TargetNec>();
        String recordTypeId = '';
        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        String recordTypeTopDownMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Multistep').getRecordTypeId();
        String recordTypeTriggerBasedMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Monostep').getRecordTypeId();
        String recordTypeTriggerBaseMulti = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Trigger - Multistep').getRecordTypeId();
        
        for(sObject obj : recordList){
            TargetNec targetNec = new TargetNec();
            for(String key : fieldMap.keySet()){
                if(key.equals('statoAzione')){
                    targetNec.statoAzione = stato;
                }
                if(key.equals('nota')){
                    targetNec.nota = note;
                }
                if(key.equals('banca')){
                    String value = fieldMap.get(key);
                    targetNec.banca = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('ndg')){
                    String value = fieldMap.get(key);
                    targetNec.ndg = !String.isBlank(value) ?String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('codiceAzione')){
                    String value = fieldMap.get(key);
                    targetNec.codiceAzione = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('codiceAzioneUtente')){
                    String value = fieldMap.get(key);
                    targetNec.codiceAzioneUtente = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('dataFineAzione')){
                    String value = fieldMap.get(key);
                    String dataFine = String.valueOf(obj.get(value));
                    dataFine = dataFine.replace(' ','T');
                    targetNec.dataFineAzione = dataFine;
                }
                if(key.equals('motivo')){
                    String value = fieldMap.get(key);
                    targetNec.motivo = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('nomeAzione')){
                    String value = fieldMap.get(key);
                    if(oggetto.equals('Opportunity')){
                        String motivo = fieldMap.get('motivo');
                        String motivoVal = String.valueOf(obj.get(motivo));
                        if(motivoVal.containsIgnoreCase('Self') || motivoVal.containsIgnoreCase('Checkup')){
                            targetNec.nomeAzione = String.valueOf(obj.get('CRM_Oggetto__c'))+' - '+String.valueOf(obj.get('CRM_Bisogno__c'));
                        }else{
                            targetNec.nomeAzione = String.valueOf(obj.get('CRM_CategoriaProdotto__c'))+' - '+String.valueOf(obj.get('CRM_Bisogno__c'));
                        }
                    }else{
                        targetNec.nomeAzione = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                    } 
                }
                if(key.equals('esito')){
                    String value = fieldMap.get(key);
                    targetNec.esito = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('matricolaAutore')){
                    String value = fieldMap.get(key);
                    targetNec.matricolaAutore = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('matricolaReferente')){
                    String value = fieldMap.get(key);
                    targetNec.matricolaReferente = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('autore')){
                    String value = fieldMap.get(key);
                    targetNec.autore = !String.isBlank(value)  ? String.valueOf(obj.get(value)) : '""';
                }
                if(key.equals('referente')){
                    String value = fieldMap.get(key);
                    targetNec.referente = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '""';
                }
                if(key.equals('motivoEliminazione')){
                    String value = fieldMap.get(key);
                    targetNec.motivoEliminazione = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('unitaOrganizzativa')){
                    String value = fieldMap.get(key);
                    targetNec.unitaOrganizzativa = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('mds')){
                    String value = fieldMap.get(key);
                    targetNec.mds = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('descrizioneMds')){
                    String value = fieldMap.get(key);
                    targetNec.descrizioneMds = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('microportafoglio')){
                    String value = fieldMap.get(key);
                    targetNec.microportafoglio = !String.isBlank(value) ? String.valueOf(obj.get(value)) : '';
                }
                if(key.equals('origineAzione')){
                    String value = fieldMap.get(key);
                    targetNec.origineAzione = !String.isBlank(value) ? String.valueOf(obj.get(value)) : 'Test';
                }
                DateTime dt = DateTime.now();
                DateTime dtGMT = DateTime.newInstanceGmt(dt.date(), dt.time());
                String dateEsitazione = String.valueOf(dt);
                dateEsitazione = dateEsitazione.replace(' ','T');
                targetNec.dataEsitazione = dateEsitazione;
            }
            if(oggetto.equals('CampaignMember')){
                recordTypeId = String.valueOf(obj.get('CRM_CampaignRecordType__c'));
            }
            targetNecList.add(targetNec);
        }
       
        ListaTarget lTarget = new ListaTarget();
        lTarget.targetNec = targetNecList;
        Request req = new Request();
        req.listaTarget = lTarget;
        if(recordTypeId == 'Top_Down_Monostep' || recordTypeId == 'Top_Down_Multistep'){
            req.tipoEsitazione = 'CAMP_TOP_DOWN';
        }else if(recordTypeId == 'Trigger_Monostep' || recordTypeId == 'Trigger_Multistep'){
            req.tipoEsitazione = 'CAMP_TRIGGER_BASED';
        }else{
            req.tipoEsitazione = 'OPPORTUNITA';
        }
        
        String jsonSerialize = JSON.serialize(req);
        System.debug(LoggingLevel.DEBUG,'### Body: '+jsonSerialize);
        return jsonSerialize;
    }

    public class Request {
        String tipoEsitazione = 'OPPORTUNITA';
        ListaTarget listaTarget;
    }

    public class ListaTarget {
        List<TargetNec> targetNec;
    }

    public class TargetNec {
        String statoAzione = 'In corso';
        String nota = '';
        String banca = '05387';
        String ndg = '21503685';
        String codiceAzione = 'OPP-0000009156';
        String codiceAzioneUtente = 'OPP-0000009156';
        String dataFineAzione = '';
        String motivo = 'Opportunità Self';
        String nomeAzione = 'Opportunità vendita - Assicurativo';
        String esito = 'Da contattare';
        String dataEsitazione = '';
        String matricolaAutore = 'U63067';
        String autore = 'Morellato Luca';
        String motivoEliminazione = '';
        String unitaOrganizzativa = 'Rete';
        String mds = '6';
        String descrizioneMds = 'SMALL BUSINESS';
        String matricolaReferente = 'U63067';
        String referente = 'Morellato Luca';
        String microportafoglio = 'PTF-BP-05387-0459-000100';
        String origineAzione = 'Self';
    }
}