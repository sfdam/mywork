@IsTest
public class NucleiAppartenenzaControllerTest {
    
    @IsTest
    static void test(){
        
        Funzionalita__c z= new Funzionalita__c();
        z.Disable_Trigger__c=true;
        insert z;
        
        Test.startTest();
        
        Nucleo__c nuc=new Nucleo__c();
        nuc.PTF_CodId__c ='Test';
        insert nuc;
            
            Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;
            
            Contact contact = AllDataFactory.getContact('01', UserInfo.getUserId(), filiale.Id);
            contact.PTF_RegistrationNumber__c='01';
                
            insert new List<Contact>{contact};
        
            Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
                
            insert new List<Wallet__c>{microPortafoglio};
        
                
            Assignment__c primarioAssignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, contact.Id);
                
            insert new List<Assignment__c>{primarioAssignment};
            String personAccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account acc= new Account();
            acc.LastName='Test';
            acc.PTF_Caponucleo__c=true;
            acc.PTF_Portafoglio__c=microPortafoglio.Id;
            acc.PTF_Nucleo__c=nuc.Id;
            acc.RecordTypeId=personAccountRTId;
              
            Account ndg = AllDataFactory.getAccount('NDG1','PersonAccount');
            ndg.PTF_Portafoglio__c=microPortafoglio.Id;
            ndg.PTF_Nucleo__c=nuc.Id;
            Account ndg2 = AllDataFactory.getAccount('NDG2','Cointestazione');
            ndg2.PTF_Portafoglio__c=microPortafoglio.Id;
            ndg.PTF_Nucleo__c=nuc.Id;
            insert new List<Account>{ndg2, ndg, acc};

            
            System.debug('SV TEST ndg: ' + ndg);
            System.debug('SV TEST ndg2: ' + ndg2);
            
            
            List<String> x = new List<String>();
            x.add(ndg2.Id);
                
            Map<String, Object> a = NucleiAppartenenzaController.getNDG(ndg.Id);
            List<Account> b = NucleiAppartenenzaController.getNDGAppartenenza(ndg.PTF_Nucleo__c,ndg.Id);
            Map<String,Object> c = NucleiAppartenenzaController.loadNdgList(ndg.PTF_Nucleo__c, null, null, ndg.PTF_Portafoglio__c, 1, 1, null, null, null);
            a = NucleiAppartenenzaController.crm_GetNDG(ndg.Id);
            b = NucleiAppartenenzaController.crm_GetNDGAppartenenza(ndg.PTF_Nucleo__c,ndg.Id);
            c = NucleiAppartenenzaController.crm_LoadNdgList(ndg.PTF_Nucleo__c, null, null, ndg.PTF_Portafoglio__c, 1, 1, null, null, null);
            NucleiAppartenenzaController.assignToNucleo(ndg.PTF_Nucleo__c, x);
            
        Test.stopTest();
            
    }

}