@isTest
public inherited sharing class WGC_Portafoglio_Debitori_ControllerTest {

    @TestSetup
    static void makeData(){
        
        Test.startTest();

        List<WGC_Posizione__c> positions = WGC_AllDataFactory.createPosizioni(3, true);
        Id IdAcc = positions[0].Anagrafica__c;

        Test.stopTest();
    }

    @isTest
    static void DebitoriTest(){

        Test.startTest();

        WGC_Portafoglio_Debitori_Controller.Debitori('','');

        Test.stopTest();
    }


}