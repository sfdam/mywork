@istest
public class OnFinanziamentiTriggerHandler_Test {
    @istest
  public static void OnFinanziamentiTriggerHandler_TestMethod() {
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
      //c.s.
      
        //Inserimento Quote 
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
        
      
      //Inserimento Business Area per condizioni
	
      Business_Area_Warrant__c fin = new Business_Area_Warrant__c (Name='fin',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(), 
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro2.id);
		insert fin;

      
      Business_Area_Warrant__c con2 = new Business_Area_Warrant__c (Name = 'con2',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro2.id
                                                             );      
		insert con2;
      
      
      
      
      Business_Area_Warrant__c fin2 = new Business_Area_Warrant__c (Name='fin2',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId(), 
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro.id);
		insert fin2;
      
      
      
      
      Business_Area_Warrant__c con = new Business_Area_Warrant__c (Name = 'con',
                                                             RecordTypeid = Schema.SObjectType.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId(),
                                                             ProdottoBundle_WarrantCPQ__c = pro.id,
                                                             SingoloProdotto_WarrantCPQ__c = pro.id
                                                                  );      
		insert con;
      
    
      
      
      //Riabilitazione trigger
      x.Disabilita_tutti_i_trigger__c=false;
      update x;
      //riabilitazione

       //Inserimento QuoteLine
		SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro.id,
                                               			 SBQQ__Quote__c = q.id,
                                                 		SBQQ__ProductOption__c=po.id,
                                                         Divisione_WarrantCPQ__c='FAA',
                                                       Tipo_Mandato__c = 'Singolo');
      
         SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c (SBQQ__Product__c = pro2.id,
                                                    		SBQQ__Quote__c = q.id,  
                                                          Divisione_WarrantCPQ__c='FAA',
                                                          Tipo_Mandato__c = 'Singolo'
                                                );

		insert ql;
      system.debug('Quote Line Option ' + ql.SBQQ__ProductOption__c);
        insert ql2;
      
      //Inserimento finanziamenti     
		finanziamenti__c f = new finanziamenti__c (Formula_Semaforo_Trigger__c=true,
                                                   Escludi_da_template__c=true,
                                                   Quote_Line__c = ql2.id);
                                                   //SingoloProdotto_WarrantCPQ__c = pro.id    

       finanziamenti__c f2 = new finanziamenti__c (Formula_Semaforo_Trigger__c=false,
                                                   Escludi_da_template__c=false,
                                                   Quote_Line__c = ql.id,
                                                  Importo_WarrantCPQ__c=1000);
                                                   //SingoloProdotto_WarrantCPQ__c = pro.id
     	 
      
      	insert f;
        insert f2;
         system.debug('Product Option' + f2.Formula_Id_Bundle__c);
      
		test.starttest ();
      	f2.Importo_WarrantCPQ__c=1200;
      	update f2;
      	delete f2;
      OnFinanziamentiTriggerHandler.eliminaFinanziamentiRelated(null);
		test.stoptest ();
      
      
      
  }

}