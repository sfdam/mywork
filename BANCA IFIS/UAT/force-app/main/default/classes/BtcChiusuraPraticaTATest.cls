@isTest
public class BtcChiusuraPraticaTATest {
     
	 @isTest static void testBatch(){
         Funzionalita__c f = Funzionalita__c.getInstance();
         f.DisabilitaControlloCambioFaseOpp__c = true;
         f.WGC_disabilita_per_batch__c = true; //adione-crm20
         upsert f;
         
         insert new Prodotto__c(CodiceUnivoco__c = 'ATDTiAnticipo');
         WGC_AllDataFactory.createUtenzaDefault();
         
         User u = TestUtils.creaUtente('utente');
         
         Account a = TestUtils.creaAccount('AccountTest');
         
         List<Cessione__c> cessSetup = new List<Cessione__c>();
         List<Opportunity> oppSetup = new List<Opportunity>();
         
         for(Integer i=0; i<3; i++){
             Cessione__c cess = new Cessione__c( Account__c = a.Id, CostoComplessivoC138__c = 12.34, DataUltimoAccesso__c = System.now());
             Opportunity opp = new Opportunity(Name='Test'+i,AccountID = a.id, StageName = 'In Istruttoria' , CloseDate = Date.today());
             opp.Cessione__c = cess.Id;
             cessSetup.add(cess);
             oppSetup.add(opp);
         }
         
         insert cessSetup;
         insert oppSetup;
         
         List<Cessione__c> cessList = [SELECT Id, Name, DataUltimoAccesso__c FROM Cessione__c WHERE CostoComplessivoC138__c = 12.34];
         
         for(Opportunity o : [SELECT Id, StageName FROM Opportunity]){
             System.assertNotEquals(o.StageName, 'Persa');
         }
         
         for(Cessione__c c : cessList){
             c.DataUltimoAccesso__c = DateTime.newInstance(2017,2,3,13,20,30);
             c.Stato__c = '0';
         }
         
         update cessList;
         
         Test.startTest();
         BtcChiusuraPraticaTA btc = new BtcChiusuraPraticaTA();
         Database.executeBatch(btc);
         Test.stopTest();
         
         Map<Id,Cessione__c> updCessMap = new Map<Id,Cessione__c>([SELECT Id, Stato__c FROM Cessione__c WHERE CostoComplessivoC138__c = 12.34]);
         for(Cessione__c c : updCessMap.values()){
             System.assertEquals(c.Stato__c, '5');
         }
         
         for(Opportunity o :  [SELECT Id, StageName, Cessione__c FROM Opportunity WHERE Cessione__c IN :updCessMap.keyset()]){
             System.assertEquals(o.StageName, 'Persa');
         }
         
		}


}