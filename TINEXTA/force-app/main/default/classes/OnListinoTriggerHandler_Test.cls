@istest
public class OnListinoTriggerHandler_Test {
    @istest
    public static void testSuccess (){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
        
        id ridfin = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        id ridcond = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
        id ridopz = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();
        
        Business_Area_Warrant__c Fin = new Business_Area_Warrant__c(	Importo_WarrantCPQ__c = 1000,
                                                                         Stima_WarrantCPQ__c= 1000,
                                                                    recordtypeid = ridfin 
                                                                    
                                                                   );
        
       insert fin ;

        Business_Area_Warrant__c Cond = new Business_Area_Warrant__c(Fisso_WarrantCPQ__c= 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond);
        insert cond ;
        
        Business_Area_Warrant__c Opz = new Business_Area_Warrant__c(Fisso_WarrantCPQ__c= 1000,
                                                                    recordtypeid= ridopz,
                                                                   Cond_Associata__c = cond.id);

        Business_Area_Warrant__c Pag = new Business_Area_Warrant__c(recordtypeid= ridpag,
                                                                   Cond_Associata__c = cond.id);
        
       
        fin.Importo_WarrantCPQ__c = 2000 ;
        
        list <Business_Area_Warrant__c> all = new list <Business_Area_Warrant__c> ();
        all.add (opz);
        all.add (pag);
        
        Business_Area_Warrant__c Opz2 = new Business_Area_Warrant__c(Fisso_WarrantCPQ__c= 1000,
                                                                     	Minimo_WarrantCPQ__c= 200,
                                                                    recordtypeid= ridopz,
                                                                   Cond_Associata__c = cond.id);
        insert opz2 ;
        
        opz2.Minimo_WarrantCPQ__c = 100 ;
        opz2.Massimo_WarrantCPQ__c = 2000;
        opz2.Tipo_WarrantCPQ__c= '2';
      
        
        
          Business_Area_Warrant__c Cond2 = new Business_Area_Warrant__c(Fisso_WarrantCPQ__c= 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond);
        
        
        Business_Area_Warrant__c Fin3 = new Business_Area_Warrant__c(	Importo_WarrantCPQ__c = 1000,
                                                                         Stima_WarrantCPQ__c= 1000,
                                                                    recordtypeid = ridfin 
                                                                    
                                                                   );
        
       insert fin3;

        
        
          Business_Area_Warrant__c Cond3 = new Business_Area_Warrant__c(Fisso_WarrantCPQ__c= 1000,
                                                                    Fin_Associato__c = fin3.id,
                                                                    recordtypeid= ridcond);
    
        insert cond3;
        
        cond3.Fin_Associato__c = fin.id ;
        
        
          Business_Area_Warrant__c Cond4 = new Business_Area_Warrant__c(Percentuale_WarrantCPQ__c= 1000,
                                                                    Fin_Associato__c = fin3.id,
                                                                    recordtypeid= ridcond);
    
       
         Business_Area_Warrant__c Cond5 = new Business_Area_Warrant__c(Percentuale_WarrantCPQ__c= 10,
                                                                       	Minimo_WarrantCPQ__c= 200,
                                                                    Fin_Associato__c = fin3.id,
                                                                    recordtypeid= ridcond);
        

       
        
    
      

 //quindi update. qualsiasi cosa deve cambiare. se non cia figli       

     

        
        
        
        
        
 
        x.Disabilita_tutti_i_process_builder__c = false;
         x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        
          Test.startTest();
       insert all ;
        update fin ;
        update opz2 ;
        insert cond2;
        update cond3;
        insert cond4;
        cond4.Fin_Associato__c = fin.id ;
        update cond4;
        insert cond5;
        
       Test.stopTest();  
        
        
        
    }
    
    
    
