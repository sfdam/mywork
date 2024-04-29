@istest
public class WRT_BatchOnRinnovi_Test {
     @istest
    public static void TestSuccess(){
        
        //custom setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
      //c.s.
        
         List <Impostazioni_Rinnovo__c> RinnoviDaCancellare = new list <Impostazioni_Rinnovo__c> ();
        insert RinnoviDaCancellare;
        
        Impostazioni_Rinnovo__c rec = new Impostazioni_Rinnovo__c ();
        insert rec;
        
        
        Datetime yesterday = system.today().addDays(-7);
Test.setCreatedDate(rec.Id, yesterday);
        
        RinnoviDaCancellare.add(rec);
        update RinnoviDaCancellare ;
        
        

        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        
         Test.startTest();
     
      WRT_BatchOnRinnovi c = new WRT_BatchOnRinnovi ();
      database.executeBatch(c);
        Test.stopTest();  
        
    }

}