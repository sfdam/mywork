public without sharing class TXT_ConversioneLead {
    
    @AuraEnabled
    public static Boolean isCommunity(){
        System.debug('@@@ ' + UserInfo.getUserType());
        return UserInfo.getUserType() == 'PowerPartner';
    }
    
    @AuraEnabled
    public static Account TXT_RecapInfo(Id lid , Account WA, string SocietaUser) {
        String[] Data = new List<String>();
        if(lid!=null){
            Lead l = [SELECT Id, Company, Forma_giuridica__c, Natura_Giuridica_Innolva__c, Codice_Fiscale__c, Partiva_Iva__c
                      FROM Lead WHERE Id =: lid];
            Data.add(l.Forma_giuridica__c);
            Data.add(l.Codice_Fiscale__c);
            Data.add(l.Partiva_Iva__c);
            Data.add(l.Company);
            //SM - FIX
            if(WA != null && WA.BillingCountry != null)
                Data.add(WA.BillingCountry);
            else
                Data.add('ITALIA');

            Data.add(SocietaUser);
        }else{
            Data.add(WA.Forma_giuridica__c);
            Data.add(WA.Codice_fiscale__c);
            Data.add(WA.Partita_iva__c);
            Data.add(WA.Name);
            //SM - FIX
            if(WA != null && WA.BillingCountry != null)
                Data.add(WA.BillingCountry);
            else
                Data.add('ITALIA');

            Data.add(SocietaUser);
        }
        TXT_ProcessiLeadAccountUtils u = new TXT_ProcessiLeadAccountUtils();
        List<Account> result = new List<Account>();
        if(Data[0] == 'PERSONA FISICA'){
            result = u.TXT_Verifica_Account_PF(Data);
        }else if(String.isBlank(Data[0])==true){
            //if (String.isBlank(Data[1])){
            result = u.TXT_Verifica_Account_PG(Data);
            /* }else if(String.isBlank(Data[2])){
result = u.TXT_Verifica_Account_PF(Data);
}*/
        }else{
            result = u.TXT_Verifica_Account_PG(Data);
        }
        
        
        if(result.size()>0){System.Debug(result[0]); return result[0];}else{ return null;}
        
    }
    
    @AuraEnabled
    public static Lead TXT_UpdateLead(Id lid, Account WA, Boolean Fake) {
        System.Debug('LID: '+ lid);
        User u = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        Lead l = [SELECT Id, Phone, Fax FROM Lead WHERE Id =: lid];
        // WA >> l
        //WA.denosociale__c;
        l.Company = WA.Name;
        l.CCIAA_CMK__c = WA.CCIAA_CMK__c;
        l.CCIAA_REA_Innolva__c = WA.CCIAA_REA__c;
        
        l.Partiva_Iva__c = WA.Partita_iva__c;
        l.Codice_Fiscale__c = WA.Codice_fiscale__c;
        l.Street = WA.BillingStreet;
        l.State = WA.BillingState;
        l.PostalCode = WA.BillingPostalCode;
        l.Country = WA.BillingCountry;
        l.City = WA.BillingCity;
        l.Forma_giuridica__c = WA.Forma_giuridica__c;
        
        l.Data_Bilancio_Innolva__c = WA.Data_Bilancio__c;
        l.Acquisti_totali_Innolva__c = WA.Acquisti_totali__c;
        l.Data_di_Iscrizione_Innolva__c = WA.Data_di_Iscrizione__c;
        l.Data_di_cessazione_Innolva__c = WA.Data_di_cessazione__c;
        l.Anno_rilevazione_addetti_Innolva__c = WA.Anno_rilevazione_addetti__c;
        l.Data_Inizio_Attivita_Innolva__c = WA.Data_Inizio_Attivita__c;
        l.AnnualRevenue = WA.AnnualRevenue;
        l.Livello_attenzione_negativita_Innolva__c = WA.Livello_attenzione_negativita__c;
        l.Capitale_Sociale_Innolva__c = WA.Capitale_Sociale__c;
        l.Crediti_vs_Clienti_Innolva__c = WA.Crediti_vs_Clienti__c;
        l.Risultato_Operativo_Lordo_Innolva__c = WA.Risultato_Operativo_Lordo__c;
        // l.Telefono_personale_Warrant__c = WA.Phone_Warrant__c;
        
        if(u.Societa__c == 'Innolva'){
            l.Phone_Innolva__c = l.Phone;
            l.Fax_Innolva__c = l.Fax;
        }
        
        
        if(WA.Censimento_Manuale__c == false){
            l.Phone = WA.Phone;
        }
        l.Totale_Patrimonio_Netto_Innolva__c = WA.Totale_Patrimonio_Netto_Tinexta__C;
        l.Fax = WA.Fax;
        l.Utile_Perdita_Innolva__c = WA.Utile_Perdita__c;
        l.Stato_Attivita_Innolva__c = WA.Stato_Attivita__c;
        // l.Fatturato__c = WA.Fatturato__c;
        // // l.Rating_Lead__c = WA.Rating__c;
        // l.Rating_Warrant__c = WA.Rating__c;
        // l.Dipendenti__c = WA.Dipendenti__c;
        // SM - FIX - Tolto il campo Fatturato__c
        // l.Fatturato_Warrant__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(WA.Fatturato__c);
        l.Fatturato_Warrant__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(l.AnnualRevenue);
        // SM - FIX
        l.Rating_Lead__c = WA.Rating__c;
        // l.Rating_Warrant__c = WA.Rating__c;
        l.Dipendenti__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Dipendenti(WA.Dipendenti__c);
        l.Codice_Ateco_Innolva__c = WA.Codice_Ateco_Innolva__c;
        l.Descrizione_Ateco_Innolva__c = WA.Descrizione_Ateco_Innolva__c;
        l.Email_Aziendale_Innolva__c = WA.Email_Aziendale_Innolva__c;
        l.TXT_Gruppo_IVA__c = WA.TXT_Gruppo_IVA__c;
        l.TXT_Denominazione_Gruppo_IVA__c = WA.TXT_Denominazione_Gruppo_IVA__c;
        l.Errore_Monitoraggio__c = WA.Errore_Monitoraggio__c;
        
        if(Fake==false){
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.DuplicateRuleHeader.AllowSave = true;
            Database.update(l, dmlOptions);
        }
        
        return l;
    }
    
    
    @AuraEnabled
    public static Lead TXT_RetriveDataLead(Id lid) {
        Lead l = [SELECT Id, Company, Forma_giuridica__c, Natura_Giuridica_Innolva__c, Codice_Fiscale__c, Partiva_Iva__c,
                  CCIAA_CMK__c,
                  CCIAA_REA_Innolva__c,
                  Street,
                  State,
                  PostalCode,
                  Country,
                  City,
                  Dipendenti__c,
                  Fatturato_Warrant__c
                  FROM Lead WHERE Id =: lid];
        return l;
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
        // String result = 'ITALIA';
        String result;
        if(code!=null){
            for(String elem :registry.split(',')){
                List<String> elems = elem.split(':');
                if(code == elems[2]){ 
                    result = elems[1]; 
                    break;
                }
            }
            if(code.length()>2){result = code;}
        }
        return result;
    }
    
    @AuraEnabled
    public static Id TXT_UpdateLeadBeforeConversion(Id Lid, Id Id, String ACName,
                                                    String Forma_giuridica, 
                                                    String Natura_Giuridica,
                                                    String CCIAA_CMK,
                                                    String CCIAA_REA,
                                                    String denosociale,
                                                    String Partita_iva,
                                                    String Codice_fiscale,
                                                    String Via_Sede_Legale,
                                                    String Provincia_Sede_Legale,
                                                    String CAP_Sede_Legale,
                                                    String Paese_Sede_Legale,
                                                    String Citta_Sede_Legale,
                                                    Boolean Censimento_Manuale,
                                                    String Fatturato,
                                                    String Dipendenti,
                                                    String GruppoIVA,
                                                    String DenominazioneGruppoIVA,
                                                    String convertStatus,
                                                    Boolean Opportnunity,
                                                    Boolean clienteEstero){
                                                        Lead Lead_Da_Convertire = [SELECT Id, Status, Email,
                                                                                   Forma_giuridica__c, 
                                                                                   Natura_Giuridica_Innolva__c, 
                                                                                   Codice_Fiscale__c, 
                                                                                   Partiva_Iva__c,
                                                                                   CCIAA_CMK__c,
                                                                                   CCIAA_REA_Innolva__c,
                                                                                   Street,
                                                                                   State,
                                                                                   PostalCode,
                                                                                   Country,
                                                                                   City, 
                                                                                   Fatturato_Warrant__c,
                                                                                   Dipendenti__c,
                                                                                   Censimento_Manuale__c, OwnerId FROM Lead WHERE Id =: Lid LIMIT 1];
                                                        Lead_Da_Convertire.Status = 'Convertito';
                                                        
                                                        Lead_Da_Convertire.Censimento_Manuale__c = Censimento_Manuale;
                                                        Lead_Da_Convertire.Company = ACName;
                                                        
                                                        if(Forma_giuridica!= null && Forma_giuridica.length()>1){
                                                            Lead_Da_Convertire.Forma_giuridica__c = Forma_giuridica;
                                                        }
                                                        if(Natura_Giuridica != null && Natura_Giuridica.length()>1){
                                                            Lead_Da_Convertire.Natura_Giuridica_Innolva__c =  Natura_Giuridica;
                                                        }
                                                        if(Codice_fiscale!= null && Codice_fiscale.length()>1){
                                                            Lead_Da_Convertire.Codice_Fiscale__c = Codice_fiscale;
                                                        }
                                                        if(Partita_iva!= null && Partita_iva.length()>1){
                                                            Lead_Da_Convertire.Partiva_Iva__c = Partita_iva;
                                                        }
                                                        if(CCIAA_CMK != null && CCIAA_CMK.length()>1 && CCIAA_CMK != 'undefined' && CCIAA_CMK != 'null'){
                                                            Lead_Da_Convertire.CCIAA_CMK__c = CCIAA_CMK;
                                                        }
                                                        if(CCIAA_REA != null && CCIAA_REA.length()>1 && CCIAA_REA != 'undefined' && CCIAA_REA != 'null'){
                                                            Lead_Da_Convertire.CCIAA_REA_Innolva__c = CCIAA_REA;
                                                        }
                                                        if(Via_Sede_Legale != null && Via_Sede_Legale.length()>1){
                                                            Lead_Da_Convertire.Street = Via_Sede_Legale;
                                                        }
                                                        if(Provincia_Sede_Legale != null && Provincia_Sede_Legale.length()>1){
                                                            Lead_Da_Convertire.State = Provincia_Sede_Legale;
                                                        }
                                                        if(CAP_Sede_Legale != null && CAP_Sede_Legale.length()>1){
                                                            Lead_Da_Convertire.PostalCode = CAP_Sede_Legale;
                                                        }
                                                        if(Paese_Sede_Legale != null && Paese_Sede_Legale.length()>1){
                                                            Lead_Da_Convertire.Country = Paese_Sede_Legale;
                                                        }
                                                        if(Citta_Sede_Legale != null && Citta_Sede_Legale.length()>1){
                                                            Lead_Da_Convertire.City = Citta_Sede_Legale;
                                                        }
                                                        
                                                        Lead_Da_Convertire.Country = CodeToCountry(Lead_Da_Convertire.Country);
                                                        if(!Censimento_Manuale || (!Censimento_Manuale && clienteEstero)) {
                                                            Lead_Da_Convertire.Data_ultimo_arricchimento__c = date.today();
                                                        }
                                                        Lead_Da_Convertire.YOR_Cliente_Estero__c = clienteEstero;
                                                        Lead_Da_Convertire.TXT_Gruppo_IVA__c = GruppoIVA;
                                                        Lead_Da_Convertire.TXT_Denominazione_Gruppo_IVA__c = DenominazioneGruppoIVA;
                                                        update Lead_Da_Convertire;
                                                        
                                                        return Lid;
                                                    }
    
    @AuraEnabled
    public static Account TXT_ProcessoDiConversione(Id Lid, Id Id, String ACName,
                                                    String Forma_giuridica, 
                                                    String Natura_Giuridica,
                                                    String CCIAA_CMK,
                                                    String CCIAA_REA,
                                                    String denosociale,
                                                    String Partita_iva,
                                                    String Codice_fiscale,
                                                    String Via_Sede_Legale,
                                                    String Provincia_Sede_Legale,
                                                    String CAP_Sede_Legale,
                                                    String Paese_Sede_Legale,
                                                    String Citta_Sede_Legale,
                                                    Boolean Censimento_Manuale,
                                                    String Fatturato,
                                                    String Dipendenti,
                                                    String convertStatus,
                                                    Boolean Opportnunity) {
                                                        
                                                        Lead Lead_Da_Convertire = [SELECT Id, Status, Email,
                                                                                   Forma_giuridica__c, 
                                                                                   Natura_Giuridica_Innolva__c, 
                                                                                   Codice_Fiscale__c, 
                                                                                   Partiva_Iva__c,
                                                                                   CCIAA_CMK__c,
                                                                                   CCIAA_REA_Innolva__c,
                                                                                   Street,
                                                                                   State,
                                                                                   PostalCode,
                                                                                   Country,
                                                                                   City, 
                                                                                   Fatturato_Warrant__c,
                                                                                   FatturatoFascia_Innolva__c,
                                                                                   Dipendenti__c,
                                                                                   Censimento_Manuale__c, OwnerId FROM Lead WHERE Id =: Lid];
                                                        // Lead_Da_Convertire.Status = 'Convertito';
                                                        
                                                        // Lead_Da_Convertire.Censimento_Manuale__c = Censimento_Manuale;
                                                        // Lead_Da_Convertire.Company = ACName;
                                                        // /*
                                                        // if(Fatturato!= null && Fatturato.length()>1){
                                                        //     Lead_Da_Convertire.Fatturato__c = Fatturato;
                                                        //     Lead_Da_Convertire.FatturatoFascia_Innolva__c = Fatturato;
                                                        //     Lead_Da_Convertire.Fatturato_Warrant__c = Fatturato;
                                                        //     Lead_Da_Convertire.FatturatoFascia_Innolva__c = Fatturato;
                                                        // }
                                                        // if(Dipendenti!= null && Dipendenti.length()>1){
                                                        //     Lead_Da_Convertire.Dipendenti__c = Dipendenti;
                                                        // }*/
                                                        
                                                        // if(Forma_giuridica!= null && Forma_giuridica.length()>1){
                                                        //     Lead_Da_Convertire.Forma_giuridica__c = Forma_giuridica;
                                                        // }
                                                        // if(Natura_Giuridica != null && Natura_Giuridica.length()>1){
                                                        //     Lead_Da_Convertire.Natura_Giuridica_Innolva__c =  Natura_Giuridica;
                                                        // }
                                                        // if(Codice_fiscale!= null && Codice_fiscale.length()>1){
                                                        //     Lead_Da_Convertire.Codice_Fiscale__c = Codice_fiscale;
                                                        // }
                                                        // if(Partita_iva!= null && Partita_iva.length()>1){
                                                        //     Lead_Da_Convertire.Partiva_Iva__c = Partita_iva;
                                                        // }
                                                        // if(CCIAA_CMK != null && CCIAA_CMK.length()>1){
                                                        //     Lead_Da_Convertire.CCIAA_CMK__c = CCIAA_CMK;
                                                        // }
                                                        // if(CCIAA_REA != null && CCIAA_REA.length()>1){
                                                        //     Lead_Da_Convertire.CCIAA_REA_Innolva__c = CCIAA_REA;
                                                        // }
                                                        // if(Via_Sede_Legale != null && Via_Sede_Legale.length()>1){
                                                        //     Lead_Da_Convertire.Street = Via_Sede_Legale;
                                                        // }
                                                        // if(Provincia_Sede_Legale != null && Provincia_Sede_Legale.length()>1){
                                                        //     Lead_Da_Convertire.State = Provincia_Sede_Legale;
                                                        // }
                                                        // if(CAP_Sede_Legale != null && CAP_Sede_Legale.length()>1){
                                                        //     Lead_Da_Convertire.PostalCode = CAP_Sede_Legale;
                                                        // }
                                                        // if(Paese_Sede_Legale != null && Paese_Sede_Legale.length()>1){
                                                        //     Lead_Da_Convertire.Country = Paese_Sede_Legale;
                                                        // }
                                                        // if(Citta_Sede_Legale != null && Citta_Sede_Legale.length()>1){
                                                        //     Lead_Da_Convertire.City = Citta_Sede_Legale;
                                                        // }
                                                        
                                                        // Lead_Da_Convertire.Country = CodeToCountry(Lead_Da_Convertire.Country);
                                                        // Lead_Da_Convertire.Data_ultimo_arricchimento__c = date.today();
                                                        // update Lead_Da_Convertire;
                                                        
                                                        Database.LeadConvert lc = new database.LeadConvert();
                                                        // lc.setLeadId(Lead_Da_Convertire.Id);
                                                        lc.setLeadId(LId);
                                                        if(convertStatus==null){
                                                            LeadStatus lsconvertStatus = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                                                            lc.setConvertedStatus(lsconvertStatus.ApiName);
                                                        }else{
                                                            lc.convertedStatus = convertStatus;
                                                        }
                                                        
                                                        if(Opportnunity!=true){
                                                            lc.setDoNotCreateOpportunity(true);
                                                        }
                                                        
                                                        Account Acc = new Account();
                                                        if(Id==null){
                                                            System.Debug('Creo nuovo Account');
                                                        }else{
                                                            
                                                            lc.setAccountId(Id);
                                                            // if(Lead_Da_Convertire.Email!=null && Lead_Da_Convertire.Email.length()>6){
                                                            //     List<Contact> contact = [SELECT Id FROM Contact WHERE (Email =: Lead_Da_Convertire.Email AND Email != null) LIMIT 1];
                                                            //     if(contact.size()>0){
                                                            //         lc.setContactId(contact[0].Id);
                                                            //     }
                                                            // }
                                                        }
                                                        
                                                        
                                                        
                                                        Database.LeadConvertResult lcr = Database.convertLead(lc);
                                                        System.assert(lcr.isSuccess());
                                                        
                                                        Acc.Id = lcr.getAccountId();
                                                        
                                                        //     List<Coverage_Team_Member__c> existingCTM = new List<Coverage_Team_Member__c>([SELECT Id,Societa__c,User__c,Ruolo_Coverage_Team__c, Account__c, Account__r.INN_Stato__c FROM Coverage_Team_Member__c WHERE Account__c =: Acc.Id]);
                                                        //     User currUsr = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
                                                        //     // List<Account> AccStato = new List<Account> ([SELECT Id, INN_Stato__c FROM Account WHERE Id=: Acc.Id]);
                                                        //     // system.debug('EU Size Account' +AccStato.size());
                                                        //     List<Account> AccStato = new List<Account>();
                                                        // 	system.debug('EU Società User' + currUsr.Societa__c);
                                                        
                                                        //     if(existingCTM.isEmpty()){
                                                        //         system.debug('EU Nuovo Account');
                                                        
                                                        //         AccStato = [SELECT Id, INN_Stato__c FROM Account WHERE Id=: Acc.Id];
                                                        //         system.debug('EU Size Account' +AccStato.size());
                                                        
                                                        //         Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
                                                        //         ctm.Account__c = Acc.id;
                                                        //         ctm.User__c = Lead_Da_Convertire.OwnerId;
                                                        //         ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
                                                        //         insert ctm;
                                                        //     } else {
                                                        //         Account tmpAcc = new Account(
                                                        //             Id = existingCTM[0].Account__c,
                                                        //             INN_Stato__c = existingCTM[0].Account__r.INN_Stato__c
                                                        //         );
                                                        
                                                        //         AccStato.add(tmpAcc);
                                                        //     }
                                                        
                                                        
                                                        //     Boolean Tinexta = false;
                                                        //     Boolean Infocert = false;
                                                        //     Boolean Innolva = false;
                                                        //     Boolean Warrant = false;
                                                        //     Boolean WRTRuolo = false;
                                                        
                                                        
                                                        //         for(Coverage_Team_Member__c c:existingCTM){
                                                        //             //string.valueOf(UserInfo.getUserId)
                                                        //             //Map.containskey(UserInfo.getUserId)
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
                                                        
                                                        
                                                        //     If(AccStato.get(0).INN_Stato__c == 'Customer' && currUsr.Societa__c == 'Innolva'){
                                                        //             system.debug('EU STATO' + AccStato.get(0).INN_Stato__c);
                                                        //             Innolva=true;
                                                        //     }
                                                        
                                                        //     system.debug('EU Tinexta' + Tinexta);
                                                        //     system.debug('EU Infocert' + Infocert);
                                                        //     system.debug('EU Innolva' + Innolva);
                                                        //     system.debug('EU Warrant' + Warrant);
                                                        //     system.debug('EU WRTRuolo' + WRTRuolo);
                                                        
                                                        // If((Tinexta == false && currUsr.Societa__c != 'Warrant' 
                                                        //     && currUsr.Societa__c != 'InfoCert' && currUsr.Societa__c != 'Innolva') || 
                                                        //     (InfoCert == false && currUsr.Societa__c == 'InfoCert') ||
                                                        //     (currUsr.Societa__c == 'Innolva' && Innolva == false) || 
                                                        //     (Warrant == false &&  currUsr.Societa__c == 'Warrant')
                                                        //     ){
                                                        //         system.debug('EU Nuovo CTM con Tinexta False');
                                                        //         Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
                                                        //         ctm.Account__c = Acc.id;
                                                        //         ctm.User__c = Lead_Da_Convertire.OwnerId;
                                                        //         If(WRTRuolo == true){
                                                        //             ctm.Ruolo_Coverage_Team__c = 'Agenti di vendita'; 
                                                        //         }else{
                                                        //         ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
                                                        //         }
                                                        //         insert ctm; 
                                                        // }
                                                        
                                                        return Acc;
                                                    }
    
    @AuraEnabled
    public static void handleCTM(Id accountId, Id leadId){
        Lead Lead_Da_Convertire = [SELECT Id, OwnerId FROM Lead WHERE Id =: leadId];
        
        List<Coverage_Team_Member__c> existingCTM = new List<Coverage_Team_Member__c>([SELECT Id,Societa__c,User__c,Ruolo_Coverage_Team__c, Account__c, Account__r.INN_Stato__c FROM Coverage_Team_Member__c WHERE Account__c =: accountId]);
        User currUsr = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
        // List<Account> AccStato = new List<Account> ([SELECT Id, INN_Stato__c FROM Account WHERE Id=: accountId]);
        // system.debug('EU Size Account' +AccStato.size());
        List<Account> AccStato = new List<Account>();
        system.debug('EU Società User' + currUsr.Societa__c);
        
        if(existingCTM.isEmpty()){
            system.debug('EU Nuovo Account');
            
            AccStato = [SELECT Id, INN_Stato__c FROM Account WHERE Id=: accountId];
            system.debug('EU Size Account' +AccStato.size());
            
            Coverage_Team_Member__c ctm = new Coverage_Team_Member__c();
            ctm.Account__c = accountId;
            ctm.User__c = Lead_Da_Convertire.OwnerId;
            ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
            insert ctm;
            
            if(!Test.isRunningTest())
                return;
        } else {
            Account tmpAcc = new Account(
                Id = existingCTM[0].Account__c,
                INN_Stato__c = existingCTM[0].Account__r.INN_Stato__c
            );
            
            AccStato.add(tmpAcc);
        }
        
        
        Boolean Tinexta = false;
        Boolean Infocert = false;
        Boolean Innolva = false;
        Boolean Warrant = false;
        Boolean WRTRuolo = false;
        
        
        for(Coverage_Team_Member__c c:existingCTM){
            //string.valueOf(UserInfo.getUserId)
            //Map.containskey(UserInfo.getUserId)
            system.debug('EU c.società' + c.Societa__c);
            if(c.User__c == Lead_Da_Convertire.OwnerId){
                Tinexta=true;
            }
            if(c.User__c == Lead_Da_Convertire.OwnerId && currUsr.Societa__c == 'InfoCert' ){
                system.debug('Caso Infocert non faccio niente');
                Infocert=true;
            }
            if(currUsr.Societa__c == 'InfoCert' && c.Societa__c == 'Infocert'){
                system.debug('Caso Infocert non faccio niente v2');
                Infocert=true;
            }
            if(c.User__c == Lead_Da_Convertire.OwnerId && currUsr.Societa__c == 'Innolva'){
                system.debug('Caso Innolva non faccio niente');
                Innolva=true;
            }
            
            if(c.Ruolo_Coverage_Team__c == 'Responsabile Account' && c.Societa__c == 'Warrant' &&  currUsr.Societa__c == 'Warrant'){
                system.debug('Caso Warrant cambio ruolo');
                WRTRuolo=true;
            }
            if(c.User__c == Lead_Da_Convertire.OwnerId && currUsr.Societa__c == 'Warrant'){
                Warrant=true;
            }
        }
        
        
        If(AccStato.get(0).INN_Stato__c == 'Customer' && currUsr.Societa__c == 'Innolva'){
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
              ctm.Account__c = accountId;
              ctm.User__c = Lead_Da_Convertire.OwnerId;
              If(WRTRuolo == true){
                  ctm.Ruolo_Coverage_Team__c = 'Agenti di vendita'; 
              }else{
                  ctm.Ruolo_Coverage_Team__c = 'Responsabile account';
              }
              insert ctm; 
          }        
        return;
    }    
    /*
public static void executeCall(){
HttpRequest req = new HttpRequest();
req.setEndpoint('http://collaudo-ws.ribes.it/wsrbs/services/BInformationV4.BInformationV4HttpSoap11Endpoint/');
req.setMethod('POST');
req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
req.setTimeout(120000);
Dom.Document doc = new Dom.Document();
doc.load('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/>'+
'<soapenv:Body>'+
'<bin:getListaAziende>'+
'<bin:codiceProdotto>BICLISAZR</bin:codiceProdotto>'+
'<bin:Tipo>PRD</bin:Tipo>'+
'<bin:formato>FLD</bin:formato>'+
'</bin:getListaAziende>' +
'</soapenv:Body></soapenv:Envelope>');
//doc.load('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4"><soapenv:Header/><soapenv:Body><bin:getProdottoPG><bin:accountName>TINEXTA-WS</bin:accountName><bin:accountPassword>pwdcollaudo</bin:accountPassword><bin:userID>TINEXTA-WS</bin:userID><bin:codiceProdotto>BIWKR</bin:codiceProdotto><bin:tipo>PRD</bin:tipo><bin:formato>XML</bin:formato><bin:tipoRichiesta>RP</bin:tipoRichiesta><bin:codiceFiscale>11142780151</bin:codiceFiscale><bin:tipoMonitoraggio></bin:tipoMonitoraggio><bin:tipoRinnovo></bin:tipoRinnovo><bin:codiceAnagraficaCliente/><bin:idBicLista/><bin:riferimento/><bin:elencoInfo><info nome="?"/></bin:elencoInfo></bin:getProdottoPG></soapenv:Body></soapenv:Envelope>');
req.setBodyDocument(doc);
Http http = new Http();
HTTPResponse res = http.send(req);
Dom.Document responseDoc = res.getBodyDocument();
System.debug('Request: ' + doc);
System.debug('Response: ' + res);
System.debug('Response body: ' + res.getBody());
System.debug('Response body: ' + responseDoc);
}
*/
}