     @istest
        public static void testSuccess2 (){
                 Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
            
            
        id ridfin = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        id ridcond = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
        id ridopz = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();
            
       
            
            
            
        Business_Area_Warrant__c Fin = new Business_Area_Warrant__c(	Importo_WarrantCPQ__c = 1000,
                                                                         Stima_WarrantCPQ__c= 1000,
                                                                    recordtypeid = ridfin 
                                                                    
                                                                   );
        
       insert fin ;
            
            
         Business_Area_Warrant__c Cond6 = new Business_Area_Warrant__c(Percentuale_WarrantCPQ__c= 10,
                                                                       	Minimo_WarrantCPQ__c= 200,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond);
      
      Business_Area_Warrant__c Cond7 = new Business_Area_Warrant__c(Percentuale_WarrantCPQ__c= 1,
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                    Massimo_WarrantCPQ__c = 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Tipo_WarrantCPQ__c = '2');
        Business_Area_Warrant__c Cond8 = new Business_Area_Warrant__c(Percentuale_WarrantCPQ__c= 1,
                                                                     Valore_max_WarrantCPQ__c = 10,
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                    Massimo_WarrantCPQ__c = 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Tipo_WarrantCPQ__c = '2');
            
            
           
            
          Business_Area_Warrant__c Cond9 = new Business_Area_Warrant__c(
                                                                    
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200
                                                                
                                                                  
                                                                  );
    
            
             Business_Area_Warrant__c Cond10 = new Business_Area_Warrant__c(
                                                                    
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200
                                                                
                                                                  
                                                                  );
    
           
          
                Business_Area_Warrant__c Cond11 = new Business_Area_Warrant__c(
                                                                    
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   Massimo_WarrantCPQ__c = 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200,
                                                                Tipo_WarrantCPQ__c = '1'
                                                                  
                                                                  );

        

                   
         
            
         x.Disabilita_tutti_i_process_builder__c = false;
         x.Disabilita_tutti_i_trigger__c=false;
        update x;   
              Test.startTest();
              insert cond6;
              cond6.Minimo_WarrantCPQ__c = 10;
              update cond6;
             insert cond7;
            insert cond8;
               insert cond9; 
            insert cond10;
             cond10.Minimo_WarrantCPQ__c = 10;
            update cond10;
            insert cond11;
            cond11.Minimo_WarrantCPQ__c = 10;
            update cond11;
          
          
              Test.stopTest();  
        
            
            
        }
     @istest
    public static void testSuccess3 (){
            Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
            
            
        id ridfin = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        id ridcond = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
        id ridopz = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();
        
        
        Business_Area_Warrant__c Fin = new Business_Area_Warrant__c(	Importo_WarrantCPQ__c = 1000,
                                                                         Stima_WarrantCPQ__c= 1000,
                                                                    recordtypeid = ridfin 
                                                                    
                                                                   );
        
       insert fin ;
        
        
            
         Business_Area_Warrant__c Cond12 = new Business_Area_Warrant__c(
                                                                    	Valore_max_WarrantCPQ__c = 10,
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   Massimo_WarrantCPQ__c = 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200,
                                                                Tipo_WarrantCPQ__c = '2'
                                                                  
                                                                  );
        
        
           Business_Area_Warrant__c Cond13 = new Business_Area_Warrant__c(
                                                                    	Min_garantito_WarrantCPQ__c = 3000,
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   Massimo_WarrantCPQ__c = 1000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200,
                                                                Tipo_WarrantCPQ__c = '2',
                                                                 Percentuale_WarrantCPQ__c= 1
                                                                  
                                                                  );
        
          Business_Area_Warrant__c Cond14 = new Business_Area_Warrant__c(
                                                                    	Min_garantito_WarrantCPQ__c = 3000,
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   Massimo_WarrantCPQ__c = 999,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200,
                                                                Tipo_WarrantCPQ__c = '2',
                                                                 Percentuale_WarrantCPQ__c= 1,
                                                                  Limite_WarrantCPQ__c = 10
                                                                  );
        
          Business_Area_Warrant__c Cond15 = new Business_Area_Warrant__c(
                                                                    	
                                                                     Minimo_WarrantCPQ__c= 200,
                                                                   Massimo_WarrantCPQ__c = 4000,
                                                                    Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200,
                                                                Tipo_WarrantCPQ__c = '2',
                                                                 Percentuale_WarrantCPQ__c= 1,
                                                                  Limite_WarrantCPQ__c = 10
                                                                  );
        
        
       
        
        
          x.Disabilita_tutti_i_process_builder__c = false;
         x.Disabilita_tutti_i_trigger__c=false;
        update x;  
        
         Test.startTest();
        insert cond12;
        cond12.Minimo_WarrantCPQ__c= 10;
        update cond12;
        insert cond13;
cond13.Minimo_WarrantCPQ__c= 10;
        update cond13;
          insert cond14;
        cond14.Minimo_WarrantCPQ__c= 10;
        update cond14;
        insert cond15;
        cond15.Minimo_WarrantCPQ__c= 10;
        update cond15;
      
         Test.stopTest();  
        
        
    }
            
