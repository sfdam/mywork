@isTest
public class InvocableRinnoviFinCondPag_Test {
    @isTest static void testSuccess(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        List<InvocableRinnoviFinCondPag.ActionRequest> arList = new List<InvocableRinnoviFinCondPag.ActionRequest>();
        InvocableRinnoviFinCondPag.ActionRequest arTest = new InvocableRinnoviFinCondPag.ActionRequest();
        
        
         List<InvocableRinnoviFinCondPag.ActionRequest> arList2 = new List<InvocableRinnoviFinCondPag.ActionRequest>();
        InvocableRinnoviFinCondPag.ActionRequest arTest2 = new InvocableRinnoviFinCondPag.ActionRequest();
        
        /* List<InvocableRinnoviFinCondPag.ActionRequest> arList3 = new List<InvocableRinnoviFinCondPag.ActionRequest>();
        InvocableRinnoviFinCondPag.ActionRequest arTest3 = new InvocableRinnoviFinCondPag.ActionRequest();*/
   
        
         Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
                                        SBQQ__Account__c=acc[0].id,
                                      RecordTypeId = rtIdQuote,
                                      SBQQ__Primary__c = true );
        
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
        
        
        
        
        
        
        
        List <condizioni__c> conlist = new list <condizioni__c> ();
        List <pagamenti__c> paglist = new list <pagamenti__c> ();
        List <finanziamenti__c> finlist = new list <finanziamenti__c> ();
        List <condizione_opzionale__c> opzlist = new list <condizione_opzionale__c> ();
        
         
     
     

        finanziamenti__c f = new finanziamenti__c (quote_line__c= NQuoteLine.id);
        insert f;
        condizioni__c c = new condizioni__c (quote_line__c= NQuoteLine.id ,
                                             Finanziamento__c = f.id,
                                             Percentuale_WarrantCPQ__c = 10 );
        insert c;
        pagamenti__c p = new pagamenti__c (quote_line__c= NQuoteLine.id,
                                          Condizione_WarrantCPQ__c= c.id);
        insert p;
       
        condizione_opzionale__c o = new condizione_opzionale__c (CondizionePadre_WarrantCPQ__c = c.id,
                                                                Percentuale_WarrantCPQ__c = 12);
        insert o;
        
        
        
        
     
        
        
        
        
        conlist.add(c);
        paglist.add(p);
        finlist.add(f);
        opzlist.add(o);
        
       
        
        Logiche_Rinnovo_WRT__c log = new  Logiche_Rinnovo_WRT__c (
                                                                  tipo__c = 'NESSUNO',
                                                                  Finanziamento_Cond__c = 'NESSUNO',
                                                                  PercentualeCond__c = 'Nessuno',
                                                                  fisso__c = 'Nessuno',
                                                                  min__c = 'Nessuno',
                                                                  max__c = 'Nessuno',
                                                                  limite__c = 'Nessuno',
                                                                  Min_Garantito__c  = 'Nessuno',
                                                                  Valore_Max__c  = 'Nessuno',
                                                                  PagPercentPag__c = 'Nessuno',
                                                                  CIG__c = 'Nessuno',
                                                                  CUP__c = 'Nessuno',
                                                                  azienda__c = 'NESSUNO',
                                                                  Descrizione_Fattura__c = 'Nessuno',
                                                                  Procedimento_pagamento__c  = 'NESSUNO',
                                                                  parte__c = 'NESSUNO',
                                                                  Probabilit__c = 'NESSUNO',
                                                                  Opzione__c = 'NESSUNO',
                                                                  Tipo_Pagamento__c = 'NESSUNO',
                                                                  ScadenzaPag__c = '0',
                                                                  Finanziamento__c = 'NESSUNO',
                                                                  Importo__c = 'Nessuno',
                                                                  fattura__c = 'Nessuno',
                                                                  stima__c = 'Nessuno'
                                                                  
                                                                  
                                                                 );
        insert log ;
        
