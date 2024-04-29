public with sharing class ServiceAppointmentController {
    @AuraEnabled
    public static List<ServiceAppointment> getAllData(String recordId){
        
        return [SELECT Id,AppointmentNumber,Subject, SchedStartTime FROM ServiceAppointment 
                WHERE Status = 'Programmato' and AccountId=:recordId];
    }
}