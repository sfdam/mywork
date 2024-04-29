public class WGC_ReteCommerciale_FD_DetailController {

    @AuraEnabled
    public static WrapperResponse getFiliali(){
        WrapperResponse response = new WrapperResponse();

        try{
            Set<Filiale> filialiSet = new Set<Filiale>();
            Set<String> uIds = new Set<String>();
            List<User> utentiF = new List<User>();
            List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>();
            Map<String, List<Sobject>> dtXFiliale = new Map<String,List<Sobject>>();

            dtList = [SELECT Id, Name, Settorista__c, Ragione_Sociale__r.WGC_Specialista_Factoring__c, Data_Visita_Commerciale__c, Esito_Visita_Livello1__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, Ragione_Sociale__c, toLabel(Ragione_Sociale__r.Filiale__c), Filiale__c, toLabel(Filiale_Settorista__c), Nome_Settorista__c FROM WGC_Dettaglio_Visite__c WHERE Filiale_Settorista__c != null AND Filiale_Settorista__c != 'TIANTICIPO' AND Data_Visita_Commerciale__c != null AND Data_Visita_Commerciale__c = THIS_YEAR AND RecordType.DeveloperName = 'Dettaglio_Visita' ORDER BY LastModifiedDate DESC];

            System.debug('@@@ dtList ' + JSON.serialize(dtList));

            for(WGC_Dettaglio_Visite__c dt : dtList){
                uIds.add(dt.Nome_Settorista__c);
            }

            utentiF = [SELECT Id, Name, toLabel(Filiale__c) FROM User WHERE Name IN: uIds AND Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali'];

            dtXFiliale = U.groupBy(dtList, 'Filiale_Settorista__c');

            System.debug('@@@ dtXFiliale ' + JSON.serialize(dtXFiliale));

            Decimal countVCTot = 0;
            Decimal conversionTot = 0;
            Decimal praticheAvviateTot = 0;

            for(String key : dtXFiliale.keySet()){
                Decimal countVC = 0;
                Decimal conversion = 0;
                Decimal praticheAvviate = 0;

                for(Sobject sobj : dtXFiliale.get(key)){
                    if(sobj.get('Data_Visita_Commerciale__c') != null){ 
                        countVC ++;
                        countVCTot ++;
                    }

                    if(sobj.get('Rapporto_Avviato__c') == 'SI'){ 
                        praticheAvviate ++;
                        praticheAvviateTot ++;
                    }
                }

                Filiale f;

                if(countVC > 0) {
                    f = new Filiale(key, ((praticheAvviate / countVC) * 100).setScale(2));
                } else {
                    f = new Filiale(key, 0);
                }

                filialiSet.add(f);
            }

            Filiale tutteLeFiliali;

            if(countVCTot > 0) {
                tutteLeFiliali = new Filiale('Tutte Le Filiali', ((praticheAvviateTot / countVCTot) * 100).setScale(2));
            } else {
                tutteLeFiliali = new Filiale('Tutte Le Filiali', 0);
            }

            List<Filiale> filiali = new List<Filiale>(filialiSet);

            filiali.sort();

            filiali.add(tutteLeFiliali);

            response.data.add(filiali);

        } catch (exception e){
            System.debug('@@@ eccezione ' + e.getMessage() + ' -- ' + e.getLineNumber());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getDatiTabella(String nomeFiliale){
        WrapperResponse response = new WrapperResponse();

        try{
            if(nomeFiliale != 'Tutte Le Filiali'){
                List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>();
                Set<String> uIds = new Set<String>();
                List<User> uList = new List<User>();
                Map<String,List<Sobject>> dtXFiliale = new Map<String,List<Sobject>>();

                dtList = [SELECT Id, Name, Settorista__c, Data_Visita_Commerciale__c, Esito_Visita_Livello1__c, Esito_Visita__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, toLabel(Ragione_Sociale__r.Filiale__c), Filiale__c, Macro_Esito__c, Nome_Settorista__c, toLabel(Filiale_Settorista__c) FROM WGC_Dettaglio_Visite__c WHERE toLabel(Filiale_Settorista__c) =: nomeFiliale AND Data_Visita_Commerciale__c != null AND Data_Visita_Commerciale__c = THIS_YEAR AND RecordType.DeveloperName = 'Dettaglio_Visita' ];

                for(WGC_Dettaglio_Visite__c dt : dtList){
                    uIds.add(dt.Nome_Settorista__c);
                }

                dtXFiliale = U.groupBy(dtList, 'Filiale_Settorista__c');

                System.debug('@@@ dtXFiliale ' + JSON.serialize(dtXFiliale));

                System.debug('@@@ uIds ' + JSON.serialize(uIds));

                uList = [SELECT Id, Name, toLabel(Filiale__c), WGC_Team_Filo_Diretto__c FROM User WHERE Name IN: uIds];

                System.debug('@@@ uList ' + JSON.serialize(uList));
                
                List<TableWrapper> twList = new List<TableWrapper>();

                // TableWrapper tutteLeFiliali = new TableWrapper();

                for(User u : uList){
                    Decimal countVC = 0;
                    Decimal rsfFirmata = 0;
                    Decimal pratichePresentate = 0;
                    Decimal praticheApprovate = 0;
                    Decimal praticheAvviate = 0;
                    
                    for(String key : dtXFiliale.keySet()){
                        for(Sobject sobj : dtXFiliale.get(key)){
                            if(sobj.get('Nome_Settorista__c') != null && sobj.get('Nome_Settorista__c') == u.Name){
                                if(sobj.get('Data_Visita_Commerciale__c') != null) countVC ++;
                                
                                if(sobj.get('Macro_Esito__c') != null && String.valueOf(sobj.get('Macro_Esito__c')) == 'Positivo') rsfFirmata ++;

                                if(sobj.get('Pratica_Presentata__c') != null && String.valueOf(sobj.get('Pratica_Presentata__c')) == 'SI') pratichePresentate ++;

                                if(sobj.get('Esito_Pratica__c') != null && String.valueOf(sobj.get('Esito_Pratica__c')) == 'Approvata') praticheApprovate ++;

                                if(sobj.get('Rapporto_Avviato__c') != null && String.valueOf(sobj.get('Rapporto_Avviato__c')) == 'SI') praticheAvviate ++;
                            }
                        }
                    }
                    //Genero un wrapper per ogni settorista che corrisponde ad una riga della tabella
                    TableWrapper tw;
                    if(countVC > 0){
                        tw = new TableWrapper(u.Name, 'test', countVC, rsfFirmata, pratichePresentate, 
                                              praticheApprovate, praticheAvviate, (rsfFirmata / countVC).setScale(2) , 
                                              (pratichePresentate / countVC).setScale(2), (praticheApprovate / countVC).setScale(2), 
                                              (praticheAvviate / countVC).setScale(2));
                    } else {
                        tw = new TableWrapper(u.Name, 'test', countVC, rsfFirmata, pratichePresentate, 
                                              praticheApprovate, praticheAvviate, 0, 0, 0, 0);
                    }
                    
                    System.debug('@@@ tw ' + JSON.serialize(tw));       
                    twList.add(tw);
                }

                // System.debug('@@@ twList ' + JSON.serialize(twList));

                response.data.add(twList);
            } else {
                List<TableWrapper> datiTabella = WGC_ReteCommerciale_FD_DetailController.getDatiTabellaTutteLeFiliali();

                response.data.add(datiTabella);
            }

        } catch(exception e){
            System.debug('@@@ eccezione ' + e.getMessage() + ' -- ' + e.getLineNumber());
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static List<TableWrapper> getDatiTabellaTutteLeFiliali(){
        List<TableWrapper> datiTabella = new List<TableWrapper>();

        try{
            // List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>();
            Set<String> uIds = new Set<String>();
            // List<User> uList = new List<User>();

            List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Settorista__c, Settorista__r.Name, Data_Visita_Commerciale__c, Esito_Visita_Livello1__c, Esito_Visita__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, toLabel(Ragione_Sociale__r.Filiale__c), Macro_Esito__c, Filiale__c, Nome_Settorista__c, toLabel(Filiale_Settorista__c) FROM WGC_Dettaglio_Visite__c WHERE Nome_Settorista__c != null AND Filiale_Settorista__c != null AND Data_Visita_Commerciale__c != null AND Data_Visita_Commerciale__c = THIS_YEAR AND RecordType.DeveloperName = 'Dettaglio_Visita' ]);
			
            
            for(WGC_Dettaglio_Visite__c dt : dtList){
                uIds.add(dt.Nome_Settorista__c);
            }
			

            List<User> uList = new List<User>([SELECT Id, Name, toLabel(Filiale__c), WGC_Team_Filo_Diretto__c FROM User WHERE Name IN: uIds]);
			
            uIds = null;
            System.debug('@@@ limit ' + Limits.getHeapSize());
            for(User u : uList){
                Decimal countVC = 0;
                Decimal rsfFirmata = 0;
                Decimal pratichePresentate = 0;
                Decimal praticheApprovate = 0;
                Decimal praticheAvviate = 0;
                for(WGC_Dettaglio_Visite__c dt : dtList){
                    

                    if(dt.Nome_Settorista__c != null && dt.Nome_Settorista__c == u.Name){
                        if(dt.Data_Visita_Commerciale__c != null) countVC ++;
                        
                        if(dt.Macro_Esito__c != null && dt.Macro_Esito__c == 'Positivo') rsfFirmata ++;

                        if(dt.Pratica_Presentata__c != null && dt.Pratica_Presentata__c == 'SI') pratichePresentate ++;

                        if(dt.Esito_Pratica__c != null && dt.Esito_Pratica__c == 'Approvata') praticheApprovate ++;

                        if(dt.Rapporto_Avviato__c != null && dt.Rapporto_Avviato__c == 'SI') praticheAvviate ++;
                    }
                }
                
                TableWrapper tw;
                if(countVC > 0){
                    tw = new TableWrapper(u.Name, '', countVC, rsfFirmata, pratichePresentate, 
                                          praticheApprovate, praticheAvviate, (rsfFirmata / countVC).setScale(2) , 
                                          (pratichePresentate / countVC).setScale(2), (praticheApprovate / countVC).setScale(2), 
                                          (praticheAvviate / countVC).setScale(2));
                } else {
                    tw = new TableWrapper(u.Name, '', countVC, rsfFirmata, pratichePresentate, 
                                          praticheApprovate, praticheAvviate, 0, 0, 0, 0);
                }
                
                // System.debug('@@@ tw ' + JSON.serialize(tw));    
                datiTabella.add(tw);
            }

            System.debug('@@@ limit 2 ' + Limits.getHeapSize());

            dtList = null;
            uIds = null;
            uList = null;

            Map<String, TableWrapper> mappaTable = new Map<String, TableWrapper>();

            for(TableWrapper tw2 : datiTabella){
            	if(mappaTable.containskey(tw2.settorista)){
                	TableWrapper twToUpdate = mappaTable.get(tw2.settorista);
                    twToUpdate.vc += tw2.vc;                            
                    twToUpdate.rsf += tw2.rsf;
                    twToUpdate.presentata += tw2.presentata;
                    twToUpdate.approvata += tw2.approvata;
                    twToUpdate.avviata += tw2.avviata;
                    twToUpdate.rsf_perc = twToUpdate.vc > 0 ? (twToUpdate.rsf / twToUpdate.vc).setScale(2) : 0;
                    twToUpdate.presentata_perc = twToUpdate.vc > 0 ? (twToUpdate.presentata / twToUpdate.vc).setScale(2) : 0;
                    twToUpdate.approvata_perc = twToUpdate.vc > 0 ? (twToUpdate.approvata / twToUpdate.vc).setScale(2) : 0;
                    twToUpdate.avviata_perc = twToUpdate.vc > 0 ? (twToUpdate.avviata / twToUpdate.vc).setScale(2) : 0;
                    mappaTable.put(tw2.settorista, twToUpdate);
                } else {
                    mappaTable.put(tw2.settorista, tw2);
                }
           }

           datiTabella = new List<TableWrapper>(mappaTable.values());

           mappaTable = null;

        } catch (exception e){
            System.debug('@@@ exception ' + e.getMessage() + ' -- ' + e.getLineNumber());
        }

        return datiTabella;

    }

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class Filiale implements Comparable{
        @AuraEnabled public String nomeFiliale;
        @AuraEnabled public Decimal conversion;
        @AuraEnabled public Boolean selected;

        public Filiale(String nome, Decimal conversion){
            this.nomeFiliale = nome;
            this.conversion = conversion;
            this.selected = false;
        }

        public Integer compareTo(Object compareTo) {
            Filiale compareToFil = (Filiale)compareTo;
            if (conversion == compareToFil.conversion) return 0;
            if (conversion > compareToFil.conversion) return -1;
            return 1;
        }
    }

    public class TableWrapper{
        @AuraEnabled public String settorista;
        @AuraEnabled public String consulentefd;
        @AuraEnabled public Decimal vc;
        @AuraEnabled public Decimal rsf;
        @AuraEnabled public Decimal presentata;
        @AuraEnabled public Decimal approvata;
        @AuraEnabled public Decimal avviata;
        @AuraEnabled public Decimal rsf_perc;
        @AuraEnabled public Decimal presentata_perc;
        @AuraEnabled public Decimal approvata_perc;
        @AuraEnabled public Decimal avviata_perc;

        public TableWrapper(){
            this.settorista = settorista;
            this.consulentefd = consulentefd;
            this.vc = vc;
            this.rsf = rsf;
            this.presentata = presentata;
            this.approvata = approvata;
            this.avviata = avviata;
            this.rsf_perc = rsf_perc;
            this.presentata_perc = presentata_perc;
            this.approvata_perc = approvata_perc;
            this.avviata_perc = avviata_perc;
        }

        public TableWrapper(String settorista, String consulente, 
                            Decimal vc, Decimal rsf, Decimal presentata, 
                            Decimal approvata, Decimal avviata, Decimal rsf_perc, 
                            Decimal presentata_perc, Decimal approvata_perc, Decimal avviata_perc){
            
            this.settorista = settorista;
            this.consulentefd = consulente;
            this.vc = vc;
            this.rsf = rsf;
            this.presentata = presentata;
            this.approvata = approvata;
            this.avviata = avviata;
            this.rsf_perc = rsf_perc;
            this.presentata_perc = presentata_perc;
            this.approvata_perc = approvata_perc;
            this.avviata_perc = avviata_perc;
        }                    
    }
}