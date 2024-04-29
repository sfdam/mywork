public without sharing class TXT_CalculateOpportunityPalCtrl {

    @AuraEnabled
    public static string calculate(Id recordId){
        try {
            
            // Elimino i record
            Map<Id,Opportunity_PAL__c> optyPAL = new Map<Id,Opportunity_PAL__c>([SELECT Id FROM Opportunity_PAL__c WHERE AccountId__c =: recordId]);
            if(!optyPAL.isEmpty()){
                delete optyPAL.values();
            }
            // Non serve, è in master-detail
            // delete [SELECT Id FROM Opportunity_Line_PAL__c WHERE AccountId__c =: recordId];

            // Ricreo i record
            Map<Id,Opportunity> optys = new Map<Id,Opportunity>([SELECT Id, Name, AccountId, Amount, CloseDate, Probability, StageName, RecordType.Name, Ammontare_Report__c FROM Opportunity WHERE AccountId =: recordId and RecordType.Name != 'Innolva']);
            Map<Id,OpportunityLineItem> optyLineItems = new Map<Id,OpportunityLineItem>([SELECT Id, OpportunityId, UnitPrice, TotalPrice, Quantity, Product2Id, Opportunity.AccountId FROM OpportunityLineItem WHERE Opportunity.AccountId =: recordId and Opportunity.RecordType.Name != 'Innolva']);

            List<Opportunity_PAL__c> optysPAL = createOptyPAL(optys.values());
            List<Opportunity_Line_PAL__c> optyLineItemsPAL = createOptyLinePAL(optyLineItems.values(), optysPAL);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' -- ' + e.getStackTraceString());
        }

        return null;
    }

    public static List<Opportunity_PAL__c> createOptyPAL(List<Opportunity> optys) {
        List<Opportunity_PAL__c> optysPAL = new List<Opportunity_PAL__c>();

        for(Opportunity opp : optys){
            Opportunity_PAL__c optyPAL = new Opportunity_PAL__c(
                AccountId__c = opp.AccountId,
                Opportunity__c = opp.Id,
                Name__c = opp.Name,
                Amount__c = opp.Amount,
                CloseDate__c = opp.CloseDate,
                Probability__c = opp.Probability,
                Stage__c = opp.StageName,
                RecordType_Name__c = opp.RecordType.Name,
                Ammontare_Report__c = opp.Ammontare_Report__c
            );

            optysPAL.add(optyPAL);
        }

        insert optysPAL;

        return optysPAL;
    }

    public static List<Opportunity_Line_PAL__c> createOptyLinePAL(List<OpportunityLineItem> optyLineItems, List<Opportunity_PAL__c> optysPAL){
        List<Opportunity_Line_PAL__c> optyLineItemsPAL = new List<Opportunity_Line_PAL__c>();

        Map<Id,Opportunity_PAL__c> optyIdXoptyPAL = new Map<Id,Opportunity_PAL__c>();

        for(Opportunity_PAL__c tmpPal : optysPAL){
            optyIdXoptyPAL.put(tmpPal.Opportunity__c, tmpPal);
        }

        for(OpportunityLineItem oli : optyLineItems){
            Opportunity_Line_PAL__c oliPAL = new Opportunity_Line_PAL__c(
                Opportunity_PAL__c = optyIdXoptyPAL.get(oli.OpportunityId).Id,
                Opportunity__c = oli.OpportunityId,
                Account__c = oli.Opportunity.AccountId,
                OpportunityLineItem__c = oli.Id,
                Product2Id__c = oli.Product2Id,
                Quantity__c = oli.Quantity,
                UnitPrice__c = oli.UnitPrice,
                TotalPrice__c = oli.TotalPrice
            );
            optyLineItemsPAL.add(oliPAL);
        }

        insert optyLineItemsPAL;

        return optyLineItemsPAL;
    }
}