public class InvocableRinnoviFinCondPag {
    //Qua setto le variabili di input che mi arrivano dal flow
    public class ActionRequest {
        
        @InvocableVariable
        public String cercologicheid; 
        @InvocableVariable
        public list<Finanziamenti__c> collezFin;
        @InvocableVariable
        public list <Condizioni__c> collezCond;
        @InvocableVariable
        public list <pagamenti__c> collezPag;
       @InvocableVariable
        public list <Condizione_Opzionale__c> collezOpz;
        @InvocableVariable
        public string idqlinenuova ;
       
        
    }
    
    
    //qua rendo le variabili disponibili da usare in questa classe
    
    @InvocableMethod(label='Update FinCondPag')
    
    public static List<String> UpdateFinCondPag (List<ActionRequest> requests){
        String cercologicheid = requests[0].cercologicheid;
        list <Finanziamenti__c> collezFin = requests[0].collezFin;
        list <condizioni__c> collezCond = requests[0].collezCond;
        list <pagamenti__c> collezPag = requests[0].collezPag;
        list <Condizione_Opzionale__c> collezOpz = requests[0].collezOpz;
        string idqlinenuova = requests[0].idqlinenuova ;      



        
        
        //qua faccio la query del singolo record logiche rinnovi che rappresenta il pulsante premuto e quindi come devono cambiare i campi
        Logiche_Rinnovo_WRT__c logi = [SELECT Id, name ,Finanziamento__c,Importo__c, Fattura__c,stima__c,PagPercentPag__c,Azienda__c,Descrizione_Fattura__c,ScadenzaPag__c,tipo__c,Finanziamento_Cond__c, PercentualeCond__c,Fisso__c, Min__c,Max__c,Limite__c,Min_Garantito__c,Valore_Max__c,Procedimento_pagamento__c,Parte__c,Probabilit__c,Opzione__c,Tipo_Pagamento__c,CIG__c,CUP__c,Codice_Ordine_Cliente__c from Logiche_Rinnovo_WRT__c WHERE Id = : cercologicheid];
        
        
        
        //ciclo la lista di condizioni e setto i campi in base al record di logiche
        If(collezCond!= null){
        for (condizioni__c c : collezCond) {
            
            switch on logi.tipo__c {
                when 'IDENTICO' {}
                when 'NESSUNO' {c.Tipo_WarrantCPQ__c = null;}
                when else {c.Tipo_WarrantCPQ__c= logi.tipo__c;}
            }
            switch on logi.Finanziamento_Cond__c {
                when 'IDENTICO' {}
                when 'NESSUNO' {c.Tipologia_Finanziamento_WarrantCPQ__c = null ;}
                when else {c.Tipologia_Finanziamento_WarrantCPQ__c = logi.Finanziamento_Cond__c;}   
            }
            
            switch on logi.PercentualeCond__c {
                when 'Identico' {}
                when 'Nessuno' {c.Percentuale_WarrantCPQ__c = null;}
            }
            switch on logi.fisso__c {
                when 'Identico' {}
                when 'Nessuno' {c.Fisso_WarrantCPQ__c = null;}
            }
            switch on logi.min__c {
                when 'Identico'{}
                when 'Nessuno' {c.Minimo_WarrantCPQ__c = null;}
            }
            switch on logi.max__c{
                when 'Identico' {}
                when 'Nessuno' {c.Massimo_WarrantCPQ__c = null;}
            }
            switch on logi.limite__c {
                when 'Identico'{}
                when 'Nessuno' {c.Limite_WarrantCPQ__c = null;}
            }
            switch on logi.Min_Garantito__c {
                when 'Identico'{}
                when 'Nessuno' {c.Min_garantito_WarrantCPQ__c = null;}
            }
            switch on logi.Valore_Max__c {
                when 'Identico' {}
                When 'Nessuno' {c.Valore_max_WarrantCPQ__c = null;}
            }
            
           
            
        }
        }
        //ciclo la lista di pagamenti e setto i campi in base al record di logiche
        
        
        if (collezPag != null){
        
        for (pagamenti__c p : collezPag){
            
             p.WRT_Update_da_Rinnovo__c = false ;
            system.debug ('errore pag');
            switch on logi.PagPercentPag__c {
                when 'Identico'{}
                when 'Nessuno' {p.Percentuale_WarrantCPQ__c = null;}
            }
            
            switch on logi.Descrizione_Fattura__c{
                when 'Identico' {}
                when 'Nessuno' {p.Descrizione_fattura_WarrantCPQ__c = null;}

            }
            switch on logi.Procedimento_pagamento__c{
                when 'IDENTICO' {}
                when 'NESSUNO' {p.Procedimento_pagamento__c = null;}
            }
            switch on logi.parte__c {
                when 'IDENTICO'{}
                when 'NESSUNO' {p.Parte_WarrantCPQ__c = null;}
                when else {p.Parte_WarrantCPQ__c = logi.parte__c;}
            }
            switch on logi.Probabilit__c {
                when 'IDENTICO'{}
                when 'NESSUNO' {p.Probabilita_WarrantCPQ__c = null;}
                when else {p.Probabilita_WarrantCPQ__c= logi.Probabilit__c;}
            }
            switch on logi.Opzione__c{
                when 'Identico'{}
                when 'Nessuno' {p.Opzione_WarrantCPQ__c = null;}
                when else {p.Opzione_WarrantCPQ__c=logi.Opzione__c;}
            }
            
            switch on logi.Tipo_Pagamento__c{
                when 'IDENTICO'{}
                when 'NESSUNO' {p.Tipo_pagamento_WarrantCPQ__c = null;}
                when else {p.Tipo_pagamento_WarrantCPQ__c = logi.Tipo_Pagamento__c;}
            }
            switch on logi.ScadenzaPag__c{
                
                when null {p.Scadenza_WarrantCPQ__c = null;}
                when '0' {}
                when '1' {p.Scadenza_WarrantCPQ__c= p.Scadenza_WarrantCPQ__c.addYears(1);}
                when '2' {p.Scadenza_WarrantCPQ__c= p.Scadenza_WarrantCPQ__c.addYears(2);}
                when '3' {p.Scadenza_WarrantCPQ__c= p.Scadenza_WarrantCPQ__c.addyears(3);}
                when '4' {p.Scadenza_WarrantCPQ__c= p.Scadenza_WarrantCPQ__c.addYears(4);}
                when '5' {p.Scadenza_WarrantCPQ__c= p.Scadenza_WarrantCPQ__c.addYears(5);}
                
            }   
         
            
        }
            }
        
        
        
        //controllo se la collezione di fin è vuota o no (può succedere che una Qline non ha i Fin ma le cond e pag si). Se non è vuota ciclo
        //la lista di finanziamenti e setto i campi in base al record di logiche 
        
        if ( collezFin != null) {    
            for (Finanziamenti__c f : collezFin ) {
                
                f.WRT_Update_da_Rinnovo__c = false ;
                
                switch on logi.Finanziamento__c {
                    when 'IDENTICO' {}
                    when 'NESSUNO' {f.Tipologia_Finanziamento_WarrantCPQ__c = null ;}
                    when else {f.Tipologia_Finanziamento_WarrantCPQ__c = logi.Finanziamento__c;}
                    
                }
                switch on logi.Importo__c {
                    when 'Identico' {}
                    when 'Nessuno' {f.Importo_WarrantCPQ__c = null ;}
                    when '1000' {f.Importo_WarrantCPQ__c=1000;}
                }
                
                switch on logi.fattura__c {
                    when 'Identico' {}
                    when 'Nessuno' {f.Fattura_WarrantCPQ__c = null; }
                }
                
                switch on logi.stima__c {
                    when 'Identico' {}
                    when 'Nessuno' {f.Stima_WarrantCPQ__c = null;}
                    when '1000' {f.Stima_WarrantCPQ__c=1000;}
                } 
                
            }
        }
          //ciclo la lista di collezOpz e setto i campi in base al record di logiche
        
       if (collezOpz != null){
            for (Condizione_Opzionale__c co : collezOpz){
             
            switch on logi.tipo__c {
                when 'IDENTICO' {}
                when 'NESSUNO' {co.Tipo_WarrantCPQ__c = null;}
                when else {co.Tipo_WarrantCPQ__c= logi.tipo__c;}
            }
            switch on logi.Finanziamento_Cond__c {
                when 'IDENTICO' {}
                when 'NESSUNO' {co.Tipologia_Finanziamento_WarrantCPQ__c = null ;}
                when else {co.Tipologia_Finanziamento_WarrantCPQ__c = logi.Finanziamento_Cond__c;}   
            }
            
            switch on logi.PercentualeCond__c {
                when 'Identico' {}
                when 'Nessuno' {co.Percentuale_WarrantCPQ__c = null;}
            }
            switch on logi.fisso__c {
                when 'Identico' {}
                when 'Nessuno' {co.Fisso_WarrantCPQ__c = null;}
            }
            switch on logi.min__c {
                when 'Identico'{}
                when 'Nessuno' {co.Minimo_WarrantCPQ__c = null;}
            }
            switch on logi.max__c{
                when 'Identico' {}
                when 'Nessuno' {co.Massimo_WarrantCPQ__c = null;}
            }
            switch on logi.limite__c {
                when 'Identico'{}
                when 'Nessuno' {co.Limite_WarrantCPQ__c = null;}
            }
            switch on logi.Min_Garantito__c {
                when 'Identico'{}
                when 'Nessuno' {co.Min_garantito_WarrantCPQ__c = null;}
            }
            switch on logi.Valore_Max__c {
                when 'Identico' {}
                When 'Nessuno' {co.Valore_max_WarrantCPQ__c = null;}
            }
            
                
            }
            
            
            }
        
        
        
        
        
        

        
        
        //finito di settare i campi e fatti i calcoli,bisogna fare l'update. Creo una stringa che  dovrebbe contenere gli eventuali errori/successi..
        List<String> res2 = new List<String>(); //cond
        List<String> res3 = new List<String>(); //pag
        List<String> res4 = new List<String>(); //fin
        List<String> res5 = new List<String>(); //opz
        List<String> res = new List<String>();
        
        
        
        
        // faccio l'update delle condizioni.
        
        If(collezCond!= null){
        Database.SaveResult[] srListCond = Database.update(collezCond, false);
      
        
        //qua catturare errori o successi     
        
        for (Database.SaveResult sr : srListCond) {
            if (sr.isSuccess()) {      
              // res2.add ('Condizione aggiornata:'+ ' ' + sr.getId());
               
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                                       
     res2.add (err.getMessage() + 'errore su questi campi condizione:' + err.getFields());
                    
                   // res.add(err.getStatusCode() + ': ' + err.getMessage());
                   //res.add('condizione fields that affected this error: ' + err.getFields());
                }
            }
        }
        }
        
