/**
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 14-03-2024
 * description        :  classe di test per REST_GetAccount
**/
@isTest
public without sharing class REST_GetAccount_Test {
     

    @isTest
    static void accountFound(){

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getAccount/';
        request.headers.put('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"key": "value"}');
        RestContext.request = request;
        RestContext.response = response;
        request.params.put('abi', '05387');
        request.params.put('ndg', '21159252');

        Account testAccount = new Account();
        testAccount.Name = 'RTUXASU IETUPIEB';
        testAccount.CRM_PEF_PDFBase64Split1__c ='111';
        testAccount.CRM_PEF_PDFBase64Split2__c='222';
        testAccount.CRM_PEF_PDFBase64Split3__c='333'; 
        testAccount.CRM_PEF_PDFBase64Split4__c='444'; 
        testAccount.NDW_ExternalId__c = '05387_21159252';
        insert testAccount;
        System.debug('testAccount' + testAccount);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpRestGetAccount());
        REST_GetAccount.getAccount();
        Test.stopTest();
    }

    @isTest
    static void accountNotFound(){

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getAccount/';
        request.headers.put('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"key": "value"}');
        RestContext.request = request;
        RestContext.response = response;
        request.params.put('abi', '05387');
        request.params.put('ndg', '21159253');

        Account testAccount = new Account();
        testAccount.Name = 'RTUXASU IETUPIEB';
        testAccount.CRM_PEF_PDFBase64Split1__c ='111';
        testAccount.CRM_PEF_PDFBase64Split2__c='222';
        testAccount.CRM_PEF_PDFBase64Split3__c='333'; 
        testAccount.CRM_PEF_PDFBase64Split4__c='444'; 
        testAccount.NDW_ExternalId__c = '05387_21159252';
        insert testAccount;
        System.debug('testAccount' + testAccount);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpRestGetAccount());
        REST_GetAccount.getAccount();
        Test.stopTest();
    }
}