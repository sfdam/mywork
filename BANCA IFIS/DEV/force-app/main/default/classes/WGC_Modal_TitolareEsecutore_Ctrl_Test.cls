@isTest
public class WGC_Modal_TitolareEsecutore_Ctrl_Test {
    @isTest
    public static void Test_WGC_Modal_TitolareEsecutore_Controller(){
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        
        
        //List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        List<Contact> listCont = WGC_AllDataFactory.createContact(5,false);
        List<Account> listAcc = [SELECT Id,Name FROM Account];
        String accId = listAcc[0].Id;
        listAcc[0].PaeseCasaMadre__c = 'Italia';
        listAcc[0].PaeseSvolgimentoAttivitaPrevalente__c = 'ITALIA';
        listAcc[0].ProvinciaSvolgimentoAttivitaPrevalente__c = 'MI';
        update listAcc;

        for (Contact c : listCont) {
            c.AccountId = accId;
            c.IsReferenteCampagna__c = false;
        }

        insert listCont;

        // Account acc = [SELECT Id, Name FROM Account WHERE Id=: accId];
        // AccountContactRelation acr = new AccountContactRelation(AccountId=accId, ContactId=listCont.get(0).Id);
        // acr.WGC_Ruolo__c='J';
        // insert acr;
        List<AccountContactRelation> acr2 = [SELECT Id, AccountId, ContactId,WGC_Ruolo__c, WGC_Ruolo_Pratica__c FROM AccountContactRelation WHERE AccountId =: accId];
        
        acr2[0].WGC_Ruolo__c='J';
        acr2[1].WGC_Ruolo__c='J1';
        acr2[2].WGC_Ruolo__c='Z1';
        acr2[3].WGC_Ruolo__c='Z';
        acr2[4].WGC_Ruolo__c='J;Z1';

        acr2[0].WGC_Ruolo_Pratica__c = 'J';
        acr2[1].WGC_Ruolo_Pratica__c = 'J1';
        acr2[2].WGC_Ruolo_Pratica__c = 'J;Z1';
        acr2[3].WGC_Ruolo_Pratica__c = 'Z1';
        acr2[4].WGC_Ruolo_Pratica__c = 'J1;Z1';
        System.debug('acr2: '+acr2);
        update acr2;

        /*Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale']; 
        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com');
        insert u;

        Test.startTest();

        System.runAs(u) {
        // WGC_Modal_TitolareEsecutore_Controller.getReferenti(a1.AccountId);
        WGC_Modal_TitolareEsecutore_Controller.getReferenti(null);
        }
        Test.stopTest();*/

        Test.startTest();
        WGC_Modal_TitolareEsecutore_Controller.getReferenti(accId);
        WGC_Modal_TitolareEsecutore_Controller.getConsensi(accId);
        
        Test.stopTest();
    }
    
}