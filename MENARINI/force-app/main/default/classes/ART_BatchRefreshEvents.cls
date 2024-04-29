/* * @author        : Sebastiano.Lisbona @ten | Roberto.Murgia @ten
 * @name		  : ART_BatchRefreshEvents 
 * @createDate    : 2023-06-10
 * @description   : Batch che triggera il flow Trigger sugli Eventi per refreshare i report
 * 
 * 					
 * @ClassTest     : ART_BatchRefreshEvents_Test
 */
global class ART_BatchRefreshEvents implements Database.Batchable<SObject>, Database.Stateful,Schedulable {    
    global  Iterable<sObject> start(Database.BatchableContext BC) {
		Iterable<sObject> result = new AggregateResultIterable('SELECT AccountId, MIN(Account.Min_Event_Date__c) minDate FROM Event WHERE Trigger_Event__c = false AND Account.Min_Event_Date__c < TODAY GROUP BY AccountId');
		AggregateResultIterator r = (AggregateResultIterator) result.Iterator();
        return result;
    }
    global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new ART_BatchRefreshEvents(),200 );
    }    
    global void execute(Database.BatchableContext BC, List<AggregateResult> scope) {
        Map<Id,DateTime> accountToMinNextEventDateMap = new Map<Id,DateTime>();
        List<Event> eventsToUpdate = new List<Event>();
        for (AggregateResult aggResult : scope) {
            Id accountId = (Id)aggResult.get('AccountId');
            DateTime minNextEventDate = (DateTime)aggResult.get('minDate');
            accountToMinNextEventDateMap.put(accountId, minNextEventDate);
        }
		Set<Id> accountIds = new Set<Id>(accountToMinNextEventDateMap.keySet());
        for (Event event : [SELECT Id, AccountId,StartDateTime, Account.Min_Event_Date__c FROM Event WHERE AccountId IN :accountIds AND Trigger_Event__c = false]) {
            DateTime minNextEventDate = accountToMinNextEventDateMap.get(event.AccountId);
            if (event.StartDateTime == minNextEventDate) {
                eventsToUpdate.add(new Event (Id = event.id,Trigger_Event__c = true));
            }
        }
        if (!eventsToUpdate.isEmpty()) {
            update eventsToUpdate;
        }
    }    
    global void finish(Database.BatchableContext BC) {
	}
}