/**
* Progetto:         Banca IFIS
* Descrizione:      Controller per pagina RichiediAssegnazione - fa scattare il trigger su Account
*                   premendo il pulsante "Richiedi Assegnazione" della scheda account
* Sviluppata il:    04/10/2016
* Developer:        Zerbinati Francesco, Michele Triaca
*/

public with sharing class ExtRichiediAssegnazione {

  private Account a;

  /**
   *  Contiene l'eventuale messaggio sul perchè non si può richiedere l'assegnazione
   */
  public String richiestaNonPossibile {get;set;}
  public Boolean nonRichiestaMotivazione {get;set;}
  private transient ApexPages.standardController controller;

  public ExtRichiediAssegnazione(ApexPages.StandardController stdController) {
    if (!Test.isRunningTest()) stdController.addFields(new String[]{'OwnerId', 'Owner.IsActive','StatoAssegnazione__c'});

    this.a = (Account)stdController.getRecord();
    System.debug(this.a);
    this.controller = stdController;

    // la richiesta non è possibile se è gestore debitori, se sono già owner oppure se una richiesta è in corso
    this.richiestaNonPossibile = '';
    if(CU.isGestoreDebitori()) richiestaNonPossibile = Label.ErroreAssegnazioneRuoloErrato;
    else if(a.OwnerId == UserInfo.getUserId()) richiestaNonPossibile = Label.ErroreAssegnazioneGiaResponsabile;
    else if(String.isNotBlank(this.a.StatoAssegnazione__c)) {
      this.richiestaNonPossibile = Label.ErroreAssegnazioneRichiestaGiaPresente;
    }

    // non è richiesta una motivazione quando l'owner è default o uno degli utenti assegnatari di default
    this.nonRichiestaMotivazione = (a.OwnerId == (Id) UtenzeDefault__c.getInstance().IdUtente__c || UtenzeDefault__c.getInstance(a.OwnerId).AssegnatarioDiDefault__c);
  }

  @RemoteAction
  public static Boolean richiediAssegnazione(String accountId, String motivazione) {
    System.debug('richiesta: ' + accountId + ' ' + motivazione);

    Account a = [
      SELECT Id,
      OwnerId,
      Owner.IsActive,
      CommercialeLending__c,
      CommercialeFastFinance__c,
      CommercialeFinanzaStrutturata__c,
      CommercialeEF__c,
      CommercialeTR__c,
      CommercialeFinance__c
      FROM Account
      WHERE Id = :accountId];

    if (CU.isGestoreDebitori()) throw new Ex.WSException(Label.ErroreAssegnazioneRuoloErrato);

    String userId = UserInfo.getUserId();
    if (a.OwnerId == userId && (!(CU.isFinance() || CU.isLeasing() || CU.isLending() || CU.isFastFinance() || CU.isFinanzaStrutturata()))) {
      throw new Ex.WSException(Label.ErroreAssegnazioneGiaResponsabile);
    } else if (a.CommercialeLending__c == userId && CU.isLending()) {
      throw new Ex.WSException(Label.ErroreAssegnazioneGiaResponsabile);
    } else if (a.CommercialeFastFinance__c == userId && CU.isFastFinance()) {
      throw new Ex.WSException(Label.ErroreAssegnazioneGiaResponsabile);
    } else if (a.CommercialeFinanzaStrutturata__c == userId && CU.isFinanzaStrutturata()) {
      throw new Ex.WSException(Label.ErroreAssegnazioneGiaResponsabile);
    } else if (a.CommercialeEF__c == userId || a.CommercialeTR__c == userId) {
      String commercialeTipo = [SELECT RuoloLeasing__c FROM User WHERE Id = :userId].RuoloLeasing__c;
      if ((commercialeTipo == 'CommercialeEF' && a.CommercialeEF__c == userId) ||
          (commercialeTipo == 'CommercialeTR' && a.CommercialeTR__c == userId))
      throw new Ex.WSException(Label.ErroreAssegnazioneGiaResponsabile);
    } else if (a.CommercialeFinance__c == userId && CU.isFinance()) {
      throw new Ex.WSException(Label.ErroreAssegnazioneGiaResponsabile);
    }

    System.debug('Invio richiesta assegnazione');

    System.SavePoint sp = Database.setSavepoint();
    try {
      if (String.isNotBlank(a.CommercialeFinanzaStrutturata__c)) {
        a.StatoAssegnazione__c = 'Richiesta';
        a.MotivazioneRichiesta__c = motivazione;
        a.Richiedente__c = userId;
        update a; //UWS.updateObjs(new SObject[]{a}, false);
      } else {
        if ((UtenzeDefault__c.getInstance(a.OwnerId).AssegnatarioDiDefault__c || !a.Owner.IsActive) && (!(CU.isFinance() || CU.isLeasing() || CU.isFastFinance() || CU.isLending() || CU.isFinanzaStrutturata()))) {
          a.OwnerId = userId;
          a.Presentatore__c = userId;
          UWS.updateObjs(new SObject[]{a}, false);
          TrgAccount.creaContattoTelefonico(new T(new Account[]{a}, null));
        } else if (CU.isLending() && String.isBlank(a.CommercialeLending__c)) {
          a.CommercialeLending__c = userId;
          UWS.updateObjs(new SObject[]{a}, false);
        } else if (CU.isFinance() && String.isBlank(a.CommercialeFinance__c)) {
          a.CommercialeFinance__c = userId;
          UWS.updateObjs(new SObject[]{a}, false);
        } else if (CU.isFastFinance() && String.isBlank(a.CommercialeFastFinance__c)) {
          a.CommercialeFastFinance__c = userId;
          UWS.updateObjs(new SObject[]{a}, false);
        } else {
          a.StatoAssegnazione__c = 'Richiesta';
          a.MotivazioneRichiesta__c = motivazione;
          a.Richiedente__c = userId;
          update a; //UWS.updateObjs(new SObject[]{a}, false);
        }
      }
      return true;
    } catch (Exception e) {
      Database.rollback(sp);
      System.debug('Errore richiesta: '+e.getMessage());
      throw new Ex.WSException('Non riesco a richiedere l\'assegnazione: ' + e.getMessage(), e);
    }
  }
}