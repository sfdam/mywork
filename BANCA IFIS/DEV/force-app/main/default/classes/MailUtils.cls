/**
* Progetto:         Banca IFIS
* Sviluppata il:    09/01/2017
* Developer:        Zerbinati Francesco
*/

/**
* Delle mail inviate:
*   - Segnalazione Rendimax: viene inviata tramite questa classe
*   - Segnalazione NPL: viene inviata tramite questa classe (ma non viene invocata)
*   - Notifica Visita Commerciale —> viene inviata da CtrlFiloDiretto con il metodo inviaMail
*/

public with sharing class MailUtils {

  // Email utilizzate per le notifiche TiAnticipo
  public static final String EMAIL_OPERATIONS = 'datacerta.tianticipo@bancaifis.it';
  public static final String EMAIL_OPERATIONS_NV = 'crm.tianticipo@bancaifis.it';
  public static final String EMAIL_SEGRETERIA_FIDI = 'cedente.tianticipo@bancaifis.it';
  public static final String EMAIL_NUCLEO_CONTRATTI = 'contratti.tianticipo@bancaifis.it';
  public static final String EMAIL_CMD = 'cmd.tianticipo@bancaifis.it';
  public static final String EMAIL_SEGRETERIA_CONTROPARTI = 'debitore.tianticipo@bancaifis.it';
  public static final String EMAIL_FILO_DIRETTO = 'filodiretto.tianticipo@bancaifis.it';
  public static final String EMAIL_GESTIONE_DEBITORI = 'gestionedebitori.tianticipo@bancaifis.it';

  // Log utilizzati nel caso in cui sia disabilitato l'invio delle mail tramite Custom Setting "DisabilitaInvioEmail"
  public static final String LOG_NAME = 'Email';
  public static final String LOG_MESSAGE = 'Il custom setting "DisabilitaInvioEmail" non ha permesso l\'invio di mail.\n';

  public static Boolean isMailTiAnticipoDisabilitate = false;

  // invia una mail, accetta stringa email oppure id di un contact
  public static void inviaMail(String destinatario, String templName) {
    Email__c e = new Email__c();
    e.Template__c = templName;

    try {
      //Se destinatario è un id
      Id x = (Id) destinatario;
      Contact c = [SELECT Id, Email FROM Contact WHERE Id = :x];
      e.To__c = c.Email;
    } catch(Exception err) {
      e.To__c = destinatario;
    }

    // Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
    if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
      MailUtils.logNotSentEmail('Template name: ' + templName + '. to: ' + destinatario);
    } else {
      insert e;
    }
  }

  // invia le mail dato un template email e una lista di task/eventi al whoid correlato
  public static void inviaMaildaTaskEventi(SObject[] lista, String templName ) {

    Impostazioni__c i = Impostazioni__c.getInstance();

    Boolean isNPL = templName == 'SegnalazioneNPL';
    Boolean isRendimax = templName == 'SegnalazioneRendimax';
    //Boolean isContattoTelefonico = templName == 'ContattoTelefonicoKO';

    //Map<Id,Contact> contattiMail = new Map<Id,Contact>([SELECT Id, Email FROM Contact WHERE Id IN :U.getIdSet(lista, 'WhoId')]);

      String mailAddr = '';
      //if(isContattoTelefonico) mailAddr = contattiMail.get(contactId).Email;
      if(isNPL) mailAddr = i.MailNPL__c;
      if(isRendimax) mailAddr = i.MailRendimax__c;

    List<Email__c> emails = new List<Email__c>();
    for(SObject l : lista) {
      Id contactId = (Id) l.get('WhoId');
      Id accountId = (Id) l.get('WhatId');

      Email__c e = new Email__c();
      e.To__c = mailAddr;
      e.Contact__c = contactId;
      e.Template__c = templName;
      emails.add(e);
    }

    // Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
    if (!emails.isEmpty()) {
      if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
        String message = '';
        for (Email__c em : emails) message += 'Template name: ' + em.Template__c + '. To: ' + em.To__c + '\n';
        MailUtils.logNotSentEmail(message);
      } else {
        // inserisco le mail, poi il workflow si occuperà di spedirle
        insert emails;
      }
    }
  }

  public static void inviaMailApex(String templName, String subject, List<String> to, List<String> cc, Map<String,String> sostituzioni) {

    EmailTemplate templ = [SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = :templName];

    String text = templ.Body;
    if (sostituzioni != null) {
      for(String k : sostituzioni.keySet()) {
        text = text.replace(k, sostituzioni.get(k));
      }
    }

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    if(!to.isEmpty()) mail.setToaddresses(to);
    if(cc != null && !cc.isEmpty()) mail.setCcAddresses(cc);

    mail.setSenderDisplayName('Salesforce BANCA IFIS');
    if(!String.isBlank(subject)) mail.setSubject(subject);

    mail.setTreatBodiesAsTemplate(true);
    mail.setPlainTextBody(text);

    mail.setTargetObjectId(UserInfo.getUserId());
    mail.setsaveAsActivity(false);
    mail.setTreatTargetObjectAsRecipient(false);

    // Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
    if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
      MailUtils.logNotSentEmail('Template name: ' + templName + '. Subject: ' + subject + '. To: ' + String.join(to, '; ') + '. Cc: ' + String.join(cc, '; ') + '\n');
    } else {
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
  }

  public static void inviaMailApexHTML(String templName, String subject, List<String> to, List<String> cc, List<String> ccn, Map<String,String> sostituzioni) {
    String html = null;
    if(Test.isRunningTest()) html = '<html></html>';
    else {
      EmailTemplate templ = [SELECT Id, Markup, Subject FROM EmailTemplate WHERE DeveloperName = :templName];
      html = templ.Markup;
    }

    for(String k : sostituzioni.keySet()) {
      String v = (String) sostituzioni.get(k);
      if(v == null) v = '-';
      html = html.replace(k, v);
    }

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    if(!to.isEmpty()) mail.setToaddresses(to);
    if(!cc.isEmpty()) mail.setCcAddresses(cc);
    if(!ccn.isEmpty()) mail.setBccAddresses(ccn);

    mail.setSenderDisplayName('Salesforce BANCA IFIS');
    if(!String.isBlank(subject)) mail.setSubject(subject);

    mail.setTreatBodiesAsTemplate(true);
    mail.setHtmlBody(html);

    mail.setTargetObjectId(UserInfo.getUserId());
    mail.setsaveAsActivity(false);
    mail.setTreatTargetObjectAsRecipient(false);

    // Se le mail sono disabilitate o se sono in un test loggo il mancato invio delle mail
    if (Funzionalita__c.getInstance().DisabilitaInvioEmail__c || Test.isRunningTest()) {
      MailUtils.logNotSentEmail('Template name: ' + templName + '. Subject: ' + subject + '. To: ' + String.join(to, '; ') + '. Cc: ' + String.join(cc, '; ') + '. Ccn: ' + String.join(ccn, '; ') + '\n');
    } else {
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
  }

  public static Messaging.SingleEmailMessage creaMailApexHTMLSostituzioni(String templateMarkup, String subject, String senderDisplayName, Id senderId, Id targetObjectId, List<String> to, List<String> cc, List<String> ccn, Map<String,String> sostituzioni) {

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String html = templateMarkup;

    for (String k : sostituzioni.keySet()) {
      String v = (String) sostituzioni.get(k);
      if (v == null) v = '-';
      html = html.replace(k, v);
    }

    if (senderId != null) mail.setOrgWideEmailAddressId(senderId);
      else if (String.isNotBlank(senderDisplayName)) mail.setSenderDisplayName(senderDisplayName);
    mail.setTreatTargetObjectAsRecipient(targetObjectId != null);

    if (to != null && !to.isEmpty()) mail.setToaddresses(to);
    if (cc != null && !cc.isEmpty()) mail.setCcAddresses(cc);
    if (ccn != null && !ccn.isEmpty()) mail.setBccAddresses(ccn);

    if (!String.isBlank(subject)) mail.setSubject(subject);
    mail.setTargetObjectId(UserInfo.getUserId());
    mail.setHtmlBody(html);
    mail.setTreatBodiesAsTemplate(true);
    mail.setSaveAsActivity(false);

    return mail;
  }


  /**
   * Crea una mail
   * @param  whatId            oggetto per popolare i merge fields
   * @param  templateId        id del template da utilizzare
   * @param  senderDisplayName se senderId non è specificato, verrà utilizzata questa stringa per il nome del mittente
   * @param  senderId          id dell'org-wide mail address, contenente indirizzo mail e senderDisplayName
   * @param  targetObjectId    se popolato, sarà il destinatario della mail; altrimenti, verranno usati i campi "to, cc, ccn"
   * @param  to
   * @param  cc
   * @param  ccn
   */
  public static Messaging.SingleEmailMessage creaMailApexHTML(Id whatId, Id templateId, String senderDisplayName, Id senderId, Id targetObjectId, List<String> to, List<String> cc, List<String> ccn) {

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    if (senderId != null) mail.setOrgWideEmailAddressId(senderId);
      else if (String.isNotBlank(senderDisplayName)) mail.setSenderDisplayName(senderDisplayName);
    mail.setTreatTargetObjectAsRecipient(targetObjectId != null);
    if (targetObjectId == null) {
      targetObjectId = UserInfo.getUserId();
      if (to != null && !to.isEmpty()) mail.setToaddresses(to);
      if (cc != null && !cc.isEmpty()) mail.setCcAddresses(cc);
      if (ccn != null && !ccn.isEmpty()) mail.setBccAddresses(ccn);
    }
    mail.setTargetObjectId(targetObjectId);
    mail.setTemplateId(templateId);
    mail.setTreatBodiesAsTemplate(false);
    mail.setWhatId(whatId);
    mail.setsaveAsActivity(false);
    return mail;
  }

  public static void logNotSentEmail() {
    MailUtils.logNotSentEmail('');
  }

  public static void logNotSentEmail(String message) {
    Logger.log(LOG_NAME, LOG_MESSAGE + message);
  }

}