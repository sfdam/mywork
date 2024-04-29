@IsTest
public class THR_TestDataFactory {

    public static void documentCreation(){
     Id foldId = [SELECT Id FROM Folder WHERE DeveloperName ='THR_DocumentForLetterheads' LIMIT 1].Id;
        
     Document doc = new Document ();
     doc.Name ='test';
     doc.FolderId= foldId; //[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     doc.DeveloperName='test';
     doc.Body = Blob.valueOf('Blablabla');
     doc.ContentType = 'image/jpeg'; //'application/pdf';
 	 doc.IsPublic = true;

     Document docFc = new Document ();
     docFc.Name ='THR_FirmaCODIFI';
     docFc.FolderId= foldId; //[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     docFc.DeveloperName='THR_FirmaCODIFIA';
     docFc.Body = Blob.valueOf('Blablabla');
     docFc.ContentType = 'image/jpeg'; //'application/pdf';
 	 docFc.IsPublic = true;

     Document docFD = new Document ();
     docFD.Name ='THR_FirmaDiagnostic';
     docFD.FolderId= foldId; //[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     docFD.DeveloperName='THR_FirmaDiagnosticA';
     docFD.Body = Blob.valueOf('Blablabla');
     docFD.ContentType = 'image/jpeg'; //'application/pdf';
 	 docFD.IsPublic = true;

     Document docFS = new Document ();
     docFS.Name ='THR_FirmaSilicon';
     docFS.FolderId=foldId; //[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     docFS.DeveloperName='THR_FirmaSiliconA';
     docFS.Body = Blob.valueOf('Blablabla');
     docFS.ContentType = 'image/jpeg'; //'application/pdf';
 	 docFS.IsPublic = true;

     Document docLC = new Document ();
     docLC.Name ='THR_LogoCODIFI';
     docLC.FolderId= foldId;//[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     docLC.DeveloperName='THR_LogoCODIFIA';
     docLC.Body = Blob.valueOf('Blablabla');
     docLC.ContentType = 'image/jpeg'; //'application/pdf';
 	 docLC.IsPublic = true;
     
     Document docLD = new Document ();
     docLD.Name ='THR_DiagnosticLogo';
     docLD.FolderId= foldId; //[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     docLD.DeveloperName='THR_DiagnosticLogoA';
     docLD.Body = Blob.valueOf('Blablabla');
     docLD.ContentType = 'image/jpeg'; //'application/pdf';
 	 docLD.IsPublic = true;

     Document docLS = new Document ();
     docLS.Name ='THR_SiliconLogo1';
     docLS.FolderId= foldId;//[SELECT ID FROM Folder where DeveloperName ='THR_DocumentForLetterheads' limit 1].id;
     docLS.DeveloperName='THR_SiliconLogo1A';
     docLS.Body = Blob.valueOf('Blablabla');
     docLS.ContentType = 'image/jpeg'; //'application/pdf';
 	 docLS.IsPublic = true;
     
     List<Document> newDocList = new List<Document>{doc, docFc, docFD, docFS, docLC, docLD, docLS};
	 insert newDocList;
        
    } 
    
    public static void AccountAndContactCreationSpaign(){
        List<Account> testAccts = new List<Account>();
        
        Account acc = new Account();
        acc.Name = 'TestAcctSpaign';
        acc.AccountNumber = '1234ABC';
        acc.THR_CustomerIdentificationCode__c='TAP_0001';
        acc.THR_AccountsKey__c ='EXTTAPIDSPA_0003';
        acc.THR_AccountGroup__c='Generic Customers';
        acc.THR_MAIL__c='TestAcctPharma@test.it';
        acc.THR_VATNumber__c='VATTAP_0001';
        acc.BillingStreet='Via test, 33';
        acc.BillingPostalCode='00Test01';
       	acc.BillingCity='Rome';
        acc.BillingState='Roma';
        acc.BillingStateCode='RM';
        acc.BillingCountry='Italy';
        acc.BillingCountryCode ='IT';
        acc.THR_DepositDevName__c='THR_BOMI';
        
        insert acc;
        
        Contact cntct = new Contact ();
        cntct.FirstName= 'NomeContattoSpaign';
        cntct.LastName='CognomeContatto'; 
        cntct.AccountId=acc.Id;
        cntct.Email='nomeContatto@test.it';
        cntct.Phone = '0775347824';
        cntct.MailingCity = 'Rome';
        cntct.MailingStateCode= 'RM';
        cntct.MailingPostalCode= '00Test01';
        cntct.MailingStreet= 'Via test, 33';
        cntct.MailingCountryCode= 'IT';
       
        insert cntct;
     	
    }
    
