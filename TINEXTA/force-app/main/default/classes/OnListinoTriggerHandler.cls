public class OnListinoTriggerHandler {

    public static void CalcoloImportoFinanziamento(List <Business_Area_Warrant__c> input, List <Business_Area_Warrant__c> old){

        set<Id> Idfin = new set <Id>();
        List<Business_Area_Warrant__c> Idcond = new List <Business_Area_Warrant__c>();
        List<Business_Area_Warrant__c> Idcondopz = new List <Business_Area_Warrant__c>();

       // id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Finanziamenti' limit 1].Id;
        id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();

        for(Business_Area_Warrant__c b: input){
            If(b.RecordTypeid == rid){
                for(Business_Area_Warrant__c bo: old){
                    if(b.Importo_WarrantCPQ__c != bo.Importo_WarrantCPQ__c || b.Stima_WarrantCPQ__c != bo.Stima_WarrantCPQ__c){
                        Idfin.add(b.id);
                    }
                }
            }

            Map <Id, Business_Area_Warrant__c> MapCond = new Map <Id, Business_Area_Warrant__c> ( [SELECT Id,RecordTypeid,Fin_Associato__c,Cond_Associata__c,CheckTriggerListino__c FROM Business_Area_Warrant__c WHERE Fin_Associato__c IN:idfin]);

            for(Id c: MapCond.keyset()){
                If(MapCond.get(c).CheckTriggerListino__c == false){
                    MapCond.get(c).CheckTriggerListino__c = true;
                } else{
                    MapCond.get(c).CheckTriggerListino__c= false;
                }
                Idcond.add(MapCond.get(c));
            }
            
            system.debug('Id cond' + Idcond);

            Map <Id, Business_Area_Warrant__c> MapOpz = new Map <Id, Business_Area_Warrant__c>([SELECT Id,RecordTypeid,Cond_Associata__c FROM Business_Area_Warrant__c WHERE Cond_Associata__c IN:Idcond and recordtypeid !=: ridpag]);

            System.debug('Mapopz' + Mapopz.values());
            for(Id cz: MapOpz.keyset()){
                Idcondopz.add(MapOpz.get(cz));
            }
            
            system.debug('Id cond opz' + Idcondopz);

            If(MapCond.size()>0 && MapOpz.size()>0 && Idcondopz.size()>0){
                system.debug('Opzionali');
             update Idcondopz;
            }
            else if(MapCond.size()>0 && MapOpz.size()== 0 &&Idcond.size()>0 ){
                system.debug('No Opzionali');
                update Idcond;
            }

        }



    }
    

    public static void CalcoloImportoCondizioniOpzionaliInsert (List <Business_Area_Warrant__c> input){
        
        //Variabili
        set <id> idcondopz = new set<id> ();
        decimal stima = 0 ;
        decimal importo = 0 ;
       
		system.debug('Rid interno' + input);
        
       // id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Condizione Opzionale' limit 1].Id;  
        id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        
        
        
        System.debug('Rid' + rid);
        
        
        // Se sto cambiando o inserendo una cond opz prendo l'id della sua condizione padre
        for (Business_Area_Warrant__c b : input){
            system.debug('Rid interno' + b.RecordTypeId);
            if (b.RecordTypeid == rid){
                idcondopz.add(b.Cond_Associata__c);                
            }
        }
        system.debug ('SET' + idcondopz);   
        

        //Mappo la condizione padre e tutti i suoi figli

        map <id, Business_Area_Warrant__c> bopz = new map <id, Business_Area_Warrant__c> ([select id,name,Cond_Associata__c,FormulaStimaOpzionale__c ,FormulaImportoOpzionale__c from Business_Area_Warrant__c where Cond_Associata__c in :idcondopz and recordtypeid !=: ridpag]);
        map <id, Business_Area_Warrant__c> bcond = new map <id, Business_Area_Warrant__c> ([select id,name,Fin_Associato__c,Importo_Appoggio__c,Stima_Appoggio__c,Fisso_WarrantCPQ__c from Business_Area_Warrant__c where id in :idcondopz]);
        
        system.debug (bopz);
        system.debug (bcond);
        

       //scorro ogni condizione padre presente
        for (id c : bcond.keyset()){

            system.debug('For cond padre');
            
            for (id co : bopz.keyset() ) {

                if(bcond.get(c).id == bopz.get(co).Cond_Associata__c){
                
                    system.debug('For figlio');
                    
                    //se le cond opz hanno un importo, li sommo tutti
                    if (bopz.get(co).FormulaImportoOpzionale__c != null ) {
                        system.debug (bopz.get(co).FormulaImportoOpzionale__c + 'importo bopz');
                        importo += bopz.get(co).FormulaImportoOpzionale__c ;
                    }
                    
                    //se le cond opz hanno una stima,le sommo tutte                              
                    if (bopz.get(co).FormulaStimaOpzionale__c != null){
                        stima += bopz.get(co).FormulaStimaOpzionale__c  ;               
                    }
                }
            }

            //alla cond che stavo scorrendo gli metto le somme e poi resetto le variabili
            
            bcond.get(c).Importo_Appoggio__c = importo ;  
            bcond.get(c).Stima_Appoggio__c = stima ;
            
            system.debug (importo);
            system.debug (stima);
            
            importo = 0;
            stima = 0;
        }//fine ciclo delle condizioni

        If(bcond.size()>0){        
            update bcond.values() ; 
        }
    }




    public static void CalcoloImportoCondizioniOpzionaliUpdate (List <Business_Area_Warrant__c> input, List <Business_Area_Warrant__c> old ){
        
        //Variabili
        set <id> idcondopz = new set<id> ();
        decimal stima = 0 ;
        decimal importo = 0 ;
       

        //id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Condizione Opzionale' limit 1].Id;  
        id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        
        // Se sto cambiando o inserendo una cond opz prendo l'id della sua condizione padre
        for (Business_Area_Warrant__c b : input){
            if (b.RecordTypeid == rid){
                for(Business_Area_Warrant__c bo:old){
                    If(b.FormulaImportoOpzionale__c != bo.FormulaImportoOpzionale__c || b.FormulaStimaOpzionale__c != bo.FormulaStimaOpzionale__c){
                     idcondopz.add(b.Cond_Associata__c);  
                    }
                }              
            }
        }
        system.debug ('SET' + idcondopz);
        

        //Mappo la condizione padre e tutti i suoi figli

        map <id, Business_Area_Warrant__c> bopz = new map <id, Business_Area_Warrant__c> ([select id,name,FormulaStimaOpzionale__c, Cond_Associata__c,FormulaImportoOpzionale__c from Business_Area_Warrant__c where Cond_Associata__c in :idcondopz and recordtypeid !=: ridpag ]);
        map <id, Business_Area_Warrant__c> bcond = new map <id, Business_Area_Warrant__c> ([select id,name,Fin_Associato__c,Importo_Appoggio__c,Stima_Appoggio__c,Fisso_WarrantCPQ__c from Business_Area_Warrant__c where id in :idcondopz]);
        
        system.debug (bopz);
        system.debug (bcond);
        

       //scorro ogni condizione padre presente
        for (id c : bcond.keyset()){

            system.debug('For cond padre');
            
            for (id co : bopz.keyset() ) {

                if(bcond.get(c).id == bopz.get(co).Cond_Associata__c){
                
                    system.debug('For figlio');
                    
                    //se le cond opz hanno un importo, li sommo tutti
                    if (bopz.get(co).FormulaImportoOpzionale__c != null ) {    
                        system.debug (bopz.get(co).FormulaImportoOpzionale__c + 'importo opzionale');
                        importo += bopz.get(co).FormulaImportoOpzionale__c ;
                     system.debug (importo + 'sto sommando gli importi');
                    }
                    system.debug (importo + 'ho sommato gli importi');
                    
                    //se le cond opz hanno una stima,le sommo tutte                              
                    if (bopz.get(co).FormulaStimaOpzionale__c != null){
                        stima += bopz.get(co).FormulaStimaOpzionale__c  ;               
                    }
                }
            }

            //alla cond che stavo scorrendo gli metto le somme e poi resetto le variabili
            system.debug (importo + 'importo finale che sto per mettere alla cond');
            bcond.get(c).Importo_Appoggio__c = importo ;  
            bcond.get(c).Stima_Appoggio__c = stima ;
            
            system.debug (importo + 'importo finale che ho messo alla cond');
            system.debug (stima);
            
            importo = 0;
            stima = 0;
        }//fine ciclo delle condizioni

        If(bcond.size()>0){        
            update bcond.values() ; 
        }
    }
    
    public static void CalcoloImportoCondizione (List <Business_Area_Warrant__c> input, List <Business_Area_Warrant__c> old){

        //Variabili
        set <id> idcond = new set<id> ();
        set <id> idfin = new set <id> ();

        //id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Condizioni' limit 1].Id;  
          id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
            id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        //se sto facendo un insert o update di una condizione, salvo sia la condizione stessa che il suo fin correlato

        for (Business_Area_Warrant__c b : input){
            if (b.RecordTypeid == rid){
                for(Business_Area_Warrant__c bo: old){
                    If(b.Fin_Associato__c != bo.Fin_Associato__c || b.CheckTriggerListino__c != bo.CheckTriggerListino__c ||b.Tipo_WarrantCPQ__c != bo.Tipo_WarrantCPQ__c ||b.Minimo_WarrantCPQ__c!=bo.Minimo_WarrantCPQ__c ||b.Min_garantito_WarrantCPQ__c!= bo.Min_garantito_WarrantCPQ__c|| b.Fisso_WarrantCPQ__c != bo.Fisso_WarrantCPQ__c || b.Massimo_WarrantCPQ__c != bo.Massimo_WarrantCPQ__c || b.Limite_WarrantCPQ__c!= bo.Limite_WarrantCPQ__c || b.Valore_max_WarrantCPQ__c!= bo.Valore_max_WarrantCPQ__c ||b.Percentuale_WarrantCPQ__c!= bo.Percentuale_WarrantCPQ__c ){
                        idcond.add(b.id);
                        idfin.add(b.Fin_Associato__c);
                    }
                }
            }    
        }

        system.debug ('SET' + idcond);
        


        //mappo tutte le condizioni correlate a quel finanziamento? Non mi serve
        map <id, Business_Area_Warrant__c> bcond = new map <id, Business_Area_Warrant__c> ([select id,name,Percentuale_WarrantCPQ__c,Limite_WarrantCPQ__c,Min_garantito_WarrantCPQ__c,Fin_Associato__r.Importo_WarrantCPQ__c,Fin_Associato__r.Stima_WarrantCPQ__c,Massimo_WarrantCPQ__c,Valore_max_WarrantCPQ__c,Minimo_WarrantCPQ__c,Tipo_WarrantCPQ__c,Fin_Associato__c,Importo_Appoggio__c,Stima_Appoggio__c,Fisso_WarrantCPQ__c from Business_Area_Warrant__c where id in :idcond]);   
        
        //Mappo tutte le condizioni opzionali solo per controllare che siano vuote --> se la condizione ha figli ho bisogno che parta il metodo 1 solo se sto cambiando il valore del Finanziamento
        map <id, Business_Area_Warrant__c> bopz = new map <id, Business_Area_Warrant__c> ([select id,name,FormulaStimaOpzionale__c ,FormulaImportoOpzionale__c from Business_Area_Warrant__c where Cond_Associata__c in :idcond and recordtypeid !=: ridpag]);  
        
        system.debug('Map cond' + bcond.values());
        system.debug('Map cond' + bopz.values());
        
        if (bopz.size() == 0 ){
           
            
            
            
            system.debug('No figli');
            //scorro ogni condizione presente
            for (id c : bcond.keyset()){
                
                
            //Casistica senza figli disattivata, l'utente compilerà manualmente la condizione singola con finanziamento.     
            
            
           /*     
                
          //nuove regole 13.01.2021
          //casi del tutto null tranne 1 campo:
              
        if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c != null && bcond.get(c).Percentuale_WarrantCPQ__c ==null && bcond.get(c).Minimo_WarrantCPQ__c ==null && bcond.get(c).Massimo_WarrantCPQ__c == null && bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null  ) {
                
            bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c ;
            bcond.get(c).Stima_Appoggio__c =   bcond.get(c).Fisso_WarrantCPQ__c ;
           } 
                else if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c == null && bcond.get(c).Percentuale_WarrantCPQ__c != null && bcond.get(c).Minimo_WarrantCPQ__c ==null && bcond.get(c).Massimo_WarrantCPQ__c == null && bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null ){
             bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
             bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                   }   

                
          //caso del tutto null tranne min e % e importo/stima Fin > min---> prima era >=
          
           else if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c == null && bcond.get(c).Percentuale_WarrantCPQ__c !=null && bcond.get(c).Minimo_WarrantCPQ__c !=null && bcond.get(c).Massimo_WarrantCPQ__c == null &&
                 bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null ){

                     if ( bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c){
                         bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                     }
                     if ( bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c >  bcond.get(c).Minimo_WarrantCPQ__c) {
                          bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                     }
                     
                 }  
                
                
                
              // caso del tutto null tranne min e fisso e importo/stima Fin > min---> prima era >=
                
else if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c != null && bcond.get(c).Percentuale_WarrantCPQ__c ==null && bcond.get(c).Minimo_WarrantCPQ__c !=null && bcond.get(c).Massimo_WarrantCPQ__c == null &&
                 bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null){

                     if ( bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c){
                          bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                         
                     }
                     if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c  > bcond.get(c).Minimo_WarrantCPQ__c){
                          bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                     }
                     
                 } 




                 //fine nuove regole 13.01.2021 con else prima del tipo fisso
                

             else   if (bcond.get(c).Tipo_WarrantCPQ__c == 'FISSO' && bcond.get(c).Fin_Associato__c != null) {
                    system.debug('Fisso');
                    //se è di tipo fisso, setta importo
                    if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c <= bcond.get(c).Massimo_WarrantCPQ__c ){
                        bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                    }
                    
                    //se è di tipo fisso, setta stima
                    if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c <= bcond.get(c).Massimo_WarrantCPQ__c ){
                        bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;   
                    }
                    
                    system.debug('Importo ' + c +  bcond.get(c).Importo_Appoggio__c);
                    system.debug('Importo ' + c +  bcond.get(c).Stima_Appoggio__c);
                }
                
                //invece, se è di tipo variabile..
                else if (bcond.get(c).Tipo_WarrantCPQ__c == 'VARIABILE'&& bcond.get(c).Fin_Associato__c != null){
                    
                    system.debug('Variabile');
                    //Importo
                    
                    //caso4:
                    if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Valore_max_WarrantCPQ__c  && bcond.get(c).Valore_max_WarrantCPQ__c != 0){    
                        bcond.get(c).Importo_Appoggio__c = bcond.get(c).Valore_max_WarrantCPQ__c ;                   
                    }
                                       
                    //caso3:
                    else if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c &&  bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c  * bcond.get(c).Percentuale_WarrantCPQ__c /100 < bcond.get(c).Min_garantito_WarrantCPQ__c && bcond.get(c).Min_garantito_WarrantCPQ__c != 0){
                        bcond.get(c).Importo_Appoggio__c = bcond.get(c).Min_garantito_WarrantCPQ__c;
                    }

                    //caso2:
                    else if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c != null && bcond.get(c).Massimo_WarrantCPQ__c != 0) ){
                        bcond.get(c).Importo_Appoggio__c = (bcond.get(c).Massimo_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                    }
    
                    //caso1:
                    else if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Limite_WarrantCPQ__c== null || bcond.get(c).Limite_WarrantCPQ__c== 0)){
                        bcond.get(c).Importo_Appoggio__c =   bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c *  bcond.get(c).Percentuale_WarrantCPQ__c /100;
                    }
                    
                    //caso 2bis:
                    else if(bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c == null || bcond.get(c).Massimo_WarrantCPQ__c == 0 || bcond.get(c).Massimo_WarrantCPQ__c > bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c)){
                        bcond.get(c).Importo_Appoggio__c = (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c /100 ;
                    }
                    
                    else {bcond.get(c).Importo_Appoggio__c = 0;}
                         
                    system.debug('Importo ' + c +  bcond.get(c).Importo_Appoggio__c);
                    

                    
                    //Stima
                    
                    //Caso 4 stima
                    if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Valore_max_WarrantCPQ__c  && bcond.get(c).Valore_max_WarrantCPQ__c != 0){     
                        bcond.get(c).Stima_Appoggio__c = bcond.get(c).Valore_max_WarrantCPQ__c ;                   
                    }
                    
                    //Caso 3 stima
                    else if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c &&  bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100 <  bcond.get(c).Min_garantito_WarrantCPQ__c &&  bcond.get(c).Min_garantito_WarrantCPQ__c != 0){
                        bcond.get(c).Stima_Appoggio__c =  bcond.get(c).Min_garantito_WarrantCPQ__c;
                    }
                    
                    //Caso 2 stima
                    else if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c != null && bcond.get(c).Massimo_WarrantCPQ__c != 0)){
                        bcond.get(c).Stima_Appoggio__c = (bcond.get(c).Massimo_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                    }
                    
                    
                    //Caso 1 stima
                    else if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Limite_WarrantCPQ__c== null || bcond.get(c).Limite_WarrantCPQ__c== 0)){
                        bcond.get(c).Stima_Appoggio__c =   bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c / 100;
                    }
                    
                    //Caso 2 bis stima
                    else if(bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c == null || bcond.get(c).Massimo_WarrantCPQ__c == 0 || bcond.get(c).Massimo_WarrantCPQ__c > bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c)){
                        bcond.get(c).Stima_Appoggio__c = (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c / 100;
                    }
                    
                    else {bcond.get(c).Stima_Appoggio__c = 0;}
                    
                    system.debug('Stima' + c + bcond.get(c).Stima_Appoggio__c);
                }

                */
                
                

                if(bcond.get(c).Fin_Associato__c == null){
                    bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                    bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;

                    system.debug('Importo' + bcond.get(c).Importo_Appoggio__c);
                    system.debug('Stima' + bcond.get(c).Stima_Appoggio__c);
                }
            }  
        }
        
       if(bcond.size() >0 && bopz.size()==0){ 
       update bcond.values ();
       }
    }

    public static void CalcoloImportoCondizioneInsert (List <Business_Area_Warrant__c> input){

        //Variabili
        set <id> idcond = new set<id> ();
        set <id> idfin = new set <id> ();

       // id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Condizioni' limit 1].Id;  
        id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
               id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId(); 
        //se sto facendo un insert o update di una condizione, salvo sia la condizione stessa che il suo fin correlato

        for (Business_Area_Warrant__c b : input){
            if (b.RecordTypeid == rid){
                    idcond.add(b.id);
                    idfin.add(b.Fin_Associato__c);
                }
            }    
        

        system.debug ('SET' + idcond);
        


        //mappo tutte le condizioni correlate a quel finanziamento? Non mi serve
        map <id, Business_Area_Warrant__c> bcond = new map <id, Business_Area_Warrant__c> ([select id,name,Percentuale_WarrantCPQ__c,Limite_WarrantCPQ__c,Min_garantito_WarrantCPQ__c,Fin_Associato__r.Importo_WarrantCPQ__c,Fin_Associato__r.Stima_WarrantCPQ__c,Massimo_WarrantCPQ__c,Valore_max_WarrantCPQ__c,Minimo_WarrantCPQ__c,Tipo_WarrantCPQ__c,Fin_Associato__c,Importo_Appoggio__c,Stima_Appoggio__c,Fisso_WarrantCPQ__c from Business_Area_Warrant__c where id in :idcond]);   
        
        //Mappo tutte le condizioni opzionali solo per controllare che siano vuote --> se la condizione ha figli ho bisogno che parta il metodo 1 solo se sto cambiando il valore del Finanziamento
        map <id, Business_Area_Warrant__c> bopz = new map <id, Business_Area_Warrant__c> ([select id,name,FormulaStimaOpzionale__c ,FormulaImportoOpzionale__c from Business_Area_Warrant__c where Cond_Associata__c in :idcond and recordtypeid !=: ridpag]);  
        
        system.debug('Map cond' + bcond.values());
        system.debug('Map cond' + bopz.values());
        
        if (bopz.size() == 0 ){
            system.debug('No figli');
            //scorro ogni condizione presente
            for (id c : bcond.keyset()){
                
                 
            //Casistica senza figli disattivata, l'utente compilerà manualmente la condizione singola con finanziamento.      
            /*    
                
                
                //nuove regole 13.01.2021
          //casi del tutto null tranne 1 campo:
              
        if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c != null && bcond.get(c).Percentuale_WarrantCPQ__c ==null && bcond.get(c).Minimo_WarrantCPQ__c ==null && bcond.get(c).Massimo_WarrantCPQ__c == null && bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null  ) {
                
            bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c ;
            bcond.get(c).Stima_Appoggio__c =   bcond.get(c).Fisso_WarrantCPQ__c ;
           } 
                else if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c == null && bcond.get(c).Percentuale_WarrantCPQ__c != null && bcond.get(c).Minimo_WarrantCPQ__c ==null && bcond.get(c).Massimo_WarrantCPQ__c == null && bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null ){
             bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
             bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                   }   

                
          //caso del tutto null tranne min e % e importo/stima Fin > min---> prima era >=
          
           else if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c == null && bcond.get(c).Percentuale_WarrantCPQ__c !=null && bcond.get(c).Minimo_WarrantCPQ__c !=null && bcond.get(c).Massimo_WarrantCPQ__c == null &&
                 bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null ){

                     if ( bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c){
                         bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                     }
                     if ( bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c >  bcond.get(c).Minimo_WarrantCPQ__c) {
                          bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                     }
                     
                 }  
                
                
                
              // caso del tutto null tranne min e fisso e importo/stima Fin > min---> prima era >=
                
else if (bcond.get(c).Fin_Associato__c != null && bcond.get(c).Fisso_WarrantCPQ__c != null && bcond.get(c).Percentuale_WarrantCPQ__c ==null && bcond.get(c).Minimo_WarrantCPQ__c !=null && bcond.get(c).Massimo_WarrantCPQ__c == null &&
                 bcond.get(c).Limite_WarrantCPQ__c == null && bcond.get(c).Min_garantito_WarrantCPQ__c == null && bcond.get(c).Valore_max_WarrantCPQ__c == null){

                     if ( bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c){
                          bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                         
                     }
                     if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c  > bcond.get(c).Minimo_WarrantCPQ__c){
                          bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                     }
                     
                 } 




                 //fine nuove regole 13.01.2021 con else prima del tipo fisso
                

                
                
              else  if (bcond.get(c).Tipo_WarrantCPQ__c == 'FISSO' && bcond.get(c).Fin_Associato__c != null) {
                    system.debug('Fisso');
                    //se è di tipo fisso, setta importo
                    if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c <= bcond.get(c).Massimo_WarrantCPQ__c ){
                        bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                    }
                    
                    //se è di tipo fisso, setta stima
                    if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c <= bcond.get(c).Massimo_WarrantCPQ__c ){
                        bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;   
                    }
                    
                    system.debug('Importo ' + c +  bcond.get(c).Importo_Appoggio__c);
                    system.debug('Importo ' + c +  bcond.get(c).Stima_Appoggio__c);
                }
                
                //invece, se è di tipo variabile..
                else if (bcond.get(c).Tipo_WarrantCPQ__c == 'VARIABILE' && bcond.get(c).Fin_Associato__c != null){
                    
                    system.debug('Variabile');
                    //Importo
                    
                    //caso4:
                    if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Valore_max_WarrantCPQ__c  && bcond.get(c).Valore_max_WarrantCPQ__c != 0){    
                        bcond.get(c).Importo_Appoggio__c = bcond.get(c).Valore_max_WarrantCPQ__c ;                   
                    }
                                       
                    //caso3:
                    else if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c &&  bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100 < bcond.get(c).Min_garantito_WarrantCPQ__c && bcond.get(c).Min_garantito_WarrantCPQ__c != 0){
                        bcond.get(c).Importo_Appoggio__c = bcond.get(c).Min_garantito_WarrantCPQ__c;
                    }

                    //caso2:
                    else if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c != null && bcond.get(c).Massimo_WarrantCPQ__c != 0) ){
                        bcond.get(c).Importo_Appoggio__c = (bcond.get(c).Massimo_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                    }
    
                    //caso1:
                    else if (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Limite_WarrantCPQ__c== null || bcond.get(c).Limite_WarrantCPQ__c== 0)){
                        bcond.get(c).Importo_Appoggio__c =   bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c *  bcond.get(c).Percentuale_WarrantCPQ__c /100;
                    }
                    
                    //caso 2bis:
                    else if(bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c == null || bcond.get(c).Massimo_WarrantCPQ__c == 0 || bcond.get(c).Massimo_WarrantCPQ__c > bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c)){
                        bcond.get(c).Importo_Appoggio__c = (bcond.get(c).Fin_Associato__r.Importo_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c /100 ;
                    }
                    
                    else {bcond.get(c).Importo_Appoggio__c = 0;}
                         
                    system.debug('Importo ' + c +  bcond.get(c).Importo_Appoggio__c);
                    

                    
                    //Stima
                    
                    //Caso 4 stima
                    if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Valore_max_WarrantCPQ__c  && bcond.get(c).Valore_max_WarrantCPQ__c != 0){     
                        bcond.get(c).Stima_Appoggio__c = bcond.get(c).Valore_max_WarrantCPQ__c ;                   
                    }
                    
                    //Caso 3 stima
                    else if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c &&  bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c /100 <  bcond.get(c).Min_garantito_WarrantCPQ__c &&  bcond.get(c).Min_garantito_WarrantCPQ__c != 0){
                        bcond.get(c).Stima_Appoggio__c =  bcond.get(c).Min_garantito_WarrantCPQ__c;
                    }
                    
                    //Caso 2 stima
                    else if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c != null && bcond.get(c).Massimo_WarrantCPQ__c != 0)){
                        bcond.get(c).Stima_Appoggio__c = (bcond.get(c).Massimo_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c /100;
                    }
                    
                    
                    //Caso 1 stima
                    else if (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c  <= bcond.get(c).Massimo_WarrantCPQ__c && (bcond.get(c).Limite_WarrantCPQ__c== null || bcond.get(c).Limite_WarrantCPQ__c== 0)){
                        bcond.get(c).Stima_Appoggio__c =   bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c * bcond.get(c).Percentuale_WarrantCPQ__c / 100;
                    }
                    
                    //Caso 2 bis stima
                    else if(bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c > bcond.get(c).Minimo_WarrantCPQ__c && bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c >= bcond.get(c).Limite_WarrantCPQ__c && (bcond.get(c).Massimo_WarrantCPQ__c == null || bcond.get(c).Massimo_WarrantCPQ__c == 0 || bcond.get(c).Massimo_WarrantCPQ__c > bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c)){
                        bcond.get(c).Stima_Appoggio__c = (bcond.get(c).Fin_Associato__r.Stima_WarrantCPQ__c - bcond.get(c).Minimo_WarrantCPQ__c) * bcond.get(c).Percentuale_WarrantCPQ__c / 100;
                    }
                    
                    else {bcond.get(c).Stima_Appoggio__c = 0;}
                    
                    system.debug('Stima' + c + bcond.get(c).Stima_Appoggio__c);
                }

               */

                if(bcond.get(c).Fin_Associato__c == null){
                    bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                    bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;

                    system.debug('Importo' + bcond.get(c).Importo_Appoggio__c);
                    system.debug('Stima' + bcond.get(c).Stima_Appoggio__c);
                }
            }  
        }
        
       if(bcond.size() >0 && bopz.size()==0){ 
       update bcond.values ();
       }
    }


        public static void CalcoloImportoFinanziamentoDelete(List <Business_Area_Warrant__c> input){

        set<Id> Idfin = new set <Id>();
        decimal stima = 0 ;
        decimal importo = 0 ;
        List<Business_Area_Warrant__c> Idcond = new List <Business_Area_Warrant__c>();
        List<Business_Area_Warrant__c> Idcondopz = new List <Business_Area_Warrant__c>();

        //id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Finanziamenti' limit 1].Id;
           id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId();
               id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
            
        for(Business_Area_Warrant__c b: input){
            If(b.RecordTypeid == rid){
                        Idfin.add(b.id);
                    }
            }

            Map <Id, Business_Area_Warrant__c> bcond = new Map <Id, Business_Area_Warrant__c> ( [SELECT Id,Fisso_WarrantCPQ__c,Stima_Appoggio__c,RecordTypeid,Fin_Associato__c,Cond_Associata__c,CheckTriggerListino__c,Importo_Appoggio__c FROM Business_Area_Warrant__c WHERE Fin_Associato__c IN:idfin]);
            
           for(Id c: bcond.keyset()){
                Idcond.add(bcond.get(c));
            }

            system.debug('Id cond' + Idcond);

            Map <Id, Business_Area_Warrant__c> bopz = new Map <Id, Business_Area_Warrant__c>([SELECT Id,Fisso_WarrantCPQ__c,RecordTypeid,Cond_Associata__c,Importo_Appoggio__c FROM Business_Area_Warrant__c WHERE Cond_Associata__c IN:Idcond and recordtypeid !=: ridpag]);

            System.debug('Mapopz' + bopz.values());
            
            system.debug('Id cond opz' + Idcondopz);

            If(bcond.size()>0 && bopz.size()>0){
                system.debug('Opzionali');
                for (id c : bcond.keyset()){
                    system.debug('For cond padre');
            
                    for (id co : bopz.keyset() ) {
                        if(bcond.get(c).id == bopz.get(co).Cond_Associata__c){
                            system.debug('Condizione Associata');
        
                            //se le cond opz hanno un importo, li sommo tutti
                            if (bopz.get(co).Fisso_WarrantCPQ__c != null ) {    
                                importo += bopz.get(co).Fisso_WarrantCPQ__c ;
                            }
                            
                            //se le cond opz hanno una stima,le sommo tutte                              
                            if (bopz.get(co).Fisso_WarrantCPQ__c != null){
                                stima += bopz.get(co).Fisso_WarrantCPQ__c  ;               
                            }
                        }
                    }

                    //alla cond che stavo scorrendo gli metto le somme e poi resetto le variabili
            
                    bcond.get(c).Importo_Appoggio__c = importo ;  
                    bcond.get(c).Stima_Appoggio__c = stima ;
                    
                    system.debug (importo);
                    system.debug (stima);
                    
                    importo = 0;
                    stima = 0;
                }
                If(bcond.size()>0){        
                    update bcond.values() ; 
                }
            }
            else if(bcond.size()>0 && bopz.size()== 0){
                system.debug('No Opzionali');
                for (id c : bcond.keyset()){
                    system.debug('For Condizioni');
                    bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                    bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;

                    system.debug('Importo' + bcond.get(c).Importo_Appoggio__c);
                    system.debug('Stima' + bcond.get(c).Stima_Appoggio__c);
                }  
        
                if(bcond.size() >0 && bopz.size()==0){ 
                    update bcond.values ();
                }
            }
        }        


public static void CalcoloCondizioneDelete(List <Business_Area_Warrant__c> input){

        set<Id> idc = new set <Id>();
        List<Business_Area_Warrant__c> Idcondopz = new List <Business_Area_Warrant__c>();

        //id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Condizioni' limit 1].Id;
           id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
      id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();

        for(Business_Area_Warrant__c b: input){
            If(b.RecordTypeid == rid){
                        idc.add(b.id);
                    }
            }

            system.debug('Id cond' + Idc);

            List <Business_Area_Warrant__c> bopz = new List <Business_Area_Warrant__c>([SELECT Id,Cond_Associata__c FROM Business_Area_Warrant__c WHERE Cond_Associata__c IN:Idc  and recordtypeid !=: ridpag]);

            System.debug('Mapopz' + bopz);

                

            try {
                delete bopz;
            } catch (DmlException e) {
                // Process exception here
            }



	}



public static void CalcoloCondizioneOpzionaleDelete(List <Business_Area_Warrant__c> input){

        set<Id> idpadre = new set <Id>();
        set<Id> idcond= new set<Id>();
        decimal stima = 0 ;
        decimal importo = 0 ;
        List<Business_Area_Warrant__c> Idcondopz = new List <Business_Area_Warrant__c>();

       // id rid = [select id from RecordType where SObjectType = 'Business_Area_Warrant__c' and name = 'Condizione Opzionale' limit 1].Id;
       id rid = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();
            id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();

        for(Business_Area_Warrant__c b: input){
            If(b.RecordTypeid == rid){
                idpadre.add(b.Cond_Associata__c);
                idcond.add(b.id);
            }
        }

            system.debug('Id cond' + idpadre);

        Map <Id, Business_Area_Warrant__c> bcond = new Map <Id, Business_Area_Warrant__c> ( [SELECT Id,Fisso_WarrantCPQ__c,Stima_Appoggio__c,RecordTypeid,Fin_Associato__c,Cond_Associata__c,CheckTriggerListino__c,Importo_Appoggio__c FROM Business_Area_Warrant__c WHERE Id IN:idpadre]);

        Map <Id, Business_Area_Warrant__c> bopz = new Map <Id, Business_Area_Warrant__c>([SELECT Id,FormulaImportoOpzionale__c,FormulaStimaOpzionale__c,Formula_Importo_Finanziamento_Associato__c,Tipo_WarrantCPQ__c,Cond_Associata__c,Fisso_WarrantCPQ__c FROM Business_Area_Warrant__c WHERE Cond_Associata__c IN:Idpadre AND Id NOT IN: idcond and recordtypeid !=: ridpag]);

        System.debug('Mapopz' + bopz);
        System.debug('Map padre' + bcond);


        if(bopz.size()>0){
            for (id c : bcond.keyset()){
                system.debug('For cond padre');
                for (id co : bopz.keyset() ) {
                    if(bcond.get(c).id == bopz.get(co).Cond_Associata__c){
                        system.debug('Condizione Associata');

                        if (bopz.get(co).FormulaImportoOpzionale__c != null ) {    
                            importo += bopz.get(co).FormulaImportoOpzionale__c ;
                        }
                    
                        //se le cond opz hanno una stima,le sommo tutte                              
                        if (bopz.get(co).FormulaStimaOpzionale__c != null){
                            stima += bopz.get(co).FormulaStimaOpzionale__c  ;               
                        }
                    }
                }
                bcond.get(c).Importo_Appoggio__c = importo ;  
                bcond.get(c).Stima_Appoggio__c = stima ;
            
                system.debug (importo);
                system.debug (stima);
            
                importo = 0;
                stima = 0;
            }//fine ciclo delle condizioni

            If(bcond.size()>0){        
                update bcond.values() ; 
            }
        }else{
            for (id c : bcond.keyset()){
                system.debug('For Condizioni Padre, non ci sono altri figli');
                bcond.get(c).Importo_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;
                bcond.get(c).Stima_Appoggio__c = bcond.get(c).Fisso_WarrantCPQ__c;

                system.debug('Importo' + bcond.get(c).Importo_Appoggio__c);
                system.debug('Stima' + bcond.get(c).Stima_Appoggio__c);
            }  
        
            if(bcond.size() >0 && bopz.size()==0){ 
                update bcond.values ();
            }

        }
	}

}