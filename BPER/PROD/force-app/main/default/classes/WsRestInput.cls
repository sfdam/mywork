/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-06-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-29-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class WsRestInput {

    private final Static String ERROR_JSON = 'Unexpected character (\'<\' (code 60))';
    private final Static String ERROR_404 = 'HTTP Status 404';

    public Headers headers;
    public Object payload;
    
    public WsRestInput(User currentUser, Object p) {
        this.payload = p;
        this.headers = new Headers(currentUser);
    }

    public class Headers {
        public Testata testata;
        public Security security;
        public BindingInfo bindingInfo;
        public UserProfile userProfile;
        public ErrorHeader error_header;

        public Headers(User currentUser){

            this.testata = new Testata(currentUser);
            this.security = new Security(currentUser);
            this.bindingInfo = new BindingInfo(currentUser);
            this.userProfile = new UserProfile(currentUser);
        }
    }

    /* classes to manage scurity information */
    public class Security {
        public String banca;
        public String utente;
        public String terminale;
        public String applicazione;
        public String token;
        public String idced;
        public String ip;

        public Security() {
            
        }

        //DK nuovo costruttore
        public Security(User currentUser) {
            
            this.banca = currentUser.banca__c;
            this.utente = currentUser.FederationIdentifier;
            this.terminale = currentUser.terminale__c;
            this.applicazione = currentUser.applicazione__c;
            this.idced = currentUser.idced__c;
            this.ip = currentUser.ip__c;
        }
    }

    /* classes to manage testata information */
    public class Testata {
        public String sessionId;
        public String timestamp;
        public String lTimeout;
        public String abi;
        public String cab;
        public String branchCode;
        public String channel;
        public String correlationid;
        public String userId;
        //DK campo mancante
        public String terminale;
        public String operationId;
        public String sysCaller;
        public String fnCaller;
        public String reqType;
        public String serviceName;
        public String fnName;
        public String serviceVersion;
        public String customerId;
        public String agenzia;
        public String livello;

        public Testata() {
            this.timestamp = String.valueOf(DateTime.now().getTime());
            this.lTimeout = '120';
        }

        //DK nuovo costruttore
        public Testata(User currentUser) {
            
            this.abi = currentUser.abi__c;
            // MS 11-01-2024 sostituito il campo customerId__c con FederationIdentifier
            //this.customerId = !String.isBlank(currentUser.customerId__c) ? currentUser.customerId__c : '65043';
            this.customerId = currentUser.FederationIdentifier;
            this.cab = currentUser.cab__c;
            this.branchCode = currentUser.branchCode__c;
            this.userId = currentUser.userId__c;
            this.terminale = currentUser.terminale__c;
            this.serviceVersion = currentUser.ServiceVersion__c;
            this.operationId = currentUser.OperationId__c;
            this.sessionId = !String.isBlank(currentUser.sessionId__c) ? currentUser.sessionId__c : '21A9A8089C305319C679820D';
            this.timestamp = String.valueOf(DateTime.now().getTime());
            this.lTimeout = '120';
            this.channel = 'IBPR';
            this.correlationid = currentUser.Id;
            this.agenzia = currentUser.idced__c;
            this.livello = '05';
        }
    }

    /* classes to manage scurity information */
    public class BindingInfo {
        public String sessionId;
        public String operationId;
        public String sysCaller;
        public String fnCaller;
        public String serviceName;
        public String fnName;
        public String serviceImplClass;
        public String serviceClient;

        public BindingInfo(){}

        //DK nuovo costruttore
        public BindingInfo(User currentUser) {
            
            this.sessionId = !String.isBlank(currentUser.sessionId__c) ? currentUser.sessionId__c : '21A9A8089C305319C679820D';
            this.operationId = currentUser.operationId__c;
            this.sysCaller = currentUser.sysCaller__c;
            this.fnCaller = currentUser.fnCaller__c;
            this.serviceName = currentUser.serviceName__c;
            this.fnName = currentUser.fnName__c;
            this.serviceImplClass = currentUser.serviceImplClass__c;
            this.serviceClient = currentUser.serviceClient__c;
        }
    }

    /* classes to manage testata information */
    public class UserProfile {
        
        public String ABI;
        public String banca;
        public String filiale;
        public String termId;
        public String uid;
        public String token;
        public String username;
        public String applicationName;
        public String idApplicazione;
        public String esb_idCed;
        public String esb_operatore;
        public String esb_IP;

        public UserProfile(){}

        //DK nuovo costruttore
        public UserProfile(User currentUser) {
            
            this.ABI = currentUser.abi__c;
            this.banca = currentUser.banca__c;
            this.filiale = currentUser.branchCode__c;
            this.termId = currentUser.TermId__c;
            this.uid = currentUser.userId__c;
            this.token = currentUser.token__c;
            this.username = currentUser.userId__c;
            this.applicationName = currentUser.applicazione__c;
            this.idApplicazione = currentUser.idApplicazione__c;
            this.esb_idCed = currentUser.esb_idCed__c;
            this.esb_operatore = currentUser.esb_operatore__c;
            this.esb_IP = currentUser.esb_IP__c;
        }
    }

    /* classes to manage Error information */
    public class ErrorHeader {
        public List<Error> archErrorList;
    }

    public class Error {
        public String code;
        public String description;
    }

    //new Error Response structure
    public class ErrorResponse {
        public String codice;
        public String messaggio;
        public String instance;
    }

    //common response
    public virtual class CommonResponse {
        public WsRestInput.Headers headers;
        public String data;
        public String statusCode;
        public String exceptionError;

        public virtual Boolean isCorrect() {
            return false;
        }

        public virtual String getErrors() {
            List<String> errors = new List<String>();
            if (
                headers!=null &&
                headers.error_header!=null &&
                headers.error_header.archErrorList!=null
            ) {
                for (Error err : headers.error_header.archErrorList) {
                    String parsedError = parseError(err.description);
                    if (String.isNotBlank(parsedError)) {
                        errors.add(parsedError);
                    } else {
                        errors.add('Codice errore: ' + err.code);
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
            List<String> tmp = new List<String>();
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

            return (!tmp.isEmpty() ? String.join(tmp,'. ') : null);
          }
    }

    // manage JSON

    public static String toJSONString(Object obj) {
        String tmp = JSON.serialize(obj);
        tmp = tmp.replaceAll('\"[^\"]*\":null(,)*', ''); //remove null values
        tmp = tmp.replaceAll('\"[^\"]*\":\\{\\}(,)*', ''); //remove empty objects
        tmp = tmp.replaceAll(',}', '}');
        tmp = tmp.replaceAll('\'\\$\\{NULL\\}\'', 'null');
        return tmp;
      }
    
}