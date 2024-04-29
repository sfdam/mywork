@isTest
public class THR_VFEmailTemplateController_TEST {
 @testSetup static void setup() {
     
     THR_TestDataFactory.documentCreation();
     
     THR_TestDataFactory.AccountAndContactCreation();
     
     THR_TestDataFactory.ProductCreation();
     
     
    }
    
    static testMethod void test1(){
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
        
        Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'Pharma',String.valueOf(dep.Id),'Return Request','HQ error');
        insert phCase;
        
        THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(String.valueOf(pL.id),'Product', String.valueOf(phCase.id));
        
        List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
        
        THR_VFEmailTemplateController ccntrl = new THR_VFEmailTemplateController();
        ccntrl.caseRecordId = phCase.id;
        ccntrl.caseItemRelatedToCaseApproved = cItemProdList;
        ccntrl.caseApproved= phCase;
        ccntrl.codiceCliente ='test';
        ccntrl.accName='NameTest';
       
        ccntrl.accBillingStreet ='Via Test';
        ccntrl.accBillingPostCodeAndCity= '00100 Roma';
        ccntrl.accBillingStateCode = 'RM';
        ccntrl.accBillingCountryCode = 'IT';
        
        
         //ccntrl.accBillingAddress='via test';
        ccntrl.depBillingAddress ='via test2';
        ccntrl.isCodifi = true;
        ccntrl.isDiagnostics =true;
        ccntrl.isSilicon =true;
        ccntrl.depName ='depName';
        ccntrl.fSil='test';
        ccntrl.fDi='test';
        ccntrl.fCod='test';
        ccntrl.LSil='test';
        ccntrl.LDi='test';
        ccntrl.LCod='test';
        ccntrl.FooterCodifi='test';  //added a.micillo 21.12.2020
        string cId = ccntrl.caseRecordId;
        List<THR_Related_Object__c> citL = ccntrl.caseItemRelatedToCaseApproved;
        Case cApp = ccntrl.caseApproved;
        String acN = ccntrl.accName;
        String cc =  ccntrl.codiceCliente;
       // String accBA = ccntrl.accBillingAddress;
        String accBA = ccntrl.accBillingStreet;
        String accBPCC = ccntrl.accBillingPostCodeAndCity;
        String accStCode = ccntrl.accBillingStateCode;
        String accBillCountryCode = ccntrl.accBillingCountryCode;
        
        
        String depBA = ccntrl.depBillingAddress;
        Boolean isC = ccntrl.isCodifi;
        Boolean isD = ccntrl.isDiagnostics;
        Boolean isS = ccntrl.isSilicon;
        
        String dName = ccntrl.depName;
        try{
        String abc = ccntrl.fSil;
        }catch(exception e){}
        try{
        String def = ccntrl.fDi;
        }Catch(exception e){}
        try{
        String ghi= ccntrl.fCod;
        }Catch(Exception e){}
        try{
        String aaa = ccntrl.LSil;
        }catch(Exception e){} 
        try{
        String bbb = ccntrl.LDi;
        }catch(Exception e){}
        try{
        String ccc = ccntrl.LCod; 
        }catch(Exception e){}
        try{
        String ddd = ccntrl.FooterCodifi;   //added a.micillo 21.12.2020
        }catch(Exception e){}
        date dt = date.parse(ccntrl.todayDate);
        
