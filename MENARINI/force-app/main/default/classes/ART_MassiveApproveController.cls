/*Author : alessandro di nardo @ten 04-10-2023
  Description : prelevo ordini da approvare o scartare in base alla loro fase 'forApproval'

*/
public with sharing class ART_MassiveApproveController {

    public class ApprovalRequests {
        @AuraEnabled public List<cgcloud__Order__c> orders {get; set;}//AD
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

    //AD prelevo ordini e il loro processo
    private static ApprovalRequests getApprovalRequests(Boolean multiOptions) {
        ApprovalRequests approvalRequests = new ApprovalRequests();
        approvalRequests.orders = new List<cgcloud__Order__c>();//AD 
        approvalRequests.processInstanceWorkitems = new List<ProcessInstanceWorkitem>();

        List<ProcessInstanceWorkitem> processInstanceWorkitems = new List<ProcessInstanceWorkitem>();
        Set<String> targetObjectIds = new Set<String>();

        Set<Id> setIdOrder = new Set<Id>();
        
        for(cgcloud__Order__c order : [SELECT Id, Name, Owner.Name,ID18__c, ART_Dilazione_da_approvare__c, ART_Order_Type__c, CreatedBy.Name,
                             cgcloud__Payer__r.ART_PaymentCondition_Farma__c,
                             cgcloud__Payer__r.ART_PaymentCondition_Derma__c,
                             cgcloud__Payer__r.ART_PaymentCondition_OTC__c,
                             cgcloud__Order_Template__c,
                             cgcloud__Order_Template__r.Name,
                             cgcloud__Order_Account__c,
                             cgcloud__Order_Account__r.Name,
                             cgcloud__Order_Account__r.ART_Rural__c,
                             cgcloud__Order_Account__r.THR_AccountGroup__c,
                             cgcloud__Order_Account__r.THR_CustomerSubcategory__c,
                             ART_Customer_identification_code__c,
                             cgcloud__Order_Account__r.ART_Customer_SubCategory_Description__c,
                             cgcloud__Phase__c,
                             cgcloud__Gross_Total_Value__c,
                             cgcloud__Value__c,
                             cgcloud__Order_Date__c,
                             cgcloud__Delivery_Date__c,
                             cgcloud__Order_Id__c,
                             ART_CIG_Code__c,
                             ART_OrderItemRowsCount__c,
                             ART_Class_C__c,
                             cgcloud__Customer_Order_Id__c,
                             cgcloud__Delivery_Recipient__r.Name,
                             cgcloud__Payer__r.Name,
                             cgcloud__Payer__r.THR_CUU__c,
                             ART_Order_send_block__c,
                             ART_Delay_days__c,
                             cgcloud__Wholesaler__c,
                             cgcloud__Wholesaler__r.Name,
                             cgcloud__Invoice_Note__c,
                             cgcloud__Delivery_Note__c,
                             ART_Payment_Code__c,
                             Delivery_Recipient_Provincia__c,
                             cgcloud__Order_Account__r.THR_CustomerIdentificationCode__c,
                             cgcloud__Payer__r.THR_CustomerIdentificationCode__c,
                             cgcloud__Wholesaler__r.THR_CustomerIdentificationCode__c,
                             cgcloud__Delivery_Recipient__r.THR_CustomerIdentificationCode__c FROM cgcloud__Order__c WHERE  cgcloud__Phase__c = 'ForApproval']){
            setIdOrder.add(order.id);
            approvalRequests.orders.add(order);
        }
        //[SELECT ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.type, ProcessInstance.SubmittedById, ProcessInstance.SubmittedBy.Name, ProcessInstance.CreatedDate, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :setIdOrder AND ProcessInstance.Status = 'Pending' ]
        
        
        for(ProcessInstanceWorkitem processInstanceWorkitem : [SELECT ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.type, ProcessInstance.SubmittedById, ProcessInstance.SubmittedBy.Name, ProcessInstance.CreatedDate, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :setIdOrder AND ProcessInstance.Status = 'Pending' ] ) {
            processInstanceWorkitems.add(processInstanceWorkitem);
            targetObjectIds.add(processInstanceWorkitem.ProcessInstance.TargetObjectId);
        }
        

        System.debug('AD check processInstanceWorkitems : ' + processInstanceWorkitems);
        System.debug('AD check targetObjectIds : ' + targetObjectIds);


        Set<String> processInstanceIds = new Set<String>();
        Set<String> SubmittedByIds = new Set<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : processInstanceWorkitems) {
            if(setIdOrder.contains(processInstanceWorkitem.ProcessInstance.TargetObjectId)) {
                approvalRequests.processInstanceWorkitems.add(processInstanceWorkitem);
                processInstanceIds.add(processInstanceWorkitem.ProcessInstanceId);
                SubmittedByIds.add(processInstanceWorkitem.ProcessInstance.SubmittedById);
            }
        }

        approvalRequests.processInstanceSteps = [SELECT Id, ProcessInstanceId, ActorId, Comments FROM ProcessInstanceStep WHERE ProcessInstanceId IN :processInstanceIds AND ActorId IN :SubmittedByIds];
        
        System.debug('AD approvalRequests : ' + approvalRequests);

        return approvalRequests;
    }
    
    private static String approvalProcess(String action, List<String> processInstanceWorkitemIds, String comments) {
        
        List<Approval.ProcessResult> result = new List<Approval.ProcessResult>();

        if(processInstanceWorkitemIds != null && !processInstanceWorkitemIds.isEmpty()) {
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

            for (String processInstanceWorkitemId : processInstanceWorkitemIds) {

                Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                //System.debug('AD approvalProcess requests.setComments : ' + comments);
                //System.debug('AD approvalProcess requests.setAction : ' + action);
                //System.debug('AD approvalProcess requests.setNextApproverIds : ' + new List<Id>{UserInfo.getUserId()});
                //System.debug('AD approvalProcess requests.setWorkitemId : ' + processInstanceWorkitemId);

                request.setComments(comments);
                request.setAction(action);
                request.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
                request.setWorkitemId(processInstanceWorkitemId);
                //System.debug('AD approvalProcess requests.add : ' + request);
                requests.add(request);
            }
            //System.debug('AD approvalProcess requests : ' + requests);
            result = Approval.process(requests);
            //System.debug('AD approvalProcess result : ' + result);

        }

        return JSON.serialize(result);
    }
}