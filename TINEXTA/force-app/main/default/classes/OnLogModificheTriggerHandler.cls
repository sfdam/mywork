public class OnLogModificheTriggerHandler {
    
    public static void mandaInApprovazioneWarrant(Map<Id, Approvazioni__c> input){
        
        Set<Id> Quo = new Set<Id>();
        Set<Id> Line = new Set<Id>();
        Set<Id> Fin = new Set<Id>();
        Set<Id> Con = new Set <Id>();
        Set<Id> Opz = new Set<Id>();
        Set<Id> Pag = new Set<Id>(); 
        
        for(Id i:input.keySet()){
            if(input.get(i).Quote__c != null && input.get(i).Creazione_da_Quote__c == true){
                Quo.add(input.get(i).Quote__c);
                system.debug('Salvo Quote');
            }
            if(input.get(i).Quote_Line__c != null && input.get(i).Approvazione_Legale_da_QLine__c == true){
                Line.add(input.get(i).Quote_Line__c);
                system.debug('Salvo Line');
            }
            if(input.get(i).Finanziamento__c!=null){
                Fin.add(input.get(i).Finanziamento__c);
                system.debug('Salvo Fin');
            }
            
            if(input.get(i).Condizione__c!=null){
                Con.add(input.get(i).Condizione__c);
                system.debug('Salvo Cond');
            }
            if(input.get(i).Condizione_Opzionale__c!=null){
                Opz.add(input.get(i).Condizione_Opzionale__c);
                system.debug('Salvo Opz');
            }
            if(input.get(i).Pagamento__c!=null){
                Pag.add(input.get(i).Pagamento__c);
                system.debug('Salvo Pag');
            }
        }
        
        
        List<SBQQ__Quote__c> quote = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> qline = new List<SBQQ__QuoteLine__c>();
        List<Finanziamenti__c> fina = new List<Finanziamenti__c>();
        List<Condizioni__c> cond = new List<Condizioni__c>();
        List<Condizione_Opzionale__c> opzi = new List<Condizione_Opzionale__c>();
        List<Pagamenti__c> paga = new List<Pagamenti__c>();
        
        
        
        if(Quo.size()>0){
            quote =([SELECT Id, Approvazione_al_legale__c, Approvazione_al_commerciale__c
                     FROM SBQQ__Quote__c
                     WHERE Id IN: Quo]);
        }
        Map<Id, SBQQ__Quote__c> NewQuote = new Map <Id, SBQQ__Quote__c>(quote);
        
        If(Line.size()>0){
            qline = ([SELECT Id, WRT_Approvazione_al_legale__c
                      FROM SBQQ__QuoteLine__c
                      WHERE Id In:Line]);
        }
        Map<Id,SBQQ__QuoteLine__c> NewLine = new Map<Id,SBQQ__QuoteLine__c>(qline);
        
        if(Fin.size()>0){
            fina=([SELECT Id,Quote_in_Approvazione_formula__c,Controllo_Approvazioni_in_attesa__c
                   FROM Finanziamenti__c
                   WHERE Id IN:Fin]);
        }
        
        Map<Id,Finanziamenti__c> NewFin = new Map<Id,Finanziamenti__c>(fina);
        
        if(Con.size()>0){
            cond=([SELECT Id,Quote_in_Approvazione_formula__c,Controllo_Approvazioni_in_attesa__c
                   FROM Condizioni__c
                   WHERE Id IN:Con]);
        }
        
        Map<Id,Condizioni__c> NewCon = new Map<Id,Condizioni__c>(cond);
        
        if(Opz.size()>0){
            opzi=([SELECT Id,Quote_in_Approvazione_formula__c,Controllo_Approvazioni_in_attesa__c
                   FROM Condizione_Opzionale__c
                   WHERE Id IN:Opz]);
        }
        Map<Id,Condizione_Opzionale__c> NewOpz = new Map<Id,Condizione_Opzionale__c>(opzi);
        
        if(Pag.size()>0){
            paga=([SELECT Id,Quote_in_Approvazione_formula__c,Controllo_Approvazioni_in_attesa__c,SwitchTrigger__c
                   FROM Pagamenti__c
                   WHERE Id IN:Pag]);
        }
        
        Map<Id,Pagamenti__c> NewPag = new Map<Id,Pagamenti__c>(paga);
        
        Boolean Check = false;
        Boolean Checkline= false;
        
        for(id n:NewQuote.keyset()){
            If(NewQuote.get(n).Approvazione_al_legale__c == true){
                NewQuote.get(n).Approvazione_al_legale__c = false;
                Check = true;
            }
            If(NewQuote.get(n).Approvazione_al_commerciale__c == true){
                NewQuote.get(n).Approvazione_al_commerciale__c = false;
                Check= true;
            }
        }
        for(id ql:NewLine.keyset()){
            If(NewLine.get(ql).WRT_Approvazione_al_legale__c == true){
                NewLine.get(ql).WRT_Approvazione_al_legale__c = false;
                Checkline = true;
            }
        }
        for(Id i:input.keySet()){
            for(id f:NewFin.keyset()){
                if(input.get(i).Finanziamento__c == NewFin.get(f).Id){
                    if(input.get(i).Approval_Step__c=='In approvazione'){
                        NewFin.get(f).Quote_in_Approvazione_formula__c=true;
                    }
                    if(input.get(i).Approval_Step__c=='Approvata'){
                        NewFin.get(f).Quote_in_Approvazione_formula__c=false;
                        NewFin.get(f).Controllo_Approvazioni_in_attesa__c=false;	
                    }
                    if(input.get(i).Approval_Step__c=='In attesa di approvazione'){
                        NewFin.get(f).Controllo_Approvazioni_in_attesa__c=true;
                        system.debug('update condizione per update');
                    }
                }
            }
        }
        
        for(Id i:input.keySet()){
            for(id f:NewCon.keyset()){
                if(input.get(i).Condizione__c == NewCon.get(f).Id){
                    if(input.get(i).Approval_Step__c=='In approvazione'){
                        NewCon.get(f).Quote_in_Approvazione_formula__c=true;
                    }
                    if(input.get(i).Approval_Step__c=='Approvata'){
                        NewCon.get(f).Quote_in_Approvazione_formula__c=false;
                        NewCon.get(f).Controllo_Approvazioni_in_attesa__c=false;	
                    }
                    if(input.get(i).Approval_Step__c=='In attesa di approvazione'){
                        NewCon.get(f).Controllo_Approvazioni_in_attesa__c=true;
                        system.debug('update condizione per update');
                    }
                }
            }
        }
        
        for(Id i:input.keySet()){
            for(id f:NewOpz.keyset()){
                if(input.get(i).Condizione_Opzionale__c == NewOpz.get(f).Id){
                    if(input.get(i).Approval_Step__c=='In approvazione'){
                        NewOpz.get(f).Quote_in_Approvazione_formula__c=true;
                    }
                    if(input.get(i).Approval_Step__c=='Approvata'){
                        NewOpz.get(f).Quote_in_Approvazione_formula__c=false;
                        NewOpz.get(f).Controllo_Approvazioni_in_attesa__c=false;	
                    }
                    if(input.get(i).Approval_Step__c=='In attesa di approvazione'){
                        NewOpz.get(f).Controllo_Approvazioni_in_attesa__c=true;
                        
                        system.debug('update condizione per update');
                    }
                }
            }
        }
        
        for(Id i:input.keySet()){
            for(id f:NewPag.keyset()){
                if(input.get(i).Pagamento__c == NewPag.get(f).Id){
                    if(input.get(i).Approval_Step__c=='In approvazione'){
                        NewPag.get(f).Quote_in_Approvazione_formula__c=true;
                    }
                    if(input.get(i).Approval_Step__c=='Approvata'){
                        NewPag.get(f).Quote_in_Approvazione_formula__c=false;
                        NewPag.get(f).Controllo_Approvazioni_in_attesa__c=false;	
                    }
                    if(input.get(i).Approval_Step__c=='In attesa di approvazione'){
                        NewPag.get(f).Controllo_Approvazioni_in_attesa__c=true;
                        NewPag.get(f).SwitchTrigger__c= !(NewPag.get(f).SwitchTrigger__c);
                        system.debug('update condizione per update');
                    }
                }
            }
        }
        
        
        try{
            If(Check==true){
                update NewQuote.values();
            }
            If(Checkline==true){
                update NewLine.values();
            }
            If(NewFin.size()>0){
                update NewFin.values();
            }
            If(NewCon.size()>0){
                update NewCon.values();
            }
            If(NewOpz.size()>0){
                update NewOpz.values();
            }
            If(NewPag.size()>0){
                update NewPag.values();
            }
            
        } catch (Exception e){
            System.debug('Si è verificato un problema: '+e.getMessage());	
        }
    }
    
    //metodo non più usato    
    public static void ApprovazioneForo2Legal (Map<Id,Approvazioni__c> oldmap, Map<Id,Approvazioni__c> newapp){
        Set<Id> Foro2 = New Set<Id>();
        List<Approvazioni__c> listaApprovazioni = new List<Approvazioni__c>();
        
        id rid = ([SELECT Id FROM RecordType WHERE SobjectType = 'Approvazioni__c' AND Name = 'Legale'  LIMIT 1]).id;
        
        
        //recupero tutte le approvazioni approvate con la check foro2
        for(Id i: newapp.keyset()){
            Approvazioni__c old = OldMap.get(newapp.get(i).id);
            if(old.Approval_Step__c != 'Approvata' && old.Approval_Step__c != newapp.get(i).Approval_Step__c
               && newapp.get(i).Approval_Step__c == 'Approvata' && newapp.get(i).Approvazione_foro_2__c == true
               && newapp.get(i).Canale_Approvativo__c == 'Commerciale'){
                   Foro2.add(newapp.get(i).id);
               }
        }
        
        
        Map<Id, Approvazioni__c> appMap = new Map<Id, Approvazioni__c>([SELECT Id, Quote__c FROM Approvazioni__c WHERE Id IN: Foro2]);
        
        
        //se approvata la commerciale, ne creo una legale
        for(Id a:appMap.keyset()){
            Approvazioni__c app = new Approvazioni__c(
                Quote__c= appMap.get(a).Quote__c,							
                Approval_Step__c='In approvazione',
                Name='Approvazione Legale',
                Approvazione_foro_2__c=true,
                RecordTypeId=rid);
            listaApprovazioni.add(app);
        }
        
        if(listaApprovazioni.size()>0){
            insert listaApprovazioni;
        }
    }
}