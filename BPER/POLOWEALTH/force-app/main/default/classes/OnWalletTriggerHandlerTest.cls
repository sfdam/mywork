/*
/**
 * @task              : test BPER_TOM_AssegnazioneAutomatica 
 * @author            : alessandro di nardo @ten
 * @group             : tengroup
 * @last modified on  : 2023-12-12
 * @class to test     : OnWalletTriggerHandler
 * @description       : copecreazione oggetto assegnazione per i portafogli          
                        asseconda del modello del portafoglio( poe,FAMILY,Controparti Istituzionali)
                        e asseconda della tipologia di ruolo dei contatti associati alla filiale

*/
@IsTest
public with sharing class OnWalletTriggerHandlerTest {

    @TestSetup
    static void setup(){
        
        /*UtenzeDefault__c utenzaDefault = new UtenzeDefault__c();
        utenzaDefault.Name = 'Test';
        utenzaDefault.PTF_POOL_IdOwner__c = UserInfo.getUserId();
        insert utenzaDefault;*/

        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Family';
        ServiceModel__c modelloDiServizio2 = new ServiceModel__c();
        modelloDiServizio2.Name = 'Controparti Istituzionali';

        insert new List<ServiceModel__c>{modelloDiServizio, modelloDiServizio2};

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        RoleMDS__c ruoloMDS2 = new RoleMDS__c();
        ruoloMDS2.PTF_BranchTypology__c = 'A';
        ruoloMDS2.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS2.PTF_ServiceModel__c = modelloDiServizio2.Id;
        ruoloMDS2.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS2.PTF_EndDate__c = Date.today().addDays(10);

        insert new List<RoleMDS__c>{ruoloMDS, ruoloMDS2};

        
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;
        
        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'Family');
        insert user;
        List<Contact> listContact = new List<Contact>();//AD
        System.runAs(user){
            Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
            contact.PTF_TipologiaRuolo__c = ruolo.Id;
            //contact.PTF_ProfiloLDAP__c = 'test';AD
            insert contact; 

        }
        
    }
    
    @IsTest
    static void testInsert(){
        
        Account filiale = [SELECT id FROM Account LIMIT 1];

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'Controparti Istituzionali');
        microPortafoglio.PTF_Pool__c=true;
        microPortafoglio.Name='Test1';
        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'Family');
        microPortafoglio2.Name='Test2';
        Wallet__c portafoglioTecnico = AllDataFactory.getWallet('TechnicalWallet', filiale.Id, 'Family');
        portafoglioTecnico.Name='Test3';
        Wallet__c portafoglioAssente = AllDataFactory.getWallet('Assente', filiale.Id, 'Assente');
        portafoglioTecnico.Name='Test4';
        Wallet__c portafoglioResiduale = AllDataFactory.getWallet('Residuale', filiale.Id, 'Residuale');
        portafoglioResiduale.Name='Test5';
        insert new List<Wallet__c>{microPortafoglio, microPortafoglio2, portafoglioTecnico, portafoglioAssente, portafoglioResiduale};
        
        try{

            delete new List<Wallet__c>{microPortafoglio, portafoglioTecnico, portafoglioAssente, portafoglioResiduale};
        }catch(Exception ex){}
    }    


    
    //AD
    @isTest
    static void testAssegnazioneWallet(){
        RoleTypology__c ruolo = new RoleTypology__c();
        ruolo.Name = 'Titolare';
        insert ruolo;

        ServiceModel__c modelloDiServizio = new ServiceModel__c();
        modelloDiServizio.Name = 'Family';
        ServiceModel__c modelloDiServizio2 = new ServiceModel__c();
        modelloDiServizio2.Name = 'Controparti Istituzionali';

        insert new List<ServiceModel__c>{modelloDiServizio, modelloDiServizio2};

        RoleMDS__c ruoloMDS = new RoleMDS__c();
        ruoloMDS.PTF_BranchTypology__c = 'A';
        ruoloMDS.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS.PTF_ServiceModel__c = modelloDiServizio.Id;
        ruoloMDS.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS.PTF_EndDate__c = Date.today().addDays(10);
        RoleMDS__c ruoloMDS2 = new RoleMDS__c();
        ruoloMDS2.PTF_BranchTypology__c = 'A';
        ruoloMDS2.PTF_RoleTypology__c = ruolo.Id;
        ruoloMDS2.PTF_ServiceModel__c = modelloDiServizio2.Id;
        ruoloMDS2.PTF_StartDate__c = Date.today().addDays(-10);
        ruoloMDS2.PTF_EndDate__c = Date.today().addDays(10);

        insert new List<RoleMDS__c>{ruoloMDS, ruoloMDS2};

        
        Account filiale = AllDataFactory.getAccount('05', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;
        
        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('02', profile.Id, 'Family');
        insert user;
        List<Contact> listContact = new List<Contact>();//AD
        System.runAs(user){
            Contact contact = AllDataFactory.getContact('02', user.Id, filiale.Id);
            contact.PTF_TipologiaRuolo__c = ruolo.Id;
            contact.PTF_ProfiloLDAP__c = 'test';
            insert contact; 

        }


        Account filiale2 = [SELECT id FROM Account where Name = 'Account05'];

        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale2.Id, 'Controparti Istituzionali');
        microPortafoglio.PTF_Pool__c=true;
        microPortafoglio.Name='Test1';
        Wallet__c microPortafoglio2 = AllDataFactory.getWallet('MicroWallet', filiale2.Id, 'Family');
        microPortafoglio2.Name='Test2';
        Wallet__c portafoglioTecnico = AllDataFactory.getWallet('TechnicalWallet', filiale2.Id, 'Family');
        portafoglioTecnico.Name='Test3';
        Wallet__c portafoglioAssente = AllDataFactory.getWallet('Assente', filiale2.Id, 'Assente');
        portafoglioTecnico.Name='Test4';
        Wallet__c portafoglioResiduale = AllDataFactory.getWallet('Residuale', filiale2.Id, 'Residuale');
        portafoglioResiduale.Name='Test5';
        insert new List<Wallet__c>{microPortafoglio, microPortafoglio2, portafoglioTecnico, portafoglioAssente, portafoglioResiduale};
    }
    
}