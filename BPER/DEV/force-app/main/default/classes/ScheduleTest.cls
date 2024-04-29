@isTest
public class ScheduleTest {
    @isTest
    public static void testIsNext() {
        Schedule schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isNext();
        
        schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SA,SU');
        schedule.isNext();
        
        schedule = new Schedule('09:00:00', '20:30:00', 'closed', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isNext();
    }
    
    @isTest
    public static void testIsInRange() {
        Schedule schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isInRange();
        
        schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SA,SU');
        schedule.isInRange();
        
        schedule = new Schedule('09:00:00', '20:30:00', 'closed', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isInRange();
    }
    
    @isTest
    public static void testIsOpen() {
        Schedule schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isOpen();
        schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SA,SU');
        schedule.isOpen();
        schedule = new Schedule('09:00:00', '20:30:00', 'closed', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isOpen();
    }
    
    @isTest
    public static void testIsClosed() {
        Schedule schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isClosed();
        schedule = new Schedule('09:00:00', '20:30:00', 'open', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SA,SU');
        schedule.isClosed();
        schedule = new Schedule('09:00:00', '20:30:00', 'closed', 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR');
        schedule.isClosed();
    }
}