    public static void AccountAndContactCreation(){
        List<Account> testAccts = new List<Account>();
        
        Account acc = new Account();
        acc.Name = 'TestAcctPharma';
        acc.AccountNumber = '1234ABC';
        acc.THR_CustomerIdentificationCode__c='TAP_0001';
        acc.THR_AccountsKey__c ='EXTTAPID_0001';
        acc.THR_AccountGroup__c='Generic Customers';
        acc.THR_MAIL__c='TestAcctPharma@test.it';
        acc.THR_VATNumber__c='VATTAP_0001';
        acc.BillingStreet='Via test, 33';
        acc.BillingPostalCode='00Test01';
       	acc.BillingCity='Rome';
        acc.BillingState='Roma';
        acc.BillingStateCode='RM';
        acc.BillingCountry='Italy';
        acc.BillingCountryCode ='IT';
        acc.THR_DepositDevName__c='THR_BOMI';
        
        insert acc;
        
        Contact cntct = new Contact (FirstName= 'NomeContatto', LastName='CognomeContatto', AccountId=acc.Id,Email='nomeContatto@test.it');
        
        Account acc1 = new Account();
        acc1.Name = 'TestAcctDiagnostics';
        acc1.THR_CustomerIdentificationCode__c='TADn_0001';
        acc1.THR_AccountsKey__c ='EXTTADnID_0001';
        acc1.THR_AccountGroup__c='Generic Customers';
        acc1.THR_MAIL__c='TestAcctDiagnostics@test.it';
        acc1.THR_VATNumber__c='VATTASn_0001';
        acc1.BillingStreet='Via test, 33';
        acc1.BillingPostalCode='00Test01';
        acc1.BillingCity='Rome';
        acc1.BillingState='Roma';
        acc1.BillingStateCode='RM';
        acc1.BillingCountryCode ='IT';
        acc1.BillingCountry='Italy';
   		insert acc1;
         Contact cntct1 = new Contact (FirstName= 'NomeContatto1', LastName='CognomeContatto1', AccountId=acc1.Id,Email='nomeContatto1@test.it');
     	
        Account acc2 = new Account();
        acc2.Name = 'TestAccSil';
        acc2.THR_CustomerIdentificationCode__c='TASn_0001';
        acc2.THR_AccountsKey__c ='EXTTASnID_0001';
        acc2.THR_AccountGroup__c='Generic Customers';
        acc2.THR_MAIL__c='TestAccSil@test.it';
        acc2.THR_VATNumber__c='VATTASn_0002';
        acc2.BillingStreet='Via test, 33';
        acc2.BillingPostalCode='00Test01';
        acc2.BillingCity='Rome';
        acc2.BillingState='Roma';
        acc2.BillingStateCode='RM';
        acc2.BillingCountryCode ='IT';
        acc2.BillingCountry='Italy';
     	insert acc2;
        
       Contact cntct2 = new Contact (FirstName= 'NomeContatto2', LastName='CognomeContatto2', AccountId=acc2.Id,Email='nomeContatto2@test.it');
		
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
        
         Contact cntctDep = new Contact (FirstName= 'NomeContattodDep', LastName='CognomeContattoDep', AccountId=accDep.Id,Email='nomeContattoDep@test.it');
       
         List<Contact> contactList = new List<Contact>{cntct, cntct1,cntct2, cntctDep};
         insert contactList;
     	
    }
    
