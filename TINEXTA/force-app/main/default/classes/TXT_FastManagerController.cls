public without sharing class TXT_FastManagerController {

    @AuraEnabled(cacheable = true)
    public static WrapperObj getDataList(String pIva, String cFiscale, String societa, String tipoRicerca){
        System.debug('SV pIva: ' + pIva);
        System.debug('SV cFiscale: ' + cFiscale);
        System.debug('SV tipoRicerca: ' + tipoRicerca);
        System.debug('SV societa: ' + societa);

        
        WrapperObj response = new WrapperObj();

        try{

            String sQuery = 'SELECT Id, Name, Codice_fiscale__c, Partita_iva__c, Stato__c, Opportunit_Aperte__c, Opportunit_Chiuse__c, Codice_Unico_Tinexta__c, Valore_Opportunit_Aperte__c'  + ' FROM Account';
            if(cFiscale == null || cFiscale == ''){
                sQuery = sQuery + ' WHERE Partita_iva__c LIKE \'' + pIva + '%\'';
            } else if(pIva == null || pIva == ''){
                sQuery = sQuery + ' WHERE Codice_fiscale__c LIKE \'' + cFiscale + '%\'';
            } else {
                sQuery = sQuery + ' WHERE Codice_fiscale__c LIKE \'' + cFiscale + '%\' AND Partita_iva__c LIKE \'' + pIva + '%\'';
            }

            //se utente innolva solo account con inn_società innolva
            user us = getUserInfo();

            if(us.Societa__c == 'Innolva')
            {
                sQuery = sQuery + ' and INN_Societa__c != null';
            }
            if(us.Societa__c == 'ReValuta')
            {
                sQuery = sQuery + ' and REV_societa__c != null';
            }
            else
            {
                sQuery = sQuery + ' and ((INN_Societa__c = null OR (Societa_su_CTM__c != null and INN_Societa__c != null)) and (REV_societa__c = null OR (Societa_su_CTM__c != null and REV_societa__c != null)))';
            }

            // if(tipoRicerca == 'singola societa'){
            //sQuery = sQuery + ' AND Societa_di_riferimento__c = \'' + societa + '\'';
            // }            
                
                sQuery = sQuery + ' ORDER BY createdDate DESC';
            System.debug('SV sQuery: ' + sQuery);
            List < sObject > lstOfRecords = Database.query(sQuery);
            System.debug('SV lstOfRecords: ' + lstOfRecords);

            Set<Id> accIdSet = new Set<Id>();
            for(SObject acc : lstOfRecords){
                accIdSet.add((Id)acc.get('Id'));
            }
            //filtro per la visibilità del ctm, opp, task ed eventi per utenti innolva
            boolean tinexta = true;
            SObject[] querylist = new SObject[]{};
            if(us.Societa__c == 'Innolva' /*|| us.societa__c == 'Revaluta'*/)
            {
                tinexta = false;
                querylist = [ SELECT AccountId,RecordType.DeveloperName,isClosed,isWon,count(Id),SUM(amount)
                                FROM Opportunity  
                                WHERE  AccountId IN : accIdSet 
                                AND RecordType.Name = 'Innolva'
                                GROUP BY AccountId,RecordType.DeveloperName,isClosed,isWon ];
            }
            if(us.Societa__c == 'ReValuta' /*|| us.societa__c == 'Revaluta'*/)
            {
                tinexta = false;
                querylist = [ SELECT AccountId,RecordType.DeveloperName,isClosed,isWon,count(Id),SUM(amount)
                                FROM Opportunity  
                                WHERE  AccountId IN : accIdSet 
                                AND RecordType.Name = 'ReValuta'
                                GROUP BY AccountId,RecordType.DeveloperName,isClosed,isWon ];
            }
            else
            {
                querylist = [ SELECT AccountId,RecordType.DeveloperName,isClosed,isWon,count(Id),SUM(amount)
                                FROM Opportunity  
                                WHERE  AccountId IN : accIdSet 
                                AND RecordType.Name != 'Innolva'
                                AND RecordType.Name != 'ReValuta'
                                GROUP BY AccountId,RecordType.DeveloperName,isClosed,isWon ];
            }
            
            Map<String, List<SObject>> ctmMap  = Utilities.groupBy([ SELECT Id,Name, Account__c, Ruolo_Coverage_Team__c, Societa__c, User__r.Name
                                                            FROM Coverage_Team_Member__c 
                                                            WHERE Account__c IN : accIdSet
                                                                AND Ruolo_Coverage_Team__c = 'Responsabile account' 
                                                                AND Tinexta__c = :tinexta], '{Account__c}_{Id}', true);
            
            response.ctmMap = ctmMap;
            
            Map<String, SObject> oppToAccMap = Utilities.keyBy(querylist, '{AccountId}.{DeveloperName}.{isClosed}.{isWon}', true);
                        
            response.oppToAccMap = oppToAccMap;
            
            Map<String, SObject> taskToAccMap = Utilities.keyBy([ SELECT COUNT(Id), AccountId
                                                                FROM Task
                                                                WHERE AccountId IN : accIdSet
                                                                AND Tinexta__c = :tinexta
                                                                GROUP BY AccountId ], '{AccountId}', true);
            
            response.taskToAccMap = taskToAccMap;

            Map<String, SObject> eventToAccMap = Utilities.keyBy([ SELECT COUNT(Id), AccountId
                                                                FROM Event
                                                                WHERE AccountId IN : accIdSet
                                                                AND Tinexta__c = :tinexta
                                                                GROUP BY AccountId ], '{AccountId}', true);
            
            response.eventToAccMap = eventToAccMap;

            Map<String, SObject> futureTaskToAccMap = Utilities.keyBy([ SELECT COUNT(Id), AccountId
                                                                FROM Task
                                                                WHERE AccountId IN : accIdSet
                                                                    AND ActivityDate >= TODAY
                                                                    AND Tinexta__c = :tinexta
                                                                GROUP BY AccountId ], '{AccountId}', true);
            
            response.futureTaskToAccMap = futureTaskToAccMap;

            Map<String, SObject> futureEventToAccMap = Utilities.keyBy([ SELECT COUNT(Id), AccountId
                                                                FROM Event
                                                                WHERE AccountId IN : accIdSet
                                                                    AND ActivityDate >= TODAY
                                                                    AND Tinexta__c = :tinexta
                                                                GROUP BY AccountId ], '{AccountId}', true);
            
            response.futureEventToAccMap = futureEventToAccMap;


    ////////////////////////////////////////////////////////////////////////////////////////////////////////
                // Map<String, SObject> OpportunityData= [SELECT id(oppID), Account_Owner__c,OpportunityNumber__c,Name,AccountId,Ammontare_pesato__c,Ammontare_non_scontato__c,Account_Rating__c,Stato_Approvazione_rating__c,RecordTypeId,StageName,Probability,CloseDate,TXT_ForecastCategory__c,Prodotto__c,Note__c,Competitor__c
                //                         FROM Opportunity
                //                         where Accouunt IN :accIdSet];

                // response.OpportunityData = OpportunityData;


                // Map<String, SObject> ContactData= [SELECT id(contactID),Name,OwnerId,AccountId,Area__c,WRT_Ruolo__c,INN_Contatto_Preferito__c,Phone,MobilePhone,Email,Email_2__c,Email_3__c,Emailaziendale_RV__c,Societa__c,Title
                // FROM Opportunity
                // where Accouunt IN :accIdSet];

                // response.ContactData = ContactData;



            



            String sQueryLead = 'SELECT Id, Name, Codice_fiscale__c, Partiva_iva__c, Owner.Name' + ' FROM Lead';
            if(cFiscale == null || cFiscale == ''){
                sQueryLead = sQueryLead + ' WHERE Partiva_iva__c LIKE \'' + pIva + '%\'' + ' AND isConverted = FALSE';
            } else if(pIva == null || pIva == ''){
                sQueryLead = sQueryLead + ' WHERE Codice_fiscale__c LIKE \'' + cFiscale + '%\'' + ' AND isConverted = FALSE';
            } else {
                sQueryLead = sQueryLead + ' WHERE Codice_fiscale__c LIKE \'' + cFiscale + '%\' AND Partiva_iva__c LIKE \'' + pIva + '%\'' + ' AND isConverted = FALSE';
            }

            //SM - Chiusa visibilità sui lead
            //if(tipoRicerca == 'singola societa'){
                sQueryLead = sQueryLead + ' AND RecordType.DeveloperName = \'' + societa + '\'';
            //}
                
                sQueryLead = sQueryLead + ' ORDER BY createdDate DESC';
            System.debug('SV sQueryLead: ' + sQueryLead);
            List < sObject > lstLeadOfRecords = Database.query(sQueryLead);
            System.debug('SV lstLeadOfRecords: ' + lstLeadOfRecords);

            Set<Id> leadIdSet = new Set<Id>();
            for(SObject lead : lstLeadOfRecords){
                leadIdSet.add((Id)lead.get('Id'));
            }

            Map<String, SObject> taskToLeadMap = Utilities.keyBy([ SELECT COUNT(Id), Lead__c
                                                                FROM Task
                                                                WHERE Lead__c IN : leadIdSet
                                                                GROUP BY Lead__c ], '{Lead__c}', true);
            
            response.taskToLeadMap = taskToLeadMap;

            Map<String, SObject> eventToLeadMap = Utilities.keyBy([ SELECT COUNT(Id), Lead__c
                                                                FROM Event
                                                                WHERE Lead__c IN : leadIdSet
                                                                GROUP BY Lead__c ], '{Lead__c}', true);
            
            response.eventToLeadMap = eventToLeadMap;

            Map<String, SObject> futureTaskToLeadMap = Utilities.keyBy([ SELECT COUNT(Id), Lead__c
                                                                FROM Task
                                                                WHERE Lead__c IN : leadIdSet
                                                                    AND ActivityDate >= TODAY
                                                                GROUP BY Lead__c ], '{Lead__c}', true);
            
            response.futureTaskToLeadMap = futureTaskToLeadMap;

            Map<String, SObject> futureEventToLeadMap = Utilities.keyBy([ SELECT COUNT(Id), Lead__c
                                                                FROM Event
                                                                WHERE Lead__c IN : leadIdSet
                                                                    AND ActivityDate >= TODAY
                                                                GROUP BY Lead__c ], '{Lead__c}', true);
            
            response.futureEventToLeadMap = futureEventToLeadMap;


            List<Sobject> CombinedItems = new List<Sobject>();
            CombinedItems.addAll(lstOfRecords);
            CombinedItems.addAll(lstLeadOfRecords);

            response.CombinedItems = CombinedItems;






        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());       
        }

        return response;
    }

    @AuraEnabled
	public static Task createNewTask(sObject user, String what_id, String sobjectName, String title, String note){
        System.debug('SV user: ' + user);
        System.debug('SV what_id: ' + what_id);
        System.debug('SV sobjectName: ' + sobjectName);
        System.debug('SV title: ' + title);
        System.debug('SV note: ' + note);
        
        String assegnatario = TXT_FastManager_User__c.getInstance().Richiesta_Approvatore__c;

        Task t = new Task();

        try{
            t.subject = 'Richiesta Assegnazione ' + sobjectName + ' - ' + user.get('Name');
            
            t.Description = note;
            t.ActivityDate = Date.today();

            if( sobjectName == 'Lead' || sobjectName == 'Contact' ){
                t.whoId = what_id;	
                t.OwnerId = assegnatario;
            } else {
                t.whatId = what_id;	
                t.OwnerId = TXT_FastManager_User__c.getInstance().Richiesta_Approvatore_Account__c;
            }	

            insert t;

        } catch (Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());       
        }

        return t;

    }

    @AuraEnabled(cacheable = true)
    public static User getUserInfo(){        
        return [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Boolean userHasAccessToRecord(Id recordId){
        return [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId =: recordId AND UserId =: UserInfo.getUserId()].HasReadAccess;
    }

    // @AuraEnabled
    // public static List<Area_Visibilita_FastManager__mdt> getVisibilitaMetadata(){
    //     try {
    //         List<Area_Visibilita_FastManager__mdt> visibilita = new List<Area_Visibilita_FastManager__mdt>();

    //         List<Area_Visibilita_FastManager__mdt> all = Area_Visibilita_FastManager__mdt.getAll().values();

    //         String macroArea = [SELECT Id, Macro_Area_FastManager__c FROM User WHERE Id =: UserInfo.getUserId()].Macro_Area_FastManager__c;

    //         for(Area_Visibilita_FastManager__mdt meta : all){
    //             List<String> aree = meta.Visibilita__c.split(';');
    //             //L'utente corrente ha visibilità su questo campo ?
    //             if(aree.contains(macroArea)){
    //                 visibilita.add(meta);
    //             }
    //         }

    //         return visibilita;

    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }


    @AuraEnabled
    public static Map<String,Object> getVisibilitaSection(){
        Map<String,Object> result = new Map<String,Object>();

        try{
            List<Area_Visibilita_FastManager__mdt> visibilitaSection = new List<Area_Visibilita_FastManager__mdt>();
            //List<Area_Visibilita_FastManager__mdt> all = Area_Visibilita_FastManager__mdt.getAll().values();
            List<Area_Visibilita_FastManager__mdt> all = [SELECT API_name__c,fields__c,order__c,title__c,Visibilita__c,MasterLabel, objectName__c, labelObject__c
                                                          FROM Area_Visibilita_FastManager__mdt];
            String macroArea = [SELECT Id, Macro_Area_FastManager__c FROM User WHERE Id =: UserInfo.getUserId()].Macro_Area_FastManager__c;

            for(Area_Visibilita_FastManager__mdt meta : all){
                List<String> aree = meta.Visibilita__c.split(';');
                //L'utente corrente ha visibilità su questo campo ?
                if(aree.contains(macroArea)){
                    visibilitaSection.add(meta);
                }
            }

            Map<String,Object> relatedListColumns = new Map<String,Object>();

            for(Area_Visibilita_FastManager__mdt meta : visibilitaSection){
                // if(meta.MasterLabel.contains('RelatedList_')){
                Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{meta.objectName__c/*MasterLabel.split('_')[1]*/});
                    Map<String, Schema.SObjectField> fieldMap = descResult[0].getSobjectType().getDescribe().fields.getMap(); 

                    List<Map<String,String>> columns = new List<Map<String,String>>();

                    List<String> field = meta.fields__c.split(';');

                    for(String apiNameF : field){
                        Schema.DescribeFieldResult dfr = fieldMap.get(apiNameF).getDescribe();
                        Map<String,String> tmpField = new Map<String,String>();
                        String l = dfr.getLabel();
                        l = l.contains('ID ') || l.contains(' ID') ? l.replace('ID','') : l;
                        tmpField.put('label', l);
                        tmpField.put('apiName', apiNameF);
                        tmpField.put('type', String.valueOf(dfr.getType()));
                        columns.add(tmpField);
                    }

                    relatedListColumns.put(meta.MasterLabel.contains('KPI') ? 'KPI' : meta.objectName__c/*MasterLabel.split('_')[1]*/, columns);
                // }
            }

            result.put('metadati', visibilitaSection);
            result.put('objectColumns', relatedListColumns);

            // return visibilitaSection;

        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        
        return result;
    }



    @AuraEnabled
    public static List<SObject> recuperoDati(string objectName, list<string> field, id recordId){

        try {
            String Query = 'select ';
            Query += String.join(field, ',');
            if(Query.contains('User__c') && objectName == 'Coverage_Team_Member__c'){
                Query = Query.replace('User__c', 'User__r.Name');
                
            }

            if(Query.contains('OwnerId')){
                Query = Query.replace('OwnerId', 'Owner.Name');  

            }

            if(Query.contains('Referente__c')&& objectName == 'Opportunity'){
            Query = Query.replace('Referente__c', 'Referente__r.Name');
            }

            if(Query.contains('RecordTypeId')&& objectName == 'Opportunity'){
            Query = Query.replace('RecordTypeId', 'RecordType.Name');
            }


            if(Query.contains('WhoId') && objectName == 'Event'){
                Query = Query.replace('WhoId','Who.Name');
            }

            Query += ' FROM ' + objectName ;
           
            if(objectName == 'Account'){
                Query +=' WHERE Id =: recordId';
            } else if (objectName != 'Coverage_Team_Member__c'){
                Query +=' WHERE Accountid =: recordId';
            }else if (objectName == 'Coverage_Team_Member__c'){
                Query +=' WHERE Account__c =: recordId';
            }
            List<SObject> resultQuery = database.query(Query);
            
            return resultQuery;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    @AuraEnabled
    public static String recuperaNomeUser(id idUser){

        List<User> nome =[SELECT Name FROM user WHERE id=:idUser LIMIT 1];
        
        return nome[0].Name;
    }

    public class WrapperObj {
        @AuraEnabled public List<SObject> CombinedItems;

        @AuraEnabled public Map<String, List<SObject>> ctmMap;    

        @AuraEnabled public Map<String, SObject> oppToAccMap;      
        @AuraEnabled public Map<String, SObject> taskToAccMap;      
        @AuraEnabled public Map<String, SObject> eventToAccMap;      
        @AuraEnabled public Map<String, SObject> futureTaskToAccMap;      
        @AuraEnabled public Map<String, SObject> futureEventToAccMap;  
        //@AuraEnabled Map<String, SObject> OpportunityData;
        //@AuraEnabled Map<String, SObject> OpportunityData;


        @AuraEnabled public Map<String, SObject> taskToLeadMap;      
        @AuraEnabled public Map<String, SObject> eventToLeadMap;      
        @AuraEnabled public Map<String, SObject> futureTaskToLeadMap;      
        @AuraEnabled public Map<String, SObject> futureEventToLeadMap;  
    }

}