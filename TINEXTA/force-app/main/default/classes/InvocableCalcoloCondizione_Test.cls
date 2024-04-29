@istest
public class InvocableCalcoloCondizione_Test {
      @isTest static void testSuccess(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
          List<InvocableCalcoloCondizione.ActionRequest> arList = new List<InvocableCalcoloCondizione.ActionRequest>();
        InvocableCalcoloCondizione.ActionRequest arTest = new InvocableCalcoloCondizione.ActionRequest();
          
          
           Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c='Warrant';
        
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
                                                    Stima_WarrantCPQ__c = 1000);
        insert f;
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                            Percentuale_WarrantCPQ__c = 10);
        insert c;
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                 Tipo_WarrantCPQ__c = 'Fisso',
                                                                 	Minimo_WarrantCPQ__c = 100,
                                                                 Massimo_WarrantCPQ__c = 1000,
                                                                 Percentuale_WarrantCPQ__c = 10,
                                                                 Fisso_WarrantCPQ__c = 1000
                                                                 );
        insert o;
        

        
        
         finanziamenti__c f2 = new finanziamenti__c (quote_line__c= NQuoteLine.id,
                                                    Importo_WarrantCPQ__c = 1000,
                                                    Stima_WarrantCPQ__c = 1000);
        insert f2;
        
        condizioni__c c2 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'FISSO',
                                             Minimo_WarrantCPQ__c = 100,
                                             Massimo_WarrantCPQ__c = 1000,
                                             Fisso_WarrantCPQ__c = 1500,
                                             Percentuale_WarrantCPQ__c = 10);
        insert c2;        
        
        
       condizioni__c c3 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 100,
                                             Massimo_WarrantCPQ__c = 1000,
                                             //Fisso_WarrantCPQ__c = 1500,
                                             Valore_max_WarrantCPQ__c = 100,
                                             Percentuale_WarrantCPQ__c = 10);
       insert c3;      
      
        condizioni__c c4 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 100,
                                             Massimo_WarrantCPQ__c = 1000,
                                             //Fisso_WarrantCPQ__c = 1500,
                                             Min_garantito_WarrantCPQ__c= 2000,
                                             Percentuale_WarrantCPQ__c = 10);
        insert c4;   
        
        
        
        condizioni__c c5 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 100,
                                             Massimo_WarrantCPQ__c = 600,
                                             Fisso_WarrantCPQ__c = 1500,
                                             Limite_WarrantCPQ__c= 500,
                                             
                                             Percentuale_WarrantCPQ__c = 10);
        insert c5;   
        
        
          condizioni__c c6 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 100,
                                             Massimo_WarrantCPQ__c = 1000,
                                             Limite_WarrantCPQ__c= 0,
                                             
                                             Percentuale_WarrantCPQ__c = 10
                                             );
        insert c6;   
        
        
          condizioni__c c7 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 100,
                                             Limite_WarrantCPQ__c= 500,
                                             Percentuale_WarrantCPQ__c = 10
                                             
                                             );
        insert c7;   
        
        
        
        
          condizioni__c c8 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 100,
                                             Limite_WarrantCPQ__c= 0,
                                             Massimo_WarrantCPQ__c = 1000,
                                             Percentuale_WarrantCPQ__c = 10
                                             );
        insert c8;   
        
          condizioni__c c9 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 2000,
                                            
                                             Massimo_WarrantCPQ__c = 100,
                                             Percentuale_WarrantCPQ__c = 10
                                             );
        insert c9;   
        
          condizioni__c c10 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 2000,
                                            
                                             Massimo_WarrantCPQ__c = 100,
                                             
                                             Fisso_WarrantCPQ__c = 1500
                                             );
        insert c10;   
        
        
        
        
        
        
        
          condizioni__c c11 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             
                                             Tipo_WarrantCPQ__c = 'VARIABILE',
                                             Minimo_WarrantCPQ__c = 2000,
                                            
                                             Massimo_WarrantCPQ__c = 100,
                                             
                                             Fisso_WarrantCPQ__c = 1500
                                             );
        insert c11;   
        
        
        
        
        
          condizioni__c c12 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Fisso_WarrantCPQ__c = 1500
                                             );
        insert c12;   
        
         condizioni__c c13 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Percentuale_WarrantCPQ__c = 10
                                             );
        insert c13;   
        
        condizioni__c c14 = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                             Percentuale_WarrantCPQ__c = 10,
                                                Minimo_WarrantCPQ__c = 100
                                             );
        insert c14;   
        
         condizioni__c c15= new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f2.id,
                                              Fisso_WarrantCPQ__c = 1500,
                                                Minimo_WarrantCPQ__c = 100
                                             );
        insert c15;   
        
        Condizioni__c c16 = new Condizioni__c(
          quote_line__c= NQuoteLine.id,
          Finanziamento__c = f2.Id,
          Tipo_WarrantCPQ__c = '2',
          Minimo_WarrantCPQ__c = null,
          Massimo_WarrantCPQ__c = null,
          Percentuale_WarrantCPQ__c = 10,
          Min_garantito_WarrantCPQ__c = 1,
          Valore_Max_WarrantCPQ__c = 10
        );

        insert c16;
        
        condizione_opzionale__c o2 = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c11.id,
                                                                 Tipo_WarrantCPQ__c = 'Fisso',
                                                                 	Minimo_WarrantCPQ__c = 100,
                                                                 Massimo_WarrantCPQ__c = 1000,
                                                                 Percentuale_WarrantCPQ__c = 10,
                                                                 Fisso_WarrantCPQ__c = 1000
                                                                 );
        insert o2;

        
        
          
          
          
          
arTest.quoteline  = NQuoteLine.id ;   
          
            arList.add(arTest);
          
            List<String> res = new List<String> ();
          
          x.Disabilita_tutti_i_process_builder__c = false ;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
          

        Test.startTest();
     
        res = InvocableCalcoloCondizione.CalcoloCondizione(arList);
        Test.stopTest();  
        
          
          
          
      }
}