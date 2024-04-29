@isTest 
public class CalendarLayoutControllerTest {
    static testMethod void testAllMethods() {
        
        Funzionalita__c x = new Funzionalita__c();
      	x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
       	insert x;         
        
        User usr = TestDataFactory.create_User(UserInfo.getProfileId());
        usr.Societa__c = 'Warrant';
        insert usr;
        
        // Create Lead
            Lead l = new Lead();
            l.LastName = 'Test';
            l.Industry = 'Altro';
            l.Company ='testComp';
            insert l;
            
            // Create Account
            Account a = new Account();
            a.Name='Test Account';
            a.Partita_iva__c = '00000000001';
            a.Codice_fiscale__c = '00000000001';                                   
            a.Industry = 'Altro';
            a.Societa_di_riferimento__c = 'Warrant';
            insert a;
            
            // Create Contact
            Contact c = new Contact();
            c.FirstName='Test';
            c.LastName='Contact';
            c.AccountId = a.Id;
            insert c;
        
        System.runAs(usr) {
            CalendarLayoutController.getUsers();
            String user_id = CalendarLayoutController.getUserId();
            System.assertEquals( user_id, UserInfo.getUserId() );
            
            CalendarLayoutController.WrapperResponse resultLead = CalendarLayoutController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',user_id,l.Id,'Lead','test event' ,'test note');
            CalendarLayoutController.WrapperResponse resultAccount = CalendarLayoutController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',user_id,a.Id,'Account','test event' ,'test note');
            CalendarLayoutController.WrapperResponse resultContact = CalendarLayoutController.createNewEvent( '2016-01-01 00:00:00','2016-01-01 01:00:00',user_id,c.Id,'Contact','test event' ,'test note');

            System.assertEquals( [SELECT Id FROM Event].size(), 3 );
            
            Event e = new Event();
            e.StartDateTime = DateTime.valueOf( '2016-01-01 00:00:00' );
            e.EndDateTime   = DateTime.valueOf( '2016-01-01 01:00:00' );
            e.OwnerId = user_id;
            e.subject = 'test';
            e.WhoId = l.Id;
            INSERT e;
            
            String sResult = CalendarLayoutController.getEvents( DateTime.valueOf('2015-01-01 00:00:00'), DateTime.valueOf('2017-01-01 01:00:00'),user_id );
            
            
        }
        
    }
}