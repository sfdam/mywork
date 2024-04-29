@isTest
public  class openFilteredReportControllerTest {

    @TestSetup
    public static void setup(){
        
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        
        dir.parentId = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        
        area.parentId = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.CRM_Nome__C = '2011 - MILANO - AGENZIA 13';
        insert filiale;

        List<Struttura_Banca__c> sbs = new List<Struttura_Banca__c>();
        Struttura_Banca__c sb1 = new Struttura_Banca__c(
            IdCed__c='12347',
            Descrizione__c ='T12347',
            Stato__c='A'
        );
        Struttura_Banca__c sb2 = new Struttura_Banca__c(
            IdCed__c='12348',
            IDCed_Padre__c='12347',
            Descrizione__c ='T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348',
            Stato__c='A'
        );
        sbs.add(sb1);
        sbs.add(sb2);
        
        insert sbs;
    }

    @isTest
    public static void testMethod1(){

        Map<String,sObject> mapStruttura = openFilteredReportController.getStrutturaBanca();

    }

    @isTest
    public static void testMethod2(){

        String idFiliale = [SELECT ID FROM ACCOUNT WHERE RecordType.DeveloperName = 'FilialeDiRelazione' LIMIT 1].id;

        String stringFiliale = openFilteredReportController.getIdCedFiliale(idFiliale);

    }

    @isTest
    public static void testMethod3(){

        String idCed = [SELECT ID, PTF_IdCED__c FROM ACCOUNT  LIMIT 1].PTF_IdCED__c;

        String idFiliale = openFilteredReportController.getAccountId(idCed);
    }

    @isTest
    public static void testMethod4(){

        //Report_Super_User__mdt mtdTest = [SELECT Id, Nome_Report__c,DeveloperName FROM Report_Super_User__mdt LIMIT 1 ];

        Map<String,sObject> mtd = openFilteredReportController.getReportName();
    }
    @isTest
    public static void testRunMethod() {
        openFilteredReportController.testRun();
    }




    
}