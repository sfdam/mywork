global class JobRunner implements Schedulable {
    
    global JobRunner(){
    }
    
    global static List<ScheduledJob__c>  calculateQuery(){
        Map<String,Integer> numdayOfWeek = new Map<String,Integer>();
        numdayOfWeek.put('Lunedi',1);
        numdayOfWeek.put('Martedi',2);
        numdayOfWeek.put('Mercoledi',3);
        numdayOfWeek.put('Giovedi',4);
        numdayOfWeek.put('Venerdi',5);
        numdayOfWeek.put('Sabato',6);
        numdayOfWeek.put('Domenica',7);
        Map<String,String> mapdayOfWeek = new Map<String,String>();
        mapdayOfWeek.put('Monday','Lunedi');
        mapdayOfWeek.put('Tuesday','Martedi');
        mapdayOfWeek.put('Wednesday','Mercoledi');
        mapdayOfWeek.put('Thursday','Giovedi');
        mapdayOfWeek.put('Friday','Venerdi');
        mapdayOfWeek.put('Saturday','Sabato');
        mapdayOfWeek.put('Sunday','Domenica');
        Map<Integer,String> MapOrdine = new Map<Integer,String>();
        MapOrdine.put(1,'Primo');
        MapOrdine.put(2,'Secondo');
        MapOrdine.put(3,'Terzo');
        MapOrdine.put(4,'Quarto');
        MapOrdine.put(5,'Ultimo');
        Map<Integer,String> MapMesi = new map<Integer,String>();
        MapMesi.put(1,'Gennaio');
        MapMesi.put(2,'Febbraio');
        MapMesi.put(3,'Marzo');
        MapMesi.put(4,'Aprile');
        MapMesi.put(5,'Maggio');
        MapMesi.put(6,'Giugno');
        MapMesi.put(7,'Luglio');
        MapMesi.put(8,'Agosto');
        MapMesi.put(9,'Settembre');
        MapMesi.put(10,'Ottobre');
        MapMesi.put(11,'Novembre');
        MapMesi.put(12,'Dicembre');
        
        Time myTime = Time.newInstance(0, 0, 0, 0);
        Datetime dt = DateTime.newInstance(Date.today(), myTime);
        String dayOfWeek=mapdayOfWeek.get(dt.format('EEEE'));
        
        Date firstcurrentday = Date.today().toStartOfMonth().toStartOfWeek().addDays(numdayOfWeek.get(dayOfWeek)-1);    
        if(firstcurrentday < date.today().toStartOfmonth()) firstcurrentday = firstcurrentday.addDays(7);
        Integer n=firstcurrentday.daysBetween(Date.today());
        system.debug(n);
        Integer ord=(n/7)+1;
        system.debug(ord);
        String ordineDelMese=MapOrdine.get(ord);
        //calcolo ultimo:
        Date LastdayOfMonth=Date.Today().addMonths(1).toStartofMonth().addDays(-1);
        
        if(Date.today()==firstcurrentday.addDays(28) && firstcurrentday.addDays(28)<LastdayOfMonth ){
            ordineDelMese=MapOrdine.get(5);
        }
        else{
            if(Date.today()==firstcurrentday.addDays(21)){
                ordineDelMese=MapOrdine.get(5);
            }
        }
        
        String query='SELECT Id, OwnerId, Name,';
        query+=' Descrizione__c, Giorni_Della_Settimana__c, Nome_Classe__c, Orario_Della_Partenza__c, Frequenza__c, Trigger__c ,Tipologia_Della_Classe__c, ';
        query+=' Giorni_Del_Mese__c, Ordine_Mensile__c, Codice_Gruppo__c, Attivo__c, Batch_Size__c, ';
        query+=' Utente__c, Ordine_Di_Esecuzione__c, Data_Fine_Validit__c,Data_Inzio_Validit__c, Giorno__c, Mese__c, ';
        
        query+=dayOfWeek+'__c';
        Id idUser = UserInfo.getUserId();
        Datetime dtt=DateTime.now();
        Date dt2=dtt.Date();
        String d=''+dtt.Day();
        String m=MapMesi.get(dt2.Month());
        String hour;
        String minute;
        if(dtt.hour()<10)
            hour='0'+String.valueOf(dtt.hour());
        else
            hour=String.valueOf(dtt.hour());
        if(dtt.minute()<10)
            minute='0'+String.valueOf(dtt.minute());
        else
            minute=String.valueOf(dtt.minute());
        
        String currentTime='%'+hour+':'+minute+'%';
        
        query+=' FROM ScheduledJob__c' ;
        query+=' WHERE (Utente__r.Id=:idUser' ;
        query+=' AND Trigger__c=FALSE  ';
        query+=' AND Data_Inzio_Validit__c<=:dt2  AND Data_Fine_Validit__c>=:dt2' ;
        query+=' AND Attivo__c=TRUE  ';
        query+=' AND  Orario_Della_Partenza__c LIKE : currentTime )  ';
        
        //settimanali e giornalieri
        query+=' AND ('+ String.escapeSingleQuotes(dayOfWeek) +'__c=TRUE';
        
        //mensili
        String strUltiomo='Ultimo';
        if(LastdayOfMonth.Day()==Date.Today().Day()){
            query+=' OR Giorni_Del_Mese__c=:strUltiomo ' ;           
        }
        query+=' OR Giorni_Del_Mese__c=:d ' ;
        query+=' OR ( Giorni_Della_Settimana__c=:dayOfWeek ';
        query+=' AND Ordine_Mensile__c=:ordineDelMese ) ';
        
        //Annualli
        query+=' OR ( Mese__c =:m';
        query+=' AND Giorno__c=:d  ) )'; 
        
        query+=' ORDER BY Ordine_Di_Esecuzione__c ';   
        system.debug('query is:'+query);
        
        
        
        List<ScheduledJob__c> sobjList = Database.query(query);             
        return sobjList;
        
    }
    global void execute(SchedulableContext SC) {
        System.debug('JobRunner execute - start');
        List <ScheduledJob__c> sj=calculateQuery();
        system.debug('the returned value of the query method:::'+sj);
        List<ScheduledJob__c> singleclasses=new List<ScheduledJob__c>();
        //Create a map of codice Gruppi e corresponding scheduledJob records.
        Map<string, List<ScheduledJob__c>> mappa = new Map<string, List<ScheduledJob__c>>();
        for(ScheduledJob__c s: sj){
            if(String.isEmpty(s.codice_gruppo__c)){
                singleclasses.add(s);
            }
            else{
                if(!mappa.containskey(s.codice_gruppo__c)){
                    List<ScheduledJob__c> nuovaLista = new List<ScheduledJob__c>();
                    nuovaLista.add(s);
                    mappa.put(s.codice_gruppo__c, nuovaLista);
                }
                else
                {
                    List<ScheduledJob__c> nuovaLista = mappa.get(s.Codice_Gruppo__c);
                    nuovaLista.add(s);
                    mappa.put(s.codice_gruppo__c, nuovaLista);
                }
            }
        }
        for(string codice_gruppo: mappa.keyset()){
            List<ScheduledJob__c> listaScheduledJobsCorrispondenti = mappa.get(codice_gruppo);
            jobRunner.executeNext(listaScheduledJobsCorrispondenti);
        }
        singleExe(singleclasses); 
    } 
    
    global static  void singleExe(List<ScheduledJob__c> schedules){
        system.debug('JobRunner executeSingle');
        if(!schedules.isEmpty()){
            for(ScheduledJob__c  sj:schedules){
                System.Type t = System.Type.forName(sj.Nome_Classe__c);
                Integer batchSize = (Integer)(sj.Batch_size__c==null || sj.Batch_size__c==0 ? 200 : sj.Batch_size__c);
                if(sj.Tipologia_Della_Classe__c=='Batchable'){
                    if (t != null) {
                        IRunner s = (IRunner) t.newInstance();
                        Database.executeBatch((Database.Batchable<sObject>)s,batchSize);
                    }
                }
                if(sj.Tipologia_Della_Classe__c=='Schedulable'){
                    if (t != null) {
                        ISRunner s = (ISRunner) t.newInstance(); //EDB 2020-04-29
                        s.initRunner(batchSize);
                        Schedulable cs = (Schedulable)s;
                        cs.execute(null);
                    }
                }
            }
        }
    }
    
    global static  void executeNext(List<ScheduledJob__c> schedules){
        if(!schedules.isEmpty()){
            ScheduledJob__c nextExe =schedules.remove(0);
            System.Type t = System.Type.forName(nextExe.Nome_Classe__c);
            if (t != null) {
                Integer batchSize = (Integer)(nextExe.Batch_size__c==null || nextExe.Batch_size__c==0 ? 200 : nextExe.Batch_size__c);
                if(nextExe.Tipologia_Della_Classe__c=='Batchable'){
                    IRunner s = (IRunner) t.newInstance();
                    s.initRunner(schedules);
                    Database.executeBatch((Database.Batchable<sObject>)s,batchSize);
                } 
                if(nextExe.Tipologia_Della_Classe__c=='Schedulable') {
                    ISRunner s = (ISRunner) t.newInstance();
                    s.initRunner(schedules,batchSize);
                    Schedulable cs = (Schedulable)s;
                    cs.execute(null);
                } 
            }
        }
    }
}