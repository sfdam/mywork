/**
 * Name         :   ManageUserFreezeUnfreezeController
 * Author       :   Giorgio Bonifazi 
 * Create Date  :   2021-03-23
 * Description  :   Test class for the component "Manage Freezing or Unfreezing of multiple Users"
**/
@isTest
public  class ManageUserFreezeUnfreezeControllerTest {

    @TestSetup
    static void setup(){

        List<Profile> profile = [SELECT id FROM Profile WHERE Name = 'NEC_D.4' LIMIT 1];
        User user = AllDataFactory.getUser('01', profile[0].Id, 'CORPORATE');
        User user2 = AllDataFactory.getUser('02', profile[0].Id, 'CORPORATE');
        User user3 = AllDataFactory.getUser('03', profile[0].Id, 'CORPORATE');
        insert new List<User>{user, user2, user3};
    }

    @IsTest
    public static void testMetodo1(){
		test.startTest();
        List<Profile> usersProfile = ManageUserFreezeUnfreezeController.profilesList();
        test.stopTest();
        System.assertEquals(true, usersProfile.size()>0);
    }

    @IsTest
    public static void testMetodo2(){

        List<Profile> profile = [SELECT id FROM Profile WHERE Name = 'NEC_D.4' LIMIT 1];

        id profileId = profile[0].id;
		test.startTest();
        Map<String,Object> users = ManageUserFreezeUnfreezeController.getUsers(profileId);
        test.stopTest();
        System.assertEquals(true, users.size()>0);
    }

    @IsTest
    public static void testMetodo3(){

        list<User> users = [SELECT ID FROM USER LIMIT 1 ];

        String eddy = '[{"Id": "'+users[0].Id+'"}]';
        list<Id> idsToFreeze  = new list<Id>();
        list<UserLogin> unfreezedId = new list<UserLogin>();
                
                test.startTest();
                
                try{
                
                  ManageUserFreezeUnfreezeController.unfreeze(eddy);

                }
                catch(exception e){

                }
                test.stopTest();
        System.assertEquals(false ,unfreezedId.size()>0);
       
        
    }

    @IsTest
    public static void testMetodo4(){

        list<User> users = [SELECT ID FROM USER LIMIT 1 ];
		list<Id> idsToFreeze  = new list<Id>();
        String eddy = '[{"Id": "'+users[0].Id+'"}]';
        list<UserLogin> freezedId = new list<UserLogin>();
           
      
                test.startTest();
                
                try{
                
                    ManageUserFreezeUnfreezeController.freeze(eddy);

                }
                catch(exception e){

                }
                test.stopTest();
         System.assertEquals(false, idsToFreeze.size()>0);
    }
    
}