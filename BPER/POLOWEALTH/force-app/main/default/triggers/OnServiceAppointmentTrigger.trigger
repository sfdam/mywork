trigger OnServiceAppointmentTrigger on ServiceAppointment (after update) {  
  
    
  //  List <Event> eventList = [Select id, SAppointtment_Opportunity__c, ServiceAppointmentId 
   //         from Event where ServiceAppointmentId =: Trigger.New];
      List <Event> eventList = [Select id, SAppointtment_Opportunity__c, ServiceAppointmentId 
            from Event where ServiceAppointmentId =: Trigger.New];
    
    system.debug('***Sono dentro OnServiceAppointmentTrigger, eventList : ' +eventList);
    
    if(!eventList.isEmpty()){   EventUpdateFields.updateEvent(eventList);   }


}