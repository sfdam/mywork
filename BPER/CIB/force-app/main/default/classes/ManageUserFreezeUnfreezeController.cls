/**
 * Name         :   ManageUserFreezeUnfreezeController
 * Author       :   Giorgio Bonifazi 
 * Create Date  :   2021-03-01
 * Description  :   Manage Freezing or Unfreezing of multiple Users
 * Lightning    :   Used as Controller by ManageUserFreezeUnfreeze component
**/

public class ManageUserFreezeUnfreezeController {


    @AuraEnabled
    public static List<Profile> profilesList(){
        
            List<Profile> usersProfile = [SELECT Id, Name  FROM Profile WHERE Name like 'NEC_%' order by Name ASC];
            
        return usersProfile;
    }

    @AuraEnabled
    public static Map<String, Object> getUsers(id profileId){

        Map<String,Object> userMap = new Map<String,Object>();

        Set<Id> freezeId = new Set<Id>();
        Set<Id> unfreezeId = new Set<Id>();

        
        try{
         
            List<user> usersList = [SELECT id FROM User WHERE Profileid = :profileId and IsActive = true];

            System.debug('USER '+ usersList);

            List<userlogin> tmpFreeze = [SELECT UserId FROM UserLogin where IsFrozen = true and UserId IN :usersList];

            System.debug('TMP FREEZE '+ tmpFreeze);

            for(userLogin ul : tmpFreeze){

                freezeId.add(ul.UserId);
            }

            List<userlogin> tmpUnfreeze = [SELECT UserId FROM UserLogin where IsFrozen = false and UserId IN :usersList];

            for(userLogin ul : tmpUnfreeze){

                unfreezeId.add(ul.UserId);
            }


            List<user> freezeUsers = [SELECT Profile.Name, Name, PTF_RegistrationNumber__c, abi__c FROM User where Id IN :freezeId];

            List<user> unfreezeUsers = [SELECT Profile.Name, Name, PTF_RegistrationNumber__c, abi__c FROM User where Id IN :unfreezeId];

                userMap.put('freeze',freezeUsers);

                userMap.put('unfreeze',unfreezeUsers);

                
        }catch(Exception exc) {
            System.debug('An exception occurred '+exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }

        return userMap;
        
    }
    
    @AuraEnabled
    public static void freeze(String users){
        
        list<UsersWrapper.Result> eddy = (list<UsersWrapper.Result>) JSON.deserialize(users, list<UsersWrapper.Result>.class);
        
        list<Id> idsToFreeze  = new list<Id>();
        
        list<UserLogin> freezedId = new list<UserLogin>();

        	for (UsersWrapper.Result result : eddy){

            	idsToFreeze.add(result.id);
        	}
        
        list<UserLogin> ul = [SELECT ID,  IsFrozen FROM UserLogin WHERE UserId  IN :idsToFreeze];
        
        	for(UserLogin u : ul){
            
            	u.IsFrozen = true;
            
            	freezedId.add(u);
        	}
        
        update freezedId;    
    }

    @AuraEnabled
    public static void unfreeze(String users){
        
        list<UsersWrapper.Result> eddy = (list<UsersWrapper.Result>) JSON.deserialize(users, list<UsersWrapper.Result>.class);
        
        list<Id> idsToUnfreeze  = new list<Id>();
        
        list<UserLogin> unfreezedId = new list<UserLogin>();

        	for (UsersWrapper.Result result : eddy){

            	idsToUnfreeze.add(result.id);
        	}
        
        list<UserLogin> ul = [SELECT ID,  IsFrozen FROM UserLogin WHERE UserId  IN :idsToUnfreeze];
        
        	for(UserLogin u : ul){
            
            	u.IsFrozen = false;
            
            	unfreezedId.add(u);
        	}
        
        update unfreezedId;    
    }
   
}