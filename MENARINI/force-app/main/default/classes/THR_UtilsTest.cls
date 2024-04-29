@isTest
public class THR_UtilsTest {
    
    @testSetup static void setup() {
        List<EmailTemplate> emTempList= THR_TestDataFactory.emailTemplateCreation();
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
            acc.THR_AccountsKey__c ='EXTTAPID_0001A';
            acc.THR_AccountGroup__c='Generic Customers';
            acc.THR_MAIL__c='TestAcctPharma@test.it';
            acc.THR_VATNumber__c='VATTAP_0001';
            acc.BillingStreet='Via test, 33';
            acc.BillingPostalCode='00Test01';
            acc.BillingCity='Rome';
            acc.BillingState='Roma';
            acc.BillingCountry='Italy';
            acc.THR_AccountsKey__c = '123456';
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
            accDep.THR_DepositDevName__c='THR_BOMI';
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
            system.debug('@@@@EC cntcPh cntcPh.email: ' + cntct.Email);
            
            Case phCase = new Case();
            phCase.AccountId = acc.id; //phAcc.id;
            phCase.ContactId = cntct.id; //cntcPh.id;
            phCase.Origin ='Email';
            phCase.THR_CommercialDivision__c = 'Pharma';
            phCase.THR_RequestType__c = 'Return Request'; // 'Return Request';
            phCase.RecordTypeId = caseRtMap.get('THR_ReturnRequest');
            phCase.Status = 'new';
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
            phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
			phCase.THR_DDTNumber__c = 'DDT_00001';
            phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
            // Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(acc.id), String.valueOf(cntct.id), 'Pharma',String.valueOf(accDep.Id),'Return Request','Return request for damage');
            insert phCase;
            id CasId = phCase.id;
            THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(String.valueOf(pL.id),'Product', String.valueOf(CasId));
            
            List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
                List<Id> caseIdList = new List<Id>{CasId};
                    test.startTest();
       //     try{
                THR_Utils.sendEmailForService(caseIdList);
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
    
    static testMethod void test2(){
            user u=  THR_TestDataFactory.userCreation('System Administrator');
         system.runAs(u){
            Map<String,String> caseRtMap =new Map<String,string>();
            caseRtMap = THR_TestDataFactory.createRtMap('Case');
       
           // List<EmailTemplate> emTempList= THR_TestDataFactory.emailTemplateCreation();
            Account acc1 = new Account();
            acc1.Name = 'TestAcctDiagnostics';
            acc1.THR_CustomerIdentificationCode__c='TADn_0001';
            acc1.THR_AccountsKey__c ='EXTTADnID_0001B';
            acc1.THR_AccountGroup__c='Generic Customers';
            acc1.THR_MAIL__c='TestAcctDiagnostics@test.it';
            acc1.THR_VATNumber__c='VATTASn_0001';
            acc1.BillingStreet='Via test, 33';
            acc1.BillingPostalCode='00Test01';
            acc1.BillingCity='Rome';
            acc1.BillingState='Roma';
            acc1.BillingCountry='Italy';
            acc1.THR_AccountsKey__c = '123';
            insert acc1;
            
            Contact cntct = new Contact ();
            cntct.FirstName= 'NomeContatto';
            cntct.LastName='CognomeContatto';
            cntct.AccountId=acc1.id;
            cntct.Email='nomeContatto1@test.it';
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
            accDep.THR_DepositDevName__c='THR_BOMI';
            insert accDep;  
            
            Contact cntctDep = new Contact ();
            cntctDep.FirstName= 'NomeContatto';
            cntctDep.LastName='CognomeContatto';
            cntctDep.AccountId=accDep.id;
            cntctDep.Email='nomeContattoDep@test.it';
            
            insert cntctDep;
            
            Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
            //RT, Acc.id, cntc.id,commDiv,depId, type
          
            Case phCase = new Case();
            phCase.AccountId = acc1.id; //phAcc.id;
            phCase.ContactId = cntct.id; //cntcPh.id;
            phCase.Origin ='Email';
            phCase.THR_CommercialDivision__c = 'Menarini Diagnostics (MD)';
            phCase.THR_RequestType__c = 'Return Request'; // 'Return Request';
            phCase.RecordTypeId = caseRtMap.get('THR_ReturnRequest');
            phCase.Status = 'new';
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
            phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
			phCase.THR_DDTNumber__c = 'DDT_00001';
            phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
            
            insert phCase;
            /*  
            Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(acc1.id), String.valueOf(cntct.id), 'Menarini Diagnostics (MD)',String.valueOf(accDep.Id),'Return Request','3R Client error');
            insert phCase; */
            id CasId = phCase.id;
            THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(String.valueOf(pL.id),'Product', String.valueOf(phCase.id));
            
            List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
                List<Id> caseIdList = new List<Id>{CasId};
                    test.startTest();
           // try{
                THR_Utils.sendEmailForService(caseIdList);
            /*}
            catch(Exception e){
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto getMessage: ' + e.getMessage());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto2 getCause: ' + e.getCause());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto3 getLineNumber: ' + e.getLineNumber());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto4 getStackTraceString: ' + e.getStackTraceString());
            }*/
            test.stopTest();
        }
    }
    
    static testMethod void test3(){
        user u=  THR_TestDataFactory.userCreation('System Administrator');
        system.runAs(u){
            List<EmailTemplate> emTempList= THR_TestDataFactory.emailTemplateCreation();
            
            Account acc2 = new Account();
            acc2.Name = 'TestAccSil';
            acc2.THR_CustomerIdentificationCode__c='TASn_0001';
            acc2.THR_AccountsKey__c ='EXTTASnID_0001C';
            acc2.THR_AccountGroup__c='Generic Customers';
            acc2.THR_MAIL__c='TestAccSil@test.it';
            acc2.THR_VATNumber__c='VATTASn_0002';
            acc2.BillingStreet='Via test, 33';
            acc2.BillingPostalCode='00Test01';
            acc2.BillingCity='Rome';
            acc2.BillingState='Roma';
            acc2.BillingCountry='Italy';
            acc2.THR_AccountsKey__c = '1234';
            insert acc2;
            
            Contact cntct = new Contact ();
            cntct.FirstName= 'NomeContatto';
            cntct.LastName='CognomeContatto';
            cntct.AccountId=acc2.id;
            cntct.Email='nomeContatto2@test.it';
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
            accDep.THR_DepositDevName__c='THR_BOMI';
            insert accDep;  
            
            Contact cntctDep = new Contact ();
            cntctDep.FirstName= 'NomeContatto';
            cntctDep.LastName='CognomeContatto';
            cntctDep.AccountId=accDep.id;
            cntctDep.Email='nomeContattoDep@test.it';
            
            insert cntctDep;
            
            Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
            //RT, Acc.id, cntc.id,commDiv,depId, type
            
            Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(acc2.id), String.valueOf(cntct.id), 'Silicon Bio System (MSB)',String.valueOf(accDep.Id),'Return Request','Client error');
            insert phCase;
            id CasId = phCase.id;
            THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(String.valueOf(pL.id),'Product', String.valueOf(phCase.id));
            
            List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
                List<Id> caseIdList = new List<Id>{CasId};
                    test.startTest();
          //  try{
                THR_Utils.sendEmailForService(caseIdList);
           /* }
            catch(Exception e){
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto getMessage: ' + e.getMessage());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto2 getCause: ' + e.getCause());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto3 getLineNumber: ' + e.getLineNumber());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto4 getStackTraceString: ' + e.getStackTraceString());
            }*/
            test.stopTest();
        }
    }
    
