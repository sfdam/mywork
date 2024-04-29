public without sharing class FeedbackTriggerHandler {

    public static void alignModalitaVisitaEvent(Map<Id,Feedback__c> feedbacks){
        Set<String> idEvents = Utilities.getSet(feedbacks.values(), 'IdEvento__c');

        Map<Id,Event> eventsMap = new Map<Id,Event>([SELECT Id, WRT_Feedback_Modalita_Visita__c, Feedback__c FROM Event WHERE Id IN: idEvents]);
        for(Event e : eventsMap.values()){
            e.WRT_Feedback_Modalita_Visita__c = feedbacks.get(eventsMap.get(e.Id).Feedback__c).Tipo_Visita__c == 'Da remoto' ? feedbacks.get(eventsMap.get(e.Id).Feedback__c).Tipo_Visita__c + ' (call/videoconf)' : feedbacks.get(eventsMap.get(e.Id).Feedback__c).Tipo_Visita__c;
            e.WRT_Stato_visita__c = feedbacks.get(eventsMap.get(e.Id).Feedback__c).Stato_visita__c;
        }

        update eventsMap.values();
    }
}