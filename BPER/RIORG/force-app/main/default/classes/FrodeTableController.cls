public class FrodeTableController {
    @AuraEnabled 
    public static WrapperObject getAllData(String caseId, Integer flow) {
        WrapperObject result = new WrapperObject();
        Map<String,String> mapCardType = new Map<String,String>();
        Date currentDate = date.today();
        
        Case cs = [SELECT Id, AccountId FROM Case WHERE Id=:caseId];
        
        if(flow==1){
        Set<String> productIds = new Set<String>();
        List<String> rtDevName= new List<String>();
        rtDevName.add('CreditCard');
        rtDevName.add('Business_Credit_Card');
        rtDevName.add('Revolving_Card');

        List<Id> rtIds = new List<Id>();
        for(String rt:rtDevName){
            rtIds.add(Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId());
        }

        //Set<String> productIds= SV_Utilities.getSet([SELECT FinServ__FinancialAccount__c, FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRole__c WHERE FinServ__FinancialAccount__r.RecordTypeId IN:rtIds AND FinServ__RelatedAccount__c=:cs.AccountId], 'FinServ__FinancialAccount__c');
        
        List<FinServ__FinancialAccountRole__c> allProducts = [SELECT FinServ__FinancialAccount__c, FinServ__RelatedAccount__c,FinServ__FinancialAccount__r.CRM_ValidityEndDate__c FROM FinServ__FinancialAccountRole__c WHERE FinServ__FinancialAccount__r.RecordTypeId IN:rtIds AND FinServ__RelatedAccount__c=:cs.AccountId];

        for(FinServ__FinancialAccountRole__c f : allProducts){

            if(f.FinServ__FinancialAccount__r.CRM_ValidityEndDate__c >= currentDate){

                productIds.add(f.FinServ__FinancialAccount__c);
            }
        }
        List<FinServ__FinancialAccount__c> prodotti= [SELECT Id, CRM_Numero_Carta_Hash__c, CRM_ValidityEndDate__c,FinServ__PrimaryOwner__c,FinServ__Status__c,Name, CRM_BankDebitaccount__r.CRM_iban__c , RecordType.developerName
                                                    FROM FinServ__FinancialAccount__c WHERE Id IN:productIds];

        List<mapCardType__mdt> mct= [SELECT Key__c, Value__c FROM mapCardType__mdt];

       

        for (mapCardType__mdt m:mct){
            mapCardType.put(m.Key__c, m.Value__c);
        }
        
        result.mapCardType=mapCardType;

        result.prodotti= prodotti;


        }
        if(flow==2){
            Set<String> productIds = SV_Utilities.getSet([SELECT FinServ__FinancialAccount__c, FinServ__RelatedAccount__c FROM FinServ__FinancialAccountRole__c WHERE FinServ__RelatedAccount__c=:cs.AccountId AND FinServ__EndDate__c = null], 'FinServ__FinancialAccount__c');

            List<FinServ__FinancialAccount__c> prodotti= [SELECT Id, Name, FinServ__OpenDate__c, CRM_ProfileTypology__c, toLabel(CRM_UserCodeStatus__c)
                                                    FROM FinServ__FinancialAccount__c WHERE FinServ__ProductName__r.CRM_MacroGroupCode__c ='MG_129' AND  Id IN:productIds];
            result.prodotti= prodotti;
            result.mapCardType=mapCardType;

        }
        if(result.prodotti.size()==0){
            throw new AuraHandledException('Prodotti vuoti');
        }
        return result;
                                                 

    }

    public class WrapperObject {
        @AuraEnabled public List<FinServ__FinancialAccount__c> prodotti;   
        @AuraEnabled public Map<String,String> mapCardType;
       
        
        
    }
}