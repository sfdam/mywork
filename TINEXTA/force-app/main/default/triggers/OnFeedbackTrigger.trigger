trigger OnFeedbackTrigger on Feedback__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        FeedbackTriggerHandler.alignModalitaVisitaEvent(Trigger.newMap);
    }
}