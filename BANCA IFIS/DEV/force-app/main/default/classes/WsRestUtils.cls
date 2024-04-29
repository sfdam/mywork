public without sharing class WsRestUtils {
  private WsRestUtils() {}

  public static final Decimal DEFAULT_TIMEOUT = 60000;

  public static WsRestInput.CommonResponse callService(String urlField, WsAnagraficaBean input, String template, Type t) {
    System.debug('SV callService: ' + urlField + ' --- ' + input);
    WsRestInput tmp = new WsRestInput(JSON.deserializeUntyped(input.toJSON(template)));
    System.debug('SV callService: ' + urlField + ' --- ' + tmp);
    return getResponseObject(urlField, tmp, t, DEFAULT_TIMEOUT);
  }

  public static WsRestInput.CommonResponse callService(String urlField, Object input, Type t, Decimal timeout) {
    System.debug('SV callService: ' + urlField + ' --- ' + input);
    return getResponseObject(urlField, new WsRestInput(input), t, timeout);
  }

  /* SM - 22/03/2019 - Aggiunto metodo per gestire la chiamata multipart per upload documenti */
  public static WsRestInput.CommonResponse callService(String urlField, Blob input, Type t, Decimal timeout, String boundary) {
    System.debug('SV callService: ' + urlField + ' --- ' + input);
    return getResponseObject(urlField, input, t, timeout, boundary);
  }

  public static WsRestInput.CommonResponse callService(String urlField, Object input, Type t) {
    System.debug('SV callService: ' + urlField);
    System.debug('SV callService: ' + input);
    return getResponseObject(urlField, new WsRestInput(input), t, DEFAULT_TIMEOUT);
  }

  public static WsRestInput.CommonResponse callServiceWithouthCatch(String urlField, Object input, Type t) {
    System.debug('SV callService: ' + urlField);
    System.debug('SV callService: ' + input);
    return getResponseObjectWithouthCatch(urlField, new WsRestInput(input), t, DEFAULT_TIMEOUT);
  }

  public static WsRestInput.CommonResponse callServiceSpecialRibes(String urlField, Object input, Type t) {
    System.debug('SV callServiceSpecialRibes');
    WsRestInput.CommonResponse responseObj = (WsRestInput.CommonResponse) t.newInstance();
    WsRestInput tmp = new WsRestInput(input);
    String body;
    String responseString;
    try {
      body = tmp.toJSONString();
      responseString = WsRestUtils.makeRequest(urlField, body, DEFAULT_TIMEOUT);
      System.debug('SV responseString: ' + responseString);
      Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseString);
      responseObj = WsRestRibes.parseInformazioniPG(responseMap);
    } catch (Exception e) {
      responseObj.exceptionError = e.getMessage();
    }

    writeLog(
      urlField,
      body,
      responseString,
      responseObj.isCorrect() ? null : responseObj.getErrors()
    );

    if (!responseObj.isCorrect()) {
      throw new Ex.WsCalloutException(responseObj.getErrors());
    }

    return responseObj;
  }

  // Come callService, ma elimina il campo "risposta" dal payload di output
  public static WsRestInput.CommonResponse callServiceSpecialEventiNegativi(String urlField, Object input, Type t) {
    WsRestInput.CommonResponse responseObj = (WsRestInput.CommonResponse) t.newInstance();
    WsRestInput tmp = new WsRestInput(input);
    String body;
    String responseString;
    try {
      body = tmp.toJSONString();
      responseString = WsRestUtils.makeRequest(urlField, body, DEFAULT_TIMEOUT);
      System.debug('SV responseString: ' + responseString);
      responseObj = (WsRestInput.CommonResponse)JSON.deserialize(responseString, t);
    } catch (Exception e) {
      responseObj.exceptionError = e.getMessage();
    }
    String regExp = '(?<="risposta":\\{"prodotto":\\{"reportPDF":\\{"fileBase64":")(.*)(?="\\}\\}\\})';
    if (responseString != null) responseString = responseString.replaceAll(regExp, 'PDF non loggato');

    writeLog(
      urlField,
      body,
      responseString,
      responseObj.isCorrect() ? null : responseObj.getErrors()
    );

    System.debug(urlField + ': ' + responseObj);

    if (!responseObj.isCorrect()) throw new Ex.WsCalloutException(responseObj.getErrors());

    System.debug(urlField + ': ' + responseObj);
    return responseObj;
  }

  private static WsRestInput.CommonResponse getResponseObject(String urlField, WsRestInput input, Type t, Decimal timeout) {
    WsRestInput.CommonResponse responseObj = (WsRestInput.CommonResponse) t.newInstance();
    String body;
    String responseString;
    try {
      body = input.toJSONString();
      responseString = WsRestUtils.makeRequest(urlField, body, timeout);
      System.debug('SV responseString: ' + responseString);
      responseObj = (WsRestInput.CommonResponse)JSON.deserialize(responseString, t);
      System.debug('SV responseObj: ' + responseObj);
    } catch (Exception e) {
      responseObj.exceptionError = e.getMessage() + ' - ' + e.getStackTraceString();
    }

    // SV ERRORE SESSION ID
    writeLog(
      urlField,
      body,
      responseString,
      responseObj.isCorrect() ? null : responseObj.getErrors()
    );

    System.debug('SV responseObj.getErrors(): ' + responseObj.getErrors());
    System.debug('SV responseObj isCorrect: ' + responseObj.isCorrect());
    List<String> resultErrorList = new List<String>();
    if(responseObj.getErrors() != null) resultErrorList = responseObj.getErrors().split(';');

    System.debug('SV resultErrorList: ' + resultErrorList);
    String error = '';
    for(String e : resultErrorList){
      System.debug('SV error: ' + e);
      if(e.contains('Descrizione') && !error.contains(e.split(' = ')[1])){
        error = error + e.split(' = ')[1] + ' ';
      }
    }

    System.debug('SV error2: ' + error);
    System.debug('SV responseObj.isCorrect(): ' + responseObj.isCorrect());
    
    if (!responseObj.isCorrect()) throw new Ex.WsCalloutException((error != '') ? error : responseObj.getErrors());

    
    System.debug(urlField + ': ' + responseObj);
    return responseObj;
  }

  private static WsRestInput.CommonResponse getResponseObjectWithouthCatch(String urlField, WsRestInput input, Type t, Decimal timeout) {
    System.debug('SV getResponseObjectWithouthCatch');
    WsRestInput.CommonResponse responseObj = (WsRestInput.CommonResponse) t.newInstance();
    String body;
    String responseString;
    try {
      body = input.toJSONString();
      responseString = WsRestUtils.makeRequest(urlField, body, timeout);
      System.debug('SV responseString: ' + responseString);
      responseObj = (WsRestInput.CommonResponse)JSON.deserialize(responseString, t);
      System.debug('SV responseObj: ' + responseObj);
    } catch (Exception e) {
      responseObj.exceptionError = e.getMessage() + ' - ' + e.getStackTraceString();
    }

    // SV ERRORE SESSION ID
    writeLog(
      urlField,
      body,
      responseString,
      responseObj.isCorrect() ? null : responseObj.getErrors()
    );

    System.debug('SV responseObj.getErrors(): ' + responseObj.getErrors());
    System.debug('SV responseObj isCorrect: ' + responseObj.isCorrect());
    List<String> resultErrorList = new List<String>();
    if(responseObj.getErrors() != null) resultErrorList = responseObj.getErrors().split(';');

    System.debug('SV resultErrorList: ' + resultErrorList);
    String error = '';
    for(String e : resultErrorList){
      System.debug('SV error: ' + e);
      if(e.contains('Descrizione') && !error.contains(e.split(' = ')[1])){
        error = error + e.split(' = ')[1] + ' ';
      }
    }

    System.debug('SV error2: ' + error);
    System.debug('SV responseObj.isCorrect(): ' + responseObj.isCorrect());
    
    System.debug(urlField + ': ' + responseObj);
    return responseObj;
  }


  /* SM - 22/03/2019 - Aggiunto metodo per gestire multipart per upload documenti */
  //Passo il body della request già popolato e formattato a string
  private static WsRestInput.CommonResponse getResponseObject(String urlField, Blob input, Type t, Decimal timeout, String boundary) {
    WsRestInput.CommonResponse responseObj = (WsRestInput.CommonResponse) t.newInstance();
    String responseString;
    try {
      responseString = WsRestUtils.makeRequest(urlField, input, timeout, boundary);
      System.debug('SV responseString: ' + responseString);
      responseObj = (WsRestInput.CommonResponse)JSON.deserialize(responseString, t);
      System.debug('SV responseObj: ' + responseObj);
    } catch (Exception e) {
      responseObj.exceptionError = e.getMessage() + ' - ' + e.getStackTraceString();
    }

    // SV ERRORE SESSION ID
    writeLog(
      urlField,
      EncodingUtil.base64Encode(input).abbreviate(131072),
      responseString,
      responseObj.isCorrect() ? null : responseObj.getErrors()
    );

    System.debug('SV responseObj isCorrect: ' + responseObj.isCorrect());

    List<String> resultErrorList = responseObj.getErrors().split(';');

    System.debug('SV resultErrorList: ' + resultErrorList);
    String error = '';
    for(String e : resultErrorList){
      System.debug('SV error: ' + e);
      if(e.contains('Descrizione') && !error.contains(e.split(' = ')[1])){
        error = error + e.split(' = ')[1] + ' ';
      }
    }

    System.debug('SV error2: ' + error);
    System.debug('SV responseObj.isCorrect(): ' + responseObj.isCorrect());
    
    if (!responseObj.isCorrect()) throw new Ex.WsCalloutException((error != '') ? error : responseObj.getErrors());

    
    System.debug(urlField + ': ' + responseObj);
    return responseObj;
  }

  private static void writeLog(String urlField, String input, String output, String errorMessage) {
    GestioneLog__c gLog = GestioneLog__c.getInstance('default');
    if (gLog != null && gLog.get(urlField) != null && (Boolean) gLog.get(urlField)) {
      Map<String, Schema.SObjectField> fieldMap = gLog.getSObjectType().getDescribe().fields.getMap();
      //String inputPretty = input;
      //String outputPretty = output;

      String inputPretty;
      String outputPretty;

      try {
        inputPretty = JSON.serializePretty(JSON.deserializeUntyped(input));
      } catch (Exception e) {
          inputPretty = input;
      }

      try {
        outputPretty = JSON.serializePretty(JSON.deserializeUntyped(output));
      } catch (Exception e) {}

      Logger.log(new Log__c(
                   Source__c = fieldMap.get(urlField).getDescribe().getLabel(),
                   ErorrMessage__c = errorMessage,
                   InputPayload__c = inputPretty,
                   OutputPayload__c = outputPretty
                 ));
    }
  }

  public static String callSimpleService(String urlField, Object input) {
    String body = JSON.serialize(input);
    String responseString = WsRestUtils.makeRequest(urlField, body, DEFAULT_TIMEOUT);
    writeLog(
      urlField,
      body,
      responseString,
      null
    );
    return responseString;
  }

  private static String makeRequest(String urlField, String body, Decimal timeout) {
    HttpRequest req = new HttpRequest();
    req.setHeader('X-LAGKey', getLagKey(urlField));
    req.setHeader('Content-Type', 'application/json');
    req.setEndpoint(getEndpoint(urlField));
    req.setMethod('POST');
    req.setBody(body);
    req.setTimeout(timeout.intValue());

    System.debug(urlField + ' - body: ' + body);

    return (new Http()).send(req).getBody();
  }

  /* SM - 22/03/2019 - Aggiunto metodo per gestire la request multipart per l'upload dei documenti */
  private static String makeRequest(String urlField, Blob bodyBlob, Decimal timeout, String boundary) {
      // EndpointServizi__c endpoint = EndpointServizi__c.getInstance('settings');
      // String url = (String) endpoint.get('WGC_Url_Doc01__c');
      HttpRequest reqMP = new HttpRequest();
      reqMP.setHeader('X-LAGKey', getLagKey(urlField));
      reqMP.setHeader('Content-Type', 'multipart/form-data; boundary='+boundary); 
      reqMP.setEndpoint(getEndpoint(urlField));
      reqMP.setMethod('POST');
      reqMP.setBodyAsBlob(bodyBlob);
      reqMP.setTimeout(120000);

      return (new Http()).send(reqMP).getBody();
    // HttpRequest req = new HttpRequest();
    // req.setHeader('X-LAGKey', getLagKey(urlField));
    // req.setHeader('Content-Type' , 'multipart/form-data');
    // req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
    // req.setHeader('Content-Length', String.valueOf(body.length()));
    // req.setEndpoint(getEndpoint(urlField));

    // req.setMethod('POST');
    // req.setBody(body);
    // req.setTimeout(timeout.intValue());

    // System.debug(urlField + ' - body: ' + body);

    // return (new Http()).send(req).getBody();
  }

  /*
  * SM - 26/02/2019 metodo aggiunto per richiamare il servizio DOC08
  *
  */
  public static Blob WGC_makeRequest_blob(String urlField, String body, Decimal timeout) {
    HttpRequest req = new HttpRequest();
    req.setHeader('X-LAGKey', getLagKey(urlField));
    req.setHeader('Content-Type', 'application/json');
    req.setEndpoint(getEndpoint(urlField));
    req.setMethod('POST');
    req.setBody(body);
    req.setTimeout(timeout.intValue());

    System.debug(urlField + ' - body: ' + body);

    Http h = new Http();
    HttpResponse response = new HttpResponse();
    Blob fileResponse;
    try{
      response = h.send(req);
      
      req = null;
      System.debug('@@@ ResponseString ' + response.getBody().substring(0,500));
      System.debug('@@@ limite heap ' + Limits.getHeapSize());
      if(response.getStatusCode() != 200){
        fileresponse = Blob.valueOf('');
      }
      else{
        fileResponse = response.getBodyAsBlob();
      }

      System.debug('@@@ limite heap before write ' + Limits.getHeapSize());

      writeLog(
        urlField,
        body,
        response.getBody(),
        null
      );

    }
    catch(Exception e){
      writeLog(
        urlField,
        body,
        response.getBody(),
        e.getMessage()
      );

      fileResponse = Blob.valueOf('');
    }

    return fileResponse;
  }

  private static String getLagKey(String urlField) {
    System.debug('SV urlField ' + urlField);
    //return urlField == 'UrlCertificazioneParser__c' ? EndpointServizi__c.getInstance('settings').LAGKeyHeroku__c : urlField == 'WGC_Url_Doc01__c' ? EndpointServizi__c.getInstance('settings').LAGKeyHeroku__c : EndpointServizi__c.getInstance('settings').LAGKey__c;
    return urlField == 'UrlCertificazioneParser__c' ? EndpointServizi__c.getInstance('settings').LAGKeyHeroku__c :  EndpointServizi__c.getInstance('settings').LAGKey__c;
  }

  private static String getEndpoint(String urlField) {
    EndpointServizi__c endpoint = EndpointServizi__c.getInstance('settings');
    String url = (String) endpoint.get(urlField);
    if (url == null) throw new Ex.WsException('custom settings non impostato per l\'URL :' + urlField);
    return url;
  }
}