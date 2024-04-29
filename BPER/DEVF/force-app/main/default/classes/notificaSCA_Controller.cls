public with sharing class notificaSCA_Controller {

    @AuraEnabled(cacheable=true)
    public static String getFieldsAndRecords(String caseId){
        Map<String, String> returnMap = new Map<String,String>();
        try{      
            //get fields from FieldSet
            List<Notifica_SCA__mdt> fields= [SELECT Field_API_Name__c, Field_Label__c, Order__c FROM Notifica_SCA__mdt ORDER BY Order__c];
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> fields : '+fields);
            Map<String,Map<String,Object>> lstFSMember= new Map<String,Map<String,Object>> ();
            for(Notifica_SCA__mdt p: fields){
                Map<String, Object> tempMap = new Map<String,Object>();
                tempMap.put('Name', p.Field_API_Name__c);
                tempMap.put('Label', p.Field_Label__c);
                tempMap.put('Order', p.Order__c);
                lstFSMember.put(p.Field_API_Name__c,tempMap);
            }
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> lstFSMember : '+lstFSMember);
            
            //recupero il case
            Case objVar = getRecord(caseId);
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> objVar : '+objVar);

            //recupero i linkedNDG collegati all'account del case
            List<CRM_LinkedNDG__c> linkedNdgList = [SELECT CRM_RelatedAccount__c, CRM_LinkType__c, CRM_RelatedAccount__r.RecordTypeName__c
                                                    FROM CRM_LinkedNDG__c
                                                    WHERE CRM_Account__c = :objVar.AccountId AND CRM_Status__c = 'A'];
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> linkedNdgList : '+linkedNdgList);
            
            //Lista contenente gli account che servono per la query sui servizi digitali                                      
            List<Id> accForChannelQuery = new List<Id>();
            accForChannelQuery.add(objVar.AccountId);
            //Lista contenente gli account che servono per la seconda query sui linkedNDG   
            List<Id> accForLinkedNdgQuery = new List<Id>();

            for (CRM_LinkedNDG__c linkedNDG : linkedNdgList) {
                if (linkedNDG.CRM_RelatedAccount__r.RecordTypeName__c == 'Cointestazione') {
                    accForLinkedNdgQuery.add(linkedNDG.CRM_Account__c);
                } else {
                    accForChannelQuery.add(linkedNDG.CRM_Account__c);
                }
            }
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> accForChannelQuery : '+accForChannelQuery);
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> accForLinkedNdgQuery : '+accForLinkedNdgQuery);

            List<CRM_LinkedNDG__c> linkedNdgListNew = [SELECT CRM_RelatedAccount__c, CRM_LinkType__c, CRM_RelatedAccount__r.RecordTypeName__c
                                                        FROM CRM_LinkedNDG__c
                                                        WHERE CRM_Account__c IN :accForLinkedNdgQuery AND CRM_RelatedAccount__c != :objVar.AccountId AND CRM_Status__c = 'A'];
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> linkedNdgListNew : '+linkedNdgListNew);
            
            //scandisco i nuovi linked ndg e aggiungo i loro account alla lista accForChannelQuery 
            for (CRM_LinkedNDG__c linkedNDG : linkedNdgListNew) {
                accForChannelQuery.add(linkedNDG.CRM_Account__c);
            }
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> accForChannelQuery : '+accForChannelQuery);
            Boolean hasNoCointestazioneLinkedNdg = !accForChannelQuery.isEmpty();        

            //recupero i servizi digitali "attivi" collegati agli account nella lista accForChannelQuery
            String query = 'SELECT ';
            for( String f : lstFSMember.keySet()) {
                query += lstFSMember.get(f).get('Name') + ', ';
            }
            query += 'Id FROM CRM_Channel__c WHERE CRM_Account__c IN :accForChannelQuery AND CRM_UserCodeStatus__c = \'ATTIVO\'' ;             
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> query : '+query);

            List<SObject> lstRecords = Database.query(query);
            System.debug('notificaSCA_Controller -> getFieldsAndRecords -> lstRecords : '+lstRecords);
            
            returnMap.put('HAS_NO_COINTESTAZIONE_LINKED_NDG', String.valueOf(hasNoCointestazioneLinkedNdg));
            returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
            returnMap.put('RECORD_LIST', JSON.serialize(lstRecords)); 

            //TODO Aggiungere la colonna "tipo di collegamento"
       }
        catch(Exception ex){
            throw new AuraHandledException('Errore nel metodo getFieldsAndRecords: '+ex.getMessage());
        }
        return JSON.serialize(returnMap);      
    }

    @AuraEnabled
    public static Case getRecord(Id recordId){
        List<Case> cs = new List<Case>();
        try{
            cs= [SELECT Id, AccountId, Account.FinServ__BankNumber__c FROM Case WHERE Id = :recordId LIMIT 1];
            System.debug('notificaSCA_Controller -> getRecord -> cs : '+cs);
        }
        catch(Exception ex){
            throw new AuraHandledException('Errore nel metodo getRecord: '+ex.getMessage());
        }
        return cs[0];
    }
}