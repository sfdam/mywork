/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/
public with sharing class CheckupListViewControllerv2 {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    public static User utenzaBatch{
        get{
            if(utenzaBatch != null)return utenzaBatch;
            utenzaBatch = [SELECT Id FROM user WHERE Name = 'Utente Integrazione Batch' LIMIT 1];
            return utenzaBatch;
        }set;
    }

    @AuraEnabled
    public static List<CRM_CustomerInterview__c> getRecordNotes(String recordId, Integer numberOfRecords, String filter){
    
        System.debug('Check-up object ID: ' + recordId);
        System.debug('filter: ' + filter);
        System.debug('numberOfRecords: ' + numberOfRecords);
        List<CRM_CustomerInterview__c> returnedRecords = new List<CRM_CustomerInterview__c>();
        List<CRM_CustomerInterview__c> returnedRecords2 = new List<CRM_CustomerInterview__c>();
        List<CRM_CustomerInterview__c> returnedRecords3 = new List<CRM_CustomerInterview__c>();
        try{

                String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('CRM_CustomerInterview__c'));
                query += ' WHERE CRM_IsCompilazione__c = true';
                query += ' AND CRM_Customer__c = :recordId';
                if(String.isNotBlank(filter)){
                    query +=' AND ';
                    query += String.escapeSingleQuotes(filter);
                    query += '!= null';
                }
                //query += ' ORDER BY CRM_CreatedDate__c DESC';
                query += ' ORDER BY CRM_DataUltimaCompilazione__c DESC';
                query += ' LIMIT :numberOfRecords ';
                
                System.debug('query: ' + query);

                returnedRecords = Database.query(query);
                
                if(returnedRecords.size() < numberOfRecords) {
                    String rtFilter = 'Check_Up_Standard';
                    String idUtente = utenzaBatch.Id;
                    String utenzaSistema = 'Utenza di Sistema';
                    Integer recordsRemaining = numberOfRecords - returnedRecords.size();
                    String query2 = String.escapeSingleQuotes(SV_Utilities.selectAllField('CRM_CustomerInterview__c'));
                    //query2 += ' WHERE CRM_IsCompilazione__c = false AND (CreatedById = :idUtente OR (CRM_MMDSStorico__c = CORPORATE AND LastModifiedBy.Name = :utenzaSistema ) ) ';
                    query2 += ' WHERE CRM_IsCompilazione__c = false AND CreatedById = :idUtente ';
                    query2 += ' AND RecordType.DeveloperName != :rtFilter';
                    query2 += ' AND CRM_Customer__c = :recordId';
                    if(String.isNotBlank(filter)){
                        query2 +=' AND ';
                        query2 += String.escapeSingleQuotes(filter);
                        query2 += '!= null';
                    }
                    //query2 += ' ORDER BY CRM_CreatedDate__c DESC';
                    query2 += ' ORDER BY CRM_DataUltimaCompilazione__c DESC';
                    query2 += ' LIMIT :recordsRemaining ';
                    
                    System.debug('query2: ' + query2);
    
                    returnedRecords2 = Database.query(query2);
                    
                    returnedRecords.addAll(returnedRecords2);
                }
                
            System.debug('risultati ---> ' + returnedRecords); 
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return returnedRecords;
    }   
}