@isTest
public class wgc_Header_Magazziono_Controller_Test {
    @isTest
    public static void test_method(){
        
        Test.startTest();
        Integer num = wgc_Header_Magazziono_Controller.countMagazzionoAperto();
        Test.stopTest();
    }
    @isTest
    public static void flowCarrello1() {
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AlldataFactory.createAccount(1, true);
        List<Opportunity> listOpp = WGC_AlldataFactory.createOpportunity2(1);

        Prodotto__c prod = new Prodotto__c();
        Parametro__c parameter = new Parametro__c();
        List<WizardOpportunityController.WrapperProduct> listWP = new List<WizardOpportunityController.WrapperProduct>();
        WizardOpportunityController.WrapperProduct wp = new WizardOpportunityController.WrapperProduct();
        wp.codice = prod.CodiceUnivoco__c = '111';
        wp.name = prod.WGC_Famiglia__c = 'Factoring';
        wp.area = prod.WGC_Area__c = 'Factoring - Cedente';
        wp.tipoCrossSelling = prod.WGC_Tipo_Cross_Selling__c = 'IFISOpportunitaFactoring';
        wp.subProductForm = prod.WGC_ConfigurazioneFormSubProduct__c = '';
        wp.icona = prod.WGC_Icona__c = 'utility:close';
        listWP.add(wp);
        insert prod;
        parameter.NumeroParametro__c = 'TEST1';
        parameter.Tipo__c = 'Parametro nascosto';
        parameter.Tipologia__c = 'Picklist';
        insert parameter;

        Account acc = listAcc[0];
        Opportunity opp = listOpp[0];

        List<Task> taskList = WGC_AlldataFactory.createTask(1);
        List<Event> eventList = WGC_AlldataFactory.createEvent(1);
        eventList[0].WhatId = taskList[0].WhatId = acc.Id;
        eventList[0].Originator__c = taskList[0].Originator__c = 'Diretto';
        eventList[0].Originator_di_dettaglio__c = taskList[0].Originator_di_dettaglio__c = 'Rete Commerciale Italia';

        insert taskList;
        insert eventList;

        WGC_TrgOpportunity.excuteInTest = true;
        opp.AccountId = acc.Id;
        opp.Tipologia_Opportunit__c = 'CONC';
        insert opp;

        ParametroProdotto__c newParam = new ParametroProdotto__c(Dominio__c = 'TEST;TEST2', SoloDeroga__c = true, Default__c = 'TEST', Sezione__c = 'PN01', Prodotto__c = prod.Id, Parametro__c = parameter.Id);
        insert newParam;
        CtrlWizardOpportunity.WoConfigurazioneParametro param = new CtrlWizardOpportunity.WoConfigurazioneParametro();
        param.id = newParam.Id;
        param.dominioVal = newParam.Dominio__c;
        param.soloDeroga = newParam.SoloDeroga__c;
        param.defaultval = newParam.Default__c;
        param.sezione = newParam.Sezione__c;

        List<User> utenti = new List<User>();
        utenti.add(TestUtils.creaUtente('leasing'));
        utenti[0].Qualifica_Utente__c = 'Leasing EF';
        utenti.add(TestUtils.creaUtente('intern'));
        utenti[1].Qualifica_Utente__c = 'IFIS_International';
        update utenti;

        Test.startTest();
		Integer num = wgc_Header_Magazziono_Controller.countMagazzionoAperto();
        Test.stopTest();
    }

}