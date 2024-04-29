public without sharing class OnWalletTriggerHandler {
    
    public static boolean toSkip = false;
    public static boolean toSkipAfterInsert = false;
    public static final String ABI = '05387';

    /*public static void buildMicroWalletName(List<Wallet__c> mws) {
        if (!toSkip) {
            System.debug('SV toSkip FALSE mws: ' + mws);

            Map<Id,Schema.RecordTypeInfo> rtMap = Wallet__c.sobjectType.getDescribe().getRecordTypeInfosById();
            System.debug('SV rtMap: ' + rtMap);

            String newName, modello, filiale;
            List<Wallet__c> mwToBuildName = new List<Wallet__c>();
            List<Wallet__c> mwToUpdate = new List<Wallet__c>();


            

            for (Wallet__c mw : mws) {
                System.debug('SV PTF: ' + mw);
                System.debug(mw.RecordTypeId);
                System.debug(rtMap.get(mw.RecordTypeId).getDeveloperName());

                if (rtMap.get(mw.RecordTypeId).getDeveloperName() != 'TechnicalWallet' && !mw.Name.startsWith('PTF')) {
                    mwToBuildName.add(mw);
                }
            }

            Map<String,String> mIdToName= new Map<String,String>();
            mIdToName=buildName(mwToBuildName);
            for(String mId:mIdToName.keySet()){
                mwToUpdate.add(new Wallet__c(Id=mId, Name= mIdToName.get(mId)));
            }
            Boolean oldSkip = toSkip;
            toSkip = !toSkip;
            update mwToUpdate;
        } else {
            System.debug('SV toSkip TRUE non faccio nulla');
        }
    }*/

    /*private static Map<String,String> buildName(List<Wallet__c> mws) {
        
        Set<String> modelliSet= new Set<String>();
        Map<String,String> returnMap= new Map<String,String>();
        for(Wallet__c mw: mws){
            modelliSet.add(mw.PTF_ModelloDiServizio__c); 
        }
        Map<String, SObject> mtdWalletAbbMap  = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_Abbreviazione__c
            FROM PTF_ModelloDiServizio__mdt 
            WHERE MasterLabel =: modelliSet ], 'MasterLabel', false);

        Set<Id> accountSet = new Set<Id>();
        for(Wallet__c mw:mws){
            accountSet.add(mw.PTF_Banca__c);
            accountSet.add(mw.PTF_Filiale__c);
        }
        

        Map<String, SObject> bancaFilialeMap  = SV_Utilities.keyBy([ SELECT Id, FinServ__BankNumber__c, PTF_IdCED__c, PTF_IdCEDFiliale__c
            FROM Account 
            WHERE Id IN : accountSet ], 'Id', false);

            System.debug('SV bancaFilialeMap: ' + bancaFilialeMap);

        for(Wallet__c mw: mws){
            String toReturn = 'PTF-';

            String abi = (!bancaFilialeMap.containsKey(mw.PTF_Banca__c)) ? 'NULL' : ((String)bancaFilialeMap.get(mw.PTF_Banca__c).get('FinServ__BankNumber__c') == null || (String)bancaFilialeMap.get(mw.PTF_Banca__c).get('FinServ__BankNumber__c') == '') ? 'NULL' : (String)bancaFilialeMap.get(mw.PTF_Banca__c).get('FinServ__BankNumber__c');
            String ced = (!bancaFilialeMap.containsKey(mw.PTF_Filiale__c)) ? 'NULL' : ((String)bancaFilialeMap.get(mw.PTF_Filiale__c).get('PTF_IdCEDFiliale__c') == null || (String)bancaFilialeMap.get(mw.PTF_Filiale__c).get('PTF_IdCEDFiliale__c') == '') ? 'NULL' : (String)bancaFilialeMap.get(mw.PTF_Filiale__c).get('PTF_IdCEDFiliale__c');
            if(String.isNotBlank(ced)){
                if(ced.length()<4){
                    do{
                        ced='0'+ced;
                    }
                    while(ced.length()<4);
                }
                
            }
            toReturn += mw.PTF_ModelloDiServizio__c != null ? (String)mtdWalletAbbMap.get(mw.PTF_ModelloDiServizio__c).get('PTF_Abbreviazione__c') + '-' : '';
            toReturn += abi + '-' + ced + '-' + mw.PTF_AutoNumber__c;
            returnMap.put(mw.Id,toReturn);
        }    
    
        

        return returnMap;
    }*/

    public static void handleBeforeInsert(List<Wallet__c> walletlist){

        List<Wallet__c> mwList = new List<Wallet__c>();
        String mwRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        
        for(Wallet__c wallet : walletlist){
                    
                mwList.add(wallet);
        }

        if(!mwList.isEmpty()){

            setMWBehaviorOnInsert(mwList);
        }
        validatOnInsert(walletlist);
    }
    
    public static void handleAfterInsert(List<Wallet__c> walletlist){

        //buildMicroWalletName(walletlist);
        // LIST MDSFamily/POE
        List<Wallet__c> poolMWList = new List<Wallet__c>();
        String mwRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        
        System.debug('SV mwRecordTypeId: ' + mwRecordTypeId);
        for(Wallet__c wallet : walletlist){
            if(wallet.RecordTypeId == mwRecordTypeId &&
                wallet.PTF_Pool__c){
                    
                poolMWList.add(wallet);
            }
        }

        System.debug('SV poolMWList: ' + poolMWList);

        if(!poolMWList.isEmpty()){
            addDefaultMangers(poolMWList);
        }
    }

    public static void handleMWBeforeUpdate(Map<Id, Wallet__c> newWalletMap, Map<Id, Wallet__c> oldWalletMap){

        if (!toSkipAfterInsert) {

            List<Wallet__c> mwList = new List<Wallet__c>();
            String mwRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
            
            for(Wallet__c wallet : newWalletMap.values()){
        
                if(wallet.RecordTypeId == mwRecordTypeId ){
                    
                    mwList.add(wallet);
                }
            }
    
            if(!mwList.isEmpty()){
    
                setMWBehaviorOnUpdate(mwList, oldWalletMap);
            }

            Boolean oldToSkipAfterInsert = toSkipAfterInsert;
            toSkipAfterInsert = !toSkipAfterInsert;
        } else {

            System.debug('DK toSkipAfterInsert TRUE non faccio nulla');
        }
    }

    public static void validatOnInsert(List<Wallet__c> walletlist){

        Set<String> existingCombinationSet = new Set<String>();
        Set<Id> filialeIdSet = new Set<Id>();
        Set<String> modelloDiservizioSet = new Set<String>();

        Map<String, SObject> mtdWalletlMap  = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_SingoloSuFiliale__c
                                                                    FROM PTF_ModelloDiServizio__mdt ], 'MasterLabel', false);


        for(Wallet__c wallet: walletlist){
            if((Boolean)mtdWalletlMap.get(wallet.PTF_ModelloDiServizio__c).get('PTF_SingoloSuFiliale__c')){
                filialeIdSet.add(wallet.PTF_Filiale__c);
                modelloDiservizioSet.add(wallet.PTF_ModelloDiServizio__c);
            }
        }

        for(Wallet__c wallet : [SELECT Id, PTF_Filiale__c, PTF_ModelloDiServizio__c 
                                FROM Wallet__c 
                                WHERE PTF_Filiale__c IN : filialeIdSet AND
                                PTF_ModelloDiServizio__c IN : modelloDiservizioSet AND PTF_DeletionDate__c=null]){

            existingCombinationSet.add(wallet.PTF_Filiale__c + '' + wallet.PTF_ModelloDiServizio__c);
        }

        for(Wallet__c wallet: walletlist){
            
            if(existingCombinationSet.contains(wallet.PTF_Filiale__c + '' + wallet.PTF_ModelloDiServizio__c)){
                
                wallet.addError('Esiste già un Microportafoglio con questo modello di servizio su questa filiale.');
            }
        }
    } 

    public static void setMWBehaviorOnInsert(List<Wallet__c> mwlist){
        
        
        /*String unassignedGestoreId = [SELECT Id FROM User WHERE Profile.Name = 'TechnicalProfilePortafogliazione' LIMIT 1][0].Id;
        for(Wallet__c mw : mwlist){
            if(mw.PTF_Pool__c){

                mw.OwnerId = unassignedGestoreId;
            }
        }*/

        handlefilialeIsSet(mwlist);
    }

    public static void setMWBehaviorOnUpdate(List<Wallet__c> mwlist, Map<Id, Wallet__c> oldWalletMap){
        
        List<Wallet__c> mwFilialeUpdateList = new List<Wallet__c>();
        for(Wallet__c mw : mwlist){

            if(mw.PTF_Filiale__c != oldWalletMap.get(mw.Id).PTF_Filiale__c){

                mwFilialeUpdateList.add(mw);
            }
        }

        
        if(!mwFilialeUpdateList.isEmpty()){

            handlefilialeIsSet(mwFilialeUpdateList);
        }
    }
    
    /*public static void setIsPool(List<Wallet__c> mwlist){

        Map<String, SObject> mtdWalletlMap  = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_IsPool__c
                                                            FROM PTF_ModelloDiServizio__mdt ], 'MasterLabel', false);
        for(Wallet__c mw : mwlist){
            
            // mw.PTF_Pool__c = (Boolean)mtdWalletlMap.get(mw.PTF_ModelloDiServizio__c).get('PTF_IsPool__c');
        }
    }*/

    public static void addDefaultMangers(List<Wallet__c> walletlist){

        Map<String, List<String>> mwReferentiMap = new Map<String, List<String>>();
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>(); 
        //String OwnerIdPool = UtenzeDefault__c.getInstance().PTF_POOL_IdOwner__c;
        Set<String> modelloDiservizioSet = new Set<String>();
        Set<String> branchTypologySet = new Set<String>();
        Set<Id> filialeIdSet = new Set<Id>();
        List<Wallet__c> walletsToUpdate = new List<Wallet__c>();
        String primarioRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        

        Map<String,String> serviceModelMap= new Map<String,String>();

        Set<Id> titolareIdSet= new Set<Id>();

        for(RoleTypology__c r: [SELECT Id FROM RoleTypology__c  WHERE Name='Titolare']){
            titolareIdSet.add(r.Id);
        }

        

        Set<String> modelBranchSet= new Set<String>();
        for(Wallet__c wallet: walletlist){
            filialeIdset.add(wallet.PTF_Filiale__c);
            modelBranchSet.add(wallet.PTF_ModelloDiServizio__c+'_'+wallet.PTF_BranchTypology__c);
            branchTypologySet.add(wallet.PTF_BranchTypology__c);
            modelloDiservizioSet.add(wallet.PTF_ModelloDiServizio__c);
        }
        Map<String, SObject> branchModelRoleToTotal =SV_Utilities.keyBy([SELECT PTF_BranchTypology__c, PTF_ServiceModel__r.Name, PTF_RoleTypology__c FROM RoleMDS__c  
                                                                WHERE  (PTF_EndDate__c>=:Date.today() OR PTF_EndDate__c=null) AND PTF_StartDate__c<=:Date.today() AND ModelBranchKey__c IN:modelBranchSet]
                                                               , '{PTF_BranchTypology__c}_{PTF_ServiceModel__r.Name}_{PTF_RoleTypology__c}', true);
        
        Map<String,List<String>> branchModelToRoleIds = new Map<String,List<String>>();
        Map<String,List<String>> branchToModels= new Map<String,List<String>>();
        for(String key:branchModelRoleToTotal.keySet()){
            branchModelRoleToTotal.put(key.split('_')[0]+'_'+key.split('_')[1].toUpperCase()+'_'+key.split('_')[2], branchModelRoleToTotal.remove(key));   
        } 
        System.debug('@@@@@@ branchModelRoleToTotal: '+JSON.serialize(branchModelRoleToTotal));
        for(String s:branchModelRoleToTotal.keySet()){
            String key=s.split('_')[0]+'_'+s.split('_')[1];
            String key2=s.split('_')[2];
            if(!branchModelToRoleIds.containsKey(key)){
                branchModelToRoleIds.put(key, new List<String>());
            }
            branchModelToRoleIds.get(key).add(key2);
            if(!branchToModels.containsKey(s.split('_')[0])){
                branchToModels.put(s.split('_')[0],new List<String>());
            }
            if(!branchToModels.get(s.split('_')[0]).contains(s.split('_')[1])){
                branchToModels.get(s.split('_')[0]).add(s.split('_')[1]);
            }
            
        }
        System.debug('@@@@@@ branchModelToRoleIds: '+JSON.serialize(branchModelToRoleIds));

        Map<String,List<Contact>> filialeModeltoReferente= new Map<String,List<Contact>>();
        for(Account fil:[SELECT Id, PTF_BranchTypology__c, ModelloDiServizio__c, (SELECT Id, PTF_TipologiaRuolo__c, FirstName, LastName FROM Contacts WHERE PTF_ProfiloLDAP__c!=null)  FROM Account WHERE Id IN:filialeIdset]){
            System.debug('@@@@ branchToModels: '+JSON.serialize(branchToModels));
            if(branchToModels.containsKey(fil.PTF_BranchTypology__c)){
                for(String modello: branchToModels.get(fil.PTF_BranchTypology__c)){
                    String key= fil.Id +'_'+modello;
                    String key2=fil.PTF_BranchTypology__c +'_'+modello;
                    if(branchModelToRoleIds.containsKey(key2)){
                        List<String> roleIds=branchModelToRoleIds.get(key2);
                        for(Contact c: fil.Contacts){
                            if(roleIds.contains(c.PTF_TipologiaRuolo__c)){
                                if(!filialeModeltoReferente.containsKey(key)){
                                    filialeModelToReferente.put(key,new List<Contact>());
                                }
                                filialeModelToReferente.get(key).add(c);
                            }
                        }
                    }
                }
            }
            
            
            
        }

        System.debug('@@@@@@ mappafilialitoreferenti: '+JSON.serialize(filialeModeltoReferente));
        
        for(Wallet__c wallet: walletlist){
            
            string key = wallet.PTF_Filiale__c + '_' + wallet.PTF_ModelloDiServizio__c.toUpperCase(); 
            
            if(filialeModelToReferente.containsKey(key)){

                System.debug('@@@@sonoqui');
                
                for(Contact referente : filialeModelToReferente.get(key)){
                    
                    if(wallet.PTF_ModelloDiServizio__c == 'Controparti Istituzionali'){
                        System.debug('@@@@sonoqui');
                        if(titolareIdSet.contains(referente.PTF_TipologiaRuolo__c)){
                            System.debug('@@@@sonoqui');
                            assignmentsToInsert.add(new Assignment__c(
                                PTF_StartDate__c = Date.today(),
                                PTF_StartDate_DT__c = Datetime.now(),
                                PTF_MicroWallet__c = wallet.id,
                                PTF_Gestore__c = referente.Id,
                                RecordTypeId = primarioRecordTypeId
                            ));
                            
                            if(!mwReferentiMap.containsKey(wallet.Id)){

                                mwReferentiMap.put(wallet.id, new List<String>());
                            }
                            mwReferentiMap.get(wallet.id).add(referente.FirstName + ' ' + referente.LastName);
                        }
                    }else{

                        assignmentsToInsert.add(new Assignment__c(
                            PTF_StartDate__c = Date.today(),
                            PTF_StartDate_DT__c = Datetime.now(),
                            PTF_MicroWallet__c = wallet.id,
                            PTF_Gestore__c = referente.Id,
                            RecordTypeId = primarioRecordTypeId
                        ));

                        if(!mwReferentiMap.containsKey(wallet.Id)){

                            mwReferentiMap.put(wallet.id, new List<String>());
                        }
                        mwReferentiMap.get(wallet.id).add(referente.FirstName + ' ' + referente.LastName);
                    }
                }
            }
            else{
                walletsToUpdate.add(new Wallet__c(
                Id = wallet.Id,
                PTF_StatoAssegnazione__c='Non assegnato')
                //OwnerId = OwnerIdPool
                );
            }
        }

        for(String walletId : mwReferentiMap.keySet()){

            walletsToUpdate.add(new Wallet__c(
                Id = walletId,
                PTF_NomiReferentiConcat__c = String.join(mwReferentiMap.get(walletId), ',')
                //OwnerId = OwnerIdPool
            ));
        }
        
        if(!assignmentsToInsert.isEmpty()){

            insert assignmentsToInsert;
        }
        if(!walletsToUpdate.isEmpty()){

            update walletsToUpdate;
        }
       
        ////
                                                                

        /*Set<Id> filialeIdSet = new Set<Id>();
        Set<Id> titolareIdSet = new Set<Id>();
        Set<Id> roleTypologyIdSet = new Set<Id>();
        Map<String,Set<Contact>> mdsFilialeCotactMap = new Map<String,Set<Contact>>();
        Set<String> branchTypologySet = new Set<String>();
        Set<String> modelloDiservizioSet = new Set<String>();
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>(); 
        Map<String, List<String>> mwReferentiMap = new Map<String, List<String>>();
        List<Wallet__c> walletsToUpdate = new List<Wallet__c>();

        // SV ADD UTENZA DI DEFAULT
        String OwnerIdPool = UtenzeDefault__c.getInstance().PTF_POOL_IdOwner__c;

        for(Wallet__c wallet: walletlist){
            
            filialeIdSet.add(wallet.PTF_Filiale__c);
            modelloDiservizioSet.add(wallet.PTF_ModelloDiServizio__c);
        }

        for(Account filiale : [SELECT id, PTF_BranchTypology__c FROM Account WHERE id IN : filialeIdSet]){

            branchTypologySet.add(filiale.PTF_BranchTypology__c);
        }
        
        System.debug('branchTypologySet: ' + JSON.serializePretty(branchTypologySet));

        for(RoleMDS__c roleMDS : [SELECT Id, PTF_RoleTypology__c, PTF_RoleTypology__r.Name FROM RoleMDS__c WHERE PTF_BranchTypology__c IN: branchTypologySet AND PTF_ServiceModel__r.Name IN: modelloDiservizioSet]){

            roleTypologyIdSet.add(roleMDS.PTF_RoleTypology__c);
            if(roleMDS.PTF_RoleTypology__r.Name == 'Titolare'){
                
                titolareIdSet.add(roleMDS.PTF_RoleTypology__c);
            }
        }

        System.debug('roleTypologyIdSet: ' + JSON.serializePretty(roleTypologyIdSet));
        System.debug('titolareIdSet: ' + JSON.serializePretty(titolareIdSet));
        
        for(Contact referente : [SELECT id, AccountId, PTF_ModelloDiServizio__c, PTF_TipologiaRuolo__c, FirstName, LastName FROM Contact WHERE PTF_TipologiaRuolo__c IN: roleTypologyIdSet]){

            string key = referente.AccountId + '' + referente.PTF_ModelloDiServizio__c;
            if(!mdsFilialeCotactMap.containsKey(key)){

                mdsFilialeCotactMap.put(key, new Set<Contact>());
            }
            mdsFilialeCotactMap.get(key).add(referente);
        }

        System.debug('mdsFilialeCotactMap: ' + JSON.serializePretty(mdsFilialeCotactMap));
        
        String primarioRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');

        for(Wallet__c wallet: walletlist){
            
            string key = wallet.PTF_Filiale__c + '' + wallet.PTF_ModelloDiServizio__c;
            
            if(mdsFilialeCotactMap.containsKey(key)){
                
                for(Contact referente : mdsFilialeCotactMap.get(key)){
                    
                    if(wallet.PTF_ModelloDiServizio__c == 'Controparti Istituzionali'){
                       
                        if(titolareIdSet.contains(referente.PTF_TipologiaRuolo__c)){

                            assignmentsToInsert.add(new Assignment__c(
                                PTF_StartDate__c = Date.today(),
                                PTF_MicroWallet__c = wallet.id,
                                PTF_Gestore__c = referente.Id,
                                RecordTypeId = primarioRecordTypeId
                            ));
                            
                            if(!mwReferentiMap.containsKey(wallet.Id)){

                                mwReferentiMap.put(wallet.id, new List<String>());
                            }
                            mwReferentiMap.get(wallet.id).add(referente.FirstName + ' ' + referente.LastName);
                        }
                    }else{

                        assignmentsToInsert.add(new Assignment__c(
                            PTF_StartDate__c = Date.today(),
                            PTF_MicroWallet__c = wallet.id,
                            PTF_Gestore__c = referente.Id,
                            RecordTypeId = primarioRecordTypeId
                        ));

                        if(!mwReferentiMap.containsKey(wallet.Id)){

                            mwReferentiMap.put(wallet.id, new List<String>());
                        }
                        mwReferentiMap.get(wallet.id).add(referente.FirstName + ' ' + referente.LastName);
                    }
                }
            }
        }
        for(String walletId : mwReferentiMap.keySet()){

            walletsToUpdate.add(new Wallet__c(
                Id = walletId,
                PTF_NomiReferentiConcat__c = String.join(mwReferentiMap.get(walletId), ','),
                OwnerId = OwnerIdPool
            ));
        }
        
        if(!assignmentsToInsert.isEmpty()){

            insert assignmentsToInsert;
        }
        if(!walletsToUpdate.isEmpty()){

            update walletsToUpdate;
        }*/
    }

    public static void handleBeforeDelete(List<Wallet__c> walletlist){

        List<Wallet__c> mwList = new List<Wallet__c>();
        List<Wallet__c> twList = new List<Wallet__c>();
        List<Wallet__c> asList = new List<Wallet__c>();
        List<Wallet__c> reList = new List<Wallet__c>();
        String mwRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        String twRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'TechnicalWallet');
        String asRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente');
        String reRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Residuale');
        
        for(Wallet__c wallet : walletlist){
    
            if(wallet.RecordTypeId == mwRecordTypeId){
                
                mwList.add(wallet);
            } else if(wallet.RecordTypeId == twRecordTypeId){

                twList.add(wallet);
            } else if(wallet.RecordTypeId == asRecordTypeId){

                asList.add(wallet);
            } else if(wallet.RecordTypeId == reRecordTypeId){

                reList.add(wallet);
            }
        }

        if(!mwList.isEmpty()){

            validateMWOnDelete(mwList);
        }
        if(!twList.isEmpty()){

            validateTWOnDelete(twList);
        }
        if(!asList.isEmpty()){

            validateASOnDelete(asList);
        }
        if(!reList.isEmpty()){

            validateREOnDelete(reList);
        }
    }

    public static void validateMWOnDelete(List<Wallet__c> mwList){

        Map<String, SObject> mwMap = SV_Utilities.keyBy(mwList, 'Id');
        Map<String, SObject> assignmentMap = SV_Utilities.keyBy([SELECT id, PTF_MicroWallet__c FROM Assignment__c WHERE PTF_MicroWallet__c IN: mwMap.keyset() AND PTF_EndDate__c = null], 'PTF_MicroWallet__c');
        Map<String, SObject> ndgMap = SV_Utilities.keyBy([SELECT id, PTF_Portafoglio__c FROM Account WHERE PTF_Portafoglio__c IN: mwMap.keyset()], 'PTF_Portafoglio__c');
        Set<String> walletIdSet = new Set<String>();
        for(WorkOrder workOrder : [SELECT id, PTF_Destinazione__c, PTF_Origine__c FROM WorkOrder WHERE Status = 'Pending' AND (PTF_Destinazione__c IN: mwMap.keySet() OR PTF_Origine__c IN: mwMap.keySet())]){

            walletIdSet.add(workOrder.PTF_Destinazione__c);
            walletIdSet.add(workOrder.PTF_Origine__c);
        }
        for(Wallet__c wallet : mwList){

            if(walletIdSet.contains(wallet.Id)){

                    wallet.addError('Non è possibile cancellare un Microportafoglio legato ad un iter di spostamento.');
            }else if(assignmentMap.containsKey(wallet.Id) ||
                    ndgMap.containsKey((wallet.Id))){
                
                wallet.addError('Non è possibile cancellare un Microportafoglio che non sia vuoto e non assegnato ad un referente');
            }
        }
    }

    public static void validateTWOnDelete(List<Wallet__c> twList){

        Map<String, SObject> twMap = SV_Utilities.keyBy(twList, 'Id');
        Map<String, SObject> ndgMap = SV_Utilities.keyBy([SELECT id, PTF_Portafoglio__c FROM Account WHERE PTF_Portafoglio__c IN: twMap.keyset()], 'PTF_Portafoglio__c');

        for(Wallet__c wallet : twList){

            if(ndgMap.containsKey((wallet.Id))){

                wallet.addError('Non è possibile cancellare un Portafoglio Tecnico che non sia vuoto e non assegnato ad alcun referente.');
            }
        }
    }

    public static void validateASOnDelete(List<Wallet__c> asList){

        for(Wallet__c wallet : asList){

            wallet.addError('Non è possibile cancellare un Portafoglio Assente.');
        }
    }

    public static void validateREOnDelete(List<Wallet__c> reList){

        for(Wallet__c wallet : reList){

            wallet.addError('Non è possibile cancellare un Portafoglio Residuale.');
        }
    }
    

    public static void handlefilialeIsSet(List<Wallet__c> mwList){
        
        //Map<String, Map<String,String>> filialeMap = new Map<String, Map<String,String>>();
        Map<String, Account> filialeMap= new Map<String, Account>();
        for(Account filiale : [SELECT Id, PTF_Capofila__c, PTF_Banca__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_BranchTypology__c FROM Account WHERE Id IN: SV_Utilities.keyBy(mwList, 'PTF_Filiale__c').keySet()]){
            
            filialeMap.put(filiale.Id, filiale);
            /*
            if(!filialeMap.containsKey(filiale.Id)){

                filialeMap.put(filiale.Id, new Map<String,String>());
            }


            
            if(filiale.PTF_BranchTypology__c == 'A' || filiale.PTF_BranchTypology__c == 'F'){
                
                filialeMap.get(filiale.Id).put('idCapofila', filiale.Id);
                filialeMap.get(filiale.Id).put('idArea', filiale.ParentId);
                filialeMap.get(filiale.Id).put('idDReg', filiale.Parent.ParentId);
                filialeMap.get(filiale.Id).put('idBanca', filiale.Parent.Parent.ParentId);
            }else{
                
                filialeMap.get(filiale.Id).put('idCapofila', filiale.ParentId);
                filialeMap.get(filiale.Id).put('idArea', filiale.Parent.ParentId);
                filialeMap.get(filiale.Id).put('idDReg', filiale.Parent.Parent.ParentId);
                filialeMap.get(filiale.Id).put('idBanca', filiale.Parent.Parent.Parent.ParentId);
            }*/
        }

        for(Wallet__c wallet : mwList){

            if(filialeMap.containsKey(wallet.PTF_Filiale__c)){
                
                if(String.isNotBlank( filialeMap.get(wallet.PTF_Filiale__c).PTF_Capofila__c)){
                    wallet.PTF_Capofila__c=filialeMap.get(wallet.PTF_Filiale__c).PTF_Capofila__c;
                }
                else{
                    wallet.PTF_Capofila__c=wallet.PTF_Filiale__c;
                }
                wallet.PTF_Area__c = filialeMap.get(wallet.PTF_Filiale__c).PTF_Area__c;
                wallet.PTF_DirezioneRegionale__c = filialeMap.get(wallet.PTF_Filiale__c).PTF_DirezioneRegionale__c;
                wallet.PTF_Banca__c = filialeMap.get(wallet.PTF_Filiale__c).PTF_Banca__c; 

                /*
                wallet.PTF_Capofila__c = filialeMap.get(wallet.PTF_Filiale__c).get('idCapofila');
                wallet.PTF_Area__c = filialeMap.get(wallet.PTF_Filiale__c).get('idArea');
                wallet.PTF_DirezioneRegionale__c = filialeMap.get(wallet.PTF_Filiale__c).get('idDReg');
                wallet.PTF_Banca__c = filialeMap.get(wallet.PTF_Filiale__c).get('idBanca'); 
                */
            }
        }
    }

    public static void setFields(List<Wallet__c> mws, Map<Id, Wallet__c> oldWalletMap) {
        
        String techMWRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'TechnicalWallet');

        for(Wallet__c mw : mws){
            if(mw.RecordTypeId != techMWRecordTypeId){
                if(mw.PTF_ModelloDiServizio__c == 'Assente'){
                    mw.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente');
                }
    
                if(mw.PTF_ModelloDiServizio__c == 'Residuale'){
                    mw.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Residuale');
                }
    
            }
        }

    }
}