@isTest
public class WGC_HomePageNew_Portafoglio_Cont_Test {
     @isTest
    public static void flowCarrello1() {
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(2);

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];
        Opportunity oppPersa = listOpp[1];
        
        
        acc.WGC_Qualifica_Corporate__c = 'Prospect';
        acc.WGC_Specialista_Factoring__c = UserInfo.getUserId();
        update acc;
        
        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'REVI';
        opp.StageName = 'In Istruttoria';
        insert opp;
		
        oppPersa.StageName = 'In Istruttoria';
		insert oppPersa;
        
		oppPersa.StageName = 'Persa';
        oppPersa.CloseDate = system.today()-5;
		update oppPersa;
        
        Test.startTest();
     
        WGC_HomePageNew_Portafoglio_Controller.WrapperData res =WGC_HomePageNew_Portafoglio_Controller.getData(); 

        Test.stopTest();
        

    }

}