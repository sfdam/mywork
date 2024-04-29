@istest
public class OnQuoteLineTriggerHandler_Test {
@isTest
    public static void OnQuoteLineTriggerHandler_TestMethod() {
    
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

        // Custom Setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c=true;
      	x.Bypass_Validation_Rules__c=true;
        insert x;

        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                     Cluster_Tagetik__c = 'ADVISORY',
                                    IsActive =true);
        Product2 pro2 = new product2 (name = 'Driver2',
                                      Cluster_Tagetik__c = 'ADVISORY',
                                     IsActive =true
                                     );
        
        insert pro ;
        insert pro2 ;

        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pro.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = pro.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        //inserimento product option
        SBQQ__ProductOption__c po = new SBQQ__ProductOption__c (SBQQ__OptionalSKU__c = pro2.id,
                                                                SBQQ__ConfiguredSKU__c= pro.id,
                                                               SBQQ__Number__c = 1);
        insert po;
        

        //Inserimento Quote 
        Account[] acc=TestDataFactory.createAccounts(1);
        insert acc;
        Contact cc = TestDataFactory.create_Contact();
        insert cc;
        
        User u = [SELECT Id FROM User WHERE Name = 'Daniele Catellani' LIMIT 1];
        system.debug('user id'+ u.id);
        
        Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
        ctm.user__c=u.id;
        ctm.Account__c=acc[0].id;
        ctm.Ruolo_Coverage_Team__c='Responsabile Account';
        insert ctm;
        
		SBQQ__Quote__c  q = new SBQQ__Quote__c  ();
        q.SBQQ__Primary__c=true;
        q.CloseDate__c=system.today()+100;
        q.Opportunity_Name__c= 'Test';
        q.StageName__c='Potenziali';
        q.WH_Business_Area__c='FAA';
        q.SBQQ__Account__c=acc[0].id;
        q.WRT_Agente3__c=u.id;
        q.OwnerId = u.id; 
        q.WRT_Template_Conga__c = 'CTM-000';
		insert q;
                                                               
		//Inserimento Business Area Finanzimenti
		
        Business_Area_Warrant__c fin = new  Business_Area_Warrant__c (name = 'Fin',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              SingoloProdotto_WarrantCPQ__c = pro.id ,
                                                               Importo_WarrantCPQ__c = null);
        
		insert fin;
         system.debug('EU inserimento BA Finanziamento'+ fin);
        
        Business_Area_Warrant__c fin2 = new  Business_Area_Warrant__c (name = 'Fin2',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              Importo_WarrantCPQ__c = 1000,
                                                              SingoloProdotto_WarrantCPQ__c = pro2.id  );
        insert fin2;
        
        
         system.debug('EU inserimento BA Finanziamento'+ fin2);
        
         Business_Area_Warrant__c fin3 = new  Business_Area_Warrant__c (name = 'Fin3',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              SingoloProdotto_WarrantCPQ__c = pro.id,
                                                              Importo_WarrantCPQ__c = 2000);
        
		insert fin3;
		system.debug('EU inserimento BA Finanziamento'+ fin3);
        
        //Inserimento Business Area Condizioni
        Business_Area_Warrant__c con = new  Business_Area_Warrant__c (name = 'Con',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              SingoloProdotto_WarrantCPQ__c = pro2.id);
		insert con;
		system.debug('EU inserimento BA Finanziamento'+ con);
        
                Business_Area_Warrant__c con2 = new  Business_Area_Warrant__c (name = 'Con2',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              SingoloProdotto_WarrantCPQ__c = pro.id);
		insert con2;
		system.debug('EU inserimento BA Finanziamento'+ con2);
        
                


   

        //Inserimento QuoteLine
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                                		SBQQ__Quote__c = q.id,
                                                 		SBQQ__ProductOption__c=po.id,
                                                        Divisione_WarrantCPQ__c='FAA',
                                                        Creato_con_processo__c = 'Rinnovo Automatico',
                                                        WRT_Modalita_pagamento__c = null
                                                    );
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro2.id,
                                                		SBQQ__Quote__c = q.id,
                                                         Divisione_WarrantCPQ__c='FAA',
                                                         WRT_Modalita_pagamento__c = null,
                                                         Creato_con_processo__c = 'Manuale',
                                                         Tipo_Mandato__c = 'Singolo'
                                                		);
		
        system.debug('EU inserimento QuoteLine'+ ql);
        
        id rid = ([SELECT Id FROM RecordType WHERE SobjectType = 'Logiche_Template__c' AND Name = 'Singolo' LIMIT 1]).id;
        
        Logiche_Template__c log = new Logiche_Template__c (Prodotto_Singolo__c = pro2.id,
                                                           Prodotto_Padre__c = pro2.id,
                                                           RecordTypeId = rid     );
        insert log;

        id rid2 = ([SELECT Id FROM RecordType WHERE SobjectType = 'Logiche_Template__c' AND Name = 'Rinnovo Automatico' LIMIT 1]).id;
        
        Logiche_Template__c log2 = new Logiche_Template__c (Prodotto_Singolo__c = pro.id,
                                                           Prodotto_Padre__c = pro.id,
                                                           RecordTypeId = rid2     );
        insert log2;

        
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{}', new Map<String,String>()));

                                 

        


        //Riabilito i trigger
        x.Disabilita_tutti_i_trigger__c=false;
        update x;

		test.startTest(); 
        SBQQ.TriggerControl.disable();   	
        insert ql ;
        insert ql2;

        x.Disabilita_tutti_i_trigger__c=true;
        update x;
        Approvazioni__c app = new Approvazioni__c (
            Approval_Step__c= 'In attesa di approvazione',
            Quote_Line__c = ql2.id,
            Quote__c = q.id
        );
        insert app;

        Condizioni__c conTest = new Condizioni__c(Quote_Line__c=ql2.Id,
                                                 WRT_Update_da_Rinnovo__c = true);
        insert conTest;

        Pagamenti__c pagTest = new Pagamenti__c(Quote_Line__c=ql2.Id,
                                                WRT_Update_da_Rinnovo__c=false,
                                                Condizione_WarrantCPQ__c=conTest.Id,
                                                Tipo_pagamento_WarrantCPQ__c='1131471362',
                                                SwitchTrigger__c=false);
        insert pagTest;
        
        system.debug('pagTest ' + pagTest );

        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        


        ql2.Stato_pagamento_dellopportunita_vinta__c = 'Pagato totalmente';
       //ql2.WRT_Referente_Tecnico__c = cc.Id;
       //ql2.Numero_Condizioni__c = 1;
       // ql2.Numero_Finanziamenti__c = 1;
       // ql2.Numero_Pagamenti__c = 1;
        ql2.WRT_StatoFatturazioneOpportunita__c = 'Fatturata completamente';
       // ql2.WRT_Modalita_pagamento__c = '1190732656';
       // ql2.Tipo_Mandato__c ='Annuale senza fine';
       // ql2.Valore_del_pagamento_in_euro_Prodotto__c = 20000;
       // ql2.ApprovalStatus__c='Approved';
       // ql2.Richiesta_Modifica_Legale__c='OK';


         update ql2 ; 
        
        system.debug('EU aggiornamento QuoteLine'+ ql);
        /* System.runAs(u){
            database.DeleteResult dr = database.delete(ql, false);        
            system.assert(dr.isSuccess()==false);
            system.assert(dr.getErrors()[0].getMessage()=='Non è possibile cancellare una QuoteLine che contiene Finanziamenti, Condizioni e Pagamenti');
        }*/
        SBQQ.TriggerControl.enable();
        test.stopTest (); 
    }
}