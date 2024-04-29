public class ContactStrategyController {

    public SObject obj;
    public String fieldSets {get; set;}
    public String profilesAllowedToEdit {get; set;}
    public ContactStrategyController() {}

    public ContactStrategyController(ApexPages.StandardController ctrl) {
      obj = (SObject) ctrl.getRecord();
      if (obj instanceOf Account) {
        Account acc = (Account) obj;
        if (acc.StatoFastFinance__c == 'Fallimento') fieldSets = 'FastFinanceAzienda';
        else if (acc.StatoFastFinance__c == 'Tribunale') fieldSets = 'FastFinanceTribunale';
        else fieldSets = 'NoInfoAvailable';
      } else if (obj instanceOf Contact) {
        Contact con = (Contact) obj;
        if (con.StatoFastFinance__c == 'Professionista') fieldSets = 'FastFinanceProfessionista';
        if (con.StatoFastFinance__c == 'Giudice Delegato') fieldSets = 'FastFinanceGiudice';
      }
      profilesAllowedToEdit = 'IFIS - Fast Finance';
  }

    @AuraEnabled
    @RemoteAction
    public static String getStatoFastFinance(Id accountId) {
      String stato = [SELECT StatoFastFinance__c FROM Account WHERE Id = :accountId][0].StatoFastFinance__c;
      return stato;
    }
}