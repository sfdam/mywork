public class WGC_QbleInvioDocumentiNuovaVendita implements Queueable, Database.AllowsCallouts {
	
    List<WGC_Documenti_Controller.AggiornamentoData> docsToNuovaVendita = new List<WGC_Documenti_Controller.AggiornamentoData>();

    public WGC_QbleInvioDocumentiNuovaVendita(List<WGC_Documenti_Controller.AggiornamentoData> docs){
        this.docsToNuovaVendita = docs;     
    }

	// QUESTO JOB ELABORA UNA LISTA DI DOCUMENTI PRENDENDO SEMPRE IL PRIMO DELLA LISTA
	// LAVORANDOLO E POI RICHIAMANDO IL JOB STESSO
	// IN QUESTO MODO LA LISTA VIENE ELABORATA "DOCUMENTO per DOCUMENTO"

    public void execute(QueueableContext context){
        if(this.docsToNuovaVendita.isEmpty()) return;

        WGC_Documenti_Controller.AggiornamentoData docNV = this.docsToNuovaVendita.remove(0);

        System.debug('@@@ docNV ' + JSON.serialize(docNV));

        WsRestInput input = new WsRestInput(docNV);
        System.debug('@@@ input qble doc invio nuova vendita ' + input.toJSONString());

        String file_name = docNV.data.datiDocumento.contenutoDocumento[0].nomeFIle;
        Blob file_body = Blob.valueOf('FAKEFILE');

        //form multipart preparation
        String boundary = '----------------------------741e90d31eff';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(boundary));

        String archMsgPart = '--'+boundary+'\nContent-Disposition: form-data; name="archMessage"; filename="archMessage.json";\nContent-Type: application/json';
        String archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
        while(archMsgPartEncoded.endsWith('=')) {
            archMsgPart+=' ';
            archMsgPartEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsgPart+'\r\n\r\n'));
        }

        String archMsg = JSON.serialize(input);
        String archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf( archMsg +'\r\n\r\n' ));
        while(archMsgEncoded.endsWith('=')) {
            archMsg+=' ';
            archMsgEncoded = EncodingUtil.base64Encode(Blob.valueOf(archMsg+'\r\n\r\n'));
        }

        String filePart = '--'+boundary+'\nContent-Disposition: form-data; name="oggetto"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
            while(filePartEncoded.endsWith('=')) {
            filePart+=' ';
            filePartEncoded = EncodingUtil.base64Encode(Blob.valueOf(filePart+'\r\n\r\n'));
        }

        String footer = '--'+boundary+'--';

        String bodyEncoded = EncodingUtil.base64Encode(file_body);

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

		try{

			String responseAggiornamento = JSON.serialize(WGC_WsRest.uploadDoc(bodyBlob, boundary));

			System.debug('@@@ responseAggiornamento ' + JSON.serialize(responseAggiornamento));

		}
		catch(Exception ex){
		
			BI_COM_AppLogFacade_CODE.insertAppLog(BI_COM_AppLogFacade_CODE.Threshold.ERROR,WGC_QbleInvioDocumentiNuovaVendita.class.getName(),file_name,ex.getTypeName() + ' - ' + ex.getStackTraceString(),input.toJSONString());			

		}
        
        if(!this.docsToNuovaVendita.isEmpty() && !Test.isRunningTest()){

			// RICHIAMA IL JOB PER IL PROSSIMO DOCUMENTO (LISTA DI DOCUMENTI DECURTATA DEL PRIMO)

            System.enqueueJob(new WGC_QbleInvioDocumentiNuovaVendita(this.docsToNuovaVendita));
        }
    }

}