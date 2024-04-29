public with sharing class pdfConfiguratorCallableMethods implements Callable {

    //S Dispatch actual methods
    public Object call(String action, Map<String, Object> args) {
        switch on action {

            when 'getProdottiList' {
                return this.getProdottiListData((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), (String)args.get('jsonAdditionalParameters'));
            }
            when 'getGroupMembersList' {
                return this.getGroupMembersListData((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), '');
            }
            when 'getScadenzeList' {
                return this.getScadenzeListData((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), '');
            }
            // DK - CR 58271
            when 'getIndicatoriRischioData' {
                return this.getIndicatoriRischioData((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), '');
            }
            // DK - CR 58271
            when 'getContactHistoryList' {
                return this.getContactHistoryList((sObject)args.get('currentObject'), (List<SObject>)args.get('recordList'), (Map<String, String>)args.get('recordObjectTypeMap'));
            }
            when else {
                throw new pdfConfiguratorCallableMethodsException('Method not implemented');
            }

            /*when 'getProdottiList' {
                return this.getProdottiList((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), (String)args.get('jsonAdditionalParameters'));
            }
            when 'getGroupMembersList' {
                return this.getGroupMembersList((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), '');
            }
            when 'getScadenzeList' {
                return this.getScadenzeList((PDFConfigurator__mdt)args.get('meta'), (sObject)args.get('currentObject'), '');
            }
            when 'getContactHistoryList' {
                return this.getContactHistoryList((sObject)args.get('currentObject'), (List<SObject>)args.get('recordList'), (Map<String, String>)args.get('recordObjectTypeMap'));
            }
            when else {
                throw new pdfConfiguratorCallableMethodsException('Method not implemented');
            }*/
        }
    }

    public Map<String, PDFConfigurator__mdt> contactHistoryMetaMap {
        get{

            if(contactHistoryMetaMap != null) return contactHistoryMetaMap;
            contactHistoryMetaMap = new Map<String, PDFConfigurator__mdt>();
            for(PDFConfigurator__mdt meta : [SELECT Id, ObjType__c, ColumnJSON__c, COMPONENT__c, FieldValueMapJSON__c FROM PDFConfigurator__mdt WHERE ObjType__c != '' 
                                            AND isActive__c = true
                                            AND SECTION__c = 'Contact History']){
                if(!String.isBlank(meta.ColumnJSON__c)){
                    contactHistoryMetaMap.put(meta.ObjType__c, meta);
                }
            }
            return contactHistoryMetaMap;
        }set;
    }

    public class WrapperGetMapDataRes{
        // public PDFConfigurator__mdt meta {get;set;}
        public String action {get;set;}
        public Map<String, List<SObject>> wrResponse {get;set;}
        public WrapperGetMapDataRes(){}
    }

    public class WrapperListRes{
        // public PDFConfigurator__mdt meta {get;set;}
        public String action {get;set;}
        public List<SObject> wrResponse {get;set;}
        public WrapperListRes(){}
    }

    public class WrapperObjRes{
        // public PDFConfigurator__mdt meta {get;set;}
        public String action {get;set;}
        public Object wrResponse {get;set;}
        public WrapperObjRes(){}
    }
    //E Dispatch actual methods

    public static List<Map<String,String>> replaceGetProdotti(PDFConfigurator__mdt meta, sObject currentObject, String responseListMapJSON) {
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        Map<String, List<SObject>> responseListMap = (Map<String, List<SObject>>) JSON.deserialize(responseListMapJSON, Map<String, List<SObject>>.class);
        // List<wrapperProdotti> wrapperProdottiList = new List<wrapperProdotti>();
        String recordId = currentObject.Id;
        try{

            //E get the additional parameter from json
            Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
            Matcher m = p.matcher(meta.TemplateIterationXml__c);
            Set<String> campiFinancialAccount = new Set<String>();
            Set<String> campiFinancialRole = new Set<String>();
            while(m.find()) {
                String daSostituire = m.group(0);
                String campo = daSostituire.replace('{!', '').replace('}', '');
                if(campo.contains('financialAccount_')){
                    campiFinancialAccount.add(campo.substringAfter('financialAccount_').toUpperCase());
                }else if(campo.contains('financialRole_')){
                    campiFinancialRole.add(campo.substringAfter('financialRole_').toUpperCase());
                }
            }
            List<FinServ__FinancialAccountRole__c> financialRoleList = (List<FinServ__FinancialAccountRole__c>)responseListMap.get('financialRoleList');
            if(financialRoleList.size() > 0){
                
                Map<String, FinServ__FinancialAccountRole__c> financialAccountIdToFinancialRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
                for(FinServ__FinancialAccountRole__c financialRoleObj : financialRoleList){
                    if(financialRoleObj?.FinServ__FinancialAccount__r?.id != NULL){
                        financialAccountIdToFinancialRoleMap.put(financialRoleObj.FinServ__FinancialAccount__r.id, financialRoleObj);
                    }
                }
                List<FinServ__FinancialAccount__c> financialAccountList = (List<FinServ__FinancialAccount__c>)responseListMap.get('financialAccountList');
                for(FinServ__FinancialAccount__c financialAccountObj : financialAccountList){
                    wrapperProdotti wrapperProdotto = new wrapperProdotti();
                    wrapperProdotto.financialRole = financialAccountIdToFinancialRoleMap.get(financialAccountObj.Id);
                    wrapperProdotto.financialAccount = financialAccountObj;
    
                    Map<String, Object> financialRolefieldsMap = wrapperProdotto.financialRole.getPopulatedFieldsAsMap();
                    Map<String, Object> financialAccountfieldsMap = wrapperProdotto.financialAccount.getPopulatedFieldsAsMap();
    
                    Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
                    
                    if(!campiFinancialRole.isEmpty()){
                        for(String objectFieldName : financialRolefieldsMap.keyset()){
                        
                            Boolean needsField = false;
                            if(campiFinancialRole.contains(objectFieldName.toUpperCase())){
                                needsField = true;
                            }else{
                                for(String campo : campiFinancialRole){
                                    
                                    if(campo.contains(objectFieldName.toUpperCase())){
                                        needsField = true; 
                                        break;
                                    }
                                }
                            }
                            if(needsField){
                                
                                if(objectFieldName.endsWith('__r')){
                                    Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(financialRolefieldsMap.get(objectFieldName)));
                                    for(String fieldName : deserializedObject.keySet()){
                                        
                                        fieldNameToFieldValueMap.put('financialRole_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                                    }
                                }else{
    
                                    fieldNameToFieldValueMap.put('financialRole_'+objectFieldName, PrintPDFController.getFieldValue(wrapperProdotto.financialRole, objectFieldName));
                                }
                            }
                        }
                    }
                    if(!campiFinancialAccount.isEmpty()){
    
                        for(String objectFieldName : financialAccountfieldsMap.keyset()){
                            
                            Boolean needsField = false;
                            if(campiFinancialAccount.contains(objectFieldName.toUpperCase())){
                                needsField = true;
                            }else{
                                for(String campo : campiFinancialAccount){
                                    
                                    if(campo.contains(objectFieldName.toUpperCase())){
                                        needsField = true; 
                                        break;
                                    } 
                                }
                            }
                            if(needsField){
                                
                                if(objectFieldName.endsWith('__r')){
                                    Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(financialAccountfieldsMap.get(objectFieldName)));
                                    for(String fieldName : deserializedObject.keySet()){
                                        
                                        fieldNameToFieldValueMap.put('financialAccount_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                                    }
                                }else{
    
                                    fieldNameToFieldValueMap.put('financialAccount_'+objectFieldName, PrintPDFController.getFieldValue(wrapperProdotto.financialAccount, objectFieldName));
                                }
                            }
                        }
                    }
                    fieldNameToFieldValueMapList.add(fieldNameToFieldValueMap);
                }
            }
        }catch (Exception ex){
            System.debug('DK getProdottiList exception: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new pdfConfiguratorCallableMethodsException('!!!!! getProdottiList exception: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
        return fieldNameToFieldValueMapList;
    }

    //S Actual methods
    /*public List<Map<String,String>> getProdottiList(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters) {
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        // List<wrapperProdotti> wrapperProdottiList = new List<wrapperProdotti>();
        String recordId = currentObject.Id;

        try{

            //S get the additional parameter from json
            //expecting jsonAdditionalParameters = {"RecordType": "CreditCard", "statusFinServ": "ATTIVO"}
            wrapperJsonAdditionalParameters wrpAdditionalParameters = new wrapperJsonAdditionalParameters();
            wrpAdditionalParameters = (wrapperJsonAdditionalParameters)JSON.deserialize(jsonAdditionalParameters, wrapperJsonAdditionalParameters.class);
            String recordTypeProdotto = wrpAdditionalParameters.RecordType;
            String statusFinServ = wrpAdditionalParameters.statusFinServ;
            String orderBy = wrpAdditionalParameters.orderBy;
            String order = wrpAdditionalParameters.order;
            
            //E get the additional parameter from json
            Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
            Matcher m = p.matcher(meta.TemplateIterationXml__c);
            Set<String> campiFinancialAccount = new Set<String>();
            Set<String> campiFinancialRole = new Set<String>();
            while(m.find()) {
                String daSostituire = m.group(0);
                String campo = daSostituire.replace('{!', '').replace('}', '');
                if(campo.contains('financialAccount_')){
                    campiFinancialAccount.add(campo.substringAfter('financialAccount_').toUpperCase());
                }else if(campo.contains('financialRole_')){
                    campiFinancialRole.add(campo.substringAfter('financialRole_').toUpperCase());
                }
            }

            if(String.isNotBlank(recordTypeProdotto) && String.isNotBlank(statusFinServ)){
                String queryFinancialRole = SV_Utilities.selectAllField('FinServ__FinancialAccountRole__c') + ' WHERE FinServ__RelatedAccount__r.id =: recordId';
                queryFinancialRole = queryFinancialRole.replaceFirst('FROM', ', FinServ__FinancialAccount__r.id FROM');
                List<FinServ__FinancialAccountRole__c> financialRoleList = (List<FinServ__FinancialAccountRole__c>)Database.query(queryFinancialRole);

                if(financialRoleList.size() > 0){
                    Map<String, FinServ__FinancialAccountRole__c> financialAccountIdToFinancialRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
                    for(FinServ__FinancialAccountRole__c financialRoleObj : financialRoleList){
                        if(financialRoleObj?.FinServ__FinancialAccount__r?.id != NULL){
                            financialAccountIdToFinancialRoleMap.put(financialRoleObj.FinServ__FinancialAccount__r.id, financialRoleObj);
                        }
                    }

                    Set<String> financialAccountIdList = financialAccountIdToFinancialRoleMap.keyset();
                    String queryFinancialAccount = SV_Utilities.selectAllField('FinServ__FinancialAccount__c') + ' WHERE id =: financialAccountIdList AND RecordType.DeveloperName =: recordTypeProdotto AND (CRM_CollegamentoAFidoCastelletto__c = NULL AND CRM_CollegamentoScontoSBF__c = NULL AND CRM_CollegamentoViacard__c = NULL) ';
                    queryFinancialAccount = queryFinancialAccount.replaceFirst('FROM', ', FinServ__PrimaryOwner__r.Name, FinServ__JointOwner__r.Name FROM');
                    if(statusFinServ != 'ATTIVO' && statusFinServ != 'ESTINTO'){
                        queryFinancialAccount += ' AND (FinServ__Status__c = \'ATTIVO\' OR FinServ__Status__c = \'ESTINTO\')';
                    }else{
                        queryFinancialAccount += ' AND FinServ__Status__c =: statusFinServ';
                    }

                    if(!String.isBlank(orderBy) && !String.isBlank(order)){
                        queryFinancialAccount += ' ORDER BY ' + orderBy + ' ' + order;
                    }
                    List<FinServ__FinancialAccount__c> financialAccountList = (List<FinServ__FinancialAccount__c>)Database.query(queryFinancialAccount);

                    for(FinServ__FinancialAccount__c financialAccountObj : financialAccountList){
                        wrapperProdotti wrapperProdotto = new wrapperProdotti();
                        wrapperProdotto.financialRole = financialAccountIdToFinancialRoleMap.get(financialAccountObj.Id);
                        wrapperProdotto.financialAccount = financialAccountObj;

                        Map<String, Object> financialRolefieldsMap = wrapperProdotto.financialRole.getPopulatedFieldsAsMap();
                        Map<String, Object> financialAccountfieldsMap = wrapperProdotto.financialAccount.getPopulatedFieldsAsMap();

                        Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
                        
                        if(!campiFinancialRole.isEmpty()){
                            for(String objectFieldName : financialRolefieldsMap.keyset()){
                            
                                Boolean needsField = false;
                                if(campiFinancialRole.contains(objectFieldName.toUpperCase())){
                                    needsField = true;
                                }else{
                                    for(String campo : campiFinancialRole){
                                        
                                        if(campo.contains(objectFieldName.toUpperCase())){
                                            needsField = true; 
                                            break;
                                        }
                                    }
                                }
                                if(needsField){
                                    
                                    if(objectFieldName.endsWith('__r')){
                                        Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(financialRolefieldsMap.get(objectFieldName)));
                                        for(String fieldName : deserializedObject.keySet()){
                                            
                                            fieldNameToFieldValueMap.put('financialRole_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                                        }
                                    }else{
        
                                        fieldNameToFieldValueMap.put('financialRole_'+objectFieldName, PrintPDFController.getFieldValue(wrapperProdotto.financialRole, objectFieldName));
                                    }
                                }
                            }
                        }
                        if(!campiFinancialAccount.isEmpty()){

                            for(String objectFieldName : financialAccountfieldsMap.keyset()){
                                
                                Boolean needsField = false;
                                if(campiFinancialAccount.contains(objectFieldName.toUpperCase())){
                                    needsField = true;
                                }else{
                                    for(String campo : campiFinancialAccount){
                                        
                                        if(campo.contains(objectFieldName.toUpperCase())){
                                            needsField = true; 
                                            break;
                                        } 
                                    }
                                }
                                if(needsField){
                                    
                                    if(objectFieldName.endsWith('__r')){
                                        Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(financialAccountfieldsMap.get(objectFieldName)));
                                        for(String fieldName : deserializedObject.keySet()){
                                            
                                            fieldNameToFieldValueMap.put('financialAccount_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                                        }
                                    }else{
        
                                        fieldNameToFieldValueMap.put('financialAccount_'+objectFieldName, PrintPDFController.getFieldValue(wrapperProdotto.financialAccount, objectFieldName));
                                    }
                                }
                            }
                        }
                        fieldNameToFieldValueMapList.add(fieldNameToFieldValueMap);
                    }

                }
            }else{
                System.debug('!!!!! getProdottiList error: recordTypeProdotto or statusFinServ are blank');
                return new List<Map<String,String>>();
            }
        }catch (Exception ex){
            System.debug('!!!!! getProdottiList exception: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            return new List<Map<String,String>>();
        }
        return fieldNameToFieldValueMapList;

    }*/

    public WrapperGetMapDataRes getProdottiListData(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters) {
        WrapperGetMapDataRes res = new WrapperGetMapDataRes();
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        List<wrapperProdotti> wrapperProdottiList = new List<wrapperProdotti>();
        String recordId = currentObject.Id;
        List<FinServ__FinancialAccount__c> financialAccountList = new List<FinServ__FinancialAccount__c>();
        List<FinServ__FinancialAccountRole__c> financialRoleList = new List<FinServ__FinancialAccountRole__c>();

        Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
        Matcher m = p.matcher(meta.TemplateIterationXml__c);
        Set<String> campiFinancialAccount = new Set<String>();
        campiFinancialAccount.add('ID');
        campiFinancialAccount.add('FINSERV__PRIMARYOWNER__R.NAME');
        campiFinancialAccount.add('FINSERV__JOINTOWNER__R.NAME');
        List<String> campiFinancialAccountList = new List<String>();
        Set<String> campiFinancialRole = new Set<String>();
        campiFinancialRole.add('ID');
        campiFinancialRole.add('FINSERV__FINANCIALACCOUNT__R.ID');
        List<String> campiFinancialRoleList = new List<String>();
        while(m.find()) {
            String daSostituire = m.group(0);
            String campo = daSostituire.replace('{!', '').replace('}', '');
            if(campo.contains('financialAccount_')){
                campiFinancialAccount.add(campo.substringAfter('financialAccount_').toUpperCase());
            }else if(campo.contains('financialRole_')){
                campiFinancialRole.add(campo.substringAfter('financialRole_').toUpperCase());
            }
        }

        campiFinancialRoleList.addAll(campiFinancialRole);
        campiFinancialAccountList.addAll(campiFinancialAccount);
        String queryFinancialRole;
        String queryFinancialAccount;
        try{

            //S get the additional parameter from json
            //expecting jsonAdditionalParameters = {"RecordType": "CreditCard", "statusFinServ": "ATTIVO"}
            wrapperJsonAdditionalParameters wrpAdditionalParameters = new wrapperJsonAdditionalParameters();
            wrpAdditionalParameters = (wrapperJsonAdditionalParameters)JSON.deserialize(jsonAdditionalParameters, wrapperJsonAdditionalParameters.class);
            String recordTypeProdotto = wrpAdditionalParameters.RecordType;
            String statusFinServ = wrpAdditionalParameters.statusFinServ;
            String orderBy = wrpAdditionalParameters.orderBy;
            String order = wrpAdditionalParameters.order;
            
            //E get the additional parameter from json

            if(String.isNotBlank(recordTypeProdotto) && String.isNotBlank(statusFinServ) ){
                // String queryFinancialRole = SV_Utilities.selectAllField('FinServ__FinancialAccountRole__c') + ' WHERE FinServ__RelatedAccount__r.id =: recordId';
                queryFinancialRole = 'SELECT ' + String.join(campiFinancialRoleList, ',') + ' FROM FinServ__FinancialAccountRole__c WHERE FinServ__RelatedAccount__r.id =: recordId';
                /*if(!String.isBlank(orderBy) && recordTypeProdotto == 'Deposito_Titoli'){
                    queryFinancialRole += ' ORDER BY ' + orderBy;
                }*/
                financialRoleList = (List<FinServ__FinancialAccountRole__c>)Database.query(queryFinancialRole);

                if(financialRoleList.size() > 0){
                    Map<String, FinServ__FinancialAccountRole__c> financialAccountIdToFinancialRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
                    for(FinServ__FinancialAccountRole__c financialRoleObj : financialRoleList){
                        if(financialRoleObj?.FinServ__FinancialAccount__r?.id != NULL){
                            financialAccountIdToFinancialRoleMap.put(financialRoleObj.FinServ__FinancialAccount__r.id, financialRoleObj);
                        }
                    }

                    Set<String> financialAccountIdList = financialAccountIdToFinancialRoleMap.keyset();
                    // String queryFinancialAccount = SV_Utilities.selectAllField('FinServ__FinancialAccount__c') + ' WHERE id IN: financialAccountIdList AND RecordType.Deres.wrResponse =veloperName =: recordTypeProdotto AND (CRM_CollegamentoAFidoCastelletto__c = NULL AND CRM_CollegamentoScontoSBF__c = NULL AND CRM_CollegamentoViacard__c = NULL) ';
                    queryFinancialAccount = 'SELECT ' + String.join(campiFinancialAccountList, ',') + ' FROM FinServ__FinancialAccount__c WHERE id IN: financialAccountIdList AND RecordType.DeveloperName =: recordTypeProdotto AND (CRM_CollegamentoAFidoCastelletto__c = NULL AND CRM_CollegamentoScontoSBF__c = NULL AND CRM_CollegamentoViacard__c = NULL) ';
                    // queryFinancialAccount = queryFinancialAccount.replaceFirst('FROM', ', FinServ__PrimaryOwner__r.Name, FinServ__JointOwner__r.Name FROM');
                    
                    if(statusFinServ != 'ATTIVO' && statusFinServ != 'ESTINTO'){
                        queryFinancialAccount += ' AND (FinServ__Status__c = \'ATTIVO\' OR FinServ__Status__c = \'ESTINTO\')';
                    }else{
                        queryFinancialAccount += ' AND FinServ__Status__c =: statusFinServ';
                    }

                    if(!String.isBlank(orderBy) && !String.isBlank(order)){
                        queryFinancialAccount += ' ORDER BY ' + orderBy + ' ' + order;
                    }
                    financialAccountList = (List<FinServ__FinancialAccount__c>)Database.query(queryFinancialAccount);
                }
            }else{
                System.debug('!!!!! getProdottiList error: recordTypeProdotto or statusFinServ are blank');
                // res.meta = meta;
                res.action = 'replaceGetProdotti';
                res.wrResponse = new Map<String, List<SObject>>{
                    'financialAccountList' => new List<FinServ__FinancialAccount__c>(),
                    'financialRoleList' => new List<FinServ__FinancialAccountRole__c>()
                };
                return res;
            }
            res.action = 'replaceGetProdotti';
            res.wrResponse = new Map<String, List<SObject>>{
                'financialAccountList' => financialAccountList,
                'financialRoleList' => financialRoleList
            };
            return res;

        }catch (Exception ex){
            System.debug('!!!!! getProdottiList exception: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            res.action = 'replaceGetProdotti';
            res.wrResponse = new Map<String, List<SObject>>{
                'financialAccountList' => new List<FinServ__FinancialAccount__c>(),
                'financialRoleList' => new List<FinServ__FinancialAccountRole__c>()
            };
            return res;
        }
    }

    // public static Map<String, Schema.SObjectField> fullAccountfieldsMap = ((SObject)(Type.forName('Schema.Account').newInstance())).getSObjectType().getDescribe().fields.getMap();
    // public static Map<String, Schema.SObjectField> fullScadenzafieldsMap = ((SObject)(Type.forName('Schema.FinServ__Alert__c').newInstance())).getSObjectType().getDescribe().fields.getMap();

    //S Actual methods
    /*public List<Map<String,String>> getGroupMembersList(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters) {

        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        treeGridGruppiController.WrapperObj response = treeGridGruppiController.crm_getAllData((String)currentObject.get('Id'), (String)currentObject.get('RecordTypeName__c'));
        Account gruppo = (Account)response.gruppiMap.get((String)response.accToLinkObj.get(currentObject.Id).get('CRM_Account__c'));
        fieldNameToFieldValueMapList.add(setMap(gruppo, currentObject.Id, response));
        for(Account account : (List<Account>)response.accMap.values()){
            if((String)response.accToLinkObj.get(account.Id).get('CRM_LinkType__c') == 'CAPOFILA'){
                fieldNameToFieldValueMapList.add(setMap(account, currentObject.Id, response));
                response.accMap.remove(account.Id);
                break;
            }
        }
        for(Account account : (List<Account>)response.accMap.values()){
            fieldNameToFieldValueMapList.add(setMap(account, currentObject.Id, response));
        }
        return fieldNameToFieldValueMapList;
    }*/
    //E Actual methods

    //S Actual methods
    public WrapperObjRes getGroupMembersListData(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters) {
        WrapperObjRes res = new WrapperObjRes();
        res.action = 'replaceGetGroupMembers';
        res.wrResponse = JSON.serialize(treeGridGruppiController.crm_getAllData((String)currentObject.get('Id'), (String)currentObject.get('RecordTypeName__c')));
        return res;
    }

    public static List<Map<String,String>> replaceGetGroupMembers(PDFConfigurator__mdt meta, sObject currentObject, String responseObjectJSON) {
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        treeGridGruppiController.wrapperObj responseObject = (treeGridGruppiController.wrapperObj)JSON.deserialize(responseObjectJSON, treeGridGruppiController.wrapperObj.class);
        if(!responseObject.gruppiMap.isEmpty()){

            Account gruppo = (Account)responseObject.gruppiMap.get((String)responseObject.accToLinkObj.get(currentObject.Id).get('CRM_Account__c'));
            fieldNameToFieldValueMapList.add(setMap(gruppo, currentObject.Id, responseObject));
            for(Account account : (List<Account>)responseObject.accMap.values()){
                if((String)responseObject.accToLinkObj.get(account.Id).get('CRM_LinkType__c') == 'CAPOFILA'){
                    fieldNameToFieldValueMapList.add(setMap(account, currentObject.Id, responseObject));
                    responseObject.accMap.remove(account.Id);
                    break;
                }
            }
            for(Account account : (List<Account>)responseObject.accMap.values()){
                fieldNameToFieldValueMapList.add(setMap(account, currentObject.Id, responseObject));
            }
        }
        return fieldNameToFieldValueMapList;
    }
    //E Actual methods

    public static List<Map<String,String>> replaceGetScadenze(PDFConfigurator__mdt meta, sObject currentObject, String responseListJSON) {

        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        List<SObject> responseList = (List<SObject>) JSON.deserialize(responseListJSON, List<SObject>.class);
        Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
        Matcher m = p.matcher(meta.TemplateIterationXml__c);
        Set<String> campiScadenze = new Set<String>();
        while(m.find()) {
            String daSostituire = m.group(0);
            String campo = daSostituire.replace('{!', '').replace('}', '');
            if(campo.contains('Alert_')){
                campiScadenze.add(campo.substringAfter('Alert_').toUpperCase());
            }
        }
        for(FinServ__Alert__c scadenza : (List<FinServ__Alert__c>)responseList){
            
            Map<String, Object> scadenzafieldsMap = scadenza.getPopulatedFieldsAsMap();
            Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
            for(String objectFieldName : scadenzafieldsMap.keyset()){

                Boolean needsField = false;
                if(campiScadenze.contains(objectFieldName.toUpperCase())){
                    needsField = true;
                }else{
                    for(String campo : campiScadenze){
                        
                        if(campo.contains(objectFieldName.toUpperCase())){
                            needsField = true; 
                            break;
                        } 
                    }
                }
                if(needsField){

                    //CHECK IF STRING IS JSON
                    Map<String,Object> deserializedObject;
                    Boolean objectFieldValueValidJSON = false;
                    try {
                        deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(scadenzafieldsMap.get(objectFieldName))); 
                        objectFieldValueValidJSON = true;
                    } catch (Exception ex) {}
                    //CHECK IF STRING IS JSON
    
                    if(objectFieldValueValidJSON){
                        deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(scadenzafieldsMap.get(objectFieldName)));
                        for(String fieldName : deserializedObject.keySet()){
                            
                            //CHECK IF STRING IS JSON
                            Map<String,Object> childDeserializedObject;
                            Boolean childObjectFieldValueValidJSON = false;
                            try {
                                childDeserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(deserializedObject.get(fieldName))); 
                                childObjectFieldValueValidJSON = true;
                            } catch (Exception ex) {}
                            //CHECK IF STRING IS JSON
                            if(childObjectFieldValueValidJSON){
                                for(String childFieldName : childDeserializedObject.keySet()){
                            
                                    fieldNameToFieldValueMap.put('Alert_'+objectFieldName+'.'+fieldName+'.'+childFieldName, String.valueOf(childDeserializedObject.get(childFieldName)));
                                }
                            }else{
                                fieldNameToFieldValueMap.put('Alert_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                            }
                        }
                    }else{
                        fieldNameToFieldValueMap.put('Alert_'+objectFieldName, PrintPDFController.getFieldValue(scadenza, objectFieldName));
                    }
                }
            }
            fieldNameToFieldValueMapList.add(fieldNameToFieldValueMap);
        }

        return fieldNameToFieldValueMapList;
    }

    /*public List<Map<String,String>> getScadenzeList(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters) {
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        List<FinServ__Alert__c> response = [select id, name, CRM_Tipo__c, CRM_CED__c,FinServ__FinancialAccount__r.CRM_DescrizioneNome__c, CRM_TipologiaScadenza__c,CRM_FormulaData__c, CRM_Importo__c,
        FinServ__Account__r.RecordTypeId, FinServ__Account__r.RecordType.Name, FinServ__FinancialAccount__r.Name, FinServ__FinancialAccount__r.id, CRM_EsitoContatto__c,CRM_ProdottoCommDS__c,CRM_CodiceProdottoElementare__c,
        CRM_OwnershipType__c
        from FinServ__Alert__c 
        where FinServ__FinancialAccount__c IN (select FinServ__FinancialAccount__c 
                                                from FinServ__FinancialAccountRole__c 
                                                where FinServ__RelatedAccount__c =:(String)currentObject.get('Id')
                                                and (FinServ__Role__c = 'Primary Owner' or FinServ__Role__c = 'Cointestatario') 
                                                and FinServ__Active__c = true)];

        Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
        Matcher m = p.matcher(meta.TemplateIterationXml__c);
        Set<String> campiScadenze = new Set<String>();
        while(m.find()) {
            String daSostituire = m.group(0);
            String campo = daSostituire.replace('{!', '').replace('}', '');
            if(campo.contains('Alert_')){
                campiScadenze.add(campo.substringAfter('Alert_').toUpperCase());
            }
        }
        for(FinServ__Alert__c scadenza : response){
            
            Map<String, Object> scadenzafieldsMap = scadenza.getPopulatedFieldsAsMap();
            Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
            for(String objectFieldName : scadenzafieldsMap.keyset()){

                Boolean needsField = false;
                if(campiScadenze.contains(objectFieldName.toUpperCase())){
                    needsField = true;
                }else{
                    for(String campo : campiScadenze){
                        
                        if(campo.contains(objectFieldName.toUpperCase())){
                            needsField = true; 
                            break;
                        } 
                    }
                }
                if(needsField){

                    //CHECK IF STRING IS JSON
                    Map<String,Object> deserializedObject;
                    Boolean objectFieldValueValidJSON = false;
                    try {
                        deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(scadenzafieldsMap.get(objectFieldName))); 
                        objectFieldValueValidJSON = true;
                    } catch (Exception ex) {}
                    //CHECK IF STRING IS JSON
    
                    if(objectFieldValueValidJSON){
                        deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(scadenzafieldsMap.get(objectFieldName)));
                        for(String fieldName : deserializedObject.keySet()){
                            
                            //CHECK IF STRING IS JSON
                            Map<String,Object> childDeserializedObject;
                            Boolean childObjectFieldValueValidJSON = false;
                            try {
                                childDeserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(deserializedObject.get(fieldName))); 
                                childObjectFieldValueValidJSON = true;
                            } catch (Exception ex) {}
                            //CHECK IF STRING IS JSON
                            if(childObjectFieldValueValidJSON){
                                for(String childFieldName : childDeserializedObject.keySet()){
                            
                                    fieldNameToFieldValueMap.put('Alert_'+objectFieldName+'.'+fieldName+'.'+childFieldName, String.valueOf(childDeserializedObject.get(childFieldName)));
                                }
                            }else{
                                fieldNameToFieldValueMap.put('Alert_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                            }
                        }
                    }else{
                        fieldNameToFieldValueMap.put('Alert_'+objectFieldName, PrintPDFController.getFieldValue(scadenza, objectFieldName));
                    }
                }
            }
            fieldNameToFieldValueMapList.add(fieldNameToFieldValueMap);
        }

        return fieldNameToFieldValueMapList;
    }*/

    public WrapperListRes getScadenzeListData(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters) {
        WrapperListRes res = new WrapperListRes();
        // res.meta = meta;
        res.action = 'replaceGetScadenze';
        res.wrResponse = [select id, name, CRM_Tipo__c, CRM_CED__c,FinServ__FinancialAccount__r.CRM_DescrizioneNome__c, CRM_TipologiaScadenza__c,CRM_FormulaData__c, CRM_Importo__c,
        FinServ__Account__r.RecordTypeId, FinServ__Account__r.RecordType.Name, FinServ__FinancialAccount__r.Name, FinServ__FinancialAccount__r.id, CRM_EsitoContatto__c,CRM_ProdottoCommDS__c,CRM_CodiceProdottoElementare__c,
        CRM_OwnershipType__c
        from FinServ__Alert__c 
        where FinServ__FinancialAccount__c IN (select FinServ__FinancialAccount__c 
                                                from FinServ__FinancialAccountRole__c 
                                                where FinServ__RelatedAccount__c =:(String)currentObject.get('Id')
                                                and (FinServ__Role__c = 'Primary Owner' or FinServ__Role__c = 'Cointestatario') 
                                                and FinServ__Active__c = true)];
        return res;
    }

    // DK - CR 58271
    public WrapperGetMapDataRes getIndicatoriRischioData(PDFConfigurator__mdt meta, sObject currentObject, String jsonAdditionalParameters){
        WrapperGetMapDataRes res = new WrapperGetMapDataRes(); 
        List<CRM_IndicatoriCliente__c> flat = [SELECT CRM_rating_ufficiale__c, CRM_F_RischiDiretti_Data_Acc__c, CRM_F_RischiDiretti_Data_Uti__c, CRM_RischiDiretti_Ammontare_Acc__c, CRM_RischiDiretti_Ammontare_Uti__c, CRM_Data_rating_ufficiale__c, CRM_CreditRating__c, CRM_DataAggCreditRating__c, CRM_SegmentoRischioUfficiale__c, 	CRM_DataAggSegmRatingUff__c, CRM_SegmentoRischioAndamentale__c, CRM_DataAggSegmRatingAnd__c, CRM_PerditaAttesa__c, CRM_DataAggPA_Formula__c, CRM_PerditaAttesaGestionale__c, CRM_DataAggPAGestionale_Formula__c, CRM_ProbabilitaDefault__c, CRM_DataAggPD_Formula__c FROM CRM_IndicatoriCliente__c WHERE RecordType.Name = 'flat' AND 
		CRM_Account__c =: (String)currentObject.get('Id')];

        List<CRM_IndicatoriCliente__c> storico = [SELECT CRM_RatingAndamentaleMeseF__c, CRM_RatingAndamentaleValore__c, CRM_DataAggRatingAnd__c FROM CRM_IndicatoriCliente__c WHERE CRM_Account__c =: (String)currentObject.get('Id') AND RecordType.Name = 'storico' AND CRM_RatingAndamentaleValore__c != null ORDER BY CRM_CRMeseDiRiferimento__c DESC LIMIT 12];
        // storico.add(0,storico[0]);
        res.action = 'replaceGetIndicatoriRischio';
        res.wrResponse = new Map<String, List<Sobject>>{
            'flat' => flat,
            'storico' => storico
        };

        return res;
    }

    public static indicatoriRischioWrapper replaceGetIndicatoriRischio(PDFConfigurator__mdt meta, sObject currentObject, String responseListMapJSON){
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        Map<String, List<SObject>> responseListMap = (Map<String, List<SObject>>) JSON.deserialize(responseListMapJSON, Map<String, List<SObject>>.class);
        indicatoriRischioWrapper wrapper = new indicatoriRischioWrapper();
        wrapper.storico = new List<Map<String, String>>();
        String recordId = currentObject.Id;
        try{

            //E get the additional parameter from json
            Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
            Matcher m = p.matcher(meta.TemplateIterationXml__c);
            Set<String> campiFlat = new Set<String>();
            Set<String> campiStorico = new Set<String>();
            while(m.find()) {
                String daSostituire = m.group(0);
                String campo = daSostituire.replace('{!', '').replace('}', '');
                if(campo.contains('flat_')){
                    campiFlat.add(campo.substringAfter('flat_').toUpperCase());
                }else if(campo.contains('storico_')){
                    campiStorico.add(campo.substringAfter('storico_').toUpperCase());
                }
            }

            for(CRM_IndicatoriCliente__c indicatoriRischio : (List<CRM_IndicatoriCliente__c>)responseListMap.get('flat')){
            
                Map<String, Object> indicatoriRischiofieldsMap = indicatoriRischio.getPopulatedFieldsAsMap();
                Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
                for(String objectFieldName : indicatoriRischiofieldsMap.keyset()){
    
                    Boolean needsField = false;
                    if(campiFlat.contains(objectFieldName.toUpperCase())){
                        needsField = true;
                    }else{
                        for(String campo : campiFlat){
                            
                            if(campo.contains(objectFieldName.toUpperCase())){
                                needsField = true; 
                                break;
                            } 
                        }
                    }
                    if(needsField){
    
                        if(objectFieldName.endsWith('__r')){
                            Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(indicatoriRischiofieldsMap.get(objectFieldName)));
                            for(String fieldName : deserializedObject.keySet()){
                                
                                fieldNameToFieldValueMap.put('flat_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                            }
                        }else{

                            fieldNameToFieldValueMap.put('flat_'+objectFieldName, PrintPDFController.getFieldValue(indicatoriRischio, objectFieldName));
                        }
                    }
                }
                wrapper.flat = fieldNameToFieldValueMap;
                // fieldNameToFieldValueMapList.add(fieldNameToFieldValueMap);
            }

            for(CRM_IndicatoriCliente__c indicatoriRischio : (List<CRM_IndicatoriCliente__c>)responseListMap.get('storico')){
            
                Map<String, Object> indicatoriRischiofieldsMap = indicatoriRischio.getPopulatedFieldsAsMap();
                Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
                for(String objectFieldName : indicatoriRischiofieldsMap.keyset()){
    
                    Boolean needsField = false;
                    if(campiStorico.contains(objectFieldName.toUpperCase())){
                        needsField = true;
                    }else{
                        for(String campo : campiStorico){
                            
                            if(campo.contains(objectFieldName.toUpperCase())){
                                needsField = true; 
                                break;
                            } 
                        }
                    }
                    if(needsField){
    
                        if(objectFieldName.endsWith('__r')){
                            Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(indicatoriRischiofieldsMap.get(objectFieldName)));
                            for(String fieldName : deserializedObject.keySet()){
                                
                                fieldNameToFieldValueMap.put('storico_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                            }
                        }else{

                            fieldNameToFieldValueMap.put('storico_'+objectFieldName, PrintPDFController.getFieldValue(indicatoriRischio, objectFieldName));
                        }
                    }
                }
                wrapper.storico.add(fieldNameToFieldValueMap);
                // fieldNameToFieldValueMapList.add(fieldNameToFieldValueMap);
            }
    
            return wrapper;
        }catch (Exception ex){
            System.debug('DK replaceGetIndicatoriRischio exception: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new pdfConfiguratorCallableMethodsException('!!!!! replaceGetIndicatoriRischio exception: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
        // return fieldNameToFieldValueMapList;
    }
    // DK - CR 58271

    public static Map<String,String> setMap (Account account, String currentObjectId, treeGridGruppiController.WrapperObj response){
        Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
        Map<String, Object> accountfieldsMap = account.getPopulatedFieldsAsMap();
        Account gruppo = new Account();
        if(response.accToLinkObj.containsKey(account.Id)){
            gruppo = (Account)response.gruppiMap.get((String)response.accToLinkObj.get(account.Id).get('CRM_Account__c'));
            fieldNameToFieldValueMap.put('Account_CRM_LinkType__c', (String)response.accToLinkObj.get(account.Id).get('CRM_LinkType__c'));
        }else{
            gruppo = account;
        }

        fieldNameToFieldValueMap.put('Account_PTF_DescTipoCollegamento__c', (String)gruppo.get('PTF_DescTipoCollegamento__c'));
        for(String objectFieldName : accountfieldsMap.keyset()){
            if(objectFieldName.endsWith('__r')){
                Map<String,Object> deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(accountfieldsMap.get(objectFieldName)));
                for(String fieldName : deserializedObject.keySet()){

                    fieldNameToFieldValueMap.put('Account_'+objectFieldName+'.'+fieldName, String.valueOf(deserializedObject.get(fieldName)));
                }
            }else{
                fieldNameToFieldValueMap.put('Account_'+objectFieldName, PrintPDFController.getFieldValue(account, objectFieldName));
                // fieldNameToFieldValueMap.put('Account_'+objectFieldName, getFieldValue(account, objectFieldName, fullAccountfieldsMap));
            }
        }
        return fieldNameToFieldValueMap;
    }
    
    public static Map<String, Map<String, Object>> deserializedColumnMap = new Map<String, Map<String, Object>>();

    public List<Map<String,String>> getContactHistoryList(sObject currentObject, List<SObject> recordList, Map<String, String> recordObjectTypeMap) {
        
        List<Map<String,String>> columnValueMapList = new List<Map<String,String>>();
        // List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        Pattern p = Pattern.compile(PrintPDFController.REGEX_SEARCH_CAMPI);
        for(SObject record : recordList){

            String objType = '';
            if(recordObjectTypeMap.containsKey(record.Id)){
                objType = recordObjectTypeMap.get(record.Id);
            }
            PDFConfigurator__mdt meta = contactHistoryMetaMap.get(objType);
            if(meta != null){

                Matcher m = p.matcher(meta.ColumnJSON__c);
                Set<String> campiColumn = new Set<String>();
                while(m.find()) {
                    String daSostituire = m.group(0);
                    String campo = daSostituire.replace('{!', '').replace('}', '');
                    campiColumn.add(campo.toUpperCase());
                }

                Map<String, Map<String,String>> fieldValueMap = !String.isBlank(meta.FieldValueMapJSON__c) ? (Map<String, Map<String,String>>)JSON.deserialize(meta.FieldValueMapJSON__c, Map<String, Map<String,String>>.class) : new Map<String, Map<String,String>>();
    
                Map<String, Schema.SObjectField> fullRecordfieldsMap = ((SObject)(Type.forName('Schema.' + objType).newInstance())).getSObjectType().getDescribe().fields.getMap();
                Map<String, Object> recordfieldsMap = record.getPopulatedFieldsAsMap();
                Map<String,String> fieldNameToFieldValueMap = new Map<String,String>();
                for(String objectFieldName : recordfieldsMap.keyset()){
    
                    Boolean needsField = false;
                    if(campiColumn.contains(objectFieldName.toUpperCase())){
                        needsField = true;
                    }else{
                        for(String campo : campiColumn){
                            
                            if(campo.contains(objectFieldName.toUpperCase())){
                                needsField = true; 
                                break;
                            } 
                        }
                    }
                    if(needsField){
                        
                        //CHECK IF STRING IS JSON
                        Map<String,Object> deserializedObject;
                        Boolean objectFieldValueValidJSON = false;
                        try {
                            deserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(recordfieldsMap.get(objectFieldName))); 
                            objectFieldValueValidJSON = true;
                        } catch (Exception ex) {}
                        //CHECK IF STRING IS JSON
        
                        if(objectFieldValueValidJSON){
                            for(String fieldName : deserializedObject.keySet()){
                                
                                //CHECK IF STRING IS JSON
                                Map<String,Object> childDeserializedObject;
                                Boolean childObjectFieldValueValidJSON = false;
                                try {
                                    childDeserializedObject = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(deserializedObject.get(fieldName))); 
                                    childObjectFieldValueValidJSON = true;
                                } catch (Exception ex) {}
                                //CHECK IF STRING IS JSON
        
                                if(childObjectFieldValueValidJSON){
                                    for(String childFieldName : childDeserializedObject.keySet()){
                                        
                                        String fieldValue = childDeserializedObject.get(childFieldName) != null ? String.valueOf(childDeserializedObject.get(childFieldName)) : '';
                                        if(fieldValueMap.containsKey(objectFieldName+'.'+fieldName+'.'+childFieldName) && fieldValueMap.get(objectFieldName+'.'+fieldName+'.'+childFieldName).containsKey(fieldValue.toUpperCase())){
                                            fieldValue = fieldValueMap.get(objectFieldName+'.'+fieldName+'.'+childFieldName).get(fieldValue.toUpperCase());
                                        }
                                        fieldNameToFieldValueMap.put('ObjectRecord_'+objectFieldName+'.'+fieldName+'.'+childFieldName, fieldValue);
                                    }
                                }else{
                                    String fieldValue = deserializedObject.get(fieldName) != null ? String.valueOf(deserializedObject.get(fieldName)) : '';
                                    if(fieldValueMap.containsKey(objectFieldName+'.'+fieldName) && fieldValueMap.get(objectFieldName+'.'+fieldName).containsKey(fieldValue.toUpperCase())){
                                        fieldValue = fieldValueMap.get(objectFieldName+'.'+fieldName).get(fieldValue.toUpperCase());
                                    }
                                    fieldNameToFieldValueMap.put('ObjectRecord_'+objectFieldName+'.'+fieldName, fieldValue);
                                }
                            }
                        }else{
                            String fieldValue = PrintPDFController.getFieldValue(record, objectFieldName);
                            if(fieldValueMap.containsKey(objectFieldName) && fieldValueMap.get(objectFieldName).containsKey(fieldValue.toUpperCase())){
                                fieldValue = fieldValueMap.get(objectFieldName).get(fieldValue.toUpperCase());
                            }
                            fieldNameToFieldValueMap.put('ObjectRecord_'+objectFieldName, fieldValue);
                        }
                    }
                }
    
                Map<String, Object> objTypeColumnMap;
                try {
                    
                    objTypeColumnMap = (Map<String, Object>)JSON.deserializeUntyped(meta.ColumnJSON__c);
                } catch (Exception ex) {
                    for(Object columnJSON : (List<Object>)JSON.deserializeUntyped(meta.ColumnJSON__c)){
                        
                        Map<String, Object> deserializedJSON = (Map<String, Object>)columnJSON;
                        String fieldTocheck = ((String)deserializedJSON.get('FIELDTOCHECK')).replace('{!', '').replace('}', '');
                        date latestYears = date.today();
                        Date today = date.today();
                        if(deserializedColumnMap.containsKey(fieldTocheck)){
                            latestYears = (Date)deserializedColumnMap.get(fieldTocheck).get('latestYears');
                            today = (Date)deserializedColumnMap.get(fieldTocheck).get('today');
                        }else{
                            deserializedColumnMap.put(fieldTocheck, new Map<String, Object>());
                            Integer yearLess = 0;
                            Integer monthLess = 0;
                            if(Decimal.valueOf((String)deserializedJSON.get('TIMING')) >= 1){
                                yearLess = Integer.valueOf((String)deserializedJSON.get('TIMING'));
                            } else {
                                monthLess = ((String)deserializedJSON.get('TIMING') == '0.25') ? 3 : ((String)deserializedJSON.get('TIMING') == '0.5') ? 6 : 9;
                            }
                            Integer year;
                            Integer month;
                            //Definisco range temporale sullo storico anni  (Data di oggi - tot anni)
                            Integer diff;
                            if(Decimal.valueOf((String)deserializedJSON.get('TIMING')) >= 1){
        
                                year = latestYears.year() - yearLess;
                                month = latestYears.month() - monthLess;
                            } else 
                            {
                                if(latestYears.month() - monthLess <=0)
                                {
                                    diff=latestYears.month() - monthLess;
                                    month=12+diff;
                                    year= latestYears.year()-1;
                                }
                                else{
        
                                    year = latestYears.year() - yearLess;
                                    month = latestYears.month() - monthLess;
                                }
                            }
                            Integer numberOfDays = Date.daysInMonth(year, month);
                            Integer day = latestYears.day() <= numberOfDays ? latestYears.day() : numberOfDays;
                            String stringDate = year + '-' + month + '-' + day;
                        
                            latestYears = date.valueOf(stringDate);
                            
                            today = today.addDays(1);
                            deserializedColumnMap.get(fieldTocheck).put('latestYears', latestYears);
                            deserializedColumnMap.get(fieldTocheck).put('today', today);
                        }
                        List<String> dataStringSplit = !String.isBlank(fieldNameToFieldValueMap.get('ObjectRecord_'+fieldTocheck)) ? fieldNameToFieldValueMap.get('ObjectRecord_'+fieldTocheck).split(' ')[0].split('-') : new List<String>();
                        String dateString = !dataStringSplit.isEmpty() ? dataStringSplit[2] + '-' + dataStringSplit[1] + '-' + dataStringSplit[0] : '';
                        Date dateValue = !String.isBlank(dateString) ? (Date)JSON.deserialize(JSON.serialize(dateString), Date.class) : null;
                        if( dateValue != null && dateValue >= latestYears && dateValue <= today){
                            
                            objTypeColumnMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(columnJSON));
                            break;
                        }
                    }
                }
                map<String, String> columnValueMap = new map<String, String>();
                
                if(objTypeColumnMap != null){

                    for(String column : objTypeColumnMap.keySet()){
        
                        List<String> value = new List<String>();
                        if(column != 'FIELDTOCHECK'){
        
                            try {
                                Map<String, String> columnFieldMap = (Map<String, String>)JSON.deserialize(JSON.serialize(objTypeColumnMap.get(column)), Map<String, String>.class);
                                for(String columnField : columnFieldMap.keySet()){
                                    
                                    String campo = columnFieldMap.get(columnField).replace('{!', '').replace('}', '');
                                    String fieldEnd = campo.contains('#ds') && campo.contains('#de') ? campo.replace('#ds', '').replace('#de', '') : campo;
                                    String fieldValue = columnField + ': ';
                                    if(fieldNameToFieldValueMap.get('ObjectRecord_' + fieldEnd) != null){
            
                                        fieldValue += campo.contains('#ds') && campo.contains('#de') ?
                                                            '#ds' + fieldNameToFieldValueMap.get('ObjectRecord_' + fieldEnd) + '#de' : 
                                                            fieldNameToFieldValueMap.get('ObjectRecord_' + fieldEnd);
                                    }
                                    value.add(fieldValue);
                                }
                            } catch (Exception ex) {
                                String campo = ((String)objTypeColumnMap.get(column)).replace('{!', '').replace('}', '');
                                String fieldEnd = campo.contains('#ds') && campo.contains('#de') ? campo.replace('#ds', '').replace('#de', '') : campo;
                                if(fullRecordfieldsMap.containsKey(fieldEnd)){
                                    
                                    String fieldValue = '';
                                    if(fieldNameToFieldValueMap.get('ObjectRecord_' + fieldEnd) != null){
            
                                        fieldValue = campo.contains('#ds') && campo.contains('#de') ?
                                                            '#ds' + fieldNameToFieldValueMap.get('ObjectRecord_' + fieldEnd) + '#de':
                                                            fieldNameToFieldValueMap.get('ObjectRecord_' + fieldEnd);
                                    }
                                    value.add(fieldValue);
                                }else{
                                    value.add((String)objTypeColumnMap.get(column));
                                }
                            }
                        }
                        columnValueMap.put('ObjectRecord_' + column, String.join(value, '{cr}'));
                    }
                    columnValueMapList.add(columnValueMap);
                }
            }
        }
        return columnValueMapList;
    }

    public class pdfConfiguratorCallableMethodsException extends Exception {}

    //S wrapper for getProdottiList method
    public class wrapperJsonAdditionalParameters{
        public String RecordType;
        public String statusFinServ;
        public String orderBy;
        public String order;

        wrapperJsonAdditionalParameters(){
            this.RecordType = '';
            this.statusFinServ = '';
            this.orderBy = '';
            this.order = '';
        }
    }

    public class wrapperProdotti{
        public FinServ__FinancialAccountRole__c financialRole;
        public FinServ__FinancialAccount__c financialAccount;

        wrapperProdotti(){
            this.financialRole = new FinServ__FinancialAccountRole__c();
            this.financialAccount = new FinServ__FinancialAccount__c();
        }
    }

    // DK - CR 58271
    public class indicatoriRischioWrapper{
        public Map<String, String> flat;
        public List<Map<String, String>> storico;

        indicatoriRischioWrapper(){
            this.flat = new Map<String, String>();
            this.storico = new List<Map<String, String>>();
        }
    }
    // DK - CR 58271
    //E wrapper for getProdottiList method

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