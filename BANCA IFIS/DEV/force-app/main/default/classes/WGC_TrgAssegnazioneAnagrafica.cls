/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 10-14-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/
public class WGC_TrgAssegnazioneAnagrafica {
	
    /*@AuraEnabled
    public static void ricalcoloAssegnazioneAnagrafica(Map<Id, AssegnazioneAnagrafica__c> oldMap, Map<Id, AssegnazioneAnagrafica__c> newMap){
        System.debug('@@@ oldMap ' + oldMap);
        System.debug('@@@ newMap ' + newMap);

        List<String> caps = new List<String>();
        Set<Id> listaUtenti = new Set<Id>();

        //Lista di cap utilizzata per matchare l'assegnazione anagrafica con l'anagrafica
        //Lista di Id di utenti, utilizzata per fare un controllo che l'utente che andrà inserito in specialista factoring sia attivo
        for(AssegnazioneAnagrafica__c ass : newMap.values()){
            caps.add(ass.Cap__c);
            listaUtenti.add(ass.IdUtente__c);
        }

        //Lista di anagrafica su cui effettuare un controllo ed un eventuale update
        List<Account> accountToUpdate = new List<Account>();
        accountToUpdate = [SELECT Id, Name, BillingPostalCode, WGC_Specialista_Factoring__c, 
                                    WGC_Specialista_Filo_Diretto__c, WGC_Factoring_Attivo__c FROM Account WHERE BillingPostalCode IN: caps AND (WGC_Specialista_Factoring__c IN :listaUtenti OR WGC_Factoring_Attivo__c = false)];
        
        //Utenti attivi
        List<User> activeUser = new List<User>();
        activeUser = [SELECT Id, FirstName, LastName, Qualifica_Utente__c FROM User WHERE Id IN: listaUtenti AND IsActive = true];

        //Set di id degli utenti attivi
        Set<Id> activeUserId = new Set<Id>();
        for(User u : activeUser){
            activeUserId.add(u.Id);
        }

        List<Account> toUpd = new List<Account>();

        //Controllo tutti gli account
        for(Account a : accountToUpdate){
            Boolean needsUpdate = false;
            for(AssegnazioneAnagrafica__c ass : newMap.values()){
                //Se il cap corrisponde tra anagrafica e record di assegnazione allora modifico lo specialista filo diretto
                if(a.BillingPostalCode == ass.Cap__c && ass.FiloDiretto__c){
                    a.WGC_Specialista_Filo_Diretto__c = ass.IdUtente__c;
                    needsUpdate = true;
                }

                //Se il cap corrisponde e WGC_Factoring_Attivo = false e l'assegnazione non è di filo diretto allora modifico lo specialista factoring
                //Oppure
                //Se il cap corrisponde e WGC_Factoring_Attivo = true e l'assegnazione non è di filo diretto, e l'utente è disattivo allora modifico lo specialista factoring
                if((a.BillingPostalCode == ass.Cap__c && !a.WGC_Factoring_Attivo__c && !ass.FiloDiretto__c) || 
                    (a.BillingPostalCode == ass.Cap__c && a.WGC_Factoring_Attivo__c && !activeUserId.contains(ass.IdUtente__c) && !ass.FiloDiretto__c)){
                    
                    a.WGC_Specialista_Factoring__c = ass.IdUtente__c;
                    needsUpdate = true;
                }

                if(needsUpdate){
                    toUpd.add(a);
                }
            }
        }

        update toUpd;
    }*/


    @AuraEnabled
    public static void ricalcoloAssegnazioneAnagrafica_New(Map<Id, AssegnazioneAnagrafica__c> oldMap, Map<Id, AssegnazioneAnagrafica__c> newMap){

        List<String> caps = new List<String>();
        Set<Id> listaUtenti = new Set<Id>();
        Set<Id> listaUtentiOld = new Set<Id>();

        //Lista di cap utilizzata per matchare l'assegnazione anagrafica con l'anagrafica
        //Lista di Id di utenti, utilizzata per fare un controllo che l'utente che andrà inserito in specialista factoring sia attivo
        for(AssegnazioneAnagrafica__c ass : newMap.values()){
            caps.add(ass.Cap__c);
            listaUtenti.add(ass.IdUtente__c);
        }

        for(AssegnazioneAnagrafica__c assOld : oldMap.values()){
            //Condizione aggiunta per non effettuare ricalcolo su assegnazioni di filo diretto web
            if(!assOld.WGC_Filo_Diretto_Web__c)
                listaUtentiOld.add(assOld.IdUtente__c);
        }

        //Lista di anagrafica su cui effettuare un controllo ed un eventuale update
        //FACTORY SV -- Aggiunta campo Specialista_assegnato_FD__c in query
        List<Account> accountToUpdate = new List<Account>();
        accountToUpdate = [SELECT Id, Name, BillingPostalCode, BillingCity, WGC_Specialista_Factoring__c, 
                                    WGC_Specialista_Filo_Diretto__c, WGC_Factoring_Attivo__c, WGC_Originator__c, Specialista_assegnato_FD__c FROM Account WHERE WGC_Specialista_Factoring__c IN :listaUtentiOld OR WGC_Specialista_Filo_Diretto__c IN :listaUtentiOld];

        //System.debug('@@@ accountToUpdate ' + JSON.serialize(accountToUpdate));
        
        //Utenti attivi
        List<User> activeUser = new List<User>();
        activeUser = [SELECT Id, FirstName, LastName, Qualifica_Utente__c FROM User WHERE Id IN: listaUtenti AND IsActive = true];

        //Set di id degli utenti attivi
        Set<Id> activeUserId = new Set<Id>();
        for(User u : activeUser){
            activeUserId.add(u.Id);
        }

        List<Account> toUpd = new List<Account>();

        // //Controllo tutti gli account
        for(Account a : accountToUpdate){
            Boolean needsUpdate = false;
            for(AssegnazioneAnagrafica__c ass : newMap.values()){
                //Se il cap corrisponde tra anagrafica e record di assegnazione allora modifico lo specialista filo diretto
                /*
                if(a.BillingPostalCode == ass.Cap__c && ass.FiloDiretto__c && !ass.WGC_Filo_Diretto_Web__c && a.WGC_Originator__c != 'Web'){
                    a.WGC_Specialista_Filo_Diretto__c = ass.IdUtente__c;
                    needsUpdate = true;
                }
				*/

                //Se il cap corrisponde e WGC_Factoring_Attivo = false e l'assegnazione non è di filo diretto allora modifico lo specialista factoring
                //Oppure
                //Se il cap corrisponde e WGC_Factoring_Attivo = true e l'assegnazione non è di filo diretto, e l'utente è disattivo allora modifico lo specialista factoring
                //FACTORY SV -- Aggiunta campo Specialista_assegnato_FD__c in condizione
                if((a.BillingPostalCode == ass.Cap__c && !a.WGC_Factoring_Attivo__c && !ass.FiloDiretto__c && a.Specialista_assegnato_FD__c == null) || 
                    (a.BillingPostalCode == ass.Cap__c && a.WGC_Factoring_Attivo__c && !activeUserId.contains(ass.IdUtente__c) && !ass.FiloDiretto__c)){
                    
                    a.WGC_Specialista_Factoring__c = ass.IdUtente__c;
                    needsUpdate = true;
                }

                if(needsUpdate){
                    toUpd.add(a);
                }
            }
        }

        System.enqueueJob(new WGC_QbleAggiornaAssegnazioneAnagrafica(toUpd));

        // update toUpd;
    }
}