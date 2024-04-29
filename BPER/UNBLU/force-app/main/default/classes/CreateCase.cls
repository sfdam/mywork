/*
* Author 		 : Akshay Talari(LUTECH)
* Description  :L’input per la DML di Creazione del Case arriva da Softphone.
* CreatedDate  : 10/08/2023  
* 
*/
public class CreateCase {

    
    public static case createCaseFromUnbluChat(Map<String,Object> resultMap){
        Case caso = null;
        String unbluChatId = null;
        try{
            caso = new Case();
            caso.Origin = 'Chat';
            caso.CRM_Source__c = 'Unblu Chat';
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Standard_Case').getRecordTypeId();
            caso.Status = 'Assegnato';
            /*
            if(resultMap.containsKey('codiceFiscalePartitaIva')){
                caso.CRM_CodiceFiscalePartitaIva__c = (String)resultMap.get('codiceFiscalePartitaIva');
            }
            if(resultMap.containsKey('cryptoString')){
                caso.CRM_CryptoString__c = (String)resultMap.get('cryptoString');
            }
            if(resultMap.containsKey('motivoDellaChat')){
                caso.CRM_MotivoDellaChat__c = (String)resultMap.get('motivoDellaChat');
            }
            if(resultMap.containsKey('webChannelEmail')){
                caso.CRM_WebChannelEmail__c = (String)resultMap.get('webChannelEmail');
            }
            if(resultMap.containsKey('webChannelName')){
                caso.CRM_WebChannelName__c = (String)resultMap.get('webChannelName');
            }
            if(resultMap.containsKey('dataDiNascita')){
                caso.Data_di_nascita__c = (String)resultMap.get('dataDiNascita');
            }
            */

            Map < String, Object > conversation = (Map < String, Object >) resultMap.get('conversation');
            Map < String, Object > visitorDataMap = (Map < String, Object >) conversation.get('visitorData');
            
            if ( conversation.containsKey('id')){
                unbluChatId = (String)conversation.get('id');
                caso.CC_Id_Conversationd_Unblu__c = (String)conversation.get('id');
            }
            if ( visitorDataMap != null ){
                if(visitorDataMap.containsKey('CRM_CodiceFiscalePartitaIva__c')){
                    caso.CRM_CodiceFiscalePartitaIva__c = (String)visitorDataMap.get('CRM_CodiceFiscalePartitaIva__c');
                }
                if(visitorDataMap.containsKey('CRM_CryptoString__c')){
                    caso.CRM_CryptoString__c = (String)visitorDataMap.get('CRM_CryptoString__c');
                }
                if(visitorDataMap.containsKey('CRM_MotivoDellaChat__c')){
                    caso.CRM_MotivoDellaChat__c = (String)visitorDataMap.get('CRM_MotivoDellaChat__c');
                }
                if(visitorDataMap.containsKey('CRM_WebChannelEmail__c')){
                    caso.CRM_WebChannelEmail__c = (String)visitorDataMap.get('CRM_WebChannelEmail__c');
                }
                if(visitorDataMap.containsKey('CRM_WebChannelName__c')){
                    caso.CRM_WebChannelName__c = (String)visitorDataMap.get('CRM_WebChannelName__c');
                }
                if(visitorDataMap.containsKey('Data_di_nascita__c')){
                    caso.Data_di_nascita__c = (String)visitorDataMap.get('Data_di_nascita__c');
                }
            }
            

            insert caso;
        }catch(Exception e ){
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'unblu_webhook_created', 'END_WEBHOOK',unbluChatId , JSON.serialize(resultMap) , e.getMessage());
        }
        
        return caso;
        
    }
}