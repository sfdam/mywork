/*********************************************
 * Name             :   OnIdentityDocumentTriggerHandler
 * Creation Date    :   2023-04-13
 * Author           :   Alessandro Di Nardo @TEN
 * Description      :  trigger handler used for update fields of account when insert new "IdentityDocument"
 **********************************************/

public with sharing class OnIdentityDocumentTriggerHandler {

    public static Boolean skipAccountTrigger=false;


    public static void handleAfterInsert(List<IdentityDocument> listIdentityDocument){

        Boolean toUpdate = false;

        List<Account> accountToUpdate = new List<Account>();

        for(IdentityDocument doc : listIdentityDocument){

            if(doc.ExpirationDate>Date.today()){
                
                toUpdate=true;

                Account acc = new Account(Id=doc.RelatedLegalEntityId,CRM_DocName__c=doc.Name,CRM_DocType__c=doc.IdDocumentType,CRM_DocExpirationDate__c=doc.ExpirationDate,CRM_DocId__c=doc.Id);

                accountToUpdate.add(acc);

            }

        }

        if(toUpdate){

            update accountToUpdate;

        }
        



    }
}