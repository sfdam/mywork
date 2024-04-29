global class Batch_AssegnazioneAzioniMassiva implements Database.Batchable<sObject>,Database.stateful {
    global List<String> idCmList = new List<String>();
    global String userId = '';
    global String campaignName = '';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Batch_AssegnazioneAzioniMassiva--Start start');
        Database.QueryLocator locator;
       
        locator = Database.getQueryLocator([SELECT Id, CRM_Assegnatario__c, Campaign.Name FROM CampaignMember WHERE id IN :idCmList]);
        
        System.debug('Batch_AssegnazioneAzioniMassiva--End start');
        return locator;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        System.debug('Batch_AssegnazioneAzioniMassiva--Start Execute');
        List<CampaignMember> cmUpdateList = new List<CampaignMember>();
        List<CampaignMember__c> cmgUpdateList = new List<CampaignMember__c>();
        System.debug('scope size: '+scope.size());    
        /*for(Id idCM :idCmList ){
            CampaignMember y = new CampaignMember(Id=idCM, CRM_Assegnatario__c = userId);
            cmUpdateList.add(y);
            
        }*/
        //campaignName = (String)scope[0].Campaign.Name;
        for (sObject r : scope) { 
             CampaignMember cm = (CampaignMember)r;
             cm.CRM_Assegnatario__c = userId;
             cmUpdateList.add(cm);
            
        }
        System.debug('cmgUpdateList : '+cmgUpdateList);
        System.debug('idCmList : '+idCmList);
       
        
        
        if(!cmUpdateList.isEmpty()){
            //OnCampaignMemberTriggerHandler.trafficLightAssegnazioneAzione = true;
            update cmUpdateList;
        }  
        
       /* if(!cmgUpdateList.isEmpty())
            update cmgUpdateList;*/
         System.debug('Batch_AssegnazioneAzioniMassiva--End Execute');      
    }
    global void finish(Database.BatchableContext BC) {
         System.debug('Batch_AssegnazioneAzioniMassiva--Start Finish');
         notifyUsers(true);
         System.debug('Batch_AssegnazioneAzioniMassiva--End Finish');
    }
    
   /* global static void invokeBatch(List<sObject> o, String operationType, String sObjectType) {
        Batch_TriggerOperation bto = new Batch_TriggerOperation();
        bto.sObjList = o;
        bto.operationType = operationType;
        bto.sObjectType = sObjectType;
        Database.executeBatch(bto,200);
    }*/

    public static void notifyUsers(Boolean success) {

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='AssegnazioneMassiva'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Assegnazione Massiva');
        if(success){

            notification.setBody('L\'assegnazione massiva delle campagne da te selezionate risulta completata.');
        }else{

            notification.setBody('Errore durante la riassegnazione delle campagne.');
        }

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetPageRef('{ type: standard__navItemPage,attributes:{apiName: \'Assegna_Azioni\'} }');
        
        // Actually send the notification
        try {
            notification.send(new Set<String>{UserInfo.getUserId()});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
  /*   public static void notifyUsers(String campaignName, Boolean success) {

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='StampaPronta'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Assegnazione Massiva');
        if(success){

            notification.setBody('L\'assegnazione massiva della campagna ' + campaignName +' risulta completata.');
        }else{

            notification.setBody('Errore durante la riassegnazione della campagna: ' + campaignName);
        }

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        //notification.setTargetId(currentAccount.Id);
        
        // Actually send the notification
        try {
            notification.send(new Set<String>{UserInfo.getUserId()});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }*/
}