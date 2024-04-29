public class InvocableRinnoviCalcoloCondizione {
    //Qua setto le variabili di input che mi arrivano dal flow
    public class ActionRequest {
        
       
        @InvocableVariable
        public string idqlinenuova ;
        
        
        
    }
    
    //qua rendo le variabili disponibili da usare in questa classe 
    @InvocableMethod (label='Calcolo condizione')

    public static List<String> CalcoloCondizione (List<ActionRequest> requests){
       
         string idqlinenuova = requests[0].idqlinenuova ;
     
        
   List <condizioni__c> cnlist = [SELECT id, WRT_Update_da_Rinnovo__c,name,Fisso_WarrantCPQ__c,Limite_WarrantCPQ__c,Percentuale_WarrantCPQ__c,Min_garantito_WarrantCPQ__c,Valore_max_WarrantCPQ__c,Minimo_WarrantCPQ__c ,Massimo_WarrantCPQ__c,Finanziamento__c,Finanziamento__r.Importo_WarrantCPQ__c,Finanziamento__r.Stima_WarrantCPQ__c,Importo_Appoggio__c, Stima_Appoggio__c, Tipo_WarrantCPQ__c,(select id,CondizionePadre_WarrantCPQ__c, name,Formula_Importo_WarrantCPQ__c,Formula_Stima_WarrantCPQ__c , Percentuale_WarrantCPQ__c , WRT_Tipologia_Finanziamento_FORM__c, Fisso_WarrantCPQ__c from condizioni_opzionali__r) FROM condizioni__c where Quote_Line__c =: idqlinenuova];
 List <finanziamenti__c> fnlist =[select id, name,WRT_Update_da_Rinnovo__c from finanziamenti__c  where Quote_Line__c =: idqlinenuova];
  list <pagamenti__c> paglist =[select id,name,WRT_Update_da_Rinnovo__c from pagamenti__c  where Quote_Line__c =: idqlinenuova];
        
      
         
        
        
      
        
        // due variabili
        decimal stima = 0 ;
        decimal importo = 0 ;
        
        if (cnlist.size() != 0){
        //scorro ogni condizione presente
        for (condizioni__c c : cnlist){
            
            
            
            //SE NON HA FIGLI ED è COLLEGATA AD 1 FIN
            if (c.condizioni_opzionali__r.size() == 0 && c.Finanziamento__c != null) {
                

                    
                // I M P O R T O  
                //Gruppo del Fin.importo * %
                
                
                
                if ( 
                    
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null) 
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c >= c.Finanziamento__r.Importo_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c != null && c.Limite_WarrantCPQ__c <= c.Finanziamento__r.Importo_WarrantCPQ__c && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c != null && c.Min_garantito_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c != null && c.Valore_max_WarrantCPQ__c > c.Finanziamento__r.Importo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 )
                    
                )   {
                    c.Importo_Appoggio__c = c.Finanziamento__r.Importo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100;
                }
                
                
                
                //Gruppo del Fisso, importo.
                
                else IF(
                    
                    
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c >= c.Finanziamento__r.Importo_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c != null && c.Limite_WarrantCPQ__c <= c.Finanziamento__r.Importo_WarrantCPQ__c && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                ){
                    c.Importo_Appoggio__c = c.Fisso_WarrantCPQ__c ; 
                    
                }
                
                
                //Gruppo del minimo garantito, importo.
                
                else IF(
                    
                    c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c != null && c.Min_garantito_WarrantCPQ__c > c.Finanziamento__r.Importo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 && c.Valore_max_WarrantCPQ__c == null 
                    
                    
                ){
                    c.Importo_Appoggio__c = c.Min_garantito_WarrantCPQ__c ;
                }
                
                //Gruppo del valore max, importo.
                
                else IF(
                    
                    c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c != null && c.Valore_max_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 
                ){
                    c.Importo_Appoggio__c =  c.Valore_max_WarrantCPQ__c;  
                }
                
                //Gruppo scaglione progressivo superato, importo.
                
                
                else IF(
                    
                    c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null && c.Tipo_WarrantCPQ__c == 'Progressivo'
                ){
                    c.Importo_Appoggio__c = c.Massimo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100  ;
                }
                
                //Gruppo scaglione progressivo centrato, importo.
                
                else  IF(
                    
                    (c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c > c.Finanziamento__r.Importo_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null && c.Tipo_WarrantCPQ__c == 'Progressivo')
                    
                    ||
                    
                    (c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Importo_WarrantCPQ__c && c.Massimo_WarrantCPQ__c == null &&  c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null && c.Tipo_WarrantCPQ__c == 'Progressivo')
                    
                ){
                    c.Importo_Appoggio__c = ( c.Finanziamento__r.Importo_WarrantCPQ__c - c.Minimo_WarrantCPQ__c ) * c.Percentuale_WarrantCPQ__c/100;
                }
                
                else {c.Importo_Appoggio__c = 0;}
                
                //S T I M A
                
                //Gruppo del Fin.stima * %
                
                if (
                    
                    
                    
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' &&  c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c >= c.Finanziamento__r.Stima_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c != null && c.Limite_WarrantCPQ__c <= c.Finanziamento__r.Stima_WarrantCPQ__c && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c != null && c.Min_garantito_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Tipo_WarrantCPQ__c != 'Progressivo' && c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c != null && c.Valore_max_WarrantCPQ__c > c.Finanziamento__r.Stima_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 )
                    
                ){
                    c.Stima_Appoggio__c = c.Finanziamento__r.Stima_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100;
                }
                
                
                //Gruppo del Fisso, stima.
                
                else  IF(
                    
                    
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c >= c.Finanziamento__r.Stima_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                    ||
                    ( c.Percentuale_WarrantCPQ__c == null && c.Fisso_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c != null && c.Limite_WarrantCPQ__c <= c.Finanziamento__r.Stima_WarrantCPQ__c && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null )
                ){
                    c.Stima_Appoggio__c = c.Fisso_WarrantCPQ__c ; 
                }
                
                //Gruppo del minimo garantito, stima.  
                else  IF(
                    
                    c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c != null && c.Min_garantito_WarrantCPQ__c > c.Finanziamento__r.Stima_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 && c.Valore_max_WarrantCPQ__c == null 
                ) {
                    c.Stima_Appoggio__c = c.Min_garantito_WarrantCPQ__c ;
                }
                
                //Gruppo del valore max, stima.
                
                
                else IF(
                    
                    c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c == null && c.Massimo_WarrantCPQ__c == null && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c != null && c.Valore_max_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 
                ){
                    c.Stima_Appoggio__c =  c.Valore_max_WarrantCPQ__c;  
                }
                
                //Gruppo scaglio progre superato, stima.
                
                else  IF(
                    
                    c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null && c.Tipo_WarrantCPQ__c == 'Progressivo'
                ){
                    c.Stima_Appoggio__c = c.Massimo_WarrantCPQ__c * c.Percentuale_WarrantCPQ__c/100 ;
                }
                
                //Gruppo scaglio progre centrato, stima.
                
                else  IF(
                    
                    (c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c != null && c.Massimo_WarrantCPQ__c > c.Finanziamento__r.Stima_WarrantCPQ__c && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null && c.Tipo_WarrantCPQ__c == 'Progressivo')
                    ||
                    (c.Percentuale_WarrantCPQ__c != null && c.Fisso_WarrantCPQ__c == null && c.Minimo_WarrantCPQ__c != null && c.Minimo_WarrantCPQ__c < c.Finanziamento__r.Stima_WarrantCPQ__c && c.Massimo_WarrantCPQ__c == null  && c.Limite_WarrantCPQ__c == null && c.Min_garantito_WarrantCPQ__c == null && c.Valore_max_WarrantCPQ__c == null && c.Tipo_WarrantCPQ__c == 'Progressivo')
                ){
                    c.Stima_Appoggio__c = ( c.Finanziamento__r.Stima_WarrantCPQ__c - c.Minimo_WarrantCPQ__c ) * c.Percentuale_WarrantCPQ__c/100;
                }
                
                
                else {c.Stima_Appoggio__c = 0;}
                
                  

                
                
                
                //________________________________________________________________________________________________________________________
            }//fine se non ha figli
            
            
            
            
            
            
            //SE HA FIGLI ED è COLLEGATA AD 1 FIN
            if (c.condizioni_opzionali__r.size() != 0 && c.Finanziamento__c != null ) {
                
                //allora mi scorro le sue cond opz
              
                for (condizione_opzionale__c co : c.condizioni_opzionali__r ) {
                    
                    
                    //se le cond opz hanno un importo, li sommo tutti
                    if (co.Formula_Importo_WarrantCPQ__c != null ) {
                        
                          importo += co.Formula_Importo_WarrantCPQ__c ;
                                                            
                    }

                    //se le cond opz hanno una stima,le sommo tutte                              
                    if (co.Formula_Stima_WarrantCPQ__c != null){

                         stima += co.Formula_Stima_WarrantCPQ__c ;               
                        
                    }
                    
    
                   
                }
                //alla cond che stavo scorrendo gli metto le somme e poi resetto le variabili
                
              c.Importo_Appoggio__c = importo ;  
              c.Stima_Appoggio__c = stima ;
                
               importo = 0;
               stima = 0;
            }//fine se ha figli
            
            // se non ha figli e non ha finanziamento
            
            if (c.Finanziamento__c == null && c.condizioni_opzionali__r.size() == 0){
                c.Importo_Appoggio__c = c.Fisso_WarrantCPQ__c ;
                c.Stima_Appoggio__c =    c.Fisso_WarrantCPQ__c;
            }
            
            //qua ci metto se ha figli ma non ha finanziamento
            if (c.condizioni_opzionali__r.size() != 0 && c.Finanziamento__c == null ){
                
                  //allora mi scorro le sue cond opz
              
                for (condizione_opzionale__c co : c.condizioni_opzionali__r ) {
                    
                    
                    //se le cond opz hanno un importo, li sommo tutti
                    if (co.Formula_Importo_WarrantCPQ__c != null ) {
                        
                          importo += co.Formula_Importo_WarrantCPQ__c ;
                                                            
                    }

                    //se le cond opz hanno una stima,le sommo tutte                              
                    if (co.Formula_Stima_WarrantCPQ__c != null){

                         stima += co.Formula_Stima_WarrantCPQ__c ;               
                        
                    }
                    
    
                   
                }
                //alla cond che stavo scorrendo gli metto le somme e poi resetto le variabili
                
              c.Importo_Appoggio__c = importo ;  
              c.Stima_Appoggio__c = stima ;
                
               importo = 0;
               stima = 0;
                
   
                
            }
            
           c.WRT_Update_da_Rinnovo__c = false ; 
        }//fine ciclo delle condizioni
        
      }
        
        
        
        
        
        
        
        
        //finito di settare i campi,bisogna fare l'update. Creo una stringa che  dovrebbe contenere gli eventuali errori/successi..
        List<String> res2 = new List<String>(); //cond
        List<String> res = new List<String>();
        
        
        
        if (cnlist.size () != 0){
        // faccio l'update delle condizioni.
        Database.SaveResult[] srListCond = Database.update(cnlist, false);
        
        
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
         
        //gestione res
        string c;
        
        if (res2.size()>0){
        c =  res2.get(0);
        }
        string uniti = c ;
        if (c != null){
        res.add (uniti);
            }
        
        
        
        
      /*     if (fnlist.size() != 0){
       for (finanziamenti__c f : fnlist)  {
            f.WRT_Update_da_Rinnovo__c = false ;
        }
        update fnlist ;
            }

  
        
        if (paglist.size() != 0){
        
         for (pagamenti__c p : paglist) {
            p.WRT_Update_da_Rinnovo__c = false ;
        }
        
        update paglist ;
            }*/
        
        
        
        
        return res;
        
        
        
        
    }

    
    
    

}