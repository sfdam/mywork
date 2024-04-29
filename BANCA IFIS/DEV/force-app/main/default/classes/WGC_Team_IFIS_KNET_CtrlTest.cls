@isTest
public without sharing class WGC_Team_IFIS_KNET_CtrlTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'TestTeamIFISKNET', NDGGruppo__c = '12235236352');
        insert acc;

        Account acc2 = new Account(Name = 'TestTeamIFISKNET_DATA', NDGGruppo__c = '12235236353', WGC_Data_ultima_chiamata_Team_IFIS_KNET__c = System.Today());
        insert acc2;

        EndpointServizi__c es = new EndpointServizi__c(
            Name = 'settings',
            WGC_Url_Team_IFIS_Knet__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/factoring/datigestionalisoggetto/read',
            LAGKey__c = 'test'
        );
        insert es;

        GestioneLog__c glog = new GestioneLog__c(
            Name = 'default',
            WGC_Url_Team_IFIS_Knet__c = true
        );
        insert glog;
    }

    @isTest
    static void getReferentiKNET_OK(){

        Test.setMock(HttpCalloutMock.Class, new WGC_HttpRequestController_MockImpl());

        Account acc = [SELECT Id FROM Account WHERE NDGGruppo__c = '12235236352' LIMIT 1];

        Test.startTest();
            WGC_Team_IFIS_KNET_Ctrl.getReferentiKNET(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getReferentiKNET_KO(){

        Test.setMock(HttpCalloutMock.Class, new WGC_HttpRequestController_MockImpl());

        Account acc = [SELECT Id FROM Account  WHERE NDGGruppo__c = '12235236353' LIMIT 1];

        Test.startTest();
            WGC_Team_IFIS_KNET_Ctrl.getReferentiKNET(acc.Id);
        Test.stopTest();
    }
}