/*
 * @Author        : Alessandro Di Nardo @ten
 * @Name		  : ART_DeleteAccountTeamBatchSchedulable 
 * @CreateDate    : 2023-09-08
 * @Description   : 
 * 					
 * @ClassTest     :
 */
global with sharing class ART_DeleteAccountTeamBatchSchedulable implements Schedulable {
    
    global String sobjectName;
    global void execute(System.SchedulableContext sc) {
        ART_DeleteAccountTeamBatch accBatch = new ART_DeleteAccountTeamBatch();
        accBatch.sobjectName = this.sobjectName;
        Database.executeBatch(accBatch, 200);
    }
}