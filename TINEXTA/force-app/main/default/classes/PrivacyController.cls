public without sharing class PrivacyController {

    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static Map<String, SObject> getData(String contactId){
        System.debug('SV getAllData contactId: ' + contactId);

        Map<String, SObject> mtdSocietMap = new Map<String, SObject>();

        try { 

            mtdSocietMap = Utilities.keyBy([ SELECT Id, Label, NomeCompleto__c, Identificativo__c, State__c, 
                                                    City__c, Street__c, PIVA__c, Email__c 
                                             FROM Informazioni_Societa__mdt ], 'Identificativo__c', false);


        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 


        return mtdSocietMap;
    }

    @AuraEnabled
    public static Boolean savePrivacy(String contactId, Boolean privacy1, Boolean privacy2, String tipoPrivacy){
        System.debug('SV savePrivacy contactId: ' + contactId);
        System.debug('SV savePrivacy privacy1: ' + privacy1);
        System.debug('SV savePrivacy privacy2: ' + privacy2);
        System.debug('SV savePrivacy tipoPrivacy: ' + tipoPrivacy);

        Map<String, SObject> contactMap = new Map<String, SObject>();
        Map<String, SObject> accountMap = new Map<String, SObject>();
        // Set<Id> accIds = new Set<Id>();

        try { 

            Id recordId = (Id) contactId;
            if(recordId.getSObjectType().getDescribe().getName() == 'Contact'){
                contactMap = Utilities.keyBy([ SELECT Id, AccountId, Contitolarita_dati_TXT__c,
                                                Consenso_marketing_contitolari_TXT__c, Consenso_marketing_terzi_TXT__c,
                                                Data_Consenso_marketing_contitolari_TXT__c, Data_Consenso_marketing_terzi_TXT__c,
                                                RecordType.DeveloperName
                                            FROM Contact
                                            WHERE Id =: contactId ], 'Id', false);
                
                System.debug('SV contactMap: ' + contactMap);

                String oldPrivacy1;
                String oldPrivacy2;
                for(String key : contactMap.keySet()){
                    if(tipoPrivacy == '1'){
                        //OLD
                        // oldPrivacy1 = (String)contactMap.get(key).put('Consenso_marketing_contitolari_TXT__c', privacy1 ? 'SI' : 'NO');
                        // oldPrivacy2 = (String)contactMap.get(key).put('Consenso_marketing_terzi_TXT__c', privacy1  ? 'SI' : (privacy2 ? 'SI' : 'NO'));
                        
                        //NEW2
                        // if((String)contactMap.get(key).get('RecordType.DeveloperName') == 'Innolva'){
                        //     oldPrivacy1 = (String)contactMap.get(key).put('Consenso_marketing_contitolari_TXT__c', privacy1 ? 'SI' : 'NO');
                        //     oldPrivacy2 = (String)contactMap.get(key).put('Consenso_marketing_terzi_TXT__c', privacy2 ? 'SI' : 'NO');
                        // } else {
                        //     oldPrivacy1 = (String)contactMap.get(key).put('Consenso_marketing_contitolari_TXT__c', privacy2 ? 'SI' : privacy1 ? 'SI' : 'NO');
                        //     oldPrivacy2 = (String)contactMap.get(key).put('Consenso_marketing_terzi_TXT__c', privacy2 ? 'SI' : 'NO');
                        // }

                        //NEW1
                        oldPrivacy1 = (String)contactMap.get(key).put('Consenso_marketing_contitolari_TXT__c', privacy1 ? 'SI' : 'NO');
                        oldPrivacy2 = (String)contactMap.get(key).put('Consenso_marketing_terzi_TXT__c', privacy2 ? 'SI' : 'NO');

                        contactMap.get(key).put('Data_Consenso_marketing_contitolari_TXT__c', Date.today());
                        contactMap.get(key).put('Data_Consenso_marketing_terzi_TXT__c',  Date.today());
                    }
                    //if(tipoPrivacy == '2') accIds.add((Id)contactMap.get(key).get('AccountId'));
                    contactMap.get(key).put('Contitolarita_dati_TXT__c', 'SI');
                    // accIds.add((Id)contactMap.get(key).get('AccountId'));
                }

                update contactMap.values();
                System.debug('SV oldPrivacy1: ' + oldPrivacy1);
                System.debug('SV newPrivacy1: ' + privacy1);
                System.debug('SV oldPrivacy2: ' + oldPrivacy2);
                System.debug('SV newPrivacy2: ' + privacy2);

                // SM - RIMOZIONE LOGICA SU ACCOUNT, LA PRIVACY VIENE GESTITA SUI SINGOLI CONTATTI
                // if(accIds.size() > 0){
                //     accountMap = Utilities.keyBy([ SELECT Id, Contitolarita_dati_TXT__c, Data_Contitolarita_dati_TXT__c
                //                             FROM Account
                //                             WHERE Id IN : accIds ], 'Id', false);

                //     System.debug('SV accountMap: ' + accountMap);
                //     // if(tipoPrivacy == '2'){
                //         for(String key : accountMap.keySet()){
                //             accountMap.get(key).put('Contitolarita_dati_TXT__c', 'SI');
                //             accountMap.get(key).put('Data_Contitolarita_dati_TXT__c',  Date.today());
                //         }
                //     // }

                //     update accountMap.values();
                // }
            } else if(recordId.getSObjectType().getDescribe().getName() == 'Lead'){

                Lead l = [SELECT Id, Name, Consenso_marketing_contitolari_TXT__c,Consenso_marketing_terzi_TXT__c, Data_Consenso_marketing_contitolari_TXT__c, 
                                Data_Consenso_marketing_terzi_TXT__c, Contitolarita_dati_TXT__c, Data_Contitolarita_dati_TXT__c, RecordType.DeveloperName FROM Lead WHERE Id=:contactId];

                if(tipoPrivacy == '1'){
                    //OLD
                    // l.Consenso_marketing_contitolari_TXT__c = privacy1 ? 'SI' : 'NO';
                    // l.Consenso_marketing_terzi_TXT__c = privacy1 ? 'SI' : (privacy2 ? 'SI' : 'NO');

                    //NEW2
                    l.Consenso_marketing_contitolari_TXT__c = privacy1 ? 'SI' : 'NO';
                    l.Consenso_marketing_terzi_TXT__c = privacy2 ? 'SI' : 'NO';

                    //NEW1
                    // l.Consenso_marketing_contitolari_TXT__c = privacy2 ? 'SI' : (privacy1 ? 'SI' : 'NO');
                    // l.Consenso_marketing_terzi_TXT__c = privacy2 ? 'SI' : 'NO';

                    l.Data_Consenso_marketing_contitolari_TXT__c = Date.today();
                    l.Data_Consenso_marketing_terzi_TXT__c = Date.today();
                }
                l.Contitolarita_dati_TXT__c = 'SI';
                l.Data_Contitolarita_dati_TXT__c = Date.today();

                update l;
            }

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);
            return false;

        } 

        return true;
    }

    // @AuraEnabled
    // public static Boolean sendRecapEmail(Id recId, String codiceAzienda, String linkPagina){
    //     Boolean success = true;
    //     try {
    //         Id recordId = (Id) recId;
    //         SObject record;
    //         String email;
    //         String consensoMarketingContitolari;
    //         String consensoMarketingTerzi;
    //         if(recordId.getSobjectType().getDescribe().getName() == 'Contact') {
    //             record = [SELECT Id, Name, Email, Consenso_marketing_contitolari_TXT__c, Consenso_marketing_terzi_TXT__c FROM Contact WHERE Id =: recordId];
    //             email = (String)record.get('Email');
    //             consensoMarketingContitolari = (String) record.get('Consenso_marketing_contitolari_TXT__c');
    //             consensoMarketingTerzi = (String) record.get('Consenso_marketing_terzi_TXT__c');
    //         } else if(recordId.getSobjectType().getDescribe().getName() == 'Lead') {
    //             record = [SELECT Id, Name, Email, Consenso_marketing_contitolari_TXT__c, Consenso_marketing_terzi_TXT__c FROM Lead WHERE Id =: recordId];
    //             email = (String)record.get('Email');
    //             consensoMarketingContitolari = (String) record.get('Consenso_marketing_contitolari_TXT__c');
    //             consensoMarketingTerzi = (String) record.get('Consenso_marketing_terzi_TXT__c');
    //         }

    //         Map<String, SObject> meta = getData(null);
    //         String nomeAzienda = (String)meta.get(codiceAzienda).get('NomeCompleto__c');
    //         DateTime o = System.now();
    //         String strDate = o.format('dd/MM/yyyy');

    //         Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
    //         em.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: nomeAzienda].Id);
    //         em.setToAddresses(new List<String>{email});
    //         em.setSubject(nomeAzienda+': riepilogo consensi informativa di Contitolarità');
    //         String bodyEmail = 'Gentile Interessato, \n\r \n\r '+
    //         'Il procedimento è andato a buon fine, La ringraziamo per la disponibilità. \n\r ' +
    //         'Di seguito le espressioni di consenso registrate: \n\r \n\r ' +
    //         'Contitolarità dei dati: SI \n\r ' + 
    //         'Data - Contitolarità dei dati: ' + strDate + ' \n\r \n\r ' + 
    //         'Consenso Marketing Contitolari: '+ consensoMarketingContitolari +' \n\r ' + 
    //         'Data - Consenso Marketing Contitolari: ' + strDate + ' \n\r \n\r ' +
    //         'Consenso Marketing Gruppo: '+consensoMarketingTerzi+' \n\r ' +
    //         'Data - Consenso Marketing Gruppo: ' + strDate + ' \n\r \n\r ' +
    //         'Se vuole conservare l\'informativa ricevuta, può fare riferimento al seguente collegamento: \n\r \n\r '+
    //         'Link: '+linkPagina+' \n\r \n\r ' +
    //         'La ringraziamo nuovamente per l\'attenzione e La salutiamo cordialmente.';
    //         em.setPlainTextBody(bodyEmail);

    //         Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{em});
    //     } catch (Exception e) {
    //         System.debug('@@@ exception ' + e.getStackTraceString());
    //         success = false;
    //     }

    //     return success;
    // }
}