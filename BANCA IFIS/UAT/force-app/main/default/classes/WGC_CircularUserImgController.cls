public class WGC_CircularUserImgController {
	@AuraEnabled
    public static user getUser(String userId){
        system.debug('SV userId: ' + userId);
        system.debug(UserInfo.getUserId());
        if (userId == null || userId == '')
        	//return [SELECT Id, Name, SmallPhotoUrl FROM User WHERE Id = :UserInfo.getUserId()];
            return null;
        else 
            return [SELECT Id, Name, SmallPhotoUrl FROM User WHERE Id = :userId];
    }
}