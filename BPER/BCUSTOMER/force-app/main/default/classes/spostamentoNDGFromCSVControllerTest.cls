@isTest
public class spostamentoNDGFromCSVControllerTest 
{
    @TestSetup
    public static void setup()
    {
        Funzionalita__c x= new Funzionalita__c();
        x.Disable_Trigger__c=true;
        insert x;
        Profile profile = [SELECT id FROM Profile WHERE Name=: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        User user2 = AllDataFactory.getUser('02', profile.Id, 'CORPORATE');
        User user3 = AllDataFactory.getUser('03', profile.Id, 'CORPORATE');
        insert new List<User>{user, user2, user3};
        System.runAs(user){
            Account account = AllDataFactory.getAccount('01', 'Banca');
            account.PTF_IdCED__c='1716';
            Account account2 = AllDataFactory.getAccount('02', 'DirezioneRegionale');
            account2.PTF_IdCED__c='8414';        
            Account account3 = AllDataFactory.getAccount('03', 'Area');
            account3.PTF_IdCED__c='5071';        
            Account account4 = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
                
            insert new List<Account>{account, account2, account3};
            account4.PTF_IdCEDFiliale__c='675';
            account4.FinServ__BankNumber__c='05387';
            account4.PTF_Banca__c=account.Id;
            account4.PTF_DirezioneRegionale__c=account2.Id;
            account4.PTF_Area__c=account3.Id; 
            insert account4;
            Contact contact = AllDataFactory.getContact('01', user.Id, account4.Id);
            contact.PTF_ReferenteElegibile__c=true;    
            insert contact;
            Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', 'Filiale di Milano', 'Family');
            microPortafoglio.name = 'PTF-FA-05387-3311-000001';
            insert microPortafoglio;
            Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', 'Filiale di Milano', 'Family');
            microPortafoglio2.name = 'PTF-FA-05387-0726-000001';
            insert microPortafoglio2;

            Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact.Id);
            insert primarioAssignment;

            Account banca= AllDataFactory.getAccount('Banca','Banca');
            banca.FinServ__BankNumber__c='675';
            banca.PTF_IdCED__c='675';
            insert banca;
            
            Account a = new Account();
            a.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'AltraUnitaOrganizzativa');
            a.Name = 'UFF. Private test';
            a.PTF_IdCED__c = '998';
            insert a;
            Account b = new Account();
            b.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'DirezioneRegionale');
            b.Name = 'Direzione Reg Test';
            b.PTF_IdCED__c = '991';
            insert b;
            ConfigUffPrivateDR__c c = new ConfigUffPrivateDR__c();
            c.Name = 'TEST';
            c.PTF_DR__c = b.Id;
            c.PTF_UffPrivate__c = a.Id;
            c.PTF_IdCP__c='CP1';
            Insert c;
            
            Account area = AllDataFactory.getAccount('Area','Area');
            area.PTF_DirezioneRegionale__c=b.Id;
            area.PTF_Banca__c=banca.Id;
            area.PTF_IdCED__c='675';
            insert area;

            Account ndg = new Account();
            ndg.Name = 'Test';
            ndg.CRM_NDG__c = '3396571';
            ndg.FinServ__BankNumber__c = '05387';
            ndg.PTF_Portafoglio__c = microPortafoglio.Id;
            insert ndg;

            Account filiale = AllDataFactory.getAccount('11', 'FilialeDiRelazione');
            filiale.PTF_BranchTypology__c='F';
            filiale.PTF_Area__c= area.Id;
            filiale.PTF_Banca__c=banca.Id;
            filiale.PTF_DirezioneRegionale__c=b.Id;
            filiale.PTF_IdCED__c='726';
            filiale.PTF_IdCEDFiliale__c='726';
            Account filiale2 = AllDataFactory.getAccount('12', 'FilialeDiRelazione');
            filiale2.PTF_Division__c='PR';
            filiale2.PTF_MacroDivision__c='WM';
            filiale2.PTF_Area__c= area.Id;
            filiale2.PTF_Banca__c=banca.Id;
            filiale2.PTF_DirezioneRegionale__c=b.Id;
            filiale2.PTF_BranchTypology__c='F';
            filiale2.PTF_IdCED__c='6751';
            filiale2.PTF_IdCEDFiliale__c='6751';
            insert new List<Account>{filiale, filiale2};
            Account uff = AllDataFactory.getAccount('22', 'AltraUnitaOrganizzativa');
            uff.PTF_IdCED__c='256';
            uff.PTF_Banca__c=banca.Id;
            uff.PTF_IdCEDPadre__c='1234';
            insert uff;
            Contact contact4 = AllDataFactory.getContact('14', user3.Id, filiale.Id);
            insert contact4;

