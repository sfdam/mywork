@isTest
public class AsyncBUCopy_Test {
    
    @isTest static void testFinanziamenti() {
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        insert x;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                     IsActive =true,
                                    cluster_tagetik__c = 'ADVISORY');
        Product2 pro2 = new product2 (name = 'Driver2',
                                      IsActive =true,
                                     cluster_tagetik__c = 'ADVISORY');
        
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
        
        List <Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant'; 
        Insert acc;
        
        Test.startTest();
        
        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].Id;
        List<SBQQ__QuoteLine__c>Listaquote= new List <SBQQ__QuoteLine__c>();
        List<Business_Area_Warrant__c>ListaFin=new List <Business_Area_Warrant__c>();
        List<Business_Area_Warrant__c>ListaCon=new List <Business_Area_Warrant__c>();
        
        
        SBQQ__Quote__c Quote = new SBQQ__Quote__c(
            SBQQ__Account__c=acc[0].Id,
            Opportunity_Name__c= 'Test',
            StageName__c= 'Potenziali',
            SBQQ__Primary__c=true,
            CloseDate__c=system.today() + 100,
            WH_Business_Area__c='FAA DRIVER',
            // ForecastCategoryName__c='Pipeline',
            RecordTypeId=rid
        );
        
        insert Quote;
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        //Inserimento Business Area Finanzimenti
        
        Business_Area_Warrant__c fin = new  Business_Area_Warrant__c (name = 'Fin',
                                                                      RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                                      ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                      SingoloProdotto_WarrantCPQ__c = pro.id ,
                                                                      Importo_WarrantCPQ__c = null);
        

        ListaFin.add(fin);
   
        
        Business_Area_Warrant__c fin2 = new  Business_Area_Warrant__c (name = 'Fin2',
                                                                       RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                                       ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                       Importo_WarrantCPQ__c = 1000,
                                                                       SingoloProdotto_WarrantCPQ__c = pro2.id  );
  
        
        
        ListaFin.add(fin2);
  
        
        Business_Area_Warrant__c con = new Business_Area_Warrant__c (Name = 'con',
                                                                     RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),
                                                                     ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                     SingoloProdotto_WarrantCPQ__c = pro.id,
                                                                     Fin_Associato__c=fin.id
                                                                    );      
        insert con;
        
        
        ListaCon.add(con);
        
        

        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro2.id,
                                                         SBQQ__Quote__c = Quote.id,
                                                         Divisione_WarrantCPQ__c='FAA'
                                                         
                                                        );
        
        system.debug('EU inserimento QuoteLine'+ ql2);
        
        Listaquote.add(ql2);
        
        
        insert Listaquote;
        insert Listafin;
        
        Set<Id> testQuoteIdSet = Utilities.getIdSet(Listaquote, 'Id');
        Set<Id> finSet=Utilities.getIdSet(ListaFin,'Id');
		Set<Id> ConSet=Utilities.getIdSet(ListaCon,'Id');
        Set<Id> idfin = new Set <Id> ();
        Set<Id> idcon = new Set <Id> ();
        Set<Id> Pag = new Set<Id>();
        String s='fin';
        
       AsyncBUCopy executeQueueable = new AsyncBUCopy(finSet,testQuoteIdSet,s,idfin,idcon,pag);
       Id jobId = System.enqueueJob(executeQueueable);
        
        Test.stopTest();
    }
    
            @isTest static void testCondizioni() {
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        insert x;
             
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true,
                                    cluster_tagetik__c = 'ADVISORY');
        Product2 pro2 = new product2 (name = 'Driver2',
                                     IsActive =true,
                                     cluster_tagetik__c = 'ADVISORY');
        
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

        List <Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant'; 
        Insert acc;
        
        Test.startTest();
        
       Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].Id;
       List<SBQQ__QuoteLine__c>Listaquote= new List <SBQQ__QuoteLine__c>();
       List<finanziamenti__c>ListaFin=new List <finanziamenti__c>();
        List<Business_Area_Warrant__c>ListaCon=new List <Business_Area_Warrant__c>();
        
        SBQQ__Quote__c Quote = new SBQQ__Quote__c(
                SBQQ__Account__c=acc[0].Id,
                Opportunity_Name__c= 'Test',
                StageName__c= 'Potenziali',
            	SBQQ__Primary__c=true,
                CloseDate__c=system.today() + 100,
                WH_Business_Area__c='FAA DRIVER',
               // ForecastCategoryName__c='Pipeline',
                RecordTypeId=rid
        );
        insert Quote;

        		//Inserimento Business Area Finanzimenti
		
        Business_Area_Warrant__c fin = new  Business_Area_Warrant__c (name = 'Fin',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              SingoloProdotto_WarrantCPQ__c = pro.id ,
                                                               Importo_WarrantCPQ__c = null);
        






        Business_Area_Warrant__c con = new Business_Area_Warrant__c (Name = 'con',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro.id,
                                                             Fin_Associato__c=fin.id
                                                                  );      
	

      
        ListaCon.add(con);
                

      
      

        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                                		SBQQ__Quote__c = Quote.id,
                                                         Divisione_WarrantCPQ__c='FAA'
                                                		);
                
        Listaquote.add(ql2);
         insert Listaquote; 
                
        finanziamenti__c f = new finanziamenti__c (Formula_Semaforo_Trigger__c=true,
                                                   Escludi_da_template__c=false,
                                                   Quote_Line__c = ql2.id,
                                                  Chiave_Esterna__c=fin.id);
		
        system.debug('EU inserimento QuoteLine'+ ql2);
        
        
        ListaFin.add(f);

       
        insert ListaFin;
        insert ListaCon;
                
 
                
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
                
        
        
        Set<Id> testQuoteIdSet = Utilities.getIdSet(Listaquote, 'Id');
           system.debug('EU QuoteLine' + testQuoteIdSet);
        Set<Id> finSet=Utilities.getIdSet(ListaFin,'Id');
           system.debug('EU fin' + finSet);
        Set<Id> ConSet=Utilities.getIdSet(ListaCon,'Id');
           system.debug('EU Con' + ConSet);
        Set<Id> idcon = new Set <Id> ();
        Set<Id> Pag = new Set<Id>();
        String s='cond';

        AsyncBUCopy executeQueueable = new AsyncBUCopy(ConSet,testQuoteIdSet,s,finSet,idcon,pag);
        Id jobId = System.enqueueJob(executeQueueable);
        //System.debug('Test Job ID: ' + jobId);
        //System.assertEquals('', '');
        Test.stopTest();
    }

                @isTest static void testOpzionale() {
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        insert x;
             
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true,
                                    cluster_tagetik__c = 'ADVISORY');
        Product2 pro2 = new product2 (name = 'Driver2',
                                     IsActive =true,
                                     cluster_tagetik__c = 'ADVISORY');
        
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

        List <Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant'; 
        Insert acc;
        
        Test.startTest();
        
       Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].Id;
       List<SBQQ__QuoteLine__c>Listaquote= new List <SBQQ__QuoteLine__c>();
       List<finanziamenti__c>ListaFin=new List <finanziamenti__c>();
       List<condizioni__c>ListaCon=new List <condizioni__c>();
       List<Business_Area_Warrant__c>Opzionali=new List <Business_Area_Warrant__c>();
       List<Business_Area_Warrant__c>Pagamenti=new List <Business_Area_Warrant__c>();
        
        SBQQ__Quote__c Quote = new SBQQ__Quote__c(
                SBQQ__Account__c=acc[0].Id,
                Opportunity_Name__c= 'Test',
                StageName__c= 'Potenziali',
            	SBQQ__Primary__c=true,
                CloseDate__c=system.today() + 100,
                WH_Business_Area__c='FAA DRIVER',
               // ForecastCategoryName__c='Pipeline',
                RecordTypeId=rid
        );
        insert Quote;

        		//Inserimento Business Area Finanzimenti
		
        Business_Area_Warrant__c fin = new  Business_Area_Warrant__c (name = 'Fin',
                                                              RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(),      
                                                              ProdottoBundle_WarrantCPQ__c = pro.id,
                                                              SingoloProdotto_WarrantCPQ__c = pro.id ,
                                                               Importo_WarrantCPQ__c = 1000);
        



        insert fin;


        Business_Area_Warrant__c con = new Business_Area_Warrant__c (Name = 'con',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro.id,
                                                             Fin_Associato__c=fin.id
                                                                  );      
	

      
        insert con;

        Business_Area_Warrant__c ConO = new Business_Area_Warrant__c (Name = 'ConO',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId(),
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro.id,
                                                             Cond_Associata__c=con.id
                                                             );      
        Opzionali.add(ConO);

              
        Business_Area_Warrant__c pag2 = new Business_Area_Warrant__c (Name = 'pag2',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId(),
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro.id,
                                                             Cond_Associata__c=con.id
                                                           );      
		Pagamenti.add(pag2);
      
      

        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                                		SBQQ__Quote__c = Quote.id,
                                                         Divisione_WarrantCPQ__c='FAA'
                                                		);
                
        Listaquote.add(ql2);
         insert Listaquote; 
                
        finanziamenti__c f = new finanziamenti__c (Formula_Semaforo_Trigger__c=true,
                                                   Escludi_da_template__c=false,
                                                   Quote_Line__c = ql2.id,
                                                  Chiave_Esterna__c=fin.id);
		
        system.debug('EU inserimento QuoteLine'+ ql2);
        
        
        ListaFin.add(f);

        condizioni__c c = new condizioni__c (Escludi_da_template__c=false,
                                             Formula_Semaforo_Trigger__c=true,
                                             Quote_Line__c = ql2.id ,
                                              Chiave_Esterna__c=con.id
                                             ); 
        ListaCon.add(c);

        
       
        insert ListaFin;
        insert ListaCon;
        insert Opzionali;
        insert Pagamenti;
                
 
                
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
                
        
        
        Set<Id> testQuoteIdSet = Utilities.getIdSet(Listaquote, 'Id');
           system.debug('EU QuoteLine' + testQuoteIdSet);
        Set<Id> finSet=Utilities.getIdSet(ListaFin,'Id');
           system.debug('EU fin' + finSet);
        Set<Id> ConSet=Utilities.getIdSet(ListaCon,'Id');
           system.debug('EU Con' + ConSet);
        Set<Id> Opz = Utilities.getIdSet(Opzionali,'Id');
           system.debug('EU Opzionali' + Opz);
        Set<Id> Pag = Utilities.getIdSet(Pagamenti,'Id');
           system.debug('EU Pagamenti' + Pag);
        String s='op';

        AsyncBUCopy executeQueueable = new AsyncBUCopy(Opz,testQuoteIdSet,s,finSet,ConSet,Pag);
        Id jobId = System.enqueueJob(executeQueueable);
        //System.debug('Test Job ID: ' + jobId);
        //System.assertEquals('', '');
        Test.stopTest();
    }
    
    
    
}