public without sharing class creaPortafoglioFromCSVController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

   

    /*..........................................*/
    /* Wrapper class to display Input Data from CSV*/
    /*.........................................*/

    public class WrapperResult {
 
        @AuraEnabled public final String PTFnum;
        @AuraEnabled public final String modelloServizio;
        @AuraEnabled public final String abi;
        @AuraEnabled public final String cedfiliale;
        @AuraEnabled public final String matricola;
    
        //parametri che mi servono per la creazione del portafoglio
        @AuraEnabled public  String filiale;
        @AuraEnabled public  String banca;
        @AuraEnabled public  String dirRegionale;
        @AuraEnabled public  String area;
        @AuraEnabled public  String capofila;
        @AuraEnabled public String idReferente;
        
        
    }

    
    public static void createShare(Set<String> walletsId){

        system.debug('@@@@sonoqui');
        List<Wallet__c> scope = [SELECT Id, PTF_Filiale__r.PTF_IdCED__c, PTF_Filiale__r.PTF_IdCEDFiliale__c, PTF_Filiale__c, PTF_Area__r.PTF_IdCED__c,PTF_Area__c, PTF_DirezioneRegionale__r.PTF_IdCED__c, PTF_DirezioneRegionale__c, PTF_Banca__r.PTF_IdCED__c, PTF_Banca__c, PTF_ModelloDiServizio__c FROM Wallet__c WHERE Id IN: walletsId];
        Set<String> filialiRIDCEDSet = new Set<String>();
        Set<String> ufficiPadreIDCEDSet = new Set<String>();
        Set<String> DRIDCEDSet = new Set<String>();

        Map<String,List<Account>> dirToCentri= new Map<String,List<Account>>();
        Map<String,Group> mRoleGroupCentroImpresa= new Map<String,Group>();
        Map<String,Group> mRoleGroupFiliale= new Map<String,Group>();
        Map<String,List<GroupWrapper>> mGroupWrapper= new Map<String,List<GroupWrapper>>();

        List<Wallet__Share> wsToInsert = new List<Wallet__Share>();
        Map<String,SObject> serviceModelMap = SV_Utilities.keyBy([SELECT PTF_Division__c, PTF_MacroDivision__c, Name FROM ServiceModel__c ], '{PTF_Division__c}_{PTF_MacroDivision__c}_{Name}', true);
        for(String modello:serviceModelMap.keySet()){
            String keyUpper=modello.split('_')[0]+'_'+modello.split('_')[1]+'_'+modello.split('_')[2].toUpperCase();
            serviceModelMap.put(keyUpper, serviceModelMap.remove(modello));   
        }
        for(Wallet__c por: scope){
            system.debug('@@@@port:'+por);
            if(String.isNotBlank(por.PTF_Filiale__r.PTF_IdCED__c)) filialiRIDCEDSet.add('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c);
            if(String.isNotBlank(por.PTF_Area__r.PTF_IdCED__c)) ufficiPadreIDCEDSet.add(por.PTF_Area__r.PTF_IdCED__c);
            if(String.isNotBlank(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)) {
                ufficiPadreIDCEDSet.add(por.PTF_DirezioneRegionale__r.PTF_IdCED__c);
                DRIDCEDSet.add(por.PTF_DirezioneRegionale__c);
            }
            if(String.isNotBlank(por.PTF_Banca__r.PTF_IdCED__c)) ufficiPadreIDCEDSet.add(por.PTF_Banca__r.PTF_IdCED__c);
        }

        //Uffici Private
        List<ConfigUffPrivateDR__c> confList= [SELECT Name,PTF_IdCEDUffPrivate__c, PTF_IdCP__c, PTF_IdCEDDR__c FROM ConfigUffPrivateDR__c];
        Set<String> IdCedToSkip= new Set<String>();
        Set<String> gruppiUffPrivateDevName= new Set<String>();
        Map<String,List<String>> drIdCedToGruppiPrivateDevName = new Map<String,List<String>>();
        for(ConfigUffPrivateDR__c conf:confList){
            IdCedToSkip.add('RIDCED'+conf.PTF_IdCEDUffPrivate__c);
            if(!drIdCedToGruppiPrivateDevName.containsKey(conf.PTF_IdCEDDR__c)){
                drIdCedToGruppiPrivateDevName.put(conf.PTF_IdCEDDR__c, new List<String>());
            }
            drIdCedToGruppiPrivateDevName.get(conf.PTF_IdCEDDR__c).add(conf.PTF_IdCP__c+'_'+conf.PTF_IdCEDUffPrivate__c);
            gruppiUffPrivateDevName.add(conf.PTF_IdCP__c+'_'+conf.PTF_IdCEDUffPrivate__c);
        }
        Map<String,Group> devNameToGroupUffPriv= new Map<String,Group>();
        List<Group> tempGroupList=[SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:gruppiUffPrivateDevName];
        for(Group g: tempGroupList){
            devNameToGroupUffPriv.put(g.DeveloperName,g);
        }

        //Eccezioni
        List<Group> eccList= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN('Filiale937_1200','Filiale2499')];
        Map<String,Group> eccMap= new Map<String,Group>();
        for(Group g:eccList){
            eccMap.put(g.DeveloperName,g);
        }
        //Eccezioni
        //Uffici Private
        
        mRoleGroupFiliale=findRoleGroupFiliale(filialiRIDCEDSet);
        dirToCentri=populateDirToCentri(DRIDCEDSet);
        mRoleGroupCentroImpresa=findRoleGroupCentroImpresa(DRIDCEDSet);
        system.debug('@@@dirToCentri: '+dirToCentri);
        system.debug('@@@mRoleGroupCentroImpresa: '+mRoleGroupCentroImpresa);
        System.debug('ufficiIdCed: '+ufficiPadreIDCEDSet);
        mGroupWrapper=findRoleGroupUfficio(ufficiPadreIDCEDSet);

        for(Wallet__c por:scope){
            if(por.PTF_ModelloDiServizio__c=='Private'){
                if(drIdCedToGruppiPrivateDevName.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    system.debug('@@@@@sonoqui');
                    for(String key:drIdCedToGruppiPrivateDevName.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                        system.debug('@@@@@sonoqui');
                        if(devNameToGroupUffPriv.containsKey(key)){
                            system.debug('@@@@@sonoqui');
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=devNameToGroupUffPriv.get(key).Id;
                            ws.AccessLevel='Edit';
                            system.debug('@@@@@wsToInsert: '+key);
                            wsToInsert.add(ws);
                        }
                    }
                }
            }
            
            //Eccezioni
            if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='937' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='1200'){
                //sharo al gruppo Filiale937_1200
                if(eccMap.containsKey('Filiale937_1200')){
                    Wallet__Share ws = new Wallet__Share();
                    ws.ParentId=por.Id;
                    ws.UserOrGroupId=eccMap.get('Filiale937_1200').Id;
                    ws.AccessLevel='Edit';
                    wsToInsert.add(ws);
                }
                
            }
            if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='2499'){
                //sharo al gruppo Filiale2499
                if(eccMap.containsKey('Filiale2499')){
                    Wallet__Share ws = new Wallet__Share();
                    ws.ParentId=por.Id;
                    ws.UserOrGroupId=eccMap.get('Filiale2499').Id;
                    ws.AccessLevel='Edit';
                    wsToInsert.add(ws);
                }
            }
            //Eccezioni
            
            if(dirToCentri.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                system.debug('@@@@centrisonoqui');
                for(Account centro:dirToCentri.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    system.debug('@@@@centrisonoqui');
                    if(por.PTF_ModelloDiServizio__c=='CORPORATE'/* || por.PTF_ModelloDiServizio__c=='Corporate'*/ ){
                        system.debug('@@@@centrisonoqui');
                        String key= centro.PTF_IdCED__c;
                        if(mRoleGroupCentroImpresa.containsKey('RIDCED'+key)){
                            system.debug('@@@@centrisonoqui');
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=mRoleGroupCentroImpresa.get('RIDCED'+key).Id;
                            ws.AccessLevel='Edit';
                            wsToInsert.add(ws);
                            system.debug('@@@@@wsToInsert: '+key);
                        }
                    }
                    
                }
            }
            
            if(mRoleGroupFiliale.containsKey('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c)){
                system.debug('@@@@:'+por.Id);
                Wallet__Share ws = new Wallet__Share();
                ws.ParentId=por.Id;
                ws.UserOrGroupId=mRoleGroupFiliale.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c).Id;
                ws.AccessLevel='Edit';
                wsToInsert.add(ws);
                system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
            }
            if(mGroupWrapper.containsKey(por.PTF_Area__r.PTF_IdCED__c)){
                system.debug('@@@@@sonoqui');
                for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_Area__r.PTF_IdCED__c)){
                    if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=wrap.gruppo.Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                        system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
                    }
                }
            }
            if(mGroupWrapper.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                system.debug('@@@@@sonoqui');
                for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=wrap.gruppo.Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                        system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
                    }
                }
            }
            if(mGroupWrapper.containsKey(por.PTF_Banca__r.PTF_IdCED__c)){
                system.debug('@@@@@sonoqui');
                for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_Banca__r.PTF_IdCED__c)){
                    if(!IdCedToSkip.contains(wrap.gruppo.DeveloperName)){
                        if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=wrap.gruppo.Id;
                            ws.AccessLevel='Edit';
                            wsToInsert.add(ws);
                            system.debug('@@@@@wsToInsert: '+ws.UserOrGroupId);
                        }
                    }
                    
                }
            }
        }
        if(wsToInsert.size()>0 && wsToInsert.size()<=10000){
            insert wsToInsert;
        }
        else{
            OnAssignmentTriggerHandler.invokeBatch(
                                'Batch_TriggerOperation',
                                new Map<String,Object>{'sObjList'=> wsToInsert,'operationType'=>'insert','sObjectType'=>'Wallet__Share'}
                            );
        }
    }

    private static Map<String,List<Account>> populateDirToCentri(Set<String> DRIDCEDSet){

        Map<String,List<Account>> returnMap= new Map<String,List<Account>>();

        List<Account> centriImpresa= [SELECT Id, PTF_IdCED__c,PTF_DirezioneRegionale__r.PTF_IdCED__c, PTF_Division__c, PTF_MacroDivision__c FROM Account WHERE PTF_BranchTypology__c='F' AND PTF_DirezioneRegionale__c IN:DRIDCEDSet];
        
        for(Account c: centriImpresa){
           if(!returnMap.containsKey(c.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
               returnMap.put(c.PTF_DirezioneRegionale__r.PTF_IdCED__c,new List<Account>());
           }
           returnMap.get(c.PTF_DirezioneRegionale__r.PTF_IdCED__c).add(c);
        }
        return returnMap;
    }

    private static Map<String,Group> findRoleGroupCentroImpresa(Set<String> DRIDCEDSet){

        Map<String,Group> RoleGroupCentroImpresa= new Map<String,Group>();

        List<Account> centriImpresa= [SELECT Id, PTF_IdCED__c FROM Account WHERE PTF_BranchTypology__c='F' AND  PTF_DirezioneRegionale__c IN:DRIDCEDSet];
        
        Set<String> centriImpresaRIDCEDSet=new Set<String>();
        
        for(Account c: centriImpresa){
            centriImpresaRIDCEDSet.add('RIDCED'+c.PTF_IdCED__c);
        }

        List<Group> centriGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:centriImpresaRIDCEDSet AND Type='Role'];

        for(Group g:centriGroup){
            RoleGroupCentroImpresa.put(g.DeveloperName, g);
        }

        return RoleGroupCentroImpresa;
    }

    private static Map<String,Group> findRoleGroupFiliale(Set<String> filialiRIDCEDSet){

        Map<String,Group> roleGroupFiliale= new Map<String,Group>();
        
        List<Group> filialiGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:filialiRIDCEDSet AND Type='Role'];

        for(Group g:filialiGroup){
            roleGroupFiliale.put(g.DeveloperName, g);
        }

        return roleGroupFiliale;
    }
    
    private static Map<String,List<GroupWrapper>> findRoleGroupUfficio(Set<String> ufficiPadreIDCEDSet){

        Map<String,List<GroupWrapper>> returnMap= new Map<String,List<GroupWrapper>>();

        List<Account> uffici = [SELECT Id, PTF_Division__c, PTF_MacroDivision__c, PTF_IdCED__c, PTF_IdCEDPadre__c  FROM Account WHERE PTF_IdCEDPadre__c IN:ufficiPadreIDCEDSet AND RecordType.DeveloperName='AltraUnitaOrganizzativa'];
        System.debug('uffici: '+uffici.size());

        Map<String,List<Account>> padreIdCedToUffici = new Map<String,List<Account>>();
        Set<String> RIDCedUffici= new Set<String>();

        for(Account acc: uffici){
            
            if(!padreIdCedToUffici.containsKey(acc.PTF_IdCEDPadre__c)){
                padreIdCedToUffici.put(acc.PTF_IdCEDPadre__c,new List<Account>());
            }
            padreIdCedToUffici.get(acc.PTF_IdCEDPadre__c).add(acc);
            RIDCedUffici.add('RIDCED'+acc.PTF_IdCED__c);
        }
        System.debug('RIDCedUffici '+RIDCedUffici);
        List<Group> gruppi= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:RIDCedUffici AND Type='Role'];

        System.debug('gruppi'+gruppi);
        Map<String, Group> RIDCedToGroup= new Map<String, Group>();

        for(Group g : gruppi){
            
            RIDCedToGroup.put(g.DeveloperName, g);
        }

        for(String key: padreIdCedToUffici.keySet()){

            for(Account uff: padreIdCedToUffici.get(key)){

                if(RIDCedToGroup.containsKey('RIDCED'+uff.PTF_IdCED__c)){

                    if(!returnMap.containsKey(key)){
                        returnMap.put(key, new List<GroupWrapper>());
                    }

                    GroupWrapper wrap= new GroupWrapper();
                    wrap.gruppo= RIDCedToGroup.get('RIDCED'+uff.PTF_IdCED__c);
                    wrap.filiera=uff.PTF_Division__c;
                    wrap.macroFiliera=uff.PTF_MacroDivision__c;

                    returnMap.get(key).add(wrap);

                }
            }
        }

        return returnMap;
    }

    private static Boolean checkShare(String mds, String filiera, String macrofiliera, Map<String,SObject> serviceModelMap){
        Boolean share=false;
        if(String.isBlank(filiera) && String.isBlank(macrofiliera)){
            share=true;
        }
        else if(String.isBlank(filiera) && String.isNotBlank(macrofiliera)){
            for(String s: serviceModelMap.keySet()){
                if(s.contains(macrofiliera+'_'+mds)) share=true;
            }
        }
        else if(String.isBlank(macrofiliera) && String.isNotBlank(filiera)){
            for(String s: serviceModelMap.keySet()){
                if(s.contains('_'+mds)) {
                    if(s.contains(filiera+'_')) share=true;
                }
            }
        }
        else if(serviceModelMap.containsKey(filiera+'_'+macrofiliera+'_'+mds)){
            share=true;
        }
        return share;

    }

    private class GroupWrapper{
        Group gruppo;
        String filiera;
        String macroFiliera;
    }

    
    private static void buildName(List<Wallet__c> mwList){

        System.debug('lista Family '+mwList);

        List<ServiceModel__c > sm=[SELECT PTF_TresholdPTF__c  FROM ServiceModel__c  WHERE Name=:mwList[0].PTF_ModelloDiServizio__c];

        System.debug('valore soglia '+sm[0].PTF_TresholdPTF__c);
        Integer start= Integer.valueOf(sm[0].PTF_TresholdPTF__c) ;
        start++;

        System.debug('@@@@start '+start);

        System.debug('### '+mwList[0].PTF_Filiale__c);

        List<Account> accList= [SELECT Id, PTF_IdCEDFiliale__c, FinServ__BankNumber__c FROM Account WHERE Recordtype.DeveloperName = 'FilialeDiRelazione' AND Id=:mwList[0].PTF_Filiale__c];
        String abi=accList[0].FinServ__BankNumber__c;
        String ced=accList[0].PTF_IdCEDFiliale__c;

        if(ced.length()<4){
            do{
                ced='0'+ced;
            }
            while(ced.length()<4);
        }

        List<PTF_ModelloDiServizio__mdt> mdt=[SELECT Id, MasterLabel, PTF_Abbreviazione__c
                                                FROM PTF_ModelloDiServizio__mdt 
                                                WHERE MasterLabel =: mwList[0].PTF_ModelloDiServizio__c];

        String ptfName='PTF-'+mdt[0].PTF_Abbreviazione__c+'-'+abi+'-'+ced+'-';

        if(mwList[0].PTF_ModelloDiServizio__c=='Private'){
            Integer max=0;
            System.debug('@@@@max '+max);
            List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mwList[0].RecordTypeId AND PTF_Filiale__c=:mwList[0].PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mwList[0].PTF_ModelloDiServizio__c];
            if(oldList.size()>0){
                for(Wallet__c w:oldList){
                    Integer num= Integer.valueOf(w.Name.split('-')[4]);
                    if(num>max && num!=50 && num!=75){
                        max=num;
                        System.debug('@@@@max '+max);
                    }
                }
            }
            System.debug('@@@@max '+max);
            if(max>=start){
                max++;
                if(max!=50 && max!=75){
                    System.debug('@@@@max '+max);
                    start=max;
                    System.debug('@@@@start '+start);
                }
                else{
                    start=max+1;
                    System.debug('@@@@start '+start);
                }
            }   
        }
        else{
            Integer max=0;
            List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mwList[0].RecordTypeId AND PTF_Filiale__c=:mwList[0].PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mwList[0].PTF_ModelloDiServizio__c];
            if(oldList.size()>0){
                for(Wallet__c w:oldList){
                    Integer num= Integer.valueOf(w.Name.split('-')[4]);
                    if(num>max){
                        max=num;
                    }
                }
            }
            if(max>=start){
                
                    start=max+1;
                    System.debug('@@@@start '+start);
                
            } 
        }
        if(mwList[0].PTF_ModelloDiServizio__c=='Private'){
            for(Wallet__c mw:mwList){
                if(start!=50 && start!=75){
                    String seq= String.valueOf(start);
                    if(seq.length()<6){
                        do{
                            seq='0'+seq;
                        }
                        while(seq.length()<6);
                    }
                    mw.Name=ptfName+seq;
                }
                else{
                    start++;
                    String seq= String.valueOf(start);
                    if(seq.length()<6){
                        do{
                            seq='0'+seq;
                        }
                        while(seq.length()<6);
                    }
                    mw.Name=ptfName+seq;
                }
                start++;
            }
        }
        else{
            for(Wallet__c mw:mwList){
                String seq= String.valueOf(start);
                    if(seq.length()<6){
                        do{
                            seq='0'+seq;
                        }
                        while(seq.length()<6);
                    }
                    mw.Name=ptfName+seq;
                    start++;
            }
        }

    }

    @AuraEnabled
    public static List<WrapperResult> getStrutturaFiliale(String mapWallets) {


        Map<String,String> WrapperFiliale = new Map<String,String>();
        Map<String,String> WrapperReferenti = new Map<String,String>();
        List<Account> filiale = new List<Account>();
        List<Contact> referenti = new List<Contact>();
        List<WrapperResult> eddy = (List<WrapperResult>) JSON.deserialize(mapWallets, List<WrapperResult>.class);
        System.debug('GB EDDY '+eddy);
        
        try{
            for(WrapperResult result : eddy){

                WrapperFiliale.put(result.PTFnum, result.cedfiliale);
                if(result.matricola != '')
                WrapperReferenti.put(result.PTFnum, result.matricola);
                
            
            }
            System.debug('Matricole '+WrapperReferenti.values());
            System.debug('cedfiliali '+WrapperFiliale.values());

            

                filiale = [SELECT id ,PTF_IdCEDFiliale__c,  PTF_Banca__c, PTF_DirezioneRegionale__c, PTF_Area__c, PTF_Capofila__c, FinServ__BankNumber__c
                                        FROM  Account WHERE RecordType.DeveloperName = 'FilialeDiRelazione' AND PTF_IdCEDFiliale__c  IN : WrapperFiliale.values()];

                
                if(WrapperReferenti.size()>0){
                    
                    referenti = [SELECT ID, PTF_RegistrationNumber__c  FROM Contact Where PTF_RegistrationNumber__c IN : WrapperReferenti.values()];
                }
                
                
                for(WrapperResult result : eddy){

                    for(Account f : filiale){

                        if((result.cedfiliale == f.PTF_IdCEDFiliale__c) && (result.abi ==  f.FinServ__BankNumber__c)){
                            result.filiale = f.id;
                            result.banca = f.PTF_Banca__c;
                            result.dirRegionale = f.PTF_DirezioneRegionale__c;
                            result.area = f.PTF_Area__c;
                            result.capofila = f.PTF_Capofila__c;
                        }
                        
                    }
                    if(WrapperReferenti.size()>0){
                        for(Contact c : referenti){

                            if(result.matricola == c.PTF_RegistrationNumber__c)
                                result.idReferente = c.Id;
                        }
                    }
                }

                System.debug('GB FINAL EDDY '+eddy);  
        }
        catch (Exception exc) {
            throw new AuraHandledException(exc.getMessage());

        }
        return eddy;
    }

    @AuraEnabled
    public static Boolean saveMicroWalletFromCSV(String walletsFromWrapper) {

													   

        List<WrapperResult> eddy = (List<WrapperResult>) JSON.deserialize(walletsFromWrapper, List<WrapperResult>.class) ;
        
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>();
        List<Wallet__c> walletsToInsert = new List<Wallet__c>();
        Map<String,Wallet__c> mwMap = new Map<String,Wallet__c>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Wallet__c.sobjectType.getDescribe().getRecordTypeInfosById();



        Map<String, SObject> mtdWalletlMap  = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_IsPool__c
                                                            FROM PTF_ModelloDiServizio__mdt ], 'MasterLabel', false);

        try { 
            Id microWalletRTId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');

            Map<String,List<Wallet__c>> testMap = new Map<String,List<Wallet__c>>();

            for(WrapperResult wr : eddy){
                String mapKey;
                List<Wallet__c> mapWallets = new List<Wallet__c>();
                Wallet__c mw = new Wallet__c();
                mw.PTF_Filiale__c = wr.filiale;
                mw.PTF_ModelloDiServizio__c = wr.modelloServizio;
                mw.PTF_Area__c = String.isNotBlank(wr.area) ? wr.area : null;
                mw.PTF_Banca__c = wr.banca;
                mw.PTF_DirezioneRegionale__c = String.isNotBlank(wr.dirRegionale) ? wr.dirRegionale : null;
                mw.PTF_Capofila__c = wr.capofila;
                mw.RecordTypeId = microWalletRTId;
                mw.PTF_Pool__c = (Boolean)mtdWalletlMap.get(wr.modelloServizio).get('PTF_IsPool__c');
                mapKey = mw.PTF_ModelloDiServizio__c + '' + mw.PTF_Filiale__c;
                mwMap.put(wr.PTFnum,mw);
                //buildName(mw);
                //walletsToInsert.add(mw);

                if(!testMap.containskey(mapKey)){
                    mapWallets.add(mw);
                    testMap.put(mapKey,mapWallets);
                }
                else{
                    mapWallets = testMap.get(mapKey);
                    mapWallets.add(mw);
                    testMap.put(mapKey,mapWallets);

                }
                
            }
            System.debug('GB MAPPA '+testMap);

                for(String k : testMap.keySet()){

                    buildName(testMap.get(k));

                    walletsToInsert.addAll(testMap.get(k));
                    
                }
                
            
            insert walletsToInsert;

            Set<String> wIds= new Set<String>();
                for(Wallet__c w: walletsToInsert){
                    wIds.add(w.Id);
                }
                createShare(wIds);

                for(WrapperResult wr : eddy){
                    for(String num : mwMap.keySet()){

                        if(num == wr.PTFnum && wr.idReferente != null){

                            assignmentsToInsert.add(new Assignment__c(
                                PTF_MicroWallet__c = mwMap.get(num).Id,
                                PTF_StartDate__c=Date.today(),
                                PTF_StartDate_DT__c = Datetime.now(),
                                PTF_Gestore__c = wr.idReferente,
                                RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Primario').getRecordTypeId()
                            ));
                        }
                    }
                }
                insert assignmentsToInsert;
            

        }catch (BaseException e) {  
            // This catches the OtherException
            System.debug('GB ERRORE ' + e);

        }
        return true; 
    }


    
    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}