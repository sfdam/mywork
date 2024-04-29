/*
AL 2022-08-24 -- Aggiunta query ad Account e CRM_LinkedNDR__c e condizione sul recordId  
*/

public with sharing class MRForDynamicTablesController {

    @AuraEnabled
    public static Map<String, SObject> getAvailabilityMonths(String recordId){
        Map<String, SObject> dateList = new Map<String, SObject>();
        try{
            dateList = SV_Utilities.keyBy([SELECT CRM_CRMeseDiRiferimento__c,  RecordType.DeveloperName FROM CRM_IndicatoriCliente__c WHERE RecordType.DeveloperName = 'Storico' AND CRM_Account__c =: recordId order by CRM_CRMeseDiRiferimento__c desc LIMIT 13],'Id');
            System.debug('GB Date Disponibili '+dateList);
        }
        catch (Exception e) {
            throw new AuraHandledException('Error Message: '
            + e.getMessage());
        } 
        
        return dateList;
    }

    //getObjectInfos(String RecordTypeDeveloperName, String recordId,String mese , String data,)
    @AuraEnabled
    public static Map<String,sObject> getObjectInfos (String recordId, String RecordTypeDeveloperName, String selectedDate) {

        System.debug('GB getObjectInfos recordId: '+recordId);
        System.debug('GB selected date: '+selectedDate);
               
        Map<String,sObject> maptest = new Map<String,Sobject>();
        // AL 2022-08-24 -- Aggiunta query ad Account e CRM_LinkedNDR__c 
        Account acc = [SELECT Id, CRM_NaturaGiuridica__c
                       FROM   Account 
                       WHERE  Id = :recordId];
        List<CRM_LinkedNDG__c> crmlinkeds = new List<CRM_LinkedNDG__c>();                  
        if(acc.CRM_NaturaGiuridica__c == 'DI') {
            crmlinkeds = [SELECT CRM_RelatedAccount__c
                                FROM   CRM_LinkedNDG__c 
                                WHERE  CRM_Account__c = :recordId 
                                AND CRM_CheckCodiceCollCompagine__c = true 
                                AND CRM_Status__c = 'A' 
                                AND CRM_LinkType__c = 'TITOLARE D.I.'];
        }
        // AL 2022-08-24 -- Fine 
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('CRM_IndicatoriCliente__c'));
        query += ' WHERE CRM_Account__c = \'' 
                + ( acc.CRM_NaturaGiuridica__c == 'DI' ? String.escapeSingleQuotes(crmlinkeds.get(0).CRM_RelatedAccount__c) : String.escapeSingleQuotes(recordId) ) // AL 2022-08-24 -- Aggiunta condizione sul recordId
                + '\' AND CRM_CRMeseDiRiferimento__c ='
                + String.escapeSingleQuotes(selectedDate) + ' AND RecordType.DeveloperName = \'' + String.escapeSingleQuotes(RecordTypeDeveloperName) + '\' LIMIT 1';
        System.debug('QUUERY '+'... WHERE CRM_Account__c = \'' +recordId+ '\' AND CRM_CRMeseDiRiferimento__c = '+selectedDate+ ' AND RecordType.DeveloperName = \'' +RecordTypeDeveloperName+ '\' LIMIT 1');
        try{
            sObject slist = Database.query(query);

                System.debug('GB ObjRecord '+slist);

                maptest.put(recordId,slist );

        }
        catch (Exception e) {
            throw new AuraHandledException('Error Message: '
            + e.getMessage());
        }    
        
        
            return maptest;

    }
}