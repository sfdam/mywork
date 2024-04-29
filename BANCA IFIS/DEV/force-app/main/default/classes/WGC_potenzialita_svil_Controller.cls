public with sharing class WGC_potenzialita_svil_Controller {

    @AuraEnabled
    public static wrapperCount getCountAnagrafiche(String currentUserId, String currentUserLevel, String filterValue, String tipoFiltro){
        wrapperCount wrp = new wrapperCount();
        try {
            if(tipoFiltro == 'utente' && (currentUserLevel == 'commerciale' ||
                (currentUserId == filterValue && (currentUserLevel == 'responsabile' || currentUserLevel == 'direzione'))))
            {
                //Caso: I miei dati
                AggregateResult[] aggrConAttivita = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Factoring_Attivo__c = true AND WGC_Specialista_Factoring__c =: currentUserId];
                wrp.prospectConAttivita = (Integer)aggrConAttivita[0].get('counter');
                AggregateResult[] aggrSenzaAttivita = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Factoring_Attivo__c = false AND WGC_Specialista_Factoring__c =: currentUserId];
                wrp.prospcetSenzaAttivita = (Integer)aggrSenzaAttivita[0].get('counter');
                AggregateResult[] aggrAltreBU = [SELECT count (Anagrafica__r.Id) counter FROM WGC_Posizione__c
                                                WHERE Famiglia_Prodotto__c NOT IN ('Factoring Cedente', 'Factoring Debitore', 'Finanziamenti', 'Servizi Bancari')
                                                AND (Anagrafica__r.WGC_Qualifica_Corporate__c= 'Prospect' OR Anagrafica__r.WGC_Qualifica_Corporate__c = 'Ex cliente')
                                                AND Anagrafica__r.WGC_Specialista_Factoring__c =: currentUserId];
                wrp.clientiAltreBU = (Integer)aggrAltreBU[0].get('counter');
                AggregateResult[] aggrExClienti = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Specialista_Factoring__c =: currentUserId];
                wrp.exClienti = (Integer)aggrExClienti[0].get('counter');
            }else if(tipoFiltro == 'utente' && (currentUserLevel == 'responsabile' || currentUserLevel == 'direzione') && currentUserId != filterValue){
                //Caso: singolo commerciale
                AggregateResult[] aggrConAttivita = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Factoring_Attivo__c = true AND WGC_Specialista_Factoring__c =: filterValue];
                wrp.prospectConAttivita = (Integer)aggrConAttivita[0].get('counter');
                AggregateResult[] aggrSenzaAttivita = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Factoring_Attivo__c = false AND WGC_Specialista_Factoring__c =: filterValue];
                wrp.prospcetSenzaAttivita = (Integer)aggrSenzaAttivita[0].get('counter');
                AggregateResult[] aggrAltreBU = [SELECT count (Anagrafica__r.Id) counter FROM WGC_Posizione__c
                                                WHERE Famiglia_Prodotto__c NOT IN ('Factoring Cedente', 'Factoring Debitore', 'Finanziamenti', 'Servizi Bancari')
                                                AND (Anagrafica__r.WGC_Qualifica_Corporate__c= 'Prospect' OR Anagrafica__r.WGC_Qualifica_Corporate__c = 'Ex cliente')
                                                AND Anagrafica__r.WGC_Specialista_Factoring__c =: filterValue];
                wrp.clientiAltreBU = (Integer)aggrAltreBU[0].get('counter');
                AggregateResult[] aggrExClienti = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Specialista_Factoring__c =: filterValue];
                wrp.exClienti = (Integer)aggrExClienti[0].get('counter');
            }else if(tipoFiltro == 'filiale' && (currentUserLevel == 'responsabile' || currentUserLevel == 'direzione')){
                //Caso: singola o tutte le filiali
                List<String> filialiList = filterValue.split(';');
                AggregateResult[] aggrConAttivita = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Factoring_Attivo__c = true AND WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN :filialiList];
                wrp.prospectConAttivita = (Integer)aggrConAttivita[0].get('counter');
                AggregateResult[] aggrSenzaAttivita = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Factoring_Attivo__c = false AND WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN :filialiList];
                wrp.prospcetSenzaAttivita = (Integer)aggrSenzaAttivita[0].get('counter');
                AggregateResult[] aggrAltreBU = [SELECT count (Anagrafica__r.Id) counter FROM WGC_Posizione__c
                                                WHERE Famiglia_Prodotto__c NOT IN ('Factoring Cedente', 'Factoring Debitore', 'Finanziamenti', 'Servizi Bancari')
                                                AND (Anagrafica__r.WGC_Qualifica_Corporate__c= 'Prospect' OR Anagrafica__r.WGC_Qualifica_Corporate__c = 'Ex cliente')
                                                AND Anagrafica__r.WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN :filialiList];
                wrp.clientiAltreBU = (Integer)aggrAltreBU[0].get('counter');
                AggregateResult[] aggrExClienti = [SELECT count(Id) counter FROM Account WHERE WGC_Qualifica_Corporate__c= 'Prospect'
                                        AND WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN :filialiList];
                wrp.exClienti = (Integer)aggrExClienti[0].get('counter');
            }
            return wrp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class wrapperCount{
        @AuraEnabled public Integer prospectConAttivita;
        @AuraEnabled public Integer prospcetSenzaAttivita;
        @AuraEnabled public Integer clientiAltreBU;
        @AuraEnabled public Integer exClienti;

        wrapperCount(){
            this.prospectConAttivita = 0;
            this.prospcetSenzaAttivita = 0;
            this.clientiAltreBU = 0;
            this.exClienti = 0;
        }
    }
}