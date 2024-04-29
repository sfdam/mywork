@isTest
public class ART_SendDirectOrderToSAPTest {
    @TestSetup
    static void setup(){
        Account a = new Account(Name = 'Test', THR_AccountsKey__c = '12345');
        insert a;
        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c(Name = 'TestTemplate');
        insert orderTemplate;
        cgcloud__Order__c order = new cgcloud__Order__c(cgcloud__Order_Template__c = orderTemplate.Id);
        order.ART_Order_Sent_to_SAP__c = false;
        order.ART_Order_To_Be_Sent__c = true;
        order.cgcloud__Phase__c = 'Ready';
        order.ART_Delivery_note__c = 'Consegna urgente;Prima di consegnare contattare;Chiuso per ferie dal/al;Consegnare dal/al;Consegnare nella fascia oraria il giorno';
        order.ART_Customer_Service_Note__c = '';
        order.ART_Riferimento_Contatto__c = '1234567890';
        order.ART_Data_inizio__c = Date.today().addDays(1);
        order.ART_Data_fine__c = Date.today().addDays(10);
        order.ART_Data_inizio_consegna__c = Date.today().addDays(1);
        order.ART_Data_fine_consegna__c = Date.today().addDays(10);
        order.ART_Orario_inizio__c = Time.newInstance(09, 00, 00, 00);
        order.ART_Orario_fine__c = Time.newInstance(12, 00, 00, 00);
        order.ART_Giorno_Settimanale__c = 'lun-mar-mer';
        insert order;
        cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c(cgcloud__Order__c = order.Id);
        orderItem.cgcloud__Quantity__c = 20;
        orderItem.cgcloud__Discount__c = 0;
        insert orderItem;
    }

    @isTest
    public static void testBatch(){

        Test.startTest();
        Test.setMock(WebServiceMock.class, new ART_SendDirectOrderToSAPMock());
        // Id batchJobId = Database.executeBatch(new ART_SendDirectOrderToSAP(), 50);
        String CRON_EXP = '0 30 7 ? * MON,TUE,WED,THU,FRI *';
        String jobId = System.schedule('ART_SendDirectOrderToSAPSchedTest', CRON_EXP, new ART_SendDirectOrderToSAPSched());
        Test.stopTest();
    }
}