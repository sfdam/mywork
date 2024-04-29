@IsTest
private class TXT_SchedulableBatchOnRinnovi_Test {
     
    
    
    
  static testmethod void testScheduledJob()  {       
        
        //custom setting
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_Integrazione__c = true;
        insert x;
      //c.s.
        
  
      
      
      TXT_BatchImpostazioneRinnovi  ab = new TXT_BatchImpostazioneRinnovi ();
      TXT_SchedulableBatchOnRinnovi bc = new TXT_SchedulableBatchOnRinnovi ();
        
        
      
      String cronExpr = '0 0 0 15 3 ? 2022';
      
      
        
   
     
      
      
        Test.startTest();
        //String jobId = scheduleBatch( ab, 'jobname', 1);
     
     String jobId = 
        System.schedule('myJobTestJobName', cronExpr, new  TXT_SchedulableBatchOnRinnovi());
      
        Database.executeBatch(new TXT_BatchImpostazioneRinnovi());

  
        Test.stopTest();

    
        
        
        
        

    }  

}