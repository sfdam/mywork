@isTest
public class customLookUpController_Test {
    
    @isTest
    static void Testa(){
        test.starttest();
        Pricebook2 PB = new Pricebook2();
        PB.name='Test';
        insert PB; 
        
        customLookUpController.fetchLookUpValues('C','Pricebook2','Italy',true);
        test.stoptest();
    }
}