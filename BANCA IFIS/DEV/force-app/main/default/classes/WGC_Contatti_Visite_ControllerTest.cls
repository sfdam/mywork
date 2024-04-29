@isTest
public inherited sharing class WGC_Contatti_Visite_ControllerTest {

    @TestSetup
    static void makeData(){
        
        Test.startTest();

        List<WGC_Posizione__c> positions = WGC_AllDataFactory.createPosizioni(1, false);
        insert positions;

        Test.stopTest();
    }

    @isTest
    static void VisiteCompletateTest(){

        Test.startTest();

        WGC_Contatti_Visite_Controller.VisiteCompletate('','');

        Test.stopTest();
    }

    @isTest
    static void ContattiTest(){

        Test.startTest();

        WGC_Contatti_Visite_Controller.Contatti('','');

        Test.stopTest();
    }

}