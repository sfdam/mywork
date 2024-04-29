@isTest
public class WRT_IntegrazioneController_Test {
    @testSetup static void setup() {    

         Profile pr = [SELECT Id FROM Profile WHERE Name = 'Warrant Hub - System Administrator' LIMIT 1];
        User usr = TestDataFactory.create_User(pr.Id);
        usr.Societa__c = 'Warrant';
        insert usr;

        // User current = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs(new User(Id = UserInfo.getUserId())){
          Funzionalita__c x= new Funzionalita__c();
          x.Disabilita_tutti_i_trigger__c=true;
          insert x;
          List<Account> accList= TestDataFactory.createAccounts(1);
          accList[0].OwnerId = usr.Id;
          accList[0].Censimento_Manuale__c = false;
          accList[0].Data_Ultimo_Arricchimento__c = System.Today();
          accList[0].Escludi_da_deduplica__c = true;
          insert accList;
          List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
          oppLIST[0].OwnerId = usr.Id;
          system.debug('oppList: '+oppList);
          RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' and IsActive = true and DeveloperName = 'WRT_CPQ' LIMIT 1];
          system.debug('rt: '+rt);
          oppList[0].RecordTypeId = rt.Id;
          OpportunityStage opstgpre = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability < 50 LIMIT 1];
          system.debug('opstgpre: '+opstgpre);
          oppList[0].StageName = opstgpre.ApiName;
          insert oppList[0];

