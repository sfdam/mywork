@isTest 
private class CalendarControlerTest{
    static testMethod void testAllMethods() {
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_trigger__c = true;
        insert x;
        User innUs = [SELECT Id FROM User WHERE Societa__c = 'Innolva' LIMIT 1 ];
        User cmkUs = [SELECT Id FROM User WHERE Societa__c = 'CoMark' LIMIT 1 ];
        User warUs = [SELECT Id FROM User WHERE Societa__c = 'Warrant' LIMIT 1 ];
        CalendarController.getUsers();
        String user_id = CalendarController.getUserId();
       	System.assertEquals( user_id, UserInfo.getUserId() );
        
        // Create Lead
        Lead l = new Lead();
        l.LastName = 'Test';
        l.Industry = 'Altro';
        l.Company ='testComp';
        insert l;
         
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        Contact c = TestDataFactory.create_Contact();
        c.AccountId = acc[0].Id;
        insert c;
           Boolean result1 = CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',innUs.Id,l.Id,'Lead','test event' ,'test note','','','','','',null);
           Boolean result2= CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',innUs.Id,acc[0].Id,'Account','test event' ,'test note','','','','','',null);

           Boolean result3 = CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',cmkUs.Id,l.Id,'Lead','test event' ,'test note','','','','','',null);
           Boolean result4 = CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',cmkUs.Id,acc[0].Id,'Account','test event' ,'test note','','','','','',null);

 
        Test.startTest();
           Boolean result5 = CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',warUs.Id,l.Id,'Lead','test event' ,'test note','','','','','',null);
           Boolean result6 = CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',warUs.Id,acc[0].Id,'Account','test event' ,'test note','','','','','',null);
		 	Boolean result7 = CalendarController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',warUs.Id,c.Id,'Contact','test event' ,'test note','','','','','',null);

				

		Event e = new Event();
       	e.StartDateTime = DateTime.valueOf( '2016-01-01 00:00:00' );
       	e.EndDateTime   = DateTime.valueOf( '2016-01-01 01:00:00' );
       	e.OwnerId = user_id;
       	e.subject = 'test';
        e.WhoId = l.Id;
       	INSERT e;

		String sResult = CalendarController.getEvents( DateTime.valueOf('2015-01-01 00:00:00'), DateTime.valueOf('2017-01-01 01:00:00'),user_id );

        Test.stopTest();
    }

}