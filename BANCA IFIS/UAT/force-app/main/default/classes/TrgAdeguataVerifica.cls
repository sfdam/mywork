public class TrgAdeguataVerifica {
  /**
   * Allineamento indirizzo corrispondenza da TiAnticipo.
   * Dagli oggetti AdeguataVerifica provvisori con campo Account popolato, allinea gli oggetti AdeguatVerifica con campo
   * Opportunità popolato.
   * AFTER INSERT - AFTER UPDATE
   */
  public static void allineaAdeguataVerifica(T tu) {

    AdeguataVerifica__c[] advsToUpdate = new AdeguataVerifica__c[]{};

    // preparo i dati, filtrando le Adv di interesse (quelle col campo Account popolato)
    AdeguataVerifica__c[] advs = tu.filter('Account__c', (String)null, false).triggerNew;
    Map<String, AdeguataVerifica__c[]> accountToAdvMap = U.groupBy(advs, 'Account__c');

    // le opportunità che considero sono quelle la cui cessione non ha ancora superato la fase di "Analisi Pratica".
    AdeguataVerifica__c[] existingAdvs = [
      SELECT Id,
      Opportunita__c,
      Opportunita__r.Cessione__r.Stato__c,
      Opportunita__r.AccountId
      FROM AdeguataVerifica__c
      WHERE Opportunita__c IN (
        SELECT Id
        FROM Opportunity
        WHERE AccountId IN :accountToAdvMap.keySet()
        AND Cessione__r.Stato__c IN ('0', '1', '2')
      )
    ];
        
    Map<String, AdeguataVerifica__c[]> accountToAdvToUpdateMap = U.groupBy(existingAdvs, 'Opportunita__r.AccountId');

    // aggiorno ora le AdeguataVerifica
    for (String acc : accountToAdvMap.keySet()) {
      if (accountToAdvToUpdateMap.containsKey(acc)) {
        AdeguataVerifica__c advTriggered = accountToAdvMap.get(acc)[0];
        for (AdeguataVerifica__c adv : accountToAdvToUpdateMap.get(acc)) {
          adv.CorrispondenzaStreetType__c = advTriggered.CorrispondenzaStreetType__c;
          adv.CorrispondenzaStreetName__c = advTriggered.CorrispondenzaStreetName__c;
          adv.CorrispondenzaStreetNumber__c = advTriggered.CorrispondenzaStreetNumber__c;
          adv.CorrispondenzaCity__c = advTriggered.CorrispondenzaCity__c;
          adv.CorrispondenzaCAP__c = advTriggered.CorrispondenzaCAP__c;
          adv.CorrispondenzaState__c = advTriggered.CorrispondenzaState__c;
          adv.CorrispondenzaCountry__c = advTriggered.CorrispondenzaCountry__c;
          adv.TipoIndirizzo__c = advTriggered.TipoIndirizzo__c;
          advsToUpdate.add(adv);
        }
      }
    }
    update advsToUpdate;
  }
}