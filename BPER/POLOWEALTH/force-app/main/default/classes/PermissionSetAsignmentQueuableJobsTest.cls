@IsTest
public class PermissionSetAsignmentQueuableJobsTest {
    @TestSetup
    public static void setup(){
        Map<String, SObject> profileMap = SV_Utilities.keyBy([SELECT id, Name FROM Profile], 'Name');
        

        User NECT4Personal = AllDataFactory.getUser('17', profileMap.get('NEC_T.4').Id, 'Personal');
        NECT4Personal.FederationIdentifier = '17';
        NECT4Personal.Profilo__c = 'NEC_T.4';
        NECT4Personal.abi__c='05387';
        NECT4Personal.idced__c='7894'; 
        insert NECT4Personal;
    }
    @isTest
    public static void test() {
        List<User> userList = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, abi__c, PTF_DivisionUO__c, PTF_MacroDivisionUO__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c  FROM User WHERE FederationIdentifier='17'];
        Test.startTest();
        System.enqueueJob(new PermissionSetAsignmentQueuableJobs(null, null, userList));
        Test.stopTest();
    }

    @isTest
    public static void test2() {
        List<User> userList = [SELECT Id, ProfileId,FederationIdentifier,IsActive,UserRoleId,Profilo__c,idced__c, abi__c, PTF_DivisionUO__c, PTF_MacroDivisionUO__c, PTF_RuoloLDAP__c, CRM_PermissionSet__c  FROM User WHERE FederationIdentifier='17'];
        Map<Id, User> userMap = new Map<Id, User>();
        for(user u : userList){
            userMap.put(u.Id, u);
        }
        Test.startTest();
        System.enqueueJob(new PermissionSetAsignmentQueuableJobs(userList, userMap, null));
        Test.stopTest();
    }
}