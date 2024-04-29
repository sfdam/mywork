public class OnAccountTeamMemberTriggerHandler {

    public static Boolean disableOnAccountTeamMemberTrigger = false;

    public static void DeleteCoverageTeamMember( List <AccountTeamMember> atmList){
        if(!disableOnAccountTeamMemberTrigger){
            Set<Id> oldIdSet = new Set<Id>();
            for (AccountTeamMember atm : atmList){
                oldIdSet.add(atm.Id);
            }

            List <Coverage_Team_Member__c> oldCoverageTeam = new List<Coverage_Team_Member__c>([SELECT  Id, Account__c, User__c 
                                                        FROM Coverage_Team_Member__c 
                                                        WHERE Account_Team_Member_Id__c IN: oldIdSet]);
                                                        
            System.debug ('oldCoverageTeam: '+oldCoverageTeam);
            delete oldCoverageTeam;
        }
    }
}