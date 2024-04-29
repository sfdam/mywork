public without sharing class MakeRequestWithActionController {
    
    @AuraEnabled
    public static List<FinServ__FinancialAccount__c> initInfo(String recId){

        List<FinServ__FinancialAccount__c> infoNDG = new List<FinServ__FinancialAccount__c>();
        System.debug('@@@GR recordId: '+ recId);
        
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('FinServ__FinancialAccount__c'));
        query += ' WHERE id =: recId';
        System.debug('GR query: ' + query);
        infoNDG = Database.query(query);
       
        System.debug('@@@GR INFO: '+ infoNDG);
        return infoNDG;
    }
}