@isTest
private class WRT_BatchOnAccountTimeout_Test  {
    
    @testSetup 
    static void setup() {
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        insert x;
        
         Set <string> accupdate = new Set<string>();
        
 		List <Account> accsegn = TestDataFactory.createAccounts(1);
        accsegn[0].Societa_di_riferimento__c = 'Warrant';
        insert accsegn;

   
        
        List <Account> acc = TestDataFactory.createAccounts(1);
        acc[0].AccountSegnalatore__c = accsegn[0].id;
        acc[0].WRT_Data_inserimento_segnalazione__c = system.today()-90;
        insert acc;
        system.debug('EU giorni insert' + acc[0].Giorni_Passati__c + acc[0].WRT_Data_inserimento_segnalazione__c + acc[0].AccountSegnalatore__c );

        
       x.Disabilita_tutti_i_trigger__c=false;
       update x;        
        
        for(Account a: acc){
            accupdate.add(a.id);
        }
        Account testacc = [SELECT Id,Giorni_Passati__c,WRT_Data_inserimento_segnalazione__c FROM Account WHERE id IN:accupdate];
        system.debug('EU mappa lead' + testacc);
        update testacc;
        
        List <Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartner(accsegn);
        segn[0].Account__c = acc[0].id;
        insert segn;
        
    }
    
    static testmethod void test() {        
        Test.startTest();
        WRT_BatchOnAccountTimeout  bza = new WRT_BatchOnAccountTimeout (); 
        Id batchId = Database.executeBatch(bza);
        Test.stopTest();
        // after the testing stops, assert records were updated properly

    }

}