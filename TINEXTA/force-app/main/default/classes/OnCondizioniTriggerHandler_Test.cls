@istest
public class OnCondizioniTriggerHandler_Test {
    @istest
    public static void OnCondizioniTriggerHandler_TestMethod() {
        
        //custom setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Bypass_Validation_Rules__c=true;
        insert x;
        
        EndpointServizi__c e = new EndpointServizi__c();
        e.WRT_Elimina_Bulk_Pricing__c='https://salesforce-test.warranthub.it/api/v1/Wh/Quote/Pricing/DeleteBulk';
        insert e;
        //custom setting
        
        //Quote
        Account[] acc=TestDataFactory.createAccounts(1);
        insert acc;
        
        SBQQ__Quote__c  q = new SBQQ__Quote__c  ();
        q.SBQQ__Primary__c=true;
        q.CloseDate__c=system.today()+100;
        q.Opportunity_Name__c= 'Test';
        q.StageName__c='Potenziali';
        q.WH_Business_Area__c='FAA';
        q.SBQQ__Account__c=acc[0].id;
        insert q;
        
        //Inserimento prodotto e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                     IsActive =true);
        Product2 pro2 = new product2 (name = 'Driver2',
                                      IsActive =true);
        
        insert pro;
        insert pro2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId,
                                                          Product2Id = pro.Id,
                                                          UnitPrice = 10000,
                                                          IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, 
                                                        Product2Id = pro.Id,
                                                        UnitPrice = 12000,
                                                        IsActive = true);
        insert customPrice;
        
        //inserimento product option
        SBQQ__ProductOption__c po = new SBQQ__ProductOption__c (SBQQ__OptionalSKU__c = pro2.id,
                                                                SBQQ__ConfiguredSKU__c= pro.id,
                                                                SBQQ__Number__c = 1);
        insert po;
        
        //Inserimento Business Area per pagamenti e condizioni opzionali
        Business_Area_Warrant__c pag = new Business_Area_Warrant__c (Name = 'pag',
                                                                     RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId(),
                                                                     ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                     SingoloProdotto_WarrantCPQ__c = pro2.id);      
        insert pag;
        
        Business_Area_Warrant__c pag2 = new Business_Area_Warrant__c (Name = 'pag2',
                                                                      RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId(),
                                                                      ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                      SingoloProdotto_WarrantCPQ__c = pro.id);      
        insert pag2;
        
        Business_Area_Warrant__c ConO = new Business_Area_Warrant__c (Name = 'ConO',
                                                                      RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId(),
                                                                      ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                      SingoloProdotto_WarrantCPQ__c = pro.id);      
        insert ConO;
        
        Business_Area_Warrant__c ConO2 = new Business_Area_Warrant__c (Name = 'ConO2',
                                                                       RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId(),
                                                                       ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                       SingoloProdotto_WarrantCPQ__c = pro2.id);      
        insert ConO2;
        
        Business_Area_Warrant__c Con = new Business_Area_Warrant__c (Name='Con',
                                                                     RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(), 
                                                                     ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                     SingoloProdotto_WarrantCPQ__c = pro.id);
        insert Con;
        
