public without sharing class NexiPaymentIntegrationCtrl {

    // public static final String callbackUrl = '/services/apexrest/v1.0/NexiPaymentNotify';
    public static final String callbackUrl = EndpointServizi__c.getOrgDefaults().WRT_Nexi_Notifica__c;
    
    @AuraEnabled
    public static Map<String,Object> paymentInit(Decimal amount, String cardHolderName, String cardHolderEmail){
        String msg = '';
        String body = '';
        String responseBody = '';
        Boolean success = true;

        Map<String,Object> result = new Map<String,Object>();

        try {
            HttpRequest request = new HttpRequest();
            request.setTimeout(90000);
            request.setMethod('POST');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Nexi_Ecobonus_Init__c);

            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            Map<String,Object> fields = new Map<String,Object>{
                'id' => UtenzeDefault__c.getOrgDefaults().WRT_Nexi_Codice_Terminale__c, //TEST 44000046 //Codice terminale --> TODO: Da richiedere, inserire in un custom settings
                'password' => UtenzeDefault__c.getOrgDefaults().WRT_Nexi_Password_Terminale__c, //TEST Password1 //Password Terminale --> TODO: Da richiedere, inserire in un custom settings
                'operationType' => 'initialize', //FISSO
                'amount' => amount, //Ammontare operazione
                'language' => 'ITA',
                'responseToMerchantUrl' => callbackUrl, //NB Deve essere un ws esposto da sito pubblico
                'merchantOrderId' => generateJWTMerchantOrderId(),
                'cardHolderName' => cardHolderName.split('\\|')[0] + ' ' + cardHolderName.split('\\|')[1],
                'cardHolderEmail' => cardHolderEmail,
                'customField' => cardHolderName+'_'+cardHolderEmail,
                'recoveryUrl' => EndpointServizi__c.getOrgDefaults().WRT_Nexi_Ecobonus_Redirect_Ok__c,
                'description' => 'green110'
            };

            for(String key : fields.keySet()){
                body += key + '=' + fields.get(key) + '&'; 
            }

            body = body.removeEnd('&');
            request.setBody(body);

            System.debug('@@@ body ' + body);
            HttpResponse response = new Http().send(request);
            System.debug('@@@ response ' + response.getBody());
            responseBody = response.getBody();

            //Parsing della response in formato in xml
            Dom.Document doc = new Dom.Document();
            doc.load(response.getBody());

            Dom.XmlNode root = doc.getRootElement();
            Dom.XmlNode[] children = root.getChildElements();

            if(root.getName() == 'error'){
                System.debug('@@@ error ');
                throw new CalloutException('Codice Errore: ' + children[0].getText() + ' - ' + 'Messaggio: ' + children[1].getText());
            }

            String redirectUrlNode;
            for(Dom.XmlNode node : children){
                result.put(node.getName(), node.getText());
                if(node.getName() == 'hostedpageurl') {
                    redirectUrlNode = node.getText();
                }
            }

            result.put('success', true);
            result.put('redirectUrl', String.isBlank(redirectUrlNode) ? EndpointServizi__c.getOrgDefaults().WRT_Nexi_Ecobonus_Redirect__c + String.valueOf(result.get('paymentid')) : redirectUrlNode + '?paymentId=' + String.valueOf(result.get('paymentid')));
            // result.put('redirectUrl', EndpointServizi__c.getOrgDefaults().WRT_Nexi_Ecobonus_Redirect__c + String.valueOf(result.get('paymentid')));
            //Redirect di esempio
            //https://test.monetaonline.it/monetaweb/page/hosted/2/html?paymentId=860138878502010639

        } catch(Exception e){
            System.debug('@@@ error ' + e.getMessage() + ' - ' + e.getLineNumber());
            msg = e.getMessage();
            success = false;

            result.put('success', false);
            result.put('message', msg);
        }

        insert new Log__c(
            Source__c = 'EcobonusPagamento',
            ErrorMessage__c = msg,
            Success__c = success,
            InputPayload__c = body,
            OutputPayload__c = responseBody
        );

        return result;
    }

    public static String generateJWTMerchantOrderId(){

        String data = String.valueOf(System.now().date());
        String hour = String.valueOf(System.now().hour());
        String minute = String.valueOf(System.now().minute());
        String second = String.valueOf(System.now().second());
        String msecond = String.valueOf(System.Now().millisecond());

        String output = encodingUtil.base64Encode(Blob.valueof(data + hour + (minute.length() <= 1 ? ('0' + minute) : minute) + (second.length() <= 1 ? ('0' + second) : second) + msecond));

        JWT jwt = new JWT('HS256'); 
        jwt.userEmail = UserInfo.getUserEmail();
        
        jwt.privateKey = output; 
        String token = jwt.issue();        
        system.debug ('token: '+ token);
        List<String> tokenSplitted = token.split('\\.');
        token = tokenSplitted[tokenSplitted.size() - 1];
        token = token.replaceAll('[^a-zA-Z0-9\\s+]', '');
        token = token.substring(0,18);
        system.debug ('token: '+ token);
        
        return token;
    }

    @AuraEnabled
    public static Map<String,Object> findPayment(String paymentId){
        Map<String,Object> response = new Map<String,Object>();

        List<WRT_Transazione__c> lista = new List<WRT_Transazione__c>([SELECT Id, Name, PaymentId__c, Result__c FROM WRT_Transazione__c WHERE PaymentId__c =: paymentId LIMIT 1]);
        response.put('record', lista);

        return response;
    }

    //V2
    // @AuraEnabled
    // public static Map<String,Object> pay(Map<String,String> params){

    //     String msg = '';
    //     String body = '';
    //     String responseBody = '';
    //     Boolean success = true;

    //     Map<String,Object> result = new Map<String,Object>();

    //     WRT_Transazione__c transazione = new WRT_Transazione__c(Email_Del_Cliente__c = params.get('email'), Nome_Del_Cliente__c = params.get('firstName'), Cognome_Del_Cliente__c = params.get('lastName'));

    //     try {
    //         HttpRequest request = new HttpRequest();
    //         request.setTimeout(90000);
    //         request.setMethod('POST');
    //         request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Nexi_Ecobonus_Init__c);

    //         request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

    //         Map<String,Object> fields = new Map<String,Object>{
    //             'id' => UtenzeDefault__c.getOrgDefaults().WRT_Nexi_Codice_Terminale__c, //TEST 44000046 //Codice terminale --> TODO: Da richiedere, inserire in un custom settings
    //             'password' => UtenzeDefault__c.getOrgDefaults().WRT_Nexi_Password_Terminale__c, //TEST Password1 //Password Terminale --> TODO: Da richiedere, inserire in un custom settings
    //             'operationType' => 'pay', //FISSO
    //             'amount' => params.get('amount'), //Ammontare operazione
    //             'merchantOrderId' => generateJWTMerchantOrderId(),
    //             'cardHolderName' => params.get('firstName') + ' ' + params.get('lastName'),
    //             'card' => params.get('card'),
    //             'cvv2' => params.get('cvv2'),
    //             'expiryMonth' => params.get('expiryMonth'),
    //             'expiryYear' => params.get('expiryYear'),
    //             // 'customField' => cardHolderName+'_'+cardHolderEmail,
    //             'description' => 'Pagamento Ecobonus: ' + params.get('firstName') + ' ' + params.get('lastName') + ' ' + params.get('email')
    //         };

    //         for(String key : fields.keySet()){
    //             body += key + '=' + fields.get(key) + '&'; 
    //         }

    //         body = body.removeEnd('&');
    //         request.setBody(body);

    //         System.debug('@@@ body ' + body);
    //         HttpResponse response = new Http().send(request);
    //         System.debug('@@@ response ' + response.getBody());
    //         responseBody = response.getBody();

    //         //Parsing della response in formato in xml
    //         Dom.Document doc = new Dom.Document();
    //         doc.load(response.getBody());

    //         Dom.XmlNode root = doc.getRootElement();
    //         Dom.XmlNode[] children = root.getChildElements();

    //         if(root.getName() == 'error'){
    //             System.debug('@@@ error ');
    //             throw new CalloutException('Codice Errore: ' + children[0].getText() + ' - ' + 'Messaggio: ' + children[1].getText());
    //         }

    //         for(Dom.XmlNode node : children){
    //             result.put(node.getName(), node.getText());
    //         }

    //         result.put('success', true);

    //         transazione.PaymentId__c = String.valueOf(result.get('paymentid'));
    //         transazione.Result__c = String.valueOf(result.get('result'));
    //         insert transazione;
    //         // result.put('redirectUrl', EndpointServizi__c.getOrgDefaults().WRT_Nexi_Ecobonus_Redirect__c + String.valueOf(result.get('paymentid')));
    //         //Redirect di esempio
    //         //https://test.monetaonline.it/monetaweb/page/hosted/2/html?paymentId=860138878502010639

    //     } catch(Exception e){
    //         System.debug('@@@ error ' + e.getMessage() + ' - ' + e.getLineNumber());
    //         msg = e.getMessage();
    //         success = false;

    //         result.put('success', false);
    //         result.put('message', msg);

    //         // transazione.PaymentId__c = params.get('paymentid');
    //         transazione.Result__c = 'Errore durante la chiamata';
    //     }

    //     insert new Log__c(
    //         Source__c = 'EcobonusPagamento',
    //         ErrorMessage__c = msg,
    //         Success__c = success,
    //         InputPayload__c = body,
    //         OutputPayload__c = responseBody
    //     );

    //     return result;
    // }

    public class ActionRequest {       
        @AuraEnabled @InvocableVariable
        public Decimal amount;
        @AuraEnabled @InvocableVariable
        public String nome;
        @AuraEnabled @InvocableVariable
        public String cognome;
        @AuraEnabled @InvocableVariable
        public String email;
    }


    @InvocableMethod(label='Init pagamento' callout=true)
    public static List<String> handlePaymentInit(List<ActionRequest> parametri){

        Map<String,String> params = new Map<String,String>{
            'nome' => parametri[0].nome,
            'cognome' => parametri[0].cognome,
            'email' => parametri[0].email,
            'amount' => String.valueOf(parametri[0].amount)
        };
        
        //Decimal amount, String cardHolderName, String cardHolderEmail

        Map<String,Object> result = NexiPaymentIntegrationCtrl.paymentInit(parametri[0].amount, parametri[0].nome + '|' + parametri[0].cognome, parametri[0].email);

        return new List<String>{String.valueOf(result.get('paymentid'))+'|'+String.valueOf(result.get('redirectUrl'))};

    }
}