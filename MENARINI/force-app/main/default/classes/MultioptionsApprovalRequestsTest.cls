@IsTest
public with sharing class MultioptionsApprovalRequestsTest {
    @TestSetup
    public static void setup() {
        Account account = new Account(
                Name = 'TestAcctPharma',
                THR_CustomerIdentificationCode__c = 'TAP_0001',
                THR_AccountsKey__c = 'EXTTAPID_0001',
                THR_MAIL__c = 'TestAcctPharma@test.it',
                THR_VATNumber__c = 'VATTAP_0001',
                BillingStreet = 'Via test, 33',
                BillingPostalCode = '00Test01',
                BillingCity = 'Roma',
                BillingCountry = 'Italy',
                THR_Country__c = 'IT',
                THR_AccountGroup__c = 'Deposit',
                THR_DepositDevName__c = 'THR_EMA'
        );
        insert account;

        Contact contact = new Contact(
                FirstName = 'FirstName',
                LastName = 'LastName',
                AccountId = account.Id,
                Email = 'firstName.lastName@test.it',
                THR_Country__c = 'IT'
        );
        insert contact;

        List<Case> cases = new List<Case> {
            new Case(
                THR_Approval_Options__c = 'Emissione Nota di Credito',
                THR_RequestType__c = 'Theft',
                THR_DDTNumber__c = '76543',
                THR_DDTdate__c = System.today(),
                TH_Deposit__c = account.Id,
                THR_Type__c = 'Theft',
                THR_Client_Request_Date__c = System.today(),
                AccountId = account.Id,
                ContactId = contact.Id,
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('THR_ProductLoss').getRecordTypeId()
            ),
            new Case(
                    THR_RequestType__c = 'Theft',
                    THR_DDTNumber__c = '76543',
                    THR_DDTdate__c = System.today(),
                    TH_Deposit__c = account.Id,
                    THR_Type__c = 'Theft',
                    THR_Client_Request_Date__c = System.today(),
                    AccountId = account.Id,
                    ContactId = contact.Id,
                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('THR_ProductLoss').getRecordTypeId()
            )
        };
        insert cases;

        Approval.ProcessSubmitRequest processSubmitRequest1 = new Approval.ProcessSubmitRequest();
        processSubmitRequest1.setComments('Submitting request for approval.');
        processSubmitRequest1.setObjectId(cases[0].Id);
        processSubmitRequest1.setSubmitterId(UserInfo.getUserId());
        processSubmitRequest1.setProcessDefinitionNameOrId('THR_CaseReviewedApprovalProcess');
        processSubmitRequest1.setSkipEntryCriteria(true);
        Approval.process(processSubmitRequest1);

        Approval.ProcessSubmitRequest processSubmitRequest2 = new Approval.ProcessSubmitRequest();
        processSubmitRequest2.setComments('Submitting request for approval.');
        processSubmitRequest2.setObjectId(cases[1].Id);
        processSubmitRequest2.setSubmitterId(UserInfo.getUserId());
        processSubmitRequest2.setProcessDefinitionNameOrId('THR_CaseReviewedApprovalProcess');
        processSubmitRequest2.setSkipEntryCriteria(true);
        Approval.process(processSubmitRequest2);
    }

    @IsTest
    public static void getMultioptionsApprovalRequestsTest1() {
        List<String> processInstanceWorkitemIds = new List<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : [SELECT Id FROM ProcessInstanceWorkitem]) {
            processInstanceWorkitemIds.add(processInstanceWorkitem.Id);
        }

        Test.startTest();
        MultioptionsApprovalRequests.reassign(processInstanceWorkitemIds, UserInfo.getUserId());
        MultioptionsApprovalRequests.getMultioptionsApprovalRequests();
        MultioptionsApprovalRequests.getStandardApprovalRequests();
        MultioptionsApprovalRequests.approve(processInstanceWorkitemIds, 'Approve');
        Test.stopTest();
    }

    @IsTest
    public static void getMultioptionsApprovalRequestsTest2() {
        List<String> processInstanceWorkitemIds = new List<String>();
        for(ProcessInstanceWorkitem processInstanceWorkitem : [SELECT Id FROM ProcessInstanceWorkitem]) {
            processInstanceWorkitemIds.add(processInstanceWorkitem.Id);
        }

        Test.startTest();
        MultioptionsApprovalRequests.reassign(processInstanceWorkitemIds, UserInfo.getUserId());
        MultioptionsApprovalRequests.getMultioptionsApprovalRequests();
        MultioptionsApprovalRequests.getStandardApprovalRequests();
        MultioptionsApprovalRequests.reject(processInstanceWorkitemIds, 'Reject');
        Test.stopTest();
    }
}