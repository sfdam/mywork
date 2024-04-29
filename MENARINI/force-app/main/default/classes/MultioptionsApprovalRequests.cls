public with sharing class MultioptionsApprovalRequests {

    public class ApprovalRequests {
        @AuraEnabled public List<Case> cases {get; set;}
        @AuraEnabled public List<THR_Related_Object__c> caseItems {get; set;}
        @AuraEnabled public List<ProcessInstanceWorkitem> processInstanceWorkitems {get; set;}
        @AuraEnabled public List<ProcessInstanceStep> processInstanceSteps {get; set;}
    }

    @AuraEnabled
    public static ApprovalRequests getMultioptionsApprovalRequests() {
        return getApprovalRequests(true);
    }

    @AuraEnabled
    public static ApprovalRequests getStandardApprovalRequests() {
        return getApprovalRequests(false);
    }

    @AuraEnabled
    public static String approve(List<String> processInstanceWorkitemIds, String comments) {
        return approvalProcess('Approve', processInstanceWorkitemIds, comments);
    }

    @AuraEnabled
    public static String reject(List<String> processInstanceWorkitemIds, String comments) {
        return approvalProcess('Reject', processInstanceWorkitemIds, comments);
    }

    @AuraEnabled
    public static void reassign(List<String> processInstanceWorkitemIds, String userId) {
        List<ProcessInstanceWorkitem> processInstanceWorkitems = [SELECT Id FROM ProcessInstanceWorkitem WHERE Id IN :processInstanceWorkitemIds];

        for(ProcessInstanceWorkitem processInstanceWorkitem : processInstanceWorkitems) {
            processInstanceWorkitem.ActorId = userId;
        }

        update processInstanceWorkitems;
    }
    
    private static ApprovalRequests getApprovalRequests(Boolean multiOptions) {
        ApprovalRequests approvalRequests = new ApprovalRequests();
        approvalRequests.cases = new List<Case>();
        approvalRequests.caseItems = new List<THR_Related_Object__c>();
        approvalRequests.processInstanceWorkitems = new List<ProcessInstanceWorkitem>();

        List<ProcessInstanceWorkitem> processInstanceWorkitems = new List<ProcessInstanceWorkitem>();
        Set<String> targetObjectIds = new Set<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : [SELECT ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.type, ProcessInstance.SubmittedById, ProcessInstance.SubmittedBy.Name, ProcessInstance.CreatedDate, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObject.type = 'Case' AND ProcessInstance.Status = 'Pending' AND ActorId = :UserInfo.getUserId() ORDER BY CreatedDate LIMIT 100]) {
            processInstanceWorkitems.add(processInstanceWorkitem);
            targetObjectIds.add(processInstanceWorkitem.ProcessInstance.TargetObjectId);
        }

        Set<String> caseIds = new Set<String>();
        String query = 'SELECT Id, CaseNumber, Account.Name, RecordType.Name, THR_CreditValue_RU__c, THR_Approval_Options__c FROM Case WHERE Id IN :targetObjectIds AND THR_Approval_Options__c ' + (multiOptions ? ' != NULL' : ' = NULL');
        for(Case caseItem : Database.query(query)) {
            approvalRequests.cases.add(caseItem);
            caseIds.add(caseItem.Id);
        }

        if(multiOptions) {
            approvalRequests.caseItems = [SELECT Id, THR_Case_Related__c, THR_Case_Related__r.CaseNumber, THR_Product__c, THR_Product__r.Name, THR_Product_Quantity__c FROM THR_Related_Object__c WHERE THR_Case_Related__c IN :caseIds ORDER BY THR_Case_Related__r.CaseNumber];
        }

        Set<String> processInstanceIds = new Set<String>();
        Set<String> SubmittedByIds = new Set<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : processInstanceWorkitems) {
            if(caseIds.contains(processInstanceWorkitem.ProcessInstance.TargetObjectId)) {
                approvalRequests.processInstanceWorkitems.add(processInstanceWorkitem);
                processInstanceIds.add(processInstanceWorkitem.ProcessInstanceId);
                SubmittedByIds.add(processInstanceWorkitem.ProcessInstance.SubmittedById);
            }
        }

        approvalRequests.processInstanceSteps = [SELECT Id, ProcessInstanceId, ActorId, Comments FROM ProcessInstanceStep WHERE ProcessInstanceId IN :processInstanceIds AND ActorId IN :SubmittedByIds];
        return approvalRequests;
    }

    private static String approvalProcess(String action, List<String> processInstanceWorkitemIds, String comments) {
        
        List<Approval.ProcessResult> result = new List<Approval.ProcessResult>();

        if(processInstanceWorkitemIds != null && !processInstanceWorkitemIds.isEmpty()) {
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

            for (String processInstanceWorkitemId : processInstanceWorkitemIds) {

                Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                

                request.setComments(comments);
                request.setAction(action);
                request.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
                request.setWorkitemId(processInstanceWorkitemId);
                
                requests.add(request);
            }
            
            result = Approval.process(requests);
            

        }

        return JSON.serialize(result);
    }
}