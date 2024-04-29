global class sganciaReferentePTF_Batch implements Database.Batchable<sObject>,Database.stateful {

    global List<String> listAssignmentToClose{get;set;}
    global String nomeReferente{get;set;}
    global String idReferente{get;set;}
    global Database.QueryLocator  start(Database.BatchableContext BC) {
        

        String query = 'SELECT Id, PTF_EndDate__c From Assignment__c WHERE Id in: listAssignmentToClose';
      
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Assignment__c> scope) {

          for(Assignment__c ass : scope){
              ass.PTF_EndDate__c = Date.today();
          }
          update scope;
    }

    
    global void finish(Database.BatchableContext BC) {
        notifyUsers(nomeReferente, idReferente, true);
    }

    global static void notifyUsers(String nomeReferente, String idReferente, Boolean success) {

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
            FROM CustomNotificationType 
            WHERE DeveloperName='OperationCompleted'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        notification.setTitle('Sgancio Referente');
        if(success){

            notification.setBody('Lo sgancio del referente ' + nomeReferente + ' è stato completato con successo.');
        }else{

            notification.setBody('Errore durante Lo sgancio del referente ' + nomeReferente + '. Contattare il proprio amministratore');
        }

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(idReferente);
        
        // Actually send the notification
        try {
            notification.send(new Set<String>{UserInfo.getUserId()});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}