@RestResource(urlMapping='/v1/gestioneEventiMulticanali/*')
global class REST_GestioneEventiMulticanale {
    
    global static Map<String,List<String>> mapDomainValue = new Map<String,List<String>>{'priorita'=>new List<String>{'2-Medio'},
        																   'argomentoComunicazione'=>new List<String>{'Altri prodotti banking','Altro','Carte di credito','Carte di debito','Carte iban','Carte prepagate','Conti','Incassi e Pagamenti','Investimenti','Multicanalità','Mutui','Pagamenti','Prestiti','Previdenza e protezione','Sicurezza'},
                                                                           'modalitaDiContattoDefinita'=>new List<String>{'Appuntamento in Filiale','E-mail','Telefono'},
                                                                           'originatorChannel'=>new List<String>{'IBSB','SBMO','TBPR','TBSB','IBMO','IBPR'}};

    @HttpPost
    global static GestioneEventiMulticanaleResponse postGestioneEventiMulticanale(List<InfoEvento> infoEvento){
        System.debug('@@@@@@ REQUEST: '+JSON.serialize(infoEvento));
        GestioneEventiMulticanaleResponse postGestioneEventiMulticanale = new GestioneEventiMulticanaleResponse();

        RestResponse res;
        RestRequest req;

        
        try{
            req = RestContext.request;
            res = RestContext.response;

            //Set Response Headers
            setHeaders(req, res);
            
            postGestioneEventiMulticanale=process(infoEvento, postGestioneEventiMulticanale);
            
        }
       finally {
            // This gets executed after the exception is handled
            WsRestUtils.writeLog('postGestioneEventiMulticanale', req.httpMethod, JSON.serializePretty(infoEvento), 200, 'status', JSON.serializePretty(postGestioneEventiMulticanale),  req.headers,  res.headers, '', '');
            
        }

        return postGestioneEventiMulticanale;
    }    

    global static boolean checkDomain(InfoEvento eventoMultiCanale)
    {
        if(
            mapDomainValue.get('priorita').contains(eventoMultiCanale.priorita) &&
            mapDomainValue.get('argomentoComunicazione').contains(eventoMultiCanale.argomentoComunicazione) &&
            mapDomainValue.get('modalitaDiContattoDefinita').contains(eventoMultiCanale.modalitaDiContattoDefinita) &&
            mapDomainValue.get('originatorChannel').contains(eventoMultiCanale.originatorChannel))
        	return true;
        else
            return false;
    }
    global static boolean isNotNullOrEmpty(String str){
        return String.isNotBlank(str) && String.isNotEmpty(str);
        
    }
    global static boolean  checkValue(InfoEvento eventoMultiCanale)
    {
        
        if(
            isNotNullOrEmpty(eventoMultiCanale.codiceEvento) &&
            isNotNullOrEmpty(eventoMultiCanale.descrizioneEvento) &&
            isNotNullOrEmpty(eventoMultiCanale.priorita) &&
            isNotNullOrEmpty(eventoMultiCanale.dataOraRichiesta) &&
            isNotNullOrEmpty(eventoMultiCanale.argomento) &&
            isNotNullOrEmpty(eventoMultiCanale.argomentoComunicazione) &&
            isNotNullOrEmpty(eventoMultiCanale.banca) &&
            isNotNullOrEmpty(eventoMultiCanale.ndg) &&
            isNotNullOrEmpty(eventoMultiCanale.titolare) &&
            isNotNullOrEmpty(eventoMultiCanale.modalitaDiContattoDefinita) &&
            isNotNullOrEmpty(eventoMultiCanale.telefono) &&
            isNotNullOrEmpty(eventoMultiCanale.email) &&
            isNotNullOrEmpty(eventoMultiCanale.preferenzaOrario) &&
            isNotNullOrEmpty(eventoMultiCanale.preferenzaData)&&
            isNotNullOrEmpty(eventoMultiCanale.dettagliRichiesta) &&
            isNotNullOrEmpty(eventoMultiCanale.originatorChannel))
        	return true;
        else
            return false;
        
    }
    
    global class InfoEvento {
		public String codiceEvento;
		public String descrizioneEvento;
		public String priorita;
		public String dataOraRichiesta;
		public String argomento;
		public String argomentoComunicazione;
		public String banca;
		public String ndg;
		public String titolare;
		public String modalitaDiContattoDefinita;
		public String telefono;
		public String email;
		public String preferenzaOrario;
		public String preferenzaData;
		public String dettagliRichiesta;
		public String originatorChannel;
    }

    private static void setHeaders(RestRequest req, RestResponse res){
        if(req.headers.containsKey('testata_operationId')){
            res.addHeader('testata_operationId', req.headers.get('testata_operationId'));
        }
    }

    global class GestioneEventiMulticanaleResponse{
        global String result;
        global String description;
    }

    private static GestioneEventiMulticanaleResponse process(List<InfoEvento> eventiRequest, GestioneEventiMulticanaleResponse x){
        Boolean check=true;
        if(eventiRequest!=null){
            for(InfoEvento er :eventiRequest){
                if(!checkValue(er)){
                    check = false;
                    x.description='Campo required non popolato';
                }
                if(! checkDomain(er)){
                    check = false;
                    x.description='Dominio valori non rispettato';
                }
            } 
        }
        if(check){
            x.result='OK';
        	x.description='Elaborazione corretta';
        }else{
            x.result='KO';
        }

        
        return x;
    }
}