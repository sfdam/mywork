public with sharing class OnContentDocumentTriggerHandler {

    public static void makeCallContentDocument(List<ContentDocument> contentDocumentList){
        System.debug('SV contentDocumentList: ' + contentDocumentList);
        List<Id> cdIdList = new List<Id>();
        for(ContentDocument cd : contentDocumentList){
            cdIdList.add(cd.Id);
        }

        Map<String,sObject> contentVersionMap = Utilities.keyBy([ SELECT Id, ContentDocumentId FROM ContentVersion  WHERE ContentDocumentId IN : cdIdList ], 'ContentDocumentId');
        Map<String,sObject> contentDocumentLinkMap = Utilities.keyBy([ SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN : cdIdList ], '{Id}_{ContentDocumentId}_{LinkedEntityId}', true);
        System.debug('SV contentVersionMap: ' + contentVersionMap);
        System.debug('SV contentDocumentLinkMap: ' + contentDocumentLinkMap);

        List<Id> oppIdList = new List<Id>();
        for(String key : contentDocumentLinkMap.keySet()){
            List<String> keySplit = key.split('_');
            if(keySplit[2].startsWith('006')){
                oppIdList.add(keySplit[2]);
            }
        }

        Map<String,sObject> oppMap = Utilities.keyBy([ SELECT Id, RecordTypeId, Probability FROM Opportunity  WHERE Id IN : oppIdList ], 'Id');
        System.debug('SV oppMap: ' + oppMap);

        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById();
        System.debug('SV rtMap: ' + rtMap);

        Set<String> oppIdFinalList = new Set<String>();
        for(ContentDocument cd : contentDocumentList){
            System.debug('SV ContentDocument: ' + cd);
            System.debug('SV contentVersionMap : ' + contentVersionMap.get(cd.Id));
            if(contentVersionMap.get(cd.Id) != null){
                for(String key : contentDocumentLinkMap.keySet()){
                    List<String> keySplit = key.split('_');
                    if(keySplit[1] == cd.Id && keySplit[2].startsWith('006')){
                        if(rtMap.get((String)oppMap.get(keySplit[2]).get('RecordTypeId')).getDeveloperName() == 'Warrant' && ((Decimal)oppMap.get(keySplit[2]).get('Probability') >= 50 || (Decimal)oppMap.get(keySplit[2]).get('Probability') == 0)){
                            oppIdFinalList.add(keySplit[2]);
                        }
                    }
                }
            }
        }

        System.debug('SV oppIdList: ' + oppIdFinalList);
        if(oppIdFinalList.size()>0) WRT_IntegrazioneController.opportunityIntegration(oppIdFinalList);


    }

}