    public static List<Product2> ProductCreation(){
       
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
	    
        Product2 pdL = new Product2();
        pdL.IsActive = true;
        pdL.Name ='ProdTestName0001';
        pdL.ProductCode ='CodProd0001';
        pdL.THR_MaterialKey__c='MK_PT0001';

        Product2 pdL2 = new Product2();
        pdL2.IsActive = true;
        pdL2.Name ='ProdTestName0002';
        pdL2.ProductCode ='CodProd0002';
        pdL2.THR_MaterialKey__c='FK0001';
        System.debug('@@@@@@pdl2: ' + pdL2 );
        
        List<Product2> prodListToInsert = new List<Product2>{pdL,pdL2};
            
        insert prodListToInsert;
        return prodListToInsert;
    }
    
    //Creazione Users
    //
    public static User userCreation(String profileName){
        
        //'System Administrator'
        Profile profileId = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
        
        User usr = new User();
        usr.Alias = 'standt';
        usr.Email='standarduser@testorg.com';
        usr.EmailEncodingKey='UTF-8';
        usr.LastName='Testing';
        usr.LanguageLocaleKey='en_US'; 
        usr.LocaleSidKey='en_US';
        usr.ProfileId = profileId.Id;
        usr.TimeZoneSidKey='America/Los_Angeles';
        usr.Username=String.valueOf(System.now().getTime())+'@testorg.com';
       // usr.UserRoleId = r.Id;
        insert usr;
        return usr;
        
    }
    
    public static List<EmailTemplate> emailTemplateCreation(){
      
        List<String> listaNameTemplate = new List<String>{'THR_VFLetteraResoCODIFI','THR_VFLetteraResoSilicon','THR_VFLetteraResoDiagnostics'};
		List<EmailTemplate> emTempList = [SELECT Id, Name, Subject, FolderId, Body, Folder.Name, HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName =:listaNameTemplate];
        return emTempList;
        
    }
    
    public static List<EmailTemplate> emailTemplateOpeningAndClosingCreation(){
      
        List<String> listaNameTemplate = new List<String>{'Opening_Diagnostics','Closing_Diagnostics','Opening_Silicon','Closing_Silicon','Opening_CODIFI_Cl','Closing_CODIFI_Cl','Closing_CODIFI_Delivered'};
		List<EmailTemplate> emTempList = [SELECT Id, Name, Subject, Body, FolderId, Folder.Name, HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName =:listaNameTemplate];
        return emTempList;
        
    }
    
    public static Case caseCreation(String RecordTypeDevName, String AccountIdSt, String ContactIdSt,String CommercDiv, String DepId,String ReqType, String TypeSt){
        
        Map<String,String> caseRtMap =new Map<String,String>();
        caseRtMap = createRtMap('Case');
        /*
		//RT, Acc.id, cntc.id,commDiv,depId, type
        THR_TestDataFactory.caseCreation('THR_ReturnRequest', phAcc.id, cntcPh, 'Pharma',dep.Id,'Return request for damage');
        */
        Case phCase = new Case();
        phCase.AccountId = AccountIdSt; //phAcc.id;
        phCase.ContactId = ContactIdSt; //cntcPh.id;
        phCase.Origin ='Email';
        phCase.THR_CommercialDivision__c = CommercDiv; //'Pharma';
        phCase.THR_RequestType__c = ReqType; // 'Return Request';
        phCase.RecordTypeId = caseRtMap.get(RecordTypeDevName);
        phCase.Status = 'new';
        phCase.TH_Deposit__c = DepId;
        phCase.THR_Country__c = 'IT';
        phCase.THR_BuManagerAuthorizationToProceed__c ='Yes';
        phCase.THR_GdAuthorizationToProceed__c ='Yes';
        phCase.THR_SAAuthorizationToProceed__c ='Yes';
        phCase.THR_Batch__c ='LottoTest0001';
        phCase.Reason ='New problem';
        phCase.Type ='Client error';
        phCase.Priority ='Medium';
        phCase.THR_Type__c=TypeSt;//'Return request for damage';
        phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
        phCase.THR_DDTNumber__c = 'DDT_00001';
        phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
       // phCase.ContactEmail ='testcontEmail@test.it';
        
       // insert phCase;
        return phCase;
		
    }
    
