//creo l'oggetto TreeGrid necessario all'aura component Pricing
public class TreeGrid {
    
  
    
    //Radice Finanziamento
    public List<Finanziamento> FinanziamentiArray; // [Select id, name [..] from Finanziamenti__c where SBQQ_QLIId__c =: qliId];
   
  
   
    
    public TreeGrid() {}
    
    public class Finanziamento {
        
       
        
        public Finanziamenti__c thisFin; //thisFin.Name, thisFin.Importo__c......
       
        public List<Condizioni__c> CondizioniConPagamentiArray; // [Select id, name, (select id, name from pagamenti__r) from condizioni__r];
    }
}