        SBQQ__ProductOption__c prodOpt = new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c=pro.Id,
                                                                    SBQQ__OptionalSKU__c=pro.Id,
                                                                    SBQQ__Number__c=12345);
        insert prodOpt;
        
        //Inserimento QuoteLine
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                                        SBQQ__Quote__c = q.id,
                                                        Divisione_WarrantCPQ__c='FAA',
                                                        SBQQ__ProductOption__c=po.id);
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro2.id,
                                                         Divisione_WarrantCPQ__c='FAA',
                                                         SBQQ__Quote__c = q.id);
        
        SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                                         SBQQ__Quote__c = q.id,
                                                         Divisione_WarrantCPQ__c='FAA',
                                                         SBQQ__ProductOption__c=prodOpt.id);
        insert ql;  
        insert ql2;
        insert ql3;
        
        //Condizioni per update
        List<Condizioni__c> listCon = new List<Condizioni__c>();        
        condizioni__c c00 = new condizioni__c (Escludi_da_template__c=false,
                                               Formula_Semaforo_Trigger__c=false,
                                               Quote_Line__c = ql.id,
                                               Fisso_WarrantCPQ__c=3,
                                               Soglia_AM_KAM_Fisso__c=1,
                                               Soglia_Commerciale_Fisso__c=1,
                                               Soglia_Dir_Comm_Fisso__c=1,
                                               Soglia_DM_Fisso__c=1);
        listCon.add(c00);
        
        Approvazioni__c app = new Approvazioni__c(Approval_Step__c='In attesa di approvazione',
                                                  Condizione__c=c00.Id,
                                                  Soglia_AM_KAM_Superata__c=true,
                                                  Soglia_Commerciale_Superata__c=true,
                                                  Soglia_Dir_Comm_Superata__c=true,
                                                  Soglia_DM_Superata__c=true,
                                                  Quote__c=q.Id);        
        
        condizioni__c c01 = new condizioni__c (Escludi_da_template__c=false,
                                               Formula_Semaforo_Trigger__c=false,
                                               Quote_Line__c = ql.id,
                                               Fisso_WarrantCPQ__c=1);
        listCon.add(c01);
        
        condizioni__c c02 = new condizioni__c (Escludi_da_template__c=false,
                                               Formula_Semaforo_Trigger__c=false,
                                               Quote_Line__c = ql.id,
                                               Fisso_WarrantCPQ__c=1);
        listCon.add(c02);
        
        condizioni__c c03 = new condizioni__c (Escludi_da_template__c=false,
                                               Formula_Semaforo_Trigger__c=false,
                                               Quote_Line__c = ql.id,
                                               Fisso_WarrantCPQ__c=1);
        listCon.add(c03);
        
        condizioni__c c04 = new condizioni__c (Escludi_da_template__c=false,
                                               Formula_Semaforo_Trigger__c=false,
                                               Quote_Line__c = ql.id,
                                               Fisso_WarrantCPQ__c=1);
        listCon.add(c04);
        
        condizioni__c c05 = new condizioni__c (Escludi_da_template__c=false,
                                               Formula_Semaforo_Trigger__c=false,
                                               Quote_Line__c = ql.id,
                                               Fisso_WarrantCPQ__c=1,
                                               WRT_Update_da_Rinnovo__c=false,
                                               Controllo_Approvazioni_in_attesa__c=false);
        listCon.add(c05);        
        
        Test.startTest();        
        insert listCon;
        insert app;
        
        //Riabilitazione trigger
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        //Riabilitazione trigger
        
        //Inserimento Condizioni      
        condizioni__c c = new condizioni__c (Escludi_da_template__c=false,
                                             Formula_Semaforo_Trigger__c=true,
                                             Quote_Line__c = ql2.id);    
        
        condizioni__c c2 = new condizioni__c (Escludi_da_template__c=false,
                                              Formula_Semaforo_Trigger__c=false,
                                              Quote_Line__c = ql.id);
        
        condizioni__c c3 = new condizioni__c (Escludi_da_template__c=false,
                                              Formula_Semaforo_Trigger__c=false,
                                              Quote_Line__c = ql3.id);
        insert c;
        insert c2;
        insert c3;
        update c2;
        delete c2;
        OnCondizioniTriggerHandler.eliminaCondizioniRelated(c.id);
        
        List<Condizioni__c> listConToUp = new List<Condizioni__c>();
        c00.Fisso_WarrantCPQ__c=4;
        listConToUp.add(c00);
        
        c01.Fisso_WarrantCPQ__c=2;
        c01.Soglia_Commerciale_Fisso__c=3;
        listConToUp.add(c01);
        
        c02.Fisso_WarrantCPQ__c=2;
        c02.Soglia_DM_Fisso__c=3;
        listConToUp.add(c02);
        
        c03.Fisso_WarrantCPQ__c=2;
        c03.Soglia_AM_KAM_Fisso__c=3;
        listConToUp.add(c03);
        
        c04.Fisso_WarrantCPQ__c=2;
        c04.Soglia_Dir_Comm_Fisso__c=3;
        listConToUp.add(c04);
        
        c05.Fisso_WarrantCPQ__c=2;
        listConToUp.add(c05);
        
        update listConToUp;
        Test.stopTest();
        
    }
}