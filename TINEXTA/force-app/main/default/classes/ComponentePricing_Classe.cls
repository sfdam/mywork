public class ComponentePricing_Classe {
    @auraenabled    
    public static  string RecuperoInfo (id qlid){
        
        //Questa è una lista che contiene tutti i finanziamenti collegati alla qline passata in input + le condizioni associate
        List<Finanziamenti__c> FinCond = [SELECT Id, toLabel(Tipologia_Finanziamento_WarrantCPQ__c),Name, Importo_WarrantCPQ__c, Stima_WarrantCPQ__c, Fattura_WarrantCPQ__c, (SELECT id,Fisso_WarrantCPQ__c,toLabel(Tipologia_Finanziamento_WarrantCPQ__c), Massimo_WarrantCPQ__c, Percentuale_WarrantCPQ__c, Limite_WarrantCPQ__c, FF_WarrantCPQ__c,Minimo_WarrantCPQ__c,Valore_max_WarrantCPQ__c, name,Finanziamento__c,toLabel (Tipo_WarrantCPQ__c), Min_garantito_WarrantCPQ__c,Importo_Appoggio__c,Stima_Appoggio__c, 	Quote_Line__r.SBQQ__Product__c  , WRT_Tipologia_Finanziamento_FORM__c FROM Condizioni__r) FROM Finanziamenti__c WHERE Quote_Line__c =: qlID];
        List <condizioni__c> CondPag = [select WRT_Tipologia_Finanziamento_FORM__c,  Quote_Line__r.SBQQ__Quote__r.WRT_Modalita_pagamento__c,      	Quote_Line__r.SBQQ__Product__c ,Importo_Appoggio__c,Stima_Appoggio__c,id,Fisso_WarrantCPQ__c,Tipologia_Finanziamento_WarrantCPQ__c, Massimo_WarrantCPQ__c, Percentuale_WarrantCPQ__c, Limite_WarrantCPQ__c, FF_WarrantCPQ__c,Minimo_WarrantCPQ__c,Valore_max_WarrantCPQ__c, name,Finanziamento__c, toLabel(Tipo_WarrantCPQ__c), Min_garantito_WarrantCPQ__c, (select id,name,Condizione_WarrantCPQ__c, Procedimento_pagamento__r.Name ,Scadenza_WarrantCPQ__c,toLabel(Probabilita_WarrantCPQ__c),toLabel( Parte_WarrantCPQ__c),	Percentuale_WarrantCPQ__c,toLabel(  Tipo_pagamento_WarrantCPQ__c), toLabel(	Opzione_WarrantCPQ__c) ,Codice_Ordine_Cliente_WarrantCPQ__c,Descrizione_fattura_WarrantCPQ__c,WRT_cig__c,WRT_cup__c,FatturaCheck_WarrantCPQ__c,Formula_Importo_WarrantCPQ__c,Formula_Stima_WarrantCPQ__c, Blocco_riga_pagamento__c ,Formula_Numero_e_data_fattura__c, WRT_Stato_pagamento__c     ,  Anno_nuovo_ordine_WarrantCPQ__c  ,  Data_Ordine_Cliente__c from pagamenti__r )Valore_max_WarrantCPQ__c, (SELECT Id,      WRT_Tipologia_Finanziamento_FORM__c,    Name,CondizionePadre_WarrantCPQ__c,Fisso_WarrantCPQ__c,Tipologia_Finanziamento_WarrantCPQ__c,Massimo_WarrantCPQ__c, Limite_WarrantCPQ__c, Percentuale_WarrantCPQ__c,Minimo_WarrantCPQ__c,	FF_WarrantCPQ__c,toLabel (Tipo_WarrantCPQ__c), Min_garantito_WarrantCPQ__c, Valore_max_WarrantCPQ__c,Formula_Importo_WarrantCPQ__c,Formula_Stima_WarrantCPQ__c FROM Condizioni_Opzionali__r  ORDER BY Minimo_WarrantCPQ__c  ASC  )from condizioni__c where Quote_Line__c =: qlID       ];  
        Map<Id, List<Condizioni__c>> mappa =  new Map<Id, List<Condizioni__c>>();
        //Id ---> Id finanziamento padre
        //List<Condizioni__c> --> tutte le condizioni che matchano tra Id Finanziamento e il campo Finanziamento__c (lookup)
        
        
        
        
        for(Condizioni__c cond : CondPag) {
            if(mappa.containsKey(cond.Finanziamento__c)) {  
                
                List<Condizioni__c> tmpCondList = mappa.get(cond.Finanziamento__c); 
                tmpCondList.add(cond); 
                mappa.put(cond.Finanziamento__c, tmpCondList); 
            }
            else {
                List<Condizioni__c> lista = new List<Condizioni__c>();
                lista.add(cond);
                mappa.put(cond.Finanziamento__c, lista); 
            }
        }
        
        TreeGrid treegrid = new TreeGrid();
        
        treegrid.FinanziamentiArray = new List<TreeGrid.Finanziamento>();
        //fin qua abbiamo inizializzato lo array...dobbiamo metterci fin e cond....
        
        
        
        //"sto aggiungendo un singolo finanziamento al vettore di finanziamenti array..."ma lo sta mascherando con questo oggetto ( treegrid)
        for(Finanziamenti__c fin : FinCond) {   
            TreeGrid.Finanziamento fin1 = new TreeGrid.Finanziamento();
            fin1.thisFin = fin;
            fin1.CondizioniConPagamentiArray = mappa.get(fin.Id);
            
            treegrid.FinanziamentiArray.add(fin1);
        }
        
        for(TreeGrid.Finanziamento f: treegrid.FinanziamentiArray) {
            System.debug('Finanziamento i-esimo: ' + f.thisFin); //Finanziamento__c: {Id=blabla,Name=finanziamento1, ....}
            System.debug('Le sue condizioni + pagamenti: ' + f.CondizioniConPagamentiArray); // Condizioni__c: [{Id=cond1,Name=Condizione1,Pagamenti__r:[{}]}, {Id=cond2,Name=Condizione2,Pagamenti__r:[{}]}, ..., ...]
        }
        
        return JSON.serialize(treegrid);
        
        
        
        
        
        
    }//fine recupero info
    
    
    @auraenabled    
    public static List<condizioni__c> RecuperoInfo2 (id qlid){
        List <condizioni__c> CondPag = [select    WRT_Tipologia_Finanziamento_FORM__c       ,Quote_Line__r.SBQQ__Quote__r.WRT_Modalita_pagamento__c,        Quote_Line__r.SBQQ__Product__c,Importo_Appoggio__c,Stima_Appoggio__c,id,	Fisso_WarrantCPQ__c,Tipologia_Finanziamento_WarrantCPQ__c,Massimo_WarrantCPQ__c, Limite_WarrantCPQ__c, Percentuale_WarrantCPQ__c,Minimo_WarrantCPQ__c,	FF_WarrantCPQ__c, name,Finanziamento__c, toLabel(Tipo_WarrantCPQ__c), Min_garantito_WarrantCPQ__c, Valore_max_WarrantCPQ__c,(select id,name,Condizione_WarrantCPQ__c,Scadenza_WarrantCPQ__c, toLabel( Probabilita_WarrantCPQ__c) ,toLabel( Parte_WarrantCPQ__c),	Percentuale_WarrantCPQ__c,toLabel( Tipo_pagamento_WarrantCPQ__c) , toLabel(	Opzione_WarrantCPQ__c ),Codice_Ordine_Cliente_WarrantCPQ__c,Descrizione_fattura_WarrantCPQ__c,WRT_cig__c,WRT_cup__c,FatturaCheck_WarrantCPQ__c,Formula_Importo_WarrantCPQ__c,Procedimento_pagamento__c,Procedimento_pagamento__r.Name  ,Formula_Stima_WarrantCPQ__c , Formula_Numero_e_data_fattura__c , Blocco_riga_pagamento__c, WRT_Stato_pagamento__c,  Anno_nuovo_ordine_WarrantCPQ__c  ,  Data_Ordine_Cliente__c    from pagamenti__r ), (SELECT   WRT_Tipologia_Finanziamento_FORM__c,   Id,Name,CondizionePadre_WarrantCPQ__c,Fisso_WarrantCPQ__c,Tipologia_Finanziamento_WarrantCPQ__c,Massimo_WarrantCPQ__c, Limite_WarrantCPQ__c, Percentuale_WarrantCPQ__c,Minimo_WarrantCPQ__c,	FF_WarrantCPQ__c,toLabel (Tipo_WarrantCPQ__c), Min_garantito_WarrantCPQ__c, Valore_max_WarrantCPQ__c,Formula_Importo_WarrantCPQ__c,Formula_Stima_WarrantCPQ__c FROM Condizioni_Opzionali__r  ORDER BY Minimo_WarrantCPQ__c  ASC  )from condizioni__c where Quote_Line__c =: qlID and Finanziamento__c = null ];
        
        
        return CondPag;
    } 
    
   
     @auraenabled
    public static boolean RecuperoInfo3(id qlid){
        SBQQ__QuoteLine__c QL = [select id,name,Non_allineare_valore_OPT_con_Pricing__c from SBQQ__QuoteLine__c where id =: qlid];
        
       Boolean Disaccoppiamento = QL.Non_allineare_valore_OPT_con_Pricing__c ;
        
        return Disaccoppiamento ;
        
    }
    
    
    
    
    
    
    
    
    @auraenabled
    public static void CalcoloImportoCondizione (id qlid){
        
        
        list <Funzionalita__c> x =[SELECT id,Disabilita_tutti_i_process_builder__c FROM Funzionalita__c LIMIT 1];
        x[0].Disabilita_tutti_i_process_builder__c= true;
        update x; 
        
        List <condizioni__c> cn = [SELECT id, name,Fisso_WarrantCPQ__c,Limite_WarrantCPQ__c,Percentuale_WarrantCPQ__c,Min_garantito_WarrantCPQ__c,Valore_max_WarrantCPQ__c,Minimo_WarrantCPQ__c ,Massimo_WarrantCPQ__c,Finanziamento__c,Finanziamento__r.Importo_WarrantCPQ__c,Finanziamento__r.Stima_WarrantCPQ__c,Importo_Appoggio__c, Stima_Appoggio__c, Tipo_WarrantCPQ__c,(select id,CondizionePadre_WarrantCPQ__c, name,Formula_Importo_WarrantCPQ__c,Formula_Stima_WarrantCPQ__c from condizioni_opzionali__r) FROM condizioni__c where Quote_Line__c =: qlid];
        List <pagamenti__c> pag = [SELECT id,name from pagamenti__c where Condizione_WarrantCPQ__c in : cn];
        //query che serve per fare un update fittizio ai pagamenti
        
        
        InvocableCalcoloCondizione.ActionRequest action = new InvocableCalcoloCondizione.ActionRequest();
          action.quoteline = qlid;
        InvocableCalcoloCondizione.CalcoloCondizione(new List<InvocableCalcoloCondizione.ActionRequest>{action});
        
        update pag;
        x[0].Disabilita_tutti_i_process_builder__c= false; 
        update x;
        
    } // fine calcolo importo 
    
    
    
    
    @auraenabled
    public static String cancellareFin (id rectodelete, id qlid){

        Boolean result = true;
        Finanziamenti__c f = [SELECT id, Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c, Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c,  Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c, CreatedDate from finanziamenti__c where id =: rectodelete];

        /*
        if(f.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && f.CreatedDate < f.Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c.addHours(-2) && f.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c == 'OK'){
            result = OnFinanziamentiTriggerHandler.eliminaFinanziamentiRelated(rectodelete);
        } else if(f.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && f.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c != 'OK'){
            result = 'Allineare l\'offerta su Infostore prima di procedere con la cancellazione di questa riga';
            return result;
        }
        */

        result = OnFinanziamentiTriggerHandler.eliminaFinanziamentiRelated(rectodelete);

        // if(result != 'OK' && result != ''){
        //     return 'error ws';
        // }
        if(!result) {
            return 'error ws';
        }


        List<Condizioni__c> condizioni = new List<Condizioni__c>([SELECT Id, Name FROM Condizioni__c WHERE Finanziamento__c =: rectodelete]);
        delete f;
        delete condizioni;
        ComponentePricing_Classe.CalcoloImportoCondizione(qlid);

        return 'ok';
    }
    
    @auraenabled
    public static String cancellareCond (id rectodelete,id qlid){
        
        Condizioni__c c = [SELECT id,	Quote_Line__c, 	Quote_Line__r.id, Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c, Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c, Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c, CreatedDate  from Condizioni__c where id =: rectodelete]; 
        Boolean resp = true;

        /*
        if(c.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && c.CreatedDate < c.Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c.addHours(-2) && c.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c == 'OK'){
            resp = OnCondizioniTriggerHandler.eliminaCondizioniRelated(rectodelete);
        } else if(c.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && c.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c != 'OK'){
            resp = 'Allineare l\'offerta su Infostore prima di procedere con la cancellazione di questa riga';
            return resp;
        }
        */

        resp = OnCondizioniTriggerHandler.eliminaCondizioniRelated(rectodelete);

        // if(resp != 'OK' && resp != '')
        //     return 'error ws';
        if(!resp) {
            return 'error ws';
        }
        
        delete c;        
        
        list <Funzionalita__c> x =[SELECT id,Disabilita_tutti_i_process_builder__c FROM Funzionalita__c LIMIT 1];
        x[0].Disabilita_tutti_i_process_builder__c= true;
        update x;        
        list <pagamenti__c> allpag = [select id,name, Quote_Line__c from pagamenti__c where Quote_Line__c =: qlid];
        
        if (allpag.size () > 0){    
            update allpag[0];
        }
        x[0].Disabilita_tutti_i_process_builder__c= false; 
        update x;
        
        return 'ok';
    }
    
    
    
    
    @auraenabled
    public static String cancellarePag (id rectodelete){
        
        Boolean result = true;
        Pagamenti__c p = [SELECT id, Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c, Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c, Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c, CreatedDate from Pagamenti__c where id =: rectodelete];
        
        /*
        if(p.Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && p.CreatedDate < p.Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c.addHours(-2) && p.Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c == 'OK'){
            result = OnPagamentiTriggerHandler.eliminaPagamentiInfostore(new Set<String>{rectodelete});
        } else if(p.Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && p.Condizione_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c != 'OK'){
            result = 'Allineare l\'offerta su Infostore prima di procedere con la cancellazione di questa riga';
            return result;
        }
        */

        result = OnPagamentiTriggerHandler.eliminaPagamentiInfostore(new Set<String>{rectodelete});

        // if(result != 'OK' && result != '')
        //     return 'error ws';
        if(!result) {
            return 'error ws';
        }        

        // Pagamenti__c p = [SELECT id from Pagamenti__c where id =: rectodelete]; 
        delete p;
        
        return 'ok';
    }
    
    @auraenabled
    public static String cancellareOpz (id rectodelete, id qlid){
        
        Boolean result = true;
        Condizione_Opzionale__c co = [SELECT id, CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c, CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c, CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c, CreatedDate from Condizione_Opzionale__c where id =: rectodelete]; 
        
        /*
        if(co.CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && co.CreatedDate < co.CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Ultimo_invio_a_infostore__c.addHours(-2) && co.CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c == 'OK'){
            result = OnCondizioneOpzionaleTriggerHandler.eliminaCondizioniOpzionaliInfostore(new Set<String>{rectodelete});
        } else if(co.CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Numero_Offerta_Infostore__c != null && co.CondizionePadre_WarrantCPQ__r.Quote_Line__r.SBQQ__Quote__r.Risposta_Ultimo_Invio_Infostore__c != 'OK'){
            result = 'Allineare l\'offerta su Infostore prima di procedere con la cancellazione di questa riga';
            return result;
        }
        */

        result = OnCondizioneOpzionaleTriggerHandler.eliminaCondizioniOpzionaliInfostore(new Set<String>{rectodelete});
        
        // if(result != 'OK' && result != '')
        //     return 'error ws';

        if(!result) {
            return 'error ws';
        }

        // Condizione_Opzionale__c co = [SELECT id from Condizione_Opzionale__c where id =: rectodelete]; 
        
        delete co;
        ComponentePricing_Classe.CalcoloImportoCondizione(qlid);
        
        return 'ok';
    }
    
    
    
}//fine classe