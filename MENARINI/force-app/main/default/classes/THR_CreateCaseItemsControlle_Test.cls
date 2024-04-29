/**
 * @description       : 
 * @author            : simone.viglianti@accenture.com
 * @group             : 
 * @last modified on  : 10-05-2020
 * @last modified by  : eleonora.caravello@accenture.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   08-26-2020   simone.viglianti@accenture.com   Initial Version
 * 1.1   10-05-2020   simone.viglianti@accenture.com   Initial Version
**/
@isTest
public class THR_CreateCaseItemsControlle_Test {
    @TestSetup
    static void setup() {
     
     THR_TestDataFactory.documentCreation();
     
     THR_TestDataFactory.AccountAndContactCreation();
     
     THR_TestDataFactory.ProductCreation();
     
     
    }
    
     @isTest
    public static void createItemTest(){
        List<THR_InvoiceItem__c> invItemList =  new List<THR_InvoiceItem__c>();
        List<THR_InvoiceItem__c> invItemList2 =  new List<THR_InvoiceItem__c>();
	 	Date currentDDTDate = Date.newInstance(2020, 07, 21);
	 	String currentDDTNumber = '1234455566';
        
        Account phAcc = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctPharma' Limit 1 ];
        
       Account dep = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctDeposit' Limit 1 ];
        
       Contact cntcPh = [Select name, Email, AccountId from Contact where AccountId =: phAcc.id Limit 1]; 
        
       List<Product2> currProd = [select id,isActive, Name, ProductCode from Product2 LIMIT 2];
        
	   Product2 PROD1 = currProd[0];    	
	   Product2 PROD2 = currProd[1];    	
        
       Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Pharma',String.valueOf(dep.Id),'Return Request','HQ error');
       insert phCase;
       THR_Related_Object__c cItem=  THR_TestDataFactory.caseItemCreation(PROD1.id, 'Product', phCase.id);
       THR_Related_Object__c cItem2=  THR_TestDataFactory.caseItemCreation(PROD2.id, 'Product', phCase.id);
        
       THR_Invoice__c inv = new THR_Invoice__c();
       inv.THR_AccountingDocumentFI__c ='Test';
       inv.THR_AccountingDocumentDate__c =Date.newInstance(2020, 06, 25); 
       inv.THR_ArchiflowKey__c ='AchiFlow0770808';
       inv.THR_Country__c ='IT';
       inv.THR_Date__c = Date.newInstance(2020, 07, 21);
       inv.THR_Currency__c ='€'; 
       inv.THR_Discount__c ='10'; 
       inv.THR_Division__c = 'CI';//'Chemical';
       inv.THR_DocumentNumberSD__c ='332'; 
       inv.THR_DueDateInvoice__c =Date.newInstance(2020, 06, 25);
       inv.THR_EndCustomer__c =phAcc.id; 
       inv.THR_GrossValue__c =10; 
       inv.THR_InvoiceBalance__c =10; 
       inv.THR_InvoiceExpiryDate__c =Date.newInstance(2050, 11, 25); 
       inv.THR_InvoiceKey__c ='INVkEY0786876876'; 
       inv.THR_InvoiceKNumber__c ='INV0786876876'; 
       inv.THR_InvoiceType__c ='Debit Memo'; 
       inv.THR_LastReminder__c ='10'; 
       inv.THR_LastReminderDate__c =Date.newInstance(2050, 11, 15); 
       inv.THR_OrderDatePODate__c =Date.newInstance(2020, 06, 25);
       inv.THR_Payer__c =phAcc.id; 
       inv.THR_SalesOrganization__c =''; 
       inv.THR_SendTo__c =phAcc.id; 
       inv.THR_ShipperCode__c ='00100'; 
       inv.THR_ShippingCondition__c ='PH: SC production'; 
       inv.THR_ShippingConditionDescription__c ='bla bla bla'; 
       inv.THR_TermsOfPaymentKey__c ='CONTRASSEGNO'; 
       inv.THR_YearofInvoice__c ='2020'; 
        
       insert inv;
        
       THR_InvoiceItem__c invItem = new THR_InvoiceItem__c();
       invItem.THR_BatchNumber__c ='LottoTest_0998008';
       invItem.THR_CommImpCodeNo__c ='17021100';
       invItem.THR_InvoiceItem_Country__c = 'IT';
       invItem.THR_DateDDT__c = Date.newInstance(2020, 07, 21);
       invItem.THR_DDT__c ='DDT_00001';
       invItem.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
       invItem.THR_InvoiceItemKey__c = '0000001';
       invItem.THR_ItemNumber__c = 10;
       invItem.THR_NetValue__c = 76;
       invItem.THR_Quantity__c = 63;
       invItem.THR_ShipperCode__c ='00100'; 
       invItem.THR_ShippingType__c = 'none';
       invItem.THR_InvoiceNumber__c = inv.Id;
       invItem.THR_MaterialID__c =PROD1.Id; 
       insert invItem;
        
       invItemList.add(invItem);
        
       system.debug('@@@@invItemList is '+invItemList);
       test.startTest();
        	THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList, currentDDTNumber, currentDDTDate);
       
        
        
       THR_InvoiceItem__c invItem2 = new THR_InvoiceItem__c();
       invItem2.THR_BatchNumber__c ='LottoTest_0998008';
       invItem2.THR_CommImpCodeNo__c ='17021100';
       invItem2.THR_InvoiceItem_Country__c = 'IT';
       invItem2.THR_DateDDT__c = Date.newInstance(2020, 07, 21);
       invItem2.THR_DDT__c ='DDT_00001';
       invItem2.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
       invItem2.THR_InvoiceItemKey__c = '0000002';
       invItem2.THR_ItemNumber__c = 10;
       invItem2.THR_NetValue__c = 79;
       invItem2.THR_Quantity__c = 63;
       invItem2.THR_ShipperCode__c ='00100'; 
       invItem2.THR_ShippingType__c = 'none';
       invItem2.THR_InvoiceNumber__c = inv.Id;
       invItem2.THR_MaterialID__c =PROD2.Id; 
       insert invItem2;
        
       invItemList.add(invItem2);
        system.debug('@@@@invItemList2 is '+invItemList);
        
        THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList, currentDDTNumber, currentDDTDate);
        
        Product2 PROD3 = new Product2();
        PROD3.IsActive = true;
        PROD3.Name ='ProdTestName000A';
        PROD3.ProductCode ='CodProd000A';
        PROD3.THR_MaterialKey__c='MK_PT0003';
        insert PROD3;
        
       THR_InvoiceItem__c invItem3 = new THR_InvoiceItem__c();
       invItem3.THR_BatchNumber__c ='LottoTest_09980082';
       invItem3.THR_CommImpCodeNo__c ='170211002';
       invItem3.THR_InvoiceItem_Country__c = 'IT';
       invItem3.THR_DateDDT__c = Date.newInstance(2020, 07, 21);
       invItem3.THR_DDT__c ='DDT_00001';
       invItem3.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
       invItem3.THR_InvoiceItemKey__c = '0000003';
       invItem3.THR_ItemNumber__c = 10;
       invItem3.THR_NetValue__c = 79;
       invItem3.THR_Quantity__c = 63;
       invItem3.THR_ShipperCode__c ='00100'; 
       invItem3.THR_ShippingType__c = 'none';
       invItem3.THR_InvoiceNumber__c = inv.Id;
       invItem3.THR_MaterialID__c =PROD3.Id; 
       insert invItem3;
        
        invItemList2.add(invItem3);
        system.debug('@@@@invItemList3 is '+invItemList2);
        
        THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList2, currentDDTNumber, currentDDTDate);
        
       test.stopTest();
      
    }
    
     @isTest
    public static void BeforeDeleteCaseItemNegative_Test(){
        List<THR_InvoiceItem__c> invItemList =  new List<THR_InvoiceItem__c>();
        List<THR_InvoiceItem__c> invItemList2 =  new List<THR_InvoiceItem__c>();
	 	Date currentDDTDate = Date.newInstance(2020, 07, 21);
	 	String currentDDTNumber = '1234455566';
        
        Account phAcc = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctPharma' Limit 1 ];
        
       Account dep = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctDeposit' Limit 1 ];
        
       Contact cntcPh = [Select name, Email, AccountId from Contact where AccountId =: phAcc.id Limit 1]; 
        
       List<Product2> currProd = [select id,isActive, Name, ProductCode from Product2 LIMIT 2];
        
	   Product2 PROD1 = currProd[0];    	
	   Product2 PROD2 = currProd[1];    	
        
       Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Pharma',String.valueOf(dep.Id),'Return Request','HQ error');
      
       insert phCase;
       THR_Related_Object__c cItem=  THR_TestDataFactory.caseItemCreation(PROD1.id, 'Product', phCase.id);
       THR_Related_Object__c cItem2=  THR_TestDataFactory.caseItemCreation(PROD2.id, 'Product', phCase.id);
        
       THR_Invoice__c inv = new THR_Invoice__c();
       inv.THR_AccountingDocumentFI__c ='Test';
       inv.THR_AccountingDocumentDate__c =Date.newInstance(2020, 06, 25); 
       inv.THR_ArchiflowKey__c ='AchiFlow0770808';
       inv.THR_Country__c ='IT';
       inv.THR_Date__c = Date.newInstance(2020, 07, 21);
       inv.THR_Currency__c ='€'; 
       inv.THR_Discount__c ='10'; 
       inv.THR_Division__c = 'CI';//'Chemical';
       inv.THR_DocumentNumberSD__c ='332'; 
       inv.THR_DueDateInvoice__c =Date.newInstance(2020, 06, 25);
       inv.THR_EndCustomer__c =phAcc.id; 
       inv.THR_GrossValue__c =10; 
       inv.THR_InvoiceBalance__c =10; 
       inv.THR_InvoiceExpiryDate__c =Date.newInstance(2050, 11, 25); 
       inv.THR_InvoiceKey__c ='INVkEY0786876876'; 
       inv.THR_InvoiceKNumber__c ='INV0786876876'; 
       inv.THR_InvoiceType__c ='Debit Memo'; 
       inv.THR_LastReminder__c ='10'; 
       inv.THR_LastReminderDate__c =Date.newInstance(2050, 11, 15); 
       inv.THR_OrderDatePODate__c =Date.newInstance(2020, 06, 25);
       inv.THR_Payer__c =phAcc.id; 
       inv.THR_SalesOrganization__c =''; 
       inv.THR_SendTo__c =phAcc.id; 
       inv.THR_ShipperCode__c ='00100'; 
       inv.THR_ShippingCondition__c ='PH: SC production'; 
       inv.THR_ShippingConditionDescription__c ='bla bla bla'; 
       inv.THR_TermsOfPaymentKey__c ='CONTRASSEGNO'; 
       inv.THR_YearofInvoice__c ='2020'; 
        
       insert inv;
        
       THR_InvoiceItem__c invItem = new THR_InvoiceItem__c();
       invItem.THR_BatchNumber__c ='LottoTest_0998008';
       invItem.THR_CommImpCodeNo__c ='17021100';
       invItem.THR_InvoiceItem_Country__c = 'IT';
       invItem.THR_DateDDT__c = Date.newInstance(2020, 07, 21);
       invItem.THR_DDT__c ='DDT_00001';
       invItem.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
       invItem.THR_InvoiceItemKey__c = '0000001';
       invItem.THR_ItemNumber__c = 10;
       invItem.THR_NetValue__c = 76;
       invItem.THR_Quantity__c = 63;
       invItem.THR_ShipperCode__c ='00100'; 
       invItem.THR_ShippingType__c = 'none';
       invItem.THR_InvoiceNumber__c = inv.Id;
       invItem.THR_MaterialID__c =PROD1.Id; 
       insert invItem;
        
       invItemList.add(invItem);
        
       system.debug('@@@@invItemList is '+invItemList);
       test.startTest();
       THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList, currentDDTNumber, currentDDTDate);
       
        
        
       THR_InvoiceItem__c invItem2 = new THR_InvoiceItem__c();
       invItem2.THR_BatchNumber__c ='LottoTest_0998008';
       invItem2.THR_CommImpCodeNo__c ='17021100';
       invItem2.THR_InvoiceItem_Country__c = 'IT';
       invItem2.THR_DateDDT__c = Date.newInstance(2020, 07, 21);
       invItem2.THR_DDT__c ='DDT_00001';
       invItem2.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
       invItem2.THR_InvoiceItemKey__c = '0000002';
       invItem2.THR_ItemNumber__c = 10;
       invItem2.THR_NetValue__c = 79;
       invItem2.THR_Quantity__c = 63;
       invItem2.THR_ShipperCode__c ='00100'; 
       invItem2.THR_ShippingType__c = 'none';
       invItem2.THR_InvoiceNumber__c = inv.Id;
       invItem2.THR_MaterialID__c =PROD2.Id; 
       insert invItem2;
        
       invItemList.add(invItem2);
        system.debug('@@@@invItemList2 is '+invItemList);
        
        THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList, currentDDTNumber, currentDDTDate);
        
        Product2 PROD3 = new Product2();
        PROD3.IsActive = true;
        PROD3.Name ='ProdTestName000A';
        PROD3.ProductCode ='CodProd000A';
        PROD3.THR_MaterialKey__c='MK_PT0003';
        insert PROD3;
        
       THR_InvoiceItem__c invItem3 = new THR_InvoiceItem__c();
       invItem3.THR_BatchNumber__c ='LottoTest_09980082';
       invItem3.THR_CommImpCodeNo__c ='170211002';
       invItem3.THR_InvoiceItem_Country__c = 'IT';
       invItem3.THR_DateDDT__c = Date.newInstance(2020, 07, 21);
       invItem3.THR_DDT__c ='DDT_00001';
       invItem3.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
       invItem3.THR_InvoiceItemKey__c = '0000003';
       invItem3.THR_ItemNumber__c = 10;
       invItem3.THR_NetValue__c = 79;
       invItem3.THR_Quantity__c = 63;
       invItem3.THR_ShipperCode__c ='00100'; 
       invItem3.THR_ShippingType__c = 'none';
       invItem3.THR_InvoiceNumber__c = inv.Id;
       invItem3.THR_MaterialID__c =PROD3.Id; 
       insert invItem3;
        
        invItemList2.add(invItem3);
        system.debug('@@@@invItemList3 is '+invItemList2);
        
        THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList2, currentDDTNumber, currentDDTDate);
        
        phCase.status ='Cancelled';
        update phCase;
        
        List<THR_Related_Object__c> caseItemToDelete = [Select id,THR_Case_Related__r.Status, THR_Case_Related__c from THR_Related_Object__c where THR_Case_Related__c=: phCase.Id];
        try{
        delete caseItemToDelete;    
        }catch(Exception e){}
        test.stopTest();
      
    }
    
    @isTest
    public static void testSearchInvoice(){
        
        
        THR_TestDataFactory.userCreation('System Administrator');
       	test.startTest();
        Account phAcc = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctPharma' Limit 1 ];
        
        Account dep = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctDeposit' Limit 1 ];
        
        Contact cntcPh = [Select name, Email, AccountId from Contact where AccountId =: phAcc.id Limit 1]; 
        //Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
        //RT, Acc.id, cntc.id,commDiv,depId, type
        
        Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Pharma',String.valueOf(dep.Id),'Return Request','HQ error');
        insert phCase;
        
        THR_CreateCaseItemsController.searchInvoice(phCase.THR_DDTdate__c, phCase.THR_DDTNumber__c, phCase.Id, phCase.THR_Country__c, phCase.AccountId);
        THR_CreateCaseItemsController.searchInvoice(phCase.THR_DDTdate__c, phCase.THR_DDTNumber__c, phCase.Id, phCase.THR_Country__c, null);
    }
    
    @isTest
    public static void testSearchInvoiceCreateCaseItem(){
        THR_TestDataFactory.userCreation('System Administrator');
        test.startTest();
        Account phAcc = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctPharma' Limit 1 ];
        
        Account dep = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctDeposit' Limit 1 ];
        
        Contact cntcPh = [Select name, Email, AccountId from Contact where AccountId =: phAcc.id Limit 1]; 
        Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
        //RT, Acc.id, cntc.id,commDiv,depId, type
        
         User CsUser = THR_TestDataFactory.userCreation('Customer Service User');
         
        Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Pharma',String.valueOf(dep.Id),'Return Request','HQ error');
        insert phCase;
         //caseItemCreation(String ProdIdSt,String TypeRelObj, String CaseIdSt){
        
         Id pricebookId = Test.getStandardPricebookId();
        
        THR_Related_Object__c cItem=  THR_TestDataFactory.caseItemCreation(pL.id, 'Product', phCase.id);
      /*  
           Order ord = new Order();
         ord.THR_AGAccountholder__c = phAcc.id;
         ord.THR_Carrier__c = dep.id;
         ord.BillToContactId = cntcPh.id;
       //  ord.THR_ArchiFlowKey__c ='AchiFlow0770808';
        // ord.CompanyAuthorizedById = CsUser.id;
        // ord.CompanyAuthorizedDate = Date.newInstance(2020, 04, 22);
        // ord.THR_CompleteDelivery__c =false;
       //  ord.THR_ConditionGroup__c ='Classe C';
         ord.EffectiveDate  = Date.newInstance(2020, 06, 25);
         ord.Status ='Draft';
         //ord.THR_OrderKey__c ='OrdKey_0001';
         //ord.THR_CustomerGroup1__c = 'CODIFI Direct Sales' ;
         insert ord;
        */
        THR_Invoice__c inv = new THR_Invoice__c();
         
        inv.THR_AccountingDocumentFI__c ='Test';
        inv.THR_AccountingDocumentDate__c =Date.newInstance(2020, 06, 25); 
        inv.THR_ArchiflowKey__c ='AchiFlow0770808';
        inv.THR_Country__c ='IT';
        inv.THR_Date__c = Date.newInstance(2020, 06, 25);
        inv.THR_Currency__c ='€'; 
        inv.THR_Discount__c ='10'; 
        inv.THR_Division__c = 'CI';// 'Chemical';
        inv.THR_DocumentNumberSD__c ='332'; 
        inv.THR_DueDateInvoice__c =Date.newInstance(2020, 06, 25);
        inv.THR_EndCustomer__c =phAcc.id; 
        inv.THR_GrossValue__c =10; 
        inv.THR_InvoiceBalance__c =10; 
        inv.THR_InvoiceExpiryDate__c =Date.newInstance(2050, 11, 25); 
        inv.THR_InvoiceKey__c ='INVkEY0786876876'; 
        inv.THR_InvoiceKNumber__c ='INV0786876876'; 
        inv.THR_InvoiceType__c ='Debit Memo'; 
        inv.THR_LastReminder__c ='10'; 
        inv.THR_LastReminderDate__c =Date.newInstance(2050, 11, 15); 
        inv.THR_OrderDatePODate__c =Date.newInstance(2020, 06, 25);
        //       inv.THR_OrderNumber__c = ord.id; 
        inv.THR_Payer__c =phAcc.id; 
        inv.THR_SalesOrganization__c =''; 
        inv.THR_SendTo__c =phAcc.id; 
        inv.THR_ShipperCode__c ='00100'; 
        inv.THR_ShippingCondition__c ='PH: SC production'; 
        inv.THR_ShippingConditionDescription__c ='bla bla bla'; 
        inv.THR_TermsOfPaymentKey__c ='CONTRASSEGNO'; 
        inv.THR_YearofInvoice__c ='2020'; 
        
        insert inv;
         
        THR_InvoiceItem__c invItem = new THR_InvoiceItem__c();
        invItem.THR_BatchNumber__c ='LottoTest_0998008';
        invItem.THR_CommImpCodeNo__c ='17021100';
        invItem.THR_InvoiceItem_Country__c = 'IT';
        invItem.THR_DateDDT__c = Date.newInstance(2020, 06, 30);
        invItem.THR_DDT__c ='DDT_00001';
        invItem.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
        invItem.THR_InvoiceItemKey__c = '0000001';
        invItem.THR_ItemNumber__c = 10;
        invItem.THR_NetValue__c = 76;
        invItem.THR_Quantity__c = 63;
        invItem.THR_ShipperCode__c ='00100'; 
        invItem.THR_ShippingType__c = 'none';
        invItem.THR_InvoiceNumber__c = inv.id;
        invItem.THR_MaterialID__c =pL.Id; 
        insert invItem;
         //componente nel page
         List<THR_InvoiceItem__c> invItemList =  new List<THR_InvoiceItem__c>{invItem};
            
     //   List<THR_InvoiceItem__c> cItemList = new List<THR_InvoiceItem__c>{cItem};
        THR_CreateCaseItemsController.searchInvoice(phCase.THR_DDTdate__c, phCase.THR_DDTNumber__c, phCase.Id, phCase.THR_Country__c, phCase.AccountId);
        THR_CreateCaseItemsController.searchInvoice(phCase.THR_DDTdate__c, phCase.THR_DDTNumber__c, phCase.Id, phCase.THR_Country__c, null);
        THR_CreateCaseItemsController.searchInvoice(invItem.THR_DateDDT__c, invItem.THR_DDT__c, phCase.Id, invItem.THR_InvoiceItem_Country__c, phCase.AccountId);
        THR_CreateCaseItemsController.searchInvoice(invItem.THR_DateDDT__c, invItem.THR_DDT__c, phCase.Id, invItem.THR_InvoiceItem_Country__c, null);
        
    }
    
    @isTest
    public static void testOtherMethods(){
        
       THR_TestDataFactory.userCreation('System Administrator');
       test.startTest();
        Account phAcc = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctPharma' Limit 1 ];
        
        Account dep = [Select id, Name, THR_CustomerIdentificationCode__c, THR_AccountsKey__c, 
                     THR_AccountGroup__c, THR_MAIL__c, THR_VATNumber__c, BillingStreet,
                     BillingPostalCode,  BillingCity, BillingState, BillingCountry from Account where Name ='TestAcctDeposit' Limit 1 ];
        
        Contact cntcPh = [Select name, Email, AccountId from Contact where AccountId =: phAcc.id Limit 1]; 
        List<Product2> prodInsertedLIst = [select id,isActive, Name, ProductCode from Product2 Limit 2];
        Product2 pL = prodInsertedLIst[0];
        Product2 pL2 = prodInsertedLIst[1];
        
        //RT, Acc.id, cntc.id,commDiv,depId, type
        
         User CsUser = THR_TestDataFactory.userCreation('Customer Service User');
         
        Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Pharma',String.valueOf(dep.Id),'Return Request','HQ error');
        insert phCase;
         //caseItemCreation(String ProdIdSt,String TypeRelObj, String CaseIdSt){
        THR_Related_Object__c cItem=  THR_TestDataFactory.caseItemCreation(pL.id, 'Product', phCase.id);
       /* 
          Order ord = new Order();
         ord.THR_AGAccountholder__c = phAcc.id;
         ord.THR_Carrier__c = dep.id;
         ord.BillToContactId = cntcPh.id;
       //  ord.THR_ArchiFlowKey__c ='AchiFlow0770808';
        // ord.CompanyAuthorizedById = CsUser.id;
        // ord.CompanyAuthorizedDate = Date.newInstance(2020, 04, 22);
        // ord.THR_CompleteDelivery__c =false;
       //  ord.THR_ConditionGroup__c ='Classe C';
         ord.EffectiveDate  = Date.newInstance(2020, 06, 25);
         ord.Status ='Draft';
         //ord.THR_OrderKey__c ='OrdKey_0001';
         //ord.THR_CustomerGroup1__c = 'CODIFI Direct Sales' ;
         insert ord;
         */
        THR_Invoice__c inv = new THR_Invoice__c();
         
        inv.THR_AccountingDocumentFI__c ='Test';
        inv.THR_AccountingDocumentDate__c =Date.newInstance(2020, 06, 25); 
        inv.THR_ArchiflowKey__c ='AchiFlow0770808';
        inv.THR_Country__c ='IT';
        inv.THR_Date__c = Date.newInstance(2020, 06, 25);
        inv.THR_Currency__c ='€'; 
        inv.THR_Discount__c ='10'; 
        inv.THR_Division__c = 'CI';//'Chemical';
        inv.THR_DocumentNumberSD__c ='332'; 
        inv.THR_DueDateInvoice__c =Date.newInstance(2020, 06, 25);
        inv.THR_EndCustomer__c =phAcc.id; 
        inv.THR_GrossValue__c =10; 
        inv.THR_InvoiceBalance__c =10; 
        inv.THR_InvoiceExpiryDate__c =Date.newInstance(2050, 11, 25); 
        inv.THR_InvoiceKey__c ='INVkEY0786876876'; 
        inv.THR_InvoiceKNumber__c ='INV0786876876'; 
        inv.THR_InvoiceType__c ='Debit Memo'; 
        inv.THR_LastReminder__c ='10'; 
        inv.THR_LastReminderDate__c =Date.newInstance(2050, 11, 15); 
        inv.THR_OrderDatePODate__c =Date.newInstance(2020, 06, 25);
        //   inv.THR_OrderNumber__c = ord.id; 
        inv.THR_Payer__c =phAcc.id; 
        inv.THR_SalesOrganization__c =''; 
        inv.THR_SendTo__c =phAcc.id; 
        inv.THR_ShipperCode__c ='00100'; 
        inv.THR_ShippingCondition__c ='PH: SC production'; 
        inv.THR_ShippingConditionDescription__c ='bla bla bla'; 
        inv.THR_TermsOfPaymentKey__c ='CONTRASSEGNO'; 
        inv.THR_YearofInvoice__c ='2020'; 
         
         insert inv;
         
        THR_InvoiceItem__c invItem = new THR_InvoiceItem__c();
        invItem.THR_BatchNumber__c ='LottoTest_0998008';
        invItem.THR_CommImpCodeNo__c ='17021100';
        invItem.THR_InvoiceItem_Country__c = 'IT';
        invItem.THR_DateDDT__c = Date.newInstance(2020, 06, 30);
        invItem.THR_DDT__c ='DDT_00001';
        invItem.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
        invItem.THR_InvoiceItemKey__c = '0000001';
        invItem.THR_ItemNumber__c = 10;
        invItem.THR_NetValue__c = 76;
        invItem.THR_Quantity__c = 63;
        invItem.THR_ShipperCode__c ='00100'; 
        invItem.THR_ShippingType__c = 'none';
        invItem.THR_InvoiceNumber__c = inv.Id;
        invItem.THR_MaterialID__c =pL.Id; 
        insert invItem;
         //componente nel page
         List<THR_InvoiceItem__c> invItemList =  new List<THR_InvoiceItem__c>{invItem};
     
         date dt = date.newInstance(2020, 07, 21);
         THR_CreateCaseItemsController.retrieveCaseField(phCase.id);
         date newDt = date.newInstance(2020, 07, 21);
         THR_CreateCaseItemsController.updateInvoiceItem(newDt, '001027832797');
         //createItem(List<THR_InvoiceItem__c> itemId, Id caseId, List<THR_InvoiceItem__c> itemOriginal, String ddtNumber, Date ddtDate)
         THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemList, '0980780', dt);
        
        THR_InvoiceItem__c invItem2 = new THR_InvoiceItem__c();
        invItem2.THR_BatchNumber__c ='LottoTest_0998008';
        invItem2.THR_CommImpCodeNo__c ='17021100';
        invItem2.THR_InvoiceItem_Country__c = 'IT';
        invItem2.THR_DateDDT__c = Date.newInstance(2020, 06, 30);
        invItem2.THR_DDT__c ='DDT_00001';
        invItem2.THR_DueDateInvoice__c = Date.newInstance(2020, 06, 25);
        invItem2.THR_InvoiceItemKey__c = '0000002';
        invItem2.THR_ItemNumber__c = 10;
        invItem2.THR_NetValue__c = 79;
        invItem2.THR_Quantity__c = 63;
        invItem2.THR_ShipperCode__c ='00100'; 
        invItem2.THR_ShippingType__c = 'none';
        invItem2.THR_InvoiceNumber__c = inv.Id;
        invItem2.THR_MaterialID__c =pL.Id; 
        insert invItem2;
        
        List<THR_InvoiceItem__c> invItemListNew =  new List<THR_InvoiceItem__c>{invItem, invItem2};
        THR_CreateCaseItemsController.createItem(invItemList, phCase.id, invItemListNew, '0980780', dt);
        
    }
    
    
}