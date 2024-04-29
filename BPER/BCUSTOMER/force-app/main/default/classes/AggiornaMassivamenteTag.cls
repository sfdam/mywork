/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : CR 76756 Batch che aggiorna gli account con il campo "PTF_RiportafogliazioneTAG__c" = oldTag
 *                      con il nuovo TAG 'newTag'
**/

public with sharing class AggiornaMassivamenteTag {
     
    @AuraEnabled
    public static string executeBatchUpdate(String oldTag,String newTag){

        System.debug('AD AggiornaMassivamenteTag');
        System.debug('AD AggiornaMassivamenteTag newtag ' + newtag);
        //oldTag = 'test RIPORTAFOGLIAZIONE 04_23';//AD valore settato staticamente per i problemi di sync con analytics
        System.debug('AD AggiornaMassivamenteTag oldTag ' + oldTag);
        
		String response = '';
        try {

            //AD chiamo la batch : 'Batch_AggiornaMassivamenteTag'
		    //che si occupa di aggiornare il vecchio tag 'oldTag' con il nuovo tag 'newTag'
            if(oldTag != 'null' && oldTag != ''){
                System.debug('AD AggiornaMassivamenteTag oldTag popolato');
                Batch_AggiornaMassivamenteTag batch = new Batch_AggiornaMassivamenteTag(oldTag,newTag);
                Id batchId = Database.executeBatch(batch,200);
                System.debug('AD AggiornaMassivamenteTag batchId : ' + batchId);
                response=batchId;
            }else{
                response='il valore oldTag deve essere popolato e diverso da NULL';
            }
            

        } catch (Exception e) {
            System.debug('AD AggiornaMassivamenteTag Exception : ' + e);

            //throw new AuraHandledException(e.getMessage());
            response=(String)e.getMessage();
        }
        
        return response;
    }
	
    //AD metodo usato per restituire con variabile booleana il completamento/stato della batch 'Batch_AggiornaMassivamenteTag'
    //true batch completata
    //false batch non completata sta ancora lavorando
    @AuraEnabled
    public static Boolean getBatchJobStatus(){

        Boolean risposta = false; 
        
        try{

            list<AsyncApexJob> statusBatch = [SELECT Status FROM AsyncApexJob 
                                                WHERE ApexClass.Name = 'Batch_AggiornaMassivamenteTag' 
                                                and Status in ('Queued', 'Holding','Preparing','Processing')
                                                order by CreatedDate DESC limit 1];
            if(statusBatch.size()>0){
                risposta = false;
            }else{
                risposta = true;

            }

        }catch(Exception e){
            System.debug('AD getBatchJobStatus Exception : ' + e);

        }

        return risposta;
    }

    @AuraEnabled
    public static string getIntegrationUser(){

        String risposta = '';
        try {
            list<user> utenteDiSistema = [SELECT id from user where name ='Integration User'];

            if(utenteDiSistema.size()>0){
                risposta=utenteDiSistema[0].id;
            }else{
                risposta = '';
            }
        } catch (Exception e) {
            risposta = '';
        }

        return risposta;
    }
    //AD status sync
    @AuraEnabled
    public static List<ResponseWrapper> getJobQueryResult() {
        System.debug('AD getJobQueryResult');
        //System.debug('AD UserInfo.getSessionId() : ' + UserInfo.getSessionId().substring(15));
        
            ResponseWrapper rw = new ResponseWrapper();

           
        try{


            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CallMeBack/services/data/v58.0/jobs/ingest/');
            request.setHeader('Content-Type', 'Application/JSON');
            request.setHeader('Accept', 'application/json');
            //request.setHeader('Authorization' ,'Bearer '+UserInfo.getSessionId().substring(15) );  
            request.setMethod('GET');

            Http h = new Http();
            HttpResponse resp = h.send(request);
            System.debug('AD request : '+request.toString());
            System.debug('AD request body: '+request.getBody());
            System.debug('AD response: '+resp.toString());
            System.debug('AD response: '+resp.getHeaderKeys());
            System.debug('AD response.getBody: '+resp.getBody());
            System.debug('AD responseStatusCode: '+resp.getStatusCode());

            if(resp.getStatusCode() <= 299) {

                rw.responseBody = resp.getBody();
                rw.responseHeaderSforceNumberOfRecords = resp.getHeader('Sforce-NumberOfRecords');
                rw.responseHeaderSforceLocator = resp.getHeader('Sforce-Locator');

            }else {
                System.debug('AD response: '+Json.deserializeUntyped(resp.getBody()));

                rw.responseBody = resp.getBody();
            }
        }catch(Exception e){
            System.debug('AD getJobQueryResult Exception : ' + e);

        }

        return new List<ResponseWrapper>{rw};


    }

    public class ResponseWrapper {
        @AuraEnabled
        public String responseBody;
        @AuraEnabled
        public String responseHeaderSforceNumberOfRecords;
        @AuraEnabled
        public String responseHeaderSforceLocator;
    }
}