          Logiche_Rinnovo_WRT__c log2 = new  Logiche_Rinnovo_WRT__c (
                                                                  tipo__c = 'IDENTICO',
                                                                  Finanziamento_Cond__c = 'IDENTICO',
                                                                  PercentualeCond__c = 'Identico',
                                                                  fisso__c = 'Identico',
                                                                  min__c = 'Identico',
                                                                  max__c = 'Identico',
                                                                  limite__c = 'Identico',
                                                                  Min_Garantito__c  = 'Identico',
                                                                  Valore_Max__c  = 'Identico',
                                                                  PagPercentPag__c = 'Identico',
                                                                  CIG__c = 'Identico',
                                                                  CUP__c = 'Identico',
                                                                  azienda__c = 'Identico',
                                                                  Descrizione_Fattura__c = 'Identico',
                                                                  Procedimento_pagamento__c  = 'IDENTICO',
                                                                  parte__c = 'IDENTICO',
                                                                  Probabilit__c = 'IDENTICO',
                                                                  Opzione__c = 'IDENTICO',
                                                                  Tipo_Pagamento__c = 'IDENTICO',
                                                                  ScadenzaPag__c = '0',
                                                                  Finanziamento__c = 'IDENTICO',
                                                                  Importo__c = 'Identico',
                                                                  fattura__c = 'Identico',
                                                                  stima__c = 'Identico'
                                                                  
                                                                  
                                                                 );
        
        
        insert log2;
        
/*         Logiche_Rinnovo_WRT__c log3 = new  Logiche_Rinnovo_WRT__c (
                                                                  tipo__c = 'IDENTICO',
                                                                  Finanziamento_Cond__c = 'IDENTICO',
                                                                  PercentualeCond__c = 'Manuale',
                                                                  fisso__c = 'Manuale',
                                                                  min__c = 'Manuale',
                                                                  max__c = 'Manuale',
                                                                  limite__c = 'Manuale',
                                                                  Min_Garantito__c  = 'Manuale',
                                                                  Valore_Max__c  = 'Manuale',
                                                                  PagPercentPag__c = 'Manuale',
                                                                  CIG__c = 'Manuale',
                                                                  CUP__c = 'Manuale',
                                                                  azienda__c = 'Identico',
                                                                  Descrizione_Fattura__c = 'Manuale',
                                                                  Procedimento_pagamento__c  = 'IDENTICO',
                                                                  parte__c = 'IDENTICO',
                                                                  Probabilit__c = 'IDENTICO',
                                                                  Opzione__c = 'IDENTICO',
                                                                  Tipo_Pagamento__c = 'IDENTICO',
                                                                  ScadenzaPag__c = '0',
                                                                  Finanziamento__c = 'IDENTICO',
                                                                  Importo__c = 'Manuale',
                                                                  fattura__c = 'Manuale',
                                                                  stima__c = 'Manuale'
                                                                  
                                                                  
                                                                 );
        
        insert log3;*/
            
            
        arTest.cercologicheid = log.id ;
        
        
        
        arTest.collezFin = finlist;
        arTest.collezCond = conlist;
        arTest.collezPag = paglist;
        arTest.collezOpz = opzlist;
        
            
        
       /* arTest.MettiFattura = 'fatt';
        arTest.MettiImporto = 1;
        arTest.MettiStima = 2;
        arTest.MettiDescrizioneFattura = '3';
        arTest.MettiPercentuale = 10;
        arTest.MettiFisso = 4;
        arTest.MettiMin = 5;    
        arTest.MettiMax = 6;         
        arTest.MettiLimite = 7;
        arTest.MettiMinGarantito = 8;
        arTest.MettiValoreMax = 9;
        arTest.MettiPagPercentuale = 10;
        arTest.MettiCIG = '11';
        arTest.MettiCUP = '12';
        arTest.MettiCodiceOrdineCliente = '13'; */
        
        
        arList.add(arTest);
        
       
        
        
         arTest2.cercologicheid = log2.id ;
        
        
        
        arTest2.collezFin = finlist;
        arTest2.collezCond = conlist;
        arTest2.collezPag = paglist;
        arTest2.collezOpz = opzlist;
        
            
        
      /*  arTest2.MettiFattura = 'fatt';
        arTest2.MettiImporto = 1;
        arTest2.MettiStima = 2;
        arTest2.MettiDescrizioneFattura = '3';
        arTest2.MettiPercentuale = 10;
        arTest2.MettiFisso = 4;
        arTest2.MettiMin = 5;    
        arTest2.MettiMax = 6;         
        arTest2.MettiLimite = 7;
        arTest2.MettiMinGarantito = 8;
        arTest2.MettiValoreMax = 9;
        arTest2.MettiPagPercentuale = 10;
        arTest2.MettiCIG = '11';
        arTest2.MettiCUP = '12';
        arTest2.MettiCodiceOrdineCliente = '13'; */
        
        
        arList2.add(arTest2);
        
        
       /* arTest3.cercologicheid = log3.id ;
        
        
        
        arTest3.collezFin = finlist;
        arTest3.collezCond = conlist;
        arTest3.collezPag = paglist;
        arTest3.collezOpz = opzlist; 
        
            
        
        arTest3.MettiFattura = 'fatt';
        arTest3.MettiImporto = 1;
        arTest3.MettiStima = 2;
        arTest3.MettiDescrizioneFattura = '3';
        arTest3.MettiPercentuale = 10;
        arTest3.MettiFisso = 4;
        arTest3.MettiMin = 5;    
        arTest3.MettiMax = 6;         
        arTest3.MettiLimite = 7;
        arTest3.MettiMinGarantito = 8;
        arTest3.MettiValoreMax = 9;
        arTest3.MettiPagPercentuale = 10;
        arTest3.MettiCIG = '11';
        arTest3.MettiCUP = '12';
        arTest3.MettiCodiceOrdineCliente = '13'; 
        
        
        arList3.add(arTest3);*/
        
        
        
        
        
        
        
        update conlist;
        update paglist;
        update finlist;
        update opzlist;
       
        List<String> res = new List<String> ();
        List<String> res2 =new List<String> ();
        List<String> res3 =new List<String> ();
        
       x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
     
      res = InvocableRinnoviFinCondPag.UpdateFinCondPag(arList);
      res2 = InvocableRinnoviFinCondPag.UpdateFinCondPag(arList2);
     // res3= InvocableRinnoviFinCondPag.UpdateFinCondPag(arList3);
        Test.stopTest();  
        
    }

}