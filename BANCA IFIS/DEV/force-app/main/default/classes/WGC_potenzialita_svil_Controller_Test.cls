@isTest
private class WGC_potenzialita_svil_Controller_Test {

    @isTest
    private static void getCountAnagraficheTest(){
        //String currentUserId, String currentUserLevel, String filterValue, String tipoFiltro
        Test.startTest();
            WGC_potenzialita_svil_Controller.getCountAnagrafiche('','','','');
            WGC_potenzialita_svil_Controller.getCountAnagrafiche('','commerciale','','utente');
            WGC_potenzialita_svil_Controller.getCountAnagrafiche('a','direzione','b','utente');
            WGC_potenzialita_svil_Controller.getCountAnagrafiche('','direzione','','filiale');
        Test.stopTest();
        
    }
}