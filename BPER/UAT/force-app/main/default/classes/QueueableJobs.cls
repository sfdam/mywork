public without sharing class QueueableJobs implements Queueable{

    private List<SObject> sObjectList;
    private String action{get;set;}

    public QueueableJobs(List<SObject> sObjectListVar, String actionVar) {
        this.sObjectList = sObjectListVar;
        this.action = actionVar;
    }

    public void execute(QueueableContext context) {
        
        if(!sObjectList.isEmpty()){
            if(action == '1'){
                insert sObjectList;
            }else if(action == '2'){
                update sObjectList;
            }else if(action == '3'){
                upsert sObjectList;
            }else if(action == '4'){
                delete sObjectList;
            }
        }
    }
}