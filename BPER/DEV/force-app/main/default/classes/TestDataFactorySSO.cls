public class TestDataFactorySSO {
    public static User createUser(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = 
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(firstname = 'test',
                          lastName = 'ut',
                          email = uniqueName + '@test' + orgId + '.org',
                          Username = uniqueName + '@test' + orgId + '.org',
                          EmailEncodingKey = 'ISO-8859-1',
                          Alias = uniqueName.substring(18, 23),
                          TimeZoneSidKey = 'America/Los_Angeles',
                          LocaleSidKey = 'en_US',
                          LanguageLocaleKey = 'en_US',
                          ProfileId = UserInfo.getProfileId()
                         );
        //insert u;
        return u;
    }
    
    //ScheduledJob__c
    public static ScheduledJob__c creaScheduledJobs(string tipologiaClasse,string codiceGruppo,string nomeclasse,User userInput){
        ScheduledJob__c sj = new ScheduledJob__c();
        sj.Codice_Gruppo__c = codiceGruppo;
        sj.Nome_Classe__c = nomeclasse;
        sj.Trigger__c = true;
        sj.Tipologia_Della_Classe__c = tipologiaClasse;
        sj.Utente__c = userInput.id;
        sj.Attivo__c = true;
        //insert sj;
        return sj;
    }
    
    public static void aggiornaScheduledJob(ScheduledJob__c sj1,string currentTime,string frequenza){
        sj1.Trigger__c=False;
        sj1.Codice_Gruppo__c='';
        sj1.Utente__c=UserInfo.getUserId();
        sj1.Frequenza__c=frequenza;
        sj1.Data_Inzio_Validit__c=Date.newInstance(2020, 1, 1);
        sj1.Data_Fine_Validit__c=Date.newInstance(2050, 12, 31);
        sj1.Lunedi__c=True;
        sj1.Martedi__c=True;   
        sj1.Mercoledi__c=True;        
        sj1.Giovedi__c=True;        
        sj1.Venerdi__c=True;        
        sj1.Sabato__c=True;       
        sj1.Domenica__c=True;
        sj1.Orario_Della_Partenza__c=currentTime;
        system.debug('currentTime in test class:::'+currentTime);
        Update sj1;
    }
    public static ScheduledJob__c creaScheduledJobsFrequenzaSettimanale(string tipologiaClasse,string codiceGruppo,string nomeclasse,User userInput){
        ScheduledJob__c sj = new ScheduledJob__c();
        sj.Codice_Gruppo__c = codiceGruppo;
        sj.Nome_Classe__c = nomeclasse;
        sj.Trigger__c = false;
        sj.Tipologia_Della_Classe__c = tipologiaClasse;
        sj.Frequenza__c = 'Settimanale';
        sj.Lunedi__c = true;
        sj.Martedi__c = true;
        sj.Utente__c = userInput.id;
        sj.Attivo__c = true;
        //insert sj;
        return sj;
    }
    public static ScheduledJob__c creaScheduledJobsFrequenzaGiornaliera(string tipologiaClasse,string codiceGruppo,string nomeclasse,User userInput){
        ScheduledJob__c sj = new ScheduledJob__c();
        sj.Codice_Gruppo__c = codiceGruppo;
        sj.Nome_Classe__c = nomeclasse;
        sj.Trigger__c = false;
        sj.Tipologia_Della_Classe__c = tipologiaClasse;
        sj.Frequenza__c = 'Giornaliera';
        sj.Giorni_Del_Mese__c = '2';
        sj.Utente__c = userInput.id;
        sj.Attivo__c = true;
        //insert sj;
        return sj;
    }
    public static ScheduledJob__c creaScheduledJobsFrequenzaMensile(string tipologiaClasse,string codiceGruppo,string nomeclasse,User userInput){
        ScheduledJob__c sj = new ScheduledJob__c();
        sj.Codice_Gruppo__c = codiceGruppo;
        sj.Nome_Classe__c = nomeclasse;
        sj.Trigger__c = false;
        sj.Tipologia_Della_Classe__c = tipologiaClasse;
        sj.Frequenza__c = 'Mensile';
        sj.Giorni_Del_Mese__c = null;
        sj.Ordine_Mensile__c = null;
        sj.Giorni_Della_Settimana__c = null;
        sj.Utente__c = userInput.id;
        sj.Attivo__c = true;
        //insert sj;
        return sj;
    }
    public static ScheduledJob__c creaScheduledJobsFrequenzaAnnuale(string tipologiaClasse,string codiceGruppo,string nomeclasse,User userInput){
        ScheduledJob__c sj = new ScheduledJob__c();
        sj.Codice_Gruppo__c = codiceGruppo;
        sj.Nome_Classe__c = nomeclasse;
        sj.Trigger__c = false;
        sj.Tipologia_Della_Classe__c = tipologiaClasse;
        sj.Frequenza__c = 'Annuale';
        sj.Giorni_Del_Mese__c = '3';
        sj.Utente__c = userInput.id;
        sj.Attivo__c = true;
        //insert sj;
        return sj;
    }
    //Elaborazione_Processo__c
    public static Elaborazione_Processo__c creaElaborazioneProcesso(string nome){
        Elaborazione_Processo__c ep = new Elaborazione_Processo__c();
        ep.Name = nome;
        //insert ep;
        return ep;
    }
}