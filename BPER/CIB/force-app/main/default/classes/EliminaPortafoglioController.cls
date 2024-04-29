public with sharing class EliminaPortafoglioController {
    @AuraEnabled
    public static void checkMW(Id recordId){
        Map<String, SObject> assignmentMap = SV_Utilities.keyBy([SELECT id, PTF_MicroWallet__c FROM Assignment__c WHERE PTF_MicroWallet__c =:recordId AND PTF_EndDate__c = null], 'PTF_MicroWallet__c');
        Map<String, SObject> ndgMap = SV_Utilities.keyBy([SELECT id, PTF_Portafoglio__c FROM Account WHERE PTF_Portafoglio__c =:recordId], 'PTF_Portafoglio__c');
        Map<String, SObject> WoMap = SV_Utilities.keyBy([SELECT id, PTF_Destinazione__c FROM WorkOrder WHERE Status = 'Pending' AND PTF_Destinazione__c =:recordId], 'PTF_Destinazione__c');


        if(assignmentMap.containsKey(recordId) ||
                ndgMap.containsKey((recordId))){

                throw new AuraHandledException('Non è possibile cancellare un Microportafoglio che non sia vuoto e non assegnato ad alcun referente.');
            }

        if(WoMap.containsKey(recordId)) {

            throw new AuraHandledException('Non è possibile cancellare un Microportafoglio legato ad un iter di spostamento.');
        }
    }

    @AuraEnabled
    public static void eliminaMW(Id recordId){
        Wallet__c wal= new Wallet__c(Id= recordId, PTF_DeletionDate__c=Date.today());
        update wal;
    }
}