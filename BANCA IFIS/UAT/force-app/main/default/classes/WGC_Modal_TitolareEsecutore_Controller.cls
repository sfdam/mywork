public class WGC_Modal_TitolareEsecutore_Controller {

    public class listWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String AccountId;
        @AuraEnabled
        public String ContactId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public P WGC_Ruolo;
        @AuraEnabled
        public String titolareEffettivo;
        @AuraEnabled
        public String titolareEsecutore;
        @AuraEnabled
        public String WGC_Tipologia_Titolare_Effettivo;
        @AuraEnabled
        public P Ruolo_Pratica;
        @AuraEnabled
        public String Address;
        @AuraEnabled
        public Boolean isRelation;
        @AuraEnabled
        public String tipoCensimento;
        @AuraEnabled
        public Boolean contactFull;
        @AuraEnabled
        public Boolean accountFull;
		@AuraEnabled
        public String comportamentoCliente;
        @AuraEnabled
        public String relazioneClienteEsecutore;
    }

    public class P{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public P(){
            this.label = label;
            this.value = value;
        }
    }

    //Aggiungere lista di contatti già aggiunti alla tabella accountcontactrelation
    @AuraEnabled
    public static List<listWrapper> getReferenti(String accountId){
        List<AccountContactRelation> listaReferentiAcc = new List<AccountContactRelation>();
        List<listWrapper> lstWrapper = new List<listWrapper>();
        //Recupero i referenti associati ad account già esistenti
        //FACTORY SV -- Aggiunto campo WGC_Relazioni_Tra_Cliente_ed_Esecutore__c in query
        listaReferentiAcc = [SELECT Id, AccountId, ContactId, isActive, WGC_Selezionato__c, Contact.WGC_Censimento_MAV__c, 
        Contact.Name, Contact.FirstName, Contact.LastName, Contact.MailingStreet, WGC_Ruolo__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c,
        WGC_Titolare_Effettivo__c, WGC_Titolare_Esecutore__c, Account.WGC_MAV_Completo__c, Contact.WGC_MAV_Completo__c, WGC_Tipologia_Esecutore__c, Comportamento_cliente__c, WGC_Relazioni_Tra_Cliente_ed_Esecutore__c
        FROM AccountContactRelation WHERE AccountId =: accountId AND Contact.IsReferenteCampagna__c = false AND WGC_Ruolo__c != null];

        List<P> listP = new List<P>();

        System.debug('@@@ getReferenti ' + JSON.serialize(listaReferentiAcc));

        for(AccountContactRelation item : listaReferentiAcc){
            System.debug('@@@ getReferenti ' + JSON.serialize(item));
            if(item.WGC_Titolare_Effettivo__c || item.WGC_Tipologia_Esecutore__c != null){
                listWrapper lw = new listWrapper();
                lw.Id = item.Id;
                lw.AccountId = item.AccountId;
                lw.ContactId = item.ContactId;
                lw.Name = item.Contact.Name;
                lw.Address = item.Contact.MailingStreet;
                lw.titolareEffettivo = item.WGC_Titolare_Effettivo__c ? 'J' : null ;
                lw.titolareEsecutore = item.WGC_Tipologia_Esecutore__c;
                //FACTORY SV -- START
                lw.relazioneClienteEsecutore = item.WGC_Relazioni_Tra_Cliente_ed_Esecutore__c;
                //FACTORY SV -- END
                lw.WGC_Tipologia_Titolare_Effettivo = item.WGC_Tipologia_Titolare_Effettivo__c;

                lw.tipoCensimento = item.Contact.WGC_Censimento_MAV__c;
                lw.isRelation = item.WGC_Selezionato__c;
                lw.contactFull = item.Contact.WGC_MAV_Completo__c;
                lw.accountFull = item.Account.WGC_MAV_Completo__c;
                lw.WGC_Ruolo = new P();
                lw.WGC_Ruolo.value = item.WGC_Ruolo__c;
                lw.Ruolo_Pratica = new P();
                lw.Ruolo_Pratica.value = item.WGC_Ruolo_Pratica__c;
				lw.comportamentoCliente = item.Comportamento_cliente__c;
                
                //Ruolo DWH
                // P pv = new P();
                // P pRP = new P();
                // Schema.DescribeFieldResult fieldResult = AccountContactRelation.WGC_Ruolo__c.getDescribe();
                // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                // List<String> valoriRuolo = item.WGC_Ruolo__c.split(';');
                // // System.debug('@@@ valoriRuolo ' + valoriRuolo);
                // // pv.label = '';
                // // pv.value = '';
                // // for( Schema.PicklistEntry pickListVal : ple){

                // //     for(String valore : valoriRuolo){
                // //         if(picklistVal.getValue() == valore && picklistVal.isActive()){
                // //             pv.label += picklistVal.getLabel() + ' ';
                // //             pv.value += picklistVal.getValue() + ';';
                // //         }
                // //     }               
                // // }
                
                // // System.debug('@@@ pv.value confronto ' + pv.value.contains('J;Z1'));
                // // if(pv.value.contains('J;Z1')){
                // //     pv.label = 'Titolare Effettivo ed Esecutore';
                // //     pv.value = 'J;Z1';
                // // }
                // // else if(pv.value.contains('J1;Z1')){
                // //     pv.label = 'Titolare Effettivo ed Esecutore';
                // //     pv.value = 'J1;Z1';
                // // }
                // // else if(pv.value.contains('Z1')){
                // //     if(pv.value.contains(';')){
                // //         pv.value = 'Z1';
                // //     }
                // //     pv.label = 'Esecutore';
                // // }
                // // else if(pv.value.contains('J;J1') || pv.value.contains('J') || pv.value.contains('J1')) {
                // //     pv.label = 'Titolare Effettivo';
                // // }
                // // // else if(pv.value.contains('J')){ 
                // // //     pv.label = 'Titolare Effettivo';
                // // // }
                // // if(pv.value.endsWith(';')){
                // //     pv.value = pv.value.substring(0,pv.value.length()-1);
                // // }

                // if((item.WGC_Ruolo__c.contains('J')) && (item.WGC_Ruolo__c.contains('Z1'))){
                //     pv.value = 'J;Z1';
                //     pv.label = 'Titolare Effettivo ed Esecutore';
                // }
                // else if(item.WGC_Ruolo__c.contains('J1') && item.WGC_Ruolo__c.contains('Z1')){
                //     pv.value = 'J;Z1';
                //     pv.label = 'Titolare Effettivo ed Esecutore';
                // }
                // else if(item.WGC_Ruolo__c.contains('J')){
                //     pv.value = 'J';
                //     pv.label = 'Titolare Effettivo';
                // }
                // else if(item.WGC_Ruolo__c.contains('J1')){
                //     pv.value = 'J1';
                //     pv.label = 'Titolare Effettivo';
                // }
                // else if(item.WGC_Ruolo__c.contains('Z1')){
                //     pv.value = 'Z1';
                //     pv.label = 'Esecutore';
                // }

                // //Ruolo Pratica
                // Schema.DescribeFieldResult fieldResult2 = AccountContactRelation.WGC_Ruolo_Pratica__c.getDescribe();
                // List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();            
                // //IF containsAny ;
                // System.debug('@@@ item.WGC_Ruolo_Pratica__c ' + item.WGC_Ruolo_Pratica__c);
                // if(item.WGC_Ruolo_Pratica__c != null){
                //     // if(item.WGC_Ruolo_Pratica__c.containsAny(';')){
                //     //     List<String> valoriRuoloPratica = item.WGC_Ruolo_Pratica__c.split(';');
                //     //     System.debug('@@@ valoriRuoloPratica ' + valoriRuoloPratica);
                        
                //     //     pRP.label = '';
                //     //     pRP.value = '';
                //     //     for( Schema.PicklistEntry pickListVal : ple2){

                //     //         for(String valore : valoriRuoloPratica){
                //     //             if(picklistVal.getValue() == valore && picklistVal.isActive()){
                //     //                 pRP.label += picklistVal.getLabel() + ' ';
                //     //                 pRP.value += picklistVal.getValue() + ';';
                //     //             }
                //     //         }               
                //     //     }
                //     //     pRP.value = pRP.value.substring(0,pRP.value.length()-1);

                //     //     //|| pRP.value.containsAny('J;Z') || pRP.value.containsAny('J1;Z')
                //     //     if(pRP.value.contains('J;Z1')){
                //     //         pRP.label = 'Titolare Effettivo ed Esecutore';
                //     //         pRP.value = 'J;Z1';
                //     //     }
                //     //     else if(pRP.value.contains('J1;Z1')){
                //     //         pRP.label = 'Titolare Effettivo ed Esecutore';
                //     //         pRP.value = 'J1;Z1';
                //     //     }
                //     //     else if(pRP.value.contains('Z1')){
                //     //         if(pRP.value.contains(';')){
                //     //             pRP.value = 'Z1';
                //     //         }
                //     //         pRP.label = 'Esecutore';
                //     //     }
                //     //     else if(pRP.value.contains('J') || pRP.value.contains('J1') || pRP.value.contains('J;J1')){
                //     //         pRP.label = 'Titolare Effettivo';
                //     //     }
                //     //     // else if(pRP.value.contains('J')){
                //     //     //     pRP.label = 'Titolare Effettivo';
                //     //     // }
                //     // }
                //     // else{
                //     //     pRP.value = item.WGC_Ruolo_Pratica__c;
                //     //     //|| pRP.value.containsAny('J;Z') || pRP.value.containsAny('J1;Z')
                //     //     if(pRP.value.contains('J;Z1') || pRP.value.contains('J1;Z1')){
                //     //         pRP.label = 'Titolare Effettivo ed Esecutore';
                //     //     }
                //     //     else if(pRP.value.contains('Z')){
                //     //         pRP.label = 'Esecutore';
                //     //     }
                //     //     else if(pRP.value.contains('J') || pRP.value.contains('J1') || pRP.value.contains('J;J1')){
                //     //         pRP.label = 'Titolare Effettivo';
                //     //     }
                //     //     // else if(pRP.value.contains('J')){
                //     //     //     pRP.label = 'Titolare Effettivo';
                //     //     // }
                //     // }

                //     if((item.WGC_Ruolo_Pratica__c.contains('J')) && (item.WGC_Ruolo_Pratica__c.contains('Z1'))){
                //         pRP.value = 'J;Z1';
                //         pRP.label = 'Titolare Effettivo ed Esecutore';
                //     }
                //     else if(item.WGC_Ruolo_Pratica__c.contains('J1') && item.WGC_Ruolo_Pratica__c.contains('Z1')){
                //         pRP.value = 'J;Z1';
                //         pRP.label = 'Titolare Effettivo ed Esecutore';
                //     }
                //     else if(item.WGC_Ruolo_Pratica__c.contains('J')){
                //         pRP.value = 'J';
                //         pRP.label = 'Titolare Effettivo';
                //     }
                //     else if(item.WGC_Ruolo_Pratica__c.contains('J1')){
                //         pRP.value = 'J1';
                //         pRP.label = 'Titolare Effettivo';
                //     }
                //     else if(item.WGC_Ruolo_Pratica__c.contains('Z1')){
                //         pRP.value = 'Z1';
                //         pRP.label = 'Esecutore';
                //     }
                // }

                // System.debug('@@@ pv.value final ' + pv.value);
                
                // lw.WGC_Ruolo = pv;
                // System.debug('@@@ pRP ' + pRP);
                // lw.Ruolo_Pratica = pRP.label != null ? pRP : null; 

                System.debug('@@@ lw '  + JSON.serialize(lw));
                lstWrapper.add(lw);
            }
        }

        if(!lstWrapper.isEmpty()){
            return lstWrapper;
        }
        else{
            return null;
        }
    }

    @AuraEnabled
    public static Account getConsensi(String accountId){
        Account acc = [SELECT Id, Name, WGC_Mav_Completo__c, PartecipazioneSocietaFiduciarie2__c FROM Account WHERE Id =: accountId];

        return acc;

    }
}