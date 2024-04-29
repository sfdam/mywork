@istest
public class OnQuoteTriggerHandler_Test {
    @istest
    public static void testSuccess(){
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        Id rtContact = [SELECT Id FROM RecordType WHERE Name = 'Warrant' AND SObjectType = 'Contact'].id;
        User Us = [select name,id from user where name = 'Chiara Sberveglieri'];
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c='Warrant';
        insert acc;
        

        
        Contact cc = TestDataFactory.create_Contact();
        cc.RecordTypeId = rtContact;
        cc.AccountId= acc[0].Id;
        insert cc;

        Contact cc1 = TestDataFactory.create_Contact();
        cc.LastName = 'Pippo';
        cc.RecordTypeId = rtContact;
        cc.AccountId= acc[0].Id;
        insert cc1;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                IsActive =true, Cluster_Tagetik__c = 'ADVISORY');
        insert pro ;

        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            SBQQ__Account__c=acc[0].id,
            RecordTypeId = rtIdQuote,
            SBQQ__Primary__c = true,
            WH_Business_Area__c = '1104244169',
            Fatturato_Account__c='Da più di 5 a 10 milioni di Euro',
            WRT_Referente_Amministrativo__c = cc.Id
            );

        SBQQ__Quote__c NQuote2 = new SBQQ__Quote__c(
                SBQQ__Account__c=acc[0].id,
                RecordTypeId = rtIdQuote,
                SBQQ__Primary__c = true,
                WH_Business_Area__c = '1104244169',
                Foro_di_Competenza__c='Milano',
            	Fatturato_Account__c='Oltre 100 milioni',
                WRT_Referente_Amministrativo__c = cc.Id
                );

                SBQQ__Quote__c NQuote3 = new SBQQ__Quote__c(
                SBQQ__Account__c=acc[0].id,
                RecordTypeId = rtIdQuote,
                SBQQ__Primary__c = true,
                WH_Business_Area__c = '1104244169',
                Foro_di_Competenza__c='Milano',
            	Fatturato_Account__c='Da più di 5 a 10 milioni di Euro',
                WRT_Referente_Amministrativo__c = cc.Id
                );

                SBQQ__Quote__c NQuote4 = new SBQQ__Quote__c(
                    SBQQ__Account__c=acc[0].id,
                    RecordTypeId = rtIdQuote,
                    SBQQ__Primary__c = true,
                    WH_Business_Area__c = '1104244169',
                    Foro_2__c='Milano',
                    WRT_Referente_Amministrativo__c = cc.Id
                    );
        
         x.Disabilita_tutti_i_trigger__c=false;
        update x;
       
        Insert NQuote;

        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Product__c = pro.id,
            SBQQ__Quote__c=NQuote.id,
            RecordTypeId = rtIdQLine,
            Divisione_WarrantCPQ__c  = 'FAA DRIVER'   );
        Insert NQuoteLine;

        Insert NQuote2;
        
        Insert NQuote3;
	
        Insert NQuote4;
        

        NQuote.WRT_Referente_Amministrativo__c = null;
        NQuote.WRT_Disdetta__c=true;
        NQuote.StageName__c = 'Chiuse/Perse';
        NQuote.TXT_ForecastCategory__c= 'Closed Lost';
        Update NQuote;
        system.debug('NQuote update 1 ' + NQuote);

        NQuote.WRT_Referente_Amministrativo__c = cc.Id;
        NQuote.Contratto_firmato__c='.';
        NQuote.WRT_DataOrdine__c=null;
        NQuote.StageName__c = 'Chiuse/Conseguite';
        NQuote.TXT_ForecastCategory__c= 'Closed Won';
        system.debug('cc1 '+cc1.accountid);
        system.debug('cc '+cc.accountid);
        system.debug('quote account '+NQuote.SBQQ__Account__c);
        Update NQuote;

        system.debug('NQuote update 2 ' + NQuote);
       
        NQuote.StageName__c = 'Potenziali';
        NQuote.TXT_ForecastCategory__c= null;
        NQuote.WRT_Modalita_pagamento__c='1181221202';
        NQuote.Foro_di_Competenza__c='Cremona';
        NQuote.Fatturato_Account__c='Da 30 milioni a 50 milioni';
        Update NQuote;
         
        system.debug('NQuote update 3 ' + NQuote);
        
        NQuote4.Foro_2__c = 'Cremona';
        NQuote.WRT_Modalita_pagamento__c='1181221202';
        Update NQuote4;

        System.runAs(Us) {   
            delete NQuote;
        }        
        
     }
    
    }