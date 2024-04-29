@istest
public class TreeGrid_Test {
    @istest 
    public static void testSuccess (){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
     
        insert x;
        
        
         TreeGrid treegrid = new TreeGrid();
         treegrid.FinanziamentiArray = new List<TreeGrid.Finanziamento>();
        
        
        
        
          
         x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        
        
        
        
        Test.startTest();
     
        
      
        Test.stopTest();  
        
        
    }

}