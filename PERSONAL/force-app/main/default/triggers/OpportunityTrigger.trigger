trigger OpportunityTrigger on Opportunity (before insert, after update) {

    List<Id> oppToApproveList = new List<Id>();
    if(Trigger.isUpdate){

        if(Trigger.isAfter){

            for(Opportunity opp : Trigger.new){

                if(Trigger.oldMap.get(opp.Id).Discount_Percentage__c != opp.Discount_Percentage__c){

                    if(opp.Discount_Percentage__c > 40){

                        oppToApproveList.add(opp.Id);
                    }
                }
            }

            if(!oppToApproveList.isEmpty()){

                ApproverHandler.initApprovalProcess(oppToApproveList);
            }
        }
    }
}