     static testMethod void test4(){
        
        user u=  THR_TestDataFactory.userCreation('System Administrator');
        
        system.runAs(u){
            List<EmailTemplate> emTempList= THR_TestDataFactory.emailTemplateCreation();
            
            Account acc2 = new Account();
            acc2.Name = 'TestAccSil';
            acc2.THR_CustomerIdentificationCode__c='TASn_0001';
            acc2.THR_AccountsKey__c ='EXTTASnID_0001D';
            acc2.THR_AccountGroup__c='Generic Customers';
            acc2.THR_MAIL__c='TestAccSil@test.it';
            acc2.THR_VATNumber__c='VATTASn_0002';
            acc2.BillingStreet='Via test, 33';
            acc2.BillingPostalCode='00Test01';
            acc2.BillingCity='Rome';
            acc2.BillingState='Roma';
            acc2.BillingCountry='Italy';
            acc2.THR_AccountsKey__c = '12345';
            insert acc2;
            
            Contact cntct = new Contact ();
            cntct.FirstName= 'NomeContatto';
            cntct.LastName='CognomeContatto';
            cntct.AccountId=acc2.id;
            cntct.Email='nomeContatto2@test.it';
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
            accDep.THR_DepositDevName__c='THR_BOMI';
            insert accDep;  
            
            Contact cntctDep = new Contact ();
            cntctDep.FirstName= 'NomeContatto';
            cntctDep.LastName='CognomeContatto';
            cntctDep.AccountId=accDep.id;
            cntctDep.Email='nomeContattoDep@test.it';
            
            insert cntctDep;
            
            Product2 pL = [select id,isActive, Name, ProductCode from Product2 Limit 1];
            //RT, Acc.id, cntc.id,commDiv,depId, type
            
            Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(acc2.id), String.valueOf(cntct.id), 'Silicon Bio System (MSB)',String.valueOf(accDep.Id),'Return Request','Client error');
            insert phCase;
            id CasId = phCase.id;
            THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(String.valueOf(pL.id),'Product', String.valueOf(phCase.id));
            
            List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
                List<Id> caseIdList = new List<Id>{accDep.id};
                    test.startTest();
            try{
                THR_Utils.sendEmailForService(caseIdList);
            }
            catch(Exception e){
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto getMessage: ' + e.getMessage());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto2 getCause: ' + e.getCause());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto3 getLineNumber: ' + e.getLineNumber());
                system.debug('@@@@@EC dentro exception. questo è ciò che è andato storto4 getStackTraceString: ' + e.getStackTraceString());
            }
            test.stopTest();
        }
    }
    
    
    
}