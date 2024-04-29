public  with sharing class wgc_Header_Magazziono_Controller {
    
    @AuraEnabled
    public static MagazzionoWrapper countMagazzionoAperto(){
        
        DateTime dtime = system.now();
        DateTime oldDateTime = dtime.addYears(-1);
        Date dt = system.today();
        Date oggipiu3mesi = dt.addMonths(3);
        MagazzionoWrapper result =  new MagazzionoWrapper();
        Map<String,sObject> taskMap = new Map<String,sObject>();
        Map<String,sObject> eventMap = new Map<String,sObject>();
        Map<String,sObject> opptyMap = new Map<String,sObject>();
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id
                                                          FROM Account 
                                                          WHERE WGC_Qualifica_Corporate__c != null 
                                                          AND WGC_Specialista_Factoring__c != null  // need to change :UserInfo.getUserId()
                                                         ]);
        system.debug('accountMap : '+accountMap.size());
        //where DataOraEsitazione__c = negli ultimi 12 mesi and ((Esito__c= Neutro and DataRicontatto__c <=  today + 3 mesi)  OR (Esito__c!= Neutro) 
        List<Task> taskList = [SELECT Esito__c, AccountId,CreatedDate
                               FROM Task 
                               WHERE  AccountId IN :accountMap.keyset()
                               AND DataOraEsitazione__c >= :oldDateTime  
                               AND DataOraEsitazione__c <= :dtime  
                               AND ( 
                                       (Esito__c='Neutro' AND DataRicontatto__c <= :oggipiu3mesi)  
                                        OR
                                       (Esito__c != 'Neutro')
                                   )
                               ORDER BY CreatedDate Desc];
        system.debug('taskList : '+taskList.size());
        List<Event> eventList = [SELECT Esito__c, CreatedDate,
                                AccountId
                                FROM Event 
                                WHERE  AccountId IN :accountMap.keyset()
                                AND DataOraEsitazione__c >= :oldDateTime  
                                AND DataOraEsitazione__c <= :dtime  
                                ORDER BY CreatedDate Desc];
        system.debug('eventList : '+eventList.size());
        List<Opportunity> opplist = [SELECT Id,Name,CreatedDate,AccountId,StageName  
                                         FROM Opportunity
                                         WHERE CreatedDate >= :oldDateTime  
                                         AND CreatedDate <= :dtime 
                                         AND RecordType.DeveloperName = 'IFISOpportunitaFactoring'
                                     	 AND AccountId IN :accountMap.keyset()
                                         ORDER BY CreatedDate Desc];
        system.debug('opplist : '+opplist.size());
        for(Task ta :taskList){
            if(!taskMap.containsKey(ta.AccountId)){
                taskMap.put(ta.AccountId,ta);
            }
        }
        for(Event ev :eventList){
            if(!eventMap.containsKey(ev.AccountId)){
                eventMap.put(ev.AccountId,ev);
            }
        }
        for(Opportunity opp :opplist){
            if(!opptyMap.containsKey(opp.AccountId)){
                opptyMap.put(opp.AccountId,opp);
            }
        }
        result.accList = accountMap.values();
		result.taskMap = taskMap;
        result.eventMap = eventMap;
        result.opptyMap = opptyMap;        
		system.debug('result  : ' + JSON.serializePretty(result));
        return result;
    }
    
    public class MagazzionoWrapper{
        @AuraEnabled
        public List<Account> accList;
        @AuraEnabled
        public Map<String,sObject> taskMap;
        @AuraEnabled
        public Map<String,sObject> eventMap;
        @AuraEnabled
        public Map<String,sObject> opptyMap;
    }

}