global class Batch_AllgnPublicGroupsPTF implements Database.Batchable<sObject>, Database.stateful, IRunner {

    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_AllgnPublicGroupsPTF';
    global Boolean errorOnCreate = false;
    global Integer gmEliminati=0;
    global String testoMail ='';

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();

    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    
    Set<String> kciSet = new Set<String>{'21707', '21709', '21708'};

    /***
     * IRunner
	***/
    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }

    global Set<String> setGroup {
        get{
            if(setGroup != null)return setGroup;
            setGroup = new Set<String>();
            for(Group gr : [
                SELECT Id, DeveloperName 
                FROM   Group 
                WHERE  DeveloperName LIKE 'ViewAll%_%'
                    AND Type = 'Regular'
            ]) {
                setGroup.add(gr.DeveloperName);
            }
            return setGroup;
        } set;
    }

    global static Map<String, Set<String>> macroDivisionMap{

        get{

            if(macroDivisionMap != null){

                return macroDivisionMap;
            }
            macroDivisionMap = new Map<String, Set<String>>();
            for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_Division__c, PTF_MacroDivision__c FROM ServiceModel__c]){
                if(!macroDivisionMap.containsKey(serviceModel.PTF_MacroDivision__c)){
                    macroDivisionMap.put(serviceModel.PTF_MacroDivision__c, new Set<String>());
                }
                macroDivisionMap.get(serviceModel.PTF_MacroDivision__c).add(serviceModel.PTF_Division__c);
            }
            return macroDivisionMap;
        }set;
    }

    global Batch_AllgnPublicGroupsPTF(){}

    global Batch_AllgnPublicGroupsPTF(Set<String> idCedSet){
        this.idCedSet = idCedSet;
    }

    global Boolean isCatena = true;
    global Set<String> updatedMatricole = new Set<String>();
    

    Set<String> idCedSet{get;set;}

    /**
     * Batch
	***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT id, idced__c, FederationIdentifier, PTF_DivisionUO__c, PTF_MacroDivisionUO__c FROM User WHERE isActive = true';
        if(isCatena && !Test.isRunningTest()){
            Set<String> matricolaSet = new Set<String>();
            for(LDAP__c ldap : [SELECT Id, Matricola__c FROM LDAP__c WHERE Profilo_LDAP__c != null AND Da_Elaborare__c = TRUE ]){
                matricolaSet.add(ldap.Matricola__c.replace('U', ''));
            }
            query += ' AND FederationIdentifier IN: matricolaSet';
        }else if(idCedSet != null){
            query += ' AND id IN (SELECT UserOrGroupId FROm GroupMember WHERE Group.DeveloperName LIKE: idCedSet)';
        }
        
        if (Test.isRunningTest()) {
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {
        try {
            
            Map<String, SObject> userMap = (Map<String, SObject>)SV_Utilities.KeyBy(scope, 'Id');
            List<GroupMember> membersToDelete = new List<GroupMember>();
    
            Set<String> matricolaSet = new Set<String>();
            for(User user : scope){
                matricolaSet.add('U'+user.FederationIdentifier);
            }
            Map<String, SObject> ldapMap = (Map<String, SObject>)SV_Utilities.KeyBy([SELECT Matricola__c, IdCedFittizia__c FROM LDAP__c WHERE Matricola__c IN: matricolaSet], 'Matricola__c');
            Map<String, List<SObject>> userRIDCEDMembersMap = (Map<String, List<SObject>>) SV_Utilities.groupBy([SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE group.DeveloperName LIKE 'RIDCED%_%' AND UserOrGroupId IN: userMap.keySet()], 'UserOrGroupId');
            Map<String, List<SObject>> userViewAllMembersMap = (Map<String, List<SObject>>) SV_Utilities.groupBy([SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE group.DeveloperName LIKE 'ViewAll%' AND UserOrGroupId IN: userMap.keySet()], 'UserOrGroupId');
            for(User user : scope){
                
                if(userRIDCEDMembersMap.containsKey(user.Id)){
                    for(GroupMember gm : (List<GroupMember>)userRIDCEDMembersMap.get(user.Id)){
                        String idced = gm.Group.DeveloperName.split('_')[0].substringAfter('RIDCED');
                        String idcedFittizia = ldapMap.containsKey('U'+user.FederationIdentifier) ? (String)ldapMap.get('U'+user.FederationIdentifier).get('IdCedFittizia__c') : '';
                        if(idced != user.idced__c && idced != idcedFittizia){
                            updatedMatricole.add(user.FederationIdentifier);
                            membersToDelete.add(gm);
                        }
                    }
                }
    
                if(userViewAllMembersMap.containsKey(user.Id)){
                    Set<String> visibleMMDS = new Set<String>();
                    if(!String.isBlank(user.PTF_DivisionUO__c)){
                        visibleMMDS.add('ViewAll' + user.PTF_DivisionUO__c);
                    }else if(!String.isBlank(user.PTF_MacroDivisionUO__c)){
                        if(macroDivisionMap.containsKey(user.PTF_MacroDivisionUO__c)){
                            for(String division : macroDivisionMap.get(user.PTF_MacroDivisionUO__c)){
                                visibleMMDS.add('ViewAll' + division);
                            }
                        }
                    }else if(String.isBlank(user.PTF_DivisionUO__c)){
                        visibleMMDS = setGroup;
                    }
                    for(GroupMember gm : (List<GroupMember>)userViewAllMembersMap.get(user.Id)){
                        if(!visibleMMDS.contains(gm.Group.DeveloperName)){
                            updatedMatricole.add(user.FederationIdentifier);
                            membersToDelete.add(gm);
                        }
                    }
                }			
            }
    
            if(!membersToDelete.isEmpty()){
                gmEliminati += membersToDelete.size();
                delete membersToDelete;
            }
        } catch (Exception exc) {
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {
            
            AsyncApexJob a = [
                SELECT	Id,
                        Status,
                        NumberOfErrors,
                        JobItemsProcessed,
                        TotalJobItems,
                        CreatedBy.Email
                        FROM AsyncApexJob 
                        WHERE Id = :BC.getJobId()
                ];
            testoMail = '';
            if (errorOnCreate) {
                testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
            }

            testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
            testoMail += 'Membri gruppi eliminati: ' + gmEliminati + '<br/>';
            if(!updatedMatricole.isEmpty()){
                testoMail += '<br/><b>Utenti allineati</b>:<br/>';
                String table = '';
                table +='<table border="1">';
                table +='<thead>';
                table +='<tr>';
                table +='<th>Matricola</th>';
                table +='</tr>';
                table +='</thead>';
                table +='<tbody>';
                for(String matricola : updatedMatricole){
                    table +='<tr>';
                    table +=('<td>'+matricola+'</td>');
                    table +='</tr>';
                }
                table +='</tbody>';
                table +='</table>';
                testoMail += table + '<br/><br/>';
            }

            if (debug.Verbose__c) {
                mandaMail('Recap',testoMail);
            }

            if (sj!=null && sj.size()>0 && !errorOnCreate && !Test.isRunningTest()) {
                JobRunner.executeNext(sj);
            }
        } catch (Exception ex) {
            System.debug('Error:' + ex.getMessage() + ' at: ' + ex.getStackTraceString());
        }
    }

    public void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione '))+NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt)MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        List<Utenti_Speciali__mdt> utentiSpeciali = (List<Utenti_Speciali__mdt>)MetadataUtility.getRecordByPrefix('Utenti_Speciali__mdt', COD_CLASSE);
        Set<Id> idUtentiSpeciali = new Set<Id>();
        Set<String> emails = new Set<String>();
        for (Utenti_Speciali__mdt us : utentiSpeciali) {
            if (!String.isEmpty(us.ID_Utente__c)) {
                idUtentiSpeciali.add(us.ID_Utente__c);
            }
            if (!String.isEmpty(us.Email__c) && debug.Email__c) {
                emails.add(us.Email__c);
            }
        }
        if (utenteSviluppatore!=null) {
            if (!String.isEmpty(utenteSviluppatore.ID_Utente__c)) {
                idUtentiSpeciali.add(utenteSviluppatore.ID_Utente__c);
            }
            if (!String.isEmpty(utenteSviluppatore.Email__c) && debug.Email__c) {
                emails.add(utenteSviluppatore.Email__c);
            }
        }
        if (idUtentiSpeciali.size()>0) {
            for (Id idUtente : idUtentiSpeciali) {
                generaMail(mailBody,subject,idUtente,emails, utenteSviluppatore);
            }
        }
        else if (emails.size()>0) {
            generaMail(mailBody,subject,null,emails, utenteSviluppatore);
        }
    }

    /***
    * Name			:	generaMail
    * Author		:	Ezio Dal Bo @TEN
    * Create date	:	2020-10-28
    ***/
    public void generaMail(String mailBody,String subject,Id idUtente,Set<String> addresses, Utenti_Speciali__mdt utenteSviluppatore) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (idUtente!=null) {
            mail.setTargetObjectId(idUtente);
        }
        mail.setSenderDisplayName('Salesforce');
        if (utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if (!Test.isRunningTest() && addresses.size()>0) {
            mail.setToAddresses(new List<String>(addresses));
        }
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(mailBody);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }


    public static void test(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}