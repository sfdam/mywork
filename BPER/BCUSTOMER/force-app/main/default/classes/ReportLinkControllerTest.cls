@IsTest
public class ReportLinkControllerTest {
    /*@TestSetup
    static void makeData(){
        //SampleReportClosedSales
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='05387';
        banca.PTF_IdCed__c='123456';
        Account banca2= AllDataFactory.getAccount('Banca2','Banca');
        banca2.FinServ__BankNumber__c='01015';

        insert new List<Account>{banca, banca2};

        Account dr= AllDataFactory.getAccount('DR','DirezioneRegionale');
        dr.PTF_Banca__c=banca.Id;

        insert dr;

        Account area = AllDataFactory.getAccount('Area','Area');
        area.PTF_DirezioneRegionale__c=dr.Id;
        area.PTF_Banca__c=banca.Id;
        insert area;

        Account ufficio = AllDataFactory.getAccount('01', 'AltraUnitaOrganizzativa');
        ufficio.Name='TestUfficio';
        ufficio.PTF_IdCED__c='123';
        ufficio.PTF_IdCEDPadre__c='123456';
        insert ufficio;

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Area__c= area.Id;
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=dr.Id;
        filiale.PTF_IdCEDFiliale__c='1238';
        filiale.PTF_IdCED__c='1238';
        Account filiale2 = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        filiale2.PTF_Area__c= area.Id;
        filiale2.PTF_Banca__c=banca.Id;
        filiale2.PTF_DirezioneRegionale__c=dr.Id;
        filiale2.PTF_BranchTypology__c='E';
        filiale.PTF_IdCEDFiliale__c='1239';
        filiale2.PTF_IdCED__c='1239';
        insert filiale;
        filiale2.PTF_Capofila__c=filiale.Id;
        insert filiale2;

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        user.FederationIdentifier='01';
        user.IdCed__c='1238';
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        user2.idced__c='1239';
        user2.FederationIdentifier='02';
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        user3.FederationIdentifier='03';
        user3.idced__c='123';
        insert new List<User>{user, user2,user3};
    }*/

    @isTest(SeeAllData=true)
    private static void test1(){
        ReportLinkController.init('8445', 'SampleReportClosedSales');
    }
    @isTest(SeeAllData=true)
    private static void test2(){
        ReportLinkController.init('16', 'SampleReportClosedSales');
    }
    @isTest(SeeAllData=true)
    private static void test3(){
        ReportLinkController.init('157', 'SampleReportClosedSales');
    }
        @isTest(SeeAllData=true)
    private static void test4(){
        ReportLinkController.init('3982', 'SampleReportClosedSales');
    }
}