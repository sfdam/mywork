@isTest 
public class Batch_DeprovisioningTest {
    @TestSetup
    static void setup(){
        
        ServiceModel__c model= new ServiceModel__c();
        model.PTF_Division__c='PR';
        model.PTF_MacroDivision__c='WM';
        model.Name='Private';
        insert model;
        
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
		banca.PTF_IdCED__c='1234';
        insert banca;
        
        Account acc = new Account();
        acc.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'AltraUnitaOrganizzativa');
        acc.Name = 'UFF. Private test';
        acc.PTF_IdCED__c = '998';
        insert acc;

        LDAP__c ldapTest = new LDAP__c();
        ldapTest.Nome__c = 'Test';
        ldapTest.Cognome__c = 'Test';
        ldapTest.Matricola__c= 'U12549';
        ldapTest.Email__c = 'test@test.it';
        ldapTest.IDCed__c = '998';
        ldapTest.Attivo__c = true;
        ldapTest.Da_Elaborare__c = true;
        ldapTest.Ruolo_LDAP__c='100';
        ldapTest.Team__c='';
        ldapTest.Vicario__c='VIC_A';


        LDAP__c ldapTest1 = new LDAP__c();
        ldapTest1.Nome__c = 'Test';
        ldapTest1.Cognome__c = 'Test';
        ldapTest1.Matricola__c= 'U99549';
        ldapTest1.Email__c = 'test@test.it';
        ldapTest1.IDCed__c = '8717';
        ldapTest1.IdCedFittizia__c = '8718';
        ldapTest1.Ruolo_LDAP__c = '100';
        ldapTest1.Profilo_LDAP__c = 'NEC_D.7';
        ldapTest1.Attivo__c = false;
        ldapTest1.Da_Elaborare__c = true;
        ldapTest1.Team__c='';
        ldapTest.Vicario__c='VIC_A';

        insert ldapTest1;
		
        Profile profile1 = [SELECT id from Profile where name='NEC_CC' limit 1];   
       // Profile profile2 = [SELECT id from Profile where name='NEC_CCSV' limit 1];  
        
        User user1 = AllDataFactory.getUser('1', profile1.Id, 'CORPORATE');
        user1.FederationIdentifier='99549';
        user1.isActive=true;
        insert user1;
        
       // User user2 = AllDataFactory.getUser('2', profile2.Id, 'CORPORATE');
        //user2.FederationIdentifier='12345';
       // user2.isActive=true;
       // insert user2;
        
        
    }
    @istest
    static void Test1() {
        User user =[SELECT id from User where FederationIdentifier='99549' limit 1];
        Test.startTest();
        Batch_Deprovisioning bdp = new Batch_Deprovisioning();
        Database.executeBatch(bdp);
        Test.stopTest();
    }
    
    
    

}