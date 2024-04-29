@isTest
public class WGC_HP_NewBusiness_Controller_Test {
    
    @TestSetup
    static void makeData(){

        WGC_AllDataFactory.disattivaTrigger();

        Account a = new Account();
        a.OwnerId = UserInfo.getUserId();
        a.Name = 'Account1';
        a.Email__c ='email1@test.it';
        a.WGC_Specialista_Leasing__c = UserInfo.getUserId();
        a.REA__c='34122';
        a.Ateco__c='';
        a.RAE__c = '3';
        a.NaturaGiuridica__c= 'AAA';
        a.CCIAA__c= '2188';
        a.ProvinciaCCIAA__c='MI';
        a.EventiNegativiIdTicket__c = '111';
        a.EventiNegativiGlobale__c = 'R';
        a.EventiNegativiProtesti__c = 'V'; 
        a.EventiNegativiPregiudizievoli__c = 'V';
        a.EventiNegativiProcedureConcorsuali__c = 'V';
        a.EventiNegativiCIGS__c = 'G';
        a.EventiNegativiAllarmiQuote__c = 'V';
        a.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
        a.WGC_Specialista_Filo_Diretto__c = UserInfo.getUserId();
        a.WGC_Specialista_Factoring__c = UserInfo.getUserId();
        //a.WGC_Gruppo__c= Math.mod(i, 2) == 0 ? true : false;
        a.WGC_Semaforo_Gianos__c = 'ROSSO';
        a.WGC_DataRichiestaCR__c=DateTime.now();
        a.DataInserimentoConsensi__c = System.Today();
        a.BillingState = 'TS';
        a.Ateco__c = '';
        a.Potenzialit_di_sviluppo__c = true;
        a.WGC_Qualifica_Corporate__c = 'Prospect';
        a.TAG_Controllante__c = '2';
        insert a;

        Account b = new Account();
        b.OwnerId = UserInfo.getUserId();
        b.Name = 'Account1';
        b.Email__c ='email1@test.it';
        b.WGC_Specialista_Leasing__c = UserInfo.getUserId();
        b.REA__c='34122';
        b.Ateco__c='';
        b.RAE__c = '3';
        b.NaturaGiuridica__c= 'AAA';
        b.CCIAA__c= '2188';
        b.ProvinciaCCIAA__c='MI';
        b.EventiNegativiIdTicket__c = '111';
        b.EventiNegativiGlobale__c = 'R';
        b.EventiNegativiProtesti__c = 'V'; 
        b.EventiNegativiPregiudizievoli__c = 'V';
        b.EventiNegativiProcedureConcorsuali__c = 'V';
        b.EventiNegativiCIGS__c = 'G';
        b.EventiNegativiAllarmiQuote__c = 'V';
        b.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
        b.WGC_Specialista_Filo_Diretto__c = UserInfo.getUserId();
        b.WGC_Specialista_Factoring__c = UserInfo.getUserId();
        //a.WGC_Gruppo__c= Math.mod(i, 2) == 0 ? true : false;
        b.WGC_Semaforo_Gianos__c = 'ROSSO';
        b.WGC_DataRichiestaCR__c=DateTime.now();
        b.DataInserimentoConsensi__c = System.Today();
        b.BillingState = 'TS';
        b.Ateco__c = '';
        b.WGC_Qualifica_Corporate_Data__c = Date.today();
        b.WGC_Qualifica_Corporate__c = 'Cliente attivo';
        b.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.today().addMonths(14);
        insert b;

        String rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IFISOpportunitaFactoring' AND SobjectType = 'Opportunity'].Id;

        Opportunity opp1 = new Opportunity();
        opp1.AccountId = a.Id;
        opp1.Name = 'Test';
        opp1.StageName = 'In Istruttoria';
        opp1.Tipologia_Opportunit__c = 'CONC';
        opp1.RecordTypeId = rtId;
        opp1.CloseDate = Date.today();
        insert opp1;

        Opportunity opp2 = new Opportunity();
        opp2.AccountId = a.Id;
        opp2.Name = 'Test2';
        opp2.StageName = 'In Istruttoria';
        opp2.Tipologia_Opportunit__c = 'CONC';
        opp2.RecordTypeId = rtId;
        opp2.CloseDate = Date.today();
        insert opp2;
        opp2.StageName = 'Valutazione Pratica';
        update opp2;

        Opportunity opp3 = new Opportunity();
        opp3.AccountId = a.Id;
        opp3.Name = 'Test3';
        opp3.StageName = 'In Istruttoria';
        opp3.Tipologia_Opportunit__c = 'CONC';
        opp3.RecordTypeId = rtId;
        opp3.CloseDate = Date.today();
        insert opp3;
        opp3.StageName = 'Perfezionamento Contratto';
        update opp3;

        Opportunity opp4 = new Opportunity();
        opp4.AccountId = b.Id;
        opp4.Name = 'Test4';
        opp4.StageName = 'In Istruttoria';
        opp4.Tipologia_Opportunit__c = 'CONC';
        opp4.RecordTypeId = rtId;
        opp4.CloseDate = Date.today();
        insert opp4;
        opp4.StageName = 'Vinta';
        opp4.WGC_Data_Fase_Chiusa_Vinta__c = Date.today();
        update opp4;
    }

    @isTest
    static void test(){
        Test.startTest();
        WGC_HomePageNew_NewBusiness_Controller.getData();
        Test.stopTest();
    }
}