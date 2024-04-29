@isTest
public  class WGC_Opp_Home_ControllerTest {

    @isTest
    public static void Test_getOpportunityCountByStatus(){
        Test.startTest();
        String userId = UserInfo.getUserId();
        WGC_Opp_Home_Controller.getOpportunityCountByStatus(userId, 'commerciale', userId, 'utente');
        Test.stopTest();
    }

    @isTest
    public static void Test_countOpty(){
        //Creo i dati
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createOpportunity(5, true);
        List<Opportunity> opp = [SELECT Id, Name, CloseDate, StageName FROM Opportunity];

        System.System.debug('List --> '+opp);
        opp.get(0).CloseDate = Date.newInstance(2059,5,19);
        /*opp.get(1).StageName = 'Valutazione Pratica';
        opp.get(2).StageName = 'Redazione Contratti';
        opp.get(3).StageName = 'Perfezionamento Contratti';
        opp.get(4).StageName = 'Attivazione prodotto';*/
        update opp;
        
        Test.startTest();
        WGC_Opp_Home_Controller.WrapperCounter wrapper = WGC_Opp_Home_Controller.countOpty(opp);
        Test.stopTest();
    }

}