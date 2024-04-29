public without sharing class TXT_AccountHandler {
    public TXT_AccountHandler() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountByCF(String CF){
        List<Account> accts = [SELECT Id,Name, CCIAA_CMK__c, CCIAA_REA__c,Forma_giuridica__c,
        denosociale__c, Codice_fiscale__c, Partita_iva__c, Societa_su_CTM__c,Inn_societa__c, REV_societa__c,
        BillingStreet, BillingCity, BillingState, BillingPostalCode,
        BillingCountry, Data_Bilancio__c, Acquisti_totali__c, Data_di_cessazione__c,
        Anno_rilevazione_addetti__c, Data_Inizio_Attivita__c, AnnualRevenue, 
        Livello_attenzione_negativita__c, Capitale_Sociale__c, Crediti_vs_Clienti__c, 
        Risultato_Operativo_Lordo__c, Phone, Email_Aziendale_Innolva__c, Phone_Warrant__c, Totale_Patrimonio_Netto_Tinexta__c,
        Fax, Utile_Perdita__c, Stato_Attivita__c, Fatturato__c, Rating__c, Dipendenti__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c, 
        Data_Ultimo_Arricchimento__c, Cliente_Estero__c, TXT_Gruppo_IVA__c, TXT_Denominazione_Gruppo_IVA__c
        FROM Account WHERE Codice_fiscale__c =: CF]; // AND Forma_giuridica__c = 'PERSONA FISICA'
        System.debug('Accounts:' + accts);
        List<Account> crmresponse = new List<Account>();
        for(Account crma :accts){
            crma.Censimento_Manuale__c = true;
            crmresponse.add(crma);
        }
        return crmresponse;

    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountByCFPIVA(String PIVA){
        List<Account> accts = [SELECT Id,Name, CCIAA_CMK__c, CCIAA_REA__c,Forma_giuridica__c,
        denosociale__c, Codice_fiscale__c, Partita_iva__c, Societa_su_CTM__c,Inn_societa__c, REV_societa__c,
        BillingStreet, BillingCity, BillingState, BillingPostalCode,
        BillingCountry, Data_Bilancio__c, Acquisti_totali__c, Data_di_cessazione__c,
        Anno_rilevazione_addetti__c, Data_Inizio_Attivita__c, AnnualRevenue, 
        Livello_attenzione_negativita__c, Capitale_Sociale__c, Crediti_vs_Clienti__c, 
        Risultato_Operativo_Lordo__c, Phone, Email_Aziendale_Innolva__c, Phone_Warrant__c, Totale_Patrimonio_Netto_Tinexta__c,
        Fax, Utile_Perdita__c, Stato_Attivita__c, Fatturato__c, Rating__c, Dipendenti__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c, 
        Data_Ultimo_Arricchimento__c, Cliente_Estero__c, TXT_Gruppo_IVA__c, TXT_Denominazione_Gruppo_IVA__c
        FROM Account WHERE Partita_iva__c =: PIVA OR Codice_fiscale__c =: PIVA];
        List<Account> crmresponse = new List<Account>();
        for(Account crma :accts){
            crma.Censimento_Manuale__c = true;
            crmresponse.add(crma);
        }
        return crmresponse;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountByName(String name){
        String search = '%'+name+'%';
        List<Account> accts = [SELECT Id,Name, CCIAA_CMK__c, CCIAA_REA__c,Forma_giuridica__c,
        denosociale__c, Codice_fiscale__c, Partita_iva__c, Societa_su_CTM__c,Inn_societa__c, REV_societa__c,
        BillingStreet, BillingCity, BillingState, BillingPostalCode,
        BillingCountry, Data_Bilancio__c, Acquisti_totali__c, Data_di_cessazione__c,
        Anno_rilevazione_addetti__c, Data_Inizio_Attivita__c, AnnualRevenue, 
        Livello_attenzione_negativita__c, Capitale_Sociale__c, Crediti_vs_Clienti__c, 
        Risultato_Operativo_Lordo__c, Phone, Email_Aziendale_Innolva__c, Phone_Warrant__c, Totale_Patrimonio_Netto_Tinexta__c,
        Fax, Utile_Perdita__c, Stato_Attivita__c, Fatturato__c, Rating__c, Dipendenti__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c, 
        Data_Ultimo_Arricchimento__c, Cliente_Estero__c, TXT_Gruppo_IVA__c, TXT_Denominazione_Gruppo_IVA__c 
        FROM Account WHERE Name LIKE :search];
        List<Account> crmresponse = new List<Account>();
        for(Account crma :accts){
            crma.Censimento_Manuale__c = true;
            crmresponse.add(crma);
        }
        return crmresponse;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountById(String id){
        List<Account> accts = [SELECT Id,Name, CCIAA_CMK__c, CCIAA_REA__c,Forma_giuridica__c,
        denosociale__c, Codice_fiscale__c, Partita_iva__c, Societa_su_CTM__c,Inn_societa__c, REV_societa__c,
        BillingStreet, BillingCity, BillingState, BillingPostalCode,
        BillingCountry, Data_Bilancio__c, Acquisti_totali__c, Data_di_cessazione__c,
        Anno_rilevazione_addetti__c, Data_Inizio_Attivita__c, AnnualRevenue, 
        Livello_attenzione_negativita__c, Capitale_Sociale__c, Crediti_vs_Clienti__c, 
        Risultato_Operativo_Lordo__c, Phone, Email_Aziendale_Innolva__c, Phone_Warrant__c, Totale_Patrimonio_Netto_Tinexta__c,
        Fax, Utile_Perdita__c, Stato_Attivita__c, Fatturato__c, Rating__c, Dipendenti__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c, 
        Data_Ultimo_Arricchimento__c, Cliente_Estero__c, TXT_Gruppo_IVA__c, TXT_Denominazione_Gruppo_IVA__c
        FROM Account WHERE Id =: id];
        return accts;
    }

    public static String CodeToCountry(String code){
        String registry = ':ALBANIA:AL,'+
        ':ALGERIA:DZ,'+
        ':ANDORRA:AD,'+
        ':ANGOLA:AO,'+
        ':ANGUILLA:AI,'+
        ':ANTARTIDE FRANCESE:TF,'+
        ':ANTIGUA/BARBUDA:AG,'+
        ':ANTILLE OLANDESI:AN,'+
        ':ARABIA SAUDITA:SA,'+
        ':ARCIPELAGO DI COOK:CK,'+
        ':ARGENTINA:AR,'+
        ':ARMENIA:AM,'+
        ':ARUBA:AW,'+
        ':ASCENSION:SH,'+
        ':AUSTRALIA:AU,'+
        ':AUSTRIA:AT,'+
        ':AZERBAIGIAN:AZ,'+
        ':BAHAMA:BS,'+
        ':BAHREIN:BH,'+
        ':BANGLADESH:BD,'+
        ':BARBADOS:BB,'+
        ':BELGIO:BE,'+
        ':BELIZE:BZ,'+
        ':BENIN:BJ,'+
        ':BERMUDE:BM,'+
        ':BHUTAN:BT,'+
        ':BIELORUSSIA:BY,'+
        ':BOLIVIA:BO,'+
        ':BOSNIA-ERZEGOVINA:BA,'+
        ':BOTSWANA:BW,'+
        ':BRASILE:BR,'+
        ':BRUNEI:BN,'+
        ':BULGARIA:BG,'+
        ':BURKINA FASO:BF,'+
        ':BURUNDI:BI,'+
        ':CAMBOGIA:KH,'+
        ':CAMERUN:CM,'+
        ':CANADA:CA,'+
        ':CAYMAN:KY,'+
        ':CENTRAFRICA:CF,'+
        ':CIAD:TD,'+
        ':CILE:CL,'+
        ':CINA:CN,'+
        ':CIPRO:CV,'+
        ':CIPRO:CY,'+
        ':CITTA\' DEL VATICANO:VA,'+
        ':COLOMBIA:CO,'+
        ':COMORE:KM,'+
        ':COREA DEL NORD:KP,'+
        ':COREA DEL SUD:KR,'+
        ':COSTA D\'AVORIO:CI,'+
        ':COSTA RICA:CR,'+
        ':CROAZIA:HR,'+
        ':CUBA:CU,'+
        ':DANIMARCA:DK,'+
        ':DOMINICA:DM,'+
        ':ECUADOR:EC,'+
        ':EGITTO:EG,'+
        ':EMIRATI ARABI UNITI:AE,'+
        ':ERITREA:ER,'+
        ':ESTONIA:EE,'+
        ':ETIOPIA:ET,'+
        ':FILIPPINE:PH,'+
        ':FINLANDIA:FI,'+
        ':FRANCIA:FR,'+
        ':GABON:GA,'+
        ':GAMBIA:GM,'+
        ':GEORGIA:GE,'+
        ':GEORGIA DEL SUD E S:GS,'+
        ':GERMANIA:DE,'+
        ':GHANA:GH,'+
        ':GIAMAICA:JM,'+
        ':GIAPPONE:JP,'+
        ':GIBILTERRA:GI,'+
        ':GIBUTI:DJ,'+
        ':GIORDANIA:JO,'+
        ':GRAN BRETAGNA:GB,'+
        ':GRECIA:GR,'+
        ':GRENADA:GD,'+
        ':GROENLANDIA:GL,'+
        ':GUADALUPA:GP,'+
        ':GUAM:GU,'+
        ':GUATEMALA:GT,'+
        ':GUIANA:GY,'+
        ':GUIANA FRANCESE:GF,'+
        ':GUINEA EQUATORIALE:GQ,'+
        ':GUINEA-BISSAU:GW,'+
        ':HAITI:HT,'+
        ':HONDURAS:HN,'+
        ':HONG KONG:HK,'+
        ':INDIA:IN,'+
        ':INDONESIA:ID,'+
        ':IRAN:IR,'+
        ':IRAQ:IQ,'+
        ':IRLANDA:IE,'+
        ':ISLANDA:IS,'+
        ':ISOLA DI NORFOLK:NF,'+
        ':ISOLE CHRISTMAS:CX,'+
        ':ISOLE COCOS:CC,'+
        ':ISOLE FAEROER:FO,'+
        ':ISOLE FALKLAND:FK,'+
        ':ISOLE FIGI:FJ,'+
        ':ISOLE MARIANNE:MP,'+
        ':ISOLE MARSHALL:MH,'+
        ':ISOLE MINORI (USA):UM,'+
        ':ISOLE PALAU:PW,'+
        ':ISOLE SALOMONE:SB,'+
        ':ISOLE TOKELAU:TK,'+
        ':ISOLE VERGINI (BRIT:VG,'+
        ':ISOLE VERGINI (USA):VI,'+
        ':ISRAELE:IL,'+
        ':ITALIA:IT,'+
        ':KAZAKISTAN:KZ,'+
        ':KENYA:KE,'+
        ':KIRGHIZISTAN:KG,'+
        ':KIRIBATI:KI,'+
        ':KOSOVO:XZ,'+
        ':KUWAIT:KW,'+
        ':LAOS:LA,'+
        ':LESOTHO:LS,'+
        ':LETTONIA:LV,'+
        ':LIBANO:LB,'+
        ':LIBERIA:LR,'+
        ':LIBIA:LY,'+
        ':LIECHTENSTEIN:LI,'+
        ':LITUANIA:LT,'+
        ':LUSSEMBURGO:LU,'+
        ':MACAO:MO,'+
        ':MACEDONIA:MK,'+
        ':MADAGASCAR:MG,'+
        ':MALAISIA:MY,'+
        ':MALAWI:MW,'+
        ':MALDIVE:MV,'+
        ':MALI:ML,'+
        ':MALTA:MT,'+
        ':MAROCCO:MA,'+
        ':MARTINICA:MQ,'+
        ':MAURITANIA:MR,'+
        ':MAURIZIO:MU,'+
        ':MAYOTTE:YT,'+
        ':MESSICO:MX,'+
        ':MOLDAVIA:MD,'+
        ':MONGOLIA:MN,'+
        ':MONTECARLO:MC,'+
        ':MONTSERRAT:MS,'+
        ':MOZAMBICO:MZ,'+
        ':MYANMAR (UNIONE):MM,'+
        ':NAMIBIA:NA,'+
        ':NAURU:NR,'+
        ':NEPAL:NP,'+
        ':NICARAGUA:NI,'+
        ':NIGER:NE,'+
        ':NIGERIA:NG,'+
        ':NORVEGIA:NO,'+
        ':NUOVA CALEDONIA:NC,'+
        ':NUOVA ZELANDA:NZ,'+
        ':OLANDA:NL,'+
        ':OMAN:OM,'+
        ':PAKISTAN:PK,'+
        ':PANAMA:PA,'+
        ':PAPUA-NUOVA GUINEA:PG,'+
        ':PARAGUAY:PY,'+
        ':PERU\':PE,'+
        ':PITCAIRN:PN,'+
        ':POLINESIA FRANCESE:PF,'+
        ':POLONIA:PL,'+
        ':PORTOGALLO:PT,'+
        ':PORTORICO:PR,'+
        ':QATAR:QA,'+
        ':REP. DEMOCRATICA CO:CD,'+
        ':REPUBBLICA CECA:CZ,'+
        ':REPUBBLICA DEL CONG:CG,'+
        ':REPUBBLICA DI GUINE:GN,'+
        ':REPUBBLICA DOMINICA:DO,'+
        ':REPUBBLICA SLOVACCA:SK,'+
        ':REUNION:RE,'+
        ':ROMANIA:RO,'+
        ':RUANDA:RW,'+
        ':RUSSIA:RU,'+
        ':SAINT VINCENT E GRE:VC,'+
        ':SAINT-PIERRE ET MIQ:PM,'+
        ':SALVADOR:SV,'+
        ':SAMOA (USA):AS,'+
        ':SAMOA OCCIDENTALI:WS,'+
        ':SAN CRISTOFORO E NE:KN,'+
        ':SAN MARINO:SM,'+
        ':SANTA LUCIA:LC,'+
        ':SAO TOME\' E PRINCIP:ST,'+
        ':SENEGAL:SN,'+
        ':SERBIA E MONTENEGRO:YU,'+
        ':SEYCHELLES:SC,'+
        ':SIERRA LEONE:SL,'+
        ':SINGAPORE:SG,'+
        ':SIRIA:SY,'+
        ':SLOVENIA:SI,'+
        ':SOMALIA:SO,'+
        ':SPAGNA:ES,'+
        ':SRI LANKA:LK,'+
        ':STATI UNITI D\'AMERI:US,'+
        ':SUD AFRICA:ZA,'+
        ':SUDAN:SD,'+
        ':SURINAME:SR,'+
        ':SVEZIA:SE,'+
        ':SVIZZERA:CH,'+
        ':SWAZILAND:SZ,'+
        ':TAGISKISTAN:TJ,'+
        ':TAILANDIA:TH,'+
        ':TAIWAN:TW,'+
        ':TANZANIA:TZ,'+
        ':TIMOR ORIENTALE:TP,'+
        ':TOGO:TG,'+
        ':TONGA:TO,'+
        ':TRINIDAD E TOBAGO:TT,'+
        ':TUNISIA:TN,'+
        ':TURCHIA:TR,'+
        ':TURKMENISTAN:TM,'+
        ':TURKS E CAICOS:TC,'+
        ':TUVALU:TV,'+
        ':UCRAINA:UA,'+
        ':UGANDA:UG,'+
        ':UNGHERIA:HU,'+
        ':UNIONE SOVIETICA:SU,'+
        ':URUGUAY:UY,'+
        ':UZBEKISTAN:UZ,'+
        ':VANUATU:VU,'+
        ':VENEZUELA:VE,'+
        ':VIETNAM:VN,'+
        ':WALLIS E FUTUNA:WF,'+
        ':YEMEN:YE,'+
        ':ZAIRE:ZR,'+
        ':ZAMBIA:ZM,'+
        ':ZIMBABWE:ZW';
        String result = 'ITALIA';
        for(String elem :registry.split(',')){
            List<String> elems = elem.split(':');
            if(code == elems[2]){ 
                result = elems[1]; 
                break;
            }
        }
        //SM - fix
        if(code != null && code.length()>2){result = code;}
        return result;
    }

    @AuraEnabled
    public static String insertAccount(AccountWrapper acc){
        // AccountWrapper acc = (AccountWrapper) JSON.deserializeStrict(accStr, AccountWrapper.Class);
        System.debug('@@@ acc ' + acc.name);

        acc.paese = CodeToCountry(acc.paese);
        System.debug('Paese: '+acc.paese);
        List<Account> existingAccount = new List<Account>();
        if(acc.naturaGiuridica == 'PERSONA FISICA'){
            existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE  Codice_fiscale__c =: acc.codiceFiscale AND Forma_giuridica__c =: acc.naturaGiuridica];
        }else{
            
            if(acc.paese != 'ITALIA' && acc.paese != null){
                existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE  name =: acc.name.split('###')[0] AND BillingCountry =: acc.paese];
            }else if(acc.name != null && acc.partitaIva == null && acc.codiceFiscale == null){
                existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Name =: acc.name.split('###')[0]];
            } else if(acc.partitaIva != null && acc.codiceFiscale != null){
                existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Partita_iva__c =: acc.partitaIva AND Codice_fiscale__c =: acc.codiceFiscale];
            } else if(acc.partitaIva != null && acc.codiceFiscale == null){
                existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Partita_iva__c =: acc.partitaIva AND Codice_Fiscale__c = null];
            } else if(acc.partitaIva == null && acc.codiceFiscale != null){ //SM - FIX
                existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Codice_fiscale__c =: acc.codiceFiscale AND Partita_Iva__c = null];
            }
        }
        
        TXT_ProcessiLeadAccountUtils u = new TXT_ProcessiLeadAccountUtils();

        Account a = new Account();

        a.Name = acc.name.split('###')[0];
        System.debug('Account name: ' + a.name);
        if(acc.partitaIva!=null && acc.partitaIva.length()<12){
            a.Partita_iva__c = acc.partitaIva;
        }
        a.Codice_fiscale__c = acc.codiceFiscale;
        a.denosociale__c = acc.ragioneSociale;
        a.CCIAA_REA__c = acc.cciaa.split('###')[0] == 'undefined' || acc.cciaa.split('###')[0] == 'null' ? '' : acc.cciaa.split('###')[0];
        a.CCIAA_CMK__c = acc.cciaa.split('###')[1] == 'undefined' || acc.cciaa.split('###')[1] == 'null' ? '' : acc.cciaa.split('###')[1];
        a.Forma_giuridica__c = acc.naturaGiuridica;
        a.BillingStreet = acc.via;
        a.BillingCity = acc.citta;
        a.BillingState = acc.provincia;
        a.BillingPostalCode = acc.cap;
        a.BillingCountry = acc.paese;
        a.Data_Bilancio__c = acc.dataBilancio;
        a.Acquisti_totali__c = acc.acquistiTotali;
        a.Data_di_cessazione__c = acc.dataCessazione;
        a.Anno_rilevazione_addetti__c = acc.annoRilevazioneAddetti;
        a.Data_Inizio_Attivita__c = acc.dataInizioAttivita;
        a.AnnualRevenue = acc.annualRevenue;
        a.Livello_attenzione_negativita__c = acc.livelloAttenzioneNegativita;
        a.Capitale_Sociale__c = acc.capitaleSociale;
        a.Crediti_vs_Clienti__c = acc.creditiVsClienti;
        a.Risultato_Operativo_Lordo__c = acc.risultatoOperativoLordo;
        // a.Phone_Warrant__c = phone;
        a.Phone = acc.phone;
        a.Email_Aziendale_Innolva__c = acc.email;
        a.Totale_Patrimonio_Netto_Tinexta__c = acc.totalePatrimonioNetto;
        a.Fax = acc.fax;
        a.Utile_Perdita__c = acc.utilePerdita;
        a.Stato_Attivita__c = acc.statoAttivita;

        // a.Fatturato__c = acc.fatturato;
        a.Fatturato__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(acc.annualRevenue);

        a.Rating__c = acc.rating;

        a.Dipendenti__c = acc.dipendenti;

        a.Codice_Ateco_Innolva__c = acc.codiceAteco;
        a.Descrizione_Ateco_Innolva__c = acc.descrizioneAteco;
        a.Cliente_Estero__c = acc.clienteEstero;
        a.TXT_Gruppo_IVA__c = acc.gruppoIva;
        a.TXT_Denominazione_Gruppo_IVA__c = acc.denominazioneGruppoIva;
        a.Errore_Monitoraggio__c = acc.erroreMonitoraggio;
        a.INN_societa__c = acc.societainn;
        a.REV_societa__c = acc.societarev;
        a.Societa_su_CTM__c = acc.societasuctm;

        if(acc.name.split('###')[1]=='true'){
            if(existingAccount.isEmpty()){
                a.Censimento_Manuale__c = true;
            }
        }else{
            if(existingAccount.isEmpty()) {
                a.Censimento_Manuale__c = false;
                a.Data_Ultimo_Arricchimento__c = date.today();
            }
        }
        
        User currUsr = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];

        if(existingAccount.size()>0){
            a.id = existingAccount[0].id;
            // if(existingAccount[0].Censimento_Manuale__c==true){a.Censimento_Manuale__c=true;}
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.DuplicateRuleHeader.AllowSave = true;
            Database.update(a, dmlOptions);
            // update a;
        }else{
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.DuplicateRuleHeader.AllowSave = true;
            //SM - popolo società di riferimento per insert account
            a.Societa_di_riferimento__c = currUsr.Societa__c;
            Database.SaveResult lsr = Database.insert(a, dmlOptions);
            System.debug('@@@ a ' + a.Id);
            if(!lsr.isSuccess()){
                for(Database.Error err : lsr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    throw new CalloutException(err.getStatusCode() + ': ' + err.getMessage());
                }        
            } else {
                if(a.Id == null){
                    a.Id = lsr.getId();
                }
            }
            // insert a;
        }

        // if(naturaGiuridica == 'PERSONA FISICA'){
        List<Coverage_Team_Member__c> existingCTM = new List<Coverage_Team_Member__c>([SELECT Id,Societa__c,User__c,Ruolo_Coverage_Team__c FROM Coverage_Team_Member__c WHERE Account__c =: a.Id]);
        system.debug('EU Account' + a.id);
        List<Account> AccStato = new List<Account> ([SELECT Id, INN_Stato__c FROM Account WHERE Id=: a.Id]);
        system.debug('EU Size Account ' + AccStato.size());
		system.debug('EU Società User ' + currUsr.Societa__c);
        system.debug('EU Size CTM ' + existingCTM.size() );

        if(existingCTM.isEmpty()){
            system.debug('EU Nuovo Account');
            Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
            ctm.Account__c = a.id;
            ctm.User__c = UserInfo.getUserId();
            ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
            insert ctm;
            return a.Id;
        }
        

        Boolean Tinexta = false;
        Boolean Infocert = false;
        Boolean Innolva = false;
        Boolean Warrant = false;
        Boolean WRTRuolo = false;

       
            for(Coverage_Team_Member__c c:existingCTM){
                system.debug('DENTRO FOR');
                
                system.debug('EU c.società' + c.Societa__c);

                if(c.User__c == UserInfo.getUserId()){
                    Tinexta=true;
                }
                if(c.User__c == UserInfo.getUserId() && currUsr.Societa__c == 'InfoCert' ){
                    system.debug('Caso Infocert non faccio niente');
                    Infocert=true;
                }
                if(currUsr.Societa__c == 'InfoCert' && c.Societa__c == 'Infocert'){
                    system.debug('Caso Infocert non faccio niente v2');
                    Infocert=true;
                }
                if(c.User__c == UserInfo.getUserId() && currUsr.Societa__c == 'Innolva'){
                    system.debug('Caso Innolva non faccio niente');
                    Innolva=true;
                }
                
                if(c.Ruolo_Coverage_Team__c == 'Responsabile Account' && c.Societa__c == 'Warrant' &&  currUsr.Societa__c == 'Warrant'){
                    system.debug('Caso Warrant cambio ruolo');
                    WRTRuolo=true;
                }
                if(c.User__c == UserInfo.getUserId() && currUsr.Societa__c == 'Warrant'){
                    Warrant=true;
                }
            }
       
      
            If(AccStato != null && !AccStato.isEmpty() && AccStato.get(0).INN_Stato__c == 'Customer' && currUsr.Societa__c == 'Innolva'){
                system.debug('EU STATO' + AccStato.get(0).INN_Stato__c);
                Innolva=true;
            }
        

            system.debug('EU Tinexta' + Tinexta);
            system.debug('EU Infocert' + Infocert);
            system.debug('EU Innolva' + Innolva);
            system.debug('EU Warrant' + Warrant);
            system.debug('EU WRTRuolo' + WRTRuolo);

    If((Tinexta == false && currUsr.Societa__c != 'Warrant' 
        && currUsr.Societa__c != 'InfoCert' && currUsr.Societa__c != 'Innolva') || 
        (InfoCert == false && currUsr.Societa__c == 'InfoCert') ||
        (currUsr.Societa__c == 'Innolva' && Innolva == false) || 
        (Warrant == false &&  currUsr.Societa__c == 'Warrant')
        ){
            system.debug('EU Nuovo CTM con Tinexta False');
            Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
            ctm.Account__c = a.id;
            ctm.User__c = UserInfo.getUserId();
            If(WRTRuolo == true){
                ctm.Ruolo_Coverage_Team__c = 'Agenti di vendita'; 
            }else{
            ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
            }
            insert ctm; 
    }
        // }
        
        //Database.UpsertResult upsertRes = Database.upsert(a, Account.Fields.Codice_fiscale__c);
        System.debug(a);
        return a.Id;
    }

    // @AuraEnabled
    // public static String insertAccount(String name,
    // String partitaIva,
    // String codiceFiscale,
    // String ragioneSociale,
    // String cciaa,
    // String naturaGiuridica,
    // String via,
    // String citta,
    // String provincia,
    // String cap,
    // String paese,
    // Date dataBilancio,
    // Double acquistiTotali,
    // Date dataCessazione,
    // String annoRilevazioneAddetti,
    // Date dataInizioAttivita,
    // Double annualRevenue,
    // String livelloAttenzioneNegativita,
    // Double capitaleSociale,
    // Double creditiVsClienti,
    // Double risultatoOperativoLordo,
    // String phone,
    // String email,
    // Double totalePatrimonioNetto,
    // String fax,
    // Double utilePerdita,
    // String statoAttivita,
    // String fatturato,
    // String rating,
    // String dipendenti,
    // String codiceAteco,
    // String descrizioneAteco){
    //     paese = CodeToCountry(paese);
    //     System.debug('Paese: '+paese);
    //     List<Account> existingAccount = new List<Account>();
    //     if(naturaGiuridica == 'PERSONA FISICA'){
    //         existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE  Codice_fiscale__c =: codiceFiscale AND Forma_giuridica__c =: naturaGiuridica];
    //     }else{
            
    //         if(paese != 'ITALIA' && paese != null){
    //             existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE  name =: name.split('###')[0] AND BillingCountry =:paese];
    //         }else if(name != null && partitaIva == null && codiceFiscale == null){
    //             existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Name =: name.split('###')[0]];
    //         } else if(partitaIva != null){
    //             existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Partita_iva__c =: partitaIva];
    //         } else if(partitaIva == null && codiceFiscale != null){ //SM - FIX
    //             existingAccount = [SELECT Id, Censimento_Manuale__c FROM Account WHERE Codice_fiscale__c =: codiceFiscale];
    //         }
    //     }
        
    //     TXT_ProcessiLeadAccountUtils u = new TXT_ProcessiLeadAccountUtils();

    //     Account a = new Account();

    //     a.Name = name.split('###')[0];
    //     System.debug('Account name: ' + a.name);
    //     if(partitaIva!=null && partitaIva.length()<12){
    //         a.Partita_iva__c = partitaIva;
    //     }
    //     a.Codice_fiscale__c = codiceFiscale;
    //     a.denosociale__c = ragioneSociale;
    //     a.CCIAA_REA__c = cciaa.split('###')[0];
    //     a.CCIAA_CMK__c = cciaa.split('###')[1];
    //     a.Forma_giuridica__c = naturaGiuridica;
    //     a.BillingStreet = via;
    //     a.BillingCity = citta;
    //     a.BillingState = provincia;
    //     a.BillingPostalCode = cap;
    //     a.BillingCountry = paese;
    //     a.Data_Bilancio__c = dataBilancio;
    //     a.Acquisti_totali__c = acquistiTotali;
    //     a.Data_di_cessazione__c = dataCessazione;
    //     a.Anno_rilevazione_addetti__c = annoRilevazioneAddetti;
    //     a.Data_Inizio_Attivita__c = dataInizioAttivita;
    //     a.AnnualRevenue = annualRevenue;
    //     a.Livello_attenzione_negativita__c = livelloAttenzioneNegativita;
    //     a.Capitale_Sociale__c = capitaleSociale;
    //     a.Crediti_vs_Clienti__c = creditiVsClienti;
    //     a.Risultato_Operativo_Lordo__c = risultatoOperativoLordo;
    //     // a.Phone_Warrant__c = phone;
    //     a.Phone = phone;
    //     a.Email_Aziendale_Innolva__c = email;
    //     a.Totale_Patrimonio_Netto_Tinexta__c = totalePatrimonioNetto;
    //     a.Fax = fax;
    //     a.Utile_Perdita__c = utilePerdita;
    //     a.Stato_Attivita__c = statoAttivita;

    //     a.Fatturato__c = fatturato;

    //     a.Rating__c = rating;

    //     a.Dipendenti__c = dipendenti;

    //     a.Codice_Ateco_Innolva__c = codiceAteco;
    //     a.Descrizione_Ateco_Innolva__c = descrizioneAteco;

    //     if(name.split('###')[1]=='true'){
    //         if(existingAccount.isEmpty()){
    //             a.Censimento_Manuale__c = true;
    //         }
    //     }else{
    //         if(existingAccount.isEmpty()) {
    //             a.Censimento_Manuale__c = false;
    //             a.Data_Ultimo_Arricchimento__c = date.today();
    //         }
    //     }
        
        

    //     if(existingAccount.size()>0){
    //         a.id = existingAccount[0].id;
    //         // if(existingAccount[0].Censimento_Manuale__c==true){a.Censimento_Manuale__c=true;}
    //         update a;
    //     }else{
    //         insert a;
    //     }

    //     // if(naturaGiuridica == 'PERSONA FISICA'){
    //     List<Coverage_Team_Member__c> existingCTM = new List<Coverage_Team_Member__c>([SELECT Id,Societa__c,User__c,Ruolo_Coverage_Team__c FROM Coverage_Team_Member__c WHERE Account__c =: a.Id]);
    //     User currUsr = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
    //     system.debug('EU Account' + a.id);
    //     List<Account> AccStato = new List<Account> ([SELECT Id, INN_Stato__c FROM Account WHERE Id=: a.Id]);
    //     system.debug('EU Size Account ' + AccStato.size());
	// 	system.debug('EU Società User ' + currUsr.Societa__c);
    //     system.debug('EU Size CTM ' + existingCTM.size() );

    //     if(existingCTM.isEmpty()){
    //         system.debug('EU Nuovo Account');
    //         Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
    //         ctm.Account__c = a.id;
    //         ctm.User__c = UserInfo.getUserId();
    //         ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
    //         insert ctm;
    //     }
        

    //     Boolean Tinexta = false;
    //     Boolean Infocert = false;
    //     Boolean Innolva = false;
    //     Boolean Warrant = false;
    //     Boolean WRTRuolo = false;

       
    //         for(Coverage_Team_Member__c c:existingCTM){
    //             system.debug('DENTRO FOR');
                
    //             system.debug('EU c.società' + c.Societa__c);

    //             if(c.User__c == UserInfo.getUserId()){
    //                 Tinexta=true;
    //             }
    //             if(c.User__c == UserInfo.getUserId() && currUsr.Societa__c == 'InfoCert' ){
    //                 system.debug('Caso Infocert non faccio niente');
    //                 Infocert=true;
    //             }
    //             if(currUsr.Societa__c == 'InfoCert' && c.Societa__c == 'Infocert'){
    //                 system.debug('Caso Infocert non faccio niente v2');
    //                 Infocert=true;
    //             }
    //             if(c.User__c == UserInfo.getUserId() && currUsr.Societa__c == 'Innolva'){
    //                 system.debug('Caso Innolva non faccio niente');
    //                 Innolva=true;
    //             }
                
    //             if(c.Ruolo_Coverage_Team__c == 'Responsabile Account' && c.Societa__c == 'Warrant' &&  currUsr.Societa__c == 'Warrant'){
    //                 system.debug('Caso Warrant cambio ruolo');
    //                 WRTRuolo=true;
    //             }
    //             if(c.User__c == UserInfo.getUserId() && currUsr.Societa__c == 'Warrant'){
    //                 Warrant=true;
    //             }
    //         }
       
      
    //         If(AccStato.get(0).INN_Stato__c == 'Customer' && currUsr.Societa__c == 'Innolva'){
    //             system.debug('EU STATO' + AccStato.get(0).INN_Stato__c);
    //             Innolva=true;
    //         }
        

    //         system.debug('EU Tinexta' + Tinexta);
    //         system.debug('EU Infocert' + Infocert);
    //         system.debug('EU Innolva' + Innolva);
    //         system.debug('EU Warrant' + Warrant);
    //         system.debug('EU WRTRuolo' + WRTRuolo);

    // If((Tinexta == false && currUsr.Societa__c != 'Warrant' 
    //     && currUsr.Societa__c != 'InfoCert' && currUsr.Societa__c != 'Innolva') || 
    //     (InfoCert == false && currUsr.Societa__c == 'InfoCert') ||
    //     (currUsr.Societa__c == 'Innolva' && Innolva == false) || 
    //     (Warrant == false &&  currUsr.Societa__c == 'Warrant')
    //     ){
    //         system.debug('EU Nuovo CTM con Tinexta False');
    //         Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
    //         ctm.Account__c = a.id;
    //         ctm.User__c = UserInfo.getUserId();
    //         If(WRTRuolo == true){
    //             ctm.Ruolo_Coverage_Team__c = 'Agenti di vendita'; 
    //         }else{
    //         ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
    //         }
    //         insert ctm; 
    // }
    //     // }
        
    //     //Database.UpsertResult upsertRes = Database.upsert(a, Account.Fields.Codice_fiscale__c);
    //     System.debug(a);
    //     return a.Id;
    // }

    @AuraEnabled
    public static Boolean isOverrideActionAccount(){

        Boolean isOverride = true;
        User currentUser = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];

        if(currentUser.Societa__c == 'Camerfirma'){
            isOverride = false;
        }

        return isOverride;
    }


    public class AccountWrapper{
        @AuraEnabled public String name {public get; public set;}
        @AuraEnabled public String partitaIva {get;set;}
        @AuraEnabled public String codiceFiscale {get;set;}
        @AuraEnabled public String ragioneSociale {get;set;}
        @AuraEnabled public String cciaa {get;set;}
        @AuraEnabled public String naturaGiuridica {get;set;}
        @AuraEnabled public String via {get;set;}
        @AuraEnabled public String citta {get;set;}
        @AuraEnabled public String provincia {get;set;}
        @AuraEnabled public String cap {get;set;}
        @AuraEnabled public String paese {get;set;}
        @AuraEnabled public Date dataBilancio {get;set;}
        @AuraEnabled public Double acquistiTotali {get;set;}
        @AuraEnabled public Date dataCessazione {get;set;}
        @AuraEnabled public String annoRilevazioneAddetti {get;set;}
        @AuraEnabled public Date dataInizioAttivita {get;set;}
        @AuraEnabled public Double annualRevenue {get;set;}
        @AuraEnabled public String livelloAttenzioneNegativita {get;set;}
        @AuraEnabled public Double capitaleSociale {get;set;}
        @AuraEnabled public Double creditiVsClienti {get;set;}
        @AuraEnabled public Double risultatoOperativoLordo {get;set;}
        @AuraEnabled public String phone {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public Double totalePatrimonioNetto {get;set;}
        @AuraEnabled public String fax {get;set;}
        @AuraEnabled public Double utilePerdita {get;set;}
        @AuraEnabled public String statoAttivita {get;set;}
        @AuraEnabled public String fatturato {get;set;}
        @AuraEnabled public String rating {get;set;}
        @AuraEnabled public String dipendenti {get;set;}
        @AuraEnabled public String codiceAteco {get;set;}
        @AuraEnabled public String descrizioneAteco {get;set;}
        @AuraEnabled public Boolean clienteEstero {get;set;}
        @AuraEnabled public String gruppoIva {get;set;}
        @AuraEnabled public String denominazioneGruppoIva {get;set;}
        @AuraEnabled public Boolean erroreMonitoraggio {get;set;}
        @AuraEnabled public String societasuctm {get;set;}
        @AuraEnabled public String societainn {get;set;}
        @AuraEnabled public String societarev {get;set;}
    }    
}