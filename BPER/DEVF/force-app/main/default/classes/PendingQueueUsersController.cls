public without sharing class PendingQueueUsersController {
    
    @AuraEnabled
    public static Map<String, List<Contact>> getAllData(String recordId){

        Map<String, SObject> requestQueueMap = SV_Utilities.keyBy([SELECT Id, ActorId,  ProcessInstance.Status, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status ='Pending' AND ProcessInstance.TargetObjectId =: recordId], 'ActorId');
        Map<String, GroupMember> memberMap = (Map<String, GroupMember>)JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT Id, GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN: requestQueueMap.keySet()], 'UserOrGroupId')), Map<String, groupmember>.class);
        Map<String, SObject> userMap = SV_Utilities.keyBy([SELECT Id, Name, Account.Name, PTF_User__r.Profilo__c, PTF_Ruolo__c, PTF_User__c FROM Contact WHERE PTF_User__c IN: memberMap.keySet()],'PTF_User__c');
        Map<String, List<Contact>> queueMembersMap = new Map<String, List<Contact>>();
        for(String userId : userMap.keySet()){
            String groupName = (String)memberMap.get(userId).Group.Name;
            if(!queueMembersMap.containsKey(groupName)){

                queueMembersMap.put(groupName, new List<Contact>());
            }
            queueMembersMap.get(groupName).add((Contact)userMap.get(userId));
        }
        return !queueMembersMap.isEmpty() ? queueMembersMap : null;
    }
}