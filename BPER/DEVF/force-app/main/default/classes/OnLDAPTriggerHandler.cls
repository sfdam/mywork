/***
* Name			:	OnLDAPTriggerHandler
* Author		:	Ezio Dal Bo @TEN
* Create Date	:	2021-03-25
* Description	:	Hanlder OnLDAPTriggerHandler event trigger
***/

public class OnLDAPTriggerHandler {
    
    /**
* Name         :   beforeInsert
* Create Date  :   2021-03-25
* Author       :   Ezio Dal Bo @TEN
* Input        :   newRecord (List<LDAP__c>)
* Description  :   Metodo utilizzato per gestire i metodi quando il trigger sull'utente viene invocato in before insert
*/
    public static void beforeInsert(List<LDAP__c> newRecord) {
        for (LDAP__c ldap : newRecord) {
            ldap.Da_Elaborare__c = true;
        }
        calcolaRuolo(newRecord,null,'onInsert');
    }
    
    /**
* Name         :   beforeUpdate
* Create Date  :   2021-03-25
* Author       :   Ezio Dal Bo @TEN
* Input        :   newRecord (List<LDAP__c>), oldRecord(Map<Id,LDAP__c>)
* Description  :   Metodo utilizzato per gestire i metodi quando il trigger sull'utente viene invocato in before update
*/
    public static void beforeUpdate(List<LDAP__c> newRecord, Map<Id,LDAP__c> oldRecord) {
        calcolaRuolo(newRecord,oldRecord,'onUpdate');
    }
    
    
    /**
* Name         :   beforeUpdate
* Create Date  :   2021-03-25
* Author       :   Ezio Dal Bo @TEN
* Input        :   newRecord (List<LDAP__c>), oldRecord(Map<Id,LDAP__c>)
* Description  :   calcola il ruolo fittizio in base a ruolo ldap e idced
*/
    private static void calcolaRuolo(List<LDAP__c> newRecord,Map<Id,LDAP__c> oldRecord,String operation) {
        Map<String,sObject> mRuoloBPER = MetadataUtility.getAllByMetadataName('Ruolo_BPER__mdt');
        
        if ('onInsert'.equals(operation)) {
            for (LDAP__c ldap : newRecord) {
                if (ldap.Attivo__c) {
                    if (String.isBlank(ldap.IDCed__c) || String.isBlank(ldap.Ruolo_LDAP__c)) {
                        ldap.Ruolo_LDAP_Calcolato__c = null;
                    }
                    else if (mRuoloBPER.containsKey('X'+ldap.Ruolo_LDAP__c+'_'+ldap.IDCed__c)) {
                        Ruolo_BPER__mdt ruoloBPER = (Ruolo_BPER__mdt)mRuoloBPER.get('X'+ldap.Ruolo_LDAP__c+'_'+ldap.IDCed__c);
                        ldap.Ruolo_LDAP_Calcolato__c = ruoloBPER.Ruolo_LDAP_Calcolato__c;
                    }
                    else if (mRuoloBPER.containsKey('X'+ldap.Ruolo_LDAP__c)) {
                        Ruolo_BPER__mdt ruoloBPER = (Ruolo_BPER__mdt)mRuoloBPER.get('X'+ldap.Ruolo_LDAP__c);
                        List<String> idceds = ruoloBPER.IDCed__c.split(';');
                        Set<String> sIdceds = new Set<String>(idceds);
                        if (!sIdceds.contains(ldap.IDCed__c)) {
                            ldap.Ruolo_LDAP_Calcolato__c=ruoloBPER.Ruolo_LDAP_Calcolato__c;
                        }
                    }
                }
            }
        }
        else if ('onUpdate'.equals(operation)) {
            for (LDAP__c ldap : newRecord) {
                LDAP__c oldLDAP = oldRecord.get(ldap.Id);
                if (ldap.Attivo__c) {
                    if (
                        (ldap.IDCed__c!=oldLDAP.IDCed__c && String.isBlank(ldap.IDCed__c)) ||
                        (ldap.Ruolo_LDAP__c!=oldLDAP.Ruolo_LDAP__c && String.isBlank(ldap.Ruolo_LDAP__c))
                    ) 
                    {
                        ldap.Ruolo_LDAP_Calcolato__c = null;
                        ldap.Da_Elaborare__c = true;
                    }
                    else if (mRuoloBPER.containsKey('X'+ldap.Ruolo_LDAP__c+'_'+ldap.IDCed__c)) {
                        Ruolo_BPER__mdt ruoloBPER = (Ruolo_BPER__mdt)mRuoloBPER.get('X'+ldap.Ruolo_LDAP__c+'_'+ldap.IDCed__c);
                        ldap.Ruolo_LDAP_Calcolato__c = ruoloBPER.Ruolo_LDAP_Calcolato__c;
                        if (oldLDAP.Ruolo_LDAP_Calcolato__c!=ruoloBPER.Ruolo_LDAP_Calcolato__c) {
                            ldap.Da_Elaborare__c = true;
                        }
                    }
                    else if (mRuoloBPER.containsKey('X'+ldap.Ruolo_LDAP__c)) {
                        Ruolo_BPER__mdt ruoloBPER = (Ruolo_BPER__mdt)mRuoloBPER.get('X'+ldap.Ruolo_LDAP__c);
                        List<String> idceds = ruoloBPER.IDCed__c.split(';');
                        Set<String> sIdceds = new Set<String>(idceds);
                        if (!sIdceds.contains(ldap.IDCed__c)) {
                            ldap.Ruolo_LDAP_Calcolato__c = ruoloBPER.Ruolo_LDAP_Calcolato__c;
                        }
                        if (ldap.Ruolo_LDAP_Calcolato__c!=oldLDAP.Ruolo_LDAP_Calcolato__c) {
                            ldap.Da_Elaborare__c = true;
                        }
                    }
                    else if (ldap.Ruolo_LDAP_Calcolato__c!=oldLDAP.Ruolo_LDAP_Calcolato__c) {
                        ldap.Da_Elaborare__c = true;
                    }
                }
                else if(ldap.Attivo__c!=oldLDAP.Attivo__c){
                    ldap.Da_Elaborare__c = true;
                }
            }
        }
    }
}