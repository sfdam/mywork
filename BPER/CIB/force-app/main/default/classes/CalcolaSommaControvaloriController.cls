public without sharing class CalcolaSommaControvaloriController {

    @AuraEnabled
    public static string CalcolaSommaControvalori(Id recordId){
        try {
            FinServ__FinancialAccount__c record = [SELECT Id, CRM_Equivalent__c FROM FinServ__FinancialAccount__c WHERE Id =: recordId];

            Schema.DescribeSObjectResult d = Schema.SObjectType.FinServ__FinancialAccount__c; 
            Id rtChildRecords = d.getRecordTypeInfosByName().get('Titolo').getRecordTypeId();
            // Schema.RecordTypeInfo rtByName =  rtMapByName.get(rt.name);

            List<FinServ__FinancialAccount__c> childRecords = new List<FinServ__FinancialAccount__c>([SELECT Id, CRM_Equivalent__c, CRM_Data_aggiornamento_controvalore__c FROM FinServ__FinancialAccount__c WHERE CRM_Deposito__c =: recordId AND RecordTypeId =: rtChildRecords]);

            Decimal sum = 0;
            for(FinServ__FinancialAccount__c child : childRecords){
                sum += child.CRM_Equivalent__c;
            }

            record.CRM_Equivalent__c = sum;
            //record.CRM_Data_aggiornamento_controvalore__c = DateTime.now();

            update record;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            return e.getMessage();
        }

        return 'ok';
    }
}