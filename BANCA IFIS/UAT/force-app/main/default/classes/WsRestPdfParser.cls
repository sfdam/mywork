public with sharing class WsRestPdfParser {
    
    public static ParseCertificazioneResponse parseCertificazione(Id contentDocumentId) {
        if (String.isBlank(contentDocumentId)) {
            throw new Ex.WsException('Non riesco a leggere il file');
        }
        /*
        ContentDocument cd = [SELECT Id, Title, FileExtension, LatestPublishedVersionId 
                              FROM ContentDocument 
                              WHERE Id=:contentVersionId];
        */
        ContentVersion cv = [SELECT Id, PathOnClient, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, 
                             ContentDocument.LatestPublishedVersionId, VersionData, ContentSize 
                             FROM ContentVersion 
                             WHERE ContentDocumentId =:contentDocumentId 
                             AND IsLatest=true];
        
        //String file_name = cd.Title +'.'+cd.FileExtension;
        String file_name = cv.ContentDocument.Title;
        WsRestInput payload = new WsRestInput( new ParseCertificazioneInput(file_name) );
        
        //form multipart preparation
        String boundary = '----------------------------741e90d31eff';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(boundary));
        
        String archMsgPart = '--'+boundary+'\r\nContent-Disposition: form-data; name="archMessage"; filename="archMessage.json"\r\nContent-Type: application/json';
        String archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
        while(archMsgPartEncoded.endsWith('=')) {
            archMsgPart+=' ';
            archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
        }
        
        String archMsg = JSON.serialize(payload);
        String archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf( archMsg +'\r\n\r\n' ));
        while(archMsgEncoded.endsWith('=')) {
            archMsg+=' ';
            archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg+'\r\n\r\n'));
        }
        
        String filePart = '--'+boundary+'\r\nContent-Disposition: form-data; name="creditocertificato"; filename="'+file_name+'"\r\nContent-Type: application/octet-stream';
        String filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
        while(filePartEncoded.endsWith('=')) {
            filePart+=' ';
            filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
        }
        
        String footer = '--'+boundary;
        
        String bodyEncoded = EncodingUtil.base64Encode(cv.VersionData);
        
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
        } else {
            footer = '\r\n' + footer;
        }
        
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode( archMsgPartEncoded + archMsgEncoded + filePartEncoded + bodyEncoded + footerEncoded); 

        ParseCertificazioneResponse res = (ParseCertificazioneResponse) WsRestUtils.callService('UrlCertificazioneParser__c', bodyBlob, ParseCertificazioneResponse.Class, 120000, boundary);

        AsyncLog__e l  = new AsyncLog__e();
        l.CodiceApplicazione__c = 'Portale Ti Anticipo';
        l.CodiceFunzione__c = 'WsRestPdfParser.parseCertificazione';
        l.Source__c = 'TiAnticipo';
        l.OutputPayload__c = (JSON.serialize(res)).abbreviate(131072);
        l.InputPayload__c = JSON.serialize(payload);
        EventBus.publish(l);
        
        return res;
    }
    
    
    
    public class ParseCertificazioneInput {
        //public String fileName;
        
        public ParseCertificazioneInput(String fileName) {
        }
    }
    
    public class ParseCertificazioneResponse extends WsRestInput.CommonResponse {
        public DatiCrediti payload;
        
        public override Boolean isCorrect() {
            return payload.resultMessage.equalsIgnoreCase('Success');
        }
    }
    
    public class DatiCrediti {
        /** Messaggio risultato estrazione */
        private String resultMessage;
        /** Codice risultato estrazione */
        private String resultCode;
        /** Flag che indica se il file è firmato */
        private boolean signature;
        /** Flag che indica se l'operazione di verifica della firma si è conclusa correttamente */
        private boolean valid;
        /** dati certificazione */
        private String dataPagamento;
        private String naturaCorrenteImportoCredito;
        private String contoCapitaleImportoCredito;
        private String ammontareComplessivoCredito;
        public String codiceControllo;
        public String dataRicezione;
        public String debitore;
        public String numeroCertificazione;
        public String numIstanzaCertificazione;
        public String pivaOrCf;
        /** dati fatture */
        public Fattura[] fatture;
        
        public Date getDataPagamento() {
            return Date.parse(dataPagamento);
        }
        
        public Double getImportoCertificato() {
            return parseValuta(naturaCorrenteImportoCredito) + parseValuta(contoCapitaleImportoCredito);
        }
        
        public Double getAmmontareComplessivoCredito() {
            return parseValuta(ammontareComplessivoCredito);
        }        
    }
    
    public class Fattura {
        private String data;
        private String importo;
        public String numeroFattura;
        private String riconosciuto;
        
        public Double getImporto() {
            return parseValuta(importo);
        }
        
        public Double getImportoRiconosciuto() {
            return parseValuta(riconosciuto);
        }
        
        public Date getData() {
            return Date.parse(data);
        }
    }
    
    //utils
    private static Double parseValuta(String valuta) {
        if (String.isBlank(valuta)) return null;
        return Double.valueOf(valuta.replace('€', '').replace('.', '').replace(',', '.'));
    }
}