          List<Opportunity> oppList2 = TestDataFactory.createOpportunity(accList);
          oppLIST2[0].OwnerId = usr.Id;
          system.debug('oppList: '+oppList);
          //RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' and IsActive = true and DeveloperName = 'Warrant' LIMIT 1];
          system.debug('rt: '+rt);
          oppList2[0].RecordTypeId = rt.Id;
          //OpportunityStage opstgpre = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability < 50 LIMIT 1];
          system.debug('opstgpre: '+opstgpre);
          oppList2[0].StageName = opstgpre.ApiName;
          insert oppList2[0];
          x.Disabilita_tutti_i_trigger__c=false;
          update x;
          delete x;
          
        }
      }
      @isTest static void testSharePointAccount() {      
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert endp;

        Map<String,String> header = new Map<String,String>(); 
          User u = [Select Id FROM User WHERE UserName = 'test.User@testr.name'];
        //String token = jwt.issue();
        header.put('Content-Type','application/json');
       // header.put('Authorization', 'Bearer ' + token);
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"CreatedFolders":["https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Mandati","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/GDPR","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Scheda fornitore","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Gare appalto","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Fusioni-Cessioni-Incorporazioni"]}', header);
        Test.setMock(HttpCalloutMock.class, mock);

        // Funzionalita__c x= new Funzionalita__c();
        // x.Bypass_Validation_Rules__c = true; 
        // x.Disabilita_tutti_i_trigger__c=true;
        // insert x;
        System.runAs(u){
          //      Funzionalita__c x= new Funzionalita__c();
          //    x.Disabilita_tutti_i_trigger__c=true;
        	//    insert x;
          //      List<Lead> l = TestDataFactory.createLeads(1);
          //     // List<Account> a = TestDataFactory.createAccounts(1);
          //     l[0].LastName = 'TestIntegration';
          //     l[0].Company = 'TestIntegration';
          //      l[0].Societa_di_riferimento__c = 'Warrant';
          //     l[0].Partiva_Iva__c = '73842983744';
          //         l[0].Codice_Fiscale__c= '73842983744';
          //       l[0].Basket_del_Lead__c = 'Mercato Potenziale';
          // insert l;
          //  x.Disabilita_tutti_i_trigger__c=false;
          //    update x;
          List<Account> accList = TestDataFactory.createAccounts(1);
          for(Account a : accList){
            a.Societa_su_CTM__c = 'Warrant';
            //a.WRT_Documento_SharePoint__c = null;
            a.Censimento_Manuale__c = false;
            a.Data_Ultimo_Arricchimento__c = System.Today();
            a.Escludi_da_deduplica__c = true;
          }
            Test.startTest();
                insert accList;
              	// TestDataFactory.convertLeads(l[0]);
              Test.stopTest();
              
         }
            
      }

      @isTest static void testSharePointAccount2() {      
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert endp;

        Map<String,String> header = new Map<String,String>(); 
          User u = [Select Id FROM User WHERE UserName = 'test.User@testr.name'];
        //String token = jwt.issue();
        header.put('Content-Type','application/json');
       // header.put('Authorization', 'Bearer ' + token);
        HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"CreatedFolders":["https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Mandati","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/GDPR","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Scheda fornitore","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Gare appalto","https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144027TEST_SPx1803x050011X00000VPxC5QAL/CUSTOMER/Fusioni-Cessioni-Incorporazioni"]}', header);
        Test.setMock(HttpCalloutMock.class, mock);

        // Funzionalita__c x= new Funzionalita__c();
        // x.Bypass_Validation_Rules__c = true; 
        // x.Disabilita_tutti_i_trigger__c=true;
        // insert x;
        System.runAs(u){
          //      Funzionalita__c x= new Funzionalita__c();
          //    x.Disabilita_tutti_i_trigger__c=true;
        	//    insert x;
          //      List<Lead> l = TestDataFactory.createLeads(1);
          //     // List<Account> a = TestDataFactory.createAccounts(1);
          //     l[0].LastName = 'TestIntegration';
          //     l[0].Company = 'TestIntegration';
          //      l[0].Societa_di_riferimento__c = 'Warrant';
          //     l[0].Partiva_Iva__c = '73842983744';
          //         l[0].Codice_Fiscale__c= '73842983744';
          //       l[0].Basket_del_Lead__c = 'Mercato Potenziale';
          // insert l;
          //  x.Disabilita_tutti_i_trigger__c=false;
          //    update x;
          List<Account> accList = TestDataFactory.createAccounts(2);
          for(Account a : accList){
            a.Societa_su_CTM__c = 'Warrant';
            //a.WRT_Documento_SharePoint__c = null;
            a.Censimento_Manuale__c = false;
            a.Data_Ultimo_Arricchimento__c = System.Today();
            a.Escludi_da_deduplica__c = true;
          }
          List<Account> accList2 = TestDataFactory.createAccounts(1);
          for(Account a : accList2){
            a.Societa_su_CTM__c = 'Warrant';
            //a.WRT_Documento_SharePoint__c = null;
            a.Censimento_Manuale__c = false;
            a.Data_Ultimo_Arricchimento__c = System.Today();
            a.Escludi_da_deduplica__c = true;
          }
            Test.startTest();
                insert accList;
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true; 
                List<Database.SaveResult> sr = Database.insert(accList2, dml); 
              	// TestDataFactory.convertLeads(l[0]);
              Test.stopTest();
              
         }
            
      }
    
     @isTest static void testSharePointOpportunity() {
      EndpointServizi__c endp = new EndpointServizi__c();
      endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
      endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
      endp.WRT_SharePoint_Folders_Account__c = 'test';
      endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
      endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
      endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
      endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
      endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
      insert endp;

         Map<String,String> header = new Map<String,String>();
         header.put('Content-type', 'application/json');
          HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"CreatedFolders":["https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144024TEST_SPx1803x010011X00000U7ncCQAR/OPPORTUNITY/0061X00000A2VQLQA3"]}', header);
        Test.setMock(HttpCalloutMock.class, mock);
         List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity ];
             List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> oppschedList = new List<OpportunityLineItemSchedule>();
         
        Product2 prod = new Product2(Name = 'Laptop X200', 
            						 Family = 'Hardware',
                                     CanUseRevenueSchedule=true,
                                     Cluster_Tagetik__c = 'ADVISORY');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

        for (Opportunity opp: oppList){
            for(integer i =0; i<3;i++){
            	OpportunityLineItem item = new OpportunityLineItem(OpportunityId = opp.Id,
                                                               		Description = 'Test',
                                                              		Quantity= 5,
                                                                   TotalPrice = 34555,
                                                                   PricebookEntryId = standardPrice.Id
                                                                  );
                oppItemList.add(item);
            }
         }
           insert oppItemList;
           for (OpportunityLineItem item: oppItemList){
             	for(integer i =0; i<3;i++){
                	OpportunityLineItemSchedule sch = new OpportunityLineItemSchedule(OpportunityLineItemId = item.Id,
                                                                                      Type = 'Revenue',
                                                                                     Revenue =3750,
                                                                                     Description = 'test',
                                                                                     ScheduleDate = Date.today(), 
                                                                                      Fatturabile__c = true
                                                                                     );
                    oppschedList.add(sch);               
            	}                   
        	}
        insert oppschedList;     

         OpportunityStage opstgpre = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability < 50 LIMIT 1];
          OpportunityStage opstgpost = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability > 50 LIMIT 1];
         system.debug('opstgpre: '+opstgpre);
         oppList[0].StageName = opstgpost.ApiName;
       	 System.debug('opp: '+oppList[0]);
         Test.startTest();
         update oppList[0];
          Test.stopTest();
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
       	insert x; 
          oppList[0].StageName = opstgpre.ApiName;
       	 System.debug('opp: '+oppList[0]);
         update oppList[0];
          x.Disabilita_tutti_i_trigger__c=false;
       		update x; 
         
         
      }
    
    @isTest static void testInfoStoreOpportunity() {
        
      EndpointServizi__c endp = new EndpointServizi__c();
      endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
      endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
      endp.WRT_SharePoint_Folders_Account__c = 'test';
      endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
      endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
      endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
      endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
      endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
      insert endp;
        /* Map<String,String> header = new Map<String,String>();
         header.put('Content-type', 'application/json');
          HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"PayLoad":[{"attributes":{"type":"Opportunity","url":"/services/data/v48.0/sobjects/Opportunity/0061X00000A00HaQAJ"},"Id":"0061X00000A00HaQAJ","IsDeleted":false,"AccountId":"0011X00000U4rwwQAB","RecordTypeId":"0122X000000VB6cQAG","IsPrivate":false,"Name":"OPP SharePoint X10","StageName":"Short List","Amount":10000.00,"Probability":75,"ExpectedRevenue":7500.00,"TotalOpportunityQuantity":1.00,"CloseDate":"2020-03-31","IsClosed":false,"IsWon":false,"ForecastCategory":"BestCase","ForecastCategoryName":"Best Case","HasOpportunityLineItem":true,"Pricebook2Id":"01s2X000001I1eZQAS","OwnerId":"0052X000008voGQQAY","CreatedDate":"2020-03-11T15:32:03.000+0000","CreatedById":"0052X000008voGQQAY","LastModifiedDate":"2020-03-12T13:52:07.000+0000","LastModifiedById":"0052X000008voGQQAY","SystemModstamp":"2020-03-12T13:52:07.000+0000","FiscalQuarter":1,"FiscalYear":2020,"Fiscal":"2020 1","LastViewedDate":"2020-03-12T13:52:08.000+0000","LastReferencedDate":"2020-03-12T13:52:08.000+0000","HasOpenActivity":false,"HasOverdueTask":false,"Ammontare_pesato__c":7500.00,"Business_Consulting__c":false,"Tech_Consulting__c":false,"CicloAttivoAccountUser__c":"chiara.sberveglieri@warranthub.it.invalid","Numero_Prodotti__c":1,"Ammontare_Report__c":10000.00,"CicloAttivoRagioneSociale__c":"test SharePoint Account X10","CicloAttivoSalesforceUrl__c":"https://infocert.my.salesforce.com/0061X00000A00Ha","OpportunityNumber__c":"28340","TitolareDiversoDaAccount__c":false,"Presales_Support_Already_Requested__c":false,"Presales_Support_Group__c":"Supporto PRESALE","Presales_Support_Requested__c":false,"Riccorrente__c":false,"New_Business__c":false,"Anticipata_esecuzione__c":false,"Approvazione_Anticipata_Esecuzione__c":false,"Billing_Account_Owner__c":"chiara.sberveglieri@warranthub.it.invalid","Billing_Account__c":"test SharePoint Account X10","Sales_Perms__c":"0","Societariferimento_formula__c":"Warrant","TitolareApprovata__c":false,"Fattura_Partner__c":false,"Approvazione_sconto_prodotti__c":false,"Is_Locked__c":false,"Proposta_a_consumo__c":false,"Proposta_a_prepagato__c":false,"Sconto_massimo__c":50,"Servizi_a_consumo_BATCH__c":false,"Ammontare_non_scontato__c":12000.00,"Fee_Corrisposta__c":500.00,"Segnalazione_Partner__c":false,"Anno_di_competenza__c":"2020","WH_Business_Area__c":"EUROPEAN FUNDING DEVELOPMENT","Account_seguito_da__c":"WarrantHub","Codice_Unico_Tinexta_Account__c":"TXT-00144011","WRT_Lead_Converted_Opportunity__c":false,"Fatturazione_cliente_finale__c":false,"WRT_Offerta_Info_Store__c":"test","WRT_Opportuita_con_disdetta__c":false,"OpportunityLineItems":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"OpportunityLineItem","url":"/services/data/v48.0/sobjects/OpportunityLineItem/00k1X000005uPTlQAM"},"OpportunityId":"0061X00000A00HaQAJ","Id":"00k1X000005uPTlQAM","PricebookEntryId":"01u2X000013Q6KAQA0","Product2Id":"01t2X0000077HqWQAU","Name":"OPP SharePoint X10 ABI EUROPEO","Quantity":1.00,"Subtotal":10000.00,"TotalPrice":10000.00,"UnitPrice":10000.00,"ListPrice":0.00,"HasRevenueSchedule":false,"HasQuantitySchedule":false,"Description":"test","HasSchedule":false,"CanUseQuantitySchedule":false,"CanUseRevenueSchedule":false,"CreatedDate":"2020-03-11T15:33:37.000+0000","CreatedById":"0052X000008voGQQAY","LastModifiedDate":"2020-03-11T15:33:37.000+0000","LastModifiedById":"0052X000008voGQQAY","SystemModstamp":"2020-03-11T15:33:37.000+0000","IsDeleted":false,"ProductName__c":"ABI EUROPEO","CicloAttivoAccountUser__c":"chiara.sberveglieri@warranthub.it.invalid","OpportunityStage__c":"Short List","Presales_Support_Group__c":"Supporto PRESALE","Presales_Support_Requested__c":false,"Da_Approvare__c":false,"Discount_granted__c":0,"Discount_max_per_famiglia_prodotto__c":0,"Prezzo_concordato__c":10000.00,"Prezzo_non_scontato__c":12000.00,"Product_family__c":"GENERALE","Sconto__c":16.67,"Sconto_massimo_applicabile__c":0,"Sconto_massimo_per_importo_opportunit__c":40}]},"Owner":{"attributes":{"type":"User","url":"/services/data/v48.0/sobjects/User/0052X000008voGQQAY"},"Id":"0052X000008voGQQAY","Email":"chiara.sberveglieri@warranthub.it.invalid","Name":"Chiara Sberveglieri"},"Account":{"attributes":{"type":"Account","url":"/services/data/v48.0/sobjects/Account/0011X00000U4rwwQAB"},"Id":"0011X00000U4rwwQAB","Name":"test SharePoint Account X10","Codice_Unico_Tinexta__c":"TXT-00144011","WRT_NomeLegaleRappresentante__c":"SV","WRT_CognomeLegaleRappresentante__c":"VS","WRT_Documento_SharePoint__c":"https://warrantgroupsrl.sharepoint.com/sites/ArchivedOldRoot/sandbox/TXT00144011test SharePoint Account X100011X00000U4/CUSTOMER/"}}]}}', header);
        Test.setMock(HttpCalloutMock.class, mock);
      
        OpportunityStage opstgpost = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability > 50 LIMIT 1];
        oppList[0].StageName = opstgpost.ApiName;
        update oppList[0];    */
         Map<String,String> header = new Map<String,String>();
         header.put('Content-type', 'application/json');
          HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"success":true,"message":"Created","data":{"Opportunity":{"Numero_offerta_Infostore__c":10}}}', header);
        Test.setMock(HttpCalloutMock.class, mock);
         List<Opportunity> oppList = [SELECT Id,StageName, RecordTypeId FROM Opportunity ];
             List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> oppschedList = new List<OpportunityLineItemSchedule>();
         
        Product2 prod = new Product2(Name = 'Laptop X200', 
            						 Family = 'Hardware',
                                     CanUseRevenueSchedule=true,
                                     Cluster_Tagetik__c = 'ADVISORY');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

        for (Opportunity opp: oppList){
            for(integer i =0; i<3;i++){
            	OpportunityLineItem item = new OpportunityLineItem(OpportunityId = opp.Id,
                                                               		Description = 'Test',
                                                              		Quantity= 5,
                                                                   TotalPrice = 34555,
                                                                   PricebookEntryId = standardPrice.Id
                                                                  );
                oppItemList.add(item);
            }
         }
           insert oppItemList;
           for (OpportunityLineItem item: oppItemList){
             	for(integer i =0; i<3;i++){
                	OpportunityLineItemSchedule sch = new OpportunityLineItemSchedule(OpportunityLineItemId = item.Id,
                                                                                      Type = 'Revenue',
                                                                                     Revenue =3750,
                                                                                     Description = 'test',
                                                                                     ScheduleDate = Date.today(), 
                                                                                      Fatturabile__c = true
                                                                                     );
                    oppschedList.add(sch);               
            	}                   
        	}
        insert oppschedList;     

         OpportunityStage opstgpre = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability < 50 LIMIT 1];
          OpportunityStage opstgpost = [SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true AND DefaultProbability > 50 LIMIT 1];
         system.debug('opstgpre: '+opstgpre);
         oppList[0].StageName = opstgpost.ApiName;
         oppList[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Warrant').getRecordTypeId();
       	 System.debug('opp: '+oppList[0]);
        Test.startTest();
         update oppList[0];
         WRT_IntegrazioneController.opportunityIntegration(new Set<String>{oppList[0].Id});
        Test.stopTest();
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
       	insert x; 
          oppList[0].StageName = opstgpre.ApiName;
       	 System.debug('opp: '+oppList[0]);
         update oppList[0];
          x.Disabilita_tutti_i_trigger__c=false;
       		update x; 
         
        
    }

    //SM - 29/01/2021 New Test Methods
    
    @isTest
    static void opportunityIntegration_Exception(){
      EndpointServizi__c endp = new EndpointServizi__c();
      endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
      endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
      endp.WRT_SharePoint_Folders_Account__c = 'test';
      endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
      endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
      endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
      endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
      endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
      insert endp;

      Funzionalita__c x= new Funzionalita__c();
      x.Disabilita_tutti_i_trigger__c=false;
      x.Disabilita_Integrazione__c = false;
      insert x; 

      User u = [Select Id FROM User WHERE UserName = 'test.User@testr.name'];

      Test.startTest();
        System.runAs(u){
          // WRT_IntegrazioneController.opportunityIntegration_InfoStore(null);
          WRT_IntegrazioneController.opportunityIntegration_InfoStore(new List<Opportunity>{new Opportunity(Name = 'Test1'), new Opportunity(Name = 'Test2')});
        }
      Test.stopTest();
    }

    @isTest
    static void integrationInfostore_CPQ(){
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert endp;

      Funzionalita__c x= new Funzionalita__c();
      x.Disabilita_tutti_i_trigger__c=true;
      x.Disabilita_Integrazione__c = false;
      x.Disabilita_tutti_i_process_builder__c = true;
      x.Disabilita_tutti_i_workflow__c = true;
      insert x; 

      List<Account> accList = TestDataFactory.createAccounts(1);
      for(Account a : accList){
        a.Societa_su_CTM__c = 'Warrant';
        //a.WRT_Documento_SharePoint__c = 'https://test';
        a.Censimento_Manuale__c = false;
        a.Data_Ultimo_Arricchimento__c = System.Today();
        a.Escludi_da_deduplica__c = true;
      }
      insert accList;

      // Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
      // insert opp;

      SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = accList[0].Id, SBQQ__Primary__c = true/*, SBQQ__Opportunity2__c = opp.Id*/);
      insert quote;

      Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ', Cluster_Tagetik__c = 'ADVISORY');
      insert p;

      SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');
      // insert quoteline;

      SBQQ__QuoteLine__c quoteline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');

      List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>{quoteline,quoteline2};
      insert quotelines;

      Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

      Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id);
      insert fin;

      Condizioni__c conPadre = new Condizioni__c(Quote_Line__c = quoteline.Id);
      // insert conPadre;

      Condizioni__c conPadre2 = new Condizioni__c(Quote_Line__c = quoteline.Id);
      // insert conPadre

      List<Condizioni__c> condPadre = new List<Condizioni__c>{conPadre,conPadre2};
      insert condPadre;

      Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id, Condizione_WarrantCPQ__c = conPadre.Id);
      insert pag;

      Test.startTest();

        WRT_IntegrazioneController.opportunityIntegration_InfoStore_CPQ(quote.Id);
      Test.stopTest();
      
    }

    @isTest
    static void integrationInfostore_CPQ2(){
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert endp;

      Funzionalita__c x= new Funzionalita__c();
      x.Disabilita_tutti_i_trigger__c=true;
      x.Disabilita_Integrazione__c = false;
      x.Disabilita_tutti_i_process_builder__c = true;
      x.Disabilita_tutti_i_workflow__c = true;
      insert x; 

      List<Account> accList = TestDataFactory.createAccounts(1);
      for(Account a : accList){
        a.Societa_su_CTM__c = 'Warrant';
        //a.WRT_Documento_SharePoint__c = 'https://test';
        a.Censimento_Manuale__c = false;
        a.Data_Ultimo_Arricchimento__c = System.Today();
        a.Escludi_da_deduplica__c = true;
      }
      insert accList;

      // Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
      // insert opp;

      SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = accList[0].Id, SBQQ__Primary__c = true/*, SBQQ__Opportunity2__c = opp.Id*/);
      insert quote;

      Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ',Cluster_Tagetik__c = 'ADVISORY');
      insert p;

      SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');
      insert quoteline;

      Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id);
      insert fin;

      Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{ "data": { "Quote": { "Numero_offerta_Infostore__c": "test2", "WRT_Link_offerta_Infostore__c": "https://test2", "LineItems": [{ "Id": "'+quoteline.Id+'", "Numero_offerta_Infostore__c": "test2", "WRT_Link_offerta_Infostore__c": "https://test2"}]} }, "success": true, "message": "" }', new Map<String,String>()));

      Test.startTest();

        // Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id);
        // insert pag;

        WRT_IntegrazioneController.opportunityIntegration_InfoStore_CPQ(quote.Id);
      Test.stopTest();
      
    }

    @isTest
    static void integrationInfostore_CPQ3(){

      EndpointServizi__c endp = new EndpointServizi__c();
      endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
      endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
      endp.WRT_SharePoint_Folders_Account__c = 'test';
      endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
      endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
      endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
      endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
      endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
      insert endp;

      Funzionalita__c x= new Funzionalita__c();
      x.Disabilita_tutti_i_trigger__c=false;
      x.Disabilita_Integrazione__c = false;
      x.Disabilita_tutti_i_process_builder__c = true;
      x.Disabilita_tutti_i_workflow__c = true;
      insert x; 

      List<Account> accList = TestDataFactory.createAccounts(1);
      for(Account a : accList){
        a.Societa_su_CTM__c = 'Warrant';
        //a.WRT_Documento_SharePoint__c = 'https://test';
        a.Censimento_Manuale__c = false;
        a.Data_Ultimo_Arricchimento__c = System.Today();
        a.Escludi_da_deduplica__c = true;
      }
      insert accList;

      // Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
      // insert opp;

      SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = accList[0].Id, SBQQ__Primary__c = true/*, SBQQ__Opportunity2__c = opp.Id*/);
      insert quote;

      Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ',Cluster_Tagetik__c = 'ADVISORY');
      insert p;

      SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');
      insert quoteline;

      Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

      Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id);
      insert fin;

      Test.startTest();

        // Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id);
        // insert pag;

        WRT_IntegrazioneController.opportunityIntegration_InfoStore_CPQ(quote.Id);
      Test.stopTest();
      
    }

    @isTest
    static void integrationInfostore_CPQ3KO(){

      EndpointServizi__c endp = new EndpointServizi__c();
      endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
      endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
      endp.WRT_SharePoint_Folders_Account__c = 'test';
      endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
      endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
      endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
      endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
      endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
      insert endp;

      Funzionalita__c x= new Funzionalita__c();
      x.Disabilita_tutti_i_trigger__c=false;
      x.Disabilita_Integrazione__c = false;
      x.Disabilita_tutti_i_process_builder__c = true;
      x.Disabilita_tutti_i_workflow__c = true;
      insert x; 

      List<Account> accList = TestDataFactory.createAccounts(1);
      for(Account a : accList){
        a.Societa_su_CTM__c = 'Warrant';
        //a.WRT_Documento_SharePoint__c = 'https://test';
        a.Censimento_Manuale__c = false;
        a.Data_Ultimo_Arricchimento__c = System.Today();
        a.Escludi_da_deduplica__c = true;
      }
      insert accList;

      // Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
      // insert opp;

      SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = accList[0].Id, SBQQ__Primary__c = true/*, SBQQ__Opportunity2__c = opp.Id*/);
      insert quote;

      Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ',Cluster_Tagetik__c = 'ADVISORY');
      insert p;

      SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');
      insert quoteline;

      Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

      Finanziamenti__c fin = new Finanziamenti__c(Quote_Line__c = quoteline.Id);
      insert fin;
      
      Test.startTest();

        // Pagamenti__c pag = new Pagamenti__c(Quote_Line__c = quoteline.Id);
        // insert pag;

        WRT_IntegrazioneController.opportunityIntegration_InfoStore_CPQ(quote.Id);
      Test.stopTest();
      
    }

    @isTest
    static void QuoteSharepointTestKO(){
        // EndpointServizi__c endp = new EndpointServizi__c();
        // endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        // endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        // endp.WRT_SharePoint_Folders_Account__c = 'test';
        // endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        // endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        // endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        // endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        // endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        // insert endp;
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=false;
        x.Disabilita_Integrazione__c = false;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x; 

      List<Account> accList = TestDataFactory.createAccounts(1);
      for(Account a : accList){
        a.Societa_su_CTM__c = 'Warrant';
        //a.WRT_Documento_SharePoint__c = 'https://test';
        a.Censimento_Manuale__c = false;
        a.Data_Ultimo_Arricchimento__c = System.Today();
        a.Escludi_da_deduplica__c = true;
      }

      insert accList;

      // Opportunity opp = new Opportunity(Name = 'TestQuote', AccountId = acc.Id, CloseDate = System.Today().addDays(30), StageName = 'Proposta /Quotazione prezzi');
      // insert opp;

      // Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ2');
      // insert p;

      // SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');
      // insert quoteline;

      Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{ "access_token": "test", "token_type": "bearer" }', new Map<String,String>()));
      Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = accList[0].Id, SBQQ__Primary__c = true/*, SBQQ__Opportunity2__c = opp.Id*/);
        insert quote;

      Product2 p = new Product2(Name = 'TestIntegrazioneISCPQ',Cluster_Tagetik__c = 'ADVISORY');
      insert p;

      SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA');
      insert quoteline;

      SBQQ__QuoteLine__c quoteline2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = p.Id, Divisione_WarrantCPQ__c = 'FAA', Documenti_oppotunita_warranthub__c = 'https://test.test');
      insert quoteline2;

        // WRT_IntegrazioneController.QuoteIntegration_SharePoint(new Set<Id>{quote.Id});
      Test.stopTest();
    }

    @isTest
    static void testUrlEncode()
    {
      EndpointServizi__c endp = new EndpointServizi__c();
      endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
      endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
      endp.WRT_SharePoint_Folders_Account__c = 'test';
      endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
      endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
      endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
      endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
      endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
      insert endp;

      Test.startTest();
        WRT_IntegrazioneController.urlEncode(new Map<String,String>{'Key' => 'Value', 'Key1' => 'Value1'});
      Test.stopTest();
    }

    @isTest
    static void integrationInfostore_CPQ_WorkOrder()
    {
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        endp.WRT_URL_Integrazione_HdR__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/WorkOrder';
        insert endp;
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = false;
        x.Disabilita_tutti_i_process_builder__c = true;
        x.Disabilita_tutti_i_workflow__c = true;
        insert x;
        
        account[] accList = DataFactoryNew.create_Account();
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        workorder wok = DataFactoryNew.createWO(accList[0], opp[0]);
        
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{'+
                                                                '"WorkOrders" : [ {'+
                                                                    '"WorkOrderLineItems" : [ ],'+
                                                                        '"WRT_Link_WorkOrder_Infostore__c" : "https://infostore-test.warranthub.it/pages/offerte.php?xcodid=1655917418",'+
                                                                    '"ID_External_System__c" : 165565457418,'+
                                                                        '"Id" : "'+ wok.id+'"'+
                                                                            '} ]'+
                                                                '}', new Map<String,String>()));
        
        Test.startTest();
        
        WRT_IntegrazioneController.workorderIntegration(new list<id>{wok.id});
        InvioWorkOrderInfostoreController.InvioWorkOrderInfostore(wok.id);
        Test.stopTest();
        
    }
    @isTest
    static void integrationInfostore_ServiceAppointment()
    {
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRT_URL_Integrazione_HdR__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/WorkOrder';
        endp.WRT_URL_Integrazione_Teams__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/WorkOrder/Calendar';
        insert endp;
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = false;
        x.Disabilita_tutti_i_process_builder__c = true;
        x.Disabilita_tutti_i_workflow__c = true;
        insert x;
        
        WRT_Warrant_FSL_Settings__c sett = new WRT_Warrant_FSL_Settings__c();
        sett.SetupOwnerId = UserInfo.getOrganizationId();
        
        insert sett;
        
        account[] accList = DataFactoryNew.create_Account();
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        workorder wok = DataFactoryNew.createWO(accList[0], opp[0]);
        ServiceAppointment servApp = DataFactoryNew.createSA(wok);
        
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{'+
                                                                '"data" : {"test" : true},'+
                                                                '"message" : "OK - Undefined index: onlineMeetingUrl - /wwwdata2/html/webservices/api/salesforce/app/Http/Controllers/Warrant/WorkOrderController.php (526)",'+
                                                                '"success" : true'+
                                                                '}', new Map<String,String>()));
        
        Test.startTest();
        
        WRT_IntegrazioneController.serviceAppointmentIntegration(new list<ServiceAppointment>{servApp});
        Test.stopTest();
        
    }
}