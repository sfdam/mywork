@isTest
public with sharing class EliminaUserDoppioPresidioTest {
    
    @TestSetup
    static void makeData(){

        Profile profile1 = [SELECT id FROM Profile WHERE  Name ='NEC_T.8' LIMIT 1];
        Profile profile2 = [SELECT id FROM Profile WHERE  Name ='NEC_D.5' LIMIT 1];
        Profile profile3 = [SELECT id FROM Profile WHERE  Name ='NEC_D.5' LIMIT 1];


        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        
        User user = AllDataFactory.getUser('10', profile.Id, 'Private');
        user.FederationIdentifier='10';
        user.Profilo__c = 'ADMIN';
        insert new List<User>{user};

        Account acc1 = AllDataFactory.getAccount('01', 'IndustriesBusiness');
        acc1.ModelloDiServizio__c='Private';
        insert acc1;

        Wallet__c wal = new Wallet__c();
        wal.PTF_Filiale__c=acc1.Id;
        wal.PTF_ModelloDiServizio__c='Private';
        wal.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        insert wal;

        Contact c1 = new Contact (LastName='LastName1');
        Contact c2 = new Contact (LastName='LastName2');
        Contact c3 = new Contact (LastName='LastName3');

        Contact c =AllDataFactory.getContact('01', user.id, acc1.id);
        System.runAs(user){
            
            insert c;
        }
        
        insert new List<Contact>{c1,c2,c3};
        Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
                                            
        NDGManagementMember__c doppioPresidio = new NDGManagementMember__c();
        doppioPresidio.PTF_Gestore__c = c.id;
        doppioPresidio.PTF_NDG__c = acc1.id;
        doppioPresidio.RecordTypeId = recTypeId;
        insert doppioPresidio;
        System.debug('Doppio Presidio' +doppioPresidio);

    }
    @isTest
    public static void eliminaUtentiTest(){
        Test.startTest();

        List<User> listUser = [SELECT id FROM user WHERE FederationIdentifier in ('10','11','12')];
        List<String> listUserId= new List<String>(); 
        for(User u: listUser){
            listUserId.add(u.id);
        }
        
        EliminaUserDoppioPresidio.eliminaUtenti(listUserId);


        Test.stopTest();
        Date tmpDate = Date.today();
        List<NDGManagementMember__c> listNDGManage = [SELECT id,PTF_EndDate__c FROM NDGManagementMember__c];
        System.assertEquals(tmpDate, listNDGManage[0].PTF_EndDate__c);
    }


}