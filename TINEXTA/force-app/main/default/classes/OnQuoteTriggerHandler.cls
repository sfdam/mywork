public class OnQuoteTriggerHandler {
    
    public static void InsertOpportunity (Map <Id,SBQQ__Quote__c> Quote){   
        
        // tutte le volte che creo una quote creo un'opportunità
        SBQQ.TriggerControl.disable();
        
        Map<Id,SBQQ__Quote__c> toCreateOpp = new Map<Id,SBQQ__Quote__c>(); 
        
        for (Id  q : Quote.keyset()) {
            If(Quote.get(q).SBQQ__Opportunity2__c == null && Quote.get(q).Escludi_da_template__c == false){
                system.debug('Dentro For');
                toCreateOpp.put(q,Quote.get(q)); 
                system.debug('Dentro If');
            }
            
        }
        system.debug('Quote' + ToCreateOpp);
        
        if(!toCreateOpp.isEmpty()&& (!SBQQ.TriggerControl.isEnabled())){
            //Uso una stringa per identificare il Record Type
            AsyncQuoteCopy executeQueueable = new AsyncQuoteCopy(toCreateOpp.keyset());  //PASSO IL SET AD ASYNCEXE
            ID jobID = System.enqueueJob(executeQueueable);
            System.debug(' Create Quote jobID : ' + jobID);
        }
        else{
            SBQQ.TriggerControl.enable();
        }  
    }
    
    public static void QuoteClose ( Map<Id,SBQQ__Quote__c> oldinput, Map <Id,SBQQ__Quote__c> newinput){
        
        for(Id q: newinput.keySet()){
            SBQQ__Quote__c oldquote = oldinput.get(newinput.get(q).Id);
            if(newinput.get(q).StageName__c != oldquote.StageName__c ||newinput.get(q).Contratto_firmato__c != oldquote.Contratto_firmato__c || newinput.get(q).WRT_data_respinta__c != oldquote.WRT_data_respinta__c|| newinput.get(q).WRT_DataOrdine__c != oldquote.WRT_DataOrdine__c ){
                If(newinput.get(q).StageName__c == 'Chiuse/Perse'){
                    system.debug('Persa');
                    If(newinput.get(q).WRT_data_respinta__c == null){
                        system.debug('Data respinta');
                        newinput.get(q).WRT_data_respinta__c = Date.today();
                    } 
                    newinput.get(q).WRT_DataOrdine__c= null;
                }
                else if(newinput.get(q).StageName__c == 'Chiuse/Conseguite'){
                    If(newinput.get(q).WRT_DataOrdine__c == null){
                        newinput.get(q).WRT_DataOrdine__c = Date.today();
                    }
                    newinput.get(q).WRT_data_respinta__c=null;
                }
                else{
                    newinput.get(q).WRT_data_respinta__c=null;
                    newinput.get(q).WRT_DataOrdine__c= null;
                }
            }
            
        }
    }
    
    
    
    
    public static void NumeroInfostore ( Map<Id,SBQQ__Quote__c> oldinput, Map <Id,SBQQ__Quote__c> newinput){
        
        
        Set<Id> Referente = new Set<Id>();
        
        for(id qu:newinput.keyset()){
            if(newinput.get(qu).WRT_Referente_Amministrativo__c != null){
                Referente.add(newinput.get(qu).WRT_Referente_Amministrativo__c);   
            }
        }
        
        for(Id q: newinput.keySet()){
            SBQQ__Quote__c oldquote = oldinput.get(newinput.get(q).Id);
            system.debug('Chiuse Stage' + newinput.get(q).StageName__c );
            system.debug('Chiuse Numero' + oldquote.Numero_di_QuoteLine__c );
            //Numero infostore
            if(newinput.get(q).StageName__c == 'Chiuse/Perse' && oldquote.Numero_di_QuoteLine__c == 0 ){
                system.debug('Chiuse IF');
                newinput.get(q).Numero_offerta_Infostore__c='0';
            }
        }
        //Referente Amministrativo
        if(Referente.size() > 0) 
        {
            Map<Id,Contact> MtpReferente = new Map<Id,Contact> ([SELECT Id, FirstName, LastName, Email
                                                                 FROM Contact
                                                                 WHERE Id IN:Referente]);
            for(Id q1: newinput.keySet()){
                SBQQ__Quote__c oldquote1 = oldinput.get(newinput.get(q1).Id);
                if(newinput.get(q1).WRT_Referente_Amministrativo__c != oldquote1.WRT_Referente_Amministrativo__c){
                    system.debug('IF Referente');
                    for(Id c:MtpReferente.keyset()){
                        If(newinput.get(q1).WRT_Referente_Amministrativo__c == MtpReferente.get(c).Id){
                            newinput.get(q1).Nome_Ref_Amministrativo__c = MtpReferente.get(c).FirstName;
                            system.debug('Nome Referente' + MtpReferente.get(c).FirstName);
                            newinput.get(q1).Cognome_Ref_Amministrativo__c = MtpReferente.get(c).LastName;
                            system.debug('Cognome Referente' + MtpReferente.get(c).LastName);
                            newinput.get(q1).Email_Ref_Amministrativo__c = MtpReferente.get(c).Email;
                            system.debug('Email Referente' + MtpReferente.get(c).Email);
                        }
                    }
                }
                If(newinput.get(q1).WRT_Referente_Amministrativo__c == null){
                    newinput.get(q1).Nome_Ref_Amministrativo__c = null;
                    newinput.get(q1).Cognome_Ref_Amministrativo__c = null;
                    newinput.get(q1).Email_Ref_Amministrativo__c = null;
                }
            }
        }
    }
    
    
    
    public static void CampiDisdetta (Map<Id,SBQQ__Quote__c> oldinput,Map <Id,SBQQ__Quote__c> newinput ){
        
        Set<Id> idquote = new Set <Id> ();
        
        for(Id q: newinput.keySet()){
            SBQQ__Quote__c oldquote= oldinput.get(newinput.get(q).Id);
            if(newinput.get(q).WRT_Disdetta__c != oldquote.WRT_Disdetta__c || newinput.get(q).Data_disdetta__c != oldquote.Data_disdetta__c || newinput.get(q).Motivo_disdetta__c != oldquote.Motivo_disdetta__c ||newinput.get(q).WRT_Modalita_ricezione_disdetta__c != oldquote.WRT_Modalita_ricezione_disdetta__c ){ 
                idquote.add(newinput.get(q).Id);
                system.debug('salvo quote');
            }
        }
        
        
        If(idquote.size()>0){
            Map<Id,SBQQ__QuoteLine__c> Mapline = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id,WRT_Disdetta__c,Data_disdetta__c,Motivo_disdetta__c,WRT_Modalita_ricezione_disdetta__c,SBQQ__Quote__c
                                                                                  FROM SBQQ__QuoteLine__c
                                                                                  WHERE SBQQ__Quote__c IN:idquote]);
            
            
            system.debug('Mappa Line ' + Mapline.size());
            
            for(Id l:newinput.keyset()){
                for(Id i:Mapline.keyset()){
                    if(newinput.get(l).Id == Mapline.get(i).SBQQ__Quote__c){
                        Mapline.get(i).WRT_Disdetta__c = newinput.get(l).WRT_Disdetta__c;
                        Mapline.get(i).Data_disdetta__c = newinput.get(l).Data_disdetta__c;
                        Mapline.get(i).Motivo_disdetta__c = newinput.get(l).Motivo_disdetta__c;
                        Mapline.get(i).WRT_Modalita_ricezione_disdetta__c = newinput.get(l).WRT_Modalita_ricezione_disdetta__c;
                    }
                }
            }
            
            
            
            If(Mapline.size()>0){
                SBQQ.TriggerControl.disable();
                update Mapline.values();
                SBQQ.TriggerControl.enable();
            }
        }
        
    }
    
    
    
    /*  public static void changeOwner(List<SBQQ__Quote__c> newList, List<SBQQ__Quote__c> oldList){
system.debug('EU changeOwner');

User currUser = [ SELECT Id, Societa__c, UserRole.Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
system.debug('currUser.Societa__c: '+currUser.Societa__c);

if(currUser.Societa__c == 'Warrant' && currUser.Profile.Name != 'Warrant - Integration Profile'){

//Set<Id> AccountIds = new Set<Id>();
Set<Id> IdQuote = new Set <Id> ();

for(SBQQ__Quote__c q : newList){
If(q.SharingModel__c == false){
//AccountIds.add(q.SBQQ__Account__c);
IdQuote.add(q.Id);
}
}

//Map<String,sObject> accMap = Utilities.keyBy([SELECT Id, Responsabile_WarrantHub__c FROM Account WHERE Id IN : AccountIds],'Id');
//system.debug('accMap: '+accMap);

Map <Id, SBQQ__Quote__c> Mapquote = new Map <id, SBQQ__Quote__c> ([SELECT Id, OwnerId,SBQQ__Account__c, SBQQ__Account__r.Responsabile_WarrantHub__c, SBQQ__PriceBook__c, SBQQ__PricebookId__c FROM SBQQ__Quote__c WHERE Id IN:IdQuote]);


for(Id qq : Mapquote.keyset()){
system.debug('Mapquote.get(qq).OwnerId: '+ Mapquote.get(qq).OwnerId);
system.debug('Mapquote.get(qq).SBQQ__Account__r.Responsabile_WarrantHub__c' + Mapquote.get(qq).SBQQ__Account__r.Responsabile_WarrantHub__c); 
if(currUser.Id == Mapquote.get(qq).OwnerId){
if(Mapquote.get(qq).SBQQ__Account__r.Responsabile_WarrantHub__c != null && Mapquote.get(qq).SBQQ__Account__r.Responsabile_WarrantHub__c!= Mapquote.get(qq).OwnerId){
Mapquote.get(qq).OwnerId = (Id)Mapquote.get(qq).SBQQ__Account__r.Responsabile_WarrantHub__c;        
} 
}
}

If(Mapquote.size()>0){
update Mapquote.values();
}
}

} */
    
    public static void BlockCreate (List<SBQQ__Quote__c> QuoteMap){
        //se il creatore non ha i permessi di Write su Account è necessario bloccare
        Profile ProfileName = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        Set <Id> IdAccount = new Set <Id>();
        
        
        for(SBQQ__Quote__c qm:QuoteMap){
            IdAccount.add(qm.SBQQ__Account__c);
        }
        system.debug('EU User creatore'+ UserInfo.getUserId());
        system.debug('EU Account' + IdAccount);
        
        Map<Id,AccountShare> MtpAccountshare = new Map <Id,AccountShare> ([SELECT Id, UserOrGroupId, AccountAccessLevel, AccountId 
                                                                           FROM AccountShare
                                                                           WHERE AccountId IN:IdAccount AND UserOrGroupId =: UserInfo.getUserId()]);
        
        System.debug('Size Map Share' + MtpAccountshare.size());
        System.debug('ShareMap' + MtpAccountshare.values());
        Boolean Check = false;
        
        
        
        
        
        for(Id a:MtpAccountshare.keyset()){
            system.debug('EU for share');
            If(UserInfo.getUserId() == MtpAccountshare.get(a).UserOrGroupId){
                system.debug('If stesso User');
                If(MtpAccountshare.get(a).AccountAccessLevel == 'All' || MtpAccountshare.get(a).AccountAccessLevel == 'Edit'){
                    system.debug('Access Level' + MtpAccountshare.get(a).AccountAccessLevel);
                    Check = true;
                }
            }
            
            
        }
        
        
        If((Check == false || MtpAccountshare.size() == 0)&& ProfileName.Name != 'Warrant - Integration Profile' && ProfileName.Name != 'Warrant - Support Marketing Alliance' && ProfileName.Name != 'Warrant Hub - System Administrator' ){
            for(SBQQ__Quote__c qt:QuoteMap){
                qt.adderror('Attenzione, non è possibile creare Quote per clienti di altri operatori');
            }
        }
    }
    
    
    public static void blockDelete(Map<Id,SBQQ__Quote__c> QuoteMap){
        User currUser = [ SELECT Id, Societa__c, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.UserRole.Name: '+ currUser.UserRole.Name);
        
        Set<Id> OppId = new Set <Id>();
        
        
        for(Id q:QuoteMap.keyset()){
            OppId.add(QuoteMap.get(q).SBQQ__Opportunity2__c);
        }
        
        //Warrant Direzione Commerciale solo per Testare se funziona
        if(currUser.Societa__c == 'Warrant' && (currUser.UserRole.Name == 'Warrant Direzione Commerciale' ||currUser.UserRole.Name == 'Warrant Sales Support' || currUser.UserRole.Name == 'Warrant Operatore Marketing' || currUser.UserRole.Name == 'Warrant Alliance Manager')){
            Map<String,sObject> quoteRecTypeMap = Utilities.keyBy([SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'SBQQ__Quote__c' and IsActive = true ], 'Id');
            Map<String,sObject> opptStage = Utilities.keyBy([SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true], 'ApiName');
            Map<String,sObject> itemMap =Utilities.keyBy([SELECT  Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: OppId], 'OpportunityId');
            
            for(SBQQ__Quote__c qq : QuoteMap.values()){
                
                system.debug('prob: '+(Decimal)opptStage.get(qq.StageName__c).get('DefaultProbability'));
                
                if(quoteRecTypeMap.get(qq.RecordTypeId).get('DeveloperName') == 'Warrant'){
                    if(itemMap.get(qq.Id) != null){
                        qq.addError('Non è possibile eliminare Quote con prodotti associati');
                    }
                    if(qq.Numero_offerta_Infostore__c != null && qq.Numero_offerta_Infostore__c != ''){
                        qq.addError('Non è possibile cancellare questa Quote perché è collegata con altri sistemi');
                    }
                    if ((Decimal)opptStage.get(qq.StageName__c).get('DefaultProbability') >= 50.00 || (Decimal)opptStage.get(qq.StageName__c).get('DefaultProbability') == 0){
                        qq.addError('Non è possibile eliminare Quote con probabilità maggiore o uguale al 50%');
                    }
                }
            }
        }
        
    }
    
    /* public static void AggiornamentoCloseDateApprovazioneLegale (Map<Id,SBQQ__Quote__c> oldinput,Map <Id,SBQQ__Quote__c> newinput ){

User currUser = [ SELECT Id, Societa__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
system.debug('currUser.Profile.Name: '+ currUser.Profile.Name);

for(Id q: newinput.keySet()){
SBQQ__Quote__c oldquote= oldinput.get(newinput.get(q).Id);
if(currUser.Profile.Name != 'Warrant - Integration Profile' && newinput.get(q).StageName__c != oldquote.StageName__c && (newinput.get(q).StageName__c == 'Chiuse/Conseguite' || newinput.get(q).StageName__c == 'Chiuse/Perse')){
newinput.get(q).CloseDate__c = system.today();
}
If(currUser.Profile.Name != 'Warrant - Integration Profile' && 
((newinput.get(q).Foro_di_Competenza__c != oldquote.Foro_di_Competenza__c && oldquote.Foro_di_Competenza__c != null) ||
newinput.get(q).Richiesta_Modifica_Legale__c != oldquote.Richiesta_Modifica_Legale__c)){
newinput.get(q).Approvazione_al_legale__c = true;
}
}              
}

public static void updateStageNameRules (Map<Id,SBQQ__Quote__c> oldinput, Map<Id,SBQQ__Quote__c> newinput){

Profile profile = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];

for(Id i:newinput.keySet()){
SBQQ__Quote__c n = newinput.get(i);
SBQQ__Quote__c o = oldinput.get(i);

// Ex regola: WRT - Update Stage on Quote = 50%
if(profile.Name!='Warrant - Integration Profile'){
if(o.Escludi_da_template__c == false && (o.Numero_di_QuoteLine__c==0 && n.Numero_di_QuoteLine__c==1)){
n.StageName__c='Proposta/Quotazione prezzi';
}
}
// Ex regola: Contratto firmato
if(o.Contratto_firmato__c != n.Contratto_firmato__c && n.Contratto_firmato__c=='.'){
n.StageName__c='Chiuse/Conseguite';
}
}
}	*/
    
    public static void AggiornamentoCloseDateApprovazioneLegale (Map<Id,SBQQ__Quote__c> oldinput,Map <Id,SBQQ__Quote__c> newinput ){
        
        User currUser = [ SELECT Id, Societa__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.Profile.Name: '+ currUser.Profile.Name);
        
        for(Id q: newinput.keySet()){
            SBQQ__Quote__c oldquote= oldinput.get(newinput.get(q).Id);
            if(currUser.Profile.Name != 'Warrant - Integration Profile' && newinput.get(q).StageName__c != oldquote.StageName__c && (newinput.get(q).StageName__c == 'Chiuse/Conseguite' || newinput.get(q).StageName__c == 'Chiuse/Perse')){
                newinput.get(q).CloseDate__c = system.today();
            }
      		//creazione legale da modifica foro è qui
            If(currUser.Profile.Name != 'Warrant - Integration Profile'){
                if(((newinput.get(q).Foro_di_Competenza__c != oldquote.Foro_di_Competenza__c && oldquote.Foro_di_Competenza__c != null) ||
                    newinput.get(q).Richiesta_Modifica_Legale__c != oldquote.Richiesta_Modifica_Legale__c)){
                        newinput.get(q).Approvazione_al_legale__c = true;
                    }
                if(/*oldquote.Escludi_da_template__c == false && */(oldquote.Numero_di_QuoteLine__c==0 && newinput.get(q).Numero_di_QuoteLine__c==1)){
                    newinput.get(q).StageName__c='Proposta/Quotazione prezzi';
                }                
            }
            if(oldquote.Contratto_firmato__c != newinput.get(q).Contratto_firmato__c && newinput.get(q).Contratto_firmato__c=='.'){
                newinput.get(q).StageName__c='Chiuse/Conseguite';
                If(newinput.get(q).WRT_DataOrdine__c == null){
                    newinput.get(q).WRT_DataOrdine__c = Date.today();
                }
                newinput.get(q).WRT_data_respinta__c=null;
            }       
        }        
    }
    
    
    /*  public static void approvazioniWarrant_Insert(List<SBQQ__Quote__c> input){

//Lista a cui aggiungere le approvazioni che dovrò inserire a DB successivamente: 
List<Approvazioni__c> listaApprovazioni = new List<Approvazioni__c>();

//Lista per aggiornare le quotes:
List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();

//In caso sia necessaria approvazione legale o commerciale creo il record correlato e lo aggiungo alla lista: 
for(SBQQ__Quote__c q:input){
if(q.Approvazione_al_legale__c==true && q.Controllo_Approvazioni_legale__c==0){		
Approvazioni__c app = new Approvazioni__c(
Quote__c=q.Id,							
Approval_Step__c='In approvazione',
Name='Approvazione Legale',
RecordTypeId='0125I000000l0bbQAA');
q.Approvazione_al_legale__c=false;
listaApprovazioni.add(app);
quoteToUpdate.add(q);            
} else if(q.Approvazione_al_commerciale__c==true && q.Controllo_Approvazioni_commerciale__c==0){		
Approvazioni__c app = new Approvazioni__c(
Quote__c=q.Id,							
Approval_Step__c='In attesa di approvazione',
Name='Approvazione Commerciale',
RecordTypeId='0125I000000l0baQAA');
q.Approvazione_al_commerciale__c=false;
listaApprovazioni.add(app);
quoteToUpdate.add(q);                                    
}
}
try{
insert listaApprovazioni;
update quoteToUpdate;
} catch (Exception e){
System.debug('Si è verificato un problema: '+e.getMessage());	
}		        
}		*/
    
    
public static void approvazioniWarrant_Update(Map<Id,SBQQ__Quote__c> input, Map<Id,SBQQ__Quote__c> Old){
        
    System.debug('Approvazioni Warrant Update Quote');
    
    Id userID = UserInfo.getUserId();
    User currentUser = [SELECT Profile.Name, UserRole.Name FROM User WHERE Id = :userID LIMIT 1];

    Set<Id> QuoteComm = new Set<Id>();
    List<Approvazioni__c> appCommerciale = new List<Approvazioni__c>();
    List<SBQQ__Quote__c> listac = new List<SBQQ__Quote__c>();

    Boolean ApprovazioneForo = false;
    Boolean ApprovazioneForo2 = false;
    Boolean ApprovazionePagamento = false;
    Boolean SogliaComm = false;
    Boolean SogliaDM = false;
    Boolean SogliaAM = false;
    Boolean SogliaDC = false;
    Boolean SogliaSup = false;
    
    for(Id i:input.keyset()){
        SBQQ__Quote__c oldi = Old.get(input.get(i).id);
        if(input.get(i).Foro_di_Competenza__c!='Reggio Emilia' && oldi.Foro_di_Competenza__c!=input.get(i).Foro_di_Competenza__c && currentUser.UserRole.Name.contains('Warrant Sales')){
               ApprovazioneForo = true;
               SogliaComm = true;
               SogliaDM = true;
           }
           if(oldi.Foro_2__c!=input.get(i).Foro_2__c && input.get(i).Foro_2__c!=null){
               ApprovazioneForo2=true;
               SogliaComm = true;
               SogliaAM = true;
               SogliaDM = true;
           }
    }
    
    for(Id q:input.keyset()){
        SBQQ__Quote__c oldquote= old.get(input.get(q).Id);
        system.debug('OldQuote ' +oldquote.Approvazione_al_legale__c  );
        system.debug('NewQuote ' +input.get(q).Approvazione_al_legale__c );

        If((oldquote.Approvazione_al_commerciale__c == false && input.get(q).Approvazione_al_commerciale__c == true)
           ||(input.get(q).Foro_di_Competenza__c!=oldquote.Foro_di_Competenza__c && input.get(q).Foro_di_Competenza__c!='Reggio Emilia' && currentUser.Profile.Name=='Warrant - Sales')
           || ApprovazioneForo2 == true || ApprovazionePagamento == true){
               QuoteComm.add(input.get(q).id);
               system.debug('Salvo quote commerciale');
           }
    }

    if(QuoteComm.size()>0){
        //controllo se ce ne sono già:
        listac = ([SELECT Id, Approvazione_al_commerciale__c FROM SBQQ__Quote__c WHERE Id IN: QuoteComm]);
        appCommerciale = ([SELECT Id, RecordType.Name, Creazione_da_Quote__c,Quote__c,Soglia_AM_KAM_Superata__c,Soglia_Diretto_Superiore__c,
                           Soglia_Commerciale_Superata__c,Soglia_DM_Superata__c,Approvazione_per_Tipo_Pagamento__c,Approvazione_foro_2__c,Soglia_Dir_Comm_Superata__c,Approvazione_per_Foro__c  FROM Approvazioni__c WHERE Quote__c IN: QuoteComm AND RecordType.Name = 'Commerciale' AND Creazione_da_Quote__c = true AND Approval_Step__c='In attesa di approvazione']);
    }
    
    Map<Id, Approvazioni__c> MapCommerciale = new Map<Id, Approvazioni__c>(appCommerciale);
    system.debug('Mappa Commerciale ' + MapCommerciale.size());
    
    //Se entrambe le mappe sono vuote vuol dire che sono in fase di insert
    //In caso di update non faccio nulla per la parte legale, guardo solo la parte commerciale per il foro

    Map<Id,SBQQ__Quote__c> QuoteC = new Map<Id,SBQQ__Quote__c>(listac);
    List<Approvazioni__c> listaApprovazioni = new List<Approvazioni__c>();
    

    If(MapCommerciale.size() == 0){ 
        //id rid = ([SELECT Id FROM RecordType WHERE SobjectType = 'Approvazioni__c' AND Name = 'Legale'  LIMIT 1]).id;
        id rid2 = ([SELECT Id FROM RecordType WHERE SobjectType = 'Approvazioni__c' AND Name = 'Commerciale' LIMIT 1]).id;
        for(Id y:QuoteC.keyset()){
            system.debug('Nuova Approvazione Commerciale');
            Approvazioni__c app2 = new Approvazioni__c(
                Quote__c=input.get(y).Id,							
                Approval_Step__c='In attesa di approvazione',
                Name='Approvazione Commerciale',
                Creazione_da_Quote__c= true,
                RecordTypeId=rid2,
                Soglia_AM_KAM_Superata__c=SogliaAM,
                Soglia_Commerciale_Superata__c=SogliaComm,                                                                 
                Approvazione_per_Foro__c = ApprovazioneForo,
                Approvazione_foro_2__c = ApprovazioneForo2,
                Soglia_DM_Superata__c=SogliaDM,
                Approvazione_per_Tipo_Pagamento__c=ApprovazionePagamento,
                Soglia_Dir_Comm_Superata__c=SogliaDC,
            	Soglia_Diretto_Superiore__c=SogliaSup);
                if(Old.get(y).Foro_di_Competenza__c != input.get(y).Foro_di_Competenza__c) app2.FORO_precedente__c = Old.get(y).Foro_di_Competenza__c;
                if(Old.get(y).Foro_2__c != input.get(y).Foro_2__c) app2.FORO_2_precedente__c = Old.get(y).Foro_2__c;
            listaApprovazioni.add(app2);
        }
        
    } else If(MapCommerciale.size()>0){
        for(id i:QuoteC.keyset()){
            for(id a:MapCommerciale.keyset()){
                if(QuoteC.get(i).Id == MapCommerciale.get(a).Quote__c){

                    //AGGIUNGERE MAPPATURA CAMPI VALORI PRECEDENTE LOG MODIFICHE

                    system.debug('Aggiornamento Approvazione Commerciale');
                    If(MapCommerciale.get(a).Soglia_AM_KAM_Superata__c == false && SogliaAM == true){
                        MapCommerciale.get(a).Soglia_AM_KAM_Superata__c=SogliaAM;
                    }
                    If(MapCommerciale.get(a).Soglia_Commerciale_Superata__c == false && SogliaComm == true){
                        MapCommerciale.get(a).Soglia_Commerciale_Superata__c=SogliaComm;   
                    }
                    If(MapCommerciale.get(a).Approvazione_per_Foro__c == false && ApprovazioneForo == true){                                                              
                        MapCommerciale.get(a).Approvazione_per_Foro__c = ApprovazioneForo;
                    }
                    If(MapCommerciale.get(a).Approvazione_foro_2__c == false && ApprovazioneForo2 == true){                                                              
                        MapCommerciale.get(a).Approvazione_foro_2__c = ApprovazioneForo2;
                    }
                    If(MapCommerciale.get(a).Approvazione_per_Tipo_Pagamento__c == false && ApprovazionePagamento == true){                                                              
                        MapCommerciale.get(a).Approvazione_per_Tipo_Pagamento__c = ApprovazionePagamento;
                        system.debug('Dentro tipo pag');
                       
                    }
                    If(MapCommerciale.get(a).Soglia_DM_Superata__c == false && SogliaDM == true){
                        MapCommerciale.get(a).Soglia_DM_Superata__c=SogliaDM;
                    }
                    If(MapCommerciale.get(a).Soglia_Dir_Comm_Superata__c == false && SogliaDC == true){
                        MapCommerciale.get(a).Soglia_Dir_Comm_Superata__c=SogliaDC;
                    }
                    If(MapCommerciale.get(a).Soglia_Diretto_Superiore__c == false && SogliaSup == true){
                        MapCommerciale.get(a).Soglia_Diretto_Superiore__c=SogliaSup;
                    }
                    if(Old.get(i).Foro_di_Competenza__c != input.get(i).Foro_di_Competenza__c) MapCommerciale.get(a).FORO_precedente__c = Old.get(i).Foro_di_Competenza__c;
                    if(Old.get(i).Foro_2__c != input.get(i).Foro_2__c) MapCommerciale.get(a).FORO_2_precedente__c = Old.get(i).Foro_2__c;
                }
            }
        }
    }
    
    else {
        system.debug('Cancello i flag');        
        for(Id y:QuoteC.keyset()){
            QuoteC.get(y).Approvazione_al_commerciale__c = false;
            system.debug('Flag commerciale');
        }
        
    }
    
    If(listaApprovazioni.size()>0){
        insert listaApprovazioni;
        system.debug('Creo Approvazioni da Quote');
    }
    If(QuoteC.size()>0 && listaApprovazioni.size() == 0 && MapCommerciale.size() != 0){
        update MapCommerciale.values();
        system.debug('Aggiorno approvazione commerciale');
    }
    if(QuoteC.size()>0 && listaApprovazioni.size() == 0 && MapCommerciale.size() == 0){
        update QuoteC.values();
        system.debug('Cancello flag commerciale');
    }
    
    
}
    //Metodo per approvazioni CPQ basato su foro e foro2 (ex metodo che guardava anche il fatturato dell'account):
    public static void approvazioneFatturato_Insert(Map<Id,SBQQ__Quote__c> input){
        
        Id userID = UserInfo.getUserId();
        User currentUser = [SELECT Profile.Name, UserRole.Name FROM User WHERE Id = :userID LIMIT 1];
        
        List<Approvazioni__c> listApp = new List<Approvazioni__c>();
        
        for(Id i:input.keySet()){
            if(input.get(i).Foro_di_Competenza__c!='Reggio Emilia' && input.get(i).Foro_di_Competenza__c!=null && currentUser.UserRole.Name.contains('Warrant Sales')){                
                Approvazioni__c app = new Approvazioni__c(Quote__c=input.get(i).Id,							
                                                          Approval_Step__c='In attesa di approvazione',
                                                          Name='Approvazione Commerciale',
                                                          Creazione_da_Quote__c= true,
                                                          RecordTypeId='0125I000000l0baQAA',
                                                          Soglia_Commerciale_Superata__c=true,                                                                 
                                                          Approvazione_per_Foro__c=true,
                                                          Soglia_DM_Superata__c=true);
                listApp.add(app);
            }
            if(input.get(i).Foro_2__c!=null){                
                Approvazioni__c app3 = new Approvazioni__c(Quote__c=input.get(i).Id,							
                                                           Approval_Step__c='In attesa di approvazione',
                                                           Name='Approvazione Commerciale',
                                                           Creazione_da_Quote__c= true,
                                                           RecordTypeId='0125I000000l0baQAA',
                                                           Soglia_AM_KAM_Superata__c=true,
                                                           Soglia_Commerciale_Superata__c=true,
                                                           Approvazione_foro_2__c=true,
                                                           Soglia_DM_Superata__c=true);
                listApp.add(app3);                
            }
        }
        if(listApp.size()>0){
            insert listApp;
        }
    }

    //AMS 001083
    /**
     * controllo per impedire di mettere in chiusa persa un'opportunità se c'è un work order in lavorazione
     */
    public static void checkWOChiusaPersa(map<id,SBQQ__Quote__c> newMap, map<id, SBQQ__Quote__c> oldMap)
    {
        //check user
        User usr = [SELECT profile.Name, userRole.Name FROM User WHERE id = :System.UserInfo.getUserId()];
        String profileName = usr.profile.Name;
        String roleName = usr.userRole.Name;            
        map<id, list<workorder>> mapOppWo = new map<id, list<workorder>>();
        for(SBQQ__Quote__c quote : newMap.values())
        {
            system.debug(quote.StageName__c + ' '+ oldMap.get(quote.id).StageName__c);
            if(quote.StageName__c == 'Chiuse/Perse' && oldMap.get(quote.id).StageName__c != 'Chiuse/Perse' &&
              (!profileName.toLowerCase().contains('administrator') || !profileName.toLowerCase().contains('amministratore') || !roleName.toLowerCase().contains('sales support')))
            {
                mapOppWo.put(quote.SBQQ__Opportunity2__c, null);
            }
        }
        if(mapOppWo.keyset().size() > 0)
        {
            for(workorder wok : [select id, WRT_Opportunity__c from workorder where status != 'New' and WRT_Opportunity__c in :mapOppWo.keyset()])
            {
                if(mapOppWo.get(wok.WRT_Opportunity__c) != null)
                {
                    mapOppWo.get(wok.WRT_Opportunity__c).add(wok);
                }
                else
                {
                    mapOppWo.put(wok.WRT_Opportunity__c, new list<workorder>{wok});
                }
            }
            for(SBQQ__Quote__c quote : newMap.values())
            {
                if(mapOppWo.get(quote.SBQQ__Opportunity2__c) != null)
                {
                    quote.addError(System.Label.WRT_Opp_Error_ClosedLost);
                }
            }
        }
    }
    
    
}