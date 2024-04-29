/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : CR 76756 controller che si occupa di chiamare la Batch che aggiorna gli account con il campo "PTF_RiportafogliazioneTAG__c" = oldTag
 *                      con il nuovo TAG 'newTag' (executeBatchUpdate) e di controllare lo stato della batch se sta lavorando o meno (getBatchJobStatus e getDateBatchCompleted )
**/

public without sharing class AggiornaMassivamenteTagController {
     

    //AD chiamo la batch : 'Batch_AggiornaMassivamenteTag'
	//che si occupa di aggiornare il vecchio tag 'oldTag' con il nuovo tag 'newTag'
    @AuraEnabled
    public static string executeBatchUpdate(String oldTag,String newTag){

        System.debug('AD AggiornaMassivamenteTag');
        System.debug('AD AggiornaMassivamenteTag newtag ' + newtag);
        System.debug('AD AggiornaMassivamenteTag oldTag ' + oldTag);
        
		String response = '';
        try {

            
            if(oldTag != 'null' && oldTag != ''){
                System.debug('AD AggiornaMassivamenteTag oldTag popolato');
                Batch_AggiornaMassivamenteTag batch = new Batch_AggiornaMassivamenteTag(oldTag,newTag);
                Id batchId = Database.executeBatch(batch,200);
                System.debug('AD AggiornaMassivamenteTag batchId : ' + batchId);
                response=batchId;
            }else{
                response='errore';
            }
            

        } catch (Exception e) {
            System.debug('AD AggiornaMassivamenteTag Exception : ' + e);

            //response=(String)e.getMessage();
            response='errore';
        }
        
        return response;
    }
	
    //AD metodo usato per restituire con variabile booleana il completamento/stato della batch 'Batch_AggiornaMassivamenteTag'
    //true batch completata
    //false batch non completata sta ancora lavorando
    @AuraEnabled
    public static Boolean getBatchJobStatus(){

        Boolean risposta = false; 
        List<AsyncApexJob> statusBatch = new List<AsyncApexJob>();
        try{

            statusBatch = [SELECT Status FROM AsyncApexJob 
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

    //AD prelevo la data della batch che si occupa di aggiornare i dati tag su account 
    //a lato database in modo da avere un punto di riferimento quando viene chiamata la sync
    @AuraEnabled
    public static String getDateBatchCompleted(){

        String risposta = ''; 

        List<AsyncApexJob> completedBatch = new List<AsyncApexJob>();

        try{

            completedBatch = [SELECT Status,CreatedDate FROM AsyncApexJob 
                                WHERE ApexClass.Name = 'Batch_AggiornaMassivamenteTag' 
                                and Status='Completed'
                                order by CreatedDate DESC limit 1];
            if(completedBatch.size()>0){
                Datetime inputDate = Datetime.valueof(completedBatch[0].CreatedDate);
                risposta = inputDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSZ','GMT');
            }else{
                risposta = ''; 
            }

        }catch(Exception e){
            System.debug('AD getDateBatchCompleted Exception : ' + e);

        }

        System.debug('AD getDateBatchCompleted risposta : ' + risposta);

        return risposta;


    }

}