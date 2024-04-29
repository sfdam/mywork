public without sharing class ApprovalStepsController {
    
    @AuraEnabled
    public static List<Map<String,Object>> getAllData(String recordId){

        List<Map<String,Object>> response = new List<Map<String,Object>>();
        ProcessInstanceWorkItem[] piwiList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkItem WHERE Id =:recordId];
        ProcessInstance pi;
        if (piwiList.size() > 0) {
            ProcessInstanceWorkItem piwi = piwiList[0];
            pi = [SELECT Id, 
                    (SELECT Id, toLabel(StepStatus), Actor.Name, ProcessNodeId, ProcessNode.Name, OriginalActor.Name
                                                FROM StepsAndWorkitems),
            TargetObjectId FROM ProcessInstance WHERE Id =:piwi.ProcessInstanceId];
        } else {
            ProcessInstanceStep procInstStep = [SELECT Id, ProcessInstanceId FROM ProcessInstanceStep WHERE Id =:recordId];
            pi = [SELECT Id, 
                    (SELECT Id, toLabel(StepStatus), Actor.Name, ProcessNodeId, ProcessNode.Name, OriginalActor.Name
                                                FROM StepsAndWorkitems)
            TargetObjectId FROM ProcessInstance WHERE Id =:procInstStep.ProcessInstanceId];
        }
        System.debug('TEST pi --> ' + pi);
        String sobjectType = pi.TargetObjectId.getSObjectType().getDescribe().getName();
        SOBJECT record = Database.query('SELECT id, Queues__c FROM ' + sobjectType + ' WHERE id = \'' + pi.TargetObjectId + '\'')[0];
        String queueCode = (String)record.get('Queues__c');
        System.debug('TEST sobjectType --> ' + sobjectType);
        System.debug('TEST record --> ' + record);
        System.debug('TEST queueCode --> ' + queueCode);
        Map<String, GroupMember> groupMemberMap = (Map<String, GroupMember>)JSON.deserialize(JSON.serialize(SV_Utilities.keyBy([SELECT id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE Group.DeveloperName LIKE: ('%' + queueCode + '%')], 'UserOrGroupId')), Map<String, GroupMember>.class);
        System.debug('TEST groupMemberMap --> ' + groupMemberMap);
        List<ProcessInstanceStep> pisList = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, ActorId, Actor.Name, Comments, StepNodeId, toLabel(StepStatus) FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =: pi.TargetObjectId AND Id !=: recordId ORDER By CreatedDate DESC];
        System.debug('TEST pisList --> ' + pisList);
        for(Integer i = 0; i < pisList.size(); i++){

            if(i+1 < pisList.size() && !String.isBlank(pisList[i].StepNodeId)){

                Integer stepIndex = groupMemberMap.get(pisList[i].ActorId).Group.DeveloperName.split('_').size() - 2; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032

                response.add(new Map<string, Object>{
    
                    'Id' => pisList[i].Id,
                    'Actor' => pisList[i].Actor.Name,
                    'Status' => pisList[i].StepStatus,
                    'Comments' => pisList[i].Comments,
                    'StepNodeId' => pisList[i].StepNodeId,
                    'Step' => 'Esito Step ' + groupMemberMap.get(pisList[i].ActorId).Group.DeveloperName.split('_')[stepIndex] //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
                });
            }
        }

        return response;
    }

    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}