public without sharing class MiniWalletNdgTableController {

    @AuraEnabled
    public static List<Account> getNDG(String miniWalletId){
        String walletId = [SELECT PTF_Portafoglio__c FROM MiniWallet__c WHERE id =: miniWalletId LIMIT 1].PTF_Portafoglio__c;
        List<Account> accList = [SELECT id, CRM_NDG__c,Name, FirstName, LastName, PTF_Capogruppo__c, PTF_NaturaGiuridica__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_MiniPortafoglio__c
                                FROM Account
                                WHERE PTF_Portafoglio__c =: walletId
                                AND PTF_MiniPortafoglio__c = NULL];
        return accList;
    }

    @AuraEnabled
    public static Boolean updateNDG(String miniWalletId, List<String> ndgIdList){
        System.debug('MC miniwalletId '+miniWalletId);
        System.debug('MC ndgIdList '+ndgIdList);
        Boolean hasNoError = false;
        try{
            List<Account> accountListToupdate = new List<Account>();
        
            for(String ndgId : ndgIdList){

                accountListToupdate.add(new Account(id = ndgId, PTF_MiniPortafoglio__c = miniWalletId));
            }
            if(!accountListToupdate.isEmpty()){

                update accountListToupdate;
            }
            hasNoError = true;
        }catch(Exception e){
            hasNoError = false;
            System.debug('AdF Exception updateNDG' + e.getMessage());
        }
       
        return hasNoError;
        
    }

    @AuraEnabled
    public static List<Account> getNDGToRemove(String miniWalletId){
        String walletId = [SELECT PTF_Portafoglio__c FROM MiniWallet__c WHERE id =: miniWalletId LIMIT 1].PTF_Portafoglio__c;
        List<Account> accList = [SELECT id, CRM_NDG__c, FirstName, LastName,Name, PTF_Capogruppo__c, PTF_NaturaGiuridica__c, PTF_Patrimonio__c, PTF_Utilizzato__c, PTF_MiniPortafoglio__c
                                FROM Account
                                WHERE PTF_Portafoglio__c =: walletId
                                AND PTF_MiniPortafoglio__c =: miniWalletId];
        return accList;
    }

    @AuraEnabled
    public static Boolean removeNDG(List<String> ndgIdList){
        System.debug('MC ndgIdList '+ndgIdList);
        Boolean hasNoError = false;
        try{
            List<Account> accountListToupdate = new List<Account>();
        
            for(String ndgId : ndgIdList){

                accountListToupdate.add(new Account(id = ndgId, PTF_MiniPortafoglio__c = null));
            }
            if(!accountListToupdate.isEmpty()){

                update accountListToupdate;
            }
            hasNoError = true;
        }catch(Exception e){
            hasNoError = false;
            System.debug('AdF Exception updateNDG' + e.getMessage());
        }
       
        return hasNoError;
    }

    //AdF funzione di appoggio per la visualizzazione di dati anche se non coerenti
    //@AuraEnabled
    //public static List<Account> getMockData(String miniWalletId){
    //    List<Account> accList = [SELECT id, CRM_Nome__c, PTF_Capogruppo__c, PTF_NaturaGiuridica__c, PTF_Patrimonio__c, PTF_Utilizzato__c
    //                            FROM Account LIMIT 5];
    //    return accList;
    //}

}