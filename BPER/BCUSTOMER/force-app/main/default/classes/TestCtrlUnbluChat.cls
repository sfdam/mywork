@isTest
public class TestCtrlUnbluChat {
    
    @isTest
    static void test_getConversationUrl_1(){

        Test.startTest();

        Case c = new Case();
        c.CC_Id_Conversationd_Unblu__c = 'testXYZ123';
        insert c;

        try{
            CtrlUnbluChat.getConversationUrl(c.Id);
        }catch(Exception ex){}

        Test.stopTest();

    }

    @isTest
    static void test_getConversationUrl_2(){

        Test.startTest();

        Case c = new Case();
        insert c;

        CtrlUnbluChat.getConversationUrl(c.Id);

        Test.stopTest();

    }

}