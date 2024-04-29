trigger CaseRelatedIssueTrigger on CaseRelatedIssue (after insert, after delete) {
    // List to hold the Incident Ids
    Set<Id> incidentIds = new Set<Id>();

    if (Trigger.isInsert) {
        // Collect the Incident Ids from the inserted CaseRelatedIssue records
        for (CaseRelatedIssue cri : Trigger.new) {
            incidentIds.add(cri.RelatedIssueId);
        }
    } else if (Trigger.isDelete) {
        // Collect the Incident Ids from the deleted CaseRelatedIssue records
        for (CaseRelatedIssue cri : Trigger.old) {
            incidentIds.add(cri.RelatedIssueId);
        }
    }

    // Update the Incident records with the count of related Case records
    List<Incident> incidentsToUpdate = [
        SELECT Id, (SELECT Id, CreatedDate FROM CaseRelatedIssues WHERE CreatedDate = TODAY) 
        FROM Incident 
        WHERE Id IN :incidentIds
    ];

    for (Incident incident : incidentsToUpdate) {
        incident.Related_Case_Count__c = incident.CaseRelatedIssues.size();
    }

    update incidentsToUpdate;
}