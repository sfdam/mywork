/*Author : alessandro di nardo @ten 
class test : ART_MassiveApproveController */
@IsTest
public with sharing class ART_MassiveApproveController_Test {
    @TestSetup
    public static void setup() {

        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c();
        insert orderTemplate;

        cgcloud__Order_Template__c orderTemplateOTC = new cgcloud__Order_Template__c
        (
            Name = 'Ordine Diretto OTC'
        );
        insert orderTemplateOTC;

        Account payer = new Account
        (
            Name = 'payer',
            ART_PaymentCondition_OTC__c = 'RIMESSA DIRETTA 90 GG.',
            BillingCountry = 'Italy',
            BillingState = 'Milano',
            BillingStreet = 'VIALE LOMBARDIA 8'
        );
        insert payer;

        List<cgcloud__Order__c> orders = new List<cgcloud__Order__c>();
        
        orders.add(
        new cgcloud__Order__c(
        	cgcloud__Phase__c = 'Initial',
        	//cgcloud__Phase__c = 'ForApproval',
            cgcloud__Mobility_Release__c = True,
            cgcloud__Order_Template__c = orderTemplateOTC.Id,
            ART_Delay_days__c = '90',
            cgcloud__Payer__c = payer.Id,
            ART_Payment_Code__c = 'test',
            cgcloud__Value__c = 3400
        ));
        insert orders;

        cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c(
        cgcloud__Order__c = orders[0].Id,
        cgcloud__Quantity__c = 20,
        cgcloud__Discount__c = 0
        );
        insert orderItem;
        
        List<cgcloud__Order__c> listaOrder = [SELECT Id,cgcloud__Phase__c FROM cgcloud__Order__c LIMIT 1];
        Approval.ProcessSubmitRequest processSubmitRequest1 = new Approval.ProcessSubmitRequest();
        processSubmitRequest1.setComments('Submitting request for approval.');
        processSubmitRequest1.setObjectId(listaOrder[0].Id);
        processSubmitRequest1.setSubmitterId(UserInfo.getUserId());
        processSubmitRequest1.setProcessDefinitionNameOrId('ART_Adv_Order_value_approval');
        //processSubmitRequest1.setSkipEntryCriteria(true);

        Approval.ProcessResult result = Approval.process(processSubmitRequest1);
        //System.debug('AD Approval.ProcessResult : ' + result);
    }

    @IsTest
    public static void getMultioptionsApprovalRequestsApporveTest() {

        List<String> processInstanceWorkitemIds = new List<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : [SELECT Id FROM ProcessInstanceWorkitem]) {
            processInstanceWorkitemIds.add(processInstanceWorkitem.Id);
        }
        
        System.debug('AD processInstanceWorkitemIds : ' + processInstanceWorkitemIds);
       
        Test.startTest();
        
        ART_MassiveApproveController.getMultioptionsApprovalRequests();
        
        ART_MassiveApproveController.approve(processInstanceWorkitemIds, 'Approve');

        Test.stopTest();
    }

    @IsTest
    public static void getMultioptionsApprovalRequestsRejectTest() {

        
        List<String> processInstanceWorkitemIds = new List<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : [SELECT Id FROM ProcessInstanceWorkitem]) {
            processInstanceWorkitemIds.add(processInstanceWorkitem.Id);
        }
        
        System.debug('AD processInstanceWorkitemIds : ' + processInstanceWorkitemIds);
       
        Test.startTest();
        
        ART_MassiveApproveController.getMultioptionsApprovalRequests();
        
        ART_MassiveApproveController.reject(processInstanceWorkitemIds, 'Reject');

        Test.stopTest();
    }

}