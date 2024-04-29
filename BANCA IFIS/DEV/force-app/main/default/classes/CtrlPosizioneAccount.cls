public with sharing class CtrlPosizioneAccount {

  @RemoteAction
  public static Rapporto__c[] fetchRapporti(String accountId) {
    Rapporto__c[] pos = [SELECT Accordato__c, Esposizione__c, RecordType.Name  FROM Rapporto__c WHERE Cliente__c = :accountId];
    return pos;
  }

  @RemoteAction
  public static Rapporto__c fetchAssetDebitore (String accountId) {
    String rtFidoDiCoppia = U.getRecordTypes('Rapporto__c').get('FidoDiCoppia').Id;
    Rapporto__c[] assetL = [SELECT
      Id,
      Name,
      Accordato__c,
      AccordatoAnticipi__c,
      AccordatoCassa__c,
      AccordatoOneri__c,
      AccordatoProsolvendo__c,
      ImportoAccordato__c,
      Esposizione__c,
      Montecrediti__c,
      MonteCreditiInScadenza__c,
      MontecreditiScaduto__c,
      MonteCreditiInScadenzaProsolvendo__c,
      MonteCreditiScadutoProsolvendo__c,
      TotaleFidiDiCoppiaProsolvendo__c,
      QuotaProsoluto__c
      FROM Rapporto__c
      WHERE Cliente__c = :accountId
      AND RecordTypeId = :rtFidoDiCoppia LIMIT 1];
    return assetL.size() > 0 ? assetL[0] : new Rapporto__c();
  }

  @RemoteAction
  public static Relazione__c[] fetchRelazioneClienti(String accountId) {
    Relazione__c[] rel = [SELECT Id, AccountFornitore__r.Name, MontecreditiAScadere__c, MontecreditiScaduto__c FROM Relazione__c WHERE AccountCliente__c = :accountId];
    return rel;
  }

  @RemoteAction
  public static String tipoAccount (String accountId) {
    Rapporto__c[] rL = [SELECT Id, SezioneCedente__c, SezioneDebitore__c FROM Rapporto__c WHERE RecordType.DeveloperName = 'FidoDiCoppia' AND Cliente__c = :accountId];

    if(rL.isEmpty() || (!rL[0].SezioneCedente__c && !rL[0].SezioneDebitore__c)) return 'null';
    else if(rL[0].SezioneCedente__c && rL[0].SezioneDebitore__c) return 'Cedente Debitore';
    else if(rL[0].SezioneCedente__c) return 'Cedente';
    else return 'Debitore';
  }

}