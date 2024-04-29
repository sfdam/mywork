@isTest
private with sharing class Batch_AllgnPublicGroupsPTFTest {
    @TestSetup
    static void setup(){
        TriggerControl__c tc = new TriggerControl__c();
        tc.name = 'TEST';
        insert tc;

        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;

        Account filiale2 = AllDataFactory.getAccount('30', 'FilialeDiRelazione');
        filiale2.FinServ__BankNumber__c = '05387';
        filiale2.parentId = area.Id;
        filiale2.PTF_BranchTypology__c = 'A';
        filiale2.PTF_Banca__c = banca.Id;
        filiale2.PTF_DirezioneRegionale__c = dir.Id;
        filiale2.PTF_Area__c = area.Id;

        Account ufficioPersonal = AllDataFactory.getAccount('110', 'AltraUnitaOrganizzativa');
        // filiale.PTF_ABICED__c = '05387';
        ufficioPersonal.parentId = area.Id;
        ufficioPersonal.PTF_BranchTypology__c = 'A';
        ufficioPersonal.PTF_Division__c = 'PE';
        ufficioPersonal.PTF_MacroDivision__c = 'WM';
        ufficioPersonal.PTF_IdCed__c = '7894';
        Account ufficioFamily = AllDataFactory.getAccount('111', 'AltraUnitaOrganizzativa');
        // filiale.PTF_ABICED__c = '05387';
        ufficioFamily.parentId = area.Id;
        ufficioFamily.PTF_BranchTypology__c = 'A';
        ufficioFamily.PTF_Division__c = 'FP';
        ufficioFamily.PTF_MacroDivision__c = 'EB';
        ufficioFamily.PTF_IdCed__c = '5612';
        insert new List<Account>{filiale, filiale2, ufficioPersonal, ufficioFamily};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioFamily2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        Wallet__c microPortafoglioPersonal2 = AllDataFactory.getWallet('MicroWallet',  filiale2.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal, microPortafoglioFamily2, microPortafoglioPersonal2};

        // Relazione Di Cointestazione
        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount.PTF_Filiale__c = filiale.Id;

        Account personAccount2 = AllDataFactory.getAccount('02', 'PersonAccount');
        personAccount2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        personAccount2.PTF_Filiale__c = filiale.Id;

        Account personAccount3 = AllDataFactory.getAccount('03', 'PersonAccount');
        personAccount3.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount3.PTF_Filiale__c = filiale.Id;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;

        // Gruppo
        Account gruppo = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('06', 'IndustriesBusiness');
        business.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        business.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account06';

        Account business2 = AllDataFactory.getAccount('07', 'IndustriesBusiness');
        business2.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        business2.PTF_Filiale__c = filiale.Id;
        business.CRM_NDG__c = 'Account07';

        insert new List<Account>{personAccount, personAccount2, personAccount3, cointestazione, gruppo, business, business2};

        CRM_LinkedNDG__c capoGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business.Id,
            CRM_LinkCode__c = '113',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CAPOGRUPPO'
        );
        CRM_LinkedNDG__c membroGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business2.Id,
            CRM_LinkCode__c = '165',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CONN.GIUR.'
        );
        insert new List<CRM_LinkedNDG__c>{capoGruppo, membroGruppo};

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazionePrimario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazionePrimario.CRM_PrimaryNDG__c = true;
        relazioneDiCointestazionePrimario.CRM_Account__c = personAccount.Id;
        relazioneDiCointestazionePrimario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazionePrimario.CRM_Active__c = true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario.CRM_PrimaryNDG__c = false;
        relazioneDiCointestazioneCointestatario.CRM_Account__c = personAccount2.Id;
        relazioneDiCointestazioneCointestatario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazioneCointestatario.CRM_Active__c = true;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazioneCointestatario2 = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazioneCointestatario2.CRM_PrimaryNDG__c = false;
        relazioneDiCointestazioneCointestatario2.CRM_Account__c = personAccount3.Id;
        relazioneDiCointestazioneCointestatario2.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazioneCointestatario2.CRM_Active__c = true;
        insert new List<CRM_AccountAccountJointOwnershipRelation__c>{relazioneDiCointestazionePrimario, relazioneDiCointestazioneCointestatario, relazioneDiCointestazioneCointestatario2};

        Map<String, SObject> profileMap = SV_Utilities.keyBy([SELECT id, Name FROM Profile], 'Name');
        
        User user = AllDataFactory.getUser('10', profileMap.get(Label.System_Administrator).Id, 'Personal');
        user.FederationIdentifier='10';
        user.Profilo__c = 'ADMIN';
        user.abi__c='05387';
        user.idced__c='5385'; 
        User ufficioModelliDistributivi = AllDataFactory.getUser('11', profileMap.get('NEC_D.0').Id, 'Personal');
        ufficioModelliDistributivi.FederationIdentifier = '11';
        ufficioModelliDistributivi.Profilo__c = 'NEC_D.0';
        ufficioModelliDistributivi.abi__c='05387';
        ufficioModelliDistributivi.idced__c='5385'; 
        User NECF1 = AllDataFactory.getUser('14', profileMap.get('NEC_F.1').Id, 'Family');
        NECF1.FederationIdentifier = '14';
        NECF1.Profilo__c = 'NEC_F.1';
        NECF1.abi__c='05387';
        NECF1.idced__c='5385'; 

        User NECA1 = AllDataFactory.getUser('15', profileMap.get('NEC_A.1').Id, 'Family');
        NECA1.FederationIdentifier = '15';
        NECA1.Profilo__c = 'NEC_A.1';
        NECA1.abi__c='05387';
        NECA1.idced__c='8553';

        User NECT4Family = AllDataFactory.getUser('16', profileMap.get('NEC_T.4').Id, 'Family');
        NECT4Family.FederationIdentifier = '16';
        NECT4Family.Profilo__c = 'NEC_T.4';
        NECT4Family.abi__c='05387';
        NECT4Family.idced__c='5612';

        User NECT4Personal = AllDataFactory.getUser('17', profileMap.get('NEC_T.4').Id, 'Personal');
        NECT4Personal.FederationIdentifier = '17';
        NECT4Personal.Profilo__c = 'NEC_T.4';
        NECT4Personal.abi__c='05387';
        NECT4Personal.idced__c='7894'; 
        insert new List<User>{user, ufficioModelliDistributivi, NECF1, NECA1, NECT4Family};

        System.runAs(user){

            Contact contactUfficioModelliDistributivi = AllDataFactory.getContact('01', ufficioModelliDistributivi.Id, banca.id);
            Contact contactNECF1 = AllDataFactory.getContact('02', NECF1.Id, filiale.id);
            Contact contactNECA1 = AllDataFactory.getContact('03', NECA1.Id, area.id);
            Contact contactNECT4Family = AllDataFactory.getContact('04', NECT4Family.Id, ufficioFamily.id);
            Contact contactNECT4Personal = AllDataFactory.getContact('05', NECT4Personal.Id, ufficioPersonal.id);
            insert new List<Contact>{contactUfficioModelliDistributivi, contactNECF1, contactNECA1, contactNECT4Family, contactNECT4Personal};
        }
    }
    @isTest
    static void Test1() {

        Test.startTest();
        Map<String, Set<String>> macroDivisionMap = Batch_AllgnPublicGroupsPTF.macroDivisionMap;
        Id batchJobId = Database.executeBatch(new Batch_AllgnPublicGroupsPTF(), 200);
        Test.stopTest();
    }
}