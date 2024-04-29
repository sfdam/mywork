@isTest private class TXT_CreateActivityController_Test {
   @isTest static void getselectOptionsTest(){
       Event evt = new Event(); 
       List<Account> acc = TestDataFactory.createAccounts(1);
       insert acc;
       Map<String,String> result =TXT_CreateActivityController.getselectOptions(evt, 'Esito_Chiamata__c');
       User usr = TXT_CreateActivityController.getUserInfo();
      	Boolean res2=TXT_CreateActivityController.createNewEvent(DateTime.now(),DateTime.now().addDays(1),usr.Id,acc[0].Id,'Test','Test','Account');

       Boolean res=TXT_CreateActivityController.createNewTask(String.valueOf(Date.Today()),'15:00',usr.Id,acc[0].Id,'Account','Test','Test','In Corso','Test','Test','Test','Test');
   }

}