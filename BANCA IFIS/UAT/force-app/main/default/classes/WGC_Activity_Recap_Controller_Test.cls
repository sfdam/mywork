@isTest
public class WGC_Activity_Recap_Controller_Test {
    @isTest
    public static void Test_WGC_Activity_Recap_Controller1(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createEvent(1,true);
        WGC_AllDataFactory.createOpportunity(1,true);
        User u = [SELECT Id,Qualifica_Utente__c FROM USer WHERE Id =: UserInfo.getUserId()];
        u.Qualifica_Utente__c = 'Filo Diretto';
        update u;
        
        Test.startTest();
        WGC_Activity_Recap_Controller.getHeaderData();
        Test.stopTest();
    }

    @isTest
    public static void Test_WGC_Activity_Recap_Controller2(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createEvent(1,true);
        List<Opportunity> listOpty = WGC_AllDataFactory.createOpportunity(3,true);

        User u = [SELECT Id,Qualifica_Utente__c FROM USer WHERE Id =: UserInfo.getUserId()];
        u.Qualifica_Utente__c = 'Filo Diretto';
        update u;

        Test.startTest();
        WGC_Activity_Recap_Controller.getHeaderData();
        WGC_Activity_Recap_Controller.getUserType(u.id);
        WGC_Activity_Recap_Controller.getUserType(null);

		u.Qualifica_Utente__c = 'Crediti Erariali';
        update u;
        WGC_Activity_Recap_Controller.getHeaderData();
        WGC_Activity_Recap_Controller.getUserType(u.id);
        WGC_Activity_Recap_Controller.getUserType(null);
		Test.stopTest();
    }

}