global class TXT_SchedulableBatchOnRinnovi implements Schedulable{
    global void execute(SchedulableContext sc){
    TXT_BatchImpostazioneRinnovi b = new TXT_BatchImpostazioneRinnovi(); //ur batch class
      database.executebatch(b);
    }   
}