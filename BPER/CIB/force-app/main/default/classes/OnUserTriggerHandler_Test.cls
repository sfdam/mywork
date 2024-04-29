@isTest
private class OnUserTriggerHandler_Test {

    @TestSetup
    static void makeData(){
        AbilitazioneGruppi__c r1= new AbilitazioneGruppi__c();
        r1.Name='05387;5385;NEC_D.6';
        r1.Gruppo__c='UtentiPortafogliazione';
        insert r1;
        AbilitazioneGruppi__c r2= new AbilitazioneGruppi__c();
        r2.Gruppo__c='UtentiPortafogliazioneBDS';
        r2.Name='01015;6928;NEC_D.2';
        insert r2;	

        //ADDED
        WorkOrder wo = new WorkOrder(Status = 'pending', Queues__c = 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)', StepsApprovers__c = 'STEP1(NEC_D.6)', OriginalOwner__c = Userinfo.getUserId());
        insert wo;

        Profile profile1 = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('10', profile1.Id, 'Personal');
        user.FederationIdentifier='10';
        user.Profilo__c = 'ADMIN';
        user.abi__c='05387';
        user.idced__c='5385'; 
        insert user;
        //ADDED
        
        
        
    }
    
    @isTest
    static void unitTest() {
        // list<GroupMember> gggg = [SELECT GroupId, Group.Name,UserOrGroupId, Group.DeveloperName FROM GroupMember LIMIT 50000];
        //ADDED
        User admin = [SELECT id FROM User WHERE FederationIdentifier='10' LIMIT 1];
        WorkOrder wo = [SELECT id FROm WorkOrder LIMIT 1];
        //ADDED
        // System.debug('*** '+gggg);
        List<User> users = new List<User>();
        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];
        UserRole ruoloCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center' LIMIT 1];
        Group g = new Group(Name='Test_1',DeveloperName='Test_1');
        insert g;
        User u1 = AllDataFactory.getUser('01', profile.Id, null);
        u1.Profilo__c = 'NEC_D.6';
        u1.abi__c='05387';
        u1.idced__c='5385';        
        u1.FederationIdentifier = 'test';
        users.add(u1);
        User u2 = AllDataFactory.getUser('02', profile.Id, null);
        u2.Profilo__c = 'NEC_CC';
        users.add(u2);
        
        Test.startTest();
        	insert users;
            //ADDED
            System.runAs(admin){

                Group queue = new Group();
                queue.Name = 'Approvers Step 1 Queue1';
                queue.DeveloperName = 'Q_TEST_false_1_1';
                queue.Type = 'Queue';
                insert queue;
                GroupMember member = new GroupMember();
                member.GroupId = queue.Id;
                member.UserOrGroupId = users.get(0).Id;
                insert member;
                List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('note');
                approvalRequest.setObjectId(wo.Id);
                approvalRequest.setSubmitterId(UserInfo.getUserId());
                approvalRequest.setNextApproverIds(new List<Id>{queue.id});
                approvalRequestList.add(approvalRequest);
                Approval.process(approvalRequestList);
            }
            //ADDED

            users.get(0).Profilo__c = 'NEC_D.2';
            users.get(0).abi__c = '01015';
            users.get(0).idced__c = '6928';
        	users.get(1).userRoleId = ruoloCC.Id;
            update users;
            users.get(0).idced__c = '';
            update users;
        Test.stopTest();
        List<User> usersResponse = [SELECT id FROM User Limit 1];
        System.assertEquals(true, usersResponse.size()>0);
        
    }
    
    @isTest
    static void testcontrolloDisattivazione(){
        Profile profile1 = [SELECT id,Name FROM Profile WHERE  Name =:'NEC_CC' LIMIT 1];
        User user1 = AllDataFactory.getUser('120', profile1.Id, 'Personal');
        user1.FederationIdentifier='12';
        user1.Profilo__c = profile1.Name;
        user1.abi__c='05387';
        user1.idced__c='5385'; 
        user1.IsActive=false;
        user1.Da_Disattivare_Batch__c=false;
        insert user1;
       
        
        
        List<User> users = [SELECT id,Profilo__c,IsActive,Da_Disattivare_Batch__c FROM User WHERE Profilo__c='NEC_CC' LIMIT 1];
        User user = [SELECT id,Profilo__c,IsActive FROM User WHERE Profilo__c='NEC_CC' LIMIT 1];
        user.IsActive = true;
        user.Da_Disattivare_Batch__c=true;
        Map<Id,User> oldRecord =new Map<ID, User>();
        oldRecord.put(user.Id, user);
         
        
        Test.startTest();
        OnUserTriggerHandler.controlloDisattivazione(users,oldRecord);
        Test.stopTest();  
       
    }

  /*  @isTest
    static void testPermissionSet() {
        String profiloName = Label.System_Administrator;
        Profile profile = [SELECT id FROM Profile WHERE Name =:profiloName  LIMIT 1];
        User user = AllDataFactory.getUser('95', profile.Id, 'CORPORATE');
        user.Profilo__c='NEC_CC';
        user.isActive=true;
        List<User> listUser = new List<User>();
        listUser.add(user);
        insert listUser;
        OnUserTriggerHandler.impostaPermissionSet(listUser);
    } */
    /*@isTest
    static void testRun() {
        OnUserTriggerHandler.testRun();

    } */

}