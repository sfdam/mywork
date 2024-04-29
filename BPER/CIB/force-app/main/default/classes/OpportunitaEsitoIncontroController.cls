public with sharing class OpportunitaEsitoIncontroController {

    @AuraEnabled(Cacheable=true)
    public static List<Opportunity> fetchOpportunitaEsitoIncontro(){
        list<Opportunity> listOpp = [SELECT Id, Name, AccountId, Account.Name, OwnerId, Owner.Name, Data_investment_committee__c, 
                                        Orario_IB_Committee__c, Deliberato_IB_Committee__c, 
                                        Data_delibera_investment_committee__c, CIB_Verbale_Meeting__c, Data_Stipula_Signing__c,
                                        Forecast_Erogazioni_Saved__c, CIB_Nome_Opportunita__c
                                        FROM Opportunity
                                        WHERE (OpportunitComitato__c != null OR Data_investment_committee__c != null)
                                            AND (CIB_Verbale_Meeting__c = null 
                                                    OR Data_delibera_investment_committee__c = null
                                                        OR Deliberato_IB_Committee__c = null)];
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