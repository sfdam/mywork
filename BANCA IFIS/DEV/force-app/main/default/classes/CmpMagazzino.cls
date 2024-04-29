public with sharing class CmpMagazzino {

   public class InterfaceAccount {
      @AuraEnabled
      public Account acc {get; set;}
      @AuraEnabled
      public Decimal priorita {get; set;}
    }

   @AuraEnabled
   public static List<InterfaceAccount> getAccountList(String tipo) {
      Id userId = UserInfo.getUserId();

      String queryStr = QueryBuilder.newInstance('Task', new String[]{'WhatId'})
        .beginFilter()
          .addUntyped('Campagna__c != NULL', tipo == 'prospect')
          .addUntyped('Campagna__c = NULL', tipo == 'magazzino')
          .add('OwnerId', QBOp.QEQUAL, userId)
          .beginCrossFilter('Account', 'WhatId', 'Id')
            .add('RecordType.Name', QBOp.QEQUAL, 'Cliente', tipo == 'clienti')
            .add('RecordType.Name', QBOp.QEQUAL, 'Prospect', tipo == 'prospect' || tipo == 'magazzino')
          .endCrossFilter(false)
        .endFilter()
        .setLimit(10)
        .orderBy(new String[]{'ActivityDate'})
        .getQuery();

      Account[] accs = new List<Account>();
      Set<Account> accSet = new Set<Account>();
      Task[] tasks = Database.query(queryStr);

      Set<String> whatIds = U.getSet(tasks, 'WhatId');
      Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id, Name, Fatturato__c FROM Account WHERE Id IN :whatIds]);
      for(Task t : tasks) {
        Account a = mapAccounts.get(t.WhatId);
        a.Name = a.Name.abbreviate(30);
        // se nel set non ho ancora l'account, lo aggiungo
        if(!accSet.contains(a)) accs.add(a);
        accSet.add(a);
      }

      InterfaceAccount[] iaccs = new List<InterfaceAccount>();
      for(Account a : accs) {
         InterfaceAccount i = new InterfaceAccount();
         i.acc = a;
         i.priorita = 0; // rimasto da vecchia versione
         iaccs.add(i);
      }
      System.debug('eccoli '+iaccs);
      return iaccs;
   }

   @AuraEnabled
   public static Account resetPrioritaAccount(String accountId, String tipo) {
      Decimal reset = 10;
      String campo = 'PrioritaSviluppo'+tipo+'__c';
      Account a = [SELECT Id,Name FROM Account WHERE Id = :accountId];
      a.put(campo,reset);
      update a;

      return a;
   }

}