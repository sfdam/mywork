public without sharing class CrmLogGarantePrivacyController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static Map<String, SObject> saveLog(String objectType, String recordId, String dati_accessori){
        System.debug('SV saveLog objectType: ' + objectType);
        System.debug('SV saveLog recordId: ' + recordId);
        System.debug('SV saveLog dati_accessori: ' + dati_accessori);
        String searchedNDG = '%' + recordId + '%';


        Map<String, SObject> result = new Map<String, SObject>();
        Map<String, SObject> cointestazioniMap = new Map<String, SObject>();
        Map<String, SObject> lstOfRecords = new Map<String, SObject>();
        Set<Id> accountIds = new Set<Id>();

        String value = '';

        try{
            DateTime dT = System.now();
            User user = [ SELECT Id, FederationIdentifier FROM User WHERE Id =: UserInfo.getUserId() ];
            String matricola ='U'+user.FederationIdentifier;
            LDAP__c ldap = [SELECT Id, Codice_Controllo_Accessi__c FROM LDAP__c where Matricola__c =: matricola];



            if(objectType == 'Financial Account'){
                FinServ__FinancialAccount__c prod = [ SELECT FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c WHERE Id =: recordId ];
                recordId = prod.FinServ__PrimaryOwner__c;
            }
            else if(objectType == 'Channel'){
                Crm_Channel__c chn = [ SELECT CRM_Account__c FROM Crm_Channel__c WHERE Id =: recordId ];
                recordId = chn.CRM_Account__c;
            }

            Account record = [ SELECT Id, FinServ__BankNumber__c, CRM_NDG__c FROM Account WHERE Id =: recordId ];
            System.debug('SV Account: ' + record);
            accountIds.add(recordId);
            List<CRM_AccountAccountJointOwnershipRelation__c> cointList = [ SELECT Id, CRM_Account__c, CRM_JointOwnership__c
            FROM CRM_AccountAccountJointOwnershipRelation__c 
            WHERE CRM_Account__c =: recordId OR CRM_JointOwnership__c =: recordId ];

            Boolean recordIdIsCointestazione = false;
            for(CRM_AccountAccountJointOwnershipRelation__c el : cointList){
                accountIds.add(el.CRM_JointOwnership__c);
                if(el.CRM_JointOwnership__c == recordId){
                    recordIdIsCointestazione = true;
                }
            }
            
            cointestazioniMap = SV_Utilities.keyBy([ SELECT Id, CRM_Account__c, CRM_JointOwnership__c, CRM_PrimaryNDG__c
                                                FROM CRM_AccountAccountJointOwnershipRelation__c 
                                                WHERE CRM_JointOwnership__c IN : accountIds ], '{CRM_JointOwnership__c}_{CRM_Account__c}', true);
            System.debug('SV cointestazioniMap: ' + cointestazioniMap);

            for(String key : cointestazioniMap.keySet()){
                List<String> keySplit = key.split('_');
                accountIds.add(keySplit[0]);
                accountIds.add(keySplit[1]);
            }

            value = value + record.FinServ__BankNumber__c.rightPad(5); // CODICE ABI BANCA
            String month = dT.month() >= 10 ? String.valueOf(dT.month()) : '0' + String.valueOf(dT.month());
            String day = dt.day() >= 10 ? String.valueOf(dt.day()) : '0' + String.valueOf(dt.day());
            value = value + dT.year() + month +  day; // DATA
            value = value + user.FederationIdentifier.rightPad(7); // MATRICOLA UTENTE
            value = value + 'FZS.'; // VALORE STATICO
            String hour = dT.hourGmt() >= 10 ? String.valueOf(dT.hourGmt()) : '0' + String.valueOf(dT.hourGmt());
            String minutes = dT.minuteGmt() >= 10 ? String.valueOf(dT.minuteGmt()) : '0' + String.valueOf(dT.minuteGmt());
            String seconds = dT.secondGmt() >= 10 ? String.valueOf(dT.secondGmt()) : '0' + String.valueOf(dT.secondGmt());
            String msec = dT.millisecondGmt() >= 100 ? String.valueOf(dT.millisecondGmt()) : dT.millisecondGmt() >= 10 ? '0' + String.valueOf(dT.millisecondGmt()) : '00' + String.valueOf(dT.millisecondGmt());
            value = value + hour + minutes + seconds + msec; // ORA
            value = value + (recordIdIsCointestazione ? '0002' : '0001'); // 
            value = value + ldap.Codice_Controllo_Accessi__c.substring(6,10); // COD FILIALE VS - 11/05/2023 sostituito valore da 0610 a NS0002
            value = value + ldap.Codice_Controllo_Accessi__c.substring(10,15); // COD VS - 11/05/2023 sostituito valore da 00000 a NS0002
            value = value + ldap.Codice_Controllo_Accessi__c.substring(16,19); // COD VS - 11/05/2023 sostituito valore da 000 a NS0002
            value = value + 'CR2CRM2NDG NS00312'; // COD -- VS - 11/05/2023 sostituito valore da NS00312 a NS0002
            
            System.debug('filiale: '+ldap.Codice_Controllo_Accessi__c.substring(6,10));
            System.debug('ufficio: '+ldap.Codice_Controllo_Accessi__c.substring(10,15));
            System.debug('sezione: '+ldap.Codice_Controllo_Accessi__c.substring(16,19));
        
            Integer lengthNDG = 9 - record.CRM_NDG__c.length();
            String valIntermedio = '';
            for(Integer i = 0; i < lengthNDG; i++){
                valIntermedio = valIntermedio + '0';
            }
            String bkNumNDG = record.FinServ__BankNumber__c + valIntermedio + record.CRM_NDG__c;
            value = value + bkNumNDG.rightPad(25); // CONCAT COD BANCA NDG
            value = value + dati_accessori.rightPad(300) + ';'; // dati_accessori
            lstOfRecords = SV_Utilities.keyBy([ SELECT Id, Name, STRINGACSV__c, ConcatAccountId__c, OwnerId  
                                                FROM CRM_LogGarantePrivacy__c 
                                                WHERE OwnerId =: UserInfo.getUserId() ], '{OwnerId}_{ConcatAccountId__c}', true);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            list<CRM_LogGarantePrivacy__c> elements = new List<CRM_LogGarantePrivacy__c>();
            for(String key : lstOfRecords.keySet()){
                if(key.contains(recordId)){
                    elements.add((CRM_LogGarantePrivacy__c)lstOfRecords.get(key));
                }
            }

            String concatAcc = '';
            for(Id val : accountIds){
                concatAcc = concatAcc + val + '_';
            }
            concatAcc = concatAcc.removeEnd('_');

            if(elements.size() <= 0){
                CRM_LogGarantePrivacy__c log = new CRM_LogGarantePrivacy__c();
                log.ConcatAccountId__c = concatAcc;
                log.Name = recordId + '_' + UserInfo.getUserId();
                log.STRINGACSV__c = value;
                elements.add(log);
            } else {
                elements[0].STRINGACSV__c = elements[0].STRINGACSV__c + value;
                elements[0].ConcatAccountId__c = concatAcc;
            }

            upsert elements;

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 


        return cointestazioniMap;
        
    }
}