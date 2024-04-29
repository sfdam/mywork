@isTest
public with sharing class CRM_EconomicIndicatorCtrl_Test {
        
        @TestSetup
        public static void setup(){
        
            ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
            PTF_Division__c = 'PE',
            PTF_MacroDivision__c = 'WM');
    
            ServiceModel__c family = new ServiceModel__c(Name = 'Family',
            PTF_Division__c = 'FP',
            PTF_MacroDivision__c = 'EB');
            insert new List<ServiceModel__c>{personal, family};
    
            Account banca = AllDataFactory.getAccount('10', 'Banca');
            banca.FinServ__BankNumber__c = '05387';
            insert banca;
            Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
            // dir.PTF_ABICED__c = '05387';
            dir.parentId = banca.Id;
            insert dir;
            Account area = AllDataFactory.getAccount('08', 'Area');
            // area.PTF_ABICED__c = '05387';
            area.parentId = dir.Id;
            insert area;
            Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
            // filiale.PTF_ABICED__c = '05387';
            filiale.parentId = area.Id;
            filiale.PTF_BranchTypology__c = 'A';
            insert filiale;

            Account customer = AllDataFactory.getPersonAccount('Test');
            insert customer;

            Account customer2 = AllDataFactory.getPersonAccount('Test2');
            insert customer2;


            CRM_IndicatoriCliente__c ind = new CRM_IndicatoriCliente__c();
            ind.CRM_Account__c = customer.Id;
            insert ind;

            CRM_IndicatoriCliente__c ind2 = new CRM_IndicatoriCliente__c();
            ind2.CRM_Account__c = customer2.Id;
            insert ind2;

            /*CRM_AccountAccountJointOwnershipRelation__c joinAcc = new CRM_AccountAccountJointOwnershipRelation__c();
            joinAcc.CRM_JointOwnership__c = customer2.id;
            joinAcc.CRM_Account__c = customer.id;
            joinAcc.CRM_Active__c = true;
            insert joinAcc;*/

    }
    @isTest
    public static void accountDataTest(){
        Account acc = [Select id from account where LastName = 'PersonTest'];
        test.startTest();
            Account accounts = CRM_EconomicIndicatorController.getAccountData(acc.id);
        Test.stopTest();
            System.debug('accounts' +accounts);
         System.assertEquals(true, accounts !=null);
    }

    @isTest
    public static void relazioniTest(){
        Account acc = [Select id from account where LastName = 'PersonTest'];
        test.startTest();
        Map<String,SObject> response = CRM_EconomicIndicatorController.getRelazioniAccount(acc.id);
        Test.stopTest();
        System.assertEquals(false, response.size()>0);
    }

    @isTest
    public static void getCointestazioniTest(){
        List<Account> accList = [Select id from account where RecordType.DeveloperName = 'PersonAccount'];
        List<String> accIdlist = new List<String>();
        for(account acc : accList){
            accIdlist.add(acc.id);
        }
        test.startTest();
        Map<String,Sobject> response = CRM_EconomicIndicatorController.getCointestazioni(accIdlist);
        Test.stopTest();
        System.assertEquals(false, response.size()>0);
    }

    @isTest
    public static void getIndicatoriClienteTest(){
        List<Account> accList = [Select id from account where RecordType.DeveloperName = 'PersonAccount'];
        List<String> accIdlist = new List<String>();
        for(account acc : accList){
            accIdlist.add(acc.id);
        }
        test.startTest();
        Map<String,Sobject> response = CRM_EconomicIndicatorController.getIndicatoriCliente(accIdlist);
        Test.stopTest();
        System.assertEquals(true, response.size()>0);
    }

    @isTest
    public static void getIndicatoriPFTest(){
        Account acc = [Select id from account where LastName = 'PersonTest'];
        test.startTest();
        Map<String,Sobject> response =  CRM_EconomicIndicatorController.getIndicatoriPF(acc.id);
        Test.stopTest();
        System.assertEquals(true, response.size()>0);

    }

    @isTest
    public static void getUser(){
        test.startTest();
        User response = CRM_EconomicIndicatorController.getUserInfo();
        Test.stopTest();
        System.assertEquals(true, response !=null);

    }
}