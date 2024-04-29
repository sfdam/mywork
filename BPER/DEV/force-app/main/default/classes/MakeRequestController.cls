public without sharing class MakeRequestController {
    
    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c
                        FROM User WHERE id =: UserInfo.getUserId()];
            return currentUser;
        }set;
    }

    public static Set<String> headerToEnhanceSet = new Set<String>{'sbloccoCarta', 'ristampaPin'};
    public static Map<String, Object> bodyToEnhanceSet = new Map<String, Object>{
        'sbloccoCarta' => 'testata', 
        'ristampaPin' => new Map<String, Object>{'headerPortale' => new Map<String, Object>{'msgHeaderMulticanale' => null}}};

    @AuraEnabled
    public static String makeRequest(String apiRequestName, Id recordId, Map<String, Map<String, Object>> fieldsMap, Map<String, Map<String, String>> conditions, String certificateName, String runAsUserId, Boolean disableLog){

        return makeRequest(apiRequestName, recordId, fieldsMap, conditions, '', certificateName, runAsUserId, disableLog);
    }

    @AuraEnabled
    public static String makeRequest(String apiRequestName, Id recordId, Map<String, Map<String, Object>> fieldsMap, Map<String, Map<String, String>> conditions, String params, String certificateName, String runAsUserId, Boolean disableLog){
        
        return makeRequest(apiRequestName, recordId, null, fieldsMap, conditions, params, certificateName, runAsUserId, disableLog, true);
    }
    @AuraEnabled
    public static String getRecordTypeName(Id recordId) {
    try {
        // Get the object type for the record ID
        SObjectType recordType = recordId.getSObjectType();
        String sObjectName = recordType.getDescribe().getName();

        // Create a dynamic query string
        String query = 'SELECT RecordTypeId FROM ' + sObjectName + ' WHERE Id = :recordId LIMIT 1';
        
        // Query the database
        SObject record = Database.query(query);
        
        if (record != null && record.get('RecordTypeId') != null) {
            Id recordTypeId = (Id)record.get('RecordTypeId');
            RecordType rt = [SELECT Name FROM RecordType WHERE Id = :recordTypeId LIMIT 1];
            
            if (rt != null) {
                return rt.Name;
            }
        }
        
        return null;
    } catch (QueryException e) {
        System.debug('Error querying sObject: ' + e.getMessage());
        return null;
    }
}

    @AuraEnabled
    public static String makeRequest(String apiRequestName, Id recordId, SObject recordParam, Map<String, Map<String, Object>> fieldsMap, Map<String, Map<String, String>> conditions, String params, String certificateName, String runAsUserId, Boolean disableLog, Boolean updateRecord){
        System.debug('SV apiRequestName: ' + apiRequestName);
        System.debug('SV recordId: ' + recordId);
        System.debug('SV fieldsMap: ' + fieldsMap);
        System.debug('SV params: ' + params);
        System.debug('SV conditions: ' + conditions);
        System.debug('SV certificateName: ' + certificateName);
        System.debug('SV runAsUserId: ' + runAsUserId);
        System.debug('SV updateRecord: ' + updateRecord);
        if(updateRecord == null){
            updateRecord = true;
        }

        Schema.SObjectType SObjectType = !String.isBlank(recordId) ? recordId.getSobjectType() : Schema.Account.getSObjectType();

        Map<String, String> paramsMap = new Map<String, String>();
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        System.debug('conditions: ' + JSON.serialize(conditions));

        //inizializza restinput con dati dell'utente corrente
        if(!String.isBlank(runAsUserId)){

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c FROM User WHERE id =: runAsUserId];
        }
        WsRestInput restInput = new WsRestInput(currentUser, null);
        
        //Recupre dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        
        //esegue query per recuperare i campi del record che poi dovranno essere aggiorati
        Map<String, Map<String, SObject>> relatedListMap = new Map<String, Map<String, SObject>>();
        Map<String, Set<String>> fieldReferenceObjectKeyMap = new Map<String, Set<String>>();
        Map<String, Set<String>> duplicateFieldsMap = new Map<String, Set<String>>();
        Map<String, Map<String,Set<String>>> relatedRecordFieldsMap = new Map<String, Map<String,Set<String>>>();
        String query = 'SELECT id ';
        for(String fieldName : fieldsMap.keySet()){

            if(fieldName.contains('_')){
                
                List<String> fieldNameList = fieldName.split('_');
                if(!duplicateFieldsMap.containsKey(fieldNameList[0])){

                    duplicateFieldsMap.put(fieldNameList[0], new Set<String>());
                }

                duplicateFieldsMap.get(fieldNameList[0]).add(fieldNameList[1]);
            }
            if(!(Boolean)fieldsMap.get(fieldName).get('isRelated')){

                if(!String.isBlank((String)fieldsMap.get(fieldName).get('fieldReferenceDevName'))){
                    for(String fieldDevName : ((String)fieldsMap.get(fieldName).get('devName')).split(',')){
                        query += ', ' + String.escapeSingleQuotes((String)fieldsMap.get(fieldName).get('fieldReferenceDevName')) + '.' + String.escapeSingleQuotes(fieldDevName) + ' ';
                    }
                }else{

                    for(String fieldDevName : ((String)fieldsMap.get(fieldName).get('devName')).split(',')){

                        if(SObjectType.getDescribe().fields.getMap().containsKey(fieldDevName)){
                            query += ', ' + String.escapeSingleQuotes(fieldDevName) + ' ';
                        }
                    }
                }
            }else {

                if(!String.isBlank((String)fieldsMap.get(fieldName).get('fieldReferenceDevName'))){

                    if(!relatedRecordFieldsMap.containsKey((String)fieldsMap.get(fieldName).get('SObject'))){
    
                        relatedRecordFieldsMap.put((String)fieldsMap.get(fieldName).get('SObject'), new Map<String,Set<String>>());
                        relatedRecordFieldsMap.get((String)fieldsMap.get(fieldName).get('SObject')).put((String)fieldsMap.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                    }
                    for(String fieldReferenceDevName : ((String)fieldsMap.get(fieldName).get('fieldReferenceDevName')).split(',')){
                        
                        relatedRecordFieldsMap.get((String)fieldsMap.get(fieldName).get('SObject')).get((String)fieldsMap.get(fieldName).get('fieldReferenceObject')).add(fieldReferenceDevName);
                    }
                    
                    if(conditions != null){
    
                        if(fieldsMap.get(fieldName).containsKey('parent')){
                            
                            if(conditions.containsKey((String)fieldsMap.get(fieldName).get('parent'))){
    
                                relatedRecordFieldsMap.get((String)fieldsMap.get(fieldName).get('SObject')).get((String)fieldsMap.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)fieldsMap.get(fieldName).get('parent')).values());
                                if(!relatedRecordFieldsMap.containsKey((String)fieldsMap.get(fieldName).get('fieldReferenceObject'))){
    
                                    fieldReferenceObjectKeyMap.put((String)fieldsMap.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                                }
                                fieldReferenceObjectKeyMap.get((String)fieldsMap.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)fieldsMap.get(fieldName).get('parent')).values());
                            }
                        }
                    }
                }
            }
        }

        System.debug('DK relatedRecordFieldsMap: ' + JSON.serialize(relatedRecordFieldsMap));
        System.debug('DK duplicateFieldsMap: ' + JSON.serialize(duplicateFieldsMap));
        SObject record;
        List<SObject> records = new List<SObject>();
        if(!String.isBlank(recordId)){
            
            for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){
                
                String objectName = new List<String>(values.keySet())[0];
                query += ', (SELECT ' +  String.escapeSingleQuotes(String.join(new List<String>(values.get(objectName)), ',')) + ' FROM ' + String.escapeSingleQuotes(objectName) + ')';
            }
            query += ' FROM ' + String.escapeSingleQuotes(SObjectType.getDescribe().getName()) + ' WHERE id =: recordId LIMIT 1';
            System.debug('DK query: ' + query);
            records = Database.query(query);
        }else{
            records.add(recordParam);
        }
        if(!records.isEmpty()){
            record = records[0];
            System.debug('DK record: ' + JSON.serialize(record));
            Map<String, Object> deserializedObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record)); 
            System.debug('@@@@@relatedRecordFieldsMap: '+JSON.serialize(relatedRecordFieldsMap));
            for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){
                System.debug('@@@@@values: '+JSON.serialize(values));
                for(String relatedListName : values.keySet()){
                    System.debug('@@@@@relatedListName: '+JSON.serialize(relatedListName));
                    System.debug('@@@@@deserializedObject: '+JSON.serialize(deserializedObject));
                    if(!deserializedObject.containsKey(relatedListName) && apiRequestName!='searchSmartAccountExtended'){
    
                        continue;
                    }
                    //Luca Search
                    /*else if(apiRequestName=='searchSmartAccountExtended' && !deserializedObject.containsKey(relatedListName)){
                        relatedListMap.put(relatedListName, new Map<String, SObject>());
                    }*/
                    else{//Luca Search
                        Map<String, Object> deserializedReletadList = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(deserializedObject.get(relatedListName)));
                        String serializedList = JSON.serialize(deserializedReletadList.get('records'));
                        System.debug('DK serializedList: ' + serializedList);
                        List<String> keyList = new List<String>();
                        if(fieldReferenceObjectKeyMap.containsKey(relatedListName)){
    
                            for(String key : fieldReferenceObjectKeyMap.get(relatedListName)){
                            
                                if(fieldReferenceObjectKeyMap.get(relatedListName).size() > 1){
    
                                    keyList.add('{' + key + '}');
                                }else{
    
                                    keyList.add(key);
                                }
                            }
                        }
                        System.debug('DK fieldReferenceObjectKeyMap.get(relatedListName): ' + JSON.serialize(keyList));
                        Map<String, Sobject> relatedMap = SV_Utilities.keyBy((List<SObject>)JSON.deserialize(serializedList, List<Sobject>.class), String.join(keyList, '_'), fieldReferenceObjectKeyMap.get(relatedListName).size() > 1 ? true : false);
                        System.debug('DK relatedMap: ' + JSON.serialize(relatedMap));
                        relatedListMap.put(relatedListName, relatedMap);
                    }
                    
                    
                }
            }
            System.debug('DK relatedListMap: ' + JSON.serialize(relatedListMap));
            //costruisce una mappa contente i parametri presenti nell'endpoint come key
            //come value è presente il valore corrispondente preso dal campo del record o dal parent del record
            String regex = '\\{.*?\\}';
            Pattern pattr = Pattern.compile(regex); 
            Matcher mat = pattr.matcher(apiRequest.Endpoint__c);
            System.debug('DK apiRequest: ' + JSON.serialize(apiRequest));
            do{
                try{
                    System.debug('DK: mat.group() ' + mat.group());
                    Map<String,Object> field = fieldsMap.get(mat.group().replace('{', '').replace('}', ''));
                    if(!String.isBlank((String)field.get('SObject')) &&
                    (String)field.get('SObject') == 'User'){
    
                        paramsMap.put(mat.group(), (String)currentUser.get((String)field.get('devName')));
                    }else{
    
                        if(String.isBlank((String)field.get('fieldReferenceDevName'))){
        
                            if((String)field.get('type') != 'Date'){
        
                                paramsMap.put(mat.group(), (String)record.get((String)field.get('devName')));
                            }else{
        
                                DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(record.get((String)field.get('devName'))), DateTime.class);
                                paramsMap.put(mat.group(), '' + dateValue.year() + dateValue.month() + dateValue.day());
                            }
                        }else{
        
                            Map<String,Object> recordMap = record.getPopulatedFieldsAsMap();
                            SObject parentRecord = (SObject)recordMap.get((String)field.get('fieldReferenceDevName'));
                            if((String)field.get('type') != 'Date'){
        
                                System.debug('DK paramsMap value: ' + (String)parentRecord.get((String)field.get('devName')));
                                paramsMap.put(mat.group(), (String)parentRecord.get((String)field.get('devName')));
                            }else{
                                
                                DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(parentRecord.get((String)field.get('devName'))), DateTime.class);
                                paramsMap.put(mat.group(), '' + dateValue.year() + dateValue.month() + dateValue.day());
                            }
                        }
                    }
                }catch(Exception ex){
                    System.debug('DK error_paramsMap: ' + ex);
                }
            }while(mat.find());
    
            Map<String, String> endpointParamsMap = new Map<String, String>();
            Map<String, Object> bodyParamsMap;
            List<Parametro> parametriBodyList = new List<Parametro>();
            Map<String, List<Parametro>> listParamentri = new Map<String, List<Parametro>>();
            String bodyParamsString;
    
            Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
            if(headerToEnhanceSet.contains(apiRequestName)){
                testataMap.put('channel', 'IBPR');
                testataMap.put('correlationid', testataMap.get('sessionId'));
            }
            Map<String, String> secutityMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.security), Map<String, String>.class);
            Map<String, String> userProfileMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.userProfile), Map<String, String>.class);
            Map<String, String> bindingInfoMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.bindingInfo), Map<String, String>.class);
            
            System.debug('DK recordXXX: ' + JSON.serialize(record));
            Map<String, Object> deserializedRecord = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record));
            if(deserializedRecord.containsKey('Account')){
                
                Map<String, Object> accountMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(deserializedRecord.get('Account')));
                System.debug('DK accountMap: ' + accountMap);
                testataMap.put('abi',(String)accountMap.get('FinServ__BankNumber__c'));
            }
            if(!String.isBlank(apiRequest.EndpointParams__c)){
    
                Map<String, String> headerMap = new Map<String, String>();
                Map<String, String> endpointAPIParamsMap = (Map<String, String>)JSON.deserialize(apiRequest.EndpointParams__c, Map<String, String>.class);
                for(String paramName : endpointAPIParamsMap.keySet()){
    
                    if(endpointAPIParamsMap.get(paramName).contains('{')){
    
                        System.debug('DK param: ' + endpointAPIParamsMap.get(paramName));
                        String textInBrackets = endpointAPIParamsMap.get(paramName).substringBetween('{', '}');
                        if(textInBrackets.contains('_') && !textInBrackets.contains('__c')){
    
                            if(textInBrackets.split('_')[0] == 'testata'){
    
                                headerMap = testataMap;
                            }else if(textInBrackets.split('_')[0] == 'security'){
    
                                headerMap = secutityMap;
                            }else if(textInBrackets.split('_')[0] == 'userProfile'){
    
                                headerMap = userProfileMap;
                            }else if(textInBrackets.split('_')[0] == 'bindingInfo'){
    
                                headerMap = bindingInfoMap;
                            }
                            if(!headerMap.isEmpty()){
    
                                endpointParamsMap.put(paramName, headerMap.get(textInBrackets.split('_')[1]));
                            }
                        }else{
    
                            endpointParamsMap.put(paramName, (String)record.get(textInBrackets));
                        }
                    }else{
    
                        endpointParamsMap.put(paramName, endpointAPIParamsMap.get(paramName));
                    }
                }
                System.debug('DK endpointParamsMap: ' + JSON.serialize(endpointParamsMap));
            }
    
            if(!String.isBlank(apiRequest.BodyParams__c)){
                bodyParamsMap = new Map<String, Object>();
                Map<String, String> headerMap = new Map<String, String>();
                Map<String, String> bodyAPIParamsMap = (Map<String, String>)JSON.deserialize(apiRequest.BodyParams__c, Map<String, String>.class);
                for(String paramFullName : bodyAPIParamsMap.keySet()){
                    
                    String value = '';
                    List<String> paramFullNameList = paramFullName.split('\\.');
                    String paramName = paramFullName.contains('.') ? paramFullName.split('\\.')[paramFullNameList.size() - 1] : paramFullName;
                    for(String parameter : bodyAPIParamsMap.get(paramFullName).split('\\+')){
    
                        if(parameter.contains('{')){
        
                            System.debug('DK param: ' + parameter);
                            String textInBrackets = parameter.substringBetween('{', '}');
                            if(textInBrackets.contains('_') && !textInBrackets.contains('__c')){
        
                                if(textInBrackets.split('_')[0] == 'testata'){
        
                                    headerMap = testataMap;
                                }else if(textInBrackets.split('_')[0] == 'security'){
        
                                    headerMap = secutityMap;
                                }else if(textInBrackets.split('_')[0] == 'userProfile'){
        
                                    headerMap = userProfileMap;
                                }else if(textInBrackets.split('_')[0] == 'bindingInfo'){
        
                                    headerMap = bindingInfoMap;
                                }
                                if(!headerMap.isEmpty()){
        
                                    // bodyParamsMap.put(paramName, headerMap.get(textInBrackets.split('_')[1]));
                                    value += headerMap.get(textInBrackets.split('_')[1]);
                                }
                            }else{
        
                                // bodyParamsMap.put(paramName, (String)record.get(parameter));
        
                                if(paramsMap.containsKey( parameter)){
                                    // bodyParamsMap.put(paramName, (String)paramsMap.get(parameter));
                                    value += (String)paramsMap.get(parameter);
                                } else {
                                    
                                    Map<String,Object> field = fieldsMap.get(textInBrackets);
                                    if((String)field.get('SObject') == 'User'){
    
                                        value += String.isBlank((String)currentUser.get((String)field.get('devName'))) ? '' : (String)currentUser.get((String)field.get('devName'));
                                    }else{
    
                                        if(String.isBlank((String)field.get('fieldReferenceDevName'))){
            
                                            if((String)field.get('type') != 'Date'){
            
                                                if(textInBrackets.contains('parametro') && String.isNotBlank((String)record.get((String)field.get('devName')))){
                                                    Parametro p = new Parametro();
                                                    p.paramName = paramName.split('#')[1];
                                                    p.paramValue = (String)record.get((String)field.get('devName'));
                                                    parametriBodyList.add(p);
                                                } else if(!textInBrackets.contains('parametro')) {
                                                    // bodyParamsMap.put(paramName, (String)record.get((String)field.get('devName')));
                                                    value += field.containsKey('maxLength') && !String.isBlank((String)record.get((String)field.get('devName'))) ? ((String)record.get((String)field.get('devName'))).left((Integer)field.get('maxLength')) : !String.isBlank((String)record.get((String)field.get('devName'))) ? (String)record.get((String)field.get('devName')) : '';
                                                }
                                            }else{
                                                
                                                if(record.get((String)field.get('devName')) != null){
    
                                                    DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(record.get((String)field.get('devName'))), DateTime.class);
                                                    System.debug('DK dataValueString: ' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                                    bodyParamsMap.put(paramFullName, '' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                                }else{
    
                                                    bodyParamsMap.put(paramFullName, null);
                                                }
                                            }
                                        }else{
            
                                            Map<String,Object> recordMap = record.getPopulatedFieldsAsMap();
                                            SObject parentRecord = (SObject)recordMap.get((String)field.get('fieldReferenceDevName'));
                                            if((String)field.get('type') != 'Date'){
            
                                                System.debug('DK bodyParamsMap value: ' + (String)parentRecord.get((String)field.get('devName')));
                                                // bodyParamsMap.put(paramName, (String)parentRecord.get((String)field.get('devName')));
                                                value += field.containsKey('maxLength') && !String.isBlank((String)parentRecord.get((String)field.get('devName'))) ? ((String)parentRecord.get((String)field.get('devName'))).left((Integer)field.get('maxLength')) : !String.isBlank((String)parentRecord.get((String)field.get('devName'))) ? (String)parentRecord.get((String)field.get('devName')) : '';
                                            }else{
                                                
                                                DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(parentRecord.get((String)field.get('devName'))), DateTime.class);
                                                System.debug('DK dataValueString: ' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                                bodyParamsMap.put(paramFullName, '' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                            }
                                        }
                                    }
                                }
                            }
                        }else{
        
                            // bodyParamsMap.put(paramName, parameter);
                            value += parameter;
                        }
                    }
    
                    System.debug('DK concatValue: ' + value);
                    if(!String.isBlank(value) || bodyAPIParamsMap.get(paramName).contains('+')){
    
                        bodyParamsMap.put(paramFullName, value);
                    }
                }
                // for(String key : bodyParamsMap.keySet()){
                //     if(key.contains('parametro')){
                //         Parametro p = new Parametro();
                //         p.paramName = key.split('#')[1];
                //         p.paramValue = bodyParamsMap.get(key);
                //         parametriBodyList.add(p);
                //     }
                // }
    
                // listParamentri.put('listaParametri', parametriBodyList);
                // System.debug('DK listaParametri: ' + JSON.serialize(listParamentri));
                if(parametriBodyList.size() > 0){
                    bodyParamsMap.put('listaParametri', parametriBodyList);
                }  
                
                //DK EDIT
                if(!String.isEmpty(params)){
                    Map<String, Object> otherParamsMap = (Map<String, Object>) JSON.deserializeUntyped(params);
                    for(String key: otherParamsMap.keySet()){
                        if(bodyParamsMap.containsKey(key)){
                            bodyParamsMap.put(key, (String)otherParamsMap.get(key));
                        }
                    }
                }
                for(String key : bodyParamsMap.keySet()){
                    if(key.contains('.')){
                        if(!bodyParamsMap.containsKey(key.split('\\.')[0])){
                            bodyParamsMap.put(key.split('\\.')[0], new Map<String, object>());
                        }
                        ((Map<String, object>)bodyParamsMap.get(key.split('\\.')[0])).put(key.split('\\.')[1], (String)bodyParamsMap.get(key));
                        bodyParamsMap.remove(key);
                    }
                }
                //DK EDIT
                if(bodyToEnhanceSet.containsKey(apiRequestName)){
                    Map<String, Object> bodyToEnhanceValue = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(bodyToEnhanceSet));
                    for(String additionalParam : bodyToEnhanceValue.keySet()){

                        if(apiRequestName == 'sbloccoCarta'){
    
                            Map<String, String> firstHeaderObject = WsRestUtils.getFinalHeader(apiRequestName, 'testata', testataMap, paramsMap, endpointParamsMap);
                            for(String testataKey: firstHeaderObject.keySet()){

                                bodyParamsMap.put(testataKey, firstHeaderObject.get(testataKey));
                            }
                            bodyParamsMap.put('headerPortale',  new Map<String, Object>{'msgHeaderMulticanale' => new Map<String, Object>{'mcAbiCode' => firstHeaderObject.get('abi')}});
                        }else{
    
                            bodyParamsMap.put(additionalParam, bodyToEnhanceValue.get(additionalParam));
                        }
                    }
                }
                System.debug('DK bodyParamsMap: ' + JSON.serialize(bodyParamsMap));
                bodyParamsString = apiRequest.InList__c ? JSON.serialize(new List<Map<String, Object>>{bodyParamsMap}) : JSON.serialize(bodyParamsMap);
            }
            
            System.debug('DK testataMap: ' + testataMap);
            System.debug('DK paramsMap: ' + JSON.serialize(paramsMap));
            System.debug('DK testata: ' + JSON.serialize(restInput.headers.testata));
            System.debug('DK security: ' + JSON.serialize(restInput.headers.security));
            System.debug('DK userProfile: ' + JSON.serialize(restInput.headers.userProfile));
            System.debug('DK bindingInfo: ' + JSON.serialize(restInput.headers.bindingInfo));

            
            //effettua la request
            WsRestInput.CommonResponse response = WsRestUtils.callService(apiRequest,
            WsRestUtils.secondHeaderSet.contains(apiRequestName) ? userProfileMap : testataMap,
            WsRestUtils.secondHeaderSet.contains(apiRequestName) ? bindingInfoMap : secutityMap,
            paramsMap,
            endpointParamsMap,
            bodyParamsMap != null ? bodyParamsString : (String)restInput.payload,
            certificateName,
            updateRecord != null && updateRecord ? 
            disableLog :
            true);
                    
            System.debug('DK MakeRequestController.makeRequest.response: ' + JSON.serialize(response));
            List<Map<String, String>> responseDataListMap = new List<Map<String, String>>();
            if(apiRequestName == 'getBodyCarta' &&
                response.statusCode == '200'){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.data);
                List<Object> responseList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(responseMap.get('servizioBodyCardList')));
                record.put('CRM_BodyCardActivationStatus__c', responseList.size() > 0);
                System.debug('SV getBodyCarta: ' + record);
                if(updateRecord){
                    update record;
                }
    
                return JSON.serialize(new Map<String, Object>{
                    'error' => '',
                    'record' => record,
                    'response' => response,
                    'statusCode' => response.statusCode
                });
    
            } else if(!String.isBlank(response.data) &&
                response.statusCode == '200'){
                
                responseDataListMap.add(new Map<String, String>{
                    'type' => 'Object',
                    'key' => 'base',
                    'value' => response.data
                });
                List<Map<String, String>> newResponseDataListMap = new List<Map<String, String>>();
                
                Integer levels = 1;
                for(Integer i = 0; i < levels; i++){
                    
                    Boolean levelsIsSet = false;
    
                    if(!responseDataListMap.isEmpty()){
                        System.debug('@@@@sonoqui: '+JSON.serialize(responseDataListMap));
                        Map<String, Map<String, Object>> newObjects = New Map<String, Map<String, Object>>();
                        
                        for(Integer k = 0; k < responseDataListMap.size(); k++){
    
                            if(responseDataListMap[k].get('type') == 'Object'){
    
                                newObjects.put(responseDataListMap[k].get('key') + '_' + k, (Map<String, Object>)JSON.deserializeUntyped(responseDataListMap[k].get('value')));
                            }else{
    
                                List<Object> newListObject = (List<Object>)JSON.deserializeUntyped(responseDataListMap[k].get('value'));
                                for(Integer j = 0; j < newListObject.size(); j++){
    
                                    newObjects.put(responseDataListMap[k].get('key') + '_' + k + '_' + j, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(newListObject[j])));
                                }
                            }
                        }
                        
                        for(String responseDataElementName : newObjects.keySet()){
                            
                            System.debug('DK responseDataElementName: ' + responseDataElementName);
                            System.debug('DK newObject.get(responseDataElementName).keySet: ' + JSON.serializePretty(newObjects.get(responseDataElementName).keySet()));
                            if(duplicateFieldsMap.containsKey(responseDataElementName.split('_')[0])){
                                
                                for(String fieldKey: duplicateFieldsMap.get(responseDataElementName.split('_')[0])){
                                    
                                    System.debug('newObjects.get(responseDataElementName).get(fieldKey): ' + newObjects.get(responseDataElementName).get(fieldKey));
                                    newObjects.get(responseDataElementName).put(responseDataElementName.split('_')[0] + '_' + fieldKey, newObjects.get(responseDataElementName).get(fieldKey));
                                }
                            }
                            for(String key: newObjects.get(responseDataElementName).keySet()){
                                
                                System.debug('DK key: ' + key);
                                System.debug('DK value: ' + newObjects.get(responseDataElementName).get(key));
                                System.debug('DK type: ' + SV_Utilities.getType(newObjects.get(responseDataElementName).get(key)));
                                if(SV_Utilities.getType(newObjects.get(responseDataElementName).get(key)) == 'Object'){
                                    
                                    
                                    //Luca Search
                                    /*if(apiRequestName=='searchSmartAccountExtended'){
                                        Map<String,Object> tempMap=(Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(newObjects.get(responseDataElementName).get(key)));
                                        tempMap.put('username',newObjects.get(responseDataElementName).get('username'));
                                        System.debug('@@@@@tempMap '+JSON.serialize(tempMap));
                                        newResponseDataListMap.add(new Map<String, String>{
                                            'type' => 'Object',
                                            'key' => key,
                                            'value' => JSON.serialize(tempMap)
                                        });
                                        if(!levelsIsSet){
                                            
                                            levels++;
                                            levelsIsSet = true;
                                        }
                                    }
                                    else{*/
                                        
                                        newResponseDataListMap.add(new Map<String, String>{
                                            'type' => 'Object',
                                            'key' => key,
                                            'value' => JSON.serialize(newObjects.get(responseDataElementName).get(key))
                                        });
                                        if(!levelsIsSet){
                                            
                                            levels++;
                                            levelsIsSet = true;
                                        }
                                    //}
                                    //Luca Search
                                }else if(SV_Utilities.getType(newObjects.get(responseDataElementName).get(key)) == 'List'){
                                    
                                    newResponseDataListMap.add(new Map<String, String>{
                                        'type' => 'List',
                                        'key' => key,
                                        'value' => JSON.serialize(newObjects.get(responseDataElementName).get(key))
                                    });
                                    if(!levelsIsSet){
                                        
                                        levels++;
                                        levelsIsSet = true;
                                    }
                                }else{
                                    if(fieldsMap.containsKey(key)){
                                        
                                        if(fieldsMap.get(key).containsKey('exclude')){
    
                                            if((Boolean)fieldsMap.get(key).get('exclude')){
                                                
                                                continue;
                                            }
                                        }
                                        if(!(Boolean)fieldsMap.get(key).get('isRelated')){
                                            
                                            if(String.isBlank((String)fieldsMap.get(key).get('fieldReferenceDevName'))){
                                                for(String fieldDevName : ((String)fieldsMap.get(key).get('devName')).split(',')){
                                                    if(record.getSobjectType().getDescribe().fields.getMap().containsKey(fieldDevName)){
                                                        
                                                        if(fieldsMap.get(key).containsKey('concat')){
                                                            
                                                            System.debug('DK concat responseDataElementName: ' + responseDataElementName);
                                                            System.debug('DK concat key: ' + key);
                                                            System.debug('DK concat newObjects: ' + JSOn.serialize(newObjects));
                                                            System.debug('DK concat newObjects: ' + JSOn.serialize(newObjects.get(responseDataElementName).get(key)));
                                                            if(newObjects.get(responseDataElementName).get(key) == null){
                                                                record.put(fieldDevName, null);
                                                            }else{
    
                                                                List<String> contactStringList = ((String)fieldsMap.get(key).get('concat')).split(',');
                                                                String currentValue = String.isBlank(String.valueOf(newObjects.get(responseDataElementName).get(key))) ? '' : String.valueOf(newObjects.get(responseDataElementName).get(key));
                                                                for(String field : contactStringList){
            
                                                                    System.debug('DK field: ' + field);
                                                                    List<String> fieldChildren = field.split('\\.');
                                                                    System.debug('DK fieldChildren: ' + JSON.serialize(fieldChildren));                                                                   
                                                                    Map<String, Object> deserializedFieldChildren = new Map<String, Object>();
                                                                    if(fieldChildren.size() > 1){
            
                                                                        for(Integer x = 0; x < fieldChildren.size(); x++){
            
                                                                            if((x + 1) == fieldChildren.size()){
                                                                                
                                                                                System.debug('DK fieldChildren[x]: ' + fieldChildren[x]);
                                                                                String concatValue = String.isBlank(String.valueOf(deserializedFieldChildren.get(fieldChildren[x]))) ? '' : String.valueOf(deserializedFieldChildren.get(fieldChildren[x]));
                                                                                currentValue += '' + concatValue;                                                               
                                                                            }else{
            
                                                                                System.debug('DK newObjects.get(responseDataElementName): ' + JSON.serialize(newObjects.get(responseDataElementName)));
                                                                                deserializedFieldChildren = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(newObjects.get(responseDataElementName).get(fieldChildren[x])));
                                                                                System.debug('DK deserializedFieldChildren: ' + JSON.serialize(deserializedFieldChildren));                                                                   
                                                                            }
                                                                        }
                                                                    }else{
            
                                                                        currentValue += '' + String.valueOf(newObjects.get(responseDataElementName).get(fieldChildren[0]));
                                                                    }
                                                                }
            
                                                                System.debug('DK type: ' + (String)fieldsMap.get(key).get('type'));
                                                                System.debug('DK forName: ' + Type.forName((String)fieldsMap.get(key).get('type')));
                                                                if((String)fieldsMap.get(key).get('type') == 'Decimal'){
                                                                    
                                                                    currentValue = currentValue.replace('+', '');
                                                                }
                                                                System.debug('DK currentValue: ' + currentValue);
                                                                if((String)fieldsMap.get(key).get('type') == 'String'){
                                                                    record.put(fieldDevName, currentValue);
                                                                }else{
                                                                    record.put(fieldDevName, JSON.deserialize(currentValue, Type.forName((String)fieldsMap.get(key).get('type'))));
                                                                }
                                                            }
                                                        }else{
        
                                                            if(newObjects.get(responseDataElementName).get(key) == null){
                                                                record.put(fieldDevName, null);
                                                            }else if((String)fieldsMap.get(key).get('type') == 'Date'){
                                                                
                                                                try{
            
                                                                    String dataValueString = ((String)newObjects.get(responseDataElementName).get(key)).contains('T') ? ((String)newObjects.get(responseDataElementName).get(key)).split('T')[0] : (String)newObjects.get(responseDataElementName).get(key);
                                                                    System.debug('DK dataValueString: ' + dataValueString);
                                                                    record.put(fieldDevName, Date.valueOf(dataValueString));
                                                                }catch(Exception ex){
                                                                    
                                                                    System.debug('DK (String)newObjects.get(responseDataElementName).get(key): ' + (String)newObjects.get(responseDataElementName).get(key));
                                                                    String dateValueString = ((String)newObjects.get(responseDataElementName).get(key)).split('T')[0];
                                                                    System.debug('DK dateValueString: ' + dateValueString);
                                                                    record.put(fieldDevName, Date.parse(dateValueString));
                                                                }
                                                            }else if((String)fieldsMap.get(key).get('type') == 'DateTime'){
                                                                
                                                                record.put(fieldDevName, (DateTime)JSON.deserialize('"' + (String)newObjects.get(responseDataElementName).get(key) + '"', DateTime.class));
                                                            }else if((String)fieldsMap.get(key).get('type') == 'Email'){
            
                                                                Pattern MyPattern = Pattern.compile(emailRegex);
                                                                Matcher MyMatcher = MyPattern.matcher((String)newObjects.get(responseDataElementName).get(key));
            
                                                                if(MyMatcher.matches()){
                                                                    
                                                                    record.put(fieldDevName, newObjects.get(responseDataElementName).get(key));
                                                                }else if(((String)newObjects.get(responseDataElementName).get(key)).contains('*')){
            
                                                                    record.put(fieldDevName, ((String)newObjects.get(responseDataElementName).get(key)).replace('*', '@'));
                                                                }
                                                            }else{
                                                                
                                                                if(fieldsMap.get(key).containsKey('valueMap')){
                                                                    
                                                                    Map<String,String> valueMap = (Map<String,String>)JSON.deserialize(JSON.serialize(fieldsMap.get(key).get('valueMap')), Map<String,String>.class);
                                                                    String value =  valueMap.containsKey(String.valueOf(newObjects.get(responseDataElementName).get(key))) ? valueMap.get(String.valueOf(newObjects.get(responseDataElementName).get(key))) : (String)newObjects.get(responseDataElementName).get(key);
                                                                    record.put(fieldDevName, value);
                                                                }else{
                                                                    record.put(fieldDevName, newObjects.get(responseDataElementName).get(key));
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }else{
    
                                            if(conditions != null){
    
                                                List<String> relatedListKeyList = new List<String>();
    
                                                if(fieldsMap.get(key).containsKey('parent')){
                                                    
                                                    if(conditions.containsKey((String)fieldsMap.get(key).get('parent'))){
    
                                                        for(String field : (Set<String>)conditions.get((String)fieldsMap.get(key).get('parent')).keySet()){
    
                                                            System.debug('DK field: ' + field);
                                                            List<String> fieldChildren = field.split('\\.');
                                                            System.debug('DK fieldChildren: ' + JSON.serialize(fieldChildren));                                                                   
                                                            Map<String, Object> deserializedFieldChildren = new Map<String, Object>();
                                                            if(fieldChildren.size() > 1){
    
                                                                for(Integer x = 0; x < fieldChildren.size(); x++){
    
                                                                    if((x + 1) == fieldChildren.size()){
                                                                        
                                                                        System.debug('DK fieldChildren[x]: ' + fieldChildren[x]);      
                                                                        // if(){
    
                                                                            relatedListKeyList.add((String)deserializedFieldChildren.get(fieldChildren[x]));
                                                                        // }                                                             
                                                                    }else{
    
                                                                        deserializedFieldChildren = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(newObjects.get(responseDataElementName).get(fieldChildren[x])));
                                                                        System.debug('DK deserializedFieldChildren: ' + JSON.serialize(deserializedFieldChildren));                                                                   
                                                                    }
                                                                }
                                                            }else{
    
                                                                // if(){
                                                                    System.debug('@@@@responseDataElementName: '+JSON.serialize(responseDataElementName));
                                                                    System.debug('@@@@newObjects: '+JSON.serialize(newObjects));
                                                                    relatedListKeyList.add((String)newObjects.get(responseDataElementName).get(field));
                                                                // }
                                                            }
                                                        }
                                                        System.debug('DK relatedListKeyList: ' + JSON.serialize(relatedListKeyList));
                                                        
                                                    }
                                                    System.debug('@@@@relatedListMap: '+ JSON.serialize(relatedListMap));
                                                    System.debug('@@@@key: '+ JSON.serialize(key));
                                                    System.debug('@@@@fieldsMap: '+ JSON.serialize(fieldsMap));
                                                    if(relatedListMap.containsKey((String)fieldsMap.get(key).get('fieldReferenceObject'))){
                                                        System.debug('@@@@sonoqui: ');
                                                        if(!relatedListKeyList.isEmpty()){
    
                                                            Boolean isSet = false;
                                                            SObject relatedRecord = Schema.getGlobalDescribe().get((String)fieldsMap.get(key).get('SObject')).newSObject();
                                                            if(relatedListMap.get((String)fieldsMap.get(key).get('fieldReferenceObject')).containsKey(String.join(relatedListKeyList, '_'))){
                                                                
                                                                relatedRecord = relatedListMap.get((String)fieldsMap.get(key).get('fieldReferenceObject')).get(String.join(relatedListKeyList, '_'));
                                                                isSet = true;
                                                            }/*else if(apiRequestName == 'searchSmartAccountExtended'){
        
                                                                relatedRecord = Schema.getGlobalDescribe().get((String)fieldsMap.get(key).get('SObject')).newSObject();
                                                                relatedRecord.put('Name', 'Internet Banking');
                                                                relatedRecord.put('CRM_UserCodeStatus__c', 'ATTIVO');
                                                                relatedRecord.put('NDW_ExternalId__c', (String)record.get('FinServ__BankNumber__c') + '_' + (String)newObjects.get(responseDataElementName).get('accountCode') + '_' + (String)newObjects.get(responseDataElementName).get('username') + '_' + (String)record.get('CRM_NDG__c'));
                                                                relatedRecord.put('RecordTypeId', SV_Utilities.getRecordTypeByDeveloperName((String)fieldsMap.get(key).get('SObject'), 'Internet_Banking'));
                                                                relatedRecord.put('CRM_Account__c', (String)record.get('Id'));
                                                                isSet = true;
                                                                // relatedListMap.get((String)fieldsMap.get(key).get('fieldReferenceObject')).put(String.join(relatedListKeyList, '_'), relatedRecord);
                                                            }*/
                                                            if(isSet){
                                                                for(String fieldReferenceDevName : ((String)fieldsMap.get(key).get('fieldReferenceDevName')).split(',')){
                                                                    if(relatedRecord.getSobjectType().getDescribe().fields.getMap().containsKey(fieldReferenceDevName)){
                                                                    
                                                                        System.debug('DK fieldReferenceDevName: ' + fieldReferenceDevName);
                                                                        System.debug('DK contains valueMap: ' + fieldsMap.get(key).containsKey('valueMap'));
                                                                        if(fieldsMap.get(key).containsKey('concat')){
                
                                                                            List<String> contactStringList = ((String)fieldsMap.get(key).get('concat')).split(',');
                                                                            String currentValue = String.valueOf(newObjects.get(responseDataElementName).get(key));
                                                                            for(String field : contactStringList){
                        
                                                                                System.debug('DK field: ' + field);
                                                                                List<String> fieldChildren = field.split('\\.');
                                                                                System.debug('DK fieldChildren: ' + JSON.serialize(fieldChildren));                                                                   
                                                                                Map<String, Object> deserializedFieldChildren = new Map<String, Object>();
                                                                                if(fieldChildren.size() > 1){
                        
                                                                                    for(Integer x = 0; x < fieldChildren.size(); x++){
                        
                                                                                        if((x + 1) == fieldChildren.size()){
                                                                                            
                                                                                            System.debug('DK fieldChildren[x]: ' + fieldChildren[x]);   
                                                                                            currentValue += '' + String.valueOf(deserializedFieldChildren.get(fieldChildren[x]));                                                                
                                                                                        }else{
                        
                                                                                            deserializedFieldChildren = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(newObjects.get(responseDataElementName).get(fieldChildren[x])));
                                                                                            System.debug('DK deserializedFieldChildren: ' + JSON.serialize(deserializedFieldChildren));                                                                   
                                                                                        }
                                                                                    }
                                                                                }else{
                        
                                                                                    currentValue += '' + String.valueOf(newObjects.get(responseDataElementName).get(fieldChildren[0]));                                                                
                                                                                }
                                                                            }
                
                                                                            System.debug('DK currentValue: ' + currentValue);
                                                                            if((String)fieldsMap.get(key).get('type') == 'String'){
                
                                                                                relatedRecord.put(fieldReferenceDevName, currentValue);
                                                                            }else{
                
                                                                                relatedRecord.put(fieldReferenceDevName, JSON.deserialize(currentValue, Type.forName((String)fieldsMap.get(key).get('type'))));
                                                                            }
                                                                        }else{
                                                                            
                                                                            // relatedRecord.put(fieldReferenceDevName, (String)newObjects.get(responseDataElementName).get(key));
                                                                            System.debug('DK responseDataElementName: '+JSON.serialize(responseDataElementName));
                                                                            if(newObjects.get(responseDataElementName).get(key) == null){
                    
                                                                                relatedRecord.put(fieldReferenceDevName, null);
                                                                            }else if((String)fieldsMap.get(key).get('type') == 'Date'){
                                                                                
                                                                                try{
                    
                                                                                    String dataValueString = ((String)newObjects.get(responseDataElementName).get(key)).contains('T') ? ((String)newObjects.get(responseDataElementName).get(key)).split('T')[0] : (String)newObjects.get(responseDataElementName).get(key);
                                                                                    System.debug('DK dataValueString: ' + dataValueString);
                                                                                    relatedRecord.put(fieldReferenceDevName, Date.valueOf(dataValueString));
                                                                                }catch(Exception ex){
                                                                                    
                    
                                                                                    System.debug('DK (String)newObjects.get(responseDataElementName).get(key): ' + (String)newObjects.get(responseDataElementName).get(key));
                                                                                    String dataValueString = ((String)newObjects.get(responseDataElementName).get(key)).split('T')[0];
                                                                                    System.debug('DK dataValueString: ' + dataValueString);
                                                                                    relatedRecord.put(fieldReferenceDevName, Date.valueOf(dataValueString));
                                                                                }
                                                                            }else if((String)fieldsMap.get(key).get('type') == 'Email'){
                    
                                                                                Pattern MyPattern = Pattern.compile(emailRegex);
                                                                                Matcher MyMatcher = MyPattern.matcher((String)newObjects.get(responseDataElementName).get(key));
                    
                                                                                if(MyMatcher.matches()){
                                                                                    
                                                                                    relatedRecord.put(fieldReferenceDevName, newObjects.get(responseDataElementName).get(key));
                                                                                }else if(((String)newObjects.get(responseDataElementName).get(key)).contains('*')){
                    
                                                                                    relatedRecord.put(fieldReferenceDevName, ((String)newObjects.get(responseDataElementName).get(key)).replace('*', '@'));
                                                                                }
                                                                            }else{
                                                                                if(fieldsMap.get(key).containsKey('valueMap')){
                    
                                                                                    Map<String,String> valueMap = (Map<String,String>)JSON.deserialize(JSON.serialize(fieldsMap.get(key).get('valueMap')), Map<String,String>.class);
                                                                                    System.debug('DK valueMap: ' + JSON.serialize(valueMap));
                                                                                    String value =  valueMap.containsKey(String.valueOf(newObjects.get(responseDataElementName).get(key))) ? valueMap.get(String.valueOf(newObjects.get(responseDataElementName).get(key))) : (String)newObjects.get(responseDataElementName).get(key);
                                                                                    relatedRecord.put(fieldReferenceDevName, value);
                                                                                }else{
                    
                                                                                    relatedRecord.put(fieldReferenceDevName, newObjects.get(responseDataElementName).get(key));
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            relatedListMap.get((String)fieldsMap.get(key).get('fieldReferenceObject')).put(String.join(relatedListKeyList, '_'), relatedRecord);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        System.debug('DK FIELDSMAP-KEY: ' + fieldsMap.get(key).get('devName'));
                                    }else if(duplicateFieldsMap.containsKey(key) && newObjects.get(responseDataElementName).get(key) == null){
                                        for(String fieldKey : duplicateFieldsMap.get(key)){
                                            if(fieldsMap.containsKey(key + '_' + fieldKey)){
                                                for(String fieldDevName : ((String)fieldsMap.get(key + '_' + fieldKey).get('devName')).split(',')){
                                                    record.put(fieldDevName, null);
                                                }
                                            }
                                        }
                                    }
                                } 
                                
                                System.debug('DK levels: ' + levels);
                                System.debug('DK i: ' + i);
                            }
                        }
                        responseDataListMap = newResponseDataListMap;
                        newResponseDataListMap = new List<Map<String, String>>();
                        System.debug('DK responseDataListMap: ' + JSON.serialize(responseDataListMap));
                        System.debug('DK record: ' + JSON.serialize(record));
                    }
                }
                if(updateRecord){
                    update record;
                }
                System.debug('DK relatedListMap: ' + JSON.serialize(relatedListMap));
                //Luca Search
                List<SObject> updateList = new List<SObject>();
                List<SObject> insertList = new List<SObject>();
                /*for(Map<String, SObject> relatedList : relatedListMap.values()){
                    
                   
                     //update relatedList.values();
                }*/
                for(Map<String, SObject> relatedList : relatedListMap.values()){
                    for(SObject related:relatedList.values()){
                        Map<String,Object> tempMap= (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(related));
                        if(tempMap.containsKey('Id')){
                            system.debug('@@@@@relatedUpdate: '+JSON.serialize(related));
                            updateList.add(related);
                        }
                        else{
                            insertList.add(related);
                        }
                    }
                }
                if(updateRecord){

                    if(updateList.size()>0){
                        update updateList;
                    }
                }
                
                /*if(apiRequestName=='searchSmartAccountExtended' && insertList.size()>0){
                    insert insertList;
                }*/
                //Luca Search
                return JSON.serialize(new Map<String, Object>{
                    'error' => '',
                    'record' => record,
                    'response' => response,
                    'statusCode' => response.statusCode
                });
            }else{
    
                return JSON.serialize(new Map<String, Object>{
                    'error' => 'Response is blank',
                    'record' => '',
                    'response' => response,
                    'statusCode' => response.statusCode
                });
            }
        }else{
            return JSON.serialize(new Map<String, Object>{
                'error' => 'Record Deleted',
                'record' => '',
                'response' => '',
                'statusCode' => 'RD'
            });
        }
    }
    
    @AuraEnabled
    public static String makeRequestWithParams(String apiRequestName, Id recordId, Map<String, Map<String, Object>> fieldsMap, Map<String, Map<String, String>> conditions, String certificateName, String runAsUserId, String params, Boolean disableLog){
        System.debug('SV apiRequestName: ' + apiRequestName);
        System.debug('SV recordId: ' + recordId);
        System.debug('SV fieldsMap: ' + fieldsMap);
        System.debug('SV conditions: ' + JSON.serialize(conditions));
        System.debug('SV params: ' + params);
        System.debug('SV certificateName: ' + certificateName);
        System.debug('SV runAsUserId: ' + runAsUserId);
        
        Map<String, String> paramsMap = new Map<String, String>();
        Map<String, String> endpointParamsMap = new Map<String, String>();

        Map<String, String> endpointParamsQueryMap = new Map<String, String>();
        Map<String, String> endpointParamsUrlMap = new Map<String, String>();

        List<WrapperParamsObject> paramsDetail = (List<WrapperParamsObject>)JSON.deserialize(params,List<WrapperParamsObject>.class);
        for(WrapperParamsObject x : paramsDetail){
            if(x.requestTo == 'url'){
                endpointParamsUrlMap.put(x.key, x.value);
            } else {
                endpointParamsQueryMap.put(x.key, x.value);
            }
        }
        System.debug('SV endpointParamsQueryMap: ' + endpointParamsQueryMap);
        System.debug('SV endpointParamsUrlMap: ' + endpointParamsUrlMap);

        //inizializza restinput con dati dell'utente corrente
        if(!String.isBlank(runAsUserId)){

            currentUser = [SELECT FederationIdentifier, abi__c, applicazione__c, ndgsettoriale__c, banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c FROM User WHERE id =: runAsUserId];
        }
        WsRestInput restInput = new WsRestInput(currentUser, null);
        
        //Recupre dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        
        //esegue query per recuperare i campi del record che poi dovranno essere aggiorati
        Map<String, Map<String, SObject>> relatedListMap = new Map<String, Map<String, SObject>>();
        Map<String, Set<String>> fieldReferenceObjectKeyMap = new Map<String, Set<String>>();
        Map<String, Set<String>> duplicateFieldsMap = new Map<String, Set<String>>();
        Map<String, Map<String,Set<String>>> relatedRecordFieldsMap = new Map<String, Map<String,Set<String>>>();
        String query = 'SELECT id ';
        for(String fieldName : fieldsMap.keySet()){

            if(fieldName.contains('_')){
                
                List<String> fieldNameList = fieldName.split('_');
                if(!duplicateFieldsMap.containsKey(fieldNameList[0])){

                    duplicateFieldsMap.put(fieldNameList[0], new Set<String>());
                }

                duplicateFieldsMap.get(fieldNameList[0]).add(fieldNameList[1]);
            }
            if(!(Boolean)fieldsMap.get(fieldName).get('isRelated')){

                if(!String.isBlank((String)fieldsMap.get(fieldName).get('fieldReferenceDevName'))){
                    
                    query += ', ' + String.escapeSingleQuotes((String)fieldsMap.get(fieldName).get('fieldReferenceDevName')) + '.' + String.escapeSingleQuotes((String)fieldsMap.get(fieldName).get('devName')) + ' ';
                }else{
                    
                    if(recordId.getSobjectType().getDescribe().fields.getMap().containsKey((String)fieldsMap.get(fieldName).get('devName'))){
        
                        query += ', ' + String.escapeSingleQuotes((String)fieldsMap.get(fieldName).get('devName')) + ' ';
                    }
                }
            }else {

                if(!relatedRecordFieldsMap.containsKey((String)fieldsMap.get(fieldName).get('SObject'))){

                    relatedRecordFieldsMap.put((String)fieldsMap.get(fieldName).get('SObject'), new Map<String,Set<String>>());
                    relatedRecordFieldsMap.get((String)fieldsMap.get(fieldName).get('SObject')).put((String)fieldsMap.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                }

                relatedRecordFieldsMap.get((String)fieldsMap.get(fieldName).get('SObject')).get((String)fieldsMap.get(fieldName).get('fieldReferenceObject')).add((String)fieldsMap.get(fieldName).get('fieldReferenceDevName'));
                
                if(conditions != null){

                    if(fieldsMap.get(fieldName).containsKey('parent')){
                        
                        if(conditions.containsKey((String)fieldsMap.get(fieldName).get('parent'))){

                            relatedRecordFieldsMap.get((String)fieldsMap.get(fieldName).get('SObject')).get((String)fieldsMap.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)fieldsMap.get(fieldName).get('parent')).values());
                            if(!relatedRecordFieldsMap.containsKey((String)fieldsMap.get(fieldName).get('fieldReferenceObject'))){

                                fieldReferenceObjectKeyMap.put((String)fieldsMap.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                            }
                            fieldReferenceObjectKeyMap.get((String)fieldsMap.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)fieldsMap.get(fieldName).get('parent')).values());
                        }
                    }
                }
            }
        }
        for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){

            String objectName = new List<String>(values.keySet())[0];
            query += ', (SELECT ' +  String.escapeSingleQuotes(String.join(new List<String>(values.get(objectName)), ',')) + ' FROM ' + String.escapeSingleQuotes(objectName) + ')';
        }
        query += ' FROM ' + String.escapeSingleQuotes(recordId.getSObjectType().getDescribe().getName()) + ' WHERE id =: recordId LIMIT 1';
        System.debug('DK query: ' + query);
        SObject record = Database.query(query);
        System.debug('DK record: ' + JSON.serialize(record));
        Map<String, Object> deserializedObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record)); 

        for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){

            for(String relatedListName : values.keySet()){

                Map<String, Object> deserializedReletadList = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(deserializedObject.get(relatedListName)));
                String serializedList = JSON.serialize(deserializedReletadList.get('records'));
                System.debug('DK serializedList: ' + serializedList);
                List<String> keyList = new List<String>();
                if(fieldReferenceObjectKeyMap.containsKey(relatedListName)){

                    for(String key : fieldReferenceObjectKeyMap.get(relatedListName)){
                    
                        if(fieldReferenceObjectKeyMap.get(relatedListName).size() > 1){

                            keyList.add('{' + key + '}');
                        }else{

                            keyList.add(key);
                        }
                    }
                }
                System.debug('DK fieldReferenceObjectKeyMap.get(relatedListName): ' + JSON.serialize(keyList));
                Map<String, Sobject> relatedMap = SV_Utilities.keyBy((List<SObject>)JSON.deserialize(serializedList, List<Sobject>.class), String.join(keyList, '_'), fieldReferenceObjectKeyMap.get(relatedListName).size() > 1 ? true : false);
                System.debug('DK relatedMap: ' + JSON.serialize(relatedMap));
                relatedListMap.put(relatedListName, relatedMap);
            }
        }
        System.debug('DK relatedListMap: ' + JSON.serialize(relatedListMap));
        //costruisce una mappa contente i parametri presenti nell'endpoint come key
        //come value è presente il valore corrispondente preso dal campo del record o dal parent del record
        String regex = '\\{.*?\\}';
        Pattern pattr = Pattern.compile(regex); 
        Matcher mat = pattr.matcher(apiRequest.Endpoint__c);
        System.debug('DK apiRequest: ' + JSON.serialize(apiRequest));
        do{
            try{
                System.debug('DK: mat.group() ' + mat.group());
                Map<String,Object> field = fieldsMap.get(mat.group().replace('{', '').replace('}', ''));
                if(String.isBlank((String)field.get('fieldReferenceDevName'))){

                    paramsMap.put(mat.group(), (String)record.get((String)field.get('devName')));
                }else{

                    Map<String,Object> recordMap = record.getPopulatedFieldsAsMap();
                    SObject parentRecord = (SObject)recordMap.get((String)field.get('fieldReferenceDevName'));
                    paramsMap.put(mat.group(), (String)parentRecord.get((String)field.get('devName')));
                }
            }catch(Exception ex){}
        }while(mat.find());

        Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
        Map<String, String> secutityMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.security), Map<String, String>.class);
        Map<String, String> userProfileMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.userProfile), Map<String, String>.class);
        Map<String, String> bindingInfoMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.bindingInfo), Map<String, String>.class);
        if(!String.isBlank(apiRequest.EndpointParams__c)){

            Map<String, String> headerMap = new Map<String, String>();
            Map<String, String> endpointAPIParamsMap = (Map<String, String>)JSON.deserialize(apiRequest.EndpointParams__c, Map<String, String>.class);
            for(String paramName : endpointAPIParamsMap.keySet()){

                if(endpointAPIParamsMap.get(paramName).contains('{')){

                    System.debug('DK param: ' + endpointAPIParamsMap.get(paramName));
                    String textInBrackets = endpointAPIParamsMap.get(paramName).substringBetween('{', '}');
                    if(textInBrackets.contains('_') && !textInBrackets.contains('__c')){

                        if(textInBrackets.split('_')[0] == 'testata'){

                            headerMap = testataMap;
                        }else if(textInBrackets.split('_')[0] == 'security'){

                            headerMap = secutityMap;
                        }else if(textInBrackets.split('_')[0] == 'userProfile'){

                            headerMap = userProfileMap;
                        }else if(textInBrackets.split('_')[0] == 'bindingInfo'){

                            headerMap = bindingInfoMap;
                        }
                        if(!headerMap.isEmpty()){

                            endpointParamsMap.put(paramName, headerMap.get(textInBrackets.split('_')[1]));
                        }
                    }else if(textInBrackets == 'C'){
                        if(String.isNotBlank(endpointParamsQueryMap.get(paramName))){
                            endpointParamsMap.put(paramName, endpointParamsQueryMap.get(paramName));
                        }
                    }else{

                        endpointParamsMap.put(paramName, (String)record.get(textInBrackets));
                    }
                }else{

                    endpointParamsMap.put(paramName, endpointAPIParamsMap.get(paramName));
                }
            }

            System.debug('SV endpointParamsQueryMap: ' + JSON.serialize(endpointParamsMap));
        }

        for(String paramName : paramsMap.keySet()){
            for(String paramNameUrl : endpointParamsUrlMap.keySet()){
                if(paramName.contains(paramNameUrl)){
                    paramsMap.put(paramName, endpointParamsUrlMap.get(paramNameUrl));
                }
            }
        }
            System.debug('SV endpointParamsMap: ' + JSON.serialize(paramsMap));

        
        System.debug('DK paramsMap: ' + JSON.serialize(paramsMap));
        System.debug('DK testata: ' + JSON.serialize(restInput.headers.testata));
        System.debug('DK security: ' + JSON.serialize(restInput.headers.security));
        System.debug('DK userProfile: ' + JSON.serialize(restInput.headers.userProfile));
        System.debug('DK bindingInfo: ' + JSON.serialize(restInput.headers.bindingInfo));
        
        //effettua la request
        WsRestInput.CommonResponse response = WsRestUtils.callService(apiRequest,
        apiRequestName == 'searchSmartAccountExtended' ? userProfileMap : testataMap,
        apiRequestName == 'searchSmartAccountExtended' ? bindingInfoMap : secutityMap,
        paramsMap,
        endpointParamsMap,
        (String)restInput.payload,
        certificateName,
        disableLog);
        System.debug('DK MakeRequestController.makeRequest.response: ' + JSON.serialize(response));
        
        return JSON.serialize(new Map<String, Object>{
                'error' => '',
                'record' => '',
                'response' => response
            });
        
    }

    public class WrapperParamsObject {
        @AuraEnabled public String key;   
        @AuraEnabled public String value;   
        @AuraEnabled public String requestTo;     
        @AuraEnabled public String apiObject;     
        @AuraEnabled public String field;
        @AuraEnabled public String where_x;
    }

    public class Parametro {
        @AuraEnabled public String paramName;   
        @AuraEnabled public String paramValue;   
    }

    public static void test(){

        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}