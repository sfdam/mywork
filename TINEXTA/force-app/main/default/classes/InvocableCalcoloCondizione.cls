public class InvocableCalcoloCondizione {
    
    //Qua setto le variabili di input che mi arrivano dal flow
    public class ActionRequest {
        @InvocableVariable
        public string quoteline ;
    }
    
    //qua rendo le variabili disponibili da usare in questa classe 
    @InvocableMethod (label='Calcolo condizione')
    
    public static List<String> CalcoloCondizione (List<ActionRequest> requests){
        
        string quoteline = requests[0].quoteline;     
        
        //List <condizioni__c> cnlist = [SELECT id, WRT_Update_da_Rinnovo__c,name,Fisso_WarrantCPQ__c,Limite_WarrantCPQ__c,Percentuale_WarrantCPQ__c,Min_garantito_WarrantCPQ__c,Valore_max_WarrantCPQ__c,Minimo_WarrantCPQ__c ,Massimo_WarrantCPQ__c,Finanziamento__c,Finanziamento__r.Importo_WarrantCPQ__c,Finanziamento__r.Stima_WarrantCPQ__c,Importo_Appoggio__c, Stima_Appoggio__c, Tipo_WarrantCPQ__c,(select id,CondizionePadre_WarrantCPQ__c, name,Formula_Importo_WarrantCPQ__c,Formula_Stima_WarrantCPQ__c from condizioni_opzionali__r) FROM condizioni__c where Quote_Line__c =: quoteline];
        //List <finanziamenti__c> fnlist =[select id, name,WRT_Update_da_Rinnovo__c from finanziamenti__c  where Quote_Line__c =: quoteline];
        //list <pagamenti__c> paglist =[select id,name,WRT_Update_da_Rinnovo__c from pagamenti__c  where Quote_Line__c =: quoteline];
        
        //Recupero i campi necessari
        List<Condizioni__c> listToConvert = [SELECT (SELECT Id FROM condizioni_opzionali__r), Id, Finanziamento__c, Percentuale_WarrantCPQ__c, Fisso_WarrantCPQ__c, Limite_WarrantCPQ__c, Valore_max_WarrantCPQ__c, Massimo_WarrantCPQ__c, FORM_Importo_Finanziamento_Associato__c, FORMStima_Finanziamento_Associato__c, Tipo_WarrantCPQ__c, Minimo_WarrantCPQ__c, FORM_Importo_Percentuale__c, FORMStima_Percentuale__c, Min_garantito_WarrantCPQ__c, WRT_Update_da_Rinnovo__c FROM Condizioni__c WHERE Quote_Line__c = :quoteline];
        
        //Converto la lista in una mappa:
        Map<Id, Condizioni__c> newinput = new Map<Id, Condizioni__c>(listToConvert);
        
        //Seleziono le condizioni opzionali da usare se il codice non entra nell'if che contiene tutte le condizioni:
        Map<Id, AggregateResult> CondOpz = new Map<Id, AggregateResult>([SELECT CondizionePadre_WarrantCPQ__c Id, SUM(Formula_Importo_WarrantCPQ__c) importi, SUM(Formula_Stima_WarrantCPQ__c) stime FROM Condizione_Opzionale__c WHERE CondizionePadre_WarrantCPQ__c IN :newinput.keySet() AND Formula_Stima_WarrantCPQ__c!=null AND Formula_Importo_WarrantCPQ__c!=null GROUP BY CondizionePadre_WarrantCPQ__c]);
        
        //Ciclo la mappa che contiene tutte le condizioni e faccio i calcoli per impostare i campi Importo_Appoggio__c e Stima_Appoggio__c: 
        for(Id i:newinput.keySet()){            
            if(newinput.get(i).condizioni_opzionali__r.size()==0 && newinput.get(i).Finanziamento__c!=null){
                
                if(newinput.get(i).Percentuale_WarrantCPQ__c!=null){
                    
                    /*//NB: Il codice non può entrare nel seguente if e, di conseguenza, nella condizione 1 e condizione 2 perchè tipo=='Progressivo' è in contrasto con la Validation Rule "Controllo_tipo" dell'oggetto Condizione__c
if(newinput.get(i).Fisso_WarrantCPQ__c==null && newinput.get(i).Limite_WarrantCPQ__c==null && newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo'){
//Condizione 1 Importo:
if(newinput.get(i).Valore_max_WarrantCPQ__c==null || newinput.get(i).Valore_max_WarrantCPQ__c>(newinput.get(i).FORM_Importo_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100){
if(newinput.get(i).Massimo_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Finanziamento_Associato__c){
if(newinput.get(i).Min_garantito_WarrantCPQ__c==null || newinput.get(i).Min_garantito_WarrantCPQ__c<(newinput.get(i).Massimo_WarrantCPQ__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100)){
newinput.get(i).Importo_Appoggio__c=(newinput.get(i).Massimo_WarrantCPQ__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100;
}
}
}
//Condizione 1 Stima:
if(newinput.get(i).Valore_max_WarrantCPQ__c==null || newinput.get(i).Valore_max_WarrantCPQ__c>(newinput.get(i).FORMStima_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100){
if(newinput.get(i).Massimo_WarrantCPQ__c<=newinput.get(i).FORMStima_Finanziamento_Associato__c){
if(newinput.get(i).Min_garantito_WarrantCPQ__c==null || newinput.get(i).Min_garantito_WarrantCPQ__c<(newinput.get(i).Massimo_WarrantCPQ__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100)){
newinput.get(i).Stima_Appoggio__c=(newinput.get(i).Massimo_WarrantCPQ__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100;
}
}
}
//Condizione 2 Importo:
if(newinput.get(i).Valore_max_WarrantCPQ__c==null || newinput.get(i).Valore_max_WarrantCPQ__c>(newinput.get(i).FORM_Importo_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100){
if(newinput.get(i).Minimo_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Finanziamento_Associato__c){
if(newinput.get(i).Min_garantito_WarrantCPQ__c==null || newinput.get(i).Min_garantito_WarrantCPQ__c<(newinput.get(i).FORM_Importo_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100)){
newinput.get(i).Importo_Appoggio__c=(newinput.get(i).FORM_Importo_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100;
}
}
}
//Condizione 2 Stima:
if(newinput.get(i).Valore_max_WarrantCPQ__c==null || newinput.get(i).Valore_max_WarrantCPQ__c>(newinput.get(i).FORMStima_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100){
if(newinput.get(i).Minimo_WarrantCPQ__c<=newinput.get(i).FORMStima_Finanziamento_Associato__c){
if(newinput.get(i).Min_garantito_WarrantCPQ__c==null || newinput.get(i).Min_garantito_WarrantCPQ__c<(newinput.get(i).FORMStima_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100)){
newinput.get(i).Stima_Appoggio__c=(newinput.get(i).FORMStima_Finanziamento_Associato__c-newinput.get(i).Minimo_WarrantCPQ__c)*newinput.get(i).Percentuale_WarrantCPQ__c/100;
}
}
}
}	*/		        
                    //Condizione 4 Importo:
                    //Per completezza, la prossima condizione dovrebbe prevedere anche tipo!='Alternativo', ma è anche vero che tipo Alternativo prevede obbligatoriamente la presenza di Condizioni Opzionali e, pertanto, non rientrerebbe proprio all'interno di questa parte di codice
                    if(newinput.get(i).Minimo_WarrantCPQ__c==null 
                       || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORM_Importo_Finanziamento_Associato__c){      
                           if(newinput.get(i).Massimo_WarrantCPQ__c==null 
                              || newinput.get(i).Massimo_WarrantCPQ__c>=newinput.get(i).FORM_Importo_Finanziamento_Associato__c){       
                                  if(newinput.get(i).Valore_max_WarrantCPQ__c==null 
                                     || newinput.get(i).Valore_max_WarrantCPQ__c>=newinput.get(i).FORM_Importo_Percentuale__c){       
                                         if(newinput.get(i).Tipo_WarrantCPQ__c!='Progressivo' && newinput.get(i).Fisso_WarrantCPQ__c==null){
                                             if(newinput.get(i).Min_garantito_WarrantCPQ__c==null 
                                                || newinput.get(i).Min_garantito_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Finanziamento_Associato__c){                                                           
                                                    if(newinput.get(i).Limite_WarrantCPQ__c==null 
                                                       || (newinput.get(i).Limite_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Finanziamento_Associato__c && newinput.get(i).Min_garantito_WarrantCPQ__c==null && newinput.get(i).Valore_max_WarrantCPQ__c==null)){
                                                           newinput.get(i).Importo_Appoggio__c=newinput.get(i).FORM_Importo_Percentuale__c;
                                                       }                                        
                                                }
                                         } 
                                     }
                              }
                       }
                    //Condizione 6 Importo:
                    if(((newinput.get(i).Minimo_WarrantCPQ__c==null || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORM_Importo_Finanziamento_Associato__c) && (newinput.get(i).Massimo_WarrantCPQ__c==null || newinput.get(i).Massimo_WarrantCPQ__c>=newinput.get(i).FORM_Importo_Finanziamento_Associato__c) && newinput.get(i).Tipo_WarrantCPQ__c!='Progressivo') || newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo'){
                        if(newinput.get(i).Valore_max_WarrantCPQ__c==null 
                           || newinput.get(i).Valore_max_WarrantCPQ__c>=newinput.get(i).FORM_Importo_Percentuale__c){
                               if(newinput.get(i).Limite_WarrantCPQ__c==null && newinput.get(i).Min_garantito_WarrantCPQ__c!=null && newinput.get(i).FORM_Importo_Percentuale__c<=newinput.get(i).Min_garantito_WarrantCPQ__c){                                    
                                   newinput.get(i).Importo_Appoggio__c=newinput.get(i).Min_garantito_WarrantCPQ__c;                                    
                               } 
                           }
                    }                                                        
                    //Condizione 4 Stima:
                    //Per completezza, la prossima condizione dovrebbe prevedere anche tipo!='Alternativo', ma è anche vero che tipo Alternativo prevede obbligatoriamente la presenza di Condizioni Opzionali e, pertanto, non rientrerebbe proprio all'interno di questa parte di codice
                    if(newinput.get(i).Minimo_WarrantCPQ__c==null 
                       || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORMStima_Finanziamento_Associato__c){       
                           if(newinput.get(i).Massimo_WarrantCPQ__c==null 
                              || newinput.get(i).Massimo_WarrantCPQ__c>=newinput.get(i).FORMStima_Finanziamento_Associato__c){       
                                  if(newinput.get(i).Valore_max_WarrantCPQ__c==null 
                                     || newinput.get(i).Valore_max_WarrantCPQ__c>=newinput.get(i).FORMStima_Percentuale__c){       
                                         if(newinput.get(i).Tipo_WarrantCPQ__c!='Progressivo' && newinput.get(i).Fisso_WarrantCPQ__c==null){
                                             if(newinput.get(i).Min_garantito_WarrantCPQ__c==null 
                                                || newinput.get(i).Min_garantito_WarrantCPQ__c<=newinput.get(i).FORMStima_Finanziamento_Associato__c){                                                           
                                                    if(newinput.get(i).Limite_WarrantCPQ__c==null 
                                                       || (newinput.get(i).Limite_WarrantCPQ__c<=newinput.get(i).FORMStima_Finanziamento_Associato__c && newinput.get(i).Min_garantito_WarrantCPQ__c==null && newinput.get(i).Valore_max_WarrantCPQ__c==null)){
                                                           newinput.get(i).Stima_Appoggio__c=newinput.get(i).FORMStima_Percentuale__c;
                                                       }                                        
                                                }
                                         }
                                     }
                              }
                       }
                    //Condizione 6 Stima:
                    if(((newinput.get(i).Minimo_WarrantCPQ__c==null || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORMStima_Finanziamento_Associato__c) && (newinput.get(i).Massimo_WarrantCPQ__c==null || newinput.get(i).Massimo_WarrantCPQ__c>=newinput.get(i).FORMStima_Finanziamento_Associato__c) && newinput.get(i).Tipo_WarrantCPQ__c!='Progressivo') || newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo'){
                        if(newinput.get(i).Valore_max_WarrantCPQ__c==null 
                           || newinput.get(i).Valore_max_WarrantCPQ__c>=newinput.get(i).FORMStima_Percentuale__c){
                               if(newinput.get(i).Limite_WarrantCPQ__c==null && newinput.get(i).Min_garantito_WarrantCPQ__c!=null && newinput.get(i).FORMStima_Percentuale__c<=newinput.get(i).Min_garantito_WarrantCPQ__c){                                    
                                   newinput.get(i).Stima_Appoggio__c=newinput.get(i).Min_garantito_WarrantCPQ__c;                                    
                               } 
                           }
                    }                                           
                    //Condizione 3 Importo:
                    if(newinput.get(i).Valore_max_WarrantCPQ__c>0 && newinput.get(i).Limite_WarrantCPQ__c==null && newinput.get(i).Valore_max_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Percentuale__c){
                        if(newinput.get(i).Minimo_WarrantCPQ__c==null 
                           || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORM_Importo_Finanziamento_Associato__c){                               
                               if(newinput.get(i).Massimo_WarrantCPQ__c==null 
                                  || newinput.get(i).Massimo_WarrantCPQ__c>newinput.get(i).FORM_Importo_Finanziamento_Associato__c
                                  //NB: Il codice non può entrare nel prossimo OR perchè tipo=='Progressivo' è in contrasto con la Validation Rule "Controllo_tipo" dell'oggetto Condizione__c 
                                  || (newinput.get(i).Massimo_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Finanziamento_Associato__c && newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo')){
                                      newinput.get(i).Importo_Appoggio__c=newinput.get(i).Valore_max_WarrantCPQ__c;
                                  }                                  
                           }
                    }
                    //Condizione 3 Stima:
                    if(newinput.get(i).Valore_max_WarrantCPQ__c>0 && newinput.get(i).Limite_WarrantCPQ__c==null && newinput.get(i).Valore_max_WarrantCPQ__c<=newinput.get(i).FORMStima_Percentuale__c){
                        if(newinput.get(i).Minimo_WarrantCPQ__c==null 
                           || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORMStima_Finanziamento_Associato__c){                               
                               if(newinput.get(i).Massimo_WarrantCPQ__c==null 
                                  || newinput.get(i).Massimo_WarrantCPQ__c>newinput.get(i).FORMStima_Finanziamento_Associato__c
                                  //NB: Il codice non può entrare nel prossimo OR perchè tipo=='Progressivo' è in contrasto con la Validation Rule "Controllo_tipo" dell'oggetto Condizione__c 
                                  || (newinput.get(i).Massimo_WarrantCPQ__c<=newinput.get(i).FORMStima_Finanziamento_Associato__c && newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo')){
                                      newinput.get(i).Stima_Appoggio__c=newinput.get(i).Valore_max_WarrantCPQ__c;
                                  }                                  
                           }
                    }                
                }
                if(newinput.get(i).Fisso_WarrantCPQ__c!=null){                  
                    //Condizione 5 Importo:
                    if(newinput.get(i).Minimo_WarrantCPQ__c==null 
                       || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORM_Importo_Finanziamento_Associato__c){                           
                           if(newinput.get(i).Massimo_WarrantCPQ__c==null 
                              || newinput.get(i).Massimo_WarrantCPQ__c>=newinput.get(i).FORM_Importo_Finanziamento_Associato__c
                              //NB: Il codice non può entrare nel prossimo OR perchè tipo=='Progressivo' è in contrasto con la Validation Rule "Controllo_tipo" dell'oggetto Condizione__c 
                              || (newinput.get(i).Massimo_WarrantCPQ__c<=newinput.get(i).FORM_Importo_Finanziamento_Associato__c && newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo')){
                                  newinput.get(i).Importo_Appoggio__c=newinput.get(i).Fisso_WarrantCPQ__c;
                              }
                       }                       
                    //Condizione 5 Stima:
                    if(newinput.get(i).Minimo_WarrantCPQ__c==null 
                       || newinput.get(i).Minimo_WarrantCPQ__c<newinput.get(i).FORMStima_Finanziamento_Associato__c){                          
                           if(newinput.get(i).Massimo_WarrantCPQ__c==null 
                              || newinput.get(i).Massimo_WarrantCPQ__c>=newinput.get(i).FORMStima_Finanziamento_Associato__c
                              //NB: Il codice non può entrare nel prossimo OR perchè tipo=='Progressivo' è in contrasto con la Validation Rule "Controllo_tipo" dell'oggetto Condizione__c 
                              || (newinput.get(i).Massimo_WarrantCPQ__c<=newinput.get(i).FORMStima_Finanziamento_Associato__c && newinput.get(i).Tipo_WarrantCPQ__c=='Progressivo')){
                                  newinput.get(i).Stima_Appoggio__c=newinput.get(i).Fisso_WarrantCPQ__c;
                              }
                       }
                }
            } else if(newinput.get(i).condizioni_opzionali__r.size()>0){      
                newinput.get(i).Importo_Appoggio__c = (Decimal) CondOpz.get(i).get('importi');
                newinput.get(i).Stima_Appoggio__c = (Decimal) CondOpz.get(i).get('stime');                                                            
            } else if(newinput.get(i).condizioni_opzionali__r.size()==0 && newinput.get(i).Finanziamento__c==null){
                newinput.get(i).Importo_Appoggio__c = newinput.get(i).Fisso_WarrantCPQ__c;
                newinput.get(i).Stima_Appoggio__c = newinput.get(i).Fisso_WarrantCPQ__c;
            }            
            if(newinput.get(i).WRT_Update_da_Rinnovo__c == true){
                newinput.get(i).WRT_Update_da_Rinnovo__c=false;
            } 
        }        
        
        //finito di settare i campi,bisogna fare l'update. Creo una stringa che  dovrebbe contenere gli eventuali errori/successi..
        List<String> res2 = new List<String>(); //cond
        List<String> res = new List<String>();   
        
        // faccio l'update delle condizioni.
        Database.SaveResult[] srListCond = Database.update(newinput.values(), false);        
        
        for (Database.SaveResult sr : srListCond) {
            if (sr.isSuccess()) {            
            } else {             
                for(Database.Error err : sr.getErrors()) {            
                    res2.add(err.getMessage() + 'errore su questi campi condizione:' + err.getFields());
                }
            }
        }
        
        //gestione res
        string c;
        
        if(res2.size()>0){
            c=res2.get(0);
        }
        string uniti=c ;
        if(c!=null){
            res.add(uniti);
        }
        return res;        
    }
}