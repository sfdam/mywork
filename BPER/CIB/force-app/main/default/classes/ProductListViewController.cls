public class ProductListViewController {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled(cacheable=false)
    public static WrapperObj getAllData(List<String> objRecordType, String statusFinServ, Id recordId, String fields,String userProfile){
        System.debug('SV getAllData objRecordType: ' + objRecordType);
        System.debug('SV getAllData statusFinServ: ' + statusFinServ);
        System.debug('SV getAllData recordId: ' + recordId);
        System.debug('SV getAllData fields: ' + fields);
        System.debug('SV getAllData userProfiles: ' + userProfile);

        Map<String, SObject> financialAccMap = new Map<String, SObject>();
        Map<String, SObject> financialRoleMap = new Map<String, SObject>();
        Set<String> fieldsOtherObj = new Set<String>();
        Map<String, List<Element>> test = new Map<String, List<Element>>();

        WrapperObj response = new WrapperObj();

        try { 

            WrapperJSON m = (WrapperJSON) JSON.deserializeStrict(fields, WrapperJSON.class);
            System.debug('SV getAllData m: ' + m);


            for(Element e : m.elements){
                System.debug('SV Element e: ' + e);
                if(e.c_object != null && e.c_object != 'FinServ__FinancialAccount__c'){
                    if(test.containsKey(e.c_object)){
                        test.get(e.c_object).add(e);
                    } else {
                        List<Element> x = new List<Element>();
                        x.add(e);
                        test.put(e.c_object, x);
                    }
                }
            }

            System.debug('SV MAP TEST: ' + test);
            if(!String.isBlank(userProfile) && (userProfile=='Operatore di Contact Center'||userProfile=='Supervisor di Contact Center'))
            {
                financialRoleMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__RelatedAccount__c, FinServ__FinancialAccount__c,
                FinServ__FinancialAccount__r.RecordType.DeveloperName, toLabel(FinServ__Role__c), FinServ__Active__c
                FROM FinServ__FinancialAccountRole__c 
                WHERE FinServ__RelatedAccount__c =: recordId AND
                    FinServ__FinancialAccount__r.RecordType.DeveloperName IN : objRecordType ], 'Id', false);
            }
            else if(!String.isBlank(userProfile) && userProfile == 'CRM - Consulenti Finanziari') {
                financialRoleMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__RelatedAccount__c, FinServ__FinancialAccount__c,
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName, toLabel(FinServ__Role__c), FinServ__Active__c
                                                    FROM FinServ__FinancialAccountRole__c 
                                                    WHERE FinServ__RelatedAccount__c =: recordId AND CRM_Flagdelegato__c=false AND
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName IN : objRecordType AND 
                                                        (FinServ__FinancialAccount__r.FinServ__JointOwner__c = null OR 
                                                        (FinServ__FinancialAccount__r.FinServ__JointOwner__r.User_Is_Referente_Portafoglio__c = true AND 
                                                        FinServ__FinancialAccount__r.FinServ__JointOwner__c != null ) ) ], 'Id', false);
            }
            else
            {
                financialRoleMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__RelatedAccount__c, FinServ__FinancialAccount__c,
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName, toLabel(FinServ__Role__c), FinServ__Active__c
                                                    FROM FinServ__FinancialAccountRole__c 
                                                    WHERE FinServ__RelatedAccount__c =: recordId AND CRM_Flagdelegato__c=false AND
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName IN : objRecordType ], 'Id', false);
            }
            System.debug('SV financialRoleMap: ' + financialRoleMap);

            response.financialRoleMap = financialRoleMap;


            Set<Id> financialAccIds = new Set<Id>();
            for (String key : financialRoleMap.keySet()) {
                financialAccIds.add((Id)financialRoleMap.get(key).get('FinServ__FinancialAccount__c'));
            }
            
            System.debug('SV financialAccIds: ' + financialAccIds);

            String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('FinServ__FinancialAccount__c'));
            query += ' WHERE Id IN : financialAccIds AND ';
                        if(statusFinServ == 'ATTIVO'){
                            query += '(FinServ__Status__c = \'ATTIVO\') ';
                        } else if(statusFinServ == 'ESTINTO'){
                            query += '(FinServ__Status__c = \'ESTINTO\') ';
                        } else {
                            query += '(FinServ__Status__c = \'ATTIVO\' OR FinServ__Status__c = \'ESTINTO\') ';
                        }
            query += 'AND (CRM_CollegamentoAFidoCastelletto__c = NULL AND CRM_CollegamentoScontoSBF__c = NULL AND CRM_CollegamentoViacard__c = NULL)';
            query += 'ORDER BY FinServ__Status__c';
            System.debug('SV query: ' + query);

            List<SObject> finAccList = Database.query(query);

            financialAccMap = SV_Utilities.keyBy(finAccList, 'Id', false);
            System.debug('SV financialAccMap: ' + financialAccMap);
            response.financialAccMap = financialAccMap;

            Map<String, Set<Id>> objIds = new Map<String, Set<Id>>();
            System.debug('SV test: ' + test);

            for (String key : financialAccMap.keySet()) {
                for(String finKey : test.keySet()){
                    for(Element e : test.get(finKey)){
                        System.debug('SV Element: ' + e);
                        System.debug('SV finKey: ' + finKey);

                        System.debug('SV XXX: ' + financialAccMap);
                        System.debug('SV objIds: ' + objIds);

                        if(objIds.containsKey(finKey)){
                            objIds.get(finKey).add((Id)financialAccMap.get(key).get(e.field));
                        } else {
                            Set<Id> y = new Set<Id>();
                            y.add((Id)financialAccMap.get(key).get(e.field));
                            objIds.put(finKey, y);
                        }
                    }
                }
            }

            System.debug('SV objIds: ' + objIds);
            Map<String, List<SObject>> otherObjectMap = new Map<String, List<SObject>>();
            if(!objIds.isEmpty()){
                for(String key : test.keySet()){
                    Set<Id> idsSet = objIds.get(key);
                    String queryOtherObj = 'SELECT Id';
                    Set<Id> finAccIds = new Set<Id>();
                    for(Element e : test.get(key)){
                        for(String x : e.objectFields){
                            if(!queryOtherObj.contains(x)) queryOtherObj += ', ' + x;
                        }
                    }
                    queryOtherObj += ' FROM ' + key;
                    queryOtherObj += ' WHERE Id IN : idsSet';
    
                    System.debug('SV queryOtherObj: ' + queryOtherObj);
    
                    List<SObject> xxx = Database.query(queryOtherObj);
                    System.debug('SV xxx: ' + xxx);
    
                    otherObjectMap.put(key, xxx);
                }
            }
            

            response.OtherObjMap = otherObjectMap;

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return response;

    }

    @AuraEnabled(cacheable=true)
    public static Account getRecordInfo(Id recordId){
        System.debug('SV getAllData recordId: ' + recordId);

        return [ SELECT Id, Name, RecordType.DeveloperName FROM Account WHERE Id =: recordId ];

    }

    @AuraEnabled
    public static Map<String, SObject> getObjColumns(List<String> objRecordType){
        System.debug('SV objRecordType: ' + objRecordType);
        
        Map<String, SObject> mtdObjectListViewColumnMap = new Map<String, SObject>();

        try {        
            
            mtdObjectListViewColumnMap  = SV_Utilities.keyBy([SELECT Id, OBJ_RECORDTYPE__c, OBJ_JSON_COLUMNS__c
            FROM ProductListView_Column__mdt 
            WHERE OBJ_RECORDTYPE__c IN : objRecordType], 'OBJ_RECORDTYPE__c', false);



            
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        }  catch (Exception e){
            // This catches the Exception
            System.debug('SV Exception ' + e);
        }
        
        return mtdObjectListViewColumnMap;

    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> financialRoleMap;
        @AuraEnabled public Map<String, SObject> financialAccMap;
        @AuraEnabled public Map<String, Object> OtherObjMap;

    }

    public class Element {

        @AuraEnabled public String field;
        @AuraEnabled public String type;
        @AuraEnabled public String c_object;
        @AuraEnabled public List<String> objectFields;

    }

    public class WrapperJSON {
        @AuraEnabled public List<Element> elements;
    }
    
}