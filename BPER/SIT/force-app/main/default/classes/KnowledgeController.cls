public class KnowledgeController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static List<String> getAllArea() {
        List<String> aree = new List<String>();
        SObjectField picklistUsingGlobal = Knowledge__kav.fields.CRM_Area__c;
        List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        for (PicklistEntry pe : entries) aree.add(pe.getLabel());

        return aree;
    }



    @AuraEnabled
    public static Map<String, SObject> getOpenAreaChild(List<String> picklistValue){
        System.debug('SV getOpenAreaChild: ' + picklistValue);

        List<String> picklistValueTranslated = new list<String>();
        Map<String,String> areeMap = new Map<String,String>();
        SObjectField picklistUsingGlobal = Knowledge__kav.fields.CRM_Area__c;
        List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        for (PicklistEntry pe : entries){
        areeMap.put(pe.getLabel(),pe.getValue());
        }
        for(String str : picklistValue){
        picklistValueTranslated.add(areeMap.get(str));

        }
        
        Map<String, SObject> knowledge1 = new Map<String, SObject>();
        try { 

            knowledge1 = SV_Utilities.keyBy([ SELECT Id, Title, ArticleNumber, LastPublishedDate, PublishStatus, 
                                                toLabel(CRM_Area__c), CRM_Scope__c, CRM_Level1__c, CRM_Level2__c,
                                                CRM_Level3__c, CRM_Answer__c, CRM_Question__c, RecordType.Name
                    FROM Knowledge__kav
                    WHERE CRM_Area__c IN : picklistValueTranslated AND PublishStatus = 'Online' ], '{CRM_Area__c}_{CRM_Scope__c}_{Id}', true);
            System.debug('SV AssignAccMap: ' + knowledge1);


        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return knowledge1;

    }

    @AuraEnabled
    public static Map<String, SObject> getOpenScopeChild(List<String> picklistValue){
        System.debug('SV getOpenAreaChild');
        Map<String, SObject> knowledge1 = new Map<String, SObject>();
        try { 

            knowledge1 = SV_Utilities.keyBy([ SELECT Id, Title, ArticleNumber, LastPublishedDate, PublishStatus, 
                                            CRM_Area__c, CRM_Scope__c, CRM_Level1__c, CRM_Level2__c,
                                            CRM_Level3__c, CRM_Answer__c, CRM_Question__c, RecordType.Name
                    FROM Knowledge__kav
                    WHERE CRM_Scope__c IN : picklistValue AND PublishStatus = 'Online' ], '{CRM_Scope__c}_{CRM_Level1__c}_{Id}', true);
            System.debug('SV AssignAccMap: ' + knowledge1);


        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return knowledge1;

    }

    @AuraEnabled
    public static Map<String, SObject> getOpenLevel1Child(List<String> picklistValue){
        System.debug('SV getOpenAreaChild');
        Map<String, SObject> knowledge1 = new Map<String, SObject>();
        try { 

            knowledge1 = SV_Utilities.keyBy([ SELECT Id, Title, ArticleNumber, LastPublishedDate, PublishStatus, 
                                            CRM_Area__c, CRM_Scope__c, CRM_Level1__c, CRM_Level2__c,
                                            CRM_Level3__c, CRM_Answer__c, CRM_Question__c, RecordType.Name
                    FROM Knowledge__kav
                    WHERE CRM_Level1__c IN : picklistValue AND PublishStatus = 'Online' ], '{CRM_Level1__c}_{CRM_Level2__c}_{Id}', true);
            System.debug('SV AssignAccMap: ' + knowledge1);


        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return knowledge1;

    }

    @AuraEnabled
    public static Map<String, SObject> getOpenLevel2Child(List<String> picklistValue){
        System.debug('SV getOpenAreaChild');
        Map<String, SObject> knowledge1 = new Map<String, SObject>();
        try { 

            knowledge1 = SV_Utilities.keyBy([ SELECT Id, Title, ArticleNumber, LastPublishedDate, PublishStatus, 
                                    CRM_Area__c, CRM_Scope__c, CRM_Level1__c, CRM_Level2__c,
                                    CRM_Level3__c, CRM_Answer__c, CRM_Question__c, RecordType.Name 
                    FROM Knowledge__kav
                    WHERE CRM_Level2__c IN : picklistValue AND PublishStatus = 'Online' ], '{CRM_Level2__c}_{CRM_Level3__c}_{Id}', true);
            System.debug('SV AssignAccMap: ' + knowledge1);


        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return knowledge1;

    }

    @AuraEnabled
    public static Map<String, SObject> getOpenLevel3Child(List<String> picklistValue){
        System.debug('SV getOpenAreaChild');
        Map<String, SObject> knowledge1 = new Map<String, SObject>();
        try { 

            knowledge1 = SV_Utilities.keyBy([ SELECT Id, Title, ArticleNumber, LastPublishedDate, PublishStatus, 
                                    CRM_Area__c, CRM_Scope__c, CRM_Level1__c, CRM_Level2__c,
                                    CRM_Level3__c, CRM_Answer__c, CRM_Question__c, RecordType.Name 
                    FROM Knowledge__kav
                    WHERE CRM_Level3__c IN : picklistValue AND PublishStatus = 'Online' ], '{Id}', true);
            System.debug('SV AssignAccMap: ' + knowledge1);


        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return knowledge1;

    }

    @AuraEnabled
    public static User getUserInfo(){
        return [ SELECT Id, Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    @AuraEnabled
    public static List<RecordType> getActiveRecordType(){
        return [ SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Knowledge__kav' AND IsActive = TRUE ];
        
    }

    @AuraEnabled
    public static Map<String, SObject> getAllDataFromText(String queryTerm){
        System.debug('SV queryTerm: ' + queryTerm);
        Map<String, SObject> result = new Map<String, SObject>();

        try{

            String sQuery = 'SELECT Id, RecordType.Name, Title, ArticleNumber, LastPublishedDate, PublishStatus, CRM_Area__c, ' +
            'CRM_Scope__c, ' +
            'CRM_Level1__c, ' + 
            'CRM_Level2__c, ' + 
            'CRM_Level3__c, ' +
            'CRM_Answer__c, ' +
            'CRM_Question__c, ' +
            'CRM_Description__c ' +
            'FROM Knowledge__kav';
            sQuery = sQuery + ' WHERE (CRM_Scope__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level1__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level2__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level3__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Area__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\'';
            // sQuery = sQuery + ' OR CRM_Answer__c LIKE \'%' + queryTerm + '%\'';
            sQuery = sQuery + ' OR CRM_Question__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR Title LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\')';
            // sQuery = sQuery + ' OR CRM_Description__c LIKE \'%' + queryTerm + '%\')';
            sQuery = sQuery + ' AND PublishStatus =\'Online\'';
            sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            result = SV_Utilities.keyBy(lstOfRecords, 'Id', false);




        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }


        return result;
        
    }

    @AuraEnabled
    public static Map<String, SObject> getAllDataForCase(String recordId){
        System.debug('SV getAllDataForCase recordId: ' + recordId);
        Map<String, SObject> result = new Map<String, SObject>();

        try{
            List<String> conditionList = new List<String>();
            List<Case> caseRecord = [ SELECT Id, CRM_Area__c, CRM_Scope__c, CRM_Level1__c, CRM_Level2__c, CRM_Level3__c FROM Case WHERE Id =: recordId ];

            String sQuery = 'SELECT Id, RecordType.Name, Title, ArticleNumber, LastPublishedDate, PublishStatus, ' +
            'CRM_Area__c, ' +
            'CRM_Scope__c, ' +
            'CRM_Level1__c, ' + 
            'CRM_Level2__c, ' + 
            'CRM_Level3__c, ' +
            'CRM_Answer__c, ' +
            'CRM_Question__c, ' +
            'CRM_Description__c ' +
            'FROM Knowledge__kav  WHERE PublishStatus =\'Online\'';
            if(String.isNotEmpty(caseRecord[0].CRM_Area__c)) conditionList.add('CRM_Area__c = \'' + String.escapeSingleQuotes(caseRecord[0].CRM_Area__c) + '\'') ;
            if(String.isNotEmpty(caseRecord[0].CRM_Scope__c)) conditionList.add('CRM_Scope__c = \'' + String.escapeSingleQuotes(caseRecord[0].CRM_Scope__c) + '\''); 
            if(String.isNotEmpty(caseRecord[0].CRM_Level1__c)) conditionList.add('CRM_Level1__c = \'' + String.escapeSingleQuotes(caseRecord[0].CRM_Level1__c) + '\'')  ;
            if(String.isNotEmpty(caseRecord[0].CRM_Level2__c))  conditionList.add('CRM_Level2__c = \'' + String.escapeSingleQuotes(caseRecord[0].CRM_Level2__c) + '\'');
            if(String.isNotEmpty(caseRecord[0].CRM_Level3__c)) conditionList.add('CRM_Level3__c = \'' + String.escapeSingleQuotes(caseRecord[0].CRM_Level3__c) + '\'');
            // sQuery = sQuery + ' OR CRM_Answer__c LIKE \'%' + queryTerm + '%\'';
            // sQuery = sQuery + ' OR CRM_Question__c LIKE \'%' + queryTerm + '%\'';
            // sQuery = sQuery + ' OR CRM_Description__c LIKE \'%' + queryTerm + '%\')';
            if(!conditionList.isEmpty()){
                sQuery= sQuery + ' AND '+String.join(conditionList, ' AND ');
            }
            
            sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            result = SV_Utilities.keyBy(lstOfRecords, 'Id', false);




        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }


        return result;
        
    }

    @AuraEnabled
    public static Map<String, SObject> getAllDataFromTextHCI(String queryTerm){
        System.debug('SV queryTerm: ' + queryTerm);
        Map<String, SObject> result = new Map<String, SObject>();

        try{

            String sQuery = 'SELECT Id, RecordType.Name, Title, ArticleNumber, LastPublishedDate, PublishStatus, CRM_Area__c, ' +
            'CRM_Scope__c, ' +
            'CRM_Level1__c, ' + 
            'CRM_Level2__c, ' + 
            'CRM_Level3__c, ' +
            'CRM_Answer__c, ' +
            'CRM_Question__c, ' +
            'CRM_Description__c, ' +
            'CRM_AmbitoCluster__c, ' +
            'CRM_Cluster__c '+
            'FROM Knowledge__kav';
            sQuery = sQuery + ' WHERE (CRM_Scope__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level1__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level2__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level3__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Area__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\'';
            // sQuery = sQuery + ' OR CRM_Answer__c LIKE \'%' + queryTerm + '%\'';
            sQuery = sQuery + ' OR Title LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_AmbitoCluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Cluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Question__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\')';
            // sQuery = sQuery + ' OR CRM_Description__c LIKE \'%' + queryTerm + '%\')';
            sQuery = sQuery + ' AND PublishStatus =\'Online\'';
            sQuery = sQuery + 'AND (CRM_Portale__c = \'Tutti\' OR CRM_Portale__c = \'Solo portale interno\') AND IsVisibleInPkb = TRUE';
            sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            result = SV_Utilities.keyBy(lstOfRecords, 'Id', false);




        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }


        return result;
        
    }

    @AuraEnabled
    public static Map<String, SObject> getAllDataFromTextHCE(String queryTerm){
        System.debug('SV queryTerm: ' + queryTerm);
        Map<String, SObject> result = new Map<String, SObject>();

        try{

            String sQuery = 'SELECT Id, RecordType.Name, Title, ArticleNumber, LastPublishedDate, PublishStatus, CRM_Area__c, ' +
            'CRM_Scope__c, ' +
            'CRM_Level1__c, ' + 
            'CRM_Level2__c, ' + 
            'CRM_Level3__c, ' +
            'CRM_Answer__c, ' +
            'CRM_Question__c, ' +
            'CRM_Description__c, ' +
            'CRM_AmbitoCluster__c, ' +
            'CRM_Cluster__c '+
            'FROM Knowledge__kav';
            sQuery = sQuery + ' WHERE (CRM_Scope__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level1__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level2__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level3__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Area__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\'';
            // sQuery = sQuery + ' OR CRM_Answer__c LIKE \'%' + queryTerm + '%\'';
            sQuery = sQuery + ' OR Title LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_AmbitoCluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Cluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Question__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\')';
            // sQuery = sQuery + ' OR CRM_Description__c LIKE \'%' + queryTerm + '%\')';
            sQuery = sQuery + ' AND PublishStatus =\'Online\'';
            sQuery = sQuery + 'AND (CRM_Portale__c = \'Tutti\' OR CRM_Portale__c = \'Solo portale esterno\') AND IsVisibleInPkb = TRUE';
            sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            result = SV_Utilities.keyBy(lstOfRecords, 'Id', false);




        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }


        return result;
        
    }

    @AuraEnabled
    public static Map<String, SObject> getAllDataFromTextExUBI(String queryTerm){
        System.debug('SV queryTerm: ' + queryTerm);
        Map<String, SObject> result = new Map<String, SObject>();

        try{

            String sQuery = 'SELECT Id, RecordType.Name, Title, ArticleNumber, LastPublishedDate, PublishStatus, CRM_Area__c, ' +
            'CRM_Scope__c, ' +
            'CRM_Level1__c, ' + 
            'CRM_Level2__c, ' + 
            'CRM_Level3__c, ' +
            'CRM_Answer__c, ' +
            'CRM_Question__c, ' +
            'CRM_Description__c, ' +
            'CRM_AmbitoCluster__c, ' +
            'CRM_Cluster__c '+
            'FROM Knowledge__kav';
            sQuery = sQuery + ' WHERE (CRM_Scope__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level1__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level2__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level3__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Area__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\'';
            // sQuery = sQuery + ' OR CRM_Answer__c LIKE \'%' + queryTerm + '%\'';
            sQuery = sQuery + ' OR Title LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_AmbitoCluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Cluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Question__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\')';
            // sQuery = sQuery + ' OR CRM_Description__c LIKE \'%' + queryTerm + '%\')';
            sQuery = sQuery + ' AND PublishStatus =\'Online\'';
            sQuery = sQuery + 'AND (CRM_Portale__c = \'Tutti\' OR CRM_Portale__c = \'Solo portale Ex-UBI\') AND IsVisibleInPkb = TRUE';
            sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            result = SV_Utilities.keyBy(lstOfRecords, 'Id', false);




        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }


        return result;
        
    }

    @AuraEnabled
    public static Map<String, SObject> getAllDataFromTextExISP(String queryTerm){
        System.debug('SV queryTerm: ' + queryTerm);
        Map<String, SObject> result = new Map<String, SObject>();

        try{

            String sQuery = 'SELECT Id, RecordType.Name, Title, ArticleNumber, LastPublishedDate, PublishStatus, CRM_Area__c, ' +
            'CRM_Scope__c, ' +
            'CRM_Level1__c, ' + 
            'CRM_Level2__c, ' + 
            'CRM_Level3__c, ' +
            'CRM_Answer__c, ' +
            'CRM_Question__c, ' +
            'CRM_Description__c, ' +
            'CRM_AmbitoCluster__c, ' +
            'CRM_Cluster__c '+
            'FROM Knowledge__kav';
            sQuery = sQuery + ' WHERE (CRM_Scope__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level1__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level2__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Level3__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\' OR CRM_Area__c LIKE \'' + String.escapeSingleQuotes(queryTerm) + '%\'';
            // sQuery = sQuery + ' OR CRM_Answer__c LIKE \'%' + queryTerm + '%\'';
            sQuery = sQuery + ' OR Title LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_AmbitoCluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Cluster__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\'';
            sQuery = sQuery + ' OR CRM_Question__c LIKE \'%' + String.escapeSingleQuotes(queryTerm) + '%\')';
            // sQuery = sQuery + ' OR CRM_Description__c LIKE \'%' + queryTerm + '%\')';
            sQuery = sQuery + ' AND PublishStatus =\'Online\'';
            sQuery = sQuery + 'AND (CRM_Portale__c = \'Tutti\' OR CRM_Portale__c = \'Solo portale Ex-ISP\') AND IsVisibleInPkb = TRUE';
            sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            result = SV_Utilities.keyBy(lstOfRecords, 'Id', false);




        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }


        return result;
        
    }
}