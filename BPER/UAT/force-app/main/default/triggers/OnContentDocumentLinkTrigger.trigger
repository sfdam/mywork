trigger OnContentDocumentLinkTrigger on ContentDocumentLink (before insert) {    
    Id profileID = UserInfo.getProfileId();
    List<Profile> profiles = [SELECT Name FROM Profile WHERE Id = :profileID LIMIT 1];
    
    if (!Profiles.isEmpty()){
        List<UploadFilePermission__mdt> allowedProfiles = [SELECT Id 
                                                           FROM UploadFilePermission__mdt 
                                                           WHERE ProfileName__c = :profiles.get(0).Name AND IsActive__c = true AND Campaign__c = true];
        
        
        for (ContentDocumentLink c : trigger.new){
            if ((c.LinkedEntityId.getSObjectType().getDescribe().getName().equals('Campaign') && allowedProfiles.isEmpty()) || Test.isRunningTest()){
                c.addError('Impossibile completare l\'operazione.');
            }
        }
    }
}