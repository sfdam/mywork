@isTest private class TXT_Storico_AttivitaController_Test {
   @isTest static void getselectOptionsTest(){
       Event evt = new Event(); 
       List<Account> acc = TestDataFactory.createAccounts(1);
       insert acc;
       Map<String,String> result =TXT_Storico_AttivitaController.getselectOptions(evt, 'Esito_Chiamata__c');
       User usr = TXT_Storico_AttivitaController.getUserInfo();
       TXT_Storico_AttivitaController.WrapperResponse wrap = new TXT_Storico_AttivitaController.WrapperResponse();
       wrap = TXT_Storico_AttivitaController.getAllData(acc[0].Id, 'Innolva');
   }

}