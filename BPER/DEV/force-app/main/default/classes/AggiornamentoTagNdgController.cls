/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 22-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * 
 * description        : CR 76756 classe usata dal componente lwc : AggiornaTagNdg
 *                      metodi : -getNdgFromAccount recupero valore "PTF_RiportafogliazioneTAG__c" di Account in base all'identificativo passato
 *                               -updateNdgValue    modifica valore  "PTF_RiportafogliazioneTAG__c" in base al valore passato dal lwc 
 *                                                  (identificativo account , valore tag)
**/
public without sharing class AggiornamentoTagNdgController {

    @AuraEnabled(cacheable=true)
    public static string getNdgFromAccount(String idAccount){
        
        System.debug('AD sono in getNdgFromAccount');

        String risposta = '';
        
        try {

            List<Account> listAccount = [select PTF_RiportafogliazioneTAG__c from Account where id =: idAccount];

            if(listAccount.size()>0){
                risposta = listAccount[0].PTF_RiportafogliazioneTAG__c;
            }
            
        } catch (Exception e) {
            System.debug('AD getNdgFromAccount Exception : ' + e);
        }

        return risposta;
    }

    @AuraEnabled 
    public static String updateNdgValue(String idAccount,String ndgValue){
        
        System.debug('AD sono in updateNdgValue');

        list<Account> accountToUpdate = new List<Account>();
        String risposta = '';
        try {

            List<Account> listAccount = [select id,PTF_RiportafogliazioneTAG__c from Account where id =: idAccount];
            for(Account acc : listAccount){
                acc.PTF_RiportafogliazioneTAG__c=ndgValue;
                accountToUpdate.add(acc);
            }

            if(accountToUpdate.size()>0){
                
                update accountToUpdate;

                risposta = accountToUpdate[0].id;
                
            }
            
        } catch (Exception e) {
            System.debug('AD updateNdgValue Exception : ' + e);
            risposta = '';
            
        }

        return risposta;

    }
    
}