        ccntrl.todayDate = String.valueOf(Date.newInstance(2020, 01, 20));
        try{
        ccntrl.getDocumentLogoUrl('test');
        }catch(exception e){}
        ccntrl.fCod ='test';
        
        
        test.stopTest();
    }
    
     static testMethod void test1MDCheckUp(){
        THR_TestDataFactory.userCreation('System Administrator');
       string mdCheckUpStr= 'MD Check Up';
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
        
        Case phCase= THR_TestDataFactory.caseCreation('THR_ReturnRequest', String.valueOf(phAcc.id), String.valueOf(cntcPh.id), 'MD Check Up',String.valueOf(dep.Id),'Return Request','HQ error');
        insert phCase;
        
        THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreation(String.valueOf(pL.id),'Product', String.valueOf(phCase.id));
        
        List<THR_Related_Object__c> cItemProdList = new List<THR_Related_Object__c> {cItemProd};
        
        THR_VFEmailTemplateController ccntrl = new THR_VFEmailTemplateController();
        ccntrl.caseRecordId = phCase.id;
        ccntrl.caseItemRelatedToCaseApproved = cItemProdList;
        ccntrl.caseApproved= phCase;
        ccntrl.codiceCliente ='test';
        ccntrl.accName='NameTest';
       
        ccntrl.accBillingStreet ='Via Test';
        ccntrl.accBillingPostCodeAndCity= '00100 Roma';
        ccntrl.accBillingStateCode = 'RM';
        ccntrl.accBillingCountryCode = 'IT';
        
        
         //ccntrl.accBillingAddress='via test';
        ccntrl.depBillingAddress ='via test2';
        ccntrl.isCodifi = true;
        ccntrl.isDiagnostics =true;
        ccntrl.isSilicon =true;
        ccntrl.depName ='depName';
        ccntrl.fSil='THR_FirmaSilicon';
        ccntrl.fDi='THR_FirmaCODIFI';
        ccntrl.fCod='THR_FirmaDiagnostic';
        ccntrl.LSil='THR_SiliconLogo1';
        ccntrl.LDi='THR_DiagnosticLogo';
        ccntrl.LCod='THR_LogoCODIFI';
        ccntrl.FooterCodifi='THR_CodifiFooter';  //added a.micillo 21.12.2020
        string cId = ccntrl.caseRecordId;
        List<THR_Related_Object__c> citL = ccntrl.caseItemRelatedToCaseApproved;
        Case cApp = ccntrl.caseApproved;
        String acN = ccntrl.accName;
        String cc =  ccntrl.codiceCliente;
       // String accBA = ccntrl.accBillingAddress;
        String accBA = ccntrl.accBillingStreet;
        String accBPCC = ccntrl.accBillingPostCodeAndCity;
        String accStCode = ccntrl.accBillingStateCode;
        String accBillCountryCode = ccntrl.accBillingCountryCode;
        
        String depBA = ccntrl.depBillingAddress;
        Boolean isC = ccntrl.isCodifi;
        Boolean isD = ccntrl.isDiagnostics;
        Boolean isS = ccntrl.isSilicon;
        
        String dName = ccntrl.depName;
        try{
        String abc = ccntrl.fSil;
        }catch(exception e){}
        try{
        String def = ccntrl.fDi;
        }Catch(exception e){}
        try{
        String ghi= ccntrl.fCod;
        }Catch(Exception e){}
        try{
        String aaa = ccntrl.LSil;
        }catch(Exception e){} 
        try{
        String bbb = ccntrl.LDi;
        }catch(Exception e){}
        try{
        String ccc = ccntrl.LCod; 
        }catch(Exception e){}
        try{
        String ddd = ccntrl.FooterCodifi; //added  a.micillo 21.12.2020
        }catch(Exception e){}
        date dt = date.parse(ccntrl.todayDate);
        
        ccntrl.todayDate = String.valueOf(Date.newInstance(2020, 01, 20));
         try{
        ccntrl.getDocumentLogoUrl('test');
         }catch(Exception e){}
        ccntrl.fCod ='test';
        ccntrl.accBillingAddress ='test';
        String acBilAdd = ccntrl.accBillingAddress;
        test.stopTest();
    }
    
    
    static testMethod void test2(){
         THR_VFEmailTemplateController ccntrl = new THR_VFEmailTemplateController();
        test.startTest();
        try{
            String abc = ccntrl.fSil;
        }
        catch(Exception e) {}
        try{
            String def = ccntrl.fDi;
        }catch(exception e){}
        try{
            String ghi= ccntrl.fCod;
        } catch(exception e){}
        try{
             String aaa = ccntrl.LSil;
        } catch(exception e){}
        try{
            String bbb = ccntrl.LDi;
        }
        catch(Exception e){}
        try{
        String ccc = ccntrl.LCod;
        }
        catch(Exception e){}
        try{
        String ddd = ccntrl.FooterCodifi;  //added a.micillo 21.12.2020
        }
        catch(Exception e){}
        test.stopTest();
    }

}