            ServiceModel__c sm1= new ServiceModel__c();
            sm1.Name='Family';
            sm1.PTF_TresholdPTF__c=0;
            ServiceModel__c sm2= new ServiceModel__c();
            sm2.Name='CORPORATE';
            sm2.PTF_TresholdPTF__c=99;
            ServiceModel__c sm3= new ServiceModel__c();
            sm3.Name='Consulenti Finanziari';
            sm3.PTF_TresholdPTF__c=99;
            ServiceModel__c sm4= new ServiceModel__c();
            sm4.Name='Personal';
            sm4.PTF_TresholdPTF__c=99;
            insert new List<ServiceModel__c>{sm1, sm2, sm3, sm4};  
        }
    }
    /*@isTest
    public static void testRunMethodBatch() {
        spostamentoNDGFromCSVController.testRun();
        creaPortafoglioFromCSVBatch.testRun();
    }*/
    @isTest
    public static void testUpload() 
    {
        SV_CSVLoad__c csvload = new SV_CSVLoad__c();
        csvload.Status__c = 'Pending';
        insert csvload;
        object mtdCsvFile = 'Test';
        object mtdCsvName = 'Test';
        list<string> mtdFileRows = new list<string>();
        boolean erroreRighe = false;
        boolean erroreSeparatore = false;
        mtdFileRows.add('05387;3396571;726;Family;PTF-FA-05387-3311-000001;PTF-FA-05387-0726-000001;;;;2\n'
        );
        //mtdFileRows.add('Personal,01015,433,,Microportafoglio,3\n'
        //);
        //mtdFileRows.add('POE,01015,378,,Microportafoglio,4\n'
        //);
        spostamentoNDGFromCSVController.upldFile(mtdCsvFile, mtdCsvName, mtdFileRows, erroreRighe, erroreSeparatore, csvload.Id);
        spostamentoNDGFromCSVController.reuploadFile(csvload.Id);
    }
    @isTest
    public static void testUploadError() 
    {
        SV_CSVLoad__c csvload = new SV_CSVLoad__c();
        csvload.Status__c = 'Pending';
        insert csvload;
        object mtdCsvFile = 'Test';
        object mtdCsvName = 'Test';
        list<string> mtdFileRows = new list<string>();
        boolean erroreRighe = false;
        boolean erroreSeparatore = false;
        mtdFileRows.add('05387;17708212;675;Personal;PTF-FA-05387-3311-000001;PTF-PE-01015-0675-000103;;;;2\n'
        );
        mtdFileRows.add('05387;17708212;675;Personal;PTF-FA-05387-3311-000001;PTF-FA-05387-3311-000001;;;;3\n'
        );
        mtdFileRows.add('15387;17630049;675;Personal;PTF-FA-05387-3311-000001;PTF-PE-01015-0675-000103;;;;4\n'
        );
        //mtdFileRows.add('05387;17708212;675;Personal;PTF-FA-05387-3311-000001;PTF-PE-01015-0675-000103;;;;5\n'
        //);
        spostamentoNDGFromCSVController.upldFile(mtdCsvFile, mtdCsvName, mtdFileRows,erroreRighe, erroreSeparatore,csvload.Id);
    }
    @isTest
    public static void testUploadError2() 
    {
        SV_CSVLoad__c csvload = new SV_CSVLoad__c();
        csvload.Status__c = 'Pending';
        insert csvload;
        object mtdCsvFile = 'Test';
        object mtdCsvName = 'Test';
        list<string> mtdFileRows = new list<string>();
        boolean erroreRighe = false;
        boolean erroreSeparatore = true;
        mtdFileRows.add('05387,17708212,675,Personal,PTF-FA-05387-3311-000001,PTF-PE-01015-0675-000103,,,,2\n'
        );
        spostamentoNDGFromCSVController.upldFile(mtdCsvFile, mtdCsvName, mtdFileRows,erroreRighe, erroreSeparatore,csvload.Id);
    }
    @isTest
    public static void testUploadError3() 
    {
        SV_CSVLoad__c csvload = new SV_CSVLoad__c();
        csvload.Status__c = 'Pending';
        insert csvload;
        object mtdCsvFile = 'Test';
        object mtdCsvName = 'Test';
        list<string> mtdFileRows = new list<string>();
        boolean erroreRighe = true;
        boolean erroreSeparatore = false;
        mtdFileRows.add('05387,17708212,675,Personal,PTF-FA-05387-3311-000001,PTF-PE-01015-0675-000103,,,,2\n'
        );
        spostamentoNDGFromCSVController.upldFile(mtdCsvFile, mtdCsvName, mtdFileRows,erroreRighe, erroreSeparatore,csvload.Id);
    }
}