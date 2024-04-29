public without sharing class ApproverHandler {
        
    //Helper method get Process Instance Work Items which represents a user’s pending approval request.
    public static Map<String, List<ProcessInstance>> getAllProcessInstancesMap(List<Id> objectIdList) {
        
        Map<String, List<ProcessInstance>> processInstanceMap = new Map<String, List<ProcessInstance>>();
        for(ProcessInstance processInstance : [SELECT Id, Status, TargetObjectId, LastActorId FROM ProcessInstance WHERE TargetObjectId IN: objectIdList AND LastActorId !=: UserInfo.getUserId()]){

            if(!processInstanceMap.containsKey(processInstance.TargetObjectId)){

                processInstanceMap.put(processInstance.TargetObjectId, new List<ProcessInstance>());
            }
            processInstanceMap.get(processInstance.TargetObjectId).add(processInstance);
        }

        return processInstanceMap;
    }
    public static void initApprovalProcess(Map<String, Map<String, Object>> sObjectApproversMap, Map<String, String> ownerIdMap, Map<String, String> noteMap) {
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
     
        for (String sObjectId : sObjectApproversMap.keySet()) {
            for (String approverId : sObjectApproversMap.get(sObjectId).keySet()) {
                
                String note = noteMap.containsKey(sObjectId) ? noteMap.get(sObjectId) : '';
                //Class to submit a record for approval.
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                //Sets the comments to be added to the approval request
                approvalRequest.setComments(note);
                //Sets the ID of the record to be submitted for approval. For example, it can specify
                // an account, contact, or custom object record.
                approvalRequest.setObjectId(sObjectId);
                //If the next step in your approval process is another Apex approval process, you specify
                // exactly one user ID as the next approver. If not, you cannot specify a user ID and this
                // method must be null

                approvalRequest.setSubmitterId(ownerIdMap.get(sObjectId));
                approvalRequest.setNextApproverIds(new List<Id>{approverId});
                 
                approvalRequestList.add(approvalRequest);
            }
        }
        
        System.debug('approvalRequestList: ' + JSON.serializePretty(approvalRequestList));
        Approval.process(approvalRequestList);
    }
}