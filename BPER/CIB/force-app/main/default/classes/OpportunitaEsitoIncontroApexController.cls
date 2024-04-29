public with sharing class OpportunitaEsitoIncontroApexController {

    @AuraEnabled(Cacheable=true)
    public static List<Opportunity> fetchOpportunitaEsitoIncontro(){
        list<Opportunity> listOpp = [SELECT Id, Name, AccountId, Account.Name, OwnerId, Owner.Name, Data_investment_committee__c, 
                                        Orario_IB_Committee__c, Deliberato_IB_Committee__c, 
                                        Data_delibera_investment_committee__c, CIB_Verbale_Meeting__c, Data_Stipula_Signing__c,
                                        Forecast_Erogazioni_Saved__c
                                        FROM Opportunity
                                        WHERE Memo_CIB_Saved__c = true
                                        LIMIT 50];
        return listOpp;
    }

    @AuraEnabled
    public static String updateOpportunitaEsitoIncontro(List<Opportunity> data){
        System.debug('LV data1 : ' + data);
        try {
            update data;          
        }
        catch (Exception e) {
            System.debug('line: '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return 'Success: opportunity updated successfully';
    }
}