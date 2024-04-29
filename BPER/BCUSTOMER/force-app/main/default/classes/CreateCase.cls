/*
* Author         : Akshay Talari(LUTECH)
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
            caso.CRM_CasefromNewPrechatForm__c = 'SI';
            
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
                    String dateString = (String)visitorDataMap.get('Data_di_nascita__c');
                    //Lutech AT 9/11/2023 Trasformare valore da "AAAA/MM/GG" in "GG/MM/AAAA". Questo se e solo se, il campo "CC_Id_Conversationd_Unblu__c" non è vuoto AND Origin = 'Chat.
                    if(dateString.contains('-') && unbluChatId != null){
                        String[] datestrList = dateString.split('-');
                        if(datestrList.size()==3){
                            system.debug(datestrList.size());
                            if(datestrList[0].length() >2){
                                Date datetemp =  Date.newInstance(Integer.valueOf(datestrList[0]),Integer.valueOf(datestrList[1]),Integer.valueOf(datestrList[2]));// datestrList[2]+'/'+datestrList[1]+'/'+datestrList[0];
                                system.debug(datetemp.format());
                                dateString = datetemp.format();
                            }
                        }
                    }
                    caso.Data_di_nascita__c = dateString;
                }
                if(visitorDataMap.containsKey('CC_UnbluDevice__c')){
                    caso.CC_UnbluDevice__c = (String)visitorDataMap.get('CC_UnbluDevice__c');
                }
                if(visitorDataMap.containsKey('CC_UnbluBrowser__c')){
                    caso.CC_UnbluBrowser__c = (String)visitorDataMap.get('CC_UnbluBrowser__c');
                }
                if(visitorDataMap.containsKey('CC_UnbluUrl__c')){
                    caso.CC_UnbluUrl__c = (String)visitorDataMap.get('CC_UnbluUrl__c');
                }
            }
            

            insert caso;
        }catch(Exception e ){
            system.debug('exception '+e);
            softphone_it.ConnectorOutboundSoftphoneLogs.insertLogWsRequest('ERROR', 'unblu_webhook_created', 'END_WEBHOOK',unbluChatId , JSON.serialize(resultMap) , e.getMessage());
        }
        
        return caso;
        
    }
}