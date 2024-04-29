public with sharing class PTF_SpostaNDGFromCSVController {
    
    @AuraEnabled
    public static WrapperResponse getDate(String objList){
        System.debug('SV objList: ' + objList);

        List<WrapperObj> elementList = (List<WrapperObj>)JSON.deserialize(objList, List<WrapperObj>.class);
                System.debug('SV JSON elementList: ' + elementList);

        WrapperResponse response = new WrapperResponse();

        try{
            
            String sQueryAccount = 'SELECT Id, PTF_Portafoglio__c, PTF_Portafoglio__r.Name, PTF_Filiale__c, PTF_Filiale__r.Name, PTF_Filiale__r.PTF_IdCEDFiliale__c FROM Account ';
            String sQueryWhereConditionAccount = '';

            String sQueryWallet = 'SELECT Id, Name FROM Wallet__c ';
            String sQueryWhereConditionWallet = '';

            String sQueryStruttura = 'SELECT Id, Name, PTF_IdCEDFiliale__c FROM Account ';
            String sQueryWhereConditionStruttura = '';


            Integer count = 0;
            for (WrapperObj element : elementList) {
                System.debug('SV element: ' + element);
                // List<String> x = element.split('_');
                if(count == 0){
                    sQueryWhereConditionAccount = 'WHERE (CRM_NDG__c = \'' + String.escapeSingleQuotes(element.ndgNumber) + '\' AND FinServ__BankNumber__c = \'' + String.escapeSingleQuotes(element.abi) + '\') ';
                    sQueryWhereConditionStruttura = 'WHERE PTF_IdCEDFiliale__c IN ( \'' + String.escapeSingleQuotes(element.newCedfiliale) + '\' ';
                    sQueryWhereConditionWallet = 'WHERE Id IN ( \'' + String.escapeSingleQuotes(element.newPTFId) + '\' ';
                } else {
                    sQueryWhereConditionAccount = 'OR (CRM_NDG__c = \'' + String.escapeSingleQuotes(element.ndgNumber) + '\' AND FinServ__BankNumber__c = \'' + String.escapeSingleQuotes(element.abi) + '\') ';
                    sQueryWhereConditionStruttura = ' ,\'' + String.escapeSingleQuotes(element.newCedfiliale) + '\'';
                    sQueryWhereConditionWallet = ' ,\'' + String.escapeSingleQuotes(element.newPTFId) + '\''; 
                }

                sQueryAccount = sQueryAccount + sQueryWhereConditionAccount;
                sQueryWallet = sQueryWallet + sQueryWhereConditionWallet;
                sQueryStruttura = sQueryStruttura + sQueryWhereConditionStruttura;
                count++;
            }

            sQueryWallet = sQueryWallet.removeEnd(',') + ')';
            sQueryStruttura = sQueryStruttura.removeEnd(',') + ')';

            System.debug('SV sQueryAccount: ' + sQueryAccount);
            System.debug('SV sQueryWallet: ' + sQueryWallet);
            System.debug('SV sQueryStruttura: ' + sQueryStruttura);
            List < sObject > lstOfAccounts = Database.query(sQueryAccount);
            List < sObject > lstOfWallets = Database.query(sQueryWallet);
            List < sObject > lstOftrutturas = Database.query(sQueryStruttura);
            System.debug('SV lstOfAccounts: ' + lstOfAccounts);

            response.ndgMap  = SV_Utilities.keyBy(lstOfAccounts, 'Id');
            response.filialiMap  = SV_Utilities.keyBy(lstOftrutturas, 'PTF_IdCEDFiliale__c');
            response.ptfMap  = SV_Utilities.keyBy(lstOfWallets, 'Id');

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }

        return response;

    }

    @AuraEnabled
    public static Boolean saveRecords(String objList){
        System.debug('SV objList: ' + objList);

        List<Account> elementList = (List<Account>)JSON.deserialize(objList, List<Account>.class);
                System.debug('SV JSON elementList: ' + elementList);

        try{
            
            update elementList;


        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }
        
        return true;

    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public String ndgNumber;
        @AuraEnabled public String abi;
        @AuraEnabled public String newPTFId;
        @AuraEnabled public String newCedfiliale;

    }

    public class WrapperResponse {

        @AuraEnabled public Map<String, SObject> ndgMap;
        @AuraEnabled public Map<String, SObject> filialiMap;
        @AuraEnabled public Map<String, SObject> ptfMap;

    }
}