@IsTest
public  class NucleiActionControllerTest {
    @TestSetup
        public static void setup(){

            Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
            filiale.PTF_BranchTypology__c = 'A';
            insert filiale;
            
            Nucleo__c nuc=new Nucleo__c();
            nuc.PTF_CodId__c ='Test';
            insert nuc;
            
            Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
            User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
            insert user;
            System.runAs(user){
                Contact contact = AllDataFactory.getContact('01', user.Id, filiale.Id);
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
                }    
        }
        @IsTest
        static void test(){
            Test.startTest();
            User u =[SELECT Id FROM User WHERE LastName='Test01'];
            Account ndg;
            Account ndg2;
            System.runAs(u){
                 ndg= [SELECT Id, PTF_Nucleo__c FROM Account WHERE Name='Test' LIMIT 1];
                 ndg2= [SELECT Id, PTF_Nucleo__c FROM Account WHERE LastName='LastNameNDG1' LIMIT 1];
                
                NucleiActionController.getNDG(ndg.Id);
                NucleiActionController.getNDG_aggiungiNDG(ndg.Id);
                NucleiActionController.assegnaCaponucleo(ndg2);
                NucleiActionController.eliminaNDGDaNucleo(ndg);
            }
            
            Test.stopTest();
            System.assertEquals(true , (NucleiActionController.getNDG(ndg.Id)) != null);
            System.assertEquals(true , (NucleiActionController.getNDG_aggiungiNDG(ndg.Id)) != null);
            System.assertEquals(true , (NucleiActionController.eliminaNDGDaNucleo(ndg)) != null);
            
        }
}