         @istest   
    public static void testSuccess4 (){ 
        
        
        
      Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
        
        
        id ridfin = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Finanziamenti').getRecordTypeId();
        id ridpag = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Pagamenti').getRecordTypeId();
        id ridcond = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizioni').getRecordTypeId();
        id ridopz = Schema.Sobjecttype.Business_Area_Warrant__c.getRecordTypeInfosByName().get('Condizione Opzionale').getRecordTypeId();     
    
    
Business_Area_Warrant__c Fin = new Business_Area_Warrant__c(	Importo_WarrantCPQ__c = 1000,
                                                                         Stima_WarrantCPQ__c= 1000,
                                                                    recordtypeid = ridfin 
                                                                    
                                                                   );
        
       insert fin ;
 
Business_Area_Warrant__c Cond16 = new Business_Area_Warrant__c(  
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200
                                                                  );   
        
        
        Business_Area_Warrant__c Cond17 = new Business_Area_Warrant__c(  	Fin_Associato__c = fin.id,
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200
                                                                  ); 
        
        insert cond17;
        
        
            Business_Area_Warrant__c opz = new Business_Area_Warrant__c(
                                                                  Tipo_WarrantCPQ__c = '1',
                                                                  recordtypeid= ridopz,
                                                                  Fisso_WarrantCPQ__c = 200,
                	                                              Cond_Associata__c = cond17.id,
                                                                  Minimo_WarrantCPQ__c= 200,
                                                                  Massimo_WarrantCPQ__c = 4000,
                                                                  Percentuale_WarrantCPQ__c= 1
                                                                 
                                                                  ); 
        
        insert opz;
        
         Business_Area_Warrant__c opz2 = new Business_Area_Warrant__c(  	
                                                                  Tipo_WarrantCPQ__c = '2',
                                                                  recordtypeid= ridopz,
                                                                  Fisso_WarrantCPQ__c = 200,
                	                                              Cond_Associata__c = cond17.id,
                                                                  Minimo_WarrantCPQ__c= 200,
                                                                  Massimo_WarrantCPQ__c = 4000,
                                                                  Percentuale_WarrantCPQ__c= 1
                                                                  ); 
        
        insert opz2;
        
        
         Business_Area_Warrant__c Cond18 = new Business_Area_Warrant__c(  	
                                                                    recordtypeid= ridcond,
                                                                   Fisso_WarrantCPQ__c = 200
                                                                  ); 
        
        insert cond18;
        
         Business_Area_Warrant__c opz3 = new Business_Area_Warrant__c(  	
                                                                  Tipo_WarrantCPQ__c = '2',
                                                                  recordtypeid= ridopz,
                                                                  Fisso_WarrantCPQ__c = 200,
                	                                              Cond_Associata__c = cond18.id,
                                                                  Minimo_WarrantCPQ__c= 200,
                                                                  Massimo_WarrantCPQ__c = 4000,
                                                                  Percentuale_WarrantCPQ__c= 1
                                                                  ); 
        
        insert opz3;
        
        

x.Disabilita_tutti_i_process_builder__c = false;
         x.Disabilita_tutti_i_trigger__c=false;
        update x;  


   Test.startTest();
        insert cond16;
        cond16.Fisso_WarrantCPQ__c = 100;
        update cond16;
        delete fin;
        delete opz;
        delete opz3;

  Test.stopTest(); 
 }
    
    
    
        
    
    

}