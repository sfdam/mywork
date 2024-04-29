public class WorkOrderQueueableJobs implements Queueable{

    private List<WorkOrder> listWorkOrder;
    
    public WorkOrderQueueableJobs(List<WorkOrder> woList){
        this.listWorkOrder = woList;
    }

    public void execute(QueueableContext context) {
        
        if(!listWorkOrder.isEmpty()){
            
            update listWorkOrder;
        }
    }
}