@IsTest
public with sharing class CRM_OptManagementTest 
{
    @TestSetup
    static void makeData()
    {
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;

        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        // dir.PTF_ABICED__c = '05387';
        dir.parentId = banca.Id;
        insert dir;

        Account area = AllDataFactory.getAccount('08', 'Area');
        area.parentId = dir.Id;
        insert area;

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;

        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        microPortafoglioPersonal.PTF_Filiale__c = filiale.Id;
        microPortafoglioPersonal.PTF_Area__c = area.Id;
        microPortafoglioPersonal.PTF_DirezioneRegionale__c = dir.id;
        microPortafoglioPersonal.PTF_Banca__c = banca.Id;
        insert microPortafoglioPersonal;

        Account personAccount = AllDataFactory.getAccount('01', 'PersonAccount');
        personAccount.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        personAccount.PTF_Filiale__c = filiale.Id;
        insert personAccount;

        Account cointestazione = AllDataFactory.getAccount('04', 'Cointestazione');
        cointestazione.PTF_Portafoglio__c = microPortafoglioPersonal.Id;
        cointestazione.PTF_Filiale__c = filiale.Id;
        insert cointestazione;

        CRM_AccountAccountJointOwnershipRelation__c relazioneDiCointestazionePrimario = new CRM_AccountAccountJointOwnershipRelation__c();
        relazioneDiCointestazionePrimario.CRM_PrimaryNDG__c = true;
        relazioneDiCointestazionePrimario.CRM_Account__c = personAccount.Id;
        relazioneDiCointestazionePrimario.CRM_JointOwnership__c = cointestazione.Id;
        relazioneDiCointestazionePrimario.CRM_Active__c = true;
        insert relazioneDiCointestazionePrimario;
    }

    @IsTest
    static void OptManagement()
    {
        Id accId = [SELECT Id FROM Account WHERE FirstName = 'FirstName01' ].Id; 
        CRM_OptManagement.getOpportunities(accId);
        CRM_OptManagement.getCointestazioni(accId);
    }
}