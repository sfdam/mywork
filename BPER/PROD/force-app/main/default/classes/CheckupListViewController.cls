public with sharing class CheckupListViewController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}


    @AuraEnabled
    public static List<CRM_Note__c> getRecordNotes(String recordId, Integer numberOfRecords){

        List<CRM_Note__c> returnedRecords = new List<CRM_Note__c>();
        System.debug('Check-up object ID: ' + recordId);
        try{
            String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('CRM_Note__c'));
            query += ' WHERE CRM_Tagliando__c = :recordId'; 
            query += ' AND CRM_Tagliando__c = :recordId';                     
            query += ' ORDER BY CRM_Data__c DESC';
            /*query += ' LIMIT :numberOfRecords ';*/

            System.debug('GB query: ' + query);

            returnedRecords = Database.query(query);
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }

        return returnedRecords;

    }
    
}