  if (collezPag != null) {        
        
        //faccio l'update dei pagamenti
        Database.SaveResult[] srListPag = Database.update(collezPag, false);
        
     //qua catturare errori o successi 
        
      
        for (Database.SaveResult sr : srListPag) {
            if (sr.isSuccess()) {
    
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                                       
     res3.add (err.getMessage() + 'errore su questi campi Pagamenti:' + err.getFields());
                    
                   // res.add(err.getStatusCode() + ': ' + err.getMessage());
                   //res.add('condizione fields that affected this error: ' + err.getFields());
                }
            }
        }
       } 

        
        //faccio l'update dei finanziamenti. Anche qui check se sono vuoti.  
        
        
        if (collezFin != null){
            Database.SaveResult[] srListFin = Database.update(collezFin, false);
            
             //qua catturare errori o successi 
        
       
        for (Database.SaveResult sr : srListFin) {
            if (sr.isSuccess()) {
                               
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                                       
     res4.add (err.getMessage() + 'errore su questi campi Finanz:' + err.getFields());
                    
                   // res.add(err.getStatusCode() + ': ' + err.getMessage());
                   //res.add('condizione fields that affected this error: ' + err.getFields());
                }
            }
        }
            
        }
        
        //faccio l'update delle condizioni opzionali
        if (collezOpz != null){
            Database.SaveResult[] srListOpz = Database.update(collezOpz, false);
             //qua catturare errori o successi 
        
       
        for (Database.SaveResult sr : srListOpz) {
            if (sr.isSuccess()) {
                
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                                       
     res5.add (err.getMessage() + 'errore su questi campi Opzionale:' + err.getFields());
                    
                   // res.add(err.getStatusCode() + ': ' + err.getMessage());
                   //res.add('condizione fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        }
        
        
        
        
        //gestione res
        string c;
        string a;
        string d;
        string h;
        
        if (res2.size()>0){
        c =  res2.get(0);
        }
        
        if (res3.size()>0){
          a = res3.get(0);   
        }
        
         if (res4.size()>0){
         d = res4.get(0);   
        }
        
         if (res5.size()>0){
         h = res5.get(0);   
        }
        string uniti = c + a + d + h ;
        if (c != null || a != null || d!=null || h!= null){
        res.add (uniti);
            }
        

        
        return res;
        

        
        
        
    }//fine metodo
}