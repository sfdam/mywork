/*
AL 2022-08-24 -- Aggiunta del parametro CRM_NaturaGiuridica__c
                 Aggiunta di un'altra Account  e aggiunta di CRM_LinkedNDG__c
                 Aggiunta chiamata a metodo con atro oggetto 
                 Aggiunta di parametro 
*/

@isTest
public with sharing class DynamicTablesControllerTest {
    
    @TestSetup
    static void setup(){ 
        Account personAccount = AllDataFactory.getAccount('05', 'PersonAccount');
        personAccount.CRM_NaturaGiuridica__c = 'DI'; 
        // AL 2022-08-24 -- Aggiunta del parametro CRM_NaturaGiuridica__c
        // AL 2022-08-24 -- Aggiunta di un'altra Account 
        System.debug('personAccount TESTTTT: '+personAccount);
        Account personAccount1 = AllDataFactory.getAccount('05', 'PersonAccount');
        personAccount1.CRM_NaturaGiuridica__c = 'DI1';
        System.debug('personAccount11111 TESTTTT: '+personAccount1);

        insert new List<Account> { personAccount, personAccount1
        };
        // AL 2022-08-24 -- Fine
        //insert personAccount;
        
        CRM_IndicatoriCliente__c data = new CRM_IndicatoriCliente__c(
            CRM_Account__c = personAccount.Id,
            CRM_ContoCorrente__c = true,
            CRM_CartaDebito__c= false,
        	CRM_CartaCredito__c = false,
        	CRM_DepositiRisparmio__c = false,
        	CRM_CertificatiDeposito__c = false,
        	CRM_AltreFormeRaccDir__c = true);
        
        insert data;
        
        // AL 2022-08-24 -- Aggiunta dell'oggetto CRM_LinkedNDG__c
        CRM_LinkedNDG__c c = new CRM_LinkedNDG__c(
            CRM_RelatedAccount__c = personAccount.id
            , CRM_Account__c = personAccount.id
            , CRM_LinkCode__c = '103' // Per avere CRM_CheckCodiceCollCompagine__c = true 
            , CRM_Status__c = 'A' 
            , CRM_LinkType__c = 'TITOLARE D.I.'
        );
        CRM_LinkedNDG__c c1 = new CRM_LinkedNDG__c(
            CRM_RelatedAccount__c = personAccount.Id
            , CRM_Account__c = personAccount.Id
            , CRM_LinkCode__c = '102' // Per avere CRM_CheckCodiceCollCompagine__c = true 
            , CRM_Status__c = 'A' 
            , CRM_LinkType__c = 'TITOLARE D.I.'
        );
     insert new List<CRM_LinkedNDG__c> { c1, c
        };
        }
        //insert c;

        // AL 2022-08-24 -- Fine 
    
    
    
    @isTest
    static void unitTest1() {
        system.debug('cccc');
        String idAccount = [SELECT CRM_Account__c FROM CRM_IndicatoriCliente__c LIMIT 1].CRM_Account__c;
        System.debug('idAccount '+ idAccount);
        String oggetto = 'CRM_IndicatoriCliente__c';
        String lookup = 'CRM_Account__c';
        String fiejS= 'CRM_TabellaEntiSegnalanti.js';
        String RecordType= 'Storico';
        Map<String,Object> x =new Map<String,Object>();
        Test.startTest();
        try{
           x = DynamicTablesController.getObjectInfos(oggetto ,lookup,idAccount, RecordType
            , fiejS  // AL 2022-08-24 -- Aggiunta di parametro  
            );      
    
            // AL 2022-08-24 -- Aggiunta chiamata a metodo con atro oggetto 
            x = DynamicTablesController.getObjectInfos('oggetto', lookup, idAccount, RecordType, fiejS);      
            // AL 2022-08-24 -- Fine 
        } catch(Exception e) {

        }
        Test.stopTest();
        System.assertEquals(true, x.size()>0);
    }

    @isTest
    static void unitTest2() {
        
        String idAccount = [SELECT  CRM_Account__c FROM CRM_IndicatoriCliente__c LIMIT 1].Id;
        String oggetto = 'CRM_IndicatoriCliente__c';
        String lookup = 'CRM_Account__c';
         String fiejS= 'CRM_TabellaEntiSegnalanti.js';
        String RecordType= 'Storico';
        Map<String,Object> x =new Map<String,Object>();
        Test.startTest();
        try{
		 x = DynamicTablesController.getObjectInfos(oggetto ,lookup,idAccount, RecordType
            , fiejS  // AL 2022-08-24 -- Aggiunta di parametro 
            );
        }
        catch(Exception e) {

        }
        Test.stopTest();
        System.assertEquals(false, x.size()>0);
    }

}