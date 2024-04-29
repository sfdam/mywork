@istest
public class TXT_BatchImpostazioneRinnovi_Test {
     @istest
    public static void TestSuccess(){
        
        //custom setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
      //c.s.
        
         List <Impostazioni_Rinnovi_Tinexta__c> RinnoviDaCancellare = new list <Impostazioni_Rinnovi_Tinexta__c> ();
        insert RinnoviDaCancellare;
        
        Impostazioni_Rinnovi_Tinexta__c rec = new Impostazioni_Rinnovi_Tinexta__c ();
        insert rec;
        
        
        Datetime yesterday = system.today().addDays(-7);
Test.setCreatedDate(rec.Id, yesterday);
        
        RinnoviDaCancellare.add(rec);
        update RinnoviDaCancellare ;
        
        

        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        
         Test.startTest();
     
      TXT_BatchImpostazioneRinnovi c = new TXT_BatchImpostazioneRinnovi ();
      database.executeBatch(c);
        Test.stopTest();  
        
    }

}