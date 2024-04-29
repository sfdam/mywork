@isTest
public with sharing class WGC_Chart_ControllerTest {

    @TestSetup
    public static void makeData(){
        // List<Account> accList = WGC_AllDataFactory.createAccount(1, true);
        // for()
        List<WGC_Posizione__c> positions = WGC_AllDataFactory.createPosizioni(3, true);
        Id IdAcc = positions[0].Anagrafica__c;
        List<WGC_Performance__c> performances = new List<WGC_Performance__c>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.WGC_Performance__c; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        for(Integer i = 0; i < 5; i++){
            Schema.RecordTypeInfo rtByName =  rtMapByName.values().get(i);
            WGC_Performance__c p = new WGC_Performance__c(
                Anagrafica__c = IdAcc,
                Actual__c = 100000,
                Actual_PY__c = 5000,
                Mese__c = String.valueOf(i),
                RecordTypeId = rtByName.getRecordTypeId()
            );
            performances.add(p);
        }
        Insert performances;
    }

    @isTest
    public static void test_getChartsMetadata(){
        Test.startTest();
            WGC_Chart_Controller.getChartsMetadata('Account_Monitoraggio');
        Test.stopTest();
    }

    @isTest
    public static void test_getChartDataGeneric(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        Map<String,Object> emptyParams = new Map<String,Object>();
        Map<String,Object> params = new Map<String,Object>{'accountId' => acc.Id};

        Test.startTest();
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Posizione_Cliente', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Posizione_Cliente', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Posizione_OutstandingDeb', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Posizione_OutstandingDeb', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Posizione_PlafondDeb', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Posizione_PlafondDeb', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Impiego', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Impiego', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Mdi', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Mdi', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_TurnoverCliente', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_TurnoverCliente', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Outstanding', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Outstanding', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Plafond', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_Plafond', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_TurnoverDebitore', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Account_Monitoraggio_TurnoverDebitore', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Opportunity_Monitoraggio_Redditivita', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Opportunity_Monitoraggio_Redditivita', null);

            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable','Base_Clienti_HP', emptyParams);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Clienti_Operativi_Factoring', emptyParams);

            WGC_Chart_Controller.getDataBaseclientiTable();

            //NO NDG
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_Impiego', emptyParams);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_Turnover', emptyParams);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_MDI', emptyParams);

        Test.stopTest();
    }

    @isTest
    public static void test_asuser(){

        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Sviluppo Commerciale Filiali']; 
        User u = new User(Alias = 'standt', Email='testuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testccuser@testorg.com', NDGGruppo__c = '111');
        insert u;

        Map<String,Object> emptyParams = new Map<String,Object>();

        Test.startTest();

        System.runAs(u){
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_Impiego', emptyParams);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_Impiego', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_Turnover', emptyParams);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_Turnover', null);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_MDI', emptyParams);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Tab_Monitoraggio_MDI', null);
        }

        Test.stopTest();
    }

    @isTest
    public static void test_ko(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Map<String,Object> params = new Map<String,Object>{'accountId' => acc.Id};

        Test.startTest();
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Opportunity_Monitoraggio_Volumi', params);
            WGC_Chart_Controller.getChartDataGeneric('WGC_Chart_Callable', 'Opportunity_Monitoraggio_Volumi', null);
        Test.stopTest();
    }
}