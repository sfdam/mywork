public class OnTaskTriggerHandler {
    public static void notifySerOwner(Map<Id,Task> oldTaskMap,Map<Id,Task> newTaskMap) {
        Id typeId = [SELECT Id FROM CUstomNotificationType WHERE DeveloperName = 'Notify_Task_to_Study_Owner'].Id;
        Set<Id> serIds = new Set<Id>();
        List<Task> notifyTaskList = new List<Task>();
        for(Task t : newTaskMap.values()){
            if(oldTaskMap.get(t.Id).Status != t.Status && t.Status == 'Completed' && t.WhatId != null && (t.WhatId).getSObjectType().getDescribe().getName() == 'SER__c' ){
                serIds.add(t.WhatId);
                notifyTaskList.add(t);
            }
        }
        if(serIds.isEmpty())return;
        Map<Id,SER__c> serMap = new Map<Id,SER__c>([SELECT Id,Owner__c FROM SER__c WHERE Id IN: serIds]);
        for(Task t : notifyTaskList){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody('A SER-related task has been completed...');
            notification.setTitle('TASK '+t.Subject+' is Completed!');
            notification.setSenderId(Userinfo.getUserId());
            notification.setNotificationTypeId(typeId);
            notification.setTargetId(t.Id); // target object id
            try {
                notification.send(new Set<String> {serMap.get(t.WhatId).Owner__c}); // target user id.
            }catch(Exception e){
                t.addError('Problem sending notification: ' + e.getMessage());
            }
        }
    }
}