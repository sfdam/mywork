public without sharing class  MakeRequestV2Controller {

    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c,
                        Profile.Name, CRM_LastCallWsRisoluzioneIndirizzi__c, MACAddress__c
                        FROM User WHERE id =: UserInfo.getUserId()];
            return currentUser;
        }set;
    }

    public static String generateCorrelationId(){
        Blob b = Crypto.GenerateAESKey(128);
        String correlationIDS = EncodingUtil.ConvertTohex(b);
        String correlationid = correlationIDS.SubString(0,8) + correlationIDS.SubString(8,12) + correlationIDS.SubString(12,16)  + correlationIDS.SubString(16,20)  + correlationIDS.substring(20);
        system.debug(correlationid);
        return correlationid;
    }

    @AuraEnabled
    public static Map<String, Object> init(Id recordId, Map<String, Map<String, Map<String, Object>>> parseJSONMap, Map<String, Map<String, Map<String, String>>> conditionsMap, List<String> additionalFields){

        String query = 'SELECT ';
        Set<String> fieldsToQuery;
        if (String.escapeSingleQuotes(recordId.getSObjectType().getDescribe().getName()) == 'Account'){
            fieldsToQuery = new Set<String>{'Id','RecordType.Name'};
        }else{
            fieldsToQuery = new Set<String>{'Id'};
        }
        
        if(additionalFields != null && !additionalFields.isEmpty())fieldsToQuery.addAll(additionalFields);
        Map<String, Map<String, SObject>> relatedListMap = new Map<String, Map<String, SObject>>();
        Map<String, Map<String,Set<String>>> relatedRecordFieldsMap = new Map<String, Map<String,Set<String>>>();
        Map<String, Set<String>> fieldReferenceObjectKeyMap = new Map<String, Set<String>>();
        Map<String, Set<String>> fieldReferenceObjectKeyMapGPF = new Map<String, Set<String>>();
        for(String requestToApiGateway : parseJSONMap.keySet()){
            
            Map<String, Map<String, String>> conditions = conditionsMap.get(requestToApiGateway);
            Map<String, Map<String, Object>> parseJSON = parseJSONMap.get(requestToApiGateway);
            system.debug('parseJSON '+ parseJSON);
            system.debug('requestToApiGateway '+requestToApiGateway);
            
            for(String fieldName : parseJSON.keySet()){
                if(parseJSON.get(fieldName).get('SObject') != 'user'){

                    if(!(Boolean)parseJSON.get(fieldName).get('isRelated')){
        
                        if(!String.isBlank((String)parseJSON.get(fieldName).get('fieldReferenceDevName'))){
                            
                            // query += ', ' + parseJSON.get(fieldName).get('fieldReferenceDevName') + '.' + parseJSON.get(fieldName).get('devName') + ' ';
                            fieldsToQuery.add((String)parseJSON.get(fieldName).get('fieldReferenceDevName') + '.' + parseJSON.get(fieldName).get('devName'));
                        }else{
        
                            if(recordId.getSobjectType().getDescribe().fields.getMap().containsKey((String)parseJSON.get(fieldName).get('devName'))){
                
                                // query += ', ' + parseJSON.get(fieldName).get('devName') + ' ';
                                fieldsToQuery.add((String)parseJSON.get(fieldName).get('devName'));
                            }
                        }
                    }else {
        
                        if(!String.isBlank((String)parseJSON.get(fieldName).get('fieldReferenceDevName'))){
        
                            if(!relatedRecordFieldsMap.containsKey((String)parseJSON.get(fieldName).get('SObject'))){
            
                                relatedRecordFieldsMap.put((String)parseJSON.get(fieldName).get('SObject'), new Map<String,Set<String>>());
                                relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).put((String)parseJSON.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                            }
            
                            relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).add((String)parseJSON.get(fieldName).get('fieldReferenceDevName'));
                            
                            if(conditions != null){
                                if(requestToApiGateway == 'getProfiloCarteNDG'){
                                   if(parseJSON.get(fieldName).containsKey('parent')){
                                        
                                        if(conditions.containsKey((String)parseJSON.get(fieldName).get('parent'))){
                
                                            relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)parseJSON.get(fieldName).get('parent')).values());
                                        }
                                        if(!relatedRecordFieldsMap.containsKey((String)parseJSON.get(fieldName).get('fieldReferenceObject'))){
    
                                            fieldReferenceObjectKeyMapGPF.put((String)parseJSON.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                                        }
                                        fieldReferenceObjectKeyMapGPF.get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)parseJSON.get(fieldName).get('parent')).values());
                                   }
                                }else{
                                      if(parseJSON.get(fieldName).containsKey('parent')){
                                        
                                        if(conditions.containsKey((String)parseJSON.get(fieldName).get('parent'))){
                
                                            relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)parseJSON.get(fieldName).get('parent')).values());
                                        }
                                        if(!relatedRecordFieldsMap.containsKey((String)parseJSON.get(fieldName).get('fieldReferenceObject'))){
    
                                            fieldReferenceObjectKeyMap.put((String)parseJSON.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                                        }
                                        fieldReferenceObjectKeyMap.get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)parseJSON.get(fieldName).get('parent')).values());
                                    }  
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug('DK fieldReferenceObjectKeyMapGPF: ' + JSON.serialize(fieldReferenceObjectKeyMapGPF));
        System.debug('DK fieldReferenceObjectKeyMap: ' + JSON.serialize(fieldReferenceObjectKeyMap));
        System.debug('DK relatedRecordFieldsMap: ' + JSON.serialize(relatedRecordFieldsMap));
        query += String.escapeSingleQuotes(String.join(new List<String>(fieldsToQuery), ','));
        for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){

            String objectName = new List<String>(values.keySet())[0];
            query += ', (SELECT Id, ' +  String.escapeSingleQuotes(String.join(new List<String>(values.get(objectName)), ',')) + ' FROM ' + String.escapeSingleQuotes(objectName) + ')';
        }
        query += ' FROM ' + String.escapeSingleQuotes(recordId.getSObjectType().getDescribe().getName()) + ' WHERE id =: recordId LIMIT 1';
        System.debug('DK query: ' + query);

        SObject record = Database.query(query);
        if(record != null){

            System.debug('DK record: ' + JSON.serialize(record));
            Map<String, Object> deserializedObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record)); 
            System.debug('@@@@@relatedRecordFieldsMap: '+JSON.serialize(relatedRecordFieldsMap));
            for(String requestToApiGateway : parseJSONMap.keySet()){
    
                for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){
                    System.debug('@@@@@values: '+JSON.serialize(values));
                    for(String relatedListName : values.keySet()){
                        System.debug('@@@@@relatedListName: '+JSON.serialize(relatedListName));
                        System.debug('@@@@@deserializedObject: '+JSON.serialize(deserializedObject));
                        if(!deserializedObject.containsKey(relatedListName) && requestToApiGateway!='searchSmartAccountExtended'){
        
                            continue;
                        }
                        //Luca Search
                        else if(requestToApiGateway=='searchSmartAccountExtended' && !deserializedObject.containsKey(relatedListName)){
                            relatedListMap.put(relatedListName, new Map<String, SObject>());
                        }
                        else{//Luca Search
                            Map<String, Object> deserializedReletadList = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(deserializedObject.get(relatedListName)));
                            String serializedList = JSON.serialize(deserializedReletadList.get('records'));
                            System.debug('DK serializedList: ' + serializedList);
                            List<String> keyList = new List<String>();
                            if(requestToApiGateway == 'getProfiloCarteNDG'){
                                if(fieldReferenceObjectKeyMapGPF.containsKey(relatedListName)){
                                
                                    for(String key : fieldReferenceObjectKeyMapGPF.get(relatedListName)){
                                    
                                        if(fieldReferenceObjectKeyMapGPF.get(relatedListName).size() > 1){
            
                                            keyList.add('{' + key + '}');
                                        }else{
            
                                            keyList.add(key);
                                        }
                                    }
                                }
                                System.debug('DK fieldReferenceObjectKeyMapGPF.get(relatedListName): ' + JSON.serialize(keyList));
                                Map<String, Sobject> relatedMap = SV_Utilities.keyBy((List<SObject>)JSON.deserialize(serializedList, List<Sobject>.class), String.join(keyList, '_'), fieldReferenceObjectKeyMapGPF.get(relatedListName).size() > 1 ? true : false);
                                System.debug('DK relatedMap: ' + JSON.serialize(relatedMap));
                                System.debug('DK relatedListName): ' + relatedListName);
                                System.debug('DK relatedMap): ' + relatedMap);
                                relatedListMap.put(relatedListName, relatedMap);
                            }else{
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
                                System.debug('DK relatedListName): ' + relatedListName);
                                System.debug('DK relatedMap): ' + relatedMap);
                                relatedListMap.put(relatedListName, relatedMap);
                            }
                     }
                 } 
             }
         }
        }
        System.debug('DK relatedListMap: ' + JSON.serialize(relatedListMap));
        return new Map<String, Object>{
            'record' => record,
            'relatedListMap' => relatedListMap,
            'currentUser' => currentUser,
            'query' => query
        };
    }
    @AuraEnabled
    public static Map<String, Object> getResponse(SObject record, String requestToApiGateway, Map<String, Map<String, Object>> parseJSON, Map<String, Map<String, String>> conditions, String certificateName, Boolean disableLog, Map<String, String> addingParamsMap) {
        return getResponse(record, requestToApiGateway, parseJSON, conditions, certificateName, disableLog, addingParamsMap, null);
    }

    @AuraEnabled
    public static Map<String, Object> getResponse(SObject record, String requestToApiGateway, Map<String, Map<String, Object>> parseJSON, Map<String, Map<String, String>> conditions, String certificateName, Boolean disableLog, Map<String, String> addingParamsMap, String bodyJSON) {
        System.debug('getResponse requestToApiGateway: ' + requestToApiGateway);
        System.debug('getResponse parseJSON: ' + parseJSON);
        System.debug('getResponse conditions: ' + conditions);
        System.debug('getResponse certificateName: ' + certificateName);
        System.debug('getResponse disableLog: ' + disableLog);
        System.debug('getResponse addingParamsMap: ' + JSON.serialize(addingParamsMap));
        Long dt1Long = DateTime.now().getTime();
        
        // Schema.SObjectType sobjectType = recordId.getSObjectType();
        // String sobjectName = sobjectType.getDescribe().getName();

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('request', requestToApiGateway);
        responseMap.put('currentUser', currentUser);

        WsRestInput restInput = new WsRestInput(currentUser, null);
        
        Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
        if(requestToApiGateway == 'calculateSimulazione' || requestToApiGateway == 'loadAmmortamentoLinea'){
            testataMap.put('cab', '12922');
        }

        testataMap.put('correlationid', generateCorrelationId());
        System.debug('pz correlationid'+testataMap.get('sessionId'));
        Map<String, String> secutityMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.security), Map<String, String>.class);
        Map<String, String> userProfileMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.userProfile), Map<String, String>.class);
        Map<String, String> bindingInfoMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.bindingInfo), Map<String, String>.class);
        

        responseMap.put('testata', testataMap);
        responseMap.put('security', secutityMap);
        responseMap.put('userProfile', userProfileMap);
        responseMap.put('bindingInfo', bindingInfoMap);

        //Recupre dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(requestToApiGateway);
        responseMap.put('method', apiRequest.method__c);
        System.debug('DK Endpoint__c: ' + apiRequest.Endpoint__c);


        //esegue query per recuperare i campi del record che poi dovranno essere aggiorati
        /*Map<String, Map<String, SObject>> relatedListMap = new Map<String, Map<String, SObject>>();
        Map<String, Set<String>> fieldReferenceObjectKeyMap = new Map<String, Set<String>>();
        Map<String, Map<String,Set<String>>> relatedRecordFieldsMap = new Map<String, Map<String,Set<String>>>();
        String query = 'SELECT id ';
        for(String fieldName : parseJSON.keySet()){

            if(!String.isBlank((String)parseJSON.get(fieldName).get('fieldReferenceDevName'))){

                if(!relatedRecordFieldsMap.containsKey((String)parseJSON.get(fieldName).get('SObject'))){

                    relatedRecordFieldsMap.put((String)parseJSON.get(fieldName).get('SObject'), new Map<String,Set<String>>());
                    relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).put((String)parseJSON.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                }

                relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).add((String)parseJSON.get(fieldName).get('fieldReferenceDevName'));
                
                if(conditions != null){

                    if(parseJSON.get(fieldName).containsKey('parent')){
                        
                        if(conditions.containsKey((String)parseJSON.get(fieldName).get('parent'))){

                            relatedRecordFieldsMap.get((String)parseJSON.get(fieldName).get('SObject')).get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)parseJSON.get(fieldName).get('parent')).values());
                            if(!relatedRecordFieldsMap.containsKey((String)parseJSON.get(fieldName).get('fieldReferenceObject'))){

                                fieldReferenceObjectKeyMap.put((String)parseJSON.get(fieldName).get('fieldReferenceObject'), new Set<String>());
                            }
                            fieldReferenceObjectKeyMap.get((String)parseJSON.get(fieldName).get('fieldReferenceObject')).addAll((List<String>)conditions.get((String)parseJSON.get(fieldName).get('parent')).values());
                        }
                    }
                }
            }
        }

        System.debug('DK record: ' + JSON.serialize(record));
        Map<String, Object> deserializedObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record)); 
        System.debug('@@@@@relatedRecordFieldsMap: '+JSON.serialize(relatedRecordFieldsMap));
        for(Map<String,Set<String>> values : relatedRecordFieldsMap.values()){
            System.debug('@@@@@values: '+JSON.serialize(values));
            for(String relatedListName : values.keySet()){
                System.debug('@@@@@relatedListName: '+JSON.serialize(relatedListName));
                System.debug('@@@@@deserializedObject: '+JSON.serialize(deserializedObject));
                if(!deserializedObject.containsKey(relatedListName) && requestToApiGateway!='searchSmartAccountExtended'){

                    continue;
                }
                //Luca Search
                else if(requestToApiGateway=='searchSmartAccountExtended' && !deserializedObject.containsKey(relatedListName)){
                    relatedListMap.put(relatedListName, new Map<String, SObject>());
                }
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

        responseMap.put('record', record);
        responseMap.put('relatedListMap', relatedListMap);*/
        responseMap.put('fields', parseJSON);

        //costruisce una mappa contente i parametri presenti nell'endpoint come key
        //come value è presente il valore corrispondente preso dal campo del record o dal parent del record
        Map<String, String> paramsMap = new Map<String, String>();
        Map<String, String> endpointParamsMap = new Map<String, String>();
        if(parseJSON != null){

            String regex = '\\{.*?\\}';
            Pattern pattr = Pattern.compile(regex); 
            Matcher mat = pattr.matcher(apiRequest.Endpoint__c);
            System.debug('DK apiRequest: ' + JSON.serialize(apiRequest));
            do{
                try{
                    System.debug('DK: mat.group() ' + mat.group());
                    Map<String,Object> field = parseJSON.get(mat.group().replace('{', '').replace('}', ''));
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
    
            responseMap.put('paramsURLMap', paramsMap);
    
            // List<Parametro> parametriEndpointList = new List<Parametro>();
            Map<String, String> endpointParamsQueryMap = new Map<String, String>();
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
    
                            // endpointParamsMap.put(paramName, (String)record.get(textInBrackets));
                            System.debug('DK getResponse.textInBrackets: ' + textInBrackets);
                            if(parseJSON.containsKey(textInBrackets)){
    
                                Map<String,Object> field = parseJSON.get(textInBrackets);
                                if(String.isBlank((String)field.get('fieldReferenceDevName'))){
        
                                    if((String)field.get('type') != 'Date'){
        
                                        if(textInBrackets.contains('parametro') && String.isNotBlank((String)record.get((String)field.get('devName')))){
                                            Parametro p = new Parametro();
                                            p.paramName = paramName.split('#')[1];
                                            p.paramValue = (String)record.get((String)field.get('devName'));
                                            // parametriEndpointList.add(p);
                                        } else if(!textInBrackets.contains('parametro')) {
                                            endpointParamsMap.put(paramName, (String)record.get((String)field.get('devName')));
                                        }
                                    }/*else{
        
                                        DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(record.get((String)field.get('devName'))), DateTime.class);
                                        endpointParamsMap.put(paramName, '' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                    }*/
                                }else{
        
                                    Map<String,Object> recordMap = record.getPopulatedFieldsAsMap();
                                    SObject parentRecord = (SObject)recordMap.get((String)field.get('fieldReferenceDevName'));
                                    if((String)field.get('type') != 'Date'){
        
                                        System.debug('DK endpointParamsMap value: ' + (String)parentRecord.get((String)field.get('devName')));
                                        endpointParamsMap.put(paramName, (String)parentRecord.get((String)field.get('devName')));
                                    }/*else{
                                        
                                        DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(parentRecord.get((String)field.get('devName'))), DateTime.class);
                                        endpointParamsMap.put(paramName, '' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                    }*/
                                }
                            }else{
                                if(addingParamsMap != null && addingParamsMap.containsKey(textInBrackets)){
                                    endpointParamsMap.put(paramName, String.valueOf(addingParamsMap.get(textInBrackets)));
                                }else if(textInBrackets != 'numeroPianoParam'){
                                    endpointParamsMap.put(paramName, (String)record.get(textInBrackets));
                                }
                            }
                        }
                    }else{
    
                        endpointParamsMap.put(paramName, endpointAPIParamsMap.get(paramName));
                    }
                }
    
                System.debug('SV endpointParamsQueryMap: ' + JSON.serialize(endpointParamsMap));
            }
    
            responseMap.put('endpointParamsMap', endpointParamsMap);
        }
        
        Map<String, Object> bodyParamsMap = new Map<String, Object>();
        List<Parametro> parametriBodyList = new List<Parametro>();
        String bodyParamsString;
        if(String.isBlank(bodyJSON)){

            if(!String.isBlank(apiRequest.BodyParams__c)){
    
                Map<String, String> headerMap = new Map<String, String>();
                Map<String, String> bodyAPIParamsMap = (Map<String, String>)JSON.deserialize(apiRequest.BodyParams__c, Map<String, String>.class);
                for(String paramName : bodyAPIParamsMap.keySet()){
    
                    if(bodyAPIParamsMap.get(paramName).contains('{')){
    
                        System.debug('DK param: ' + bodyAPIParamsMap.get(paramName));
                        String textInBrackets = bodyAPIParamsMap.get(paramName).substringBetween('{', '}');
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
    
                                bodyParamsMap.put(paramName, headerMap.get(textInBrackets.split('_')[1]));
                            }
                        }else{
    
                            // bodyParamsMap.put(paramName, (String)record.get(bodyAPIParamsMap.get(paramName)));
    
                            if(paramsMap.containsKey( bodyAPIParamsMap.get(paramName))){
                                bodyParamsMap.put(paramName, (String)paramsMap.get(bodyAPIParamsMap.get(paramName)));
                            } else {
                                
                                Map<String,Object> field = parseJSON.get(textInBrackets);
                                if(String.isBlank((String)field.get('fieldReferenceDevName'))){
    
                                    if((String)field.get('type') != 'Date'){
    
                                        if(textInBrackets.contains('parametro') && String.isNotBlank((String)record.get((String)field.get('devName')))){
                                            Parametro p = new Parametro();
                                            p.paramName = paramName.split('#')[1];
                                            p.paramValue = (String)record.get((String)field.get('devName'));
                                            parametriBodyList.add(p);
                                        } else if(!textInBrackets.contains('parametro')) {
                                            bodyParamsMap.put(paramName, (String)record.get((String)field.get('devName')));
                                        }
                                    }else{
    
                                        DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(record.get((String)field.get('devName'))), DateTime.class);
                                        bodyParamsMap.put(paramName, '' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                    }
                                }else{
    
                                    Map<String,Object> recordMap = record.getPopulatedFieldsAsMap();
                                    SObject parentRecord = (SObject)recordMap.get((String)field.get('fieldReferenceDevName'));
                                    if((String)field.get('type') != 'Date'){
    
                                        System.debug('DK bodyParamsMap value: ' + (String)parentRecord.get((String)field.get('fieldReferenceDevName')));
                                        bodyParamsMap.put(paramName, (String)parentRecord.get((String)field.get('fieldReferenceDevName')));
                                    }else{
                                        
                                        DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(parentRecord.get((String)field.get('fieldReferenceDevName'))), DateTime.class);
                                        bodyParamsMap.put(paramName, '' + dateValue.formatGMT('yyyy-MM-dd')+ 'T' + dateValue.formatGMT('HH:mm:ss.SSS') + 'Z');
                                    }
                                }
                            }
                        }
                    }else{
    
                        bodyParamsMap.put(paramName, bodyAPIParamsMap.get(paramName));
                    }
                }
                if(parametriBodyList.size() > 0){
                    bodyParamsMap.put('listaParametri', parametriBodyList);
                }   
                
                //DK EDIT
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
                System.debug('DK bodyParamsMap: ' + JSON.serialize(bodyParamsMap));
                bodyParamsString = apiRequest.InList__c ? JSON.serialize(new List<Map<String, Object>>{bodyParamsMap}) : JSON.serialize(bodyParamsMap);     
            }
        }else{
            bodyParamsString = bodyJSON;
        }

        responseMap.put('bodyParamsMap', bodyParamsMap);


        //effettua la request
        WsRestInput.CommonResponse response = WsRestUtils.callService(apiRequest,
        requestToApiGateway == 'searchSmartAccountExtended' ? userProfileMap : testataMap,
        requestToApiGateway == 'searchSmartAccountExtended' ? bindingInfoMap : secutityMap,
        paramsMap,
        endpointParamsMap,
        (apiRequest.method__c == 'POST' && bodyParamsString != null) ? bodyParamsString : (String)restInput.payload,
        certificateName,
        disableLog
        );
        Map<String, String> responseX = (Map<String, String>)JSON.deserialize(JSON.serialize(response), Map<String, String>.class);

        responseMap.put('response', responseX);
        responseMap.put('conditions', conditions);
        Long dt2Long = DateTime.now().getTime();
        Long milliseconds = dt2Long - dt1Long;

        responseMap.put('executionTime', milliseconds);
        responseMap.put('certificateName', certificateName);

        return responseMap;
    }

    @AuraEnabled
    public static Boolean saveElements(String recordToUpdateJSON, String recordToInsertJSON) {
        List<SObject> recordToUpdateList = (List<SObject>)JSON.deserialize(recordToUpdateJSON, List<SObject>.class);
        List<SObject> recordToInsertList = (List<SObject>)JSON.deserialize(recordToInsertJSON, List<SObject>.class);
        if(recordToUpdateList != null && !recordToUpdateList.isEmpty()) update recordToUpdateList;
        if(recordToInsertList != null && !recordToInsertList.isEmpty()) insert recordToInsertList;
        return true;
    }

    @AuraEnabled
    public static Boolean updateElements(List<SObject> recordToUpdate) {
        System.debug('saveElements record: ' + recordToUpdate);
        
        update recordToUpdate;
        return true;
    }

    public class Parametro {
        @AuraEnabled public String paramName;   
        @AuraEnabled public String paramValue;   
    }
}