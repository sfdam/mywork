@isTest
private class WRT_BatchOnLeadTimeout_Test {
    
    @testSetup 
    static void setup() {
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        insert x;
        
         Set <string> leadupdate = new Set<string>();
        
 		List <Account> acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c = 'Warrant';
        insert acc;

       //x.Disabilita_tutti_i_trigger__c=false;
       //update x;        
        
        List <Lead> leadlist = TestDataFactory.createLeads(1);
        leadlist[0].Societa_di_riferimento__c='Warrant';
        leadlist[0].Testo_societa_di_riferimento__c='Warrant';
        leadlist[0].AccountSegnalatore__c = acc[0].id;
        leadlist[0].Data_inserimento_segnalazione__c = system.today()-100;
        leadlist[0].Basket_del_Lead__c='Nessuno';
        leadlist[0].Origine_Lead_Livello_1__c='Segnalazione Partner';
        leadlist[0].Origine_Lead_Livello_2__c='Partner';
        leadlist[0].Data_Origine__c=system.today();
        insert leadlist;
        
        system.debug('EU giorni insert' + leadlist[0].Giorni_Passati__c + leadlist[0].Data_inserimento_segnalazione__c + leadlist[0].AccountSegnalatore__c );

        for(Lead l: leadlist){
            leadupdate.add(l.id);
        }
        Lead testLead = [SELECT Id,Giorni_Passati__c,Data_inserimento_segnalazione__c FROM Lead WHERE id IN:leadupdate];
        system.debug('EU mappa lead' + testLead);
        update testLead;
        
        List <Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartner(acc);
        segn[0].Lead_Di_Riferimento__c = leadlist[0].id;
        insert segn;
        
       x.Disabilita_tutti_i_trigger__c=false;
       update x;
        
    }
    
    static testmethod void test() {        
        Test.startTest();
        WRT_BatchOnLeadTimeout bza = new WRT_BatchOnLeadTimeout(); 
        Id batchId = Database.executeBatch(bza);
        Test.stopTest();
        // after the testing stops, assert records were updated properly

    }

}