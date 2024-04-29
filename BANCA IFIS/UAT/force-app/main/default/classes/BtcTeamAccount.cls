/**
* Progetto:         Banca IFIS
* Developer:        Dario Mapelli
* Description:      Batch per introduzione dei team account
*/
global class BtcTeamAccount implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

  Integer numberOfAccountsToProcess = 0;
  Integer numberOfInsertedATMs = 0;
  Boolean thereIsFailure = false;
  String failuresDetails = '';


  global BtcTeamAccount() {}

  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator('SELECT Id, OwnerId FROM Account');
  }


  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    Account[] accs = (Account[]) scope;
    Set<Id> utenzeDaNonConsiderare = U.getIdSet([SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', 'Amministratore del sistema')], 'Id');
    AccountTeamMember[] atms = new AccountTeamMember[]{};
    for (Account a : accs) {
      if (a.OwnerId != null && !utenzeDaNonConsiderare.contains(a.OwnerId)) atms.add(new AccountTeamMember(AccountId = a.Id, UserId = a.OwnerId, TeamMemberRole = 'CommercialeFactoring', CaseAccessLevel = 'Read'));
    }
    Database.SaveResult[] srAList = Database.insert(atms, false);

    for (Database.SaveResult sr : srAList) {
      if (!sr.isSuccess()) {
        thereIsFailure = true;
        failuresDetails += 'Id ' + sr.getId() + ': ';
        for (Database.Error err : sr.getErrors()) {
          failuresDetails += err.getStatusCode() + ': ' + err.getMessage() + ', ';
        }
        failuresDetails += '\n';
      } else {
        numberOfInsertedATMs++;
      }
    }
  }

  /**
   * Inserisco un log che riassume gli errori riscontrati
   */
  global void finish(Database.BatchableContext bc) {
    String message = 'Processati ' + numberOfAccountsToProcess + ' account, inseriti ' + numberOfInsertedATMs + ' AccountTeamMember.\n ERRORI: ';
    message += (thereIsFailure) ? '\n' + failuresDetails : 'nessuno.';
    Logger.log('BTC_TeamAccount', message);
  }

}