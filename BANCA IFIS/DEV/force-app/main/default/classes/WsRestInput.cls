public without sharing class WsRestInput {

  private final Static String ERROR_JSON = 'Unexpected character (\'<\' (code 60))';
  private final Static String ERROR_404 = 'HTTP Status 404';

  public Object payload;
  public HeaderWrapper headers;

  public WsRestInput(Object p) {
    this.payload = p;
    this.headers = new HeaderWrapper();
  }

  public String toJSONString() {
    String tmp = JSON.serialize(this);
    tmp = tmp.replaceAll('\"[^\"]*\":null(,)*', ''); //remove null values
    tmp = tmp.replaceAll('\"[^\"]*\":\\{\\}(,)*', ''); //remove empty objects
    tmp = tmp.replaceAll(',}', '}');
    tmp = tmp.replaceAll('\"\\$\\{NULL\\}\"', 'null');
    tmp = tmp.replaceAll('-999999', 'null');
    return tmp;
  }

  /**
   * Serializes an object removing null values
   * @param  obj object (used as input to a service) to be serialized
   * @return     return object serialized w/o null fields
   */
  public static String toJSONString(Object obj) {
    String tmp = JSON.serialize(obj);
    tmp = tmp.replaceAll('\"[^\"]*\":null(,)*', ''); //remove null values
    tmp = tmp.replaceAll('\"[^\"]*\":\\{\\}(,)*', ''); //remove empty objects
    tmp = tmp.replaceAll(',}', '}');
    tmp = tmp.replaceAll('\'\\$\\{NULL\\}\'', 'null');
    tmp = tmp.replaceAll('-999999', 'null');
    return tmp;
  }

  //common input
  public virtual class CommonInput {
    public Decimal codiceIstituto3N = Decimal.valueOf(ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c);
    public String idApplicazioneChiamante = 'CRM'; //le transcodifiche giuste sembrano essere quelle di KNT, non quelle di CRM
    public String idSessioneChiamante = 'CRM';  //arbitrario, per identificare il chiamante
    public String lingua = 'it';
    public String idOperazione;
    public String utenzaCanale;
  }

  //common response
  public virtual class CommonResponse {
    public WsRestInput.HeaderWrapper headers;
    public String exceptionError;

    public virtual Boolean isCorrect() {
      return false;
    }

    public virtual String getErrors() {
      String[] errors = new String[] {};
      if (
        headers != null &&
        headers.headers != null &&
        headers.headers.error_header != null &&
        headers.headers.error_header.archErrorList != null
      ) {
        for (Error e : headers.headers.error_header.archErrorList) {
          String parsedError = parseError(e.description);
          if (String.isNotBlank(parsedError)) {
            errors.add(parsedError);
          } else {
            errors.add('Codice errore: ' + e.code);
          }
        }
      }

      if (String.isNotBlank(exceptionError)) {
        if (exceptionError.contains(ERROR_404)) {
          exceptionError = 'il servizio ha risposto con status 404';
        } else if (exceptionError.contains(ERROR_JSON)) {
          exceptionError = 'il servizio non ha resituito un json valido.';
        }
        errors.add(exceptionError);
      }

      return String.join(errors, ', ');
    }

    public String parseError(String error) {
      String[] tmp = new String[] {};
      Pattern p = Pattern.compile('Descrizione = ([^;]+)');
      Matcher pm = p.matcher(error);
      if (pm.find()) {
        tmp.add(pm.group(1));
        while (pm.find()) {
          tmp.add(pm.group(1));
        }
      } else {
        tmp.add(error);
      }
      if (!tmp.isEmpty()) {
        return String.join(tmp, '. ');
      }
      return null;
    }
  }

  //header: teoricamente fisso per tutte le chiamate, per cui si può valorizzare automaticamente
  public class HeaderWrapper {
    public Headers headers = new Headers();
  }

  public class Headers {
    public TechHeader tech_header = new TechHeader();
    public UserHeader user_header = new UserHeader();
    public ErrorHeader error_header; //output
  }

  public class TechHeader {
    public String id = 'tech_header';
    public String applicationCode = 'CRM'; //le transcodifiche giuste sembrano essere quelle di KNT, non quelle di CRM
    public String correlationId; //RANDOM UUID. NPL passa una sequence, noi possiamo usare il timestamp corrente
    public String channel = 'B2B'; //NPL passa lo usa per differenziare desktop/mobile
    public Long timeStamp;  //NPL non lo passa
    public String workstationId;
    public String clientIpAddress;
    public String clientHostname;


    public TechHeader() {
      this.timeStamp = DateTime.now().getTime();

      // MB - TEN: Inserimento di correlationId formattato come da standard UUID
      // Blob b = Crypto.GenerateAESKey(128);
      // String h = EncodingUtil.ConvertTohex(b);
      // String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
      // // this.correlationId = 'abcd-' + this.timeStamp + '-efgh';
      // this.correlationId = guid;

      // VS - TEN: Utilizzata classe d'appoggio per la generazione del codice UUID
      WGC_UUID uuid = new WGC_UUID();
      this.correlationId = uuid.getValue();
    }
  }

  public class UserHeader {
    public String id = 'user_header';
    public ArchUser archUser = new ArchUser();
  }

  public class ErrorHeader {
    public Error[] archErrorList;
  }

  public class Error {
    public String code;
    public String description;
  }

  public class ArchUser {
    public String name;
    public String surname;
    public String emailAddress;
    public String phoneNumber;
    public String userId;
    public String actualUserId;
    public String institute;
    public UserGroup[] userGroups = new UserGroup[]{};
    public UserGroup[] userRoles = new UserGroup[]{};

    public ArchUser() {
      User u = [SELECT
        Id,
        FirstName,
        LastName,
        Alias,
        LoginSiebel__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];

      EndpointServizi__c e = EndpointServizi__c.getInstance('settings');

      this.userId = e != null && String.isNotBlank(e.UserIdOverride__c) ? e.UserIdOverride__c : u.LoginSiebel__c;
      this.actualUserId = userId;
      this.name = u.FirstName;
      this.surname = u.LastName;
    }
  }

  public class UserGroup {
    public String name;
    public String description;
  }
}