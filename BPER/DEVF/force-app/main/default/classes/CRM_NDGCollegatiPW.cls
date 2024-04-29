public without sharing class CRM_NDGCollegatiPW {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static WrapperObj getAllData(String recordId, String ndgGoverno, String abiQuest){
        System.debug('SV getAllData recordId: ' + recordId);
        System.debug('SV getAllData ndgGoverno: ' + ndgGoverno);
        System.debug('SV getAllData abiQuest: ' + abiQuest);
        /*if (ndgGoverno == null || ){*/
            Account currAcc = [SELECT id,CRM_NDGGoverno__c, FinServ__BankNumber__c from Account where id = :recordId];
            ndgGoverno = currAcc.CRM_NDGGoverno__c;
            abiQuest = currAcc.FinServ__BankNumber__c;
            if(currAcc.FinServ__BankNumber__c =='05387')
                abiQuest = '03084';
            else if (currAcc.FinServ__BankNumber__c =='03084')
                abiQuest = '05387';
        //}
        System.debug('SV getAllData ndgGoverno: ' + ndgGoverno);
        WrapperObj response = new WrapperObj();

        try {
        
            Set<Id> ListRelatedAccount = new Set<Id>();

            List<Account> accList = [ SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, CRM_NDG__c, CRM_NDGGoverno__c, CRM_NomePortafoglio__c, CRM_ReferenteNameFormula__c,PTF_StatoCRMFull__c,PTF_Filiale__r.Name,ModelloDiServizio__c,FinServ__BankNumber__c  FROM Account WHERE CRM_NDGGoverno__c =: ndgGoverno AND FinServ__BankNumber__c =: abiQuest and CRM_NDGGoverno__c != null];
            
            if(accList.size() > 0){
                response.accMap = accList;
                for (Account acct : accList ) {
                    ListRelatedAccount.add(acct.Id);
                }
                
                List<SObject> AccountJoinAccount = [ SELECT CRM_Account__c , CRM_JointOwnership__c from CRM_AccountAccountJointOwnershipRelation__c  WHERE CRM_Account__c =: response.accMap[0].Id ];
                //Set<Id> ListRelatedAccount = new Set<Id>();
                for (sObject o : AccountJoinAccount) {
                    CRM_AccountAccountJointOwnershipRelation__c acc = (CRM_AccountAccountJointOwnershipRelation__c)o;
                    ListRelatedAccount.add(acc.CRM_JointOwnership__c);
                }
    
                response.ListCOMap = [ SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, CRM_NDG__c, CRM_NDGGoverno__c, CRM_NomePortafoglio__c, CRM_ReferenteNameFormula__c FROM Account WHERE Id IN : ListRelatedAccount ];    
            }

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
 
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return response;

    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public List<Account> accMap;
        @AuraEnabled public List<SObject> ListCOMap;

    }

}