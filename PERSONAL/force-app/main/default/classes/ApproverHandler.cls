public with sharing class ApproverHandler {
    

    //Helper method get Process Instance Work Items which represents a user’s pending approval request.
    @AuraEnabled
    public static Id getSobjectId(Id processId) {
        return [
                SELECT
                        Id, ProcessInstance.TargetObjectId
                FROM
                        ProcessInstanceWorkitem
                WHERE
                        Id =: processId
        ].ProcessInstance.TargetObjectId;
    }

    //Helper method get Process Instance Work Items which represents a user’s pending approval request.
    private static List<ProcessInstance> getAllProcessInstances(Id objectId) {
        return [
                SELECT
                        Id, Status
                FROM
                        ProcessInstance
                WHERE
                        TargetObjectId =: objectId
        ];
    }

    //Helper method get Process Instance Work Items which represents a user’s pending approval request.
    private static List<ProcessInstanceWorkitem> getProcessInstanceWorkItems(Id objectId) {
        return [
                SELECT
                        Id
                FROM
                        ProcessInstanceWorkitem
                WHERE
                        ProcessInstance.TargetObjectId =: objectId AND
                        ActorId =: UserInfo.getUserId()
        ];
    }
    
    //Helper method to create new Process Work Item Request record to process an approval request after it is submitted.
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, String approvalAction, String commentFromApprover){
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);
        return result;
    }

    public static void initApprovalProcess(List<Id> sObjectIdList) {
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
     
        List<User> managerUserList = [
                SELECT
                        Id
                FROM
                        User
                WHERE
                        Position__c = 'Manager'
        ];
     
        System.debug('managerUserList: ' + JSON.serializePretty(managerUserList));
        for (Id sObjectId : sObjectIdList) {
            for (User managerUser : managerUserList) {
                
                //Class to submit a record for approval.
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                //Sets the comments to be added to the approval request
                approvalRequest.setComments('Submitting request for approval to Managers.');
                //Sets the ID of the record to be submitted for approval. For example, it can specify
                // an account, contact, or custom object record.
                approvalRequest.setObjectId(sObjectId);
                //If the next step in your approval process is another Apex approval process, you specify
                // exactly one user ID as the next approver. If not, you cannot specify a user ID and this
                // method must be null
                approvalRequest.setNextApproverIds(new List<Id>{managerUser.Id});
                 
                approvalRequestList.add(approvalRequest);
            }
        }
        
        System.debug('approvalRequestList: ' + JSON.serializePretty(approvalRequestList));
        Approval.process(approvalRequestList);
    }

    @AuraEnabled
    public static void handleActionForManager(Id sObjectId, String action, String commentFromApprover) {
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        Boolean isApproved = true;
        
        for (ProcessInstanceWorkitem workItem : getProcessInstanceWorkItems(sObjectId)) {
            approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, action, commentFromApprover));
        }

        Approval.process(approvalRequestList);

        for(ProcessInstance item : getAllProcessInstances(sObjectId)){

            if(item.Status != 'Approved'){

                isApproved = false;
                break;
            }
        }
     
        if(isApproved){
            
            List<Approval.ProcessSubmitRequest> newApprovalRequestList = new List<Approval.ProcessSubmitRequest>();
            List<User> directorUserList = [
                    SELECT
                            Id
                    FROM
                            User
                    WHERE
                            Position__c = 'Director'
            ];
            update new WorkOrder(id = sObjectId, Status = 'Secondo Step');
            for (User directorUser : directorUserList) {
                
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitting request for approval to Directors.');
                approvalRequest.setObjectId(sObjectId);
                approvalRequest.setNextApproverIds(new List<Id>{directorUser.Id});
                newApprovalRequestList.add(approvalRequest);
            }

            Approval.process(newApprovalRequestList);
        }
    }
}