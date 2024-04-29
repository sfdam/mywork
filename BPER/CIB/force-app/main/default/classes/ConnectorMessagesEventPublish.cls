public with sharing class ConnectorMessagesEventPublish {
    @AuraEnabled(cacheable=false)
    public static void createMessagesEvent(){
   	  JSONGenerator gen = JSON.createGenerator(true);
        try{
            List<GenesysSetting__c> queues = [select id,G_MEDIA_TYPE__c, G_QUEUE_ID__c, G_SCHEDULE_GROUP_ID__c,S_MESSAGES_TIMEOUT__c, S_OMNI_ID__c  from GenesysSetting__c ];
            System.debug('queues : ' + queues);
            gen.writeStartObject();
            for ( GenesysSetting__c q : queues){
               
                System.debug('writing field name : ' + q.G_QUEUE_ID__c);
                  gen.writeFieldName(q.G_QUEUE_ID__c);
                  gen.writeStartObject();  
                System.debug('writing field name : ' + q.G_MEDIA_TYPE__c);
                  gen.writeFieldName(q.G_MEDIA_TYPE__c);
                  gen.writeObject(q);
               
                 if ( q.G_MEDIA_TYPE__c == 'chat' ){               
                  Map<String, Object> schedule = ConnectorScheduleBuilder.loadSchedule(q.G_SCHEDULE_GROUP_ID__c);
                  System.debug('schedule : ' + schedule);
                  gen.writeFieldName('chatSchedule');
                  gen.writeObject(schedule);
                }
                 gen.writeEndObject();
            }
           
            System.debug('payload : ' + gen.getAsString());
        }catch( Exception e ){
            System.debug('error building schedule : ' + e);
            gen = JSON.createGenerator(true);
             gen.writeStartObject();
             gen.writeEndObject();
        }
        // gen.writeEndObject();
        connector_load_schedule_event__e cls = new connector_load_schedule_event__e(schedule__c=gen.getAsString());
        EventBus.publish(cls);
    }
    
    
}