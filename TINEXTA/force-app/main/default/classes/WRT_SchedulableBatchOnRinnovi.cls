global class WRT_SchedulableBatchOnRinnovi implements Schedulable{
    global void execute(SchedulableContext sc){
    WRT_BatchOnRinnovi b = new WRT_BatchOnRinnovi(); //ur batch class
      database.executebatch(b);
        
       //string sch = '0 1 1 * * ?';
      // system.schedule ('Batch', sch, new WRT_SchedulableBatchOnRinnovi());
    }   
}