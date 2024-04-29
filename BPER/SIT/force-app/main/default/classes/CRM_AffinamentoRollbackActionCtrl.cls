public with sharing class CRM_AffinamentoRollbackActionCtrl {
    

    @AuraEnabled
    public static boolean setRollback(String recordIdCM){
        System.debug('setRollback Start: '+recordIdCM);
        try{

            CampaignMember cm = [SELECT id, name, status, Motivo_Affinamento__c, CRM_NominativoUtente__c, CRM_NoteAffinamento__c,
            Campaign.CRM_DataFineAffinamento__c, Campaign.CRM_PrevistoAffinamento__c
            FROM CampaignMember WHERE id=:recordIdCM];

            if(cm.campaign.CRM_PrevistoAffinamento__c && Date.today()<=cm.Campaign.CRM_DataFineAffinamento__c){
               
                cm.Status = 'Da contattare';
                cm.Motivo_Affinamento__c ='';
                cm.CRM_NominativoUtente__c='';
                cm.CRM_NoteAffinamento__c='';
    
                update cm;
                return true;
            }else{
                throw new AuraHandledException('Non è possibile ripristinare il cliente in campagna - Campagna non più affinabile');
                
            }
            

        }catch(AuraHandledException e){
            throw new AuraHandledException('Non è possibile ripristinare il cliente in campagna');
            
        }
        catch (Exception ex){
            System.debug('Exception: '+ex.getMessage());
            return false;
        }
        
    }
}