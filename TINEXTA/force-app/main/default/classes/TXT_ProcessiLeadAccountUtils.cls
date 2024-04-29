public without sharing class TXT_ProcessiLeadAccountUtils {
    public TXT_ProcessiLeadAccountUtils() {

    }
    /*
                    Via_Sede_Legale__c,
                Provincia_Sede_Legale__c,
                CAP_Sede_Legale__c,
                Paese_Sede_Legale__c,
                Citta_Sede_Legale__c,
                */
    public List<Account> TXT_VerificaCFPIinAccount(string cf, string pi, String company, String country, string SocUser){
        List<Account> result = new List<Account>();
        // if(String.isBlank(cf)==false && String.isBlank(pi)==false){
        //     result = [
        //         SELECT 
        //             Id, Name,
        //             CCIAA_CMK__c,
        //             CCIAA_REA__c,
        //             denosociale__c,
        //             Partita_iva__c,
        //             Codice_fiscale__c,

        //             Via_Sede_Legale__c,
        //             Provincia_Sede_Legale__c,
        //             CAP_Sede_Legale__c,
        //             Paese_Sede_Legale__c,
        //             Citta_Sede_Legale__c,


        //             // Natura_Giuridica__c,
        //             Forma_giuridica__c
        //         FROM Account 
        //         WHERE (Codice_fiscale__c =: cf AND Codice_fiscale__c != null)  OR (Partita_iva__c =: pi AND Partita_iva__c != null) OR (Name =: company)];
        // }

        
        //SM - FIX
        if(String.isNotBlank(cf) || String.isNotBlank(pi))
        {
            //result = [];
            /**
                * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
                * @param objectApiName: nome API oggetto su cui eseguire la query
                * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
                */ 
            //reperisco tutti i campi dell'oggetto
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
            list<string> list_field = new list<string>(fieldMap.keyset());
        
        
            string qrSelect = 'select '+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
            string qrFrom = ' from Account';//FROM oggetto
            string qrWhere = ' where '; //WHERE filtri query
            if(String.isNotBlank(cf) && String.isNotBlank(pi)) qrWhere += '(Codice_fiscale__c =: cf) AND (Partita_iva__c =: pi)';
            else if(String.isBlank(cf) && String.isNotBlank(pi)) qrWhere += '(Partita_iva__c =: pi)';
            else if(String.isNotBlank(cf) && String.isBlank(pi)) qrWhere += '(Codice_fiscale__c =: cf)';
            //else if(String.isBlank(cf) && String.isBlank(pi) && String.isNotBlank(company)) qrWhere = '(Name =: company) AND BillingCountry =: country';
            qrWhere += ' AND Societa_su_CTM__c like \'%'+SocUser+'%\'';
            string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
            
            //creo una variabile di tipo "Tipo lista<Oggetto>"
            //System.Type listType = System.Type.forName('List<Account>');
            //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
            //List<SObject> result = (List<SObject>)listType.newInstance();
        
        
            //aggiungere where/order se correttamente valorizzati nelle variabili
            //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
            result = database.query(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);

            system.debug(SocUser);
            system.debug(result.size());
        }
        if(result.size()<=0)
        {
            if(String.isNotBlank(cf) && String.isNotBlank(pi)){
                result = [
                    SELECT 
                        Id, Name,
                        CCIAA_CMK__c,
                        CCIAA_REA__c,
                        denosociale__c,
                        Partita_iva__c,
                        Codice_fiscale__c,
                        
                        Data_Bilancio__c,
                        Acquisti_totali__c,
                        Data_di_cessazione__c,
                        Anno_rilevazione_addetti__c,
                        Data_Inizio_Attivita__c,
                        AnnualRevenue,
                        Livello_attenzione_negativita__c,
                        Capitale_Sociale__c,
                        Crediti_vs_Clienti__c,
                        Risultato_Operativo_Lordo__c,
                        Phone,
                        Email_Aziendale_Innolva__c,
                        Totale_Patrimonio_Netto_Tinexta__c,
                        Fax,
                        Utile_Perdita__c,
                        Stato_Attivita__c,
                        Fatturato__c,
                        Rating__c,
                        Dipendenti__c,
                        Codice_Ateco_Innolva__c,
                        Descrizione_Ateco_Innolva__c,
                        Data_Ultimo_Arricchimento__c,
                        Cliente_Estero__c,
    
                        Via_Sede_Legale__c,
                        Provincia_Sede_Legale__c,
                        CAP_Sede_Legale__c,
                        Paese_Sede_Legale__c,
                        Citta_Sede_Legale__c,
    
                        TXT_Gruppo_IVA__c,
                        TXT_Denominazione_Gruppo_IVA__c,
    
                        BillingStreet,
                        BillingCountry,
                        BillingCity,
                        BillingPostalCode,
                        BillingState,
    
                        // Natura_Giuridica__c,
                        Forma_giuridica__c,
                        societa_su_ctm__c,
                        INN_societa__c,
                        REV_societa__c
                    FROM Account 
                    WHERE (Codice_fiscale__c =: cf) AND (Partita_iva__c =: pi)];
            } else if(String.isBlank(cf) && String.isNotBlank(pi)){
                result = [
                    SELECT 
                        Id, Name,
                        CCIAA_CMK__c,
                        CCIAA_REA__c,
                        denosociale__c,
                        Partita_iva__c,
                        Codice_fiscale__c,
    
                        Data_Bilancio__c,
                        Acquisti_totali__c,
                        Data_di_cessazione__c,
                        Anno_rilevazione_addetti__c,
                        Data_Inizio_Attivita__c,
                        AnnualRevenue,
                        Livello_attenzione_negativita__c,
                        Capitale_Sociale__c,
                        Crediti_vs_Clienti__c,
                        Risultato_Operativo_Lordo__c,
                        Phone,
                        Email_Aziendale_Innolva__c,
                        Totale_Patrimonio_Netto_Tinexta__c,
                        Fax,
                        Utile_Perdita__c,
                        Stato_Attivita__c,
                        Fatturato__c,
                        Rating__c,
                        Dipendenti__c,
                        Codice_Ateco_Innolva__c,
                        Descrizione_Ateco_Innolva__c,
                        Data_Ultimo_Arricchimento__c,
                        Cliente_Estero__c,
    
                        Via_Sede_Legale__c,
                        Provincia_Sede_Legale__c,
                        CAP_Sede_Legale__c,
                        Paese_Sede_Legale__c,
                        Citta_Sede_Legale__c,
    
                        TXT_Gruppo_IVA__c,
                        TXT_Denominazione_Gruppo_IVA__c,
    
                        BillingStreet,
                        BillingCountry,
                        BillingCity,
                        BillingPostalCode,
                        BillingState,
    
                        // Natura_Giuridica__c,
                        Forma_giuridica__c,
                        societa_su_ctm__c,
                        INN_societa__c,
                        REV_societa__c
                    FROM Account 
                    WHERE (Partita_iva__c =: pi)];
            } else if(String.isNotBlank(cf) && String.isBlank(pi)){
                result = [
                    SELECT 
                        Id, Name,
                        CCIAA_CMK__c,
                        CCIAA_REA__c,
                        denosociale__c,
                        Partita_iva__c,
                        Codice_fiscale__c,
    
                        Data_Bilancio__c,
                        Acquisti_totali__c,
                        Data_di_cessazione__c,
                        Anno_rilevazione_addetti__c,
                        Data_Inizio_Attivita__c,
                        AnnualRevenue,
                        Livello_attenzione_negativita__c,
                        Capitale_Sociale__c,
                        Crediti_vs_Clienti__c,
                        Risultato_Operativo_Lordo__c,
                        Phone,
                        Email_Aziendale_Innolva__c,
                        Totale_Patrimonio_Netto_Tinexta__c,
                        Fax,
                        Utile_Perdita__c,
                        Stato_Attivita__c,
                        Fatturato__c,
                        Rating__c,
                        Dipendenti__c,
                        Codice_Ateco_Innolva__c,
                        Descrizione_Ateco_Innolva__c,
                        Data_Ultimo_Arricchimento__c,
                        Cliente_Estero__c,
    
                        Via_Sede_Legale__c,
                        Provincia_Sede_Legale__c,
                        CAP_Sede_Legale__c,
                        Paese_Sede_Legale__c,
                        Citta_Sede_Legale__c,
    
                        TXT_Gruppo_IVA__c,
                        TXT_Denominazione_Gruppo_IVA__c,
    
                        BillingStreet,
                        BillingCountry,
                        BillingCity,
                        BillingPostalCode,
                        BillingState,
    
                        // Natura_Giuridica__c,
                        Forma_giuridica__c,
                        societa_su_ctm__c,
                        INN_societa__c,
                        REV_societa__c
                    FROM Account 
                    WHERE (Codice_fiscale__c =: cf)];
            } else if(String.isBlank(cf) && String.isBlank(pi) && String.isNotBlank(company)){
                company = company.trim();
                result = [
                    SELECT 
                        Id, Name,
                        CCIAA_CMK__c,
                        CCIAA_REA__c,
                        denosociale__c,
                        Partita_iva__c,
                        Codice_fiscale__c,
    
                        Data_Bilancio__c,
                        Acquisti_totali__c,
                        Data_di_cessazione__c,
                        Anno_rilevazione_addetti__c,
                        Data_Inizio_Attivita__c,
                        AnnualRevenue,
                        Livello_attenzione_negativita__c,
                        Capitale_Sociale__c,
                        Crediti_vs_Clienti__c,
                        Risultato_Operativo_Lordo__c,
                        Phone,
                        Email_Aziendale_Innolva__c,
                        Totale_Patrimonio_Netto_Tinexta__c,
                        Fax,
                        Utile_Perdita__c,
                        Stato_Attivita__c,
                        Fatturato__c,
                        Rating__c,
                        Dipendenti__c,
                        Codice_Ateco_Innolva__c,
                        Descrizione_Ateco_Innolva__c,
                        Data_Ultimo_Arricchimento__c,
                        Cliente_Estero__c,
    
                        Via_Sede_Legale__c,
                        Provincia_Sede_Legale__c,
                        CAP_Sede_Legale__c,
                        Paese_Sede_Legale__c,
                        Citta_Sede_Legale__c,
                        
                        TXT_Gruppo_IVA__c,
                        TXT_Denominazione_Gruppo_IVA__c,
                        
                        BillingStreet,
                        BillingCountry,
                        BillingCity,
                        BillingPostalCode,
                        BillingState,
    
    
                        // Natura_Giuridica__c,
                        Forma_giuridica__c,
                        societa_su_ctm__c,
                        INN_societa__c,
                        REV_societa__c
                    FROM Account 
                    WHERE (Name =: company) AND BillingCountry =: country];
            }
        }

        return result;
    }

    public List<Account> TXT_Verifica_Account_PF(String[] LA){
        return TXT_VerificaCFPIinAccount(LA[1], '', '', '', LA[5]); 
    }

    public List<Account> TXT_Verifica_Account_PG(String[] LA){
        return TXT_VerificaCFPIinAccount(LA[1], LA[2], LA[3], LA.size() == 5 ? LA[4] : '', LA[5]);
    }

    // @AuraEnabled(cacheable=true)
    // public static String TXT_PickList_Fatturato(String strnumero){
    //     /*  0 = less than 1 M€
    //         1 = Fino a 1 milione di Euro
    //         2 = Da 1 a 5 milioni di Euro
    //         3 = Da più di 5 a 10 milioni di Euro
    //         4 = Oltre i 10 milioni di Euro
    //     */
    //     if(strnumero==null || strnumero==''){
    //         strnumero = '0.0';
    //     }
    //     String label = '';
    //     if(strnumero.contains(' ')==false){
    //         Integer result = 0;
    //         Decimal numero = Decimal.valueof(strnumero);
    //         if(numero<1){
    //             result = 0;
    //         }else if(numero<1.5){
    //             result = 1;
    //         }else if(numero<5){
    //             result = 2;
    //         }else if(numero<10){
    //             result = 3;
    //         }else if(numero>10){
    //             result = 4;
    //         }

            
    //         Schema.DescribeFieldResult fieldResult = Account.Fatturato__c.getDescribe();
    //         label = fieldResult.getPicklistValues()[result].getLabel();
    //     }else{ 
    //         label = strnumero;
    //     }
    //     return label;
    // }

    @AuraEnabled(cacheable=true)
    public static String TXT_PickList_Dipendenti(String strnumero){
        /*  0 = 1-9
            1 = 10-49
            2 = 50-249
            3 = 250 e oltre
        */
        // if(strnumero==null || strnumero=='' || strnumero == 'Nessun dipendente'){
        //     strnumero = '0';
        // }
        if(strnumero == null || strnumero == '') {
            return null;
        } else if(strnumero == 'Nessun dipendente') {
            strnumero = '0';
        }
        Integer result = 0;
        if(strnumero.contains('-')){ //es: 1-9
            strnumero = strnumero.split('-')[0];
        }
        Integer numero;
        try {
            numero = Integer.valueof(strnumero);
        } catch (Exception e) {
            System.debug('@@@ exception ' + e.getStackTraceString());
        }
        if(numero == 0){
            result = 0;
        }else if(numero<10){
            result = 1;
        }else if(numero<50){
            result = 2;
        }else if(numero<250){
            result = 3;
        }else if(numero>249){
            result = 4;
        }
        
        Schema.DescribeFieldResult fieldResult = Account.Dipendenti__c.getDescribe();
        String label = fieldResult.getPicklistValues()[result].getLabel();
        return label;
    }


    // @AuraEnabled
    // public static String TXT_PickList_Fatturato(String strnumero){
    //     /*  0 = less than 1 M€
    //         1 = Fino a 1 milione di Euro
    //         2 = Da 1 a 5 milioni di Euro
    //         3 = Da più di 5 a 10 milioni di Euro
    //         4 = Oltre i 10 milioni di Euro
    //     */
    //     if(strnumero==null || strnumero==''){
    //         // strnumero = '0.0';
    //         return null;
    //     }
    //     String label = '';
    //     if(strnumero.contains(' ')==false){
    //         Integer result = 0;
    //         Decimal numero = Decimal.valueof(strnumero);
    //         if(numero == 0.0 || numero == 0){
    //             result = 0;
    //         } else if(numero<0.6){
    //             result = 1;
    //         }else if(numero<1){
    //             result = 2;
    //         }else if(numero<3){
    //             result = 3;
    //         }else if(numero<5){
    //             result = 4;
    //         }else if(numero<10){
    //             result = 5;
    //         }else if(numero<20){
    //             result = 6;
    //         }else if(numero<30){
    //             result = 7;
    //         }else if(numero<50){
    //             result = 8;
    //         }else if(numero<70){
    //             result = 9;
    //         }else if(numero<100){
    //             result = 10;
    //         }else if(numero>=100){
    //             result = 11;
    //         }

            
    //         Schema.DescribeFieldResult fieldResult = Account.Fatturato__c.getDescribe();
    //         label = fieldResult.getPicklistValues()[result].getLabel();
    //     }else{ 
    //         label = strnumero;
    //     }
    //     return label;
    // }

    @AuraEnabled
    public static String TXT_PickList_Fatturato(Decimal annualrevenue){
        /*  0 = less than 1 M€
            1 = Fino a 1 milione di Euro
            2 = Da 1 a 5 milioni di Euro
            3 = Da più di 5 a 10 milioni di Euro
            4 = Oltre i 10 milioni di Euro
        */

        String result;
        if(annualrevenue==null){
            return result;
        } else {
            // Decimal numero = Decimal.valueof(annualrevenue);
            Integer i = 0;
            if(annualrevenue == 0.0 || annualrevenue == 0){
                i = 0;
            } else if(annualrevenue<600000){
                i = 1;
            }else if(annualrevenue<1000000){
                i = 2;
            }else if(annualrevenue<3000000){
                i = 3;
            }else if(annualrevenue<5000000){
                i = 4;
            }else if(annualrevenue<10000000){
                i = 5;
            }else if(annualrevenue<20000000){
                i = 6;
            }else if(annualrevenue<30000000){
                i = 7;
            }else if(annualrevenue<50000000){
                i = 8;
            }else if(annualrevenue<70000000){
                i = 9;
            }else if(annualrevenue<100000000){
                i = 10;
            }else if(annualrevenue>=100000000){
                i = 11;
            }

            
            Schema.DescribeFieldResult fieldResult = Account.Fatturato__c.getDescribe();
            result = fieldResult.getPicklistValues()[i].getLabel();
        }

        return result;
    }

    // @AuraEnabled(cacheable=true)
    // public static String TXT_PickList_Dipendenti_LEAD(String strnumero){
    //     /*  0 = 1-9
    //         1 = 10-49
    //         2 = 50-249
    //         3 = 250 e oltre
    //     */
    //     if(strnumero==null || strnumero==''){
    //         strnumero = '0';
    //     }
    //     Integer result = 0;
    //     if(strnumero.contains('-')){ //es: 1-9
    //         strnumero = strnumero.split('-')[0];
    //     }
    //     Integer numero = Integer.valueof(strnumero);
    //     if(numero<10){
    //         result = 0;
    //     }else if(numero<50){
    //         result = 1;
    //     }else if(numero<250){
    //         result = 2;
    //     }else if(numero>249){
    //         result = 3;
    //     }
        
    //     Schema.DescribeFieldResult fieldResult = Lead.Dipendenti__c.getDescribe();
    //     String label = fieldResult.getPicklistValues()[result].getLabel();
    //     return label;
    // }

    public static List<Account> executeCallMock(Integer searchType, String searchedParameter){
        List<Account> response = new List<Account>();
        //Mock della risposta provvisoria
        Account newAccount = new Account();
        //newaccount.Name = 'NewAccount';
        //newaccount.CCIAA_CMK__c = '1234567890';
        //newaccount.CCIAA_REA__c = '1234567890';
        newaccount.denosociale__c = 'New Account';
        newaccount.Partita_iva__c = '1234567890';
        newaccount.Codice_fiscale__c = '1234567890';
        newaccount.Via_Sede_Legale__c = 'Via Test';
        newaccount.Provincia_Sede_Legale__c = 'TS';


        newaccount.CAP_Sede_Legale__c = '12345';

        newaccount.Paese_Sede_Legale__c = 'Paese Test';
        newaccount.Citta_Sede_Legale__c = 'Citta Test';
        newaccount.Forma_giuridica__c = 'PERSONA FISICA';

        newaccount.Data_Bilancio__c = System.TODAY();
        newaccount.Acquisti_totali__c = 10;
        newAccount.Data_di_cessazione__c = System.TODAY();
        newaccount.Anno_rilevazione_addetti__c = '2020';
        newaccount.Data_Inizio_Attivita__c = System.TODAY();
        newAccount.AnnualRevenue = 20000;
        newAccount.Livello_attenzione_negativita__c = 'Alto';
        newAccount.Capitale_Sociale__c = 20000;
        newAccount.Crediti_vs_Clienti__c = 2000;
        newaccount.Risultato_Operativo_Lordo__c = 2000;
        newAccount.Phone_Warrant__c = '123456789';
        newAccount.Totale_Patrimonio_Netto_Tinexta__c = 20000;
        newAccount.Fax = '12345679';
        newAccount.Utile_Perdita__c = 20000;
        newAccount.Stato_Attivita__c = 'Attiva';
        // newaccount.Fatturato__c = '1. Fino a 1 milione di Euro';
        newAccount.Rating__c = '1';
        newaccount.Dipendenti__c = '1-9';
        newAccount.Codice_Ateco_Innolva__c = '12345';
        newAccount.Descrizione_Ateco_Innolva__c = 'Descrizione';

        response.add(newAccount);
        return response;
    }

}