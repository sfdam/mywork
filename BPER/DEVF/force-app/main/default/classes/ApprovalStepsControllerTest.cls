@isTest
public with sharing class ApprovalStepsControllerTest {
    public static final String NDGString = 'NDGTestClass_';
    public static final String USERNAME = 'sitbperbancaapproval@test.test';
    @testSetup 
    public static void setup() {
        Id filialeRTId = [SELECT Id from RecordType where DeveloperName = 'FilialeDiRelazione'][0].Id;
        Id personAccountRTId = [SELECT Id from RecordType where DeveloperName = 'PersonAccount'][0].Id;
        Id cointestazioneRTId = [SELECT Id from RecordType where DeveloperName = 'Cointestazione'][0].Id;
        Id assBackupRTId = [SELECT Id from RecordType where DeveloperName = 'Backup' AND SObjectType = 'Assignment__c'][0].Id;
        Id assPrincipaleRTId = [SELECT Id from RecordType where DeveloperName = 'Primario' AND SObjectType = 'Assignment__c'][0].Id;
        Id microportafoglioRTId = [SELECT Id from RecordType where DeveloperName = 'MicroWallet'][0].Id;
        Id profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema'][0].Id;
        User u = new User(Alias = 'standt', Email= USERNAME, 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profId, 
            TimeZoneSidKey='America/Los_Angeles', UserName=USERNAME);
        insert u;
        // User u1 = new User(Alias = 'standt1', Email= USERNAME + 'test', 
        //     EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        //     LocaleSidKey='en_US', ProfileId = profId, 
        //     TimeZoneSidKey='America/Los_Angeles', UserName=USERNAME + 'test');
        // insert u1;
        Account filialeTest1 = new Account(Name = 'Filiale Test 1', RecordTypeId = filialeRTId);
        insert filialeTest1;
        List<Contact> refList = new List<Contact>();
        for (Integer i = 0; i < 5; i++) refList.add(new Contact(LastName = 'Ref_'+i, PTF_RegistrationNumber__c = '00000'+i, AccountId = filialeTest1.Id));
        insert refList;
        List<Wallet__c> walletList = new List<Wallet__c>();
        walletList.add(new Wallet__c(Name = 'Wallet_1', PTF_ModelloDiServizio__c = 'Personal', PTF_Filiale__c = filialeTest1.Id, RecordTypeId = microportafoglioRTId));
        insert walletList;
        List<Assignment__c> assignments = new List<Assignment__c>();
        assignments.add(new Assignment__c(PTF_MicroWallet__c = walletList[0].Id, PTF_Gestore__c = refList[0].Id, RecordTypeId = assPrincipaleRTId));
        assignments.add(new Assignment__c(PTF_MicroWallet__c = walletList[0].Id, PTF_Gestore__c = refList[1].Id, RecordTypeId = assBackupRTId));
        insert assignments;
        List<Account> ndgList = new List<Account>();
        for (Integer i = 0; i < 10; i++) ndgList.add(new Account(LastName = NDGString+i, CRM_NDG__c = '000000'+i, RecordTypeId = personAccountRTId, PTF_Portafoglio__c = walletList[0].Id));
        ndgList.add(new Account(LastName = 'NoWallet_'+NDGString, CRM_NDG__c = '100000', RecordTypeId = personAccountRTId));
        Account coint = new Account(Name = 'NDGCoint', CRM_NDG__c = '200000', RecordTypeId = cointestazioneRTId);
        insert ndgList;
        insert coint;
        CRM_LinkedNDG__c linkedNDG = new CRM_LinkedNDG__c (CRM_Account__c = ndgList[0].Id, CRM_RelatedAccount__c = coint.Id, CRM_LinkCode__c = '0', CRM_LinkType__c = 'Test', CRM_Status__c = 'A');
        insert linkedNDG;
        CRM_Channel__c chan = new CRM_Channel__c(Name = 'Test', CRM_Account__c = ndgList[0].Id);
        insert chan;
        WorkOrder wo = new WorkOrder(Subject = 'WO1', Status = 'Pending');
        insert wo;
        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = wo.Id);
        insert woli;
        WorkOrderLineItem woli2 = new WorkOrderLineItem(WorkOrderId = wo.Id);
        insert woli2;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(wo.Id);
        req1.setProcessDefinitionNameOrId('IterSpostamento3');
        req1.setSkipEntryCriteria(true);
        req1.setNextApproverIds(new Id[] {u.Id});
        Approval.ProcessResult result = Approval.process(req1);

    }

    @isTest
    public static void testing() {
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE Subject = 'WO1'][0];
		ProcessInstanceWorkitem[] workItems = [ SELECT Id
                                               FROM ProcessInstanceWorkitem 
                                               WHERE ProcessInstance.TargetObjectId =:wo.Id];
        // ProcessInstanceStep procInstStep = new ProcessInstanceStep();
        // procInstStep.ProcessInstanceId = workItems[0].Id;
        // insert procInstStep;

        System.debug('TEST workItems --> ' + workItems);
        ApprovalStepsController.getAllData((workItems[0].Id));
        ApprovalStepsController.testRun();
    }
}