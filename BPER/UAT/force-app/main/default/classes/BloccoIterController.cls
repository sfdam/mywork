public class BloccoIterController {
    
    @AuraEnabled
    public static Map<String,sObject> getStrutturaBanca(){
        return   SV_Utilities.keyBy([ SELECT IDCed__c, Nome_Livello__c FROM Struttura_Banca__c], 'IDCed__c', false);
    }

    @AuraEnabled
    public static string getAccountId(String idCed ){
        return [SELECT Id, Name  FROM Account WHERE PTF_IdCED__c =: idCed LIMIT 1 ].Id;
    }

    @AuraEnabled
    public static void blockIterUO(Account uo, String recTypeName, String note){
        
        String campoUO = recTypeName == 'Filiale di relazione' ? 'PTF_Filiale__c':
        recTypeName == 'Area' ? 'PTF_Area__c':
        recTypeName == 'Direzione Territoriale' ? 'PTF_DirezioneRegionale__c': 'PTF_Banca__c';
        
        String query = 'SELECT Id, PTF_BloccoSpostamenti__c FROM Account WHERE PTF_BloccoSpostamenti__c = false AND PTF_Portafoglio__c != null '; 
        if(String.isBlank(uo.PTF_Capofila__c) && recTypeName == 'Filiale di relazione'){
            query += ' AND (' + campoUO + '= \'' + uo.Id + '\' OR PTF_Filiale__r.PTF_Capofila__c = \'' + uo.Id + '\')'; 
        }else{
            query += ' AND ' + campoUO + '= \'' + uo.Id + '\''; 
        }

        System.debug('DK query: ' + query);
        Batch_ExecuteCRUD batchCRUD = new Batch_ExecuteCRUD();
        batchCRUD.operation = 'update';
        batchCRUD.query = query;
        batchCRUD.fieldValueUpdate = new Map<String,Object>{'PTF_BloccoSpostamenti__c' => true, 'PTF_NoteBloccoSpostamenti__c' => note};
        Database.executeBatch(batchCRUD, 200);
    }

    @AuraEnabled
    public static void updateNDGs(List<String> ndgBancaList, String note){
        String query = 'SELECT Id, PTF_BloccoSpostamenti__c FROM Account WHERE PTF_BloccoSpostamenti__c = false AND PTF_Portafoglio__c != null AND NDW_ExternalId__c IN: ndgBancaList'; 
        System.debug('Dk query: ' + query);

        Batch_ExecuteCRUD batchCRUD = new Batch_ExecuteCRUD();
        batchCRUD.operation = 'update';
        batchCRUD.query = query;
        batchCRUD.ndgBancaList = ndgBancaList;
        batchCRUD.fieldValueUpdate = new Map<String,Object>{'PTF_BloccoSpostamenti__c' => true, 'PTF_NoteBloccoSpostamenti__c' => note};
        Database.executeBatch(batchCRUD, 200);
    }

    public static void notifyUsers(String uoName, String recTypeName, Boolean success) {

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='BloccoIterCompletato'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Blocco Iter');
        if(success){
            if(uoName != null && recTypeName != null){
                notification.setBody('Blocco di Iter per NDG legati alla unità organizzativa ' + uoName + '(' + recTypeName + ') completato con successo.');
            }else{
                notification.setBody('Blocco di Iter per NDG indicati completato con successo.');
            }
        }else{
            if(uoName != null && recTypeName != null){
                notification.setBody('Errore durante il blocco degli iter per NDG legati alla unità organizzativa ' + uoName + '(' + recTypeName + '). Contattare l\'amministratore di sistema.');
            }else{
                notification.setBody('Errore durante il blocco degli iter per NDG indicati. Contattare l\'amministratore di sistema.');
            }
        }

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(UserInfo.getUserId());
        
        // Actually send the notification
        try {
            notification.send(new Set<String>{UserInfo.getUserId()});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}