    public static THR_Related_Object__c caseItemCreation(String ProdIdSt,String TypeRelObj, String CaseIdSt){
        
         Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        THR_Related_Object__c cItemProd = new THR_Related_Object__c();
        cItemProd.THR_Batch__c = 'LottoTest0001';
        cItemProd.THR_Batch_Expire_Date__c = Date.newInstance(2026, 12, 23);
        cItemProd.THR_Product__c = ProdIdSt;// pL.id;
        cItemProd.THR_Product_Quantity__c = 66;
        cItemProd.THR_Related_Object__c = TypeRelObj; //'Product';
        cItemProd.THR_Case_Related__c = CaseIdSt; //phCase.id;
        System.debug('@@@@caseItemCreation.cItemProd: ' + cItemProd);
       
       	insert cItemProd;
        return cItemProd;
    }
    
    
    public static THR_Related_Object__c caseItemCreationSpaign(String accId, String ProdIdSt,String TypeRelObj, String CaseIdSt){
       	
         Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        Order cOrder = new Order();
        cOrder.AccountId = accId;
        cOrder.EffectiveDate=Date.newInstance(2026, 12, 23);
        cOrder.Status='Draft';
        cOrder.THR_OrderKey__c='KSPA_002';
        insert cOrder;
        
        THR_Invoice__c currentInvoice = new THR_Invoice__c();
        currentInvoice.THR_DocumentNumberSD__c = '';
        currentInvoice.THR_Date__c = Date.newInstance(2026, 12, 23);
        currentInvoice.THR_OrderNumber__c = cOrder.OrderNumber;
        currentInvoice.THR_GrossValue__c =  Decimal.valueOf('1');
        insert currentInvoice;
        
        THR_Related_Object__c cItemProd = new THR_Related_Object__c();
        cItemProd.THR_Batch__c = 'LottoTest0001';
        cItemProd.THR_Batch_Expire_Date__c = Date.newInstance(2026, 12, 23);
        cItemProd.THR_Product__c = ProdIdSt;
        cItemProd.THR_Product_Quantity__c = 66;
        cItemProd.THR_Related_Object__c = TypeRelObj; 
        cItemProd.THR_Case_Related__c = CaseIdSt; 
        cItemProd.THR_Description__c = 'TestDescription'; 
        cItemProd.THR_Order__c = cOrder.Id; 
        cItemProd.THR_Invoice__c = currentInvoice.Id; 
       	insert cItemProd;
        return cItemProd;
        
    }
    
    public static Map<String,String> createRtMap(String objName){
        Map<String,String> rtMapL =new Map<String,String>();
        for(RecordType rt: [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType=: objName]){
            rtMapL.put(rt.DeveloperName, rt.Id);
        }
        System.debug('nel metodo di creazione mappa. rtMapL: ' + rtMapL);
        return rtMapL;

    }

    // Method to create one single Account
    public static Account createAccount(String name, String country, String accountsKey) {
        Account account = new Account();
        account.Name  = name;
        account.THR_Country__c = country;
        account.THR_AccountsKey__c = accountsKey;
        return account;
    }

    //
    public static Account CreateSingleCompleteAccount(String SpainOrItalyOr, String accountsKey){
        
        Account acc = new Account();
        acc.THR_AccountGroup__c='Generic Customers';
        System.debug('@@@@SpainOrItalyOr: ' + SpainOrItalyOr);
       	if('Italy'.equalsIgnoreCase(SpainOrItalyOr)){
       	//if(SpainOrItalyOr.equalsIgnoreCase('Italy')){
         System.debug('@@@@ ItalianAccountCreation ');
        acc.Name = 'TestAcctPharma';
        acc.THR_VATNumber__c='VATTAP_0001';
        acc.THR_CustomerIdentificationCode__c='TAP_0001';
        acc.THR_AccountsKey__c = accountsKey;
        acc.THR_MAIL__c='TestAcctPharma@test.it';
        acc.BillingStreet='Via test, 33';
        acc.BillingPostalCode='00Test01';
        acc.BillingCity='Rome';
        acc.BillingState='Roma';
        acc.BillingStateCode='RM';
        acc.BillingCountry='Italy';
        acc.BillingCountryCode ='IT';
        acc.THR_Country__c ='IT';
        acc.Phone='06232323';
        }else{
        System.debug('@@@@ SpanishAccountCreation ');
        acc.THR_CustomerIdentificationCode__c='TAPS_001';
        acc.Name = 'TestAcctPharmaSpain';
        acc.THR_VATNumber__c='VATTAPS_0001';
        acc.THR_MAIL__c='TestAcctPharmaSpain@test.it';
        acc.THR_AccountsKey__c =accountsKey;
        acc.BillingStreet='CL CALDERON DE LA BARCA, 33';
        acc.BillingPostalCode ='28049';
        acc.BillingCity='Madrid';
        acc.BillingState='Madrid';
        acc.BillingStateCode='28';
        acc.BillingCountry='Spain';
        acc.BillingCountryCode ='ES';
        acc.THR_Country__c ='ES';
        acc.Phone ='+34949790000';
        }
        insert acc;
        return acc;
    }
    
