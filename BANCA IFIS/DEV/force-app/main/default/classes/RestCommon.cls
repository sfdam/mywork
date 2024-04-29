global class RestCommon {
  private RestCommon() {}

  //codici di ritono generici
  public static final String NESSUN_ERRORE = '0'; //Nessun errore
  public static final String ERRORE_GENERICO = '99'; //Errore generico

  //codici di ritono StatoOpportunita
  public static final String CODICE_ISTITUTO_ASSENTE = '10'; //Codice istituto assente
  public static final String ID_APPLICAZIONE_ASSENTE = '20'; //Id applicazione assente
  public static final String ID_CARTELLA_ASSENTE = '30'; //Id cartella assente
  public static final String STATO_CARTELLA_ASSENTE = '31'; //Stato cartella assente
  public static final String ID_LINEA_ASSENTE = '40'; //Id linea assente
  public static final String STATO_LINEA_ASSENTE = '41'; //Stato linea assente
  public static final String ID_ISTRUTTORIA_ASSENTE = '42'; //Id Istruttoria assente
  public static final String DATA_ISTRUTTORIA_ASSENTE = '43'; //Data Istruttoria assente
  public static final String ID_ISTRUTTORIA_FIGLIO_ASSENTE = '44'; //Id Istruttoria figlio assente
  public static final String DATA_ISTRUTTORIA_FIGLIO_ASSENTE = '45'; //Data Istruttoria figlio assente

  global class ResponseObject {
    @testVisible String returnCode;
    @testVisible String message;

    public ResponseObject(String returnCode, String message) {
      this.returnCode = returnCode;
      this.message = message;
    }
  }

  global class TechInfo {
    String applicationCode;
    String correlationId;
    String channel;
    String timeStamp;
    String clientIpAddress;
    String userId;
    String username;
    String usersurname;
    String emailAddress;
  }

  public static void logInboundMessage(String serviceName, Object[] inputArray, Object output) {
    try {
      String jsonInput = '';
      for (Object input : inputArray) {
        jsonInput += JSON.serialize(input) + '\n';
      }

      insert new Log__c(
        Source__c = serviceName,
        InputPayload__c = jsonInput,
        OutputPayload__c = JSON.serialize(output)
      );
    } catch (Exception e) {}
  }
}