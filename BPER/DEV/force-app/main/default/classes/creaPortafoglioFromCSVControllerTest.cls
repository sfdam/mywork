@isTest
public  class creaPortafoglioFromCSVControllerTest {
    
    @TestSetup
    public static void setup(){

        
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
		account4.PTF_IdCEDFiliale__c='1238';
        account4.FinServ__BankNumber__c='1234';
        account4.PTF_Banca__c=account.Id;
        account4.PTF_DirezioneRegionale__c=account2.Id;
        account4.PTF_Area__c=account3.Id; 
        insert account4;        
        Account account5 = AllDataFactory.getAccount('04', 'AltraUnitaOrganizzativa');
        Account5.PTF_IdCEDPadre__c='1716';
        insert account5;
        Account account6 = AllDataFactory.getAccount('04', 'AltraUnitaOrganizzativa');
        Account6.PTF_IdCEDPadre__c='8414';
        insert account6;        
        Contact contact = AllDataFactory.getContact('01', user.Id, account4.Id);
        contact.PTF_ReferenteElegibile__c=true;        
        Contact contact2 = AllDataFactory.getContact('02', user2.Id, account4.Id);
        contact2.PTF_ReferenteElegibile__c=true;        
        Contact contact3 = AllDataFactory.getContact('03', user3.Id, account4.Id);
        contact3.PTF_ReferenteElegibile__c=true;
        Contact contact5 = AllDataFactory.getContact('04', user3.Id, account3.Id);
        contact5.PTF_ReferenteElegibile__c=true;
        Contact contact6 = AllDataFactory.getContact('05', user3.Id, account5.Id);
        contact6.PTF_ReferenteElegibile__c=true; 
        Contact contact7 = AllDataFactory.getContact('06', user3.Id, account6.Id);
        contact7.PTF_ReferenteElegibile__c=true;        
        insert new List<Contact>{contact, contact2, contact3, contact5, contact6, contact7};

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', 'Filiale di Milano', 'CORPORATE');
        insert microPortafoglio;

        Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact.Id);
        insert primarioAssignment;

        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
		banca.PTF_IdCED__c='1234';
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
        area.PTF_IdCED__c='123456';
        insert area;


        Account filiale = AllDataFactory.getAccount('11', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Area__c= area.Id;
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=b.Id;
        filiale.PTF_IdCED__c='1238';
        filiale.PTF_IdCEDFiliale__c='1238';
        Account filiale2 = AllDataFactory.getAccount('12', 'FilialeDiRelazione');
        filiale2.PTF_Division__c='PR';
        filiale2.PTF_MacroDivision__c='WM';
        filiale2.PTF_Area__c= area.Id;
        filiale2.PTF_Banca__c=banca.Id;
        filiale2.PTF_DirezioneRegionale__c=b.Id;
        filiale2.PTF_BranchTypology__c='F';
        filiale2.PTF_IdCED__c='1239';
        filiale2.PTF_IdCEDFiliale__c='1239';
        insert new List<Account>{filiale, filiale2};
        Account uff = AllDataFactory.getAccount('22', 'AltraUnitaOrganizzativa');
        uff.PTF_IdCED__c='256';
        uff.PTF_Banca__c=banca.Id;
        uff.PTF_IdCEDPadre__c='1234';
        insert uff;
        Contact contact4 = AllDataFactory.getContact('14', user3.Id, filiale.Id);
        insert contact4;

        ServiceModel__c sm1= new ServiceModel__c();
        sm1.Name='Private';
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
    @isTest
    public static void testSaveMultipleMicroWallet(){

       
		Test.startTest();
        String eddy = '[{"PTFnum": "'+'0'+'",'+
                    '"modelloServizio": "'+'Private'+'",'+
                    '"abi": "'+'05387'+'",'+
                    '"cedfiliale": "'+'3134'+'",'+
                    '"matricola": "'+'11750'+'"}]';
                    System.Debug('EDDYY '+eddy);

        List<creaPortafoglioFromCSVController.WrapperResult> result = creaPortafoglioFromCSVController.getStrutturaFiliale(eddy);
        //Boolean response = creaPortafoglioFromCSVController.saveMicroWalletFromCSV(result);
        Test.stopTest();
    }

    @isTest
    static void TestShare() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser){
            UserRole role1= new UserRole();
            role1.DeveloperName='RIDCED1234';
            role1.Name=role1.DeveloperName;
            UserRole role2= new UserRole();
            role2.DeveloperName='RIDCED12345';
            role2.Name=role2.DeveloperName;
            UserRole role3= new UserRole();
            role3.DeveloperName='RIDCED123456';
            role3.Name=role3.DeveloperName;
            UserRole role4= new UserRole();
            role4.DeveloperName='RIDCED991';
            role4.Name=role4.DeveloperName;
            UserRole role5= new UserRole();
            role5.DeveloperName='RIDCED1238';
            role5.Name=role5.DeveloperName;
            UserRole role6= new UserRole();
            role6.DeveloperName='RIDCED1239';
            role6.Name=role6.DeveloperName;
            UserRole role7= new UserRole();
            role7.DeveloperName='RIDCED256';
            role7.Name=role7.DeveloperName;
            insert new List<UserRole>{role1, role2, role3, role4, role5, role6, role7};
            Group g = new Group();
            g.developerName='CP1_998';
            g.Name=g.DeveloperName;
            g.Type='Regular';
            insert g;
        }
       
