@isTest
public class WGC_Test_PrivacyPersonaGiuridica {
	
    @isTest
    public static void Test_getDefaultData1(){
        //Credo i dati di test
        WGC_AllDataFactory.disattivaTrigger();

        Account acc = new Account();
        Integer rand = Integer.valueOf(Math.Random());
        acc.Name='TestAccount'+rand;
        acc.ConsensoAllaProfilazione__c=false;
        acc.ConsensoProdottiBancaRicercheMercato__c=false;
        acc.ConsensoProdottiSocietaTerze__c=false;
        acc.ConsensoAttivitaPromozionaleTerzi__c=false;
        acc.ConsensoAttivitaPromRicercheMercato__c=false;
        acc.ConsensoSoloModalitaTradizionali__c=false;
        insert acc;

        String accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Test.startTest();
        WGC_PrivacyPersonaGiuridica ctrl = new WGC_PrivacyPersonaGiuridica();
        //primo metodo di test
        Sobject accResp = WGC_PrivacyPersonaGiuridica.getDefaultData(accId);
        String accString = JSON.serialize(accResp);
        Account accUpdate = [SELECT Id FROM Account LIMIT 1];
        accUpdate.ConsensoAllaProfilazione__c=true;
        accUpdate.ConsensoProdottiBancaRicercheMercato__c=true;
        accUpdate.ConsensoProdottiSocietaTerze__c=true;
        accUpdate.ConsensoAttivitaPromozionaleTerzi__c=true;
        accUpdate.ConsensoAttivitaPromRicercheMercato__c=true;
        accUpdate.ConsensoSoloModalitaTradizionali__c=true;
        update accUpdate;

        //secondo metodo di test
        WGC_PrivacyPersonaGiuridica.getText();
        WGC_PrivacyPersonaGiuridica.SaveRecord(accUpdate.Id, accString);
        WGC_PrivacyPersonaGiuridica.getReferentiEsecutori(accId);
        WGC_PrivacyPersonaGiuridica.saveAccountPrivacy(accId, accString,'Esecutore');
        Test.stopTest();
    }


    @isTest
    public static void Test_getDefaultData2(){
        //Credo i dati di test
        WGC_AllDataFactory.disattivaTrigger();

        Contact cont = new Contact();
        Integer rand = Integer.valueOf(Math.Random());
        cont.LastName='TestContact'+rand;
        cont.ConsensoAllaProfilazione__c=false;
        cont.ConsensoProdottiBancaRicercheMercato__c=false;
        cont.ConsensoProdottiSocietaTerze__c=false;
        cont.ConsensoAttivitaPromozionaleTerzi__c=false;
        cont.ConsensoAttivitaPromRicercheMercato__c=false;
        cont.ConsensoSoloModalitaTradizionali__c=false;
        insert cont;

        String contID = [SELECT Id FROM Contact LIMIT 1].Id;
        
        Test.startTest();
        WGC_PrivacyPersonaGiuridica ctrl = new WGC_PrivacyPersonaGiuridica();
        //primo metodo di test
        Sobject contResp = WGC_PrivacyPersonaGiuridica.getDefaultData(contID);
        String contString = JSON.serialize(contResp);
        Contact contUpdate = [SELECT Id FROM Contact LIMIT 1];
        contUpdate.ConsensoAllaProfilazione__c=true;
        contUpdate.ConsensoProdottiBancaRicercheMercato__c=true;
        contUpdate.ConsensoProdottiSocietaTerze__c=true;
        contUpdate.ConsensoAttivitaPromozionaleTerzi__c=true;
        contUpdate.ConsensoAttivitaPromRicercheMercato__c=true;
        contUpdate.ConsensoSoloModalitaTradizionali__c=true;
        update contUpdate;

        //secondo metodo di test
        WGC_PrivacyPersonaGiuridica.SaveRecord(contID, contString);
        Test.stopTest();
    }
}