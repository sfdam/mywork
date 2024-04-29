/****
 * Name			:	Batch_SvuotaResiduale
 * Create Date	:	2022-12-05
 * Author 		:	Alessandro LUMACA @TEN
 ****/

@isTest
public class Batch_SvuotaResidualeTest {
    
    private static final Profile integratorProfile = [SELECT id FROM Profile WHERE Name = 'Integration Profile' LIMIT 1];
    private static List<User> lUser = new List<User>();
    
    @testSetup
    public static void load() {
        Wallet__c microPortafoglio  = AllDataFactory.getWallet('MicroWallet', 'Filiale di Milano', 'POE'); 
        insert    microPortafoglio;
        
        Account account0 = AllDataFactory.getAccount('00', 'PersonAccount');
        account0.PTF_DeactivationDate__c = Date.today().addDays(-366);
        account0.ModelloDiServizio__c    = 'Family';
        account0.PTF_Portafoglio__c      = microPortafoglio.Id;
        account0.PTF_Filiale__c = microPortafoglio.PTF_Filiale__c;
        Account account1 = AllDataFactory.getAccount('01', 'IndustriesBusiness');
        account1.PTF_DeactivationDate__c = Date.today().addDays(-365);
        account1.ModelloDiServizio__c    = 'Corporate';
        account1.PTF_Portafoglio__c      = microPortafoglio.Id;
        account1.PTF_Filiale__c = microPortafoglio.PTF_Filiale__c;
        Account account2 = AllDataFactory.getAccount('02', 'Cointestazione');
        account2.PTF_DeactivationDate__c = Date.today().addDays(-366);
        account2.ModelloDiServizio__c    = 'Residuale';   
        account2.PTF_Portafoglio__c      = microPortafoglio.Id;
        account2.PTF_Filiale__c = microPortafoglio.PTF_Filiale__c;
        insert new List<Account> { account0, account1, account2 }; 
        
        lUser.add(TestDataFactorySSO.createUser());
        insert lUser;    
        ScheduledJob__c sh0 = TestDataFactorySSO.creaScheduledJobsFrequenzaSettimanale('Batchable'
                                                                                       , 'test'
                                                                                       , 'Batch_SvuotaResiduale'
                                                                                       , lUser.get(0));
        sh0.Frequenza__c    = 'Giornaliera';
        sh0.Data_Inzio_Validit__c = Date.today();
        sh0.Data_Fine_Validit__c  = Date.today().addDays(1);
        insert sh0;
        
        User u = AllDataFactory.getUser('00', integratorProfile.Id, 'Family'); 
        insert u;
    }
    
    @isTest 
    public static void test() {
        Batch_SvuotaResiduale batch_class_to_test = new Batch_SvuotaResiduale();
        batch_class_to_test.initRunner(new List<ScheduledJob__c> {
            [SELECT Id, Nome_Classe__c, Tipologia_Della_Classe__c, Batch_Size__c 
             FROM   ScheduledJob__c 
             WHERE  Tipologia_Della_Classe__c = 'Batchable'
            ]
        });
        User u = [
            SELECT Id, LastName 
            FROM   User
            WHERE  LastName = 'Test00' 
            LIMIT  1
        ];
        Test.startTest();
        System.runAs( u ) {
            Database.executeBatch(batch_class_to_test, 200);
        }
        Test.StopTest();
        
    }
}