public class OnQuoteLineTriggerHandler {
    
    public static void InsertdaListino (Map <Id,SBQQ__QuoteLine__c> input){   
        
        SBQQ.TriggerControl.disable();
        
        //Map per receupare i dati dalla maschera BAW
        Set<Id> idproduct = new Set<Id>();
        // Set<Id> idqlinevuote = new Set<Id>();
        Set<Id> idbundle = new Set<Id>();
        Set<Id> idoption = new Set<Id>();
        Set<Id> idfin = new Set <Id> ();
        Set<Id> idcon = new Set <Id> ();
        Set<Id> Pag = new Set<Id>();
        boolean bun=false;
        
        
        // se non sto usando il pulsante di rinnovo carico i prodottidata:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAPCAYAAADd/14OAAAA40lEQVQoz2P4//8/AzpWzGj6L59U/V8urgxMg/g4FUn6J/+X9E38LxWc8V8htR67IpCkuGfMfxCQjSpENRFFkXvk/1+/foGxQloDSD0DVkVfvnyBY7hCdEVv3rxBwXCFIIdKh2WDFT1+/BgDo1qd2fL/1q1bWDFcoW5xz3/Xppn/oycu/X/x4kUMDFeoWdD136R8wn+f9rlgxSdOnEDBKFajK96/fz8coyjEpnj79u1gjKEQXXFE/+L/Gzdu/G9WMfG/am4HZlzDFAf3LPwfOWEJWBPIwwzYUg9MsXXNFDAN4gMAmASShdkS4AcAAAAASUVORK5CYII=
        for (Id  ql : input.keyset()) {
            IF(input.get(ql).Escludi_da_template__c == false){  
                idproduct.add(input.get(ql).SBQQ__Product__c);
                idoption.add(input.get(ql).SBQQ__ProductOption__c);
            }
            //idqlinevuote.add(input.get(ql).Id);
        }

        system.debug(idproduct);
        system.debug(idoption);        
        
        
        //Mappa BU Warrant e Product
        Map<Id, SBQQ__ProductOption__c> Bundle = new map <Id, SBQQ__ProductOption__c>();
        Map<Id, Business_Area_Warrant__c> BUFinanziamenti = new map <Id,Business_Area_Warrant__c>();
        if(idproduct.size() > 0) BUFinanziamenti = new map <Id,Business_Area_Warrant__c> ([SELECT Id,Importo_WarrantCPQ__c,SingoloProdotto_WarrantCPQ__c, ProdottoBundle_WarrantCPQ__c,RecordTypeId, RecordType.Name FROM Business_Area_Warrant__c WHERE SingoloProdotto_WarrantCPQ__c in : idproduct]);
        if(idoption.size() > 0) Bundle = new map <Id, SBQQ__ProductOption__c> ([SELECT Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE Id IN: idoption]);
        
        // Map<Id, SBQQ__QuoteLine__c> QuoteLine = new map<Id,SBQQ__QuoteLine__c>([SELECT Id FROM SBQQ__QuoteLine__c WHERE Id IN:idqlinevuote]);
        
        //mappe vuote per AsyncCopy
        Map<Id,Business_Area_Warrant__c> toSaveFinanziamenti = new Map<Id,Business_Area_Warrant__c>();
        Map<Id,Business_Area_Warrant__c> toSaveCondizioni = new Map<Id,Business_Area_Warrant__c>();             
        Map<Id,SBQQ__QuoteLine__c> idquote = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> idquoteline = new Map<Id,SBQQ__QuoteLine__c>();  
        
        // se l'oggetto è tipo bundle lo segnalo con un flag
        If(Bundle.size()>0){
            bun=true;
        }
        
        // Stampe di controllo
        System.debug('BuFinanziamenti' + BUFinanziamenti);
        System.debug('Bundle' + Bundle + bun);
        
        
        //Mappo i finanziamenti da Creare
        
        for(Id q:input.keyset()){
            //Caso di prodotto secco
            If(bun == false){
                for (Id b : BUFinanziamenti.keyset()) {
                    //Caso per prodotto singolo: la query su bundle è vuota
                    If(BUFinanziamenti.get(b).Importo_WarrantCPQ__c != 0 && BUFinanziamenti.get(b).RecordType.Name == 'Finanziamenti'){
                        //If(BUFinanziamenti.get(b).RecordType.Name == 'Finanziamenti'){
                        toSaveFinanziamenti.put(b,BUFinanziamenti.get(b));
                        idquote.put(q,input.get(q));
                        System.debug('Dentro Finanziamenti con prodotto secco');
                    }  
                }
            }
            // Caso di prodotto bundle
            If(bun == true){
                for (Id bk : BUFinanziamenti.keyset()) {
                    for(Id p:Bundle.keyset()){
                        If(BUFinanziamenti.get(bk).ProdottoBundle_WarrantCPQ__c == Bundle.get(p).SBQQ__ConfiguredSKU__c && BUFinanziamenti.get(bk).SingoloProdotto_WarrantCPQ__c == Bundle.get(p).SBQQ__OptionalSKU__c){
                            System.debug('Dentro Finanziamenti con prodotto bundle 1 if');
                            //Caso per prodotto bundle: confronto il master
                            If(BUFinanziamenti.get(bk).Importo_WarrantCPQ__c != 0 && BUFinanziamenti.get(bk).RecordType.Name == 'Finanziamenti'){
                                //If(BUFinanziamenti.get(bk).RecordType.Name == 'Finanziamenti'){
                                toSaveFinanziamenti.put(bk,BUFinanziamenti.get(bk));
                                idquote.put(q,input.get(q));
                                System.debug('Dentro Finanziamenti con prodotto bundle 2 if');
                            }
                        }
                    }
                }
            }
        }
        
        // stampo gli input di AsyncBU
        System.debug('Business Area Map Finanziamenti : ' + toSaveFinanziamenti);
        System.debug('Business Area Map Condizioni : ' + toSaveCondizioni);
        
        if(!toSaveFinanziamenti.isEmpty() && (!SBQQ.TriggerControl.isEnabled())){
            //Uso una stringa per identificare il Record Type
            //Spengo i trigger CPQ
            String s='fin';
            AsyncBUCopy executeQueueable = new AsyncBUCopy(toSaveFinanziamenti.keyset(),idquote.keyset(),s,idfin,idcon,Pag);  //PASSO IL SET AD ASYNCEXE
            ID jobID = System.enqueueJob(executeQueueable);
            System.debug('Finanziamenti jobID : ' + jobID);
            
        }
        else{
            
            SBQQ.TriggerControl.enable();
            //   system.debug('Prima dellupdate' + QuoteLine.values());
            //   update QuoteLine.values();
            //   system.debug('Dopo');
        }
    } 
    
    
    /*   public static void QuoteStatoPagStatoFatt (list <SBQQ__QuoteLine__c> oldinput, list <SBQQ__QuoteLine__c> newinput){

//Se webservice da problemi, inserire qui il controllo su utente integrazione

// per sostituire il flow, provare con rinnovi

boolean ischanged = false ;

Set<Id> idquoteline = new Set <Id> ();
Set<Id> idquote = new Set <Id> ();

Set <Id> pagati = new Set <Id> ();
Set <Id> nonpagati = new Set <Id> ();
Set <Id> fatturati = new Set <Id> ();
Set <Id> nonfatturati = new Set <Id> ();


for(SBQQ__QuoteLine__c oldq : oldinput) {
for (SBQQ__QuoteLine__c newq : newinput){

if (oldq.Stato_pagamento_dellopportunita_vinta__c != newq.Stato_pagamento_dellopportunita_vinta__c || oldq.WRT_StatoFatturazioneOpportunita__c != newq.WRT_StatoFatturazioneOpportunita__c){
ischanged = true ; 
idquoteline.add (newq.id); 
}

}
}



if (ischanged == true){
Map<id, SBQQ__QuoteLine__c> SingleQline = new Map<id, SBQQ__QuoteLine__c>([SELECT id,name, SBQQ__Quote__c,SBQQ__Quote__r.id,WRT_StatoFatturazioneOpportunita__c,Stato_pagamento_dellopportunita_vinta__c FROM SBQQ__QuoteLine__c WHERE id IN :idquoteline]);
for (id q : SingleQline.keyset()){
idquote.add (SingleQline.get(q).SBQQ__Quote__r.id);
}

Map <Id, SBQQ__Quote__c> Mapquote = new Map <id, SBQQ__Quote__c> ([SELECT Id,name,WRT_StatoFatturazioneOpportunita__c,Stato_pagamento_dellopportunita_vinta__c FROM SBQQ__Quote__c WHERE Id IN:idquote ]);    
Map<id, SBQQ__QuoteLine__c> AllQline = new Map<id, SBQQ__QuoteLine__c>([SELECT id,name, SBQQ__Quote__c,SBQQ__Quote__r.id,WRT_StatoFatturazioneOpportunita__c,Stato_pagamento_dellopportunita_vinta__c FROM SBQQ__QuoteLine__c WHERE  SBQQ__Quote__c  IN :idquote]);        





for (id ql : AllQline.keyset()){
if (AllQline.get(ql).Stato_pagamento_dellopportunita_vinta__c == 'Nessuna info'){ nonpagati.add(AllQline.get(ql).Id);}
if (AllQline.get(ql).Stato_pagamento_dellopportunita_vinta__c == 'Pagato totalmente'){  pagati.add(AllQline.get(ql).Id) ;}

if (AllQline.get(ql).WRT_StatoFatturazioneOpportunita__c == 'Non fatturata'){  nonfatturati.add(AllQline.get(ql).Id); }
if (AllQline.get(ql).WRT_StatoFatturazioneOpportunita__c == 'Fatturata completamente'){fatturati.add(AllQline.get(ql).Id) ; }
}

for (id quote : mapquote.keyset ()){

if (pagati.size() != 0 && nonpagati.size() == 0){   
MapQuote.get(quote).Stato_pagamento_dellopportunita_vinta__c = 'Pagato totalmente';
}else if (pagati.size() == 0)  {
MapQuote.get(quote).Stato_pagamento_dellopportunita_vinta__c = 'Nessuna info';
} else if (pagati.size() != 0 && nonpagati.size() != 0){
MapQuote.get(quote).Stato_pagamento_dellopportunita_vinta__c = 'Pagato parzialmente';
}


if (fatturati.size() != 0 && nonfatturati.size() == 0){   
MapQuote.get(quote).WRT_StatoFatturazioneOpportunita__c = 'Fatturata completamente';
}else if (fatturati.size() == 0)  {
MapQuote.get(quote).WRT_StatoFatturazioneOpportunita__c = 'Non fatturata';
} else if (fatturati.size() != 0 && nonfatturati.size() != 0){
MapQuote.get(quote).WRT_StatoFatturazioneOpportunita__c = 'Fatturata parzialmente';
}   


}
update MapQuote.values();

}



} //end method
*/
    
    
    
