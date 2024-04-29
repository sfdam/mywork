@isTest
public inherited sharing class WGC_Portafoglio_Clienti_ControllerTest {

    @TestSetup
    static void makeData(){
        
        Test.startTest();

        List<WGC_Posizione__c> positions = WGC_AllDataFactory.createPosizioni(1, false);
        insert positions;

        Test.stopTest();
    }

    @isTest
    static void ClientiPerQualificaTest(){

        Test.startTest();

        //WGC_Portafoglio_Clienti_Controller.ClientiPerQualifica('','');
        WGC_Portafoglio_Clienti_Controller.clientiPerQualificaProgressive('','',Datetime.now(), 2, '');

        Test.stopTest();
    }

    @isTest
    static void ClientiPerProdottoTest(){

        Test.startTest();

        WGC_Portafoglio_Clienti_Controller.ClientiPerProdotto('','');

        Test.stopTest();
    }

}