        List<Contact> contactList = [SELECT id FROM Contact WHERE Account.PTF_IDCed__c = '1238'];
        Account filiale = [SELECT Id, PTF_Banca__c, PTF_DirezioneRegionale__c, PTF_Area__c FROM Account WHERE PTF_IDCed__c = '1238' LIMIT 1];
        Test.startTest();
        String eddy = '[{"PTFnum": "'+'0'+'",'+
                    '"modelloServizio": "'+'Private'+'",'+
                    '"abi": "'+'05387'+'",'+
                    '"cedfiliale": "'+'3134'+'",'+
                    '"matricola": "'+'11750'+'"}]';
                    
                    System.Debug('EDDYY '+eddy);

        List<creaPortafoglioFromCSVController.WrapperResult> result = creaPortafoglioFromCSVController.getStrutturaFiliale(eddy);

        //Boolean response = creaPortafoglioFromCSVController.saveMicroWalletFromCSV(result);
        Test.stopTest();


    }
    @isTest
    public static void testRunMethod() {
        creaPortafoglioFromCSVController.testRun();
    }
    @isTest
    public static void testRunMethodBatch() {
        creaPortafoglioFromCSVController_V2.testRun();
        creaPortafoglioFromCSVBatch.testRun();
    }
    @isTest
    public static void testBatch() 
    {
        SV_CSVLoad__c csvload = new SV_CSVLoad__c();
        csvload.Status__c = 'Pending';
        insert csvload;
        object mtdCsvFile = 'Test';
        object mtdCsvName = 'Test';
        list<string> mtdFileRows = new list<string>();
        boolean errore = false;
        mtdFileRows.add('Personal,1234,1238,,Portafoglio tecnico,2\n'
        );
        //mtdFileRows.add('Personal,01015,433,,Microportafoglio,3\n'
        //);
        //mtdFileRows.add('POE,01015,378,,Microportafoglio,4\n'
        //);
        creaPortafoglioFromCSVController_V2.upldFile(mtdCsvFile, mtdCsvName, mtdFileRows,errore,csvload.Id);
    }
    @isTest
    public static void testBatchError() 
    {
        SV_CSVLoad__c csvload = new SV_CSVLoad__c();
        csvload.Status__c = 'Pending';
        insert csvload;
        object mtdCsvFile = 'Test';
        object mtdCsvName = 'Test';
        list<string> mtdFileRows = new list<string>();
        boolean errore = true;
        mtdFileRows.add('Personal,01015,631,,Portafoglio tecnico,2\n'
        );
        mtdFileRows.add('Personal,01015,433,,Microportafoglio,3\n'
        );
        mtdFileRows.add('POE,01015,378,,Microportafoglio,4\n'
        );
        creaPortafoglioFromCSVController_V2.upldFile(mtdCsvFile, mtdCsvName, mtdFileRows,errore,csvload.Id);
    }
}