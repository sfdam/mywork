public without sharing class OnDelegaTriggerHandler {
    
    public static void handleBeforeInsert(List<Delega__c> newList){

        Set<String> deleganteSet = new Set<String>();
        for(Delega__c delega : newList){
            if(String.isBlank(delega.Delegante__c)){
                delega.Delegante__c = UserInfo.getUserId();
            }
            deleganteSet.add(delega.Delegante__c);
        }

        Map<String, List<SObject>> delegheMap = SV_Utilities.groupBy([SELECT Id, Delegante__c, StartDate__c, EndDate__c FROM Delega__c WHERE Scaduto__c = false AND Delegante__c IN: deleganteSet], 'Delegante__c');
        List<User> userToUpdate = new List<User>();
        for(Delega__c delega : newList){
            if(delegheMap.containsKey(delega.Delegante__c)){
                for(Delega__c exsistingDelega : (List<Delega__c>)delegheMap.get(delega.Delegante__c)){
                    Date EndDate = exsistingDelega.EndDate__c != null ? exsistingDelega.EndDate__c : exsistingDelega.StartDate__c.addDays(30);
                    if((delega.StartDate__c <= EndDate && delega.StartDate__c >= exsistingDelega.StartDate__c) ||
                    (delega.EndDate__c >= exsistingDelega.StartDate__c && delega.EndDate__c <= EndDate)){
                        
                        delega.addError('É già presente una delega attiva tra le date impostate.');
                    }
                }
            }
            if(!delega.hasErrors() && delega.Startdate__c == Date.today()){
                userToUpdate.add(new User(Id = delega.Delegante__c, DelegatedApproverId = delega.Delegato__c));
            }
        }
        if(!userToUpdate.isEmpty()){

            updateUsers(JSON.serialize(userToUpdate));
        }
    }

    public static void handleBeforeUpdate(List<Delega__c> newList, Map<Id,Delega__c> oldMap){

        List<User> userToUpdate = new List<User>();
        for(Delega__c delega : newList){
            if(delega.Cancelled__c && !oldMap.get(delega.Id).Cancelled__c){
                delega.EndDate__c = Date.today();
                userToUpdate.add(new User(Id = delega.Delegante__c, DelegatedApproverId = null));
            }
        }
        if(!userToUpdate.isEmpty()){

            updateUsers(JSON.serialize(userToUpdate));
        }
    }

    @Future
    public static void updateUsers(String userListJSON){
        OnUserTriggerHandler.skipUpdateMember = true;
        update (List<User>)JSON.deserialize(userListJSON, List<User>.class);
    } 
}