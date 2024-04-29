/***
 * Name			:	OnScheduledJobTriggerHandler
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-10-13
 ***/

public class OnScheduledJobTriggerHandler {
    
    public static void BeforeInsert(List<ScheduledJob__c> schJob){
         groupedClass(schJob);
    }
    
    public static void AfterInsert(List<ScheduledJob__c> schJob){
         frequenzaGiornaliera(schJob);
         frequenzaSettimanale(schJob);
         frequenzaMensile(schJob);
         frequenzaAnnuale(schJob);
         requiredFields(schJob);
    }
    
    public static void BeforeUpdate(List<ScheduledJob__c> schJob){
         groupedClass(schJob);
    }
    
    public static void AfterUpdate(List<ScheduledJob__c> schJob){
         frequenzaGiornaliera(schJob);
         frequenzaSettimanale(schJob);
         frequenzaMensile(schJob);
         frequenzaAnnuale(schJob);
         requiredFields(schJob);
    }
    
    public static void frequenzaGiornaliera(List<ScheduledJob__c> schJob){
       for(ScheduledJob__c sch:schJob){
          if(sch.Trigger__c==False &&(sch.Frequenza__c =='Giornaliera' &&( sch.Giorni_Del_Mese__c!=NULL || sch.Ordine_Mensile__c!=NULL || sch.Giorni_Della_Settimana__c!=NULL 
             || (sch.Lunedi__c==FALSE && sch.Martedi__c==FALSE && sch.Mercoledi__c==FALSE && sch.Giovedi__c==FALSE && sch.Venerdi__c==FALSE && sch.Sabato__c==FALSE
             && sch.Domenica__c==TRUE) || sch.Giorno__c!=NULL || sch.Mese__c!=NULL))){
                sch.Frequenza__c.adderror('Per frequenza Giornaliera lascia tutti i campi delle sezioni Settimanale e Mensile vuoti e scegli almeno un giorno della settimana.');
             }
        }           
    }
    
    public static void frequenzaSettimanale(List<ScheduledJob__c> schJob){
        for(ScheduledJob__c sch:schJob){
            if(sch.Trigger__c==FALSE){
                if(sch.Frequenza__c=='Settimanale' && !sch.Trigger__c){
                    Integer counter=0;
                    if(sch.Lunedi__c==True) counter ++ ;
                    if(sch.Martedi__c==True) counter ++ ;
                    if(sch.Mercoledi__c==True) counter ++ ;
                    if(sch.Giovedi__c==True) counter ++ ;
                    if(sch.Venerdi__c==True) counter ++ ;
                    if(sch.Sabato__c==True) counter ++ ;
                    if(sch.Domenica__c==True) counter ++ ;
                    system.debug('the value of counter is:::'+counter);
                    if(counter !=1){
                        sch.Frequenza__c.addError('Per frequenza Settimanale,seleziona solo un giorno della settimana.');
                    }
                    if(sch.Giorni_Del_Mese__c!=NULL || sch.Giorni_Della_Settimana__c!=NULL || sch.Ordine_Mensile__c!=NULL
                       || sch.Giorno__c!=NULL || sch.Mese__c!=NULL ){
                           sch.Frequenza__c.addError('Per una frequenza settimanale ,non puoi scegliere campi mensile e annuale.');
                           
                           
                       }
                }
            }
        }
    }
    
    public static void frequenzaMensile(List<ScheduledJob__c> schJob){
       for(ScheduledJob__c sch:schJob){
          if(sch.Trigger__c==False && sch.Frequenza__c =='Mensile' && (((sch.Giorni_Del_Mese__c==NULL &&(sch.Ordine_Mensile__c==NULL || sch.Giorni_Della_Settimana__c==NULL))
             ||(sch.Giorni_Del_Mese__c!=NULL &&(sch.Ordine_Mensile__c!=NULL || sch.Giorni_Della_Settimana__c!=NULL)))
             || sch.Lunedi__c==TRUE || sch.Martedi__c==TRUE || sch.Mercoledi__c==TRUE || sch.Giovedi__c==TRUE || sch.Venerdi__c==TRUE || sch.Sabato__c==TRUE
             || sch.Domenica__c==TRUE || sch.Giorno__c!=NULL || sch.Mese__c!=NULL)){
                 sch.Frequenza__c.adderror('Per frequenza Mensile inserisci campi della sezione Mensile e lascia tutti campi delle sezioni Settimanale e Annuale.');
             }
        }           
    }
    
    public static void frequenzaAnnuale(List<ScheduledJob__c> schJob){
       for(ScheduledJob__c sch:schJob){
          if(sch.Trigger__c==False && (sch.Frequenza__c =='Annuale' &&(sch.Giorni_Del_Mese__c!=NULL || sch.Ordine_Mensile__c!=NULL || sch.Giorni_Della_Settimana__c!=NULL 
             || sch.Lunedi__c==True || sch.Martedi__c==True ||  sch.Mercoledi__c==TRUE || sch.Giovedi__c==TRUE || sch.Venerdi__c==TRUE || sch.Sabato__c==TRUE
             || sch.Domenica__c==TRUE || sch.Giorno__c==NULL || sch.Mese__c==NULL))){
                 sch.Giorno__c.adderror('Per frequenza Annuale inserisci solo campi nella sezione Annuale e lascia tutti i campi delle sezioni Settimanale e Mensile vuoti.');
             }
        }           
    }
    
    public static void requiredFields(List<ScheduledJob__c> schJob){
        for(ScheduledJob__c sch:schJob){
            if(sch.Attivo__c==True){
                    if(sch.Utente__c ==NULL && !sch.Trigger__c){
                        sch.Utente__c.adderror('Scegli esecutore.');
                    }
                    if(sch.Frequenza__c ==NULL && !sch.Trigger__c){
                        sch.Frequenza__c.adderror('Scegli Frequenza.');
                    }
                    if(sch.Ordine_Di_Esecuzione__c ==NULL || String.isEmpty(sch.Ordine_Di_Esecuzione__c)
                      ||!sch.Ordine_Di_Esecuzione__c.isNumericSpace()){
                         sch.Ordine_Di_Esecuzione__c.adderror('Inserisci un Numero per Ordine di esecuzione.');
                    }
                if((sch.Data_Fine_Validit__c==NULL || sch.Data_Inzio_Validit__c==NULL) && !sch.Trigger__c ){
                    sch.Data_Inzio_Validit__c.adderror('Inserisci data inzio e fine di validità.');
                }
                if((sch.Data_Fine_Validit__c<sch.Data_Inzio_Validit__c) && !sch.Trigger__c ){
                    sch.Data_Inzio_Validit__c.adderror('Data fine dovrebbe essere dopo data inizio.');
                }
                    
            }
        }
    }
 
    public static void groupedClass(List<ScheduledJob__c> schJob){
        for(ScheduledJob__c sj:schJob){
             if(sj.Ordine_Di_Esecuzione__c==Null || String.isEmpty(sj.Ordine_Di_Esecuzione__c) ){
                  sj.Ordine_Di_Esecuzione__c='1';
             }
             if(sj.Codice_Gruppo__c!=Null || !String.isEmpty(sj.Codice_Gruppo__c) ){
                   sj.CodiceGruppoOrdine__c= sj.Codice_Gruppo__c + sj.Ordine_Di_Esecuzione__c;
             }
            if(sj.Trigger__c==true && (sj.Codice_Gruppo__c==Null || String.isEmpty(sj.Codice_Gruppo__c)) ){
                sj.Codice_Gruppo__c.adderror('Inserisci Codice Gruppo.');
            }
            
         }
    }
}