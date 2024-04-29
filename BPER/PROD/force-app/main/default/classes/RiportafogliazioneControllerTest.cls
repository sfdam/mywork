@IsTest
public class RiportafogliazioneControllerTest {
    @TestSetup
    static void makeData(){
        List<sObject> ls1 = Test.loadData(ServiceModel__c.sObjectType, 'ServiceModel_TEST');
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
        Account banca2= AllDataFactory.getAccount('Banca2','Banca');
        banca2.FinServ__BankNumber__c='12345';

        insert new List<Account>{banca, banca2};

        Account dr= AllDataFactory.getAccount('DR','DirezioneRegionale');
        dr.PTF_Banca__c=banca.Id;

        insert dr;

        Account area = AllDataFactory.getAccount('Area','Area');
        area.PTF_DirezioneRegionale__c=dr.Id;
        area.PTF_Banca__c=banca.Id;
        insert area;


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
        filiale2.PTF_BranchTypology__c='A';
        filiale.PTF_IdCEDFiliale__c='1239';
        filiale2.PTF_IdCED__c='1239';
        insert new List<Account>{filiale, filiale2};

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'CORPORATE';
        insert modelloDiServizio;

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        insert ruoloMDS;
        
        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        user.FederationIdentifier='01';
        user.idced__c='1238';
        
        insert new List<User>{user};

        System.runAs(user){
        
        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        microPortafoglio.Name='partenza';
        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', filiale2.Id, 'CORPORATE');
        microPortafoglio2.Name='destinazione';

        insert new List<Wallet__c>{microPortafoglio, microPortafoglio2};

        Account ndg = AllDataFactory.getAccount('NDG1','PersonAccount');
        ndg.PTF_Portafoglio__c=microPortafoglio2.Id;
        ndg.CRM_NDG__c='1234';
        
        insert new List<Account>{ndg};

        Riportafogliazione__c rip= new Riportafogliazione__c();
        rip.ABI__c='05387';
        rip.NDG__c='1234';
        rip.Id_Ced_Di_Partenza__c='1238';
        rip.Id_Ced_Di_Destinazione__c='1239';
        rip.Portafoglio_Di_Partenza__c='partenza';
        rip.Portafoglio_Di_Destinazione__c='destinazione';
        rip.Tipo_impurezza__c='Upgrade';
        insert rip;
        }

        
    }

    @isTest
        static void test(){
            List<User> userList=[SELECT Id, idced__c  FROM User WHERE federationIdentifier='01'];
            system.debug('@@@@@user: '+userList[0].idced__c);
            List<Riportafogliazione__c> ripList=[SELECT Id FROM Riportafogliazione__c];
            List<Id> recordIds= new List<Id>{ripList[0].Id};
            System.runAs(userList[0]){
                RiportafogliazioneController.getInfoFiliale();
                RiportafogliazioneController.getAllData('Upgrade');
                RiportafogliazioneController.noSpost(null, recordIds, 'motivo', 'altro');
                RiportafogliazioneController.annullaRifiuto(recordIds);
            }
        }
}