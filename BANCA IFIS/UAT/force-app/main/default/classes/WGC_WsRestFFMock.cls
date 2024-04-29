@isTest
global class WGC_WsRestFFMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {

        String body;
        if(request.getMethod() == 'POST'){
            System.debug('REQUEST.ENDPOINT(): ' + request.getEndpoint());
            if(request.getEndpoint().containsIgnoreCase('WGC_CensimentoTratt__c')){
                body = this.createBodycensimentoTrattativa();
            } else if(request.getEndpoint().containsIgnoreCase('WGC_ConfermaTratt__c')){
                body = this.createBodyconfermaTrattativa();
            } else if(request.getEndpoint().containsIgnoreCase('WGC_CalcoloInteressi__c')){
                body = this.createBodycalcoloInteressi();
            } else if(request.getEndpoint().containsIgnoreCase('WGC_CalcoloDIP__c')){
                body = this.createBodycalcoloDip();
            } else if(request.getEndpoint().containsIgnoreCase('WGC_CalcoloIRR__c')){
                body = this.createBodycalcoloIrr();
            } else if(request.getEndpoint().containsIgnoreCase('WGC_CalcoloCompensi__c')){
                body = this.createBodycalcoloCompensi();
            }

        }else{
            body = 'null';
        }

        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Accept','application/json');
        response.setBody(body);
        response.setStatus('OK');
        response.setStatusCode(200);
        return response;
    }

    private String createBodycensimentoTrattativa() {
        Opportunity oppFEG = WGC_AllDataFactory.createOpportunity2(1).get(0);
        insert oppFEG;
        Credito__c credito = new Credito__c();
        credito.Opportunita__c = oppFEG.Id;
        insert credito;

        return '{"payload":{"esito":[{"esitoRiga":"OK","idCrmLinea":"'+credito.Id+'","pRapporto":"5711502444463"}]},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"bfffe90b-0477-4656-b373-86cf8b274d94","channel":"B2B","timeStamp":1583486760063,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"utenti.CRM","description":""},{"name":"Users","description":""},{"name":"NoLocalLogon","description":""},{"name":"cbox.ff.uat","description":""},{"name":"cbox.ff.prd","description":""}],"userRoles":[]}}}}}';
    }

    private String createBodyconfermaTrattativa(){
        return '{"payload":{"esito":"OK"},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"cccff91b-f462-4dbd-8303-af262211f4ce","channel":"B2B","timeStamp":1582195784064,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"utenti.CRM","description":""},{"name":"Users","description":""},{"name":"NoLocalLogon","description":""},{"name":"cbox.ff.uat","description":""},{"name":"cbox.ff.prd","description":""}],"userRoles":[]}}}}}';
    }

    private String createBodycalcoloInteressi(){
        return '{"payload":{"pInteressi":"362.19"},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"2d7a1084-3056-4a5a-ae6e-9b32616110e4","channel":"B2B","timeStamp":1582622527458,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"utenti.CRM","description":""},{"name":"Users","description":""},{"name":"NoLocalLogon","description":""},{"name":"cbox.ff.uat","description":""},{"name":"cbox.ff.prd","description":""}],"userRoles":[]}}}}}';
    }

    private String createBodycalcoloDip(){
        return '{"payload":{"pDIP":1719698400000,"pNrCasi":256,"pDipUltOsserv":null,"pCommessaUltOsserv":null,"pTempoRecupero":null,"pTipoTMR":4,"pDescTipoTMR":"Italia","pDataRichRimborso":null,"pDescrTipolIncasso":"Altro"},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"cccff91b-f462-4dbd-8303-af262211f4ce","channel":"B2B","timeStamp":1582195784064,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"utenti.CRM","description":""},{"name":"Users","description":""},{"name":"NoLocalLogon","description":""},{"name":"cbox.ff.uat","description":""},{"name":"cbox.ff.prd","description":""}],"userRoles":[]}}}}}';
    }

    private String createBodycalcoloIrr(){
        return '{"payload":{"elencoCrediti":[{"testata":{"pGgIncasso":255,"pIRR":5187.34263408169400},"righe":[{"pNrMese":null,"pNgGiorni":0,"pData":1587333600000,"pTasso":2.0,"pInteressiMaturati":0,"pInteressiCumul":0.00,"pVNInteressi":100000.00,"pPrezzoRata1":0.00,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0,"PIntpassiviRata2":0,"pFlussoNetto":0.00},{"pNrMese":0,"pNgGiorni":10,"pData":1588197600000,"pTasso":2.0,"pInteressiMaturati":0,"pInteressiCumul":0.00,"pVNInteressi":100000.00,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":-1000.0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":-1000.00},{"pNrMese":1,"pNgGiorni":31,"pData":1590876000000,"pTasso":2.0,"pInteressiMaturati":0,"pInteressiCumul":0.00,"pVNInteressi":100000.00,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":-8465.45,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":-8465.45},{"pNrMese":2,"pNgGiorni":30,"pData":1593468000000,"pTasso":2.0,"pInteressiMaturati":32.79,"pInteressiCumul":32.79,"pVNInteressi":100032.79,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":0.00},{"pNrMese":3,"pNgGiorni":31,"pData":1596146400000,"pTasso":2.0,"pInteressiMaturati":169.40,"pInteressiCumul":202.19,"pVNInteressi":100202.19,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":0.00},{"pNrMese":4,"pNgGiorni":31,"pData":1598824800000,"pTasso":2.0,"pInteressiMaturati":169.40,"pInteressiCumul":371.59,"pVNInteressi":100371.59,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":0.00},{"pNrMese":5,"pNgGiorni":30,"pData":1601416800000,"pTasso":2.0,"pInteressiMaturati":163.94,"pInteressiCumul":535.53,"pVNInteressi":100535.53,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":0.00},{"pNrMese":6,"pNgGiorni":31,"pData":1604098800000,"pTasso":2.0,"pInteressiMaturati":169.40,"pInteressiCumul":704.93,"pVNInteressi":100704.93,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":0.00},{"pNrMese":7,"pNgGiorni":30,"pData":1606690800000,"pTasso":2.0,"pInteressiMaturati":163.94,"pInteressiCumul":868.87,"pVNInteressi":100868.87,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":0,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":0.00},{"pNrMese":8,"pNgGiorni":31,"pData":1609369200000,"pTasso":2.0,"pInteressiMaturati":169.40,"pInteressiCumul":1038.27,"pVNInteressi":101038.27,"pPrezzoRata1":0,"pPrezzoRata2":0,"pCostoNotaio":0,"pCostoContenz":0,"pCostoUL":0,"pIncassi":101038.27,"pIntPassiviRata1":0.00,"PIntpassiviRata2":0.00,"pFlussoNetto":101038.27}],"esito":"OK"}]},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"90a38eeb-89d6-4515-8ece-87100cff0af4","channel":"B2B","timeStamp":1583490501001,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"utenti.CRM","description":""},{"name":"Users","description":""},{"name":"NoLocalLogon","description":""},{"name":"cbox.ff.uat","description":""},{"name":"cbox.ff.prd","description":""}],"userRoles":[]}}}}}';
    }

    private String createBodycalcoloCompensi(){
        return '{"payload":{"pCompenso":1845.34,"pCap":58.176,"pIVA":332.76672},"headers":{"headers":{"tech_header":{"id":"tech_header","applicationCode":"CRM","correlationId":"d9e75f09-0270-4f1f-a9a9-7c69445a098a","channel":"B2B","timeStamp":1582540010077,"workstationId":null,"clientIpAddress":null,"clientHostname":null},"user_header":{"id":"user_header","archUser":{"name":"CRM Salesforce","surname":"SFDC","emailAddress":null,"phoneNumber":null,"userId":"ext.crm","actualUserId":"ext.crm","institute":null,"userGroups":[{"name":"utenti.CRM","description":""},{"name":"Users","description":""},{"name":"NoLocalLogon","description":""},{"name":"cbox.ff.uat","description":""},{"name":"cbox.ff.prd","description":""}],"userRoles":[]}}}}}';
    }
}