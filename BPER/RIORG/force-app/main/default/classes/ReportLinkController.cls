public without sharing class ReportLinkController {
    @AuraEnabled
    public static Map<String,Object> init(String idCed, String reportDevName){

        Map<String,Object> returnMap= new Map<String,Object>();
        system.debug('@@@@idced: '+idCed);
        if(String.isNotBlank(idCed)){
            List<ConfigUffPrivateDR__c> privList=[SELECT PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDUffPrivate__c=:idCed];
            if(privList.size()>0){
                User u = [SELECT Id, PTF_DirezioniRegionaliVisibili__c, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
                Set<String> setDR= new Set<String>(u.PTF_DirezioniRegionaliVisibili__c.split(', '));
                List<String> listDR= new List<String>(setDR);
                returnMap.put('private',listDR);
            }
            else{
                List<Account> accList=[SELECT Id, PTF_Capofila__c, RecordType.DeveloperName, PTF_IdCEDPadre__c, FinServ__BankNumber__c FROM Account WHERE PTF_IdCED__c=:idCed];
                if(accList.size()>0){
                    system.debug('@@@@accountlog: '+JSON.serialize(accList[0]));
                    if(accList[0].RecordType.DeveloperName=='AltraUnitaOrganizzativa'){
                        returnMap.put('cedFilter',accList[0].PTF_IdCEDPadre__c);
                        returnMap.put('capofila','false');
                    }
                    else if(accList[0].RecordType.DeveloperName!='AltraUnitaOrganizzativa'){
                        returnMap.put('cedFilter',idCed);
                        if(String.isNotBlank(accList[0].PTF_Capofila__c)){
                            returnMap.put('capofila','false');
                        }
                        else{
                            returnMap.put('capofila','true');
                        }
                    }
                    if(accList[0].FinServ__BankNumber__c=='05387'){
                        returnMap.put('banca','BPER');
                    }
                    else if(accList[0].FinServ__BankNumber__c=='01015'){
                        returnMap.put('banca','BDS');
                    }
                }
            }
            
        }
        
        List<Report> repList=[SELECT Id FROM Report WHERE DeveloperName=:reportDevName];
        if(repList.size()>0){
            returnMap.put('reportId',repList[0].Id);
        }
        return returnMap;
    }
    @AuraEnabled
    public static Id getId(String devName){
        List<Report> repList=[SELECT Id FROM Report WHERE DeveloperName=:devName];
        return repList[0].Id;
        
    }
    
}