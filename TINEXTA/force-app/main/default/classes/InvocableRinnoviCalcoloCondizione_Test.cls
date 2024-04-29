@isTest
public class InvocableRinnoviCalcoloCondizione_Test {

    @isTest static void testSuccess(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
       
        
        
        
        
        List<InvocableRinnoviCalcoloCondizione.ActionRequest> arList = new List<InvocableRinnoviCalcoloCondizione.ActionRequest>();
        InvocableRinnoviCalcoloCondizione.ActionRequest arTest = new InvocableRinnoviCalcoloCondizione.ActionRequest();
        
        
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                             SBQQ__Primary__c = true);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine,
        Divisione_WarrantCPQ__c = 'FAA DRIVER');

        
        
        Insert NQuoteLine;
        
        
        
        
        
       
        
 
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                  Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000
                                                     );
        insert f;
        
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
     
        insert c;
            
        
        
      
        
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                               Percentuale_WarrantCPQ__c = 10 );
        insert o;
        

         condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
        insert c2;
        
        
         condizioni__c c3 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'VARIABILE',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000,
                                              Valore_max_WarrantCPQ__c = 10);
        insert c3;
        
        
        
        
 
        
     
        
        arTest.idqlinenuova = NQuoteLine.id ;
        
        
        arList.add(arTest);
        
        
    
          List<String> res = new List<String> ();
        
        
        
        x.Disabilita_tutti_i_process_builder__c = false ;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
     
    res = InvocableRinnoviCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
        
        
        
        
        
        
        
        
        
    }
    
    
     @isTest static void testSuccess2(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
         x.Disabilita_tutti_i_process_builder__c = true;

        insert x;
        
       
        
        
        
        
        List<InvocableRinnoviCalcoloCondizione.ActionRequest> arList = new List<InvocableRinnoviCalcoloCondizione.ActionRequest>();
        InvocableRinnoviCalcoloCondizione.ActionRequest arTest = new InvocableRinnoviCalcoloCondizione.ActionRequest();
        
        
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                                   SBQQ__Primary__c = true);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine,
        Divisione_WarrantCPQ__c = 'FAA DRIVER');

        
        
        Insert NQuoteLine;
        
        
        
        
        
       
        
 
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                  Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000
                                                     );
        insert f;
        
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
     
        insert c;
            
        
        
      
        
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                Percentuale_WarrantCPQ__c = 10);
        insert o;
        

         condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
        insert c2;
        
        
      
        
        
        
        
        condizioni__c c4 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'VARIABILE',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000,
                                            Min_garantito_WarrantCPQ__c = 3500);
        insert c4;
        
        
     
        
        arTest.idqlinenuova = NQuoteLine.id ;
        
        
        arList.add(arTest);
        
        
    
          List<String> res = new List<String> ();
        
        
        
         x.Disabilita_tutti_i_process_builder__c = false ;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
     
 //   res = InvocableRinnoviCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
}
    
    
    
        @isTest static void testSuccess3(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;

        insert x;
        
       
        
        
        
        
        List<InvocableRinnoviCalcoloCondizione.ActionRequest> arList = new List<InvocableRinnoviCalcoloCondizione.ActionRequest>();
        InvocableRinnoviCalcoloCondizione.ActionRequest arTest = new InvocableRinnoviCalcoloCondizione.ActionRequest();
        
        
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                                    SBQQ__Primary__c = true);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine,
                                     Divisione_WarrantCPQ__c = 'FAA DRIVER');

        
        
        Insert NQuoteLine;
        
        
        
        
        
       
        
 
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                  Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000
                                                     );
        insert f;
        
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
     
        insert c;
            
        
        
      
        
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                Percentuale_WarrantCPQ__c = 10);
        insert o;
        

         condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
        insert c2;
        
        
      
        
        
        
        
        condizioni__c c4 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'VARIABILE',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 200,
                                            Limite_WarrantCPQ__c = 300,
                                              Percentuale_WarrantCPQ__c = 10
                                             );
        insert c4;
        
        
     
        
        arTest.idqlinenuova = NQuoteLine.id ;
        
        
        arList.add(arTest);
        
        
    
          List<String> res = new List<String> ();
        
        
        
         x.Disabilita_tutti_i_process_builder__c = false ;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
     
    res = InvocableRinnoviCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
}
    
    
    
    
       @isTest static void testSuccess4(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
           x.Disabilita_tutti_i_process_builder__c = true;

        insert x;
        
       
        
        
        
        
        List<InvocableRinnoviCalcoloCondizione.ActionRequest> arList = new List<InvocableRinnoviCalcoloCondizione.ActionRequest>();
        InvocableRinnoviCalcoloCondizione.ActionRequest arTest = new InvocableRinnoviCalcoloCondizione.ActionRequest();
        
        
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                                       SBQQ__Primary__c = true);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine,
                                      Divisione_WarrantCPQ__c = 'FAA DRIVER');

        
        
        Insert NQuoteLine;
        
        
        
        
        
       
        
 
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                  Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000
                                                     );
        insert f;
        
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
     
        insert c;
            
        
        
      
        
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id,
                                          Percentuale_WarrantCPQ__c = 10);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                Percentuale_WarrantCPQ__c = 10);
        insert o;
        

         condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
        insert c2;
        
        
      
        
        
        
        
        condizioni__c c4 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'VARIABILE',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000,
                                           
                                              Percentuale_WarrantCPQ__c = 10
                                             );
        insert c4;
        
        
     
        
        arTest.idqlinenuova = NQuoteLine.id ;
        
        
        arList.add(arTest);
        
        
    
          List<String> res = new List<String> ();
        
        
        
        
        x.Disabilita_tutti_i_trigger__c=false;
            x.Disabilita_tutti_i_process_builder__c = false ;
        update x;
        
        Test.startTest();
     
    res = InvocableRinnoviCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
}
    
    
    @isTest static void testSuccess5(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;

        insert x;
        
       
        
        
        
        
        List<InvocableRinnoviCalcoloCondizione.ActionRequest> arList = new List<InvocableRinnoviCalcoloCondizione.ActionRequest>();
        InvocableRinnoviCalcoloCondizione.ActionRequest arTest = new InvocableRinnoviCalcoloCondizione.ActionRequest();
        
        
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                                   SBQQ__Primary__c = true);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine,
                                       Divisione_WarrantCPQ__c = 'FAA DRIVER');

        
        
        Insert NQuoteLine;
        
        
        
        
        
       
        
 
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                  Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000
                                                     );
        insert f;
        
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
     
        insert c;
            
        
        
      
        
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id,
                                          Percentuale_WarrantCPQ__c = 10);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                Percentuale_WarrantCPQ__c = 10);
        insert o;
        

         condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
        insert c2;
        
        
      
        
        
        
        
        condizioni__c c4 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'VARIABILE',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 0,
                                            Limite_WarrantCPQ__c = 200,
                                            Percentuale_WarrantCPQ__c = 10
                                             );
        insert c4;
        
        
     
        
        arTest.idqlinenuova = NQuoteLine.id ;
        
        
        arList.add(arTest);
        
        
    
          List<String> res = new List<String> ();
        
        
        
         x.Disabilita_tutti_i_process_builder__c = false ;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
     
    res = InvocableRinnoviCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
}
    
    
       @isTest static void testSuccess6(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
           x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
       
        
        
        
        
        List<InvocableRinnoviCalcoloCondizione.ActionRequest> arList = new List<InvocableRinnoviCalcoloCondizione.ActionRequest>();
        InvocableRinnoviCalcoloCondizione.ActionRequest arTest = new InvocableRinnoviCalcoloCondizione.ActionRequest();
        
        
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                                          SBQQ__Primary__c = true);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine,
                               Divisione_WarrantCPQ__c = 'FAA DRIVER');

        
        
        Insert NQuoteLine;
        
        
        
        
        
       
        
 
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                  Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000
                                                     );
        insert f;
        
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                            
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
     
        insert c;
            
        
        
      
        
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                Tipo_WarrantCPQ__c = 'Fisso',
                                                                 	Minimo_WarrantCPQ__c = 100,
                                                                 Massimo_WarrantCPQ__c = 1000,
                                                                 Percentuale_WarrantCPQ__c = 10,
                                                                 Fisso_WarrantCPQ__c = 1000);
        insert o;
        

         condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                            
                                            Tipo_WarrantCPQ__c = 'FISSO',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 1000);
        insert c2;
        
        
      
        
        
        
        
        condizioni__c c4 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Tipo_WarrantCPQ__c = 'VARIABILE',
                                            Minimo_WarrantCPQ__c= 100,
                                            Massimo_WarrantCPQ__c= 0,
                                            Limite_WarrantCPQ__c = 200,
                                            Percentuale_WarrantCPQ__c = 10
                                             );
        insert c4;
           
        condizione_opzionale__c o2 = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c4.id,
                                                                 Tipo_WarrantCPQ__c = 'Fisso',
                                                                 	Minimo_WarrantCPQ__c = 100,
                                                                 Massimo_WarrantCPQ__c = 1000,
                                                                 Percentuale_WarrantCPQ__c = 10,
                                                                 Fisso_WarrantCPQ__c = 1000
                                                                 );
        insert o2;

        
           
            condizioni__c c5 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                           
                                           Fisso_WarrantCPQ__c = 1000
                                           
                                            
                                             );
        insert c5;
           
           
               condizioni__c c6 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Percentuale_WarrantCPQ__c = 10
                                         
                                           
                                            
                                             );
        insert c6;
           
            condizioni__c c7 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Percentuale_WarrantCPQ__c = 10,
                                         Minimo_WarrantCPQ__c = 100
                                           
                                            
                                             );
        insert c7;
           
           
           
            condizioni__c c8 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Fisso_WarrantCPQ__c = 1000,
                                         Minimo_WarrantCPQ__c = 100
                                           
                                            
                                             );
        insert c8;
           
     
        
        arTest.idqlinenuova = NQuoteLine.id ;
        
        
        arList.add(arTest);
        
        
    
          List<String> res = new List<String> ();
        
        
        
         x.Disabilita_tutti_i_process_builder__c = false ;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
     
    res = InvocableRinnoviCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
} 
    
    
    
}