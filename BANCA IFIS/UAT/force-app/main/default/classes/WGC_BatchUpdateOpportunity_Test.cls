@isTest
public class WGC_BatchUpdateOpportunity_Test
{
	@TestSetup
    static void setupData()
    {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        upsert f;
        
        insert new EndpointServizi__c(
            Name = 'settings',
            LAGKey__c = 'x',
            URLGetBilancioSinteticoRibes__c = 'https://a.com',
            UrlSearchDocument__c = 'https://b.com',
            WGC_Url_Dati_PEF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/datipef'
        );
        
        Account a = TestUtils.creaAccount('test');
        a.CodiceIstituto3N__c = '123';
        update a;
        Opportunity opp = TestUtils.CreaOpportunity(a);
        opp.WGC_Codice_Pratica__c = 123456; 
        opp.IdCartella__c = '123456';
        opp.StageName = 'Valutazione Pratica'; 
        update opp;
        
        
        f.DisabilitaTriggers__c= true;
        update f;
        TestUtils.creaLinee(opp, 3);
    }
    
    @isTest
    static void testBatchOpportunita() 
    {
        //Id batchJobId = Database.executeBatch(new WGC_BatchUpdateOpportunity(), 200);
        Test.StartTest();
        SchBatchUpdateOpportunity sh1 = new SchBatchUpdateOpportunity();      
        String sch = '0 0 23 * * ?';
        System.schedule('Test for SchBatchUpdateOpportunity', sch, sh1);
        Test.stopTest();
    }
}