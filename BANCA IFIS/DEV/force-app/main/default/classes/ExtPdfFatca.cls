/**
* Created by ccardinale on 08/05/2017.
*/

public with sharing class ExtPdfFatca {
    private Opportunity o;
    public Account a { public get; set; }
    public NDGLinea__c[] linee { public get; set; }
    public Integer checkBoxSelected { public get; set; }
    public Integer checkBoxSelected2 { public get; set; }
    public List<String> fieldsA { public get; set; }
    public List<String> fieldsB { public get; set; }
    public List<String> fieldsC { public get; set; }
    public List<String> fieldsLineaA { public get; set; }
    public List<String> fieldsLineaB { public get; set; }
    public List<String> fieldsLineaC { public get; set; }
    public List<Integer> lineaSelected { public get; set; }
    
    public ExtPdfFatca(ApexPages.StandardController stdController) {
        this.o = (Opportunity) stdController.getRecord();
        lineaSelected = new List<Integer> ();
        this.o = [SELECT Id, AccountId FROM Opportunity WHERE Id = :this.o.Id];
        a = [SELECT
             Id,
             Name,
             PIVA__c,
             Phone,
             Fax,
             Email__c,
             EmailPEC__c,
             BillingStreet,
             BillingStreetName__c,
             BillingStreetNumber__c,
             BillingStreetType__c,
             BillingCity,
             BillingState,
             BillingCountry,
             BillingPostalCode,
             ShippingStreet,
             ShippingStreetName__c,
             ShippingStreetType__c,
             ShippingStreetNumber__c,
             ShippingCity,
             ShippingState,
             ShippingCountry,
             ShippingPostalCode,
             RegimeTrasparenzaFiscale__c,
             USPerson__c,
             SpecifiedUSPerson__c,
             FiscalmenteResidenteSoloStatiUniti__c,
             IstituzioneFinanziaria__c,
             ValoriFiscalmenteResidenteSoloUSA__c,
             ValoriActiveNFFEActiveNFE__c,
             AltroFiscalmenteResidenteSoloUSA__c,
             CostituzioneStreetName__c,
             CostituzioneStreetType__c,
             CostituzioneStreetNumber__c,
             CostituzioneCity__c,
             CostituzionePostalCode__c,
             CostituzioneState__c,
             CostituzioneCountry__c,
             ResidenzaFiscale1__c,
             ResidenzaFiscale2__c,
             ResidenzaFiscale3__c,
             ResidenzaFiscale4__c,
             CodiceFiscaleResidenzaFiscale1__c,
             CodiceFiscaleResidenzaFiscale2__c,
             CodiceFiscaleResidenzaFiscale3__c,
             CodiceFiscaleResidenzaFiscale4__c
             FROM Account
             WHERE Id = :o.AccountId
            ];
        linee = [SELECT
                 Id,
                 Contact__c,
                 Trust__c,
                 ValoriTrust__c,
                 TipoTrust__c,
                 ReferenteFatca__c,
                 ResidenzaFiscale1__c,
                 ResidenzaFiscale2__c,
                 ResidenzaFiscale3__c,
                 ResidenzaFiscale4__c,
                 CodiceFiscaleResidenzaFiscale1__c,
                 CodiceFiscaleResidenzaFiscale2__c,
                 CodiceFiscaleResidenzaFiscale3__c,
                 CodiceFiscaleResidenzaFiscale4__c,
                 Contact__r.FirstName,
                 Contact__r.LastName,
                 Contact__r.Name,
                 Contact__r.CF__c,
                 Contact__r.LuogoNascita__c,
                 Contact__r.MailingStreet,
                 Contact__r.MailingStreetType__c,
                 Contact__r.MailingStreetNumber__c,
                 Contact__r.MailingStreetName__c,
                 Contact__r.MailingCity,
                 Contact__r.MailingState,
                 Contact__r.MailingCountry,
                 Contact__r.MailingPostalCode,
                 Contact__r.Sesso__c,
                 Contact__r.CodCatastaleLocNascita__c,
                 Contact__r.Birthdate,
                 Contact__r.TipoDocumentoIdentita__c,
                 Contact__r.NumeroDoc__c,
                 Contact__r.EnteEmitettenteDocumento__c,
                 Contact__r.DataEmissioneDoc__c
                 FROM NDGLinea__c
                 WHERE Opportunita__c = :this.o.Id
                 AND ReferenteFatca__c = true
                ];
        if (a.BillingCountry == null || a.BillingCountry == '')
            a.BillingCountry = 'ITALIA'; // TODO INTERNATIONAL: togliere mock
        setCheckboxSelected();
        setFieldsLinea();
    }
    
    private void setFieldsLinea() {
        fieldsLineaA = new List<String> {
            'Proprietario (diretto o indiretto)',
            'Controllante con altri mezzi',
            'Funzionario alta direzione'
		};
		fieldsLineaB = new List<String> {
			'Disponente',
            'Fiduciario',
            'Protettore',
            'Beneficiario',
            'Altro'
		};
		fieldsLineaC = new List<String> {
			'Disponente equivalente',
            'Fiduciario equivalente',
            'Protettore equivalente',
            'Beneficiario equivalente',
            'Altro'
		};
        
		Integer i;
        for (i = 0; i<linee.size(); i++) {
            //è un dispositivo giuridico diverso da un trust
            if (this.linee[i].Trust__c == 'è una persona giuridica diversa da un trust') {
                this.lineaSelected.add(indexOf(fieldsLineaA, this.linee[i].ValoriTrust__c));
                continue;
            } else if (this.linee[i].Trust__c == 'è un trust') {
                this.lineaSelected.add(indexOf(fieldsLineaB, this.linee[i].ValoriTrust__c) + fieldsLineaA.size());
                continue;
            } else if (this.linee[i].Trust__c == 'è un dispositivo giuridico diverso da un trust') {
                this.lineaSelected.add(indexOf(fieldsLineaC, this.linee[i].ValoriTrust__c) + fieldsLineaA.size() + fieldsLineaB.size());
                continue;
            } else {
                this.lineaSelected.add(- 1);
                continue;
            }
        }
    }
    
    private void setCheckboxSelected() {
        fieldsA = new List<String> {
            'Istituzione finanziaria Italiana (IFI) o di altra giurisdizione partecipante (PJFI)',
            'Istituzione finanziaria estera partecipante (PFFI)',
            'Istituzione finanziaria italiana/ estera registrata considerata adempiente (RDCFFI)',
            'Istituzione finanziaria italiana/ estera certificata considerata adempiente (CDCFFI)',
            'Istituzione Finanziaria non partecipante (NPFI)',
            'Entità di investimento residente in giurisdizione non partecipante',
            'Beneficiario Effettivo Esente (EBO)',
            'Altro'
		};
		fieldsB = new List<String> {
			'Active NFFE/ Active NFE',
            'Passive NFFE/ Passive NFE',
            'Beneficiario Effettivo Esente (EBO)',
            'Altro soggetto non sottoposto a segnalazione FATCA'
		};
        fieldsC = new List<String> {
			'Società di capitali quotata o di Gruppo Quotato',
            'Società con reddito lordo, relativo all’esercizio precedente, derivante in prevalenza (maggiore del 50%) dalla gestione non finanziaria (Active Trade or Business)',
             'Entità statale, organizzazione internazionale o banca centrale o interamente controllata da uno o più di tali soggetti',
             'Ente no profit',
             'Altro'
		};
                                            
		if (this.a.FiscalmenteResidenteSoloStatiUniti__c == 'Si') {
            this.checkBoxSelected = - 1;
            this.checkBoxSelected2 = - 1;
			return;
		}
        if (this.a.IstituzioneFinanziaria__c == 'Si') {
            this.checkBoxSelected = indexOf(fieldsA, this.a.ValoriFiscalmenteResidenteSoloUSA__c);
            return;
        } else {
            this.checkBoxSelected = indexOf(fieldsB, this.a.ValoriFiscalmenteResidenteSoloUSA__c) + fieldsA.size();
            this.checkBoxSelected2 = indexOf(fieldsC, this.a.ValoriActiveNFFEActiveNFE__c);
            return;
        }
    }
    
    public Integer indexOf(List<String> myList, String element) {
        Integer i;
        for (i = 0; i<myList.size(); i++)
            if (myList[i] == element)
            return i;
        return - 1;
    }
}