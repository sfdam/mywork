public class ResetRelatedCaseCount implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<Incident> incidentsToUpdate = [
            SELECT Id, Related_Case_Count__c
            FROM Incident
            WHERE Related_Case_Count__c > 0
        ];
        
        for (Incident inc : incidentsToUpdate) {
            inc.Related_Case_Count__c = 0;
        }
        
        update incidentsToUpdate;
    }
}