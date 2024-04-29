/*
AL 2022-08-24 -- Aggiunta query ad Account e CRM_LinkedNDR__c e condizione sul recordId  
                 Aggiunta di parametro  a getObjectInfos
*/

public with sharing class DynamicTablesController {



    @AuraEnabled
    public static Map<String,Object> getObjectInfos (String obj, String field_lookup, String recordId, String recordTypeDeveloperName
    , String fileJS // AL 2022-08-24 -- Aggiunta di parametro 
    ) {

        System.debug('GB getObjectInfos obj: '+obj);
        System.debug('GB getObjectInfos field_lookup: '+field_lookup);
        System.debug('GB getObjectInfos recordTypeDeveloperName: '+recordTypeDeveloperName);
        System.debug('GB getObjectInfos recordId: '+recordId);
        System.debug('GB getObjectInfos fileJS: '+fileJS);

        String recordTypeDeveloperNameCondition = '';
        Map<String,Object> maptest = new Map<String,Object>();

        if(recordTypeDeveloperName != null && obj != 'CRM_IndicatoriCliente__c'){ recordTypeDeveloperNameCondition = ' AND RecordType.DeveloperName = \'' + String.escapeSingleQuotes(recordTypeDeveloperName) + '\'';}
        // AL 2022-08-24 -- Aggiunta query ad Account e CRM_LinkedNDR__c
        Account acc = [SELECT Id, CRM_NaturaGiuridica__c
                       FROM   Account 
                       WHERE  Id = :recordId];
        List<CRM_LinkedNDG__c> crmlinkeds = new List<CRM_LinkedNDG__c>();                
        if(acc.CRM_NaturaGiuridica__c == 'DI' && fileJS == 'CRM_TabellaEntiSegnalanti.js') {
            crmlinkeds = [SELECT CRM_RelatedAccount__c
                                FROM   CRM_LinkedNDG__c 
                                WHERE  CRM_Account__c = :recordId 
                                AND CRM_CheckCodiceCollCompagine__c = true 
                                AND CRM_Status__c = 'A' 
                                AND CRM_LinkType__c = 'TITOLARE D.I.'];
        }
        // AL 2022-08-24 -- Fine
        String additionalCriterias;
        
        if(obj == 'CRM_IndicatoriCliente__c'){
            additionalCriterias = ' AND RecordType.DeveloperName != \'Testa\' ORDER BY CRM_CRMeseDiRiferimento__c DESC LIMIT 13';
        } else {additionalCriterias = ' LIMIT 1';}
        
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField(obj));
        
        query += ' WHERE ' + String.escapeSingleQuotes(field_lookup) +  ' = \'' 
            + ( acc.CRM_NaturaGiuridica__c == 'DI' && crmlinkeds.size() > 0 ? String.escapeSingleQuotes(crmlinkeds.get(0).CRM_RelatedAccount__c) : String.escapeSingleQuotes(recordId) ) // AL 2022-08-24 -- Aggiunta condizione sul recordId
            //+ recordId
                + '\'' + recordTypeDeveloperNameCondition + additionalCriterias;
        System.debug(query); 
        try{
            List<sObject> slist = Database.query(query);

            System.debug('GB ObjRecord size: '+slist.size());
            System.debug('GB ObjRecord '+slist);
            
                maptest.put(recordId,slist );

        }
        catch (Exception e) { throw new AuraHandledException('Error Message: '+ e.getMessage());} 
        
        return maptest;
    }
}