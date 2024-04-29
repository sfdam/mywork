public without sharing class AvocaIterController {

    public virtual class BaseException extends Exception {}
    
    public static Map<String,Set<String>> avocaMap = new Map<String,Set<String>>{
        'NEC_A.1' => new Set<String>{'NEC_T.4','NEC_F.1'},
        'NEC_T.1' => new Set<String>{'NEC_A.1','NEC_T.4','NEC_F.10'},
        'NEC_T.4' => new Set<String>{'NEC_F.10'},
        'NEC_D.10' => new Set<String>{'NEC_T.7'}
    };

    public static Map<String,Set<String>> avocaMapNotPresent = new Map<String,Set<String>>{
        'NEC_T.1' => new Set<String>{'NEC_T.4'},
        'NEC_T.4' => new Set<String>{'NEC_F.10'}
    };

    public static Map<String,String> avocaFieldMap = new Map<String,String>{
        'NEC_A.1' => 'PTF_Area__c',
        'NEC_T.1' => 'PTF_DirezioneRegionale__c',
        'NEC_D.10' => 'PTF_Banca__c'
    };

    public static Map<String,String> approvalStatusMap = new Map<String,String>{
        'Approvato' => 'Approve',
        'Rifiutato' => 'Reject'
    };

    public static Contact currentUser {
        get{
            if(currentUser!=null) return currentUser;
            
            currentUser = [SELECT Id, PTF_User__c, Account.PTF_IdCed__c, PTF_User__r.Profilo__c, PTF_RegistrationNumber__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
            return currentUser;
        }set;
    }

    public static Set<String> bdsIdCedSet = new Set<String>{'4439','6928','6929'};
    @AuraEnabled
    public static Map<String, Object> init(String recordId) {

        Boolean hasNF = false;
        WorkOrder wo = [SELECT StepsApprovers__c, Queues__c, Status, Step__c, PTF_StoriaAvocazione__c,
        PTF_Origine__r.PTF_ABI__c, PTF_Origine__r.PTF_Area__c,PTF_Origine__r.PTF_DirezioneRegionale__c, PTF_Origine__r.PTF_Banca__c,
        PTF_Destinazione__r.PTF_Area__c,PTF_Destinazione__r.PTF_DirezioneRegionale__c, PTF_Destinazione__r.PTF_Banca__c
        FROM Workorder WHERE id =: recordId LIMIT 1][0];
        if(wo.Status != 'Pending')return null;
        
        // String avocazioneSteps = wo.PTF_StoriaAvocazione__c;
        List<String> avocazioneStepsList = !String.isBlank(wo.PTF_StoriaAvocazione__c) ? wo.PTF_StoriaAvocazione__c.split(',') : new List<String>();
        Map<String, String> avocazioneStepsMap = new Map<String, String>();
        for(Integer i=1; i<=avocazioneStepsList.size(); i++){

            avocazioneStepsMap.put(avocazioneStepsList[i-1].substringBefore('_'), avocazioneStepsList[i-1].substringAfter('_'));
        }

        System.debug('DK avocazioneStepsMap: ' + JSON.serialize(avocazioneStepsMap));
        Map<String, Object> woMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(wo));
        Map<String, Object> origineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(woMap.get('PTF_Origine__r')));
        Map<String, Object> destinazioneMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(woMap.get('PTF_Destinazione__r')));
        List<String> stepsApprovers = wo.StepsApprovers__c.split('\\), ');

        // Contact currentUser = [SELECT Id, PTF_User__c, Account.PTF_IdCed__c, PTF_User__r.Profilo__c, PTF_RegistrationNumber__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
        List<Group> groups = [SELECT id, Name, DeveloperName, (SELECT ID, UserOrGroupId, Group.DeveloperName FROM GroupMembers) FROM Group WHERE DeveloperName LIKE: '%' + wo.Queues__c + '%'];
        Map<String, List<GroupMember>> queueMap = new Map<String, List<GroupMember>>();
        Map<String, String> queueNameMap = new Map<String, String>();
        Map<String,GroupMember> memberMap = new Map<String,GroupMember>();
        for(Group queue: groups){

            queueMap.put(queue.DeveloperName, queue.GroupMembers);
            queueNameMap.put(queue.Name, queue.id);
            for(GroupMember gm : queue.GroupMembers){
                memberMap.put(gm.UserOrGroupId, gm);
            }
        }
        Set<String> piwiList = SV_Utilities.keyBy([SELECT Id, ProcessInstance.TargetObjectId, ActorId
                                                    FROM ProcessInstanceWorkitem
                                                    WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId =: wo.Id], 'ActorId').keySet();
        Map<String,Integer> groupMap = new Map<String,Integer>();
        for(String queueName : queueMap.keySet()){

            // if(piwiList.contains((String)queueMap.get(queueName)[0].get('GroupId'))){

                String step = queueName.split('_')[3];
                if(!groupMap.containsKey(step)){
                    groupMap.put(step, 1);
                }else{
                    groupMap.put(step, 2);
                }
            // }
        }
        Map<String,SObject> contactMap = SV_Utilities.keyBy([SELECT PTF_User__c, Name, PTF_User__r.Profilo__c, AccountId, Account.PTF_Area__c, Account.PTF_DirezioneRegionale__c, Account.PTF_Banca__c FROM Contact WHERE PTF_User__c IN: memberMap.keySet()], 'PTF_User__c');
        String userProfile = currentUser.PTF_User__r.Profilo__c;

        if(currentUser.PTF_User__r.Profilo__c == 'NEC_D.0' || (currentUser.PTF_User__r.Profilo__c == 'NEC_D.2' && bdsIdCedSet.contains(currentUser.Account.PTF_IdCed__c) && wo.PTF_Origine__r.PTF_ABI__c == '01015')){
            List<String> storiaAvocazioneList = new List<String>();
            // if(Integer.valueOf(step) > Integer.valueOf(wo.Step__c)){

            for(Group queue : groups){
                if(piwiList.contains(queue.Id)){
                    if(avocazioneStepsMap.containsKey(currentUser.PTF_RegistrationNumber__c)){
                        String value = avocazioneStepsMap.get(currentUser.PTF_RegistrationNumber__c);
                        avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, value + '-' + queue.Id);
                    }else{
                        avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queue.Id);
                    }
                }
            }
            // }
            for(String key : avocazioneStepsMap.keySet()){
                storiaAvocazioneList.add(key + '_' + avocazioneStepsMap.get(key));
            }
            return new Map<String, Object>{
                'action' => 'close',
                'storiaAvocazione' => String.join(storiaAvocazioneList, ',')
            };
        }else{
            if(avocaMap.containsKey(userProfile)){
                //PROFILO ABILITATO
                if(!memberMap.containsKey(currentUser.PTF_User__c)){
                    ///UTENTE CORRENTE NON E' PRESENTE COME APPROVATORE
                    for(String userId : memberMap.keySet()){
                        if(piwiList.contains((String)memberMap.get(userId).get('GroupId'))){

                            Contact contact = (Contact)contactMap.get(userId);
                            if(avocaMapNotPresent.containsKey(userProfile) && avocaMapNotPresent.get(userProfile).contains(contact.PTF_User__r.Profilo__c)){
                                //E' PRESENTE UTENTE CON PROFILO AVOCABILE
                                if(destinazioneMap.get(avocaFieldMap.get(userProfile)) == currentUser.AccountId ||
                                    origineMap.get(avocaFieldMap.get(userProfile)) == currentUser.AccountId){
                                    System.debug('DK CASE 4');
                                    GroupMember member = (GroupMember)memberMap.get(userId);
                                    String step = member.Group.DeveloperName.split('_')[3];
                                    avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, (String)memberMap.get(userId).get('GroupId'));

                                    //E' NEL PERIMETRO
                                    List<String> storiaAvocazioneList = new List<String>();
                                    if(Integer.valueOf(step) > Integer.valueOf(wo.Step__c)){

                                        for(Group queue : groups){
                                            if(piwiList.contains(queue.Id)){
                                                if(avocazioneStepsMap.containsKey(currentUser.PTF_RegistrationNumber__c)){
                                                    String value = avocazioneStepsMap.get(currentUser.PTF_RegistrationNumber__c);
                                                    avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, value + '-' + queue.Id);
                                                }else{
                                                    avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queue.Id);
                                                }
                                            }
                                        }
                                    }
                                    for(String key : avocazioneStepsMap.keySet()){
                                        storiaAvocazioneList.add(key + '_' + avocazioneStepsMap.get(key));
                                    }
                                    return new Map<String, Object>{
                                        'action' => 'replace',
                                        'case' => '4',
                                        // 'hasNF' => hasNF,
                                        'groupMap' => groupMap,
                                        'piwiList' => piwiList,
                                        'step' => Integer.valueOf(step),
                                        'currentStep' => Integer.valueOf(wo.Step__c),
                                        'queueId' => (String)memberMap.get(userId).get('GroupId'),
                                        'storiaAvocazione' => String.join(storiaAvocazioneList, ',')
                                    };
                                }
                            }
                        }
                    }
                }else{

                    //UTENTE CORRENTE E' PRESENTE COME APPROVATORE
                    GroupMember member = (GroupMember)memberMap.get(currentUser.PTF_User__c);
                    String workOrderKey = member.Group.DeveloperName.split('_')[1];
                    String parere = member.Group.DeveloperName.split('_')[2];
                    String step = member.Group.DeveloperName.split('_')[3];
                    if(Integer.valueOf(step) > Integer.valueOf(wo.Step__c)){
                        for(Integer i = 0; i < stepsApprovers.size(); i++){
                            Integer approverStep = i+1;
                            for(String avocableProfile : avocaMap.get(userProfile)){
                                if(stepsApprovers[i].contains(avocableProfile) && Integer.valueOf(step) > Integer.valueOf(wo.Step__c) && Integer.valueOf(step) > approverStep){

                                    //IN QUSTO STEP C'E' UN PROFILO AVOCABILE DALL'UTENTE CORRENTE
                                    //UTENTE CORRENTE IN UNO STEP SUCCESSIVO A QUELLO CORRENTE
                                    // hasNF = stepsApprovers[i].contains(avocableProfile + ' NF');
                                    if(groupMap.get(step) == 1){

                                        //UTENTE CORRENTE E' UNICO APPROVATORE DI QUESTO STEP
                                        if(Integer.valueOf(step) == stepsApprovers.size()){

                                            //UTENTE CORRENTE E' ALL'ULTIMO STEP
                                            avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, (String)memberMap.get(currentUser.PTF_User__c).get('GroupId'));
                                            List<String> storiaAvocazioneList = new List<String>();
                                            for(Group queue : groups){
                                                if(piwiList.contains(queue.Id)){
                                                    if(avocazioneStepsMap.containsKey(currentUser.PTF_RegistrationNumber__c)){
                                                        String value = avocazioneStepsMap.get(currentUser.PTF_RegistrationNumber__c);
                                                        avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, value + '-' + queue.Id);
                                                    }else{
                                                        avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queue.Id);
                                                    }
                                                }
                                            }

                                            for(String key : avocazioneStepsMap.keySet()){
                                                storiaAvocazioneList.add(key + '_' + avocazioneStepsMap.get(key));
                                            }

                                            System.debug('DK CASE 1');
                                            return new Map<String, Object>{
                                                'action' => 'close',
                                                'case' => '1',
                                                // 'hasNF' => hasNF,
                                                'groupMap' => groupMap,
                                                'piwiList' => piwiList,
                                                'step' => Integer.valueOf(step),
                                                'currentStep' => Integer.valueOf(wo.Step__c),
                                                'queueId' => (String)memberMap.get(currentUser.PTF_User__c).get('GroupId'),
                                                'storiaAvocazione' => String.join(storiaAvocazioneList, ', ')
                                            };
                                        }else{
                                            //UTENTE CORRENTE NON E' ALL'ULTIMO STEP

                                            // CR 58356 -- AVOCA ITER EXECUTIVE
                                            String queueId = '';
                                            List<String> steps = stepsApprovers[i].substringAfter('(').substringBefore(')').split(', ');
                                            if(userProfile == 'NEC_D.10'){
                                                for(Integer k = 0 ; k< steps.size(); k++){
                                                    if(steps[k].contains(avocableProfile)){
                                                        queueId = queueNameMap.get('Approvers Step ' + approverStep + ' Queue' + String.valueOf(k+1));
                                                        break;
                                                    }
                                                }
                                            }

                                            if(!String.isBlank(queueId) && !piwiList.contains(queueId)){
                                                return null;
                                            }

                                            List<String> storiaAvocazioneList = new List<String>();
                                            if(!String.isBlank(queueId)){
                                                avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queueId);
                                            }else{
                                                
                                                avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, (String)memberMap.get(currentUser.PTF_User__c).get('GroupId'));
                                                for(Group queue : groups){
                                                    if(piwiList.contains(queue.Id)){
                                                        if(avocazioneStepsMap.containsKey(currentUser.PTF_RegistrationNumber__c)){
                                                            String value = avocazioneStepsMap.get(currentUser.PTF_RegistrationNumber__c);
                                                            avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, value + '-' + queue.Id);
                                                        }else{
                                                            avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queue.Id);
                                                        }
                                                    }
                                                }
                                            }

                                            for(String key : avocazioneStepsMap.keySet()){
                                                storiaAvocazioneList.add(key + '_' + avocazioneStepsMap.get(key));
                                            }

                                            if(String.isBlank(queueId)){
                                                queueId = (String)memberMap.get(currentUser.PTF_User__c).get('GroupId');
                                            }
                                            // CR 58356 -- AVOCA ITER EXECUTIVE

                                            System.debug('DK CASE 2');
                                            return new Map<String, Object>{
                                                'action' => 'replace',
                                                'case' => '2',
                                                'groupMap' => groupMap,
                                                'piwiList' => piwiList,
                                                // 'hasNF' => hasNF,
                                                'step' => userProfile == 'NEC_D.10' ? Integer.valueOf(wo.Step__c) : Integer.valueOf(step),
                                                'currentStep' => Integer.valueOf(wo.Step__c),
                                                'queueId' => queueId,
                                                'storiaAvocazione' => String.join(storiaAvocazioneList, ', ')
                                            };
                                        }
                                    }else{
                                        //NON E' UNICO APPROVATORE DI QUESTO STEP
                                        Integer caseI = 0;
                                        // CR 58356 -- AVOCA ITER EXECUTIVE
                                        String queueId = '';
                                        List<String> steps = stepsApprovers[i].substringAfter('(').substringBefore(')').split(', ');
                                        if(userProfile == 'NEC_D.10'){
                                            for(Integer k = 0 ; k< steps.size(); k++){
                                                if(steps[k].contains(avocableProfile)){
                                                    queueId = queueNameMap.get('Approvers Step ' + approverStep + ' Queue' + String.valueOf(k+1));
                                                    break;
                                                }
                                            }
                                        }

                                        if(!String.isBlank(queueId) && !piwiList.contains(queueId)){
                                            return null;
                                        }

                                        List<String> storiaAvocazioneList = new List<String>();
                                        if(!String.isBlank(queueId)){
                                            avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queueId);
                                        }else{
                                            
                                            avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, (String)memberMap.get(currentUser.PTF_User__c).get('GroupId'));
                                            for(Group queue : groups){
                                                if(piwiList.contains(queue.Id)){
                                                    if(avocazioneStepsMap.containsKey(currentUser.PTF_RegistrationNumber__c)){
                                                        String value = avocazioneStepsMap.get(currentUser.PTF_RegistrationNumber__c);
                                                        avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, value + '-' + queue.Id);
                                                    }else{
                                                        avocazioneStepsMap.put(currentUser.PTF_RegistrationNumber__c, queue.Id);
                                                    }
                                                }
                                            }

                                            caseI = 2;
                                        }

                                        for(String key : avocazioneStepsMap.keySet()){
                                            storiaAvocazioneList.add(key + '_' + avocazioneStepsMap.get(key));
                                        }

                                        if(String.isBlank(queueId)){
                                            queueId = (String)memberMap.get(currentUser.PTF_User__c).get('GroupId');
                                            caseI = 3;
                                        }
                                        // CR 58356 -- AVOCA ITER EXECUTIVE
                                        System.debug('DK CASE 3');
                                        System.debug('DK step: ' + wo.Step__c);
                                        System.debug('DK piwiList: ' + JSON.serialize(piwiList));
                                        System.debug('DK groupMap: ' + JSON.serialize(groupMap));
                                        return new Map<String, Object>{
                                            'action' => 'replace',
                                            'case' => '3',
                                            // 'hasNF' => hasNF,
                                            'groupMap' => groupMap,
                                            'piwiList' => piwiList,
                                            'step' => userProfile == 'NEC_D.10' ? Integer.valueOf(wo.Step__c) : Integer.valueOf(step),
                                            'currentStep' => Integer.valueOf(wo.Step__c),
                                            'queueId' => queueId,
                                            'storiaAvocazione' => String.join(storiaAvocazioneList, ', ')
                                        };
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    @AuraEnabled
    public static String closeIter(String recordId, String status, String nota, String action, String queueId, Integer step, Integer currentStep, String storiaAvocazione) {

        Map<String, Object> requestBody = new Map<String, Object>{
            'recordId' => recordId
        };

        Http req = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Map<String, Object> response = new Map<String, Object>();
        String responseBody = '';
        if((step != null && currentStep != null && step > currentStep) || action != 'replace'){
            request.setEndpoint('callout:CallMeBack/services/apexrest/iterhandler');
            request.setHeader('Content-Type', 'Application/JSON');
            request.setMethod('PATCH');
            request.setTimeout(120000);
            System.debug('DK requestBody: ' + JSON.serialize(requestBody));
            request.setBody(JSON.serialize(requestBody));
            if(!Test.isRunningTest()){

                responseBody = req.send(request).getBody();
            }else{
                responseBody = JSON.serialize(JSON.serialize(new Map<String, String>()));
            }
            System.debug('DK responseBody: ' + responseBody);
            response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
        }
        System.debug('DK responseBody: ' + responseBody);
        if(currentUser.PTF_User__r.Profilo__c == 'NEC_D.0' ||
            currentUser.PTF_User__r.Profilo__c == 'NEC_D.2'){

            if(response.containsKey('errorMessage')){
                throw new AuraHandledException((String)response.get('errorMessage'));
            }else{
                update new WorkOrder(Id = recordId, Status = status, PTF_NotaAvocazione__c = nota, PTF_Avocatore__c = UserInfo.getUserId(), PTF_StoriaAvocazione__c = storiaAvocazione);
            }
        }else{

            if(Integer.valueOf(step) > Integer.valueOf(currentStep)){

                Map<String, String> ownerIdMap = new Map<String, String> {
                    recordId => UserInfo.getUserId()
                };
                if(!Test.isRunningTest()){
                    OnWorkOrderTriggerHandler.skip = true;
                    WorkOrder wo = new WorkOrder(Id = recordId, Step__c = String.valueOf(step), OwnerId = UserInfo.getUserId(), PTF_StoriaAvocazione__c = storiaAvocazione);
                    if(action == 'close'){
                        wo.PTF_NotaAvocazione__c = nota;
                        wo.PTF_Avocatore__c = UserInfo.getUserId();
                    }
                    update wo;
                    List<WorkOrder> woList = [SELECT Id, Step__c, Queues__c, OwnerId FROM WorkOrder WHERE Id =: recordId];
                    Map<String,  Map<String, Boolean>> workOrderApproversMap = OnWorkOrderTriggerHandler.getApprovers(woList);

                    ApproverHandler.initApprovalProcess(workOrderApproversMap, ownerIdMap, new Map<String, String>());
                }
                OnWorkOrderTriggerHandler.skip = false;
            }else{
                if(!Test.isRunningTest()){
                    OnWorkOrderTriggerHandler.skip = true;
                    update new WorkOrder(Id = recordId, PTF_StoriaAvocazione__c = storiaAvocazione);
                }
            }
            requestBody = new Map<String, Object>{
                'recordId' => recordId,
                'status' => approvalStatusMap.get(status),
                'queueId' => queueId
            };

            String requestBodyJSON = JSON.serialize(requestBody);
            updateStep(requestBodyJSON, String.valueOf(step), String.valueOf(currentStep), recordId);
        }
        return responseBody;
    }


    @future(callout=true)
    public static void updateStep(String requestBodyJSON, String step, String currentStep, String recordId){
        
        Http req = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Map<String, Object> response = new Map<String, Object>();
        String responseBody = '';
        req = new Http();
        request = new HttpRequest();
        request.setEndpoint('callout:CallMeBack/services/apexrest/iterhandler');
        request.setHeader('Content-Type', 'Application/JSON');
        request.setMethod('PATCH');
        request.setTimeout(120000);
        System.debug('DK requestBody: ' + requestBodyJSON);
        request.setBody(requestBodyJSON);
        resp = new HttpResponse();
        if(!Test.isRunningTest()){

            responseBody = req.send(request).getBody();
        }else{
            responseBody = JSON.serialize(JSON.serialize(new Map<String, String>()));
        }
        System.debug('DK responseBody: ' + responseBody);
        response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
        /*if(response.containsKey('errorMessage')){
            throw new AuraHandledException((String)response.get('errorMessage'));
        }
        return responseBody;*/
    }
}