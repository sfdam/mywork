@isTest
public class OnCondizioneOpzionaleTriggerHandler_Test {
    
    @isTest
    public static void OpzionaliTest(){
        
        EndpointServizi__c e = new EndpointServizi__c();
        e.WRT_Elimina_Bulk_Pricing__c='https://salesforce-test.warranthub.it/api/v1/Wh/Quote/Pricing/DeleteBulk';
        e.WRN_Key_IntegrazioneInfoStore__c = 'test';
        e.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        e.WRT_SharePoint_Folders_Account__c = 'test';
        e.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        e.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        e.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        e.WRT_SharePoint_Folders_Opportunity__c = 'test';
        e.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        insert e;
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        //x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Bypass_Validation_Rules__c=true;
        insert x;
        
        Product2 pro = new product2 (name = 'Driver',
                                     IsActive = true);
        Product2 pro2 = new product2 (name = 'Driver2',
                                      IsActive = true);        
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
        
        SBQQ__ProductOption__c po = new SBQQ__ProductOption__c (SBQQ__OptionalSKU__c = pro2.id,
                                                                SBQQ__ConfiguredSKU__c = pro.id,
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
        Condizioni__c conToIns = new Condizioni__c(Quote_Line__c=qlToIns.Id,
                                                   WRT_Update_da_Rinnovo__c=false,
                                                   Tipo_WarrantCPQ__c='Alternativo');
        insert finToIns;
        insert conToIns;
        
        
        Condizione_Opzionale__c con1 = new Condizione_Opzionale__c(                                                     		  
            CondizionePadre_WarrantCPQ__c=conToIns.Id,                                                                   
            Fisso_WarrantCPQ__c=3,
            Soglia_Commerciale_Fisso__c=2,
            Min_garantito_WarrantCPQ__c=10,
            Tipo_WarrantCPQ__c='1');
        
        Condizione_Opzionale__c con2 = new Condizione_Opzionale__c(                                                     		  
            CondizionePadre_WarrantCPQ__c=conToIns.Id,                                                                   
            Fisso_WarrantCPQ__c=1,
            Soglia_Commerciale_Fisso__c=5,
            Soglia_AM_KAM_Fisso__c=3,
            Soglia_DM_Fisso__c=4,
            Soglia_Dir_Comm_Fisso__c=2,
            Valore_max_WarrantCPQ__c=4,
            Min_garantito_WarrantCPQ__c=10,
            Tipo_WarrantCPQ__c='1');
        
		Set<String> Todel = new Set<String>();
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
        
        insert con1;
        insert con2;
        con1.Fisso_WarrantCPQ__c = 1;
        con1.Valore_max_WarrantCPQ__c=4;
        con1.Min_garantito_WarrantCPQ__c=null;
        update con1;
        
        Todel.add(con2.id);
        OnCondizioneOpzionaleTriggerHandler.eliminaCondizioniOpzionaliInfostore(Todel);
        Test.stopTest();
        
        
        
    }
}