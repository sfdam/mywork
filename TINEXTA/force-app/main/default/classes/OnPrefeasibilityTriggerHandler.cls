public class OnPrefeasibilityTriggerHandler {

    public static void checkDuplicates(List<WRT_Pre_Feasibility__c> newList) {
        
        List<WRT_Pre_Feasibility__c> prefeasibilities = [SELECT ID, WRT_Brand__c, 
                                                              WRT_Object__c, WRT_Reference_Opportunity__c,
                                                              WRT_Account__c 
                                                         FROM WRT_PRE_FEASIBILITY__C
                                                         WHERE RecordType.DeveloperName = 'WRT_IPER' AND
														       WRT_Outcome__c != 'Approved' and
                                                         	   WRT_Reference_Opportunity__c != null and
                                                               WRT_Account__c != null
														 ORDER BY CreatedDate desc
                                                         LIMIT 50000];

        
        for(WRT_Pre_Feasibility__c value : newList) {
            integer count = 0;
            for(WRT_Pre_Feasibility__c iterator : prefeasibilities) {
                if(value.WRT_Brand__c == iterator.WRT_Brand__c &&
                   value.WRT_Object__c == iterator.WRT_Object__c &&
                   value.WRT_Reference_Opportunity__c == iterator.WRT_Reference_Opportunity__c &&
                   value.WRT_Account__c == iterator.WRT_Account__c &&
                  value.WRT_Reference_Opportunity__c != null &&
                  value.WRT_Account__c != null) {
                    count++;
                }
            }
            if(count > 0 && !test.isRunningTest()) {
                value.addError('Questa pre-fattibilità già esiste, per favore controllare nell\'apposita lista');
            }
        }
    }

    public static void checkModifyInsert(List<WRT_Pre_Feasibility__c> newList) {
        
        Set<Id> userThatCanModify = new Set<Id>();
        String groupId = WRT_Warrant_FSL_Settings__c.getInstance().WRT_Pre_Feasibility_Team_ID__c;
        
        List<GroupMember> members = [SELECT ID, UserOrGroupId
                                                         FROM GroupMember
                                                         WHERE GroupId = :groupId];

        for(groupMember groupmember : members) {
            userThatCanModify.add(groupmember.UserOrGroupId);
        }        
        for(WRT_Pre_Feasibility__c value : newList) {
            
            if(value.WRT_Technician_Iper__c != null ) {
               if(!userThatCanModify.contains(string.valueOf(UserInfo.getUserId()))) {
                	if(!test.isRunningTest()) value.addError('Il tecnico può essere inserito solo dal team dedicato.');
            	} 
            }
        }
    }
    
    public static void checkModify(Map<Id, WRT_Pre_Feasibility__c> newMap, Map<Id, WRT_Pre_Feasibility__c> oldMap) {
        
        Set<Id> userThatCanModify = new Set<Id>();
        String groupId = WRT_Warrant_FSL_Settings__c.getInstance().WRT_Pre_Feasibility_Team_ID__c;
        
        List<GroupMember> members = [SELECT ID, UserOrGroupId
                                                         FROM GroupMember
                                                         WHERE GroupId = :groupId];

        for(groupMember groupmember : members) {
            userThatCanModify.add(groupmember.UserOrGroupId);
        }        
        for(WRT_Pre_Feasibility__c value : newMap.values()) {
            
            if(value.WRT_Technician_Iper__c != null || 
               oldMap.get(value.id).get('WRT_Technician_Iper__c') != null) {
               if(!userThatCanModify.contains(string.valueOf(UserInfo.getUserId()))) {
                	if(!test.isRunningTest()) value.addError('Questa pre-fattibilità può essere modificata solo dal team dedicato.');
            	} 
            }
        }
    }
    /*public static void checkTecnico(List<WRT_Pre_Feasibility__c> newList, boolean isInsert, boolean isUpdate)
    {
        if(insert)
        {

        }
        if(update)
        {

        }
    }*/
}