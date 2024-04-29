public class SegnalazioneTriggerHandler {

	public static void sla(List<Tracking_segnalazione__c> newTrackingSegnalazioni){
    	BusinessHours bh = [SELECT ID FROM BusinessHours WHERE Name='AMS'];
    
        for(Tracking_segnalazione__c s : newTrackingSegnalazioni) {
            if(s.Fine__c != null) {
                DateTime Fine = s.Fine__c;
                DateTime Inizio = s.Inizio__c;
                
                Long RespondDiff = BusinessHours.diff(bh.id, Inizio, Fine);
                Long mins = RespondDiff / 60000;
                Decimal hours = mins / 60;
                Decimal remainingMins = (mins - (hours * 60)) / 100;
        
                s.Durata_effettiva__c = hours + remainingMins;
                s.Durata_effettiva_Minuti__c = mins;
            }
        }
    }
    
    public static void handleDateSlaSegnalazioni(List<Segnalazione__c> newSegnalazioni) {
        BusinessHours bh = [SELECT ID FROM BusinessHours WHERE Name='AMS'];
        
        for(Segnalazione__c s : newSegnalazioni) {
            Segnalazione__c tmpS = s.clone(false,false,false,false);
            List<FormulaRecalcResult> results = Formula.recalculateFormulas(new List<Segnalazione__c>{tmpS});
            if(results[0].isSuccess()) {
                System.debug('@@@ priorit ' + tmpS.Priorit__c);
                System.debug('@@@ tmpS ' + tmpS.Tempo_di_risoluzione_minuti__c);
            }
            if(tmpS.Priorit__c != null) {
                AMS_setting__mdt setting = AMS_setting__mdt.getInstance(s.Tipologia__c.replaceAll(' ', '_')+'_'+tmpS.Priorit__c.replaceAll(' ','_'));
                System.debug('@@@ setting ' + setting);
                    
                if(setting != null) {
                    Long ms_ore_presa_in_carico = (setting.Ore_presa_in_carico__c * (1*60*60*1000)).longValue();
                    Datetime dtLimitePresaInCarico = BusinessHours.add(bh.Id,s.CreatedDate != null ? s.CreatedDate : System.now(),ms_ore_presa_in_carico);
                    Datetime dtLimiteRisoluzione;
                    Long ms_ore_risoluzione = (setting.Ore_risoluzione__c * (1*60*60*1000)).longValue();
                    if(s.Data_presa_in_carico__c == null) {
                        dtLimiteRisoluzione = BusinessHours.add(bh.Id,dtLimitePresaInCarico,ms_ore_risoluzione);
                    } else {
                        dtLimiteRisoluzione = BusinessHours.add(bh.Id,s.Data_presa_in_carico__c,ms_ore_risoluzione);
                    }
                    s.Data_limite_di_presa_in_carico__c = dtLimitePresaInCarico;
                    s.Data_limite_di_risoluzione__c = dtLimiteRisoluzione;
                    
                    if(s.Tipologia__c == 'Change Request' || s.Tipologia__c == 'Informazione') {
                        Long ms_ore_presa_in_carico_CR = (setting.Ore_presa_in_carico_CR__c * (1*60*60*1000)).longValue();
                        Datetime dtLimitePresaInCarico_CR = BusinessHours.add(bh.Id,s.CreatedDate != null ? s.CreatedDate : System.now(),ms_ore_presa_in_carico_CR);
                        s.Data_limite_di_presa_in_carico_CR__c = dtLimitePresaInCarico_CR;
                    }
                    
                    
                    if(tmpS.Tempo_di_risoluzione_minuti__c != null) {
                        Decimal mins = tmpS.Tempo_di_risoluzione_minuti__c;
                        Decimal hours = mins / 60;
                        System.debug('@@@ String.valueOf(hours) ' + String.valueOf(hours));
                        String decimalMinuti = '0';
                        try {
                            decimalMinuti = String.valueOf(hours).split('\\.')[1];
                        } catch (Exception e) {
                            System.debug('@@@ eccezione ' + decimalMinuti);
                        }
                        Decimal minuti = Decimal.valueOf('0.'+decimalMinuti);
                        System.debug('@@@ minuti ' + minuti);
                        Decimal remainingMins = minuti * 60 / 100;
                        s.Tempo_di_risoluzione__c = hours + remainingMins - minuti;   
                    }

                    if(tmpS.Tempo_gestione_segnalazione_minuti__c != null) {
                        Decimal mins = tmpS.Tempo_gestione_segnalazione_minuti__c;
                        Decimal hours = mins / 60;
                        System.debug('@@@ String.valueOf(hours) ' + String.valueOf(hours));
                        String decimalMinuti = '0';
                        try {
                            decimalMinuti = String.valueOf(hours).split('\\.')[1];
                        } catch (Exception e) {
                            System.debug('@@@ eccezione ' + decimalMinuti);
                        }
                        Decimal minuti = Decimal.valueOf('0.'+decimalMinuti);
                        System.debug('@@@ minuti ' + minuti);
                        Decimal remainingMins = minuti * 60 / 100;
                        s.Tempo_gestione_segnalazione__c = hours + remainingMins - minuti;
                    }

                    if(tmpS.Durata_Standby_minuti__c != null) {
                        Decimal mins = tmpS.Durata_Standby_minuti__c;
                        Decimal hours = mins / 60;
                        System.debug('@@@ String.valueOf(hours) ' + String.valueOf(hours));
                        String decimalMinuti = '0';
                        try {
                            decimalMinuti = String.valueOf(hours).split('\\.')[1];
                        } catch (Exception e) {
                            System.debug('@@@ eccezione ' + decimalMinuti);
                        }
                        Decimal minuti = Decimal.valueOf('0.'+decimalMinuti);
                        System.debug('@@@ minuti ' + minuti);
                        Decimal remainingMins = minuti * 60 / 100;
                        s.Tempo_Standby__c = hours + remainingMins - minuti;
                    }
                }
            }
        }
    }
    
}