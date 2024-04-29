/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-23-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-31-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger OnAccountTrigger on Account (before update,  after update) {

    if(Trigger.isAfter && Trigger.isUpdate && Batch_AccountLink.executeChangeStruttura){
        OnAccountTriggerHandler.changeStruttura(Trigger.new, Trigger.oldMap);
    }

    List<TriggerControl__c> t =[SELECT Name FROM TriggerControl__c WHERE Stream__c='Account' ];
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_AccountTrigger__c) return;

    if(Batch_AccountLink.skipAccountTrigger) return;
    if(f.isETL__c && t.size()>0 && t[0].Name=='CI' && !Batch_SpostaInResiduale.fireTrigger) return;
    /*if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV Account INSERT trigger.isBefore');
            //OnAccountTriggerHandler.emptyTW(Trigger.new);
            OnAccountTriggerHandler.setModelloDiServizio(Trigger.new, Trigger.oldMap, false);
            OnAccountTriggerHandler.setPTF_Assente(Trigger.new, null);
            OnAccountTriggerHandler.populateHierarchy(Trigger.new, null);
            OnAccountTriggerHandler.createNucleo(Trigger.new);
            OnAccountTriggerHandler.setTechnicalWallet(Trigger.new);
            OnAccountTriggerHandler.setPortafoglioAssegnato(Trigger.new,Trigger.oldMap, false);
        }
        
        if(trigger.isAfter){
            System.debug('SV Account INSERT trigger.isAfter');
            OnAccountTriggerHandler.updatePTFOnWallet(Trigger.newMap, Trigger.oldMap);
            OnAccountTriggerHandler.createBookMember(Trigger.new,null);
            //OnAccountTriggerHandler.setNdgCounter(Trigger.new, Trigger.oldMap, 'onInsert');
            OnAccountTriggerHandler.createDoppioPresidio(Trigger.new,null,'OnAfterInsert');
        }        
    }*/
    
    if(trigger.isUpdate){
        if(trigger.isBefore){
            System.debug('SV Account UPDATE trigger.isBefore');
            //OnAccountTriggerHandler.emptyTW(Trigger.new);
            OnAccountTriggerHandler.setTechnicalWallet(Trigger.new);
            OnAccountTriggerHandler.setPTF_Assente(Trigger.new, Trigger.oldMap);
            OnAccountTriggerHandler.setModelloDiServizio(Trigger.new, Trigger.oldMap, true);
            OnAccountTriggerHandler.setResiduale(Trigger.new, Trigger.oldMap);
            OnAccountTriggerHandler.populateHierarchy(Trigger.new, Trigger.oldMap);
            OnAccountTriggerHandler.deleteDoppioPresidio(Trigger.new,Trigger.oldMap);
            OnAccountTriggerHandler.setPortafoglioAssegnato(Trigger.new,Trigger.oldMap, true);
            OnAccountTriggerHandler.createNucleo(Trigger.new);

            //GPF S:43039 - Sportelli Leggeri
            OnAccountTriggerHandler.resetMiniWalletLookup(Trigger.new,Trigger.oldMap);
            //GPF E:43039 - Sportelli Leggeri

        }
        
        if(trigger.isAfter){
            System.debug('SV Account UPDATE trigger.isAfter');
            if(!f.isETL__c){
                OnAccountTriggerHandler.updatePTFOnWallet(Trigger.newMap, Trigger.oldMap);
            }
            
            //OnAccountTriggerHandler.setNdgCounter(Trigger.new, Trigger.oldMap, 'onUpdate');
            OnAccountTriggerHandler.createDoppioPresidio(Trigger.new,Trigger.oldMap,'OnAfterUpdate');
            OnAccountTriggerHandler.updateBookAndManagementMember(Trigger.new,Trigger.oldMap);
            if(!f.Disable_Integrazione_Anagrafe__c){
                OnAccountTriggerHandler.UpdateBranch(Trigger.new,Trigger.oldMap);
            }
            if(!f.isETL__c){
                
                OnAccountTriggerHandler.updateCampaignMember(Trigger.newMap,Trigger.oldMap);
            }
            
            
        }
    }

    /*if(trigger.isDelete){
        if(trigger.isAfter){
            System.debug('SV Account DELETE trigger.isAfter');
            OnAccountTriggerHandler.updatePTFOnWallet(Trigger.newMap, Trigger.oldMap);
            OnAccountTriggerHandler.setNdgCounter(Trigger.old, Trigger.oldMap, 'onDelete');
        }
    }*/
}