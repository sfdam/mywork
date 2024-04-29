@isTest
public class TestREST_KopernicoAPIMock implements HttpCalloutMock {
    
    public static HTTPResponse response = new HTTPResponse();
    
    public HTTPResponse respond(HTTPRequest req) {
    	REST_KopernicoAPI.Agenzie ag = new REST_KopernicoAPI.Agenzie();
        ag.tipologia             = 'tpl';
        ag.codice                = 'Codice usato per il test';
        ag.denominazione		 = 'descriz';
        ag.indirizzo             = 'via xxx, bbb';
        ag.comune                = 'cmn';
        ag.provincia             = 'prv';
        ag.regione               = 'rgn';
        ag.cap                   = '1450023';
        ag.telefono              = '+396541221255';
        ag.compagnia             = 'cmp';
        ag.dataInizio            = '22/07/2021';
        ag.codiceSegnalatore     = 'Codice usa';
        
        REST_KopernicoAPI.ResponseRecuperaAgenzie ags = new REST_KopernicoAPI.ResponseRecuperaAgenzie();
        ags.listaAgenzie = new Map<String, List<REST_KopernicoAPI.Agenzie>>{'1' => new List<REST_KopernicoAPI.Agenzie>{ag} };
        
        // Set response values
        response.setHeader('Content-Type', 'application/json');
        response.setBody( System.JSON.serialize( ags ) );
        System.debug('[MOCK CLASS] Body : ' + response.getBody());
        response.setStatusCode(200);
        response.setStatus('status');
        
        // return response.
        return response;
    }
}