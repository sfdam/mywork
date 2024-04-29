@IsTest
private class WRT_SchedulableBatchOnRinnovi_Test {
     
    
    
    
  static testmethod void testScheduledJob()  {       
        
        //custom setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
      //c.s.
        
        
        
       /* List <Impostazioni_Rinnovo__c> RinnoviDaCancellare = new list <Impostazioni_Rinnovo__c> (); 
        Impostazioni_Rinnovo__c ir = new Impostazioni_Rinnovo__c ();
        rinnovidacancellare.add (ir);
        insert rinnovidacancellare ;*/
      
      
      WRT_BatchOnRinnovi  ab = new WRT_BatchOnRinnovi ();
      WRT_SchedulableBatchOnRinnovi bc = new WRT_SchedulableBatchOnRinnovi ();
        
        
      
      String cronExpr = '0 0 0 15 3 ? 2022';
      
      
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
      
     
      
      
        Test.startTest();
        //String jobId = scheduleBatch( ab, 'jobname', 1);
     
     String jobId = 
        System.schedule('myJobTestJobName', cronExpr, new  WRT_SchedulableBatchOnRinnovi());
      
        Database.executeBatch(new WRT_BatchOnRinnovi());

  
        Test.stopTest();

    
        
        
        
        

    }  

}