    public static void CheckDelete (Map <Id,SBQQ__QuoteLine__c> QuoteLineMap){
        
        //salvo Id solo se il numero di Fin, Cond e Pag è diverso null
        User currUser = [ SELECT Id, Societa__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
        If(currUser.Profile.Name != 'Warrant - Integration Profile' && currUser.Profile.Name !='System Administrator'  ){
            for(SBQQ__QuoteLine__c q : QuoteLineMap.values()){
                If(q.Numero_Finanziamenti__c != null && q.Numero_Condizioni__c != null && q.Numero_Pagamenti__c != null){
                    system.debug('Line Error');
                    q.addError('Non è possibile cancellare una QuoteLine che contiene Finanziamenti, Condizioni e Pagamenti');
                }
            }
        }
        
        
    }  
    
    
    
    public static void ReferenteTecnico ( Map<Id,SBQQ__QuoteLine__c> oldinput, Map <Id,SBQQ__QuoteLine__c> newinput){
        
        
        Set<Id> Referente = new Set<Id>();
        
        for(id qu:newinput.keyset()){
            if(newinput.get(qu).WRT_Referente_Tecnico__c != null){
                Referente.add(newinput.get(qu).WRT_Referente_Tecnico__c);   
            }
        }
        
        Map<Id,Contact> MtpReferente = new Map<Id,Contact> ([SELECT Id, FirstName, LastName, Email
                                                             FROM Contact
                                                             WHERE Id IN:Referente]);
        
        //Referente Tecnico
        
        for(Id q1: newinput.keySet()){
            SBQQ__QuoteLine__c oldquote1 = oldinput.get(newinput.get(q1).Id);
            if(newinput.get(q1).WRT_Referente_Tecnico__c != oldquote1.WRT_Referente_Tecnico__c){
                system.debug('IF Referente');
                for(Id c:MtpReferente.keyset()){
                    If(newinput.get(q1).WRT_Referente_Tecnico__c == MtpReferente.get(c).Id){
                        newinput.get(q1).Nome_Ref_Tecnico__c = MtpReferente.get(c).FirstName;
                        system.debug('Nome Referente' + MtpReferente.get(c).FirstName);
                        newinput.get(q1).Cognome_Ref_Tecnico__c = MtpReferente.get(c).LastName;
                        system.debug('Cognome Referente' + MtpReferente.get(c).LastName);
                        newinput.get(q1).Email_Ref_Tecnico__c = MtpReferente.get(c).Email;
                        system.debug('Email Referente' + MtpReferente.get(c).Email);
                    }
                }
            }
            If(newinput.get(q1).WRT_Referente_Tecnico__c == null){
                newinput.get(q1).Nome_Ref_Tecnico__c = null;
                newinput.get(q1).Cognome_Ref_Tecnico__c = null;
                newinput.get(q1).Email_Ref_Tecnico__c = null;
            }
        }
    }
    
    public static void ListUnitPriceApprovazioneLegale ( Map<Id,SBQQ__QuoteLine__c> oldinput, Map <Id,SBQQ__QuoteLine__c> newinput){
        
        User currUser = [ SELECT Id, Societa__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.Profile.Name: '+ currUser.Profile.Name);
        
        for(Id q1: newinput.keySet()){
            SBQQ__QuoteLine__c oldquote1 = oldinput.get(newinput.get(q1).Id);
            if((newinput.get(q1).Valore_del_pagamento_in_euro_Prodotto__c != oldquote1.Valore_del_pagamento_in_euro_Prodotto__c
                || (oldquote1.Valore_del_pagamento_in_euro_Prodotto__c == null && newinput.get(q1).Valore_del_pagamento_in_euro_Prodotto__c!= null)) && newinput.get(q1).AllineaConImporto__c == true){
                    newinput.get(q1).SBQQ__ListPrice__c =  newinput.get(q1).Valore_del_pagamento_in_euro_Prodotto__c;                    
                }
            if((newinput.get(q1).Finanziamento_Stimato_Prodotto__c != oldquote1.Finanziamento_Stimato_Prodotto__c
                || (oldquote1.Finanziamento_Stimato_Prodotto__c == null && newinput.get(q1).Finanziamento_Stimato_Prodotto__c!= null))){
                    newinput.get(q1).SBQQ__ListPrice__c =  newinput.get(q1).Finanziamento_Stimato_Prodotto__c;                    
                }
            If(currUser.Profile.Name != 'Warrant - Integration Profile' && newinput.get(q1).Richiesta_Modifica_Legale__c  != oldquote1.Richiesta_Modifica_Legale__c ){
                newinput.get(q1).WRT_Approvazione_al_legale__c = true;
            }
        }
        
    }
    
    public static void aggiornaStatoApprovazioni_Update(Map<Id, SBQQ__QuoteLine__c> input, Map<Id, SBQQ__QuoteLine__c> oldInput){
        
        set<Id> QuoteL = new Set <Id>();
        for(id ql:input.keyset()){
            if(input.get(ql).ApprovalStatus__c != oldInput.get(ql).ApprovalStatus__c && input.get(ql).ApprovalStatus__c!=null){
            QuoteL.add(input.get(ql).id);
        }
    }
        system.debug('QuoteL' + QuoteL);
        
        //Recupero le approvazioni correlate:
        Map<Id, Approvazioni__c> appCorrelate = new Map<Id, Approvazioni__c>([SELECT Quote_Line__c, Approval_Step__c FROM Approvazioni__c WHERE Quote_Line__c IN :QuoteL AND Approval_Step__c != 'Approvata' AND Approval_Step__c != 'Rifiutata']);
        
        system.debug('Size approvazione' + appCorrelate.size());
        
        for(Id i:input.keySet()){
            for(Id q:appCorrelate.keySet()){
                system.debug('dentro approvazioni');
                if(input.get(i).Id==appCorrelate.get(q).Quote_Line__c){
                    if(input.get(i).ApprovalStatus__c=='Approved'){
                        appcorrelate.get(q).Approval_Step__c='Approvata';
                        } else if(input.get(i).ApprovalStatus__c=='Rejected'){
                        appcorrelate.get(q).Approval_Step__c='Rifiutata';                        
                    }
                }
            }
                    }
        
        if(appcorrelate.size()>0){
            update appcorrelate.values();
        }
        
        
    }  
    
    public static void approvazioniWarrantQLI_Update(Map<Id,SBQQ__QuoteLine__c> input, Map<Id,SBQQ__QuoteLine__c> old){
        
        //Recupero picklist WRT_Modalita_pagamento__c:
		List<Schema.PicklistEntry> pickList = Schema.SObjectType.SBQQ__Quote__c.fields.WRT_Modalita_pagamento__c.getPicklistValues();
        
        Set<Id> QuoteLineLegale = new Set<Id>();
        List<SBQQ__QuoteLine__c> listal = new List<SBQQ__QuoteLine__c>();
        List<Approvazioni__c> appLegale = new List<Approvazioni__c>();
        
        Map<Id, Approvazioni__c> appMap = new Map<Id, Approvazioni__c>([SELECT Id, Approvazione_per_Tipo_Pagamento__c, Approval_Step__c FROM Approvazioni__c WHERE Quote_Line__c IN: input.keyset() AND Approval_Step__c = 'In attesa di approvazione' AND Approvazione_per_Tipo_Pagamento__c = true]);
        List<Approvazioni__c> listApp = new List<Approvazioni__c>();
        Boolean ApprovazionePagamento=false;
    
        for(Id q:input.keyset()){
            SBQQ__QuoteLine__c oldline = old.get(input.get(q).id);
            if(oldline.WRT_Approvazione_al_legale__c != input.get(q).WRT_Approvazione_al_legale__c && input.get(q).WRT_Approvazione_al_legale__c == true){
                QuoteLineLegale.add(input.get(q).Id);
                system.debug('Salvo la QuoteLine');
            }
            //recupero i valori delle label e api della picklsit dei pagamenti
            Schema.DescribeFieldResult stagesFR = Schema.getGlobalDescribe().get('Pagamenti__c').getDescribe().fields.getMap().get('Tipo_pagamento_WarrantCPQ__c').getDescribe();
            List<Schema.PicklistEntry> stagesPle = stagesFR.getPicklistValues();

            Map<String,String> valuesList = new Map<String,String>();

            for( Schema.PicklistEntry s : stagesPle)
            {
                valuesList.put(s.getValue(), s.getLabel());
            }

            If(oldline.WRT_Modalita_pagamento__c != input.get(q).WRT_Modalita_pagamento__c){
                for(Schema.PicklistEntry pl :pickList){
                    if(input.get(q).WRT_Modalita_pagamento__c==pl.getValue()){
                        if((pl.getLabel().contains('60')
                            || pl.getLabel().contains('90')
                            || pl.getLabel().contains('120')
                            || pl.getLabel().contains('135')
                            || pl.getLabel().contains('150')
                            || pl.getLabel().contains('165')
                            || pl.getLabel().contains('180')
                            || pl.getLabel().contains('210'))){                                
                                ApprovazionePagamento=true;
                                system.debug('Approvazione pagamento necessaria');
                            }
                    }
                }
            }
            if(ApprovazionePagamento==true){
                if(appMap.size()==0){
                    Approvazioni__c app = new Approvazioni__c(
                        Quote__c=input.get(q).SBQQ__Quote__c,
                        Approval_Step__c='In attesa di approvazione',
                        Name='Approvazione Commerciale',
                        Quote_Line__c=input.get(q).Id,
                        Soglia_Diretto_Superiore__c = true,
                        Approvazione_per_Tipo_Pagamento__c=true,
                        RecordTypeId='0125I000000l0baQAA');
                    system.debug('creazione approvazione');  
                    if(old.get(q).WRT_Modalita_pagamento__c != input.get(q).WRT_Modalita_pagamento__c) app.Tipo_Pagamento_attuale__c = valuesList.get(input.get(q).WRT_Modalita_pagamento__c);
                    if(old.get(q).WRT_Modalita_pagamento__c != input.get(q).WRT_Modalita_pagamento__c) app.Tipo_Pagamento_precedente__c = valuesList.get(old.get(q).WRT_Modalita_pagamento__c); 
                    listApp.add(app);
                }
                else
                {
                    for(Id a:appMap.keySet())
                    {
                        if(old.get(q).WRT_Modalita_pagamento__c != input.get(q).WRT_Modalita_pagamento__c) appMap.get(a).Tipo_Pagamento_attuale__c = valuesList.get(input.get(q).WRT_Modalita_pagamento__c);
                        if(old.get(q).WRT_Modalita_pagamento__c != input.get(q).WRT_Modalita_pagamento__c) appMap.get(a).Tipo_Pagamento_precedente__c = valuesList.get(old.get(q).WRT_Modalita_pagamento__c); 
                    }
                }
            }
        }
        
        
   /*    if(QuoteLineLegale.size()>0){
            //controllo se ce ne sono già e mi faccio una lista delle Quoteline
            listal = ([SELECT Id,SBQQ__Quote__c,WRT_Approvazione_al_legale__c FROM SBQQ__QuoteLine__c WHERE Id IN: QuoteLineLegale]);
            appLegale = ([SELECT Id, RecordType.Name, Approvazione_Legale_da_QLine__c FROM Approvazioni__c WHERE Quote_Line__c IN: QuoteLineLegale AND RecordType.Name = 'Legale' AND Approvazione_Legale_da_QLine__c = true AND Approval_Step__c='In approvazione']);
        }
        Map<Id, Approvazioni__c> MapLegale = new Map<Id, Approvazioni__c>(applegale);
        system.debug('Mappa Legale ' + MapLegale.size());
    
        Map<Id,SBQQ__QuoteLine__c> QuoteLlegal = new Map<Id,SBQQ__QuoteLine__c>(listal);
        List<Approvazioni__c> listaApprovazioni = new List<Approvazioni__c>();
        
        id rid = ([SELECT Id FROM RecordType WHERE SobjectType = 'Approvazioni__c' AND Name = 'Legale'  LIMIT 1]).id;
    
        If(MapLegale.size() == 0){
            for(Id x: QuoteLlegal.keyset()){
                system.debug('Nuova Appprovazione Legale');
                Approvazioni__c app = new Approvazioni__c(
                    Quote__c=QuoteLlegal.get(x).SBQQ__Quote__c,							
                    Approval_Step__c='In approvazione',
                    Name='Approvazione Legale',
                    Approvazione_Legale_da_QLine__c=true,
                    Quote_Line__c=QuoteLlegal.get(x).Id,
                    RecordTypeId=rid);
                    listaApprovazioni.add(app);
            }
        } //update non serve, non devo aggiornare i flag
        else{
            system.debug('Cancello i flag');
            for(Id x: QuoteLlegal.keyset()){
                QuoteLlegal.get(x).WRT_Approvazione_al_legale__c = false;
                system.debug('Flag legale');
            }
        }									Approvazione Legale disattivata 1 di 2 */
        If(listApp.size()>0){
            insert listApp;
        }
        if(appMap.size()> 0)
        {
            update appMap.values();
        }
    
      /*  If(listaApprovazioni.size()>0){
            insert listaApprovazioni;
            system.debug('Creo Approvazioni da QuoteLine');
        }
        if(QuoteLlegal.size()>0 && listaApprovazioni.size() == 0 ){
            update QuoteLlegal.values();
            system.debug('Cancello flag legale');
        }												Approvazione Legale disattivata 2 di 2 */
    
    }	
    
    public static void updateTipoPagamento(Map<Id,SBQQ__QuoteLine__c> oldinput, Map<Id,SBQQ__QuoteLine__c> newinput){
        
        Set<Id> qlList = new Set<Id>();
        Set<Id> quoteList = new Set<Id>();
        List<SBQQ__Quote__c> qToUp = new List<SBQQ__Quote__c>();
        
        for(Id i:newinput.keySet()){
            SBQQ__QuoteLine__c old = oldinput.get(newinput.get(i).id);
            system.debug('NEWPAG' + newinput.get(i).WRT_Modalita_pagamento__c);
            system.debug('OLDPAG' + old.WRT_Modalita_pagamento__c);
            if(newinput.get(i).WRT_Modalita_pagamento__c != old.WRT_Modalita_pagamento__c){
                qlList.add(newinput.get(i).id);
                quoteList.add(newinput.get(i).SBQQ__Quote__c);
            }
        }
        
        system.debug('QuoteLine' + qlList);
        
        if(qlList.size()>0){
            system.debug('Dentro if');
            Map<Id,Pagamenti__c> pagMap = new Map<Id,Pagamenti__c>([SELECT Quote_Line__c,Tipo_pagamento_WarrantCPQ__c,SwitchTrigger__c FROM Pagamenti__c WHERE WRT_Update_da_Rinnovo__c=false AND Quote_Line__c IN :qlList]);

            Map<Id,SBQQ__Quote__c> qMap = new Map<Id,SBQQ__Quote__c>([SELECT Id,WRT_Modalita_pagamento__c FROM SBQQ__Quote__c WHERE Id IN :quoteList]);

            system.debug('Numero Pag' + pagMap.size());
            system.debug('Numero Quote' + qMap.size());
            
            for(Id q:newinput.keyset()){                
                for(Id i:pagMap.keyset()){
                    if(newinput.get(q).Id == pagMap.get(i).Quote_Line__c){               
                        system.debug('dentro Pagamento for');                        
                        pagMap.get(i).Tipo_pagamento_WarrantCPQ__c = newinput.get(q).WRT_Modalita_pagamento__c;
                        pagMap.get(i).SwitchTrigger__c = !(pagMap.get(i).SwitchTrigger__c);                                
                    }
                }
            
                for(Id x:qMap.keySet()){
                    if(newinput.get(q).SBQQ__Quote__c == qMap.get(x).Id){
                        system.debug('dentro Quote for');
                        qMap.get(x).WRT_Modalita_pagamento__c = newinput.get(q).WRT_Modalita_pagamento__c;
                    }
                }
            }


                if(pagMap.size()>0){
                    system.debug('dentro pagamento update');
                    update pagMap.values();
                }
                if(qMap.size()>0){
                    system.debug('dentro quote update');
                    update qMap.values();
                }
        }
        
    }
    
    public static void setCongaTemplateAppoggio(List<SBQQ__QuoteLine__c> input, Map<Id,SBQQ__QuoteLine__c> oldinput, string triggerTiming){

        //Creo un Set di prodotti da usare per recuperare i campi da Logiche Template:
        Set<Id> productSet = new Set<Id>();
        Set<Id> idoption = new Set<Id>();
        Set<Id> padre = new Set <Id>();
        List<Logiche_Template__c> log = new List<Logiche_Template__c>();
        boolean bun = false;
        
        for(SBQQ__QuoteLine__c ql:input){
            if(triggerTiming=='isInsert' || (triggerTiming=='isUpdate' && ql.Tipo_Mandato__c!=oldinput.get(ql.id).Tipo_Mandato__c)){
            productSet.add(ql.SBQQ__Product__c);
            idoption.add(ql.SBQQ__ProductOption__c);
            }            
        }
        system.debug('setCongaTemplateAppoggio ' + triggerTiming);
        system.debug('Prodotto Padre' + idoption);
        system.debug('Prodotto figlio' + productSet);
        
        //Recupero Bundle
        Map<Id, SBQQ__ProductOption__c> Bundle = new map <Id, SBQQ__ProductOption__c> ([SELECT Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE Id IN: idoption]);
        
        system.debug('Bundle' + Bundle.values());
        
        If(Bundle.size()>0){
            bun=true;
            System.debug('Bundle true');
            for(Id B:Bundle.keyset()){
                padre.add(Bundle.get(b).SBQQ__ConfiguredSKU__c);
            }
        }
        
        System.debug('Bundle' + padre);
        
        If(bun == false){
            system.debug('PRODOTTO SECCO');
            log = ([SELECT Gruppo_Template__c, Prodotto_Singolo__c,Prodotto_Padre__c, RecordTypeId, RecordType.Name FROM Logiche_Template__c WHERE Prodotto_Singolo__c IN :productSet AND Prodotto_Padre__c IN :productSet]);
        }else{
            system.debug('PRODOTTO BUNDLE');
            log = ([SELECT RecordType.Name, Gruppo_Template__c,Prodotto_Padre__c, Prodotto_Singolo__c, RecordTypeId FROM Logiche_Template__c WHERE Prodotto_Singolo__c IN :productSet AND Prodotto_Padre__c IN :padre]);    
        }
        
        Map<Id, Logiche_Template__c> logiche = new Map<Id,Logiche_Template__c>(log);
        
        //Recupero Id Template e Record Type Id:
        //Map<Id,Logiche_Template__c> logiche = new Map<Id,Logiche_Template__c>([SELECT ID_Template__c, Prodotto_Singolo__c, RecordTypeId FROM Logiche_Template__c WHERE Prodotto_Singolo__c IN :productSet]);
        System.debug('Numero Template Recuperati: '+logiche.size());
        System.debug('Template Recuperati: '+logiche.values());
        
        String ConcatTemplate;
        //DA ATTIVARE SOLO PER I BUNDLE:
        /*for(SBQQ__QuoteLine__c ip:input){
            if(ip.TemplateQuote__c != null){
                system.debug('Quote '+ ip.TemplateQuote__c );
                ConcatTemplate = ip.TemplateQuote__c + ',';
            }
        }*/
        system.debug('Concact iniziale' + ConcatTemplate);
        
        for(SBQQ__QuoteLine__c ql:input){
            system.debug('Tipo Mandato ' + ql.Tipo_Mandato__c);
            system.debug('Creato con processo ' + ql.Creato_con_processo__c);
            for(Id q:logiche.keySet()){
                
                system.debug('logiche.get(q).RecordType.Name' + logiche.get(q).RecordType.Name);
                
                //Condizione Singolo
                if(ql.Tipo_Mandato__c == 'Singolo'){
                    system.debug('dentro if singolo');
                    if(ql.SBQQ__Product__c == logiche.get(q).Prodotto_Singolo__c && logiche.get(q).RecordType.Name=='Singolo'){
                        if(ConcatTemplate == null){
                            ConcatTemplate = logiche.get(q).Gruppo_Template__c + ',';
                        }else{
                            ConcatTemplate += logiche.get(q).Gruppo_Template__c + ',';
                        }
                        system.debug('Caso singolo');						                       
                    }
                }
                //Condizione Pluriennale
                else if(ql.Tipo_Mandato__c!='Singolo' && !(ql.Creato_con_processo__c.contains('Rinnovo Automatico'))){
                    system.debug('dentro if pluri');
                    if(ql.SBQQ__Product__c == logiche.get(q).Prodotto_Singolo__c && logiche.get(q).RecordType.Name=='Pluriennale'){
                        if(ConcatTemplate == null){
                            ConcatTemplate = logiche.get(q).Gruppo_Template__c + ',';
                        }else{
                            ConcatTemplate += logiche.get(q).Gruppo_Template__c + ',';
                        }
                        System.debug('Caso Pluri');                       
                    }
                }              
                //Condizione Rinnovo Automatico
                else if(ql.Creato_con_processo__c.contains('Rinnovo Automatico')){
                    system.debug('dentro if rinnovo');
                    if(ql.SBQQ__Product__c == logiche.get(q).Prodotto_Singolo__c && logiche.get(q).RecordType.Name=='Rinnovo Automatico'){
                        if(ConcatTemplate == null){
                            ConcatTemplate = logiche.get(q).Gruppo_Template__c + ',';
                        }else{
                            ConcatTemplate += logiche.get(q).Gruppo_Template__c + ',';
                        }	
                        system.debug('Caso rinnovo');					                        
                    }
                }                
            }
            If(ConcatTemplate != null){
                ConcatTemplate=ConcatTemplate.removeEnd(',');
            }
            system.debug('ConcatTemplate'+ConcatTemplate);
            
            ql.WRT_Template_Conga_Appoggio__c=ConcatTemplate;
        }        
    }
    
    public static void setCongaTemplateOnQuote(Map<Id,SBQQ__QuoteLine__c> input, Map<Id,SBQQ__QuoteLine__c> oldinput, string triggerTiming){
        
        //Recupero le Quote associate alle QuoteLine in input:
        Set<Id> idQuote = new Set<Id>();
        system.debug('setCongaTemplateOnQuote ' + triggerTiming);
        for(Id i:input.keySet()){
            
            if(input.get(i).WRT_Template_Conga_Appoggio__c != null){
                if(triggerTiming=='isInsert' || (triggerTiming=='isUpdate' && input.get(i).Tipo_Mandato__c!=oldinput.get(i).Tipo_Mandato__c)){
                idQuote.add(input.get(i).SBQQ__Quote__c);
                }
            }
        }
        Map<Id,SBQQ__Quote__C> quoteMap = new Map<Id,SBQQ__Quote__c>();
        if(idQuote.size()>0) quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT WRT_Template_Conga__c FROM SBQQ__Quote__C WHERE Id IN :idQuote]);
        
        //Assegno l'Id Template alla quote corrispondente:
        List<SBQQ__Quote__C> quoteToUp = new List<SBQQ__Quote__C>();
        for(Id i:input.keySet()){
            for(Id q:quoteMap.keySet()){
                if(input.get(i).SBQQ__Quote__c==quoteMap.get(q).Id){
                    quoteMap.get(q).WRT_Template_Conga__c = input.get(i).WRT_Template_Conga_Appoggio__c;
                    quoteToUp.add(quoteMap.get(q));
                }
            }
        }
        
        //Aggiorno le Quote:
        if(quoteToUp.size()>0){
            update quoteToUp;
        }
    }
}