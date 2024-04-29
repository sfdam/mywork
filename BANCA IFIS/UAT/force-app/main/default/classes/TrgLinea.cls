public class TrgLinea {

  /**
   * Invio di mail per le linee TiAnticipo
   */
  public static void inviaMail(T tu) {

    if (MailUtils.isMailTiAnticipoDisabilitate) return;

    // prendo gli id delle linee di interesse..
    Linea__c[] lineeTemp = new Linea__c[]{};
    lineeTemp.addAll((Linea__c[]) tu.filter('Stato__c', '4').getChanged('Stato__c')); // linee approvate
    lineeTemp.addAll((Linea__c[]) tu.filter('Stato__c', '5').getChanged('Stato__c')); // linee rifiutate
    lineeTemp.addAll((Linea__c[]) tu.filter('Stato__c', '6').getChanged('Stato__c')); // linee in lavorazione
    Set<Id> lineeIds = U.getIdSet(lineeTemp, 'Id');

    // ..con le informazioni degli oggetti collegati, filtrando le linee TiAnticipo
    Linea__c[] linee = [
      SELECT Id,
      Stato__c,
      Opportunity__c,
      Opportunity__r.AccountId,
      Opportunity__r.Cessione__c,
      Opportunity__r.Account.Name,
      Opportunity__r.Account.NDGGruppo__c,
      Opportunity__r.Account.Email__c,
      Opportunity__r.Account.EmailPEC__c,
      Opportunity__r.Account.Filiale__c,
      Opportunity__r.Account.IBAN__c,
      Opportunity__r.Account.Phone,
      Opportunity__r.Cessione__r.FirmaDigitale__c,
      Opportunity__r.Cessione__r.CreatedById,
      Opportunity__r.Cessione__r.CreatedBy.Email
      FROM Linea__c
      WHERE Id IN :lineeIds
      AND Opportunity__r.TiAnticipo__c = true];

    if (linee.size() == 0) return;

    Set<Id> oppIds = U.getIdSet(linee, 'Opportunity__c');
    Map<String, NDGLinea__c[]> attoriPerOppTipo = U.groupBy([
      SELECT Id,
      Account__r.Name,
      Tipo__c,
      NDG__c,
      Opportunita__c
      FROM NDGLinea__c
      WHERE Opportunita__c IN :oppIds
      AND (Tipo__c = 'Esecutore adeguata verifica'
        OR Tipo__c = 'Titolare effettivo adeguata verifica')
      ], '{Opportunita__c}_{Tipo__c}', true);

    Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
    String[] toAddresses;
    String[] ccAddresses;

    Map<String, SObject> emailTemplates = U.keyBy([
      SELECT Id,
      DeveloperName,
      Markup
      FROM EmailTemplate
      WHERE DeveloperName IN ('TiAnticipo3', 'TiAnticipo4', 'TiAnticipo7', 'TiAnticipo8', 'TiAnticipo9a', 'TiAnticipo9b', 'TiAnticipo10', 'TiAnticipo16')], 'DeveloperName');

    Map<String, OrgWideEmailAddress[]> senderIds = U.groupBy([
      SELECT Id,
      DisplayName
      FROM OrgWideEmailAddress], 'DisplayName');

    Map<String, IndirizziFiliali__mdt[]> indirizziFiliali = U.groupBy([
      SELECT Id,
      DeveloperName,
      Email__c,
      EmailGestore__c
      FROM IndirizziFiliali__mdt
    ], 'DeveloperName');

    // per ognuna di queste, invio una mail:
    for (Linea__c l : linee) {

      // linea approvata e firma digitale
      if (l.Stato__c == '4' && l.Opportunity__r.Cessione__r.FirmaDigitale__c) {

        // Codice notifica 109 FD / 108 FA - 112FD / 111FA ---> 108 D - 110 D
        toAddresses = new String[]{MailUtils.EMAIL_NUCLEO_CONTRATTI};
        ccAddresses = null;
        if (emailTemplates.containsKey('TiAnticipo7') && senderIds.containsKey('Segreteria Fidi'))
          mails.add(MailUtils.creaMailApexHTML(l.Opportunity__r.Cessione__c, emailTemplates.get('TiAnticipo7').Id, null, senderIds.get('Segreteria Fidi')[0].Id, null, toAddresses, ccAddresses, null));

        // Codice notifica 110 FD - 113 FD ---> 109 D - 111 D
        // popolo i dati della mail
        String subject = 'TiAnticipo ' + l.Opportunity__r.Account.NDGGruppo__c + ' ' + l.Opportunity__r.Account.Name;
        String titolareEffettivo = attoriPerOppTipo.containsKey(l.Opportunity__c + '_Titolare effettivo adeguata verifica') ? attoriPerOppTipo.get(l.Opportunity__c + '_Titolare effettivo adeguata verifica')[0].Account__r.Name : '';
        String[] esecutori = new String[]{};
        if (attoriPerOppTipo.containsKey(l.Opportunity__c + '_Titolare effettivo adeguata verifica')) {
          for (NDGLinea__c esec : attoriPerOppTipo.get(l.Opportunity__c + '_Esecutore adeguata verifica')) {
            esecutori.add(esec.Account__r.Name);
          }
        }
        Map<String,String> sostituzioni = new Map<String,String>();
        sostituzioni.put('$$Name$$', l.Opportunity__r.Account.Name);
        sostituzioni.put('$$NDGGruppo__c$$', l.Opportunity__r.Account.NDGGruppo__c);
        sostituzioni.put('$$EmailPEC__c$$', l.Opportunity__r.Account.EmailPEC__c);
        sostituzioni.put('$$IBAN__c$$', l.Opportunity__r.Account.IBAN__c);
        sostituzioni.put('$$TitolareEffettivo$$', titolareEffettivo);
        sostituzioni.put('$$Esecutori$$', String.join(esecutori, ', '));

        toAddresses = new String[]{MailUtils.EMAIL_CMD};
        ccAddresses = null;
        if (emailTemplates.containsKey('TiAnticipo9b') && senderIds.containsKey('Segreteria Fidi'))
          mails.add(MailUtils.creaMailApexHTMLSostituzioni((String)emailTemplates.get('TiAnticipo9b').get('Markup'), subject , null, senderIds.get('Segreteria Fidi')[0].Id, null, toAddresses, ccAddresses, null, sostituzioni));
      }

      // linea approvata e firma autografa
      if (l.Stato__c == '4' && !l.Opportunity__r.Cessione__r.FirmaDigitale__c) {

        // Codice notifica 109 FD / 108 FA - 112FD / 111FA ---> 108 A - 110 A
        toAddresses = new String[]{MailUtils.EMAIL_NUCLEO_CONTRATTI};
        ccAddresses = null;
        if (emailTemplates.containsKey('TiAnticipo8') && senderIds.containsKey('Segreteria Fidi'))
          mails.add(MailUtils.creaMailApexHTML(l.Opportunity__r.Cessione__c, emailTemplates.get('TiAnticipo8').Id, null, senderIds.get('Segreteria Fidi')[0].Id, null, toAddresses, ccAddresses, null));

        // Codice notifica 109 FA - 112 FA ---> 109A - 111A
        if (indirizziFiliali.containsKey('F' + l.Opportunity__r.Account.Filiale__c)) {
          IndirizziFiliali__mdt indirizziFiliale = indirizziFiliali.get('F' + l.Opportunity__r.Account.Filiale__c)[0];
          if (String.isNotBlank(indirizziFiliale.Email__c) && String.isNotBlank(indirizziFiliale.EmailGestore__c)) {
            // popolo i dati della mail
            String subject = 'TiAnticipo ' + l.Opportunity__r.Account.NDGGruppo__c + ' ' + l.Opportunity__r.Account.Name;
            String titolareEffettivo = attoriPerOppTipo.containsKey(l.Opportunity__c + '_Titolare effettivo adeguata verifica') ? attoriPerOppTipo.get(l.Opportunity__c + '_Titolare effettivo adeguata verifica')[0].Account__r.Name : '';
            String[] esecutori = new String[]{};
            if (attoriPerOppTipo.containsKey(l.Opportunity__c + '_Titolare effettivo adeguata verifica')) {
              for (NDGLinea__c esec : attoriPerOppTipo.get(l.Opportunity__c + '_Esecutore adeguata verifica')) {
                esecutori.add(esec.Account__r.Name);
              }
            }
            Map<String,String> sostituzioni = new Map<String,String>();
            sostituzioni.put('$$Name$$', l.Opportunity__r.Account.Name);
            sostituzioni.put('$$NDGGruppo__c$$', l.Opportunity__r.Account.NDGGruppo__c);
            sostituzioni.put('$$EmailPEC__c$$', l.Opportunity__r.Account.EmailPEC__c);
            sostituzioni.put('$$Email__c$$', l.Opportunity__r.Account.Email__c);
            sostituzioni.put('$$Phone$$', l.Opportunity__r.Account.Phone);
            sostituzioni.put('$$IBAN__c$$', l.Opportunity__r.Account.IBAN__c);
            sostituzioni.put('$$TitolareEffettivo$$', titolareEffettivo);
            sostituzioni.put('$$Esecutori$$', String.join(esecutori, ', '));

            toAddresses = new String[]{indirizziFiliale.Email__c};
            ccAddresses = new String[]{indirizziFiliale.EmailGestore__c};
            if (emailTemplates.containsKey('TiAnticipo9a') && senderIds.containsKey('Segreteria Fidi'))
              mails.add(MailUtils.creaMailApexHTMLSostituzioni((String)emailTemplates.get('TiAnticipo9a').get('Markup'), subject , null, senderIds.get('Segreteria Fidi')[0].Id, null, toAddresses, ccAddresses, null, sostituzioni));
          }
        }
      }

      // linea rifiutata
      if (l.Stato__c == '5') {

        // Codice notifica 114a FD / 113a FA ---> 114
        toAddresses = new String[]{l.Opportunity__r.Cessione__r.CreatedBy.Email};
        ccAddresses = new String[]{MailUtils.EMAIL_FILO_DIRETTO};
        if (emailTemplates.containsKey('TiAnticipo10') && senderIds.containsKey('Portale TiAnticipo'))
          mails.add(MailUtils.creaMailApexHTML(l.Opportunity__r.Cessione__c, emailTemplates.get('TiAnticipo10').Id, null, senderIds.get('Portale TiAnticipo')[0].Id, null, toAddresses, ccAddresses, null));

        // Codice notifica 114b FD / 113b FA ---> 114b (ELIMINATA)
        /*
        toAddresses = new String[]{MailUtils.EMAIL_FILO_DIRETTO};
        ccAddresses = null;
        if (emailTemplates.containsKey('TiAnticipo16') && senderIds.containsKey('Portale TiAnticipo'))
          mails.add(MailUtils.creaMailApexHTML(l.Opportunity__r.Cessione__c, emailTemplates.get('TiAnticipo16').Id, null, senderIds.get('Portale TiAnticipo')[0].Id, null, toAddresses, ccAddresses, null));
        */
      }

      // linea in lavorazione
      if (l.Stato__c == '6') {

        // Codice notifica 106 FD / 105 FA ---> 107
        toAddresses = new String[]{MailUtils.EMAIL_SEGRETERIA_FIDI};
        ccAddresses = new String[]{MailUtils.EMAIL_FILO_DIRETTO};
        if (emailTemplates.containsKey('TiAnticipo3') && senderIds.containsKey('Operations'))
          mails.add(MailUtils.creaMailApexHTML(l.Opportunity__c, emailTemplates.get('TiAnticipo3').Id, null, senderIds.get('Operations')[0].Id, null, toAddresses, ccAddresses, null));

        // Codice notifica 107 FD / 106 FA ---> 106
        toAddresses = new String[]{MailUtils.EMAIL_SEGRETERIA_CONTROPARTI};
        ccAddresses = null;
        if (emailTemplates.containsKey('TiAnticipo4') && senderIds.containsKey('Operations'))
          mails.add(MailUtils.creaMailApexHTML(l.Opportunity__c, emailTemplates.get('TiAnticipo4').Id, null, senderIds.get('Operations')[0].Id, null, toAddresses, ccAddresses, null));
      }
    }

    // Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
    if (!mails.isEmpty()) {
      if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
        MailUtils.logNotSentEmail();
      } else {
        Messaging.sendEmail(mails);
      }
    }
  }

}