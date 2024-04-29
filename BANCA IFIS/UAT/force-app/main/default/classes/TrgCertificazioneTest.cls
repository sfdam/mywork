@isTest
public class TrgCertificazioneTest {

    @testSetup
  	static void setupData () {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        upsert f;
        WGC_AllDataFactory.createUtenzaDefault();
        insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');

        Account a = TestUtils.creaAccount('AccountTest');
        Opportunity opp = TestUtils.creaOpportunity(a);

        Cessione__c cessione = new Cessione__c(Name = 'test', Account__c = a.Id);
        insert cessione;
		
        Test.startTest();
        Certificazione__c cert = new Certificazione__c(Cessione__c = cessione.Id, TerminiPagamento__c = 30);
    	  insert cert;
        Test.stopTest();
    }

    @isTest
    static void testDeleteCertificazione() {
      Test.startTest();
       delete [SELECT Id FROM Certificazione__c];
      Test.stopTest();
    }
	
    /*
    @isTest 
    static void testValidazioneCertificazione(){
        Test.startTest();
      Certificazione__c cert = [SELECT Cessione__c, TerminiPagamento__c FROM Certificazione__c];
      cert.DataPagamento__c = Date.newInstance(2018,01,01);
      update cert;
      System.assertEquals(cert.Errore__c, null);
      Test.stopTest();
    }
*/

}