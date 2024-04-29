@istest
public class OnPagamentiTriggerHandler_Test {
    @istest
    public static void PagamentiTestMethod() {
        
        //custom setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Bypass_Validation_Rules__c=true;
        insert x;
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
        
        //inserimento procedimenti/pagamenti:
        Id rid = [SELECT Id FROM RecordType WHERE SobjectType ='Procedimento_pagamento__c' AND Name ='Pagamento' LIMIT 1].id;
        
        Procedimento_pagamento__c proc = new Procedimento_pagamento__c(Product__c=pro.Id,
                                                                       RecordTypeId=rid,
                                                                       Name='FATTIBILITA POSITIVA');
        insert proc;
        
        Procedimento_pagamento__c proc2 = new Procedimento_pagamento__c(Product__c=pro2.Id,
                                                                        RecordTypeId=rid,
                                                                        Name='TEST');
        insert proc2;
        
        
        //Inserimento Business Area per pagamenti e condizioni opzionali
        Business_Area_Warrant__c pag = new Business_Area_Warrant__c (Name = 'pag',
                                                                     RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId(),
                                                                     ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                     SingoloProdotto_WarrantCPQ__c = pro2.id
                                                                    );      
        insert pag;
        
        Business_Area_Warrant__c pag2 = new Business_Area_Warrant__c (Name = 'pag2',
                                                                      RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId(),
                                                                      ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                      SingoloProdotto_WarrantCPQ__c = pro.id
                                                                     );      
        insert pag2;
        
        Business_Area_Warrant__c ConO = new Business_Area_Warrant__c (Name = 'ConO',
                                                                      RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId(),
                                                                      ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                      SingoloProdotto_WarrantCPQ__c = pro.id
                                                                     );      
        insert ConO;
        
        Business_Area_Warrant__c ConO2 = new Business_Area_Warrant__c (Name = 'ConO2',
                                                                       RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId(),
                                                                       ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                       SingoloProdotto_WarrantCPQ__c = pro2.id
                                                                      );      
        insert ConO2;
        
        Business_Area_Warrant__c Con = new Business_Area_Warrant__c (Name='Con',
                                                                     RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(), 
                                                                     ProdottoBundle_WarrantCPQ__c = pro.id,
                                                                     SingoloProdotto_WarrantCPQ__c = pro.id);
        insert Con;
        
        
        
        
        //Inserimento QuoteLine
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                                        SBQQ__Quote__c = q.id,
                                                        Divisione_WarrantCPQ__c='FAA',
                                                        SBQQ__ProductOption__c=po.id,
                                                        Valore_del_pagamento_in_euro_Prodotto__c=1000,
                                                        Finanziamento_Stimato_Prodotto__c=1000);
        

        
        insert ql;  
        
        
        
        
        //Inserimento Condizioni      
        condizioni__c c = new condizioni__c (Escludi_da_template__c=false,
                                             Formula_Semaforo_Trigger__c=true,
                                             Importo_Appoggio__c=1000,
                                             Stima_Appoggio__c = -1000,
                                             Quote_Line__c = ql.id 
                                            );    
        
        condizioni__c c2 = new condizioni__c (Escludi_da_template__c=false,
                                              Formula_Semaforo_Trigger__c=false,
                                              Importo_Appoggio__c = -1000,
                                              Stima_Appoggio__c = -1000,
                                              Quote_Line__c = ql.id );    
        
        
        insert c;
        insert c2;       
        


        
        Pagamenti__c p1 = new Pagamenti__c(Escludi_da_template_Pag__c=false,
                                           Formula_Semaforo_Trigger__c=false,
                                           Quote_Line__c=ql.id,
                                           Opzione_WarrantCPQ__c='1475143698',
                                           Percentuale_WarrantCPQ__c=1,
                                           Procedimento_pagamento__c=proc.id,
                                           Condizione_WarrantCPQ__c=c.id);    

        Pagamenti__c p3 = new Pagamenti__c(Escludi_da_template_Pag__c=false,
                                           Formula_Semaforo_Trigger__c=false,
                                           Quote_Line__c=ql.id,
                                           Condizione_WarrantCPQ__c=c2.id);
        
  
        
              
	    //Riabilitazione trigger
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
       test.starttest ();
        insert p1;       
        insert p3;
        system.debug('PROCEDIMENTO INSERT ' + p1.Procedimento_pagamento__c + p1.Approvazione_per_Proc_Pagamenti__c);
       
        //p1.Opzione_WarrantCPQ__c=null;
        //p1.WRT_Stato_pagamento__c='Pagato';
        //p1.Procedimento_pagamento__c=proc2.Id;
        p1.SwitchTrigger__c = !(p1.SwitchTrigger__c);
        update p1;


        delete p3;
        set <string> setpag = new set <string> ();
        setpag.add (p1.id);  
        OnPagamentiTriggerHandler.eliminaPagamentiInfostore (setpag);
        
        test.stoptest ();
        
       	
        
    }
}