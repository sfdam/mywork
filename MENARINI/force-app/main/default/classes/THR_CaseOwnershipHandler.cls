/**
 * Created by ssalaris on 10/08/2021.
 */

public class THR_CaseOwnershipHandler {

    public static void createNewPartialRecord(List<Case_Ownership__c> newCaseOwnerships) {

        List<Case_Ownership_Partial__c> partialsToInsert = new List<Case_Ownership_Partial__c>();
        Case_Ownership_Partial__c newPartial;

        for(Case_Ownership__c csOwn : newCaseOwnerships) {
            newPartial = new Case_Ownership_Partial__c(Case_Ownership__c = csOwn.Id, Partial_Owner_Name__c = csOwn.Case_Owner_Name__c, Is_Current_Partial__c = true);
            partialsToInsert.add(newPartial);
        }

        insert partialsToInsert;
    }
}