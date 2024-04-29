public class WGC_Profilo_Card_Controller {
    @AuraEnabled
    public static WrapperResponse getElementAccount(String accountId){
        System.debug('SV accountId: ' + accountId);

        WrapperResponse responseFinal = new WrapperResponse();

        try{
        
            Result result = new Result();
            NumberOf numberOfElement = new NumberOf();
            List<ContactIfis> contList = new List<ContactIfis>();

            List<WGC_Soggetti_Collegati__c> soggetti_collegati = [ SELECT Id, Anagrafica__c, Anagrafica_Collegata__c, RecordType.DeveloperName, Relazione_cancellata__c 
                                                                   FROM WGC_Soggetti_Collegati__c 
                                                                   WHERE Anagrafica__c =: accountId OR 
                                                                         Anagrafica_Collegata__c =: accountId ];

            Account acc = [ SELECT Id, Name, Phone, Ateco__c, Description, CodiceIstituto3N__c, NDGGruppoGiuridico__c,
                                   WGC_Specialista_Crediti_Erariali__r.Name, WGC_Specialista_Crediti_Erariali__r.Phone,  
                                   WGC_Specialista_Factoring__r.Name, WGC_Specialista_Factoring__r.Phone, WGC_Factoring_Attivo__c, 
                                   WGC_Specialista_IFIS_International__r.Name, WGC_Specialista_IFIS_International__r.Phone,
                                   WGC_Specialista_Filo_Diretto__r.Name, WGC_Specialista_Filo_Diretto__r.Phone, WGC_Filo_Diretto_Attivo__c,
                                   WGC_Specialista_Finanza_Strutturata__r.Name, WGC_Specialista_Finanza_Strutturata__r.Phone, 
                                   WGC_Specialista_IFIS_Finance__r.Name, WGC_Specialista_IFIS_Finance__r.Phone, 
                                   WGC_Specialista_Leasing__r.Name, WGC_Specialista_Leasing__r.Phone, 
								   WGC_Specialista_Pharma__r.Name, WGC_Specialista_Pharma__r.Phone,
                                   BillingPostalCode, BillingCity, BillingState, NaturaGiuridica__c, Fatturato__c, Filiale__c
                            FROM Account
                            WHERE Id =: accountId];

            System.debug(acc);

            for(WGC_Soggetti_Collegati__c sc : soggetti_collegati){
                    switch on sc.RecordType.DeveloperName {
                        when 'Fornitore_Cliente' {
                            if(sc.Anagrafica__c == accountId) {
                                numberOfElement.fornitori ++;
                            } else if(sc.Anagrafica_Collegata__c == accountId) {
                                numberOfElement.clienti ++;
                            }
                        }
                        // when 'Referral' {
                        //     if(sc.Anagrafica__c == accountId) {
                        //         numberOfElement.referralEffettuati ++;
                        //     } else if(sc.Anagrafica_Collegata__c == accountId) {
                        //         numberOfElement.referralRicevuti ++;
                        //     }
                        // }
                    }
            }

            numberOfElement.gruppo = [ SELECT COUNT() FROM Account WHERE NDGGruppoGiuridico__c =: acc.NDGGruppoGiuridico__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND NDGGruppoGiuridico__c != '' AND Id !=: accountId ];
            //numberOfElement.competitor = [ SELECT COUNT() FROM Account WHERE Ateco__c =: acc.Ateco__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND Ateco__c != '' AND Id !=: accountId  ];
			//adione - CR ID82 - fasce di Fatturato per report Competitor
			Integer midFatt=10000; //10 milioni in migliaia
			Integer maxFatt=50000; //50 milioni in migliaia
			Integer min,max=0;
			if (acc.Fatturato__c >= maxFatt) {
				min=midFatt;
				max=maxFatt;
			} else if (acc.Fatturato__c >= midFatt) {
				min=midFatt;
				max=maxFatt;
			} else {
				min=0;
				max=midFatt;
			}			
			//A.M. CR334 -> Start
			//numberOfElement.competitor = [ SELECT COUNT() FROM Account WHERE Ateco__c =: acc.Ateco__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND Ateco__c != '' AND Id !=: accountId AND Filiale__c =: acc.Filiale__c AND Fatturato__c >= :min AND Fatturato__c <= :max];
            numberOfElement.competitor = [ SELECT COUNT() FROM Account WHERE Ateco__c =: acc.Ateco__c AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND Ateco__c != '' AND Id !=: accountId AND BillingState =: acc.BillingState AND Fatturato__c >= :min AND Fatturato__c <= :max];
            //A.M. CR334 -> End
            numberOfElement.geografia = [ SELECT COUNT() FROM Account WHERE BillingPostalCode =: acc.BillingPostalCode AND RecordType.DeveloperName != 'WGC_Tribunale' AND CodiceIstituto3N__c =: acc.CodiceIstituto3N__c AND BillingPostalCode != '' AND Id !=: accountId ];
            List<AggregateResult> tribList = new  List<AggregateResult>();
            tribList = [ SELECT Assuntore__c FROM Opportunity WHERE Assuntore__c != '' AND RecordType.DeveloperName = 'IFISOpportunitaFastFinance' AND AccountId =: accountId GROUP BY  Assuntore__c ];

            numberOfElement.tribunali = tribList.size();
            
            numberOfElement.referralEffettuati = [ SELECT COUNT() FROM WGC_Soggetti_Collegati__c WHERE RecordType.DeveloperName = 'Referral' AND Anagrafica__c =: accountId ];
            numberOfElement.referralRicevuti = [ SELECT Id, Name, Anagrafica__r.Name FROM WGC_Soggetti_Collegati__c WHERE RecordType.DeveloperName = 'Referral' AND Anagrafica_Collegata__c =: accountId ].size();

            
			if(acc.WGC_Factoring_Attivo__c){
                ContactIfis cont1 = new ContactIfis();
                cont1.name = acc.WGC_Specialista_Factoring__r.Name;
                cont1.phone = acc.WGC_Specialista_Factoring__r.Phone;
                cont1.role = 'Referente Commerciale CC';
                contList.add(cont1);
            }

			if(acc.WGC_Specialista_Crediti_Erariali__c != null){
                ContactIfis cont2 = new ContactIfis();
                cont2.name = acc.WGC_Specialista_Crediti_Erariali__r.Name;
                cont2.phone = acc.WGC_Specialista_Crediti_Erariali__r.Phone;
                cont2.role = 'Referente Commerciale FF';
                contList.add(cont2);
            }
			
			if(acc.WGC_Filo_Diretto_Attivo__c){
                ContactIfis cont3 = new ContactIfis();
                cont3.name = acc.WGC_Specialista_Filo_Diretto__r.Name;
                cont3.phone = acc.WGC_Specialista_Filo_Diretto__r.Phone;
                cont3.role = 'Filo Diretto';
                contList.add(cont3);
            }

			if(acc.WGC_Specialista_Leasing__c != null){
                ContactIfis cont4 = new ContactIfis();
                cont4.name = acc.WGC_Specialista_Leasing__r.Name;
                cont4.phone = acc.WGC_Specialista_Leasing__r.Phone;
                cont4.role = 'Referente	Leasing';
                contList.add(cont4);
            }		

			if(acc.WGC_Specialista_Pharma__c != null){
                ContactIfis cont5 = new ContactIfis();
                cont5.name = acc.WGC_Specialista_Pharma__r.Name;
                cont5.phone = acc.WGC_Specialista_Pharma__r.Phone;
                cont5.role = 'Referente	Pharma';
                contList.add(cont5);
            }
					
			if(acc.WGC_Specialista_IFIS_International__c != null){
                ContactIfis cont6 = new ContactIfis();
                cont6.name = acc.WGC_Specialista_IFIS_International__r.Name;
                cont6.phone = acc.WGC_Specialista_IFIS_International__r.Phone;
                cont6.role = 'Referente International';
                contList.add(cont6);
            }
		

            result.soggettiCollegati = numberOfElement;
            result.teamIFIS = contList;
            result.id = acc.Id;
            result.name = acc.Name;
            result.ateco = acc.Ateco__c;
			result.naturaGiuridica = acc.NaturaGiuridica__c;

			for (Schema.PicklistEntry f : Account.NaturaGiuridica__c.getDescribe().getPicklistValues()) {
				if (f.getValue().equals(acc.NaturaGiuridica__c))	{	
					result.naturaGiuridicaDescrizione = f.getLabel();
				}
			}

            
            if(!(acc.Ateco__c == '' || acc.Ateco__c == null)){
                List<Ateco__c> ateco = new List<Ateco__c>();
                ateco = [ SELECT Id, Cedacri__c, Descrizione__c FROM Ateco__c WHERE Cedacri__c =: acc.Ateco__c ];
                if (ateco.size() > 0){
                     result.descrizioneAteco = ateco[0].Descrizione__c;
                } else {
                     result.descrizioneAteco = '';
                }
            }
            // result.descrizioneAteco = [ SELECT Id, Cedacri__c, Descrizione__c FROM Ateco__c WHERE Cedacri__c =: acc.Ateco__c LIMIT 1].Descrizione__c;
            result.centralino = acc.Phone;
            result.postalCode = acc.BillingPostalCode;
            result.state = acc.BillingState;
            result.city = acc.BillingCity;
            result.phone = acc.Phone;
            responseFinal.data.add(result);
                
                
        } catch (Exception e){
            System.debug('SV exception message: ' + e.getMessage());
            responseFinal.success = false;
            responseFinal.msg = e.getMessage();
            //throw new AuraHandledException(e.getMessage());
            System.debug('SV responseFinal: ' + responseFinal);
            return responseFinal;
        }

        return responseFinal;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

    public class Result {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String ateco;
        @AuraEnabled public String descrizioneAteco;
        @AuraEnabled public String centralino;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String state;
        @AuraEnabled public String city;
        @AuraEnabled public String phone;
        @AuraEnabled public NumberOf soggettiCollegati;
        @AuraEnabled public List<ContactIfis> teamIFIS;
		@AuraEnabled public String naturaGiuridica;
		@AuraEnabled public String naturaGiuridicaDescrizione;
    }

    public class NumberOf {
        
        @AuraEnabled public Integer fornitori;
        @AuraEnabled public Integer clienti;
        @AuraEnabled public Integer competitor;
        @AuraEnabled public Integer fci;
        @AuraEnabled public Integer tribunali;
        @AuraEnabled public Integer partner;
        @AuraEnabled public Integer gruppo;
        @AuraEnabled public Integer geografia;
        @AuraEnabled public Integer referralEffettuati;
        @AuraEnabled public Integer referralRicevuti;
        @AuraEnabled public Integer altro;
        
        public NumberOf(){
            fornitori  = 0;
            clienti    = 0;
            competitor = 0;
            fci        = 0;
            tribunali  = 0;
            partner    = 0;
            gruppo     = 0;
            geografia  = 0;
            altro      = 0;
            
        }
    }

    public class ContactIfis {
    
        @AuraEnabled public String name;
        @AuraEnabled public String phone;
        @AuraEnabled public String role;

        public ContactIfis(){
            name  = '';
            phone    = '';
            role = '';            
        }
    }

}