/**
* Progetto:         Banca IFIS - Ti Anticipo
* Sviluppata il:    09/10/2017
* Developer:        Alberto Maianti
*/
public with sharing class TaCtrlTesti {
    
    public static final String TIPO_FAQ = 'FAQ';
    public static final String TIPO_AREACLIENTI = 'AREACLIENTI';
    
    /**
* fetchTesti Metodo che recupera una lista di testi date delle tipologie
* @param  tipologie Tipologie di testi cercati
* @return           Lista dei testi
*/
    public static List<TestiTa__c> fetchTesti(List<String> tipologie) {
        return [SELECT Titolo__c,
                Testo__c,
                Tipo__c,
                Ordinamento__c
                FROM TestiTa__c
                WHERE Tipo__c IN :tipologie
                ORDER BY Tipo__c,Ordinamento__c];
    }
    
    /**
* fetchFAQ Metodo che recupera tutti i testi per le FAQ (FAQ e AREA CLIENTI)
* @return   Lista delle FAQ
*/
    public static List<TestiTa__c> fetchFAQ() {
        return fetchTesti(new List<String>{TIPO_FAQ,TIPO_AREACLIENTI});
    }
    

    
}