trigger ART_Order_trigger on Order (before delete) {
    if(trigger.isBefore && Trigger.isDelete){
        Id profileId = userinfo.getProfileId();
        profile profileName = [SELECT Name FROM Profile WHERE id=:profileId];
        list<ART_SalesRepProfile__mdt> customMetadataProfileName = [SELECT ART_ProfileName__c FROM ART_SalesRepProfile__mdt];
        set<string> SetProfile=new set<string>();
        for(ART_SalesRepProfile__mdt SRP:customMetadataProfileName){
            SetProfile.add(SRP.ART_ProfileName__c);
        }
        for(Order DelOrd : Trigger.old){
            if(SetProfile.contains(profileName.Name)){
                DelOrd.addError('L\'ordine non può essere cancellato.');
            }
        }
    }
}