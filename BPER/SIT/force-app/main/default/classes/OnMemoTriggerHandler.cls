public class OnMemoTriggerHandler {
	
	public static String userId{get;set;}
	public static Boolean skipTrigger = false;

	public static User currentUser {
		get{

			if(currentUser != null){
				return currentUser;
			}

			currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c,applicazione__c, ndgsettoriale__c,
				banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
				sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
				Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
				serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c
				FROM User WHERE id =: userId];
			return currentUser;
		}set;
	}

	public static void handleAfterInsert(List<CRM_Memo__c> newList, Map<Id, CRM_Memo__c> newMap){
		if(!skipTrigger){
			List<CRM_Memo__c> memoList = [SELECT Id, CRM_IdMemoGalileo__c, Name, Cliente__c, Cliente__r.FinServ__BankNumber__c, Cliente__r.CRM_NDG__c, CRM_FineValidita__c, CRM_Titolo__c,
							CRM_PopupCassa__c, Da__c, A__c, CRM_Note__c, CreatedBy.FederationIdentifier, Autore__c, CRM_Tipologia_Memo__c
							FROM CRM_Memo__c
							WHERE Id IN: newMap.keySet()];
			for(CRM_Memo__c memo : memoList){
				chiamataGalileo(JSON.serialize(memo), null, 'afterInsert');
			}
		}
	}

	public static void handleAfterUpdate(List<CRM_Memo__c> newList, Map<Id, CRM_Memo__c> oldMap){
		if(!skipTrigger){
			List<CRM_Memo__c> memoList = [SELECT Id, CRM_IdMemoGalileo__c, Name, Cliente__c, Cliente__r.FinServ__BankNumber__c, Cliente__r.CRM_NDG__c, CRM_FineValidita__c, CRM_Titolo__c,
							CRM_PopupCassa__c, Da__c, A__c, CRM_Note__c, CreatedBy.FederationIdentifier, Autore__c, CRM_Tipologia_Memo__c
							FROM CRM_Memo__c
							WHERE Id IN: oldMap.keySet()];
			for(CRM_Memo__c memo : memoList){
				chiamataGalileo(JSON.serialize(memo), null, 'afterUpdate');
			}
		}
	}

	public static void handleAfterDelete(Map<Id, CRM_Memo__c> oldMap){
		System.debug('DK oldMap: ' + JSON.serialize(oldMap));
		if(!skipTrigger){
			Set<String> clienteSet = SV_Utilities.keyBy(oldMap.values(), 'Cliente__c').keySet();
			Set<String> autoreSet = SV_Utilities.keyBy(oldMap.values(), 'CreatedById').keySet();
			Map<String, SObject> clienteMap = SV_Utilities.keyBy([SELECT Id, FinServ__BankNumber__c, CRM_NDG__c FROM Account WHERE ID IN: clienteSet], 'Id');
			Map<String, SObject> autoreMap = SV_Utilities.keyBy([SELECT Id, FederationIdentifier FROM User WHERE ID IN: autoreSet], 'Id');
			for(CRM_Memo__c memo : oldMap.values()){
				Map<String, String> paramsMap = new Map<String, String>{
					'abi' => (String)clienteMap.get(memo.Cliente__c).get('FinServ__BankNumber__c'),
					'ndg' => (String)clienteMap.get(memo.Cliente__c).get('CRM_NDG__c'),
					'matricolaAutore' => (String)autoreMap.get(memo.CreatedById).get('FederationIdentifier')
				};
				chiamataGalileo(JSON.serialize(memo), paramsMap, 'afterDelete');
			}
		}
	}

	@future(callout=true)
	public static void chiamataGalileo (String memoJSON, Map<String, String> paramsMap, String tipoTrigger){
		
		try {
							
			userId = UserInfo.getUserId();
			CRM_Memo__c memo = (CRM_Memo__c)JSON.deserialize(memoJSON, CRM_Memo__c.class);
			WsRestInput restInput = new WsRestInput(currentUser, null);
			Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
			testataMap.put('channel', 'IBPR');
			testataMap.put('cab', '12905');
			testataMap.put('correlationid', '5ef755b5-fc9e-467a-9022-23b9e2f9616');
			testataMap.put('applicazione', 'NPV');
			Map<String,String> headersReq= new Map<String,String>();
			HttpRequest request = new HttpRequest();
			String endpoint;
			String method;
			Endpoint__c apiRequest = new Endpoint__c();
			String body;
			if(tipoTrigger == 'afterInsert'){
				apiRequest = Endpoint__c.getInstance('memoInsert');
				endpoint = apiRequest.Endpoint__c;
				method = apiRequest.Method__c;
				body = memoRequestBodyInsert(memo);
				system.debug('il body della chiamate è' + memo);

			}else if(tipoTrigger == 'afterUpdate'){
				apiRequest = Endpoint__c.getInstance('memoUpdate');
				body = memoRequestBodyUpdate(memo);
				endpoint = apiRequest.Endpoint__c.replace('{idMemo}', memo.CRM_IdMemoGalileo__c);
				system.debug('endpoint memoUpdate' + endpoint);
				method = apiRequest.Method__c;
			}else if(tipoTrigger == 'afterDelete'){
				apiRequest = Endpoint__c.getInstance('memoDelete');
				endpoint = apiRequest.Endpoint__c.replace('{idMemo}', memo.CRM_IdMemoGalileo__c) + '?';
				Map<String, String> queryParamsMap = memoQueryParams(memo, paramsMap);
				for(String key : queryParamsMap.keySet()){
				endpoint += key + '=' + queryParamsMap.get(key) + '&';
				}
				endpoint = endpoint.removeEnd('&');
				system.debug('endpoint memoDelete' + endpoint);
				method = apiRequest.Method__c;
			}

			for(String key: testataMap.keySet()){
				if(testataMap.get(key) != null){
					request.setHeader(key, testataMap.get(key));
					headersReq.put(key, testataMap.get(key));
				}
			}
				
			request.setHeader('Content-Type', 'application/json');
			headersReq.put('Content-Type', 'application/json');
			request.setEndpoint(endpoint);
			request.setMethod(method);
			request.setClientCertificateName('salesforcetestclient2024');
			
			if(body != null){

				request.setBody(body);
			}
			Http http = new Http();
			HttpResponse response = http.send(request);
			Map<string, string> headersRes = new map<string, string>();

			if (!String.valueOf(response.getStatusCode()).startsWithIgnoreCase('2')) {
				system.debug('errore nella chiamata al webservice REST');
			}
			else {
				if(tipoTrigger == 'afterInsert'){

					system.debug('After Insert eseguito con successo');
					Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
					memo.CRM_IdMemoGalileo__c = (String)responseBody.get('idMemo');
					skipTrigger = true;
					update memo;
				}

				string[] headerkeysRes = response.getHeaderKeys();

				for(string s : headerkeysRes){
					headersRes.put(s,response.getHeader(s));
				}
			}

			WsRestUtils.writeLog(
				tipoTrigger == 'afterDelete' ? 'memoDelete' : apiRequest.Name,
				method,
				body,
				response.getStatusCode(),
				response.getStatus(),
				response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
				headersReq,
				headersRes,
				endpoint,
				''
				// responseObj.isCorrect() ? null : responseObj.getErrors()
			);
		} catch (Exception ex) {
			System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
		}
	}

	public static String memoRequestBodyInsert(CRM_Memo__c memo) {
		Map<String, String> requestBodyMap = new Map<String, String>();
		requestBodyMap.put('idEntita', memo.Id);
		requestBodyMap.put('codiceEntita',String.valueof('MEMO'));
		requestBodyMap.put('entita', 'Memo');
		requestBodyMap.put('operationType', 'C');
		requestBodyMap.put('abi', memo.Cliente__r.FinServ__BankNumber__c);
		requestBodyMap.put('ndg', memo.Cliente__r.CRM_NDG__c);
		requestBodyMap.put('fineValidita', String.valueof(Memo.CRM_FineValidita__c));
		requestBodyMap.put('motivo', 'Memo');
		requestBodyMap.put('descrizione', memo.Name);
		requestBodyMap.put('flagPopUp', memo.CRM_PopupCassa__c ? 'S' : 'N');
		if(memo.CRM_PopupCassa__c){

		requestBodyMap.put('dataInizioPopUp', memo.Da__c != null ? memo.Da__c.format() : '');
		requestBodyMap.put('dataFinePopUp', memo.A__c != null ? memo.A__c.format() : '');
		}
		requestBodyMap.put('nota', memo.CRM_Note__c);
		requestBodyMap.put('matricolaAutore', 'U' + memo.CreatedBy.FederationIdentifier);
		requestBodyMap.put('autore', memo.Autore__c);
		requestBodyMap.put('tipologia', memo.CRM_Tipologia_Memo__c.toUpperCase());

		return JSON.serialize(requestBodyMap, true);
	}

	public static String memoRequestBodyUpdate(CRM_Memo__c memo) {
		Map<String, String> requestBodyMap = new Map<String, String>();
		requestBodyMap.put('idEntita', memo.Id);
		requestBodyMap.put('codiceEntita', 'MEMO');
		requestBodyMap.put('entita', 'Memo');
		requestBodyMap.put('operationType', 'U');
		requestBodyMap.put('abi', memo.Cliente__r.FinServ__BankNumber__c);
		requestBodyMap.put('ndg', memo.Cliente__r.CRM_NDG__c);
		requestBodyMap.put('fineValidita', String.valueof(Memo.CRM_FineValidita__c));
		requestBodyMap.put('motivo', 'Memo');
		requestBodyMap.put('descrizione', memo.Name);
		requestBodyMap.put('flagPopUp', memo.CRM_PopupCassa__c ? 'S' : 'N');
		if(memo.CRM_PopupCassa__c){

		requestBodyMap.put('dataInizioPopUp', memo.Da__c != null ? memo.Da__c.format() : '');
		requestBodyMap.put('dataFinePopUp', memo.A__c != null ? memo.A__c.format() : '');
		}
		requestBodyMap.put('nota', memo.CRM_Note__c);
		requestBodyMap.put('matricolaAutore', 'U' + memo.CreatedBy.FederationIdentifier);
		requestBodyMap.put('autore', memo.Autore__c);
		requestBodyMap.put('tipologia', memo.CRM_Tipologia_Memo__c.toUpperCase());

		return JSON.serialize(requestBodyMap, true);
	}

	public static Map<String, String> memoQueryParams(CRM_Memo__c memo, Map<String, String> paramsMap) {
		Map<String, String> requestBodyMap = new Map<String, String>();
		requestBodyMap.put('idEntita', memo.Id);
		requestBodyMap.put('codiceEntita', 'MEMO');
		requestBodyMap.put('entita', 'Memo');
		requestBodyMap.put('operationType', 'D');
		requestBodyMap.put('abi', paramsMap.get('abi'));
		requestBodyMap.put('ndg', paramsMap.get('ndg'));
		requestBodyMap.put('motivo', 'Memo');
		requestBodyMap.put('matricolaAutore', 'U' + paramsMap.get('matricolaAutore'));
		requestBodyMap.put('autore', memo.Autore__c);
		requestBodyMap.put('tipologia', memo.CRM_Tipologia_Memo__c.toUpperCase());

		return requestBodyMap;
	}
}