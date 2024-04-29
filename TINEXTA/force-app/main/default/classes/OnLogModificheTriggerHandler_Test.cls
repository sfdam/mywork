@isTest
public class OnLogModificheTriggerHandler_Test {
    
@isTest
   public static void makeData(){
       
        // Custom Setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c=true;
      	x.Bypass_Validation_Rules__c=true;
        insert x;
        //C.S.
       
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        Product2 pro2 = new product2 (name = 'Driver2',
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
        
        
        List<Account> accList = new List<Account>(TestDataFactory.createAccounts(1));
        insert accList;
        
        SBQQ__Quote__c quoteToIns = new SBQQ__Quote__c(SBQQ__Account__c=accList[0].Id,
                                                       WH_Business_Area__c='1104244169',
                                                       SBQQ__Primary__c=true,
                                                       Opportunity_Name__c='testClass',
                                                       Approvazione_al_legale__c=false,
                                                       RecordTypeId='0125I000000l0VJQAY');    
        insert quoteToIns;
        
        SBQQ__QuoteLine__c qlToIns = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteToIns.Id,
                                                            SBQQ__Product__c = pro2.id,
                                                            Tipo_Mandato__c='Singolo');
        insert qlToIns;
        

        Finanziamenti__c finToIns = new Finanziamenti__c(Quote_Line__c=qlToIns.Id);
        Condizioni__c conToIns = new Condizioni__c(Quote_Line__c=qlToIns.Id);
        insert finToIns;
        insert conToIns;
        
        Condizione_Opzionale__c conOpzToIns = new Condizione_Opzionale__c(Quote_Line__c=qlToIns.Id,
                                                                          CondizionePadre_WarrantCPQ__c=conToIns.Id,
                                                                          Percentuale_WarrantCPQ__c=20);
        Pagamenti__c pagToIns = new Pagamenti__c(Quote_Line__c=qlToIns.Id,
                                                 Condizione_WarrantCPQ__c=conToIns.Id);        
        insert conOpzToIns;
        insert pagToIns;    
    
        id rid = ([SELECT Id FROM RecordType WHERE SobjectType = 'Approvazioni__c' AND Name = 'Legale'  LIMIT 1]).id;
    
        id rid2 = ([SELECT Id FROM RecordType WHERE SobjectType = 'Approvazioni__c' AND Name = 'Commerciale'  LIMIT 1]).id;
    
        
        Approvazioni__c app1 = new Approvazioni__c(Quote__c=quoteToIns.Id,
                                                   Finanziamento__c=finToIns.Id,
                                                   Condizione__c=conToIns.Id,
                                                   Condizione_Opzionale__c=conOpzToIns.Id,
                                                   Pagamento__c=pagToIns.Id,
                                                   Creazione_da_Quote__c=true,
                                                   RecordTypeId=rid2,
                                                   Approvazione_foro_2__c=true,
                                                   Canale_Approvativo__c='Commerciale',
                                                   Approval_Step__c='In approvazione');
        
        Approvazioni__c app2 = new Approvazioni__c(Quote__c=quoteToIns.Id,
                                                   Finanziamento__c=finToIns.Id,
                                                   Condizione__c=conToIns.Id,
                                                   Condizione_Opzionale__c=conOpzToIns.Id,
                                                   Pagamento__c=pagToIns.Id,
                                                   RecordTypeId=rid2,
                                                   Approval_Step__c='Approvata');
        
        Approvazioni__c app3 = new Approvazioni__c(Quote__c=quoteToIns.Id,
                                                   Finanziamento__c=finToIns.Id,
                                                   Condizione__c=conToIns.Id,
                                                   Condizione_Opzionale__c=conOpzToIns.Id,
                                                   Pagamento__c=pagToIns.Id,
                                                   Approval_Step__c='In attesa di approvazione');
        
         x.Disabilita_tutti_i_trigger__c=false;
         update x;

        Test.startTest();
    	insert app1;
        app1.Approval_Step__c='Approvata';
        update app1;
        insert app2;
        insert app3;		
        Test.stopTest();        
    }
}