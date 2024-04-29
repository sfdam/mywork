global with sharing class  ConnectorScheduleBuilder {
    public ConnectorScheduleBuilder(Object o) { } 
    
    global static Map<String, Object> loadSchedule(String schedulGroupId) {
       System.debug('START loadSchedule :' + schedulGroupId);
        Map<String, Object> schedulerGroups = ConnectorScheduleHelper.getSchedulerGroup(schedulGroupId);
        System.debug('loadSchedule schedulerGroups :' + schedulerGroups);
        
        List<Object> openSchedules = (List<Object>)schedulerGroups.get('openSchedules');
        
        Schedule open = buildSchedule(openSchedules,'open');
        if ( open == null ) {
             Map<String, Object> result = new Map<String, Object>();
            result.put('open', false);
            return result;
        }
        List<Object> closedSchedules = (List<Object>)schedulerGroups.get('closedSchedules'); 
        Schedule closed = buildSchedule(closedSchedules,'closed');
        if ( closed == null ){
            List<Object> holidaySchedules = (List<Object>)schedulerGroups.get('holidaySchedules');
            closed = buildSchedule(holidaySchedules,'closed');
        }
        
        ScheduleEx ex = new ScheduleEx(open,closed);
        return ex.toJson();
       
    }
    
    private Static Schedule buildSchedule(List<Object> schedules, String type){
        System.debug('START buildSchedule, type : ' + type +', schedules :  ' + schedules);
        Schedule next = null;
        for(Object os : schedules){
            Map<String, Object> scheduleMap = (Map<String, Object>)os;
           
            if ( type.equals('closed')){
                  String name = (String)scheduleMap.get('name'); 
                  String ddd = datetime.now().format('dd/MM');      
                if(!name.startsWith(ddd)){
                    System.debug('buildSchedule closed and days doesnt match,id :' + scheduleMap.get('id') + ', name : ' + name + ',today : ' + ddd);
                   continue;
                }   
            }
            String scheduleId = (String)scheduleMap.get('id');
            if ( scheduleId == null ){
                System.debug('schedule id is null, skipping...');
                continue;
            }
            System.debug('getSchedule for id : ' + scheduleId);
            Map<String, Object> obj = ConnectorScheduleHelper.getSchedule(scheduleId);
            if ( obj == null ){
                System.debug('buildSchedule schedule is null, skipping, id : ' + scheduleId);
                continue;
            }
            String startTime = (String)obj.get('start');
            String endTime = (String)obj.get('end');
            System.debug('start : ' + startTime + ' - end : ' + endTime);
            Schedule schedule = new Schedule(startTime.split('T')[1], endTime.split('T')[1], type, (String)obj.get('rrule'));
            if(schedule.isInRange()){
                 System.debug('buildSchedule schedule isInRange :' + schedule);
                return schedule;                
            }
            if ( schedule.isNext() ){
                System.debug('buildSchedule schedule isNext :' + schedule);
                next = schedule;
            }
            if ( next == null ){
             System.debug('buildSchedule schedule not in range, skipping ');
       		 }
        }
        
       
        return next;
    }
    
     @RemoteAction
    global static  Map<String, Object> checkQueues(List<String> ids) {
         System.debug('START checkQueues :' + ids);
        Map<String, Object> result = new Map<String, Object>();
        GenesysSetting__c config;
         
        List<GenesysSetting__c> queues = [select id,G_MEDIA_TYPE__c, G_QUEUE_ID__c, G_SCHEDULE_GROUP_ID__c,S_MESSAGES_TIMEOUT__c, S_OMNI_ID__c  from GenesysSetting__c where G_QUEUE_ID__c in :ids];
       System.debug('checkQueues,queues :' + queues);
        for ( GenesysSetting__c q : queues ){
            System.debug('checkQueues,cycle setting :' + q);
            if ( q.G_MEDIA_TYPE__c == 'chat' ){
                System.debug('loading schedules :' + q);
                Map<String, Object> schedule = loadSchedule(q.G_SCHEDULE_GROUP_ID__c);
            	result.put('chatSchedule',schedule); 
                System.debug('checkQueues,open :' + schedule.get('open'));
                result.put('chat', q);
            }
            if ( q.G_MEDIA_TYPE__c == 'whatsapp' ){
                result.put('whatsapp', q);
            }
        }
         System.debug('checkQueues partial result :' + config);
       /*
        if ( config == null ){
            queues = [select id,G_MEDIA_TYPE__c, G_QUEUE_ID__c, G_SCHEDULE_GROUP_ID__c,S_MESSAGES_TIMEOUT__c, S_OMNI_ID__c   from GenesysSetting__c where G_MEDIA_TYPE__c = 'other'];
            if ( queues.size() == 0 ){
                return result;
            }       
            config = queues.get(0);
        }
        result.put('config', config);
*/
        return result;
    }
    
    @RemoteAction
     global static Map<String, Object> buildScheduleSettings(List<String> ids){
         Map<String, Object> result = new Map<String, Object>();
        try{
            List<GenesysSetting__c> queues = [select id,G_MEDIA_TYPE__c, G_QUEUE_ID__c, G_SCHEDULE_GROUP_ID__c,S_MESSAGES_TIMEOUT__c, S_OMNI_ID__c  from GenesysSetting__c ];
            System.debug('queues : ' + queues);
            for ( GenesysSetting__c q : queues){
                if ( q.G_MEDIA_TYPE__c == 'chat' ){          
                  Map<String, Object> chat = new Map<String, Object>();   
                    if ( ids.contains(q.G_QUEUE_ID__c) ){
                        Map<String, Object> schedule = ConnectorScheduleBuilder.loadSchedule(q.G_SCHEDULE_GROUP_ID__c);
                        System.debug('schedule : ' + schedule);
                        chat.put('chatSchedule',schedule);                  
                    }
                  chat.put('chat',q);
                  result.put(q.G_QUEUE_ID__c,chat);
                }else if ( q.G_MEDIA_TYPE__c == 'whatsapp' ){    
                    Map<String, Object> whatsapp = new Map<String, Object>();       
                    whatsapp.put(q.G_MEDIA_TYPE__c,q);  
                    result.put(q.G_QUEUE_ID__c,whatsapp);
                }
                
            }
           
            System.debug('payload : ' + result);
        }catch( Exception e ){
            System.debug('error building schedule : ' + e);
            
        }
        return result;
    }
    
       
}