    public static Contact CreateSingleCompleteContact(String AccId){
		 System.debug('@@@TestDataFactory AccId: ' + AccId);
        Account acc = [SELECT Id,Name, THR_CustomerIdentificationCode__c,THR_AccountsKey__c,
                       THR_AccountGroup__c,THR_MAIL__c,THR_VATNumber__c,THR_Country__c, 
                       BillingStreet, BillingPostalCode, BillingCity, BillingState, 
                       BillingStateCode, BillingCountry, BillingCountryCode, Phone 
                       FROM Account WHERE Id=:AccId LIMIT 1];
        
        System.debug('@@@TestDataFactory acc: ' + acc);
        System.debug('@@@TestDataFactory acc.BillingCountryCode: ' + acc.BillingCountryCode);
        System.debug('@@@TestDataFactory acc.BillingCountry: ' + acc.BillingCountry);
        Contact cntct = new Contact();
        if(acc.THR_Country__c == 'IT'){
            cntct.FirstName= 'NomeContattodDep';
            cntct.LastName='CognomeContattoDep';
            cntct.AccountId=AccId;
            cntct.Email='nomeContattoDep@test.it'; 
            cntct.Phone='06222129292';
            cntct.OtherPhone='3333131331';
            cntct.MobilePhone='33232331422';
            cntct.HomePhone='06222222222';
            cntct.THR_Country__c = acc.THR_Country__c;
        }else{
            cntct.FirstName= 'NomeSpagna';
            cntct.LastName='CognomeSpagna';
            cntct.AccountId=AccId;
            cntct.Email='nomeContattoSpagna@test.it'; 
            cntct.Phone='06223469292';
            cntct.OtherPhone='3333131331';
            cntct.MobilePhone='33232331422';
            cntct.HomePhone='06222222222';
            cntct.THR_Country__c = acc.THR_Country__c;
        }
        insert cntct;
        return cntct;
        
    }
    // Method to create one single Entitlement
    public static Entitlement createEntitlement(String name, String country, Id accountId) {
        Entitlement entitlement = new Entitlement();
        entitlement.Name = name; 
        entitlement.THR_Country__c = country;
        entitlement.AccountId = accountId;
        entitlement.StartDate = Date.today().addDays(-2);
        entitlement.EndDate = Date.today().addDays(2);
        //entitlement.SlaProcessId = ;
        return entitlement;
    }
	
    // Method to create one single Account Deposit.
    public static Account depositAccountCreation(){
        
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

		return accDep;
        
    }
    
    // Method to create one single Case
    public static Case createCase(String recordTypeName, Id accountId, String ContactIdSt, String commercialDivision,String country, String accDepositId) {

        Map<String,String> caseRtMap =new Map<String,String>();
        caseRtMap = createRtMap('Case');
        
        Case phCase = new Case();
        phCase.AccountId = accountId; //phAcc.id;
        phCase.ContactId = ContactIdSt; //cntcPh.id;
        phCase.THR_RequestType__c = 'Return Request'; //cntcPh.id;
		phCase.THR_Type__c='HQ Error';
        phCase.Origin ='Phone';
        phCase.TH_Deposit__c = accDepositId;
        phCase.THR_CommercialDivision__c = commercialDivision; //'Pharma';
        phCase.RecordTypeId = caseRtMap.get(recordTypeName);
        phCase.Status = 'new';
        phCase.THR_Country__c = country;
        phCase.THR_BuManagerAuthorizationToProceed__c ='Yes';
        phCase.THR_GdAuthorizationToProceed__c ='Yes';
        phCase.THR_SAAuthorizationToProceed__c ='Yes';
        phCase.THR_Batch__c ='LottoTest0001';
        phCase.Reason ='New problem';
        phCase.Type ='Client error';
        phCase.Priority ='Medium';
        phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
        phCase.THR_DDTNumber__c = 'DDT_00001';
        phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
        return phCase;
    }
    
    // Method to create one single Case
    public static Case createSpanishCase(String recordTypeName, Id accountId, String ContactIdSt, String commercialDivision,String country, String accDepositId) {

        Map<String,String> caseRtMap =new Map<String,String>();
        caseRtMap = createRtMap('Case');
        
        Case phCase = new Case();
        phCase.AccountId = accountId; //phAcc.id;
        phCase.ContactId = ContactIdSt; //cntcPh.id;
        phCase.THR_RequestType__c = 'Logistics'; //cntcPh.id;
		phCase.THR_Type__c='Order Introduction';
        phCase.Origin ='Phone';
        phCase.TH_Deposit__c = accDepositId;
        phCase.THR_CommercialDivision__c = commercialDivision; //'Pharma';
        phCase.RecordTypeId = caseRtMap.get(recordTypeName);
        phCase.Status = 'New';
        phCase.THR_Country__c = country;
        phCase.THR_BuManagerAuthorizationToProceed__c ='Yes';
        phCase.THR_GdAuthorizationToProceed__c ='Yes';
        phCase.THR_SAAuthorizationToProceed__c ='Yes';
        phCase.THR_Batch__c ='LottoTest0001';
        phCase.Priority ='Medium';
        phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
        phCase.THR_DDTNumber__c = 'DDTSPA_00001';
        phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
        return phCase;
    }
    
    public static Case createSpainCase(String recordTypeName, Id accountId, String ContactIdSt, String commercialDivision,String country, String accDepositId) {

        Map<String,String> caseRtMap =new Map<String,String>();
        caseRtMap = createRtMap('Case');
        
        Case phCase = new Case();
        phCase.AccountId = accountId; //phAcc.id;
        phCase.ContactId = ContactIdSt; //cntcPh.id;
        phCase.THR_RequestType__c = 'Logistics'; //cntcPh.id;
		//phCase.THR_Type__c='HQ Error';
        phCase.Origin ='Phone';
        phCase.TH_Deposit__c = accDepositId;
        phCase.THR_CommercialDivision__c = commercialDivision; //'Pharma';
        phCase.RecordTypeId = caseRtMap.get(recordTypeName);
        phCase.Status = 'new';
        phCase.THR_Country__c = country;
        phCase.THR_BuManagerAuthorizationToProceed__c ='Yes';
        phCase.THR_GdAuthorizationToProceed__c ='Yes';
        phCase.THR_SAAuthorizationToProceed__c ='Yes';
        phCase.THR_Batch__c ='LottoTest0001';
        phCase.Reason ='New problem';
        phCase.Type ='Loss';
        phCase.Priority ='Medium';
        phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
        phCase.THR_DDTNumber__c = 'DDT_00001';
        phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
        return phCase;
    }

    //21.03.2022

    public static Case createSpainCaseForBatch(String recordTypeName, Id accountId, String contactId) {
        Map<String, String> caseRtMap = createRtMap('Case');
        Case newCase = new Case();
        newCase.RecordTypeId = caseRtMap.get(recordTypeName);
        newCase.AccountId = accountId;
        newCase.ContactId = contactId;
        newCase.Origin = 'Email';
        newCase.Status = 'New';
        newCase.THR_Country__c = 'ES';
        newCase.THR_BuManagerAuthorizationToProceed__c = 'Yes';
        newCase.THR_GdAuthorizationToProceed__c = 'Yes';
        newCase.THR_SAAuthorizationToProceed__c = 'Yes';
        newCase.THR_SAAuthorizationToProceed__c = 'Yes';
        newCase.THR_Batch__c = 'LottoTest0001';
        newCase.Priority = 'Medium';
        newCase.THR_Client_Request_Date__c = Date.newInstance(2020,06,25);
        newCase.THR_DDTdate__c = Date.newInstance(2020,06,30);
        newCase.THR_DDTNumber__c = 'DDTSPA_00001';

        if(recordTypeName == 'THR_Logistic_ES') {
            newCase.THR_RequestType__c = 'Logistics';
            newCase.THR_Type__c = 'Delay in delivery order';
            newCase.THR_Case_Reason__c = '';
        }
        else if(recordTypeName == 'THR_Regulatory_es') {
            newCase.THR_RequestType__c = 'Regulatory Affairs';
            newCase.THR_Type__c = 'External efforts';
            newCase.THR_Case_Reason__c = '';
        }
        else if(recordTypeName == 'THR_Quality_es') {
            newCase.THR_RequestType__c = 'Quality';
            newCase.THR_Type__c = 'Environment communication';
            newCase.THR_Case_Reason__c = '';
        }
        else if(recordTypeName == 'THR_Medical_and_Pharmacovigilance_ES') {
            newCase.THR_RequestType__c = 'Medical';
            newCase.THR_Type__c = 'Medical consultations for product administration in a special situation';
            newCase.THR_Case_Reason__c = '';
        }
        else if(recordTypeName == 'THR_Pharmacovigilance') {
            newCase.THR_RequestType__c = 'Pharmacovigilance';
            newCase.THR_Type__c = 'Adverse Reaction';
        }
        else if(recordTypeName == 'THR_Trade_es'){
            newCase.THR_RequestType__c = 'Trade';
            newCase.THR_Type__c = 'Claims Field Force Template';
            newCase.THR_Case_Reason__c = '';
        }
        else if(recordTypeName == 'THR_ClaimEs') {

            newCase.THR_RequestType__c = 'Logistics';
            newCase.THR_Type__c = 'Other';
            newCase.THR_Case_Reason__c = '';
            newCase.THR_DDTNumber__c = '1234';
        }

        insert newCase;
        return newCase;
    }

   public static Map<String, SObject> createGenericPatientAndContactSpain() {
       Map<String, SObject> accConMap = new Map<String, SObject>();
       Account pacGen = new Account(
               Name = 'PACIENTE GENERICO',
               THR_AccountsKey__c ='111111B',
               THR_Country__c = 'ES'
       );
       insert pacGen;
       accConMap.put('Account', pacGen);
       Contact cntdel = new Contact (
               FirstName= 'Contacto',
               LastName='Eliminado',
               THR_Country__c = 'ES',
               AccountId=pacGen.Id,
               Email='nomeContattoDel@test.it',
               MobilePhone ='3489991155',
               Phone = '05690000',
               MailingStreet = 'Via Test, 123'
       );
       insert cntdel;
       accConMap.put('Contact', cntdel);
       return accConMap;
   }



    public static List<Contact> createNContactSpain (Id accId, Integer amount) {
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<amount;i++) {
            Contact con = new Contact (
                    FirstName= 'Test',
                    LastName='Contact' + i,
                    THR_Country__c = 'ES',
                    AccountId=accId,
                    Email='test.contact_' + i + '@test.it',
                    MobilePhone ='39300000' + i,
                    Phone = '06690000' +i,
                    MailingStreet = 'Via test, 2' +i,
                    MailingCity = 'Rome',
                    MailingStateCode= 'RM',
                    MailingPostalCode= '00Test0' + i,
                    MailingCountryCode= 'IT'
            );
            conList.add(con);
        }
        insert conList;
        return conList;
    }

    public static Order createOrder(Account acc, String key, String status, String country) {
        Order ord = new Order();
        ord.Account = acc;
        ord.AccountId = acc.Id;
        ord.EffectiveDate = Date.today();
        ord.THR_OrderKey__c = key;
        ord.Status = status;
        ord.THR_Country__c = country;
        return ord;
    }
}