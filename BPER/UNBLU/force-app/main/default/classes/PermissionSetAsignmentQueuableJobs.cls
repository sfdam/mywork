public class PermissionSetAsignmentQueuableJobs implements Queueable{

    private List<User> userWithDifferentPSList;
    private Map<Id, User> userWithDifferentPSOldMap;
    private List<User> newUsers;
    
    public PermissionSetAsignmentQueuableJobs(List<User> userWithDifferentPSList, Map<Id, User> userWithDifferentPSOldMap, List<User> newUsers){
        this.userWithDifferentPSList = userWithDifferentPSList;
        this.userWithDifferentPSOldMap = userWithDifferentPSOldMap;
        this.newUsers = newUsers;
    }

    public void execute(QueueableContext context) {
        
        if(newUsers != null){
            onUserTriggerHandler.impostaPermissionSet(newUsers);
        } else if(userWithDifferentPSList != null && userWithDifferentPSOldMap != null){
            OnUserTriggerHandler.associaPermissionSet(userWithDifferentPSList, userWithDifferentPSOldMap);
        }
    }
}