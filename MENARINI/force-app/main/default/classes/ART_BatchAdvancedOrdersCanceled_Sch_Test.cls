@IsTest
public class ART_BatchAdvancedOrdersCanceled_Sch_Test {

    @IsTest
    static void methodName() {
        Test.startTest();
        System.schedule('ART_BatchAdvancedOrdersCanceled_Sch_Test', '0 0 12 * * ?', new ART_BatchAdvancedOrdersCanceled_Sch());
        Test.stopTest();
    }
        
}