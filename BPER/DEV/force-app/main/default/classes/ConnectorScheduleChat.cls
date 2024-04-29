@RestResource(urlMapping='/chatschedule/*')
global class ConnectorScheduleChat {
    global ConnectorScheduleChat() {}
    
    @HttpGet
    global static Map<String,String> isOpen() {
		Map<String, String> result = new Map<String,String>();
         result.put('status','closed');
        String dateformat = 'yyyy-MM-dd\'T\'HH:mm:ss';
        
        String schedulGroupId = getSchedulGroupId();//'a52553cf-d3f5-47bb-83d2-abd49575a0dd';
                    
        Map<String, Object> schedulerGroups = ConnectorScheduleHelper.getSchedulerGroup(schedulGroupId);
        String timeZone = (String)schedulerGroups.get('timeZone');
        
        List<Object> closedSchedules = (List<Object>)schedulerGroups.get('closedSchedules');
        System.debug('closedSchedules: ' + closedSchedules);
        if(isClosed(closedSchedules)){
            result.put('status','pike');
            return result;
        }
        
        List<Object> holidaySchedules = (List<Object>)schedulerGroups.get('holidaySchedules');
        System.debug('holidaySchedules: ' + holidaySchedules);
        
        if(isClosed(holidaySchedules)){     
            return result;
        }
        
        List<Object> openSchedules = (List<Object>)schedulerGroups.get('openSchedules');
        System.debug('openSchedules: ' + openSchedules);
        if(isOpen(openSchedules)){
           result.put('status','open');
            return result;
        }
        
        return result;
    }
    
    public Static String getSchedulGroupId(){
       	String result; 
        List<GenesysSetting__c> schedulGroup = [select id,G_MEDIA_TYPE__c, G_SCHEDULE_GROUP_ID__c  from GenesysSetting__c where G_MEDIA_TYPE__c = 'chat'];
       	System.debug('checkQueues,queues :' + schedulGroup);
        for ( GenesysSetting__c sg : schedulGroup ){
            System.debug('checkQueues,cycle setting :' + sg);
            result = sg.G_SCHEDULE_GROUP_ID__c;
        }
        return result;
    }
    
    public Static Boolean isClosed(List<Object> closedSchedules){
        for(Object cs : closedSchedules){
            Map<String, Object> closedMap = (Map<String, Object>)cs;
            String name = (String)closedMap.get('name');
            if(name.contains(datetime.now().format('dd/MM'))){
                Map<String, Object> closedObj = ConnectorScheduleHelper.getSchedule((String)closedMap.get('id'));
                String closedStartTime = (String)closedObj.get('start');
                String closedEndTime = (String)closedObj.get('end');
                System.debug('start : ' + closedStartTime + ' - end : ' + closedEndTime);
                Schedule schedule = new Schedule(closedStartTime.split('T')[1], closedEndTime.split('T')[1], 'closed', (String)closedObj.get('rrule'));
                if(schedule.isClosed()){
                    return true;
                }
            }         
        }
        return false;
    }
    
    public Static Boolean isOpen(List<Object> openSchedules){
        for(Object os : openSchedules){
            Map<String, Object> openMap = (Map<String, Object>)os;
            System.debug('open Map: ' + openMap);
            String name = (String)openMap.get('name'); 
            Map<String, Object> openObj = ConnectorScheduleHelper.getSchedule((String)openMap.get('id'));
            String openStartTime = (String)openObj.get('start');
            String openEndTime = (String)openObj.get('end');
            System.debug('start : ' + openStartTime + ' - end : ' + openEndTime);
            Schedule schedule = new Schedule(openStartTime.split('T')[1], openEndTime.split('T')[1], 'open', (String)openObj.get('rrule'));
            if(schedule.isOpen()){
                return true;
            }         
        }
        return false;
    }
}