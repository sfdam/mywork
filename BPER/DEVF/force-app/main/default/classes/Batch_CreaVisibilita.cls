/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 05-16-2022
 * @last modified by  : simone.viglianti@tengroup.it
**/

/** 
* Auhtor		:	Alessandro Lumaca
* Label         :   CR 60703
* Modify Date	:	2022-10-22
* Modify		:	Gestione profili
***/
global class Batch_CreaVisibilita implements Database.Batchable<sObject>, Database.stateful, IRunner {
    private static final String COD_CLASSE = 'GR005';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_CreaVisibilita';

    private class GroupWrapper{
        Group gruppo;
        String filiera;
        String macroFiliera;
    }

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);
    global Map<String,SObject> serviceModelMap = SV_Utilities.keyBy([SELECT PTF_Division__c, PTF_MacroDivision__c, Name FROM ServiceModel__c ], '{PTF_Division__c}_{PTF_MacroDivision__c}_{Name}', true);
    
    global Integer recordElab = 0;
    global Integer recordCreati=0;
    global Integer recordEliminati=0;
    global Boolean errorOnCreate = false;
    global String testoMail ='';

    private List<String> queryFields = new List<String> {
        'Id',
        'PTF_Filiale__r.PTF_IdCED__c',
        'PTF_Filiale__r.PTF_IdCEDFiliale__c',
        'PTF_Filiale__r.PTF_IDCEDUffPrivate__c',
        'PTF_Filiale__c',
        'PTF_Area__r.PTF_IdCED__c',
        'PTF_Area__c',
        'PTF_DirezioneRegionale__r.PTF_IdCED__c',
        'PTF_DirezioneRegionale__c',
        'PTF_Banca__r.PTF_IdCED__c',
        'PTF_Banca__r.FinServ__BankNumber__c',
        'PTF_Banca__c',
        'PTF_ModelloDiServizio__c',
        //CR 52359 SV Start
        'PTF_UffPrivate__r.PTF_IdCED__c',
        'PTF_UffPrivate__c'
        //CR 52359 end
    };

    // CR 60703 -- Gestione profili
    global static Map<String, String> viewAllMMDSMap{
        get{
            if(viewAllMMDSMap != null) return viewAllMMDSMap;
            viewAllMMDSMap = new Map<String, String>();
            for(Group gr : [
                SELECT Id, DeveloperName 
                FROM   Group 
                WHERE  DeveloperName LIKE 'ViewAll%_%'
                    AND Type = 'Regular'
            ]) {
                viewAllMMDSMap.put(gr.DeveloperName, gr.Id);
            }
            return viewAllMMDSMap;
        }set;
    }
    // END CR 60703
    

    global void initRunner(List<ScheduledJob__c> schedules) {
        this.sj.addAll(schedules);
    }

    global static Map<String, String> filialeVirtualeGroupMap {
        get{
            if(filialeVirtualeGroupMap != null){
                return filialeVirtualeGroupMap;
            }

            filialeVirtualeGroupMap = new Map<String, String>();
            Map<String, String> idcedFittiziaMap = new Map<String, String>();
            for(Struttura_Banca__c sb : [SELECT Id, IdCed__c, IDCed_Fittizia__c FROm STRUTTURA_BANCA__c WHERE IDCed_Fittizia__c  != '' AND Codice_Filiale__c IN ('937', '1200','1201')]){
                // filialeVirtualeGroupMap.put(sb.IdCed__c, sb.IDCed_Fittizia__c);
                idcedFittiziaMap.put('RIDCED'+sb.IDCed_Fittizia__c, sb.IdCed__c);
            }

            for(Group gr : [SELECT ID, DeveloperName FROM Group WHERE DeveloperName IN: idcedFittiziaMap.keySet()]){
                
                filialeVirtualeGroupMap.put(idcedFittiziaMap.get(gr.DeveloperName), gr.Id);
            }
            return filialeVirtualeGroupMap;
        }set;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        for(String modello:serviceModelMap.keySet()){
            String keyUpper=modello.split('_')[0]+'_'+modello.split('_')[1]+'_'+modello.split('_')[2].toUpperCase();
            serviceModelMap.put(keyUpper, serviceModelMap.remove(modello));   
        }

        String query = 'SELECT '+String.join(queryFields, ',')+' FROM Wallet__c WHERE PTF_DeletionDate__c = NULL';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Wallet__c> scope){
        
        Set<String> filialiRIDCEDSet = new Set<String>();
        Set<String> ufficiPadreIDCEDSet = new Set<String>();
        //Set<String> DRIDCEDSet = new Set<String>();
        
        /*Map<String,List<Account>> dirToCentri= new Map<String,List<Account>>();
        Map<String,Group> mRoleGroupCentroImpresa= new Map<String,Group>();
        Map<String,Group> mRoleGroupFiliale= new Map<String,Group>();*/
        Map<String,Group> mRoleGroupFilialeMDS= new Map<String,Group>();
        //NEW UFF PRIVATE
        Set<String> uffPrivateRIDCEDSet = new Set<String>();
        Map<String,Group> mRoleGroupUffPrivate= new Map<String,Group>();
        //NEW UFF PRIVATE
        Map<String,List<GroupWrapper>> mGroupWrapper= new Map<String,List<GroupWrapper>>();
        List<String> scopeIds = new List<String>();
        List<Wallet__Share> wsToInsert = new List<Wallet__Share>();

        try{
            recordElab += scope.size();
            for(Wallet__c por: scope){ 
                if(String.isNotBlank(por.PTF_Filiale__r.PTF_IdCED__c)) filialiRIDCEDSet.add('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c);
                //NEW UFF PRIVATE //CR 52359 SV start
                if(String.isNotBlank(por.PTF_UffPrivate__r.PTF_IdCED__c)) {
                    uffPrivateRIDCEDSet.add('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c);
                }
                //NEW UFF PRIVATE // CR 52359 end
                if(String.isNotBlank(por.PTF_Area__r.PTF_IdCED__c)) ufficiPadreIDCEDSet.add(por.PTF_Area__r.PTF_IdCED__c);
                if(String.isNotBlank(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)) {
                    ufficiPadreIDCEDSet.add(por.PTF_DirezioneRegionale__r.PTF_IdCED__c);
                    //DRIDCEDSet.add(por.PTF_DirezioneRegionale__c);
                }
                if(String.isNotBlank(por.PTF_Banca__r.PTF_IdCED__c)) ufficiPadreIDCEDSet.add(por.PTF_Banca__r.PTF_IdCED__c);
                scopeIds.add(por.Id);
            }
            //Eccezioni
            List<Group> eccList= [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN('Filiale937_1200','Filiale2499')];
            Map<String,Group> eccMap= new Map<String,Group>();
            for(Group g:eccList){
                eccMap.put(g.DeveloperName,g);
            }
            //Eccezioni

            //Forzatura
            Set<String> forzSet= SV_Utilities.getSet([SELECT Id FROM Group WHERE Type='Regular' AND DeveloperName Like 'DR%'], 'Id');
            //Forzatura
            Map<String,SObject> wsMap= SV_Utilities.keyBy([SELECT Id, UserOrGroupId, ParentId 
                                                           FROM Wallet__Share 
                                                           WHERE ParentId IN:scopeIds AND RowCause='Manual' AND UserOrGroupId NOT IN:forzSet
                                                          ], '{UserOrGroupId}_{ParentId}', true);
            for(String key:wsMap.keySet()){
                if(key.startsWith('005')){
                    wsMap.remove(key);
                }
            }


            
            //Uffici Private
            /*List<ConfigUffPrivateDR__c> confList= [SELECT Name,PTF_IdCEDUffPrivate__c, PTF_IdCP__c, PTF_IdCEDDR__c FROM ConfigUffPrivateDR__c];
            Set<String> gruppiUffPrivateDevName= new Set<String>();
            Set<String> IdCedToSkip= new Set<String>();
            Map<String,List<String>> drIdCedToGruppiPrivateDevName = new Map<String,List<String>>();
            //NEW UFF PRIVATE
            IdCedToSkip.addAll(uffPrivateRIDCEDSet);
            //NEW UFF PRIVATE
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
            }*/
            //Uffici Private

            // mRoleGroupFiliale=findRoleGroupFiliale(filialiRIDCEDSet);
            //NEW UFF PRIVATE
            mRoleGroupUffPrivate=findRoleGroupUffPrivate(uffPrivateRIDCEDSet);
            //NEW UFF PRIVATE
            mRoleGroupFilialeMDS=findRoleGroupFilialeMDS(filialiRIDCEDSet);
            
            //dirToCentri=populateDirToCentri(DRIDCEDSet);
            //mRoleGroupCentroImpresa=findRoleGroupCentroImpresa(DRIDCEDSet);
            System.debug('ufficiIdCed: '+ufficiPadreIDCEDSet);
            mGroupWrapper=findRoleGroupUfficio(ufficiPadreIDCEDSet);

            System.debug('DK mGroupWrapper: ' + JSON.serialize(mGroupWrapper));

            for(Wallet__c por:scope){
                if(por.PTF_ModelloDiServizio__c=='Private'){
                    //NEW UFF PRIVATE
                    /*if(por.PTF_Banca__r.FinServ__BankNumber__c == '01015'){
                    //NEW UFF PRIVATE
                        if(drIdCedToGruppiPrivateDevName.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                            for(String key:drIdCedToGruppiPrivateDevName.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                                if(devNameToGroupUffPriv.containsKey(key)){
                                    if(wsMap.containsKey(devNameToGroupUffPriv.get(key).Id+'_'+por.Id)){
                                        wsMap.remove(devNameToGroupUffPriv.get(key).Id+'_'+por.Id);
                                    }
                                    else{
                                        Wallet__Share ws = new Wallet__Share();
                                        ws.ParentId=por.Id;
                                        ws.UserOrGroupId=devNameToGroupUffPriv.get(key).Id;
                                        ws.AccessLevel='Edit';
                                        wsToInsert.add(ws);
                                    }
                                    
                                }
                            }
                        }
                    }
                    //NEW UFF PRIVATE CR 52359 SV start
                    else{*/
                        if(mRoleGroupUffPrivate.containsKey('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c)){
                            if(wsMap.containsKey(mRoleGroupUffPrivate.get('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c).Id+'_'+por.Id)){
                                wsMap.remove(mRoleGroupUffPrivate.get('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c).Id+'_'+por.Id);
                            }
                            else{
                                Wallet__Share ws = new Wallet__Share();
                                ws.ParentId=por.Id;
                                ws.UserOrGroupId=mRoleGroupUffPrivate.get('RIDCED'+por.PTF_UffPrivate__r.PTF_IdCED__c).Id;
                                ws.AccessLevel='Edit';
                                wsToInsert.add(ws);
                            }
                        }
                    // }
                    //NEW UFF PRIVATE // CR 52359 SV end
                }
                
                //Eccezioni
                /*if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='937' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='1200'){ 
                    //sharo al gruppo Filiale937_1200
                   
                    if(eccMap.containsKey('Filiale937_1200')){
                        if(wsMap.containsKey(eccMap.get('Filiale937_1200').Id+'_'+por.Id)){
                            wsMap.remove(eccMap.get('Filiale937_1200').Id+'_'+por.Id);
                        }
                        else{
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=eccMap.get('Filiale937_1200').Id;
                            ws.AccessLevel='Edit';
                            wsToInsert.add(ws);
                        }
                        
                    }
                    
                }*/
                System.debug('por.PTF_Filiale__r.PTF_IdCEDFiliale__c :' + por.PTF_Filiale__r.PTF_IdCEDFiliale__c);
                if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c=='2499'){ 
                    //sharo al gruppo Filiale2499
                    if(eccMap.containsKey('Filiale2499')){
                        if(wsMap.containsKey(eccMap.get('Filiale2499').Id+'_'+por.Id)){
                            wsMap.remove(eccMap.get('Filiale2499').Id+'_'+por.Id);
                        }
                        else{
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=eccMap.get('Filiale2499').Id;
                            ws.AccessLevel='Edit';
                            wsToInsert.add(ws);
                        }
                        
                    }
                }
                //Eccezioni
                
                /*if(dirToCentri.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    for(Account centro:dirToCentri.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                        if(por.PTF_ModelloDiServizio__c=='CORPORATE' || por.PTF_ModelloDiServizio__c=='Corporate' ){
                            String key= centro.PTF_IdCED__c;
                            if(mRoleGroupCentroImpresa.containsKey('RIDCED'+key)){
                                if(wsMap.containsKey(mRoleGroupCentroImpresa.get('RIDCED'+key).Id+'_'+por.Id)){
                                    wsMap.remove(mRoleGroupCentroImpresa.get('RIDCED'+key).Id+'_'+por.Id);
                                }
                                else{
                                    Wallet__Share ws = new Wallet__Share();
                                    ws.ParentId=por.Id;
                                    ws.UserOrGroupId=mRoleGroupCentroImpresa.get('RIDCED'+key).Id;
                                    ws.AccessLevel='Edit';
                                    wsToInsert.add(ws);
                                }
                                
                            }
                        }
                        
                    }
                }*/
                
                //COMMENTED BY DK 30/07
                /*if(mRoleGroupFiliale.containsKey('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c)){
                    if(wsMap.containsKey(mRoleGroupFiliale.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c).Id+'_'+por.Id)){
                        wsMap.remove(mRoleGroupFiliale.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c).Id+'_'+por.Id);
                    }
                    else{
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=mRoleGroupFiliale.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c).Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                    }
                    
                }*/
                //COMMENTED BY DK 30/07
                // START DK 30/07 - VISIBILITA PORTAFOGLI 
                if(mRoleGroupFilialeMDS.containsKey('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c + '_' + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_NameAbbreviation__c)){
                    if(wsMap.containsKey(mRoleGroupFilialeMDS.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c + '_' + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_NameAbbreviation__c).Id+'_'+por.Id)){
                        wsMap.remove(mRoleGroupFilialeMDS.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c + '_' + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_NameAbbreviation__c).Id+'_'+por.Id);
                    }
                    else{
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId=por.Id;
                        ws.UserOrGroupId=mRoleGroupFilialeMDS.get('RIDCED'+por.PTF_Filiale__r.PTF_IdCED__c + '_' + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_NameAbbreviation__c).Id;
                        ws.AccessLevel='Edit';
                        wsToInsert.add(ws);
                    }

                    // START DK 02/02 - VISIBILITA PORTAFOGLI KCI
                    if(por.PTF_Filiale__r.PTF_IdCEDFiliale__c == '937' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c == '1200' || por.PTF_Filiale__r.PTF_IdCEDFiliale__c == '1201'){
                        
                        if(wsMap.containsKey(filialeVirtualeGroupMap.get(por.PTF_Filiale__r.PTF_IdCed__c)+'_'+por.Id)){
                            wsMap.remove(filialeVirtualeGroupMap.get(por.PTF_Filiale__r.PTF_IdCed__c)+'_'+por.Id);
                        }
                        else{
                            Wallet__Share ws = new Wallet__Share();
                            ws.ParentId=por.Id;
                            ws.UserOrGroupId=filialeVirtualeGroupMap.get(por.PTF_Filiale__r.PTF_IdCed__c);
                            ws.AccessLevel='Edit';
                            wsToInsert.add(ws);
                        }
                    }
                    // START DK 02/02 - VISIBILITA PORTAFOGLI KCI
                    
                }
                
                // END DK 30/07 - VISIBILITA PORTAFOGLI
                if(mGroupWrapper.containsKey(por.PTF_Area__r.PTF_IdCED__c)){
                    for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_Area__r.PTF_IdCED__c)){
                        if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                            if(wsMap.containsKey(wrap.gruppo.Id+'_'+por.Id)){
                                wsMap.remove(wrap.gruppo.Id+'_'+por.Id);
                            }
                            else{
                                Wallet__Share ws = new Wallet__Share();
                                ws.ParentId=por.Id;
                                ws.UserOrGroupId=wrap.gruppo.Id;
                                ws.AccessLevel='Edit';
                                wsToInsert.add(ws);
                            }
                            
                        }
                    }
                }
                if(mGroupWrapper.containsKey(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                    for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_DirezioneRegionale__r.PTF_IdCED__c)){
                        if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                            if(wsMap.containsKey(wrap.gruppo.Id+'_'+por.Id)){
                                wsMap.remove(wrap.gruppo.Id+'_'+por.Id);
                            }
                            else{
                                Wallet__Share ws = new Wallet__Share();
                                ws.ParentId=por.Id;
                                ws.UserOrGroupId=wrap.gruppo.Id;
                                ws.AccessLevel='Edit';
                                wsToInsert.add(ws);
                            }
                            
                        }
                    }
                }
                if(mGroupWrapper.containsKey(por.PTF_Banca__r.PTF_IdCED__c)){
                    for(GroupWrapper wrap:mGroupWrapper.get(por.PTF_Banca__r.PTF_IdCED__c)){
                        if(!idCedUffPrivateSet.contains(wrap.gruppo.DeveloperName)){
                            if(checkShare(por.PTF_ModelloDiServizio__c.toUpperCase() , wrap.filiera, wrap.macroFiliera, serviceModelMap)){
                                if(por.PTF_ModelloDiServizio__c!='LARGE CORPORATE'){

                                    if(wsMap.containsKey(wrap.gruppo.Id+'_'+por.Id)){
                                        wsMap.remove(wrap.gruppo.Id+'_'+por.Id);
                                    }
                                    else{
                                        Wallet__Share ws = new Wallet__Share();
                                        ws.ParentId=por.Id;
                                        ws.UserOrGroupId=wrap.gruppo.Id;
                                        ws.AccessLevel='Edit';
                                        wsToInsert.add(ws);
                                    }
                                }
								
                            }
                        }
                        
                    }
                }
                // CR 60703 -- Gestione profili
                if(viewAllMMDSMap.containsKey('ViewAll_' + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_Division__c)) { 
                    if(wsMap.containsKey(viewAllMMDSMap.get('ViewAll_' 
                        + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_Division__c) + '_' + por.Id)){
                        wsMap.remove(viewAllMMDSMap.get('ViewAll_' +
                        MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_Division__c) + '_' + por.Id);
                    } else {
                        Wallet__Share ws = new Wallet__Share();
                        ws.ParentId = por.Id;
                        ws.UserOrGroupId = 
                            viewAllMMDSMap.get('ViewAll_' 
                                                + MDSMap.get(por.PTF_ModelloDiServizio__c.toUpperCase()).PTF_Division__c);
                        ws.AccessLevel = 'Edit';
                        wsToInsert.add(ws);
                    }
                } 
                // CR 60703 -- Fine
            } 

            if(wsToInsert.size()>0){
                insert wsToInsert;
            }
            
            recordCreati+=wsToInsert.size();

            if(wsMap.keySet().size()>0){
                delete wsMap.values();
            }

            recordEliminati+=wsMap.keySet().size();
            
        }
        
        catch(Exception exc){
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
            errorOnCreate = true;
        }

    }


    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            SELECT	Id,
            		Status,
            		NumberOfErrors,
            		JobItemsProcessed,
            		TotalJobItems,
            		CreatedBy.Email
            		FROM AsyncApexJob 
            		WHERE Id = :BC.getJobId()
        	];
        
        testoMail = '';
        if (errorOnCreate) {
            testoMail += '<span style="{color:red;}">Ci sono stati degli errori durante la fase di gestione dei record. sono state inviate le mail</span><br/><br/>';
        }
        
        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' con '+a.NumberOfErrors+' errori.<br/>';
        testoMail += 'Numero totale di Record elaborati : '+recordElab+'<br/>';
        testoMail += 'Numero totale di Record di Wallet__Share creati: '+recordCreati+'<br/>';
        testoMail += 'Numero totale di Record di Wallet__Share eliminati: '+recordEliminati+'<br/>';
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
        if (sj!=null && sj.size()>0 && !errorOnCreate) {
            JobRunner.executeNext(sj);
        }
    }

    public static Set<String> idCedUffPrivateSet {
        get{
            if(idCedUffPrivateSet != null) return idCedUffPrivateSet;

            idCedUffPrivateSet = new Set<String>();
            for(Account filiale : [SELECT id, PTF_IDCEDUffPrivate__c from Account WHERE RecordTypeName__c = 'Filiale di relazione' AND PTF_IDCEDUffPrivate__c  != null]){
                idCedUffPrivateSet.addAll(filiale.PTF_IDCEDUffPrivate__c.replace('|', ';').split(';'));
         }
            return idCedUffPrivateSet;
        }set;
    }

    /*private static Map<String,List<Account>> populateDirToCentri(Set<String> DRIDCEDSet){

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

        List<Account> centriImpresa= [SELECT Id, PTF_IdCED__c FROM Account WHERE PTF_BranchTypology__c='F' AND PTF_DirezioneRegionale__c IN:DRIDCEDSet];
        
        Set<String> centriImpresaRIDCEDSet=new Set<String>();
        
        for(Account c: centriImpresa){
            centriImpresaRIDCEDSet.add('RIDCED'+c.PTF_IdCED__c);
        }

        List<Group> centriGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:centriImpresaRIDCEDSet AND Type='Role'];

        for(Group g:centriGroup){
            RoleGroupCentroImpresa.put(g.DeveloperName, g);
        }

        return RoleGroupCentroImpresa;
    }*/

    /*private static Map<String,Group> findRoleGroupFiliale(Set<String> filialiRIDCEDSet){

        Map<String,Group> roleGroupFiliale= new Map<String,Group>();
        
        List<Group> filialiGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:filialiRIDCEDSet AND Type='Role'];

        for(Group g:filialiGroup){
            roleGroupFiliale.put(g.DeveloperName, g);
        }

        return roleGroupFiliale;
    }*/

    public static Map<String,Group> findRoleGroupUffPrivate(Set<String> uffPrivateRIDCEDSet){

        Map<String,Group> roleGroupFiliale= new Map<String,Group>();
        
        List<Group> filialiGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:uffPrivateRIDCEDSet AND Type='Role'];

        for(Group g:filialiGroup){
            roleGroupFiliale.put(g.DeveloperName, g);
        }

        return roleGroupFiliale;
    }

    //START DK 30/07 - VISIBILITA PORTAFOGLI
    public static Map<String, ServiceModel__c> MDSMap {
        get{
            if(MDSMap != null) return MDSMap;
            MDSMap = new Map<String, ServiceModel__c>();
            for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_NameAbbreviation__c, PTF_Division__c FROM ServiceModel__c]){
                
                MDSMap.put(serviceModel.Name.toUpperCase(), serviceModel);
            }
            return MDSMap;
        }set;
    }
    public static Map<String,Group> findRoleGroupFilialeMDS(Set<String> filialiRIDCEDSet){

        Map<String,Group> roleGroupFiliale= new Map<String,Group>();
        Set<String> groupNameSet = new Set<String>();
        for(String groupName : filialiRIDCEDSet){
            for(String mds : MDSMap.keySet()){
                groupNameSet.add(groupName + '_' + MDSMap.get(mds).PTF_NameAbbreviation__c);
            }
        }
        
        List<Group> filialiGroup = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:groupNameSet];

        for(Group g:filialiGroup){
            roleGroupFiliale.put(g.DeveloperName, g);
        }

        return roleGroupFiliale;
    }
    //END DK 30/07 - VISIBILITA PORTAFOGLI
    
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

    public void mandaMail(String tipoMail, String mailBody) {
        String subject = (tipoMail=='Errore' ? 'Errore ' : (tipoMail=='Warning' ? 'Warning ' :'Elaborazione '))+NOME_CLASSE;
        Utenti_Speciali__mdt utenteSviluppatore = (Utenti_Speciali__mdt)MetadataUtility.getRecordByName('Utenti_Speciali__mdt', COD_SVILUPPATORI);
        List<Utenti_Speciali__mdt> utentiSpeciali = (List<Utenti_Speciali__mdt>)MetadataUtility.getRecordByPrefix('Utenti_Speciali__mdt', COD_CLASSE);
        Set<Id> idUtentiSpeciali = new Set<Id>();
        Set<String> emails = new Set<String>();
        for (Utenti_Speciali__mdt us : utentiSpeciali) {
            if (!String.isEmpty(us.ID_Utente__c)) {
                idUtentiSpeciali.add(us.ID_Utente__c);
            }
            if (!String.isEmpty(us.Email__c) && debug.Email__c) {
                emails.add(us.Email__c);
            }
        }
        if (utenteSviluppatore!=null) {
            if (!String.isEmpty(utenteSviluppatore.ID_Utente__c)) {
                idUtentiSpeciali.add(utenteSviluppatore.ID_Utente__c);
            }
            if (!String.isEmpty(utenteSviluppatore.Email__c) && debug.Email__c) {
                emails.add(utenteSviluppatore.Email__c);
            }
        }
        if (idUtentiSpeciali.size()>0) {
            for (Id idUtente : idUtentiSpeciali) {
            	generaMail(mailBody,subject,idUtente,emails, utenteSviluppatore);
            }
        }
        else if (emails.size()>0) {
            generaMail(mailBody,subject,null,emails, utenteSviluppatore);
        }
    }
    
    /***
     * Name			:	generaMail
     * Author		:	Ezio Dal Bo @TEN
     * Create date	:	2020-10-28
     ***/
    public void generaMail(String mailBody,String subject,Id idUtente,Set<String> addresses, Utenti_Speciali__mdt utenteSviluppatore) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (idUtente!=null) {
            mail.setTargetObjectId(idUtente);
        }
        mail.setSenderDisplayName('Salesforce');
        if (utenteSviluppatore!=null && !String.isEmpty(utenteSviluppatore.Email__c)) {
            mail.setReplyTo(utenteSviluppatore.Email__c);
        }
        mail.setSubject(subject);
        if (!Test.isRunningTest() && addresses.size()>0) {
            mail.setToAddresses(new List<String>(addresses));
        }
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(mailBody);
        if (!Test.isRunningTest()) {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}