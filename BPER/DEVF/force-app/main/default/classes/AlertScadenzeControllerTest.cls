@isTest public with sharing class AlertScadenzeControllerTest {
    
    @TestSetup
        public static void setup(){

            Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
            User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
            insert user;
            
            Profile profile2 = [SELECT id FROM Profile WHERE Name = 'CRM - Consulenti Finanziari' LIMIT 1];
            User user2 = AllDataFactory.getUser('02', profile2.Id, 'CORPORATE');
            insert user2;
            
            System.runAs(user){

                Product2 product = new Product2(
                    Name = 'Test'
                );
                insert product;
                
                Account account = AllDataFactory.getPersonAccount('01');
                Account account2 = AllDataFactory.getPersonAccount('02');
                insert new List<Account>{account,account2};
                
                AccountShare accShare = new AccountShare();
                accShare.AccountId=account.Id;
                accShare.UserOrGroupId=user2.Id;
                accShare.AccountAccessLevel='Read';
                accShare.OpportunityAccessLevel='Read';
                accShare.CaseAccessLevel='Read';
                insert accShare;

                FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account.Id);
                financialAccount.FinServ__ProductName__c = product.Id;
                
                insert financialAccount;

                FinServ__FinancialAccountRole__c finAccountRole = AllDataFactory.getFinancialAccountRole('AccountRole',financialAccount.id, account2.id,'Primary Owner');
                finAccountRole.FinServ__Active__c=true;
                insert finAccountRole;

                Account acc = AllDataFactory.getAccount('01', 'GruppoFinanziario');
                insert acc;

                Date today = Date.today();
                FinServ__Alert__c finServAlert = new FinServ__Alert__c();
                finServAlert.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('FinServ__Alert__c', 'Scadenziario_Portafoglio');
                finServAlert.CRM_CED__c='123';
                finServAlert.FinServ__Account__c=acc.id;
                finServAlert.CRM_TipoDocumento__c='MAV';
                finServAlert.FinServ__Message__c='Scadenza';
                finServAlert.CRM_DataScadenza__c=today;
                finServAlert.CRM_EsitoContatto__c='Da ricontattare';
                finServAlert.CRM_Importo__c=100;


                insert finServAlert;
                
            }    
        }
        @IsTest
        static void getAllDataTest(){
            Test.startTest();
            User u =[SELECT Id FROM User WHERE LastName='Test01'];
            System.runAs(u){
                Account ndg= [SELECT Id FROM Account WHERE Name='Person01' LIMIT 1];
                System.assert(AlertScadenzeController.getAllData(ndg.id)!=null);
            }
            
            Test.stopTest();
            
        }
        
       @IsTest 
        static void getAllDataTest2(){
            Test.startTest();
            User u2 =[SELECT Id, Profile.Name FROM User WHERE LastName = 'Test02'];
            System.runAs(u2){
                Account ndg= [SELECT Id FROM Account WHERE Name='Person01' LIMIT 1];
                System.assert(AlertScadenzeController.getAllData(ndg.id)!=null);
            }
            
            
            Test.stopTest();
            
        }
        
        

}