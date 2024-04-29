/*
AL 2022-08-24 -- Aggiunta del parametro CRM_NaturaGiuridica__c
                    Aggiunta di un'altra Account 
                    Aggiunta dell'oggetto CRM_LinkedNDG__c
*/

@isTest
private class MRForDynamicTablesControllerTest {
    
    @TestSetup
    static void setup(){
        Account personAccount = AllDataFactory.getAccount('05', 'PersonAccount');
        personAccount.CRM_NaturaGiuridica__c = 'DI'; // AL 2022-08-24 -- Aggiunta del parametro CRM_NaturaGiuridica__c
        
        // AL 2022-08-24 -- Aggiunta di un'altra Account 
        Account personAccount1 = AllDataFactory.getAccount('05', 'PersonAccount');
        personAccount1.CRM_NaturaGiuridica__c = 'DI1';
        insert new List<Account> { personAccount, personAccount1
        };
        // AL 2022-08-24 -- Fine
        //insert personAccount;
        
        CRM_IndicatoriCliente__c data1 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 01, 21));

            CRM_IndicatoriCliente__c data2 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 02, 21));

            CRM_IndicatoriCliente__c data3 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 03, 21));

            CRM_IndicatoriCliente__c data4 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 04, 21));

            CRM_IndicatoriCliente__c data5 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 05, 21));

            CRM_IndicatoriCliente__c data6 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 06, 21));

            CRM_IndicatoriCliente__c data7 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 07, 21));

            CRM_IndicatoriCliente__c data8 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 08, 21));

            CRM_IndicatoriCliente__c data9 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 09, 21));

            CRM_IndicatoriCliente__c data10 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 10, 21));

            CRM_IndicatoriCliente__c data11 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Storico').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= Date.newInstance(2021, 11, 21));

            CRM_IndicatoriCliente__c data12 = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true,
            recordTypeId = Schema.SObjectType.CRM_IndicatoriCliente__c.getRecordTypeInfosByDeveloperName().get('Flat').getRecordTypeId(),
            CRM_CRMeseDiRiferimento__c= null
            );

            
        
        insert new list<CRM_IndicatoriCliente__c>{data1,data2,data3,data4,data5,data6,data7,data8,data9,data10,data11,data12};
        
        // AL 2022-08-24 -- Aggiunta dell'oggetto CRM_LinkedNDG__c
        CRM_LinkedNDG__c c = new CRM_LinkedNDG__c(
            CRM_RelatedAccount__c = personAccount.Id
            , CRM_Account__c = personAccount.Id
            , CRM_LinkCode__c = '102' // Per avere CRM_CheckCodiceCollCompagine__c = true 
            , CRM_Status__c = 'A' 
            , CRM_LinkType__c = 'TITOLARE D.I.'
        );
        CRM_LinkedNDG__c c1 = new CRM_LinkedNDG__c(
            CRM_RelatedAccount__c = personAccount.Id
            , CRM_Account__c = personAccount1.Id
            , CRM_LinkCode__c = '103' // Per avere CRM_CheckCodiceCollCompagine__c = true 
            , CRM_Status__c = 'A' 
            , CRM_LinkType__c = 'TITOLARE D.I.'
        );
        insert new List<CRM_LinkedNDG__c> {c, c1 
        };
        //insert c;

        // AL 2022-08-24 -- Fine 
    }
    
    
    @isTest
    static void unitTest1() {
        
        String idAccount = [SELECT  CRM_Account__c FROM CRM_IndicatoriCliente__c LIMIT 1].CRM_Account__c;
        
		Map<String,sObject> x = MRForDynamicTablesController.getObjectInfos(idAccount,'Storico','2021-06-21');      
    }

    @isTest
    static void unitTest2() {
        
        String idAccount = [SELECT  CRM_Account__c FROM CRM_IndicatoriCliente__c LIMIT 1].id;
        
        try{
		Map<String,sObject> x = MRForDynamicTablesController.getObjectInfos(idAccount,'Storico','2021-06-21');
        }
        catch(Exception e) {

        }      
    }

    @isTest
    static void unitTest3() {
        
        String idAccount = [SELECT  CRM_Account__c FROM CRM_IndicatoriCliente__c LIMIT 1].id;
        
		Map<String,sObject> x = MRForDynamicTablesController.getAvailabilityMonths(idAccount);
            
    }

    
}