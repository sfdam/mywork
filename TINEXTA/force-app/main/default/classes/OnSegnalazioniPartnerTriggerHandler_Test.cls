@isTest
public class OnSegnalazioniPartnerTriggerHandler_Test {
    
    @isTest static void testnumero(){
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
            

    
    List <Account> acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c = 'Warrant';
      insert acc;
    
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
     List <Lead> LeadUpdate=TestDataFactory.createLeads(1);
    insert LeadUpdate;
        List <Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartner(acc);
        segn[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
         segn[0].AccountSegnalatore__c = acc[0].id;
        insert segn;
        
    }
    
        @isTest static void testchangelead(){
    
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;  

    
    List <Account> acc = TestDataFactory.createAccounts(1);
            acc[0].Societa_di_riferimento__c = 'Warrant';
        insert acc;
                
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
            
                List <Lead> LeadUpdate=TestDataFactory.createLeads(1);
    insert LeadUpdate;
    
        List <Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartner(acc);
        segn[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
             segn[0].AccountSegnalatore__c = acc[0].id;
        insert segn;
        
        List <Segnalazioni__c> segn1 = TestDataFactory.create_segnalazionipartner(acc);
        segn1[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
        segn1[0].Stato_Segnalazione_Warrant__c = 'Positivo';
        insert segn1;   
           
        
    }
    
            @isTest static void testchangeacc(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
            

    
    List <Account> acc = TestDataFactory.createAccounts(1);
                acc[0].Societa_di_riferimento__c = 'Warrant';
        insert acc;
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
                    
         List <Lead> LeadUpdate=TestDataFactory.createLeads(1);
         insert LeadUpdate;
    
        List <Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartner(acc);
        //segn[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
        segn[0].Account__c = acc[0].id;
        segn[0].AccountSegnalatore__c = acc[0].id;
        insert segn;
        
        List <Segnalazioni__c> segn1 = TestDataFactory.create_segnalazionipartner(acc);
       // segn1[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
        segn1[0].Account__c = acc[0].id;
        segn1[0].Stato_Segnalazione_Warrant__c = 'Positivo';
        insert segn1;   

    }
    
      @isTest static void testchangeaccKO(){
            Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
            

    
    List <Account> acc = TestDataFactory.createAccounts(1);
          acc[0].Societa_di_riferimento__c = 'Warrant';
        insert acc;
          
                  x.Disabilita_tutti_i_trigger__c=false;
        update x;
        List <Lead> LeadUpdate=TestDataFactory.createLeads(1);
    insert LeadUpdate;
          
        List <Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartner(acc);
        //segn[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
        segn[0].Account__c = acc[0].id;
           segn[0].AccountSegnalatore__c = acc[0].id;
        insert segn;
        
        List <Segnalazioni__c> segn1 = TestDataFactory.create_segnalazionipartner(acc);
       // segn1[0].Lead_Di_Riferimento__c = LeadUpdate[0].id;
        segn1[0].Account__c = acc[0].id;
        segn1[0].Note_KO__c = 'KO Timeout';
        insert segn1;   

    }

    
}