@isTest
public class THR_VFEmailTemplateSpainControllerTest {
    
     @testSetup static void setup() {
         THR_TestDataFactory.AccountAndContactCreationSpaign();
         THR_TestDataFactory.ProductCreation();
    }
    
     static testMethod void test1(){
        THR_TestDataFactory.userCreation('System Administrator');
       	test.startTest();
         
             Account phAcc = [Select id, Name, AccountNumber, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                              THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet, TOLABEL(Account.BillingCountryCode),
                              TOLABEL(Account.BillingStateCode),BillingPostalCode,  BillingCity, BillingState, BillingCountry 
                              from Account where THR_AccountsKey__c ='EXTTAPIDSPA_0003' Limit 1 ];
           
             Account accDep = new Account();
             accDep.Name = 'TestAcctDeposit';
             accDep.THR_CustomerIdentificationCode__c='TADE_0001';
             accDep.THR_AccountsKey__c ='EXTTADIDE_0001';
             accDep.THR_AccountGroup__c='Deposit';
             accDep.THR_MAIL__c='TestAcctDeposit@test.it';
             accDep.THR_VATNumber__c='VATTADE_0001';
             accDep.BillingStreet='Via test, 33';
             accDep.BillingPostalCode='00Test01';
             accDep.BillingCity='Rome';
             accDep.BillingState='Roma';
             accDep.BillingStateCode='RM';
             accDep.BillingCountryCode ='IT';
             accDep.BillingCountry='Italy';
             accDep.THR_DepositEmail__c ='dep@test.it';
             accDep.THR_OtherDepositEmail__c ='test@test.it; Test2@test.it; test34@test.it; test54@test.com';
             accDep.THR_DepositDevName__c='THR_BOMI';
             insert accDep;  
             
             Contact cntctDep = new Contact (FirstName= 'NomeContattodDep', LastName='CognomeContattoDep', AccountId=accDep.id,Email='nomeContattoDep@test.it');
             insert cntctDep;
             
             Contact cntcPh = [Select name, Email, AccountId from Contact where AccountId =: phAcc.id Limit 1]; 
             Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
    
             Case phCase= THR_TestDataFactory.createSpanishCase('THR_Logistic_ES', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Laboratorios Retrain','ES',String.valueOf(accDep.Id));
             insert phCase;
             
             THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreationSpaign(phAcc.Id,pL.id,'Product', phCase.id); 
             List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
                  
             THR_VFEmailTemplateSpainController ccntrl = new THR_VFEmailTemplateSpainController();
             ccntrl.accBillingAddress = 'via test';
             ccntrl.caseRecordId = phCase.id;
             ccntrl.caseApproved = phCase;
             ccntrl.caseItemRelatedToCaseApproved = cItemProdList;
             ccntrl.contactMailingAddress = 'via test 300, roma italy';
             
             String contactMailingAdd = ccntrl.contactMailingAddress;
             String accBillingAdd = ccntrl.accBillingAddress;
             Case currCase = ccntrl.caseApproved;
             List<THR_Related_Object__c> currCaseItemList = ccntrl.caseItemRelatedToCaseApproved;
             
         
         test.stopTest();
     }
    
    
}