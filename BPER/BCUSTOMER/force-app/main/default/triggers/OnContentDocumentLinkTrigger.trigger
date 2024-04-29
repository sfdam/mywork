trigger OnContentDocumentLinkTrigger on ContentDocumentLink (before insert) {   
    if(OnContentDocumentLinkTriggerHandler.semaforoStampaPDF) return;

    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV ContentDocumentLink INSERT trigger.isBefore');
            OnContentDocumentLinkTriggerHandler.checkUploadFilePermission(Trigger.new);
        }
        
        if(trigger.isAfter){
            System.debug('SV ContentDocumentLink INSERT trigger.isAfter');
        }
    }
}