@isTest
public class OnServiceAppointmentTrigger_Test {

    @isTest 
    static  void test_Event_SA_Trigger(){
        
		Datetime now = System.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
		
        Account account = AllDataFactory.getPersonAccount('01');
        insert account;
        
        ServiceAppointment servApp = new ServiceAppointment();
        servApp.Subject='Appuntamento call 1';
        servApp.SchedStartTime=Datetime.now();
        servApp.status='Programmato';
        servApp.ParentRecordId=account.id;
        insert servApp;
        
		Event Eve = new Event ();
       // Eve.ServiceAppointmentId = servApp.Id;
		Eve.WhatId = servApp.Id;
		Eve.SAppointtment_Opportunity__c ='';
		//Eve.EventAppointmentFlag__c = true;
        Eve.DurationInMinutes = 30;
        Eve.ActivityDateTime = datetime.newInstance(2021, 11, 18, 09, 30, 0);
         
		insert Eve;
        
        List<Event> listEvent = new List<Event>();
        listEvent.add(Eve);
        
        update listEvent;
        
        Test.startTest();
        system.debug('Stanpo la lista degli Eventi:'+ listEvent);
        update servApp;
        
        Test.stopTest();
        
    }
    
}