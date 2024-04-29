/**
* Progetto:         Banca IFIS
* Developer:        Triaca Michele, Stefano Brivio
*/
@RestResource(urlMapping = '/log')
global without sharing class Logger {
  private Logger() {}

  @HttpPost
  global static Boolean createLog(Log__c log) {
    try {
      insert log;
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  static Id oppId;
  static Id accOrContactId;
  static String transactionId;
  global static void beginTransaction() {
    Logger.transactionId = String.valueOf(Datetime.now().getTime()) + String.valueOf((Math.random() * 100000).intValue());
  }

  global static void setTransactionContext(Id oppId, Id accOrContactId) {
    if(String.isBlank(transactionId)) beginTransaction();
    Logger.oppId = oppId;
    Logger.accOrContactId = accOrContactId;
  }

  global static void endTransaction() {
    oppId = null;
    accOrContactId = null;
    transactionId = null;
  }

  @future
  public static void logAsync(String logJSON) {
    insert (Log__c) JSON.deserialize(logJSON, Log__c.class);
  }

  public static Boolean log(String source, String errorMsg) {
    return log(new Log__c(
      Source__c = source,
      ErorrMessage__c = errorMsg,
      Opportunity__c = oppId,
      Account__c = accOrContactId != null && accOrContactId.getSObjectType() == Account.SObjectType ? accOrContactId : null,
      Contact__c = accOrContactId != null && accOrContactId.getSObjectType() == Contact.SObjectType ? accOrContactId : null
    ));
  }

  public static Boolean log(Log__c l) {

    if (Test.isRunningTest()) return false;

    l.Opportunity__c = oppId;
    l.Account__c = accOrContactId != null && accOrContactId.getSobjectType() == Account.SObjectType ? accOrContactId : null;
    l.Contact__c = accOrContactId != null && accOrContactId.getSobjectType() == Contact.SObjectType ? accOrContactId : null;

    Boolean canCallout = Limits.getDMLRows() == 0 && !Trigger.isExecuting;
    Boolean canFuture = !U.isAsync();
    if(canCallout) {
      String sessionId = getSessionId();
      HttpRequest req = new HttpRequest();
      req.setHeader('Authorization', 'Bearer ' + sessionId);
      req.setHeader('Content-Type', 'application/json');
      EndpointServizi__c endpoint = EndpointServizi__c.getInstance('settings');
      req.setEndpoint(endpoint.UrlLogger__c + '/services/apexrest/log');
      req.setMethod('POST');
      req.setBody('{ "log" : ' + JSON.serialize(l) + '}');
      req.setTimeout(40000);

      Http h = new Http();
      HttpResponse res = h.send(req);

      return res.getBody() == '"true"';
    } else if(canFuture) {
      logAsync(JSON.serialize(l));
      return true;
    } else {
      return createLog(l);
    }
  }

  private static String getSessionId() {
    return (String) JSON.deserialize(Page.SessionId.getContent().toString(), String.class);
  }
}