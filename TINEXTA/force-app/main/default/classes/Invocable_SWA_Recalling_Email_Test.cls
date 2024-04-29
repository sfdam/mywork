@isTest
public class Invocable_SWA_Recalling_Email_Test {
    
    @isTest
    public static void invocaMetodo(){
        
        List<List<string>> inputlistlist = new List<List<string>>();
        List<String> inputlist = new List<String>{'test@email.it','test2@email.it','oggetto','Riccardo Paglia','idOpportunita','corpo mail di test'};
        inputlistlist.add(inputlist);        
        
        Invocable_SWA_Recalling_Email.Invocable_Invio_Recall(inputlistlist);
    }
    @isTest
    public static void invocaMetodoErr(){
        
        List<List<string>> inputlistlist = new List<List<string>>();
        List<String> inputlist = new List<String>();
        inputlistlist.add(inputlist);        
        
        Invocable_SWA_Recalling_Email.Invocable_Invio_Recall(inputlistlist);
    }
}