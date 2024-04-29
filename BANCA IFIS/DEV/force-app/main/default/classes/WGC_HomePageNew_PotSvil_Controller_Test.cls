@isTest
public class WGC_HomePageNew_PotSvil_Controller_Test {
    
    @isTest
    static void test(){

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
        b.Potenzialit_di_sviluppo__c = true;
        b.WGC_Qualifica_Corporate__c = 'Prospect';
        b.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.today().addMonths(14);
        insert b;

        Account c = new Account();
        c.OwnerId = UserInfo.getUserId();
        c.Name = 'Account1';
        c.Email__c ='email1@test.it';
        c.WGC_Specialista_Leasing__c = UserInfo.getUserId();
        c.REA__c='34122';
        c.Ateco__c='';
        c.RAE__c = '3';
        c.NaturaGiuridica__c= 'AAA';
        c.CCIAA__c= '2188';
        c.ProvinciaCCIAA__c='MI';
        c.EventiNegativiIdTicket__c = '111';
        c.EventiNegativiGlobale__c = 'R';
        c.EventiNegativiProtesti__c = 'V'; 
        c.EventiNegativiPregiudizievoli__c = 'V';
        c.EventiNegativiProcedureConcorsuali__c = 'V';
        c.EventiNegativiCIGS__c = 'G';
        c.EventiNegativiAllarmiQuote__c = 'V';
        c.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
        c.WGC_Specialista_Filo_Diretto__c = UserInfo.getUserId();
        c.WGC_Specialista_Factoring__c = UserInfo.getUserId();
        //a.WGC_Gruppo__c= Math.mod(i, 2) == 0 ? true : false;
        c.WGC_Semaforo_Gianos__c = 'ROSSO';
        c.WGC_DataRichiestaCR__c=DateTime.now();
        c.DataInserimentoConsensi__c = System.Today();
        c.BillingState = 'TS';
        c.Ateco__c = '';
        c.Potenzialit_di_sviluppo__c = true;
        c.WGC_Qualifica_Corporate__c = 'Debitore attivo';
        c.TAG_Controllante__c = '2';
        c.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.today().addMonths(14);
        insert c;

        Account d = new Account();
        d.OwnerId = UserInfo.getUserId();
        d.Name = 'Account1';
        d.Email__c ='email1@test.it';
        d.WGC_Specialista_Leasing__c = UserInfo.getUserId();
        d.REA__c='34122';
        d.Ateco__c='';
        d.RAE__c = '3';
        d.NaturaGiuridica__c= 'AAA';
        d.CCIAA__c= '2188';
        d.ProvinciaCCIAA__c='MI';
        d.EventiNegativiIdTicket__c = '111';
        d.EventiNegativiGlobale__c = 'R';
        d.EventiNegativiProtesti__c = 'V'; 
        d.EventiNegativiPregiudizievoli__c = 'V';
        d.EventiNegativiProcedureConcorsuali__c = 'V';
        d.EventiNegativiCIGS__c = 'G';
        d.EventiNegativiAllarmiQuote__c = 'V';
        d.WGC_UltimaRichiestaEventiNegativi__c = Date.newInstance(2019,01,01);
        d.WGC_Specialista_Filo_Diretto__c = UserInfo.getUserId();
        d.WGC_Specialista_Factoring__c = UserInfo.getUserId();
        //a.WGC_Gruppo__c= Math.mod(i, 2) == 0 ? true : false;
        d.WGC_Semaforo_Gianos__c = 'ROSSO';
        d.WGC_DataRichiestaCR__c=DateTime.now();
        d.DataInserimentoConsensi__c = System.Today();
        d.BillingState = 'TS';
        d.Ateco__c = '';
        d.Potenzialit_di_sviluppo__c = true;
        d.WGC_Qualifica_Corporate__c = 'Ex cliente';
        d.WGC_Data_ultima_attivita_SvilCommFiliali__c = Date.today().addMonths(14);
        insert d;

        String rtId = [SELECT Id FROM RecordType WHERE SobjectType = 'WGC_Linea_Prodotto__c' AND DeveloperName  = 'FACTORINGCEDENTE'].Id;

        WGC_Linea_Prodotto__c lp = new WGC_Linea_Prodotto__c();
        lp.Name = 'LineaProd';
        lp.Anagrafica__c = a.Id;
        lP.Accordato__c=1000;
        lp.RecordTypeId = rtId;
        lp.Stato__c = 'Attivo';
        insert lp;

        Test.startTest();
        WGC_HomePageNew_PotSvil_Controller.getData();
        Test.stopTest();
    }
    
}