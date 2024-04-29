/**
* Progetto:         Banca IFIS
* Developer:        Dario Mapelli
* Description:      Batch che invoca, per ogni opportunità (o solo del TiAnticipo) con una fase diversa da "In Lavorazione", "Vinta" o "Persa", il servizio nvInquiryStatoCartella
*                   per aggiornare lo stato delle linee associate
*/
global class BtcAggiornaOpp implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

  String query;
  Boolean tiAnticipo;
  Integer numberOfOpportunitiesToProcess = 0;
  Boolean thereIsFailure = false;
  String failuresDetails = '';
  String failuresLinee = '';

  /**
   * Costruttore
   * @param  onlyTiAnticipo se true, verranno aggiornate solamente le opportunità TiAnticipo (quelle che rispettan le condizioni);
   *                        se false, tutte (quelle che rispettan le condizioni)
   */
  global BtcAggiornaOpp(Boolean onlyTiAnticipo) {
    tiAnticipo = onlyTiAnticipo;
    query = 'SELECT Id FROM Opportunity WHERE StageName NOT IN (\'In Lavorazione\', \'Vinta\', \'Persa\') AND RecordTypeId = \'' + U.getRecordTypes('Opportunity').get('IFISOpportunitaFactoring').Id + '\'';
    if (onlyTiAnticipo) query += ' AND TiAnticipo__c = true';
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    // preparo i dati necessari
    Id[] oppIds = U.toIdList(U.getIdSet(scope, 'Id'));
    Opportunity[] opportunities = [SELECT Id, IdCartella__c FROM Opportunity WHERE Id = :oppIds];
    numberOfOpportunitiesToProcess += opportunities.size();
    Map<String, ExtViewCheckList.Prodotto> prodotti = new Map<String, ExtViewCheckList.Prodotto>(); // chiave: {oppId}_{prodottoId della linea}. valore: codiceStato della linea
    Set<String> prodottoSet = new Set<String>{};

    // per ogni opportunità da aggiornare, invoco il servizio e mi salvo le linee da aggiornare
    for (Opportunity o : opportunities) {
      Logger.setTransactionContext(o.Id, null);
      try {
        WsRestCrm.NvInquiryStatoCartellaResponse res = WsRestCrm.nvInquiryStatoCartella(o.IdCartella__c);
        for (WsRestCrm.Prodotto pc: res.payload.prodotti.prodotto) {
          ExtViewCheckList.Prodotto p = new ExtViewCheckList.Prodotto();
          p.idProdotto = String.valueOf(pc.idProdotto).leftPad(6, '0');
          p.codiceStato = String.valueOf(pc.codiceStato);
          p.descrizioneStato = pc.descrizioneStato;
          prodotti.put(o.Id + '_' + p.idProdotto, p);
          prodottoSet.add(p.idProdotto);
        }
        o.DataInquiryStatoCartella__c = Datetime.now();
      } catch (Exception e) {
        thereIsFailure = true;
        failuresDetails += 'Opportunità ' + o.Id + ': ' + e.getMessage() + '\n';
      }
      Logger.endTransaction();
    }

    Linea__c[] linee = [SELECT Opportunity__c, IdProdotto__c FROM Linea__c WHERE Opportunity__c IN :oppIds AND IdProdotto__c IN :prodottoSet];
    Map<String, Linea__c[]> lineePerOpp = U.groupBy(linee, 'Opportunity__c');

    if (linee.size() < prodotti.keySet().size()) {
      failuresLinee = 'Alcuni prodotti non sono stati trovati su CRM. \n';
    }

    Linea__c[] lineeToUpdate = new Linea__c[]{};
    for (Opportunity o : opportunities) {
      if (lineePerOpp.containsKey(o.Id)) {
        for (Linea__c l : lineePerOpp.get(o.Id)) {
          l.Stato__c = prodotti.get(o.Id + '_' + l.IdProdotto__c).codiceStato;
          lineeToUpdate.add(l);
        }
      }
    }
    Database.SaveResult[] srLList = Database.update(lineeToUpdate, false);
    Database.SaveResult[] srOList = Database.update(opportunities, false);

    // Cerco errori nel salvataggio dei record su CRM
    for (Database.SaveResult sr : srOList) {
      if (!sr.isSuccess()) {
        thereIsFailure = true;
        failuresDetails += 'Opportunità ' + sr.getId() + ': ';
        for (Database.Error err : sr.getErrors()) {
          failuresDetails += err.getStatusCode() + ': ' + err.getMessage() + ', ';
        }
        failuresDetails += '\n';
      }
    }

    for (Database.SaveResult sr : srLList) {
      if (!sr.isSuccess()) {
        thereIsFailure = true;
        failuresDetails += 'Linea ' + sr.getId() + ': ';
        for (Database.Error err : sr.getErrors()) {
          failuresDetails += err.getStatusCode() + ': ' + err.getMessage() + ', ';
        }
        failuresDetails += '\n';
      }
    }

  }

  /**
   * Inserisco un log (con Source__c: BTC_AggiornaOpp oppure BTC_AggiornaOppTA)
   * che riassume gli errori riscontrati
   */
  global void finish(Database.BatchableContext bc) {
    String message = 'Processate ' + numberOfOpportunitiesToProcess + ' opportunità' + (tiAnticipo ? ' TiAnticipo' : '') + '.\n' + failuresLinee + 'ERRORI: ';
    message += (thereIsFailure) ? '\n' + failuresDetails : 'nessuno.';
    Logger.log('BTC_AggiornaOpp' + (tiAnticipo ? ' TA' : ''), message);
  }

}