public class BI_CRM_DigiBox_CODE {

	public static final String DIGIBOX = 'DIGIBOX';

	/**
	 * Carica tramite DigiBox i documenti designati su FileNet
	 * I documenti sono:
	 * - Modulo di adeguata verifica della clientela
	 * - Tecniche di comunicazione a distanza
	 * - RSF (Richiesta Servizi Finanziari)
	 * - Informativa Privacy Persona Giuridica
	 * - Informativa Privacy Persona Fisica
	 * @param ContentVersion cv il file da caricare in DigiBox
	 **/
	public static WGC_FileUploaderController.WrapperResponse createAutomatic(String docId, String recordId, List<Object> listaIndici, String fileName, Blob fileData) {

		WGC_FileUploaderController.WrapperResponse wrap = new WGC_FileUploaderController.WrapperResponse();
		Account cedente;
		WsRestInput payload;
		ResponseUpload om;
		try {
			String usrId = UserInfo.getUserId();
			User u = [SELECT Id, FederationIdentifier FROM User WHERE Id = :usrId LIMIT 1]; 

			Id objectId = (Id) recordId;
			String objectName = objectId.getSObjectType().getDescribe().getName();
			if (objectName == 'Account') {
				cedente = [SELECT Id, NDGGruppo__c, Filiale__c FROM Account WHERE Id =:recordId LIMIT 1];
			} else {
				Contact esecutore = [SELECT Id, NDGGruppo__c, AccountId FROM Contact WHERE Id =:recordId LIMIT 1];
				cedente = [SELECT Id, NDGGruppo__c, Filiale__c FROM Account WHERE Id =:esecutore.AccountId LIMIT 1];
			}

			//Input Wrapper
			InputMultipart input = new InputMultipart();
            //standard UO di IBAF: S + codice filiale con zero padding a 4 cifre, p.e. Padova 017 => S0017 
			input.data.filiale = String.isNotBlank(cedente.Filiale__c) ? 'S0'+cedente.Filiale__c : 'S0001';
			input.data.ndg = cedente.NDGGruppo__c;
			input.data.useridInserimento = u.FederationIdentifier;

			DboxMetadatoDocumento d;
			List<DboxMetadatoDocumento> metadati = new List<DboxMetadatoDocumento>();
			for (Object i : listaIndici) {
				d = new DboxMetadatoDocumento();
                //i doc che passano per DigiBox son destinati a FileNet => i metadati hanno tipo IndiceInput
				d.chiave = ((WGC_FileUploaderController.IndiceInput)i).nome;
				d.valore = ((WGC_FileUploaderController.IndiceInput)i).valore;
				metadati.add(d);
			}
			input.data.metadati = metadati;
			System.debug('-----> BI_CRM_DigiBox_CODE.createAutomatic input serialized: '+ JSON.serialize(input) );
			payload = new WsRestInput(input);


			//form multipart preparation
			String boundary = '------WebKitFormBoundaryqBrgE8Q9dPLWtV4J';
			String footer = '--' + boundary + '--';

			String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(boundary));

			String archMsgPart = '--' + boundary + '\r\nContent-Disposition: form-data; name="archMessage"; filename="archMessage.json"\r\nContent-Type: application/json';
			String archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart + '\r\n\r\n'));
			while (archMsgPartEncoded.endsWith('=')) {
				archMsgPart += ' ';
				archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart + '\r\n\r\n'));
			}

			String archMsg = JSON.serialize(payload);
			String archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg + '\r\n\r\n'));
			while (archMsgEncoded.endsWith('=')) {
				archMsg += ' ';
				archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg + '\r\n\r\n'));
			}
			//adione - attenzione alle differenze con FileNet 1-part name, 2- content-type, 3- CRLF per l'a-capo 
			String filePart = '--' + boundary + '\r\nContent-Disposition: form-data; name="documento"; filename="' + fileName + '"\r\nContent-Type: application/pdf';
			String filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart + '\r\n\r\n'));
			while (filePartEncoded.endsWith('=')) {
				filePart += ' ';
				filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart + '\r\n\r\n'));
			}

			String bodyEncoded = EncodingUtil.base64Encode(fileData);
			List<String> bodyEncs = new List<String> ();

			bodyEncs = WGC_FileUploaderController.splitStringEvery(bodyEncoded, 6000000);

			Blob bodyBlob = null;
			String last4Bytes;

			last4Bytes = bodyEncs[bodyEncs.size() - 1].substring(bodyEncs[bodyEncs.size() - 1].length() - 4, bodyEncs[bodyEncs.size() - 1].length());

			if (last4Bytes.endsWith('==')) {
				last4Bytes = last4Bytes.substring(0, 2) + '0K';
				bodyEncs[bodyEncs.size() - 1] = bodyEncs[bodyEncs.size() - 1].substring(0, bodyEncs[bodyEncs.size() - 1].length() - 4) + last4Bytes;
			} else if (last4Bytes.endsWith('=')) {
				last4Bytes = last4Bytes.substring(0, 3) + 'N';
				bodyEncs[bodyEncs.size() - 1] = bodyEncs[bodyEncs.size() - 1].substring(0, bodyEncs[bodyEncs.size() - 1].length() - 4) + last4Bytes;
				footer = '\n' + footer;
			} else {
				footer = '\r\n' + footer;
			}

			String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));

			if (bodyEncoded.length() < 6000000) {
				last4Bytes = bodyEncoded.substring(bodyEncoded.length() - 4, bodyEncoded.length());
				if (last4Bytes.endsWith('==')) {
					last4Bytes = last4Bytes.substring(0, 2) + '0K';
					bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
				} else if (last4Bytes.endsWith('=')) {
					last4Bytes = last4Bytes.substring(0, 3) + 'N';
					bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
					footer = '\n' + footer;
				} else {
					footer = '\r\n' + footer;
				}

				bodyBlob = EncodingUtil.base64Decode(archMsgPartEncoded + archMsgEncoded + filePartEncoded + bodyEncoded + footerEncoded);

			} else { 
			   multipartForBigFile(archMsgPartEncoded, archMsgEncoded, filePartEncoded, bodyEncs, footerEncoded, JSON.serialize(input));
			   wrap.message = 'Il documento verrà caricato a breve';
		  
			   archMsgPartEncoded = null;
			   archMsgEncoded = null;
			   filePartEncoded = null;
			   bodyEncs = null;
			   footerEncoded = null;
			}

			//loggo la chiamata per avere arch msg input altrimenti poi il metodo generico di chiamata servizio 
			//che logga le chiamate, non logga quelle con input binario
			Log__c l = new Log__c(); 
			l.Source__c = DIGIBOX;
			l.Account__c = cedente.Id;
			l.InputPayload__c = JSON.serialize(payload).abbreviate(131072);
			Logger.log(l);

			om = (ResponseUpload) WGC_WsRest.uploadDocDigiBox(bodyBlob, boundary);

			wrap.data.add(om);
			wrap.message = 'OK';
			return wrap;

        } catch (Exception e) {
            System.debug('-----> BI_CRM_DigiBox_CODE.createAutomatic exception: ' + e.getMessage() + ' - ' + e.getCause() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
			Log__c l = new Log__c(); 
			l.Source__c = DIGIBOX;
			l.Account__c = cedente.Id;
			l.ErorrMessage__c = e.getMessage().abbreviate(131072);
			l.InputPayload__c = JSON.serialize(payload).abbreviate(131072);

			Logger.log(l);

            wrap.message = e.getMessage();
            wrap.success = false;

            return wrap;
        }
	}


	@future(callout=true)
    public static void multipartForBigFile(String str, String str2, String str3, List<String> listaBody, String str6, String payload) {
        String boundary = '------WebKitFormBoundaryqBrgE8Q9dPLWtV4J';
        String abc = str + str2 + str3;
        String msgPost;

        try {
            for(String s : listaBody){
                abc += s;
            }

            //Nullify for apex heap size
            listaBody = null;

            abc += str6;
            Blob bodyBlob = EncodingUtil.base64Decode(abc);

            //Nullify for apex heap size
            abc = null;

			ResponseUpload res = WGC_WsRest.uploadDocDigiBox(bodyBlob, boundary);
            msgPost = 'Documento caricato correttamente';

        } catch (Exception e) {
            System.debug('-----> BI_CRM_DigiBox_CODE.createAutomatic eccezione future: ' + e.getMessage() + ' - ' + e.getCause() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString());
			Log__c l = new Log__c(); 
			l.Source__c = DIGIBOX;
			l.ErorrMessage__c = e.getMessage().abbreviate(131072);
			l.InputPayload__c = payload;

			Logger.log(l);

            msgPost = 'Documento non caricato correttamente';
        }

        String rispostaChatter = WGC_FileUploaderController.createChatterPostForDocument(msgPost);
    }


	/**
	 * Classi wrapper per gestire la risposta di inserimento del documentale
	 */
	public class ResponseUpload extends WsRestInput.CommonResponse {
		public String payload;

		public ResponseUpload() {
			this.payload = '';
		}

		public override Boolean isCorrect() {
			return payload != null;
		}
	}

	/** 
	 * Classi Wrapper di creazione del payload di input
	 **/
	public class InputMultipart {
		@AuraEnabled
		public WrapperData data;

		public InputMultipart() {
			this.data = new WrapperData();
		}
	}

	public class WrapperData {
		public List<DboxMetadatoDocumento> metadati = new List<DboxMetadatoDocumento>();
		//public String barcode;
		//public BigDecimal numeroPagine;
		public String filiale = '';
		public String ndg = '';
		public String useridInserimento = '';
		//public Long idModello = -1;

		public WrapperData() {
		}
	}

	public class DboxMetadatoDocumento {
		/** The id. 
		private Long id = null;
		*/
		/** The chiave. */
		public String chiave = null;
		/** The valore. */
		public String valore = null;
		/** The documento id. 
		private Long documentoId = null;
		*/

		public DboxMetadatoDocumento() {
		}
	}


}