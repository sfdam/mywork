global class ART_SendDirectOrderToSAPSched implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<Holiday> holydays = [SELECT ActivityDate 
        FROM Holiday 
        WHERE Description = 'IT' AND ActivityDate = TODAY];        
        if(holydays.isEmpty()){

            Database.executeBatch(new ART_SendDirectOrderToSAP(), 25);
        }
    }
}