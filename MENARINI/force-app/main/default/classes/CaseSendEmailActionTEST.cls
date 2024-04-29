@isTest
public class CaseSendEmailActionTEST {

    @testSetup static void setup() {
        List<EmailTemplate> emTempList= THR_TestDataFactory.emailTemplateOpeningAndClosingCreation();
        user u=  THR_TestDataFactory.userCreation('System Administrator');
        system.runAs(u){
            THR_TestDataFactory.documentCreation();
            
            // THR_TestDataFactory.AccountAndContactCreation();
            
            THR_TestDataFactory.ProductCreation();
        }
        
    }
    
      static testMethod void test1(){
        //   THR_TestDataFactory.userCreation('System Administrator');
        user u=  THR_TestDataFactory.userCreation('System Administrator');
          
        system.runAs(u){
            Map<String,String> caseRtMap =new Map<String,string>();
            caseRtMap = THR_TestDataFactory.createRtMap('Case');
            
            Account acc = new Account();
            acc.Name = 'TestAcctPharma';
            acc.THR_CustomerIdentificationCode__c='TAP_0001';
            acc.THR_AccountsKey__c ='EXTTAPID_0001';
            acc.THR_AccountGroup__c='Generic Customers';
            acc.THR_MAIL__c='TestAcctPharma@test.it';
            acc.THR_VATNumber__c='VATTAP_0001';
            acc.BillingStreet='Via test, 33';
            acc.BillingPostalCode='00Test01';
            acc.BillingCity='Rome';
            acc.BillingState='Roma';
            acc.BillingCountry='Italy';
            
            insert acc;
            
            Contact cntct = new Contact ();
            cntct.FirstName= 'NomeContatto';
            cntct.LastName='CognomeContatto';
            cntct.AccountId=acc.id;
            cntct.Email='nomeContatto@test.it';
            insert cntct;
            
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
            accDep.BillingCountry='Italy';
            accDep.THR_DepositEmail__c ='dep@test.it';
            accDep.THR_OtherDepositEmail__c ='test@test.it; Test2@test.it; test34@test.it; test54@test.com';
            accDep.THR_DepositDevName__c ='THR_BOMI';
            insert accDep;  
            
            Contact cntctDep = new Contact ();
            cntctDep.FirstName= 'NomeContatto';
            cntctDep.LastName='CognomeContatto';
            cntctDep.AccountId=accDep.id;
            cntctDep.Email='nomeContattoDep@test.it';
            
            insert cntctDep;
            
            Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
            //RT, Acc.id, cntc.id,commDiv,depId, type
            //Quality
            system.debug('@@@@EC pL: ' + pL);
            system.debug('@@@@EC cntcPh cntcPh.email: ' + cntct.Email);
            
            Case phCase = new Case();
            phCase.AccountId = acc.id; //phAcc.id;
            phCase.ContactId = cntct.id; //cntcPh.id;
            phCase.Origin ='Email';
            phCase.THR_CommercialDivision__c = 'Pharma';
            phCase.THR_RequestType__c = 'Return Request'; // 'Return Request';
            phCase.RecordTypeId = caseRtMap.get('THR_ReturnRequest');
            phCase.Status = 'New';
            phCase.TH_Deposit__c = accDep.Id;
            phCase.THR_Country__c = 'IT';
            phCase.THR_BuManagerAuthorizationToProceed__c ='Yes';
            phCase.THR_GdAuthorizationToProceed__c ='Yes';
            phCase.THR_SAAuthorizationToProceed__c ='Yes';
            phCase.THR_Batch__c ='LottoTest0001';
            phCase.Reason ='New problem';
            phCase.Type ='Client error';
            phCase.Priority ='Medium';
            phCase.THR_Type__c='HQ Error';
            phCase.THR_Client_Request_Date__c=Date.newInstance(2020, 01, 20);
            phCase.THR_DDTdate__c=Date.newInstance(2019, 01, 20);
            phCase.THR_DDTNumber__c='DDTNumber';
            
            // Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(acc.id), String.valueOf(cntct.id), 'Pharma',String.valueOf(accDep.Id),'Return Request','Return request for damage');
            insert phCase;
            id CasId = phCase.id;  
			
            THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(pL.id,'Product', CasId);
            
            
            List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
                List<Id> caseIdList = new List<Id>{CasId};
                    test.startTest();
            CaseSendEmailAction.FlowInput fInp = new CaseSendEmailAction.FlowInput();
            List<String> ccAddressList = new List<String>{'test2@test.com,test3@test.com'};
            fInp.caseId = phCase.id;
            fInp.templateId = [Select id from EmailTemplate Limit 1][0].id;
            fInp.toAddresses ='test@test.com, test3@test.com, test_31@test.com';
            fInp.ccAddresses =ccAddressList;
            List<CaseSendEmailAction.FlowInput> fInpList = new List<CaseSendEmailAction.FlowInput>{fInp};
       //     try{
                CaseSendEmailAction.sendTemplateEmail(fInpList);
         /*   }
            catch(Exception e){
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto getMessage: ' + e.getMessage());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto2 getCause: ' + e.getCause());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto3 getLineNumber: ' + e.getLineNumber());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto4 getStackTraceString: ' + e.getStackTraceString());
            }*/
            test.stopTest();
        }
    }
    
}