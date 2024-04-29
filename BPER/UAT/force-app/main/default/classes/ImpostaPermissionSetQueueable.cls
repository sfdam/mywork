public  class ImpostaPermissionSetQueueable implements System.Queueable {

    public List<String> userListId = new List<String>();

    public ImpostaPermissionSetQueueable(List<String> userIdList){
        this.userListId = userIdList;
    }

    public void execute(QueueableContext qc) {  

        if (!userListId.isEmpty()) { 
            List<User> userList = [SELECT Id,Profilo__c,isActive FROM User WHERE Id IN: userListId];
            OnUserTriggerHandler.impostaPermissionSet(userList);
        }
    }
}