/*
 * Name         :   OnAssignmentTriggerHandler
 * Author       :   Ezio Dal Bo @TEN
 * Create Date  :   2020-07-30
 * -------------
 * Modify Date	:	2021-04-19
 * Author		:	Ezio Dal Bo @TEN
 * Modify		:	fix about 50000+ record and time cpu limit exception
 */
public class OnAssignmentTriggerHandler {
    
    public static Boolean trafficLightTrigger = false;

    /***
    * Name          :   OnAfterInsert
    * Author        :   Ezio Dal Bo @TEN
    * Create Date   :   2020-07-30
    * Description   :   Manage after insert event 
    */
    public static void onAfterInsert(List<Assignment__c> newRecords) {
        Map<Id,List<Assignment__c>> mPTFAssignment = new Map<Id,List<Assignment__c>>();
        List<NDGManagementMember__c> storicoReferenti = new List<NDGManagementMember__c>();
        List<Wallet__c> walletToUpdate = new List<Wallet__c>();
        Set<Id> idMicroWalletOver1K = new Set<Id>();
        Set<Id> idMicroWalletUnder1K = new Set<Id>();
        Id rectypeId= SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'Standard');
        Id idRecTypePrimario = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        Id idRecTypeBackup = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Backup');
        
        // obtain set of MicroWallets id
        for (Assignment__c ass : newRecords) {
            if (ass.PTF_MicroWallet__c!=null) {
                List<Assignment__c> lAss = (mPTFAssignment.containsKey(ass.PTF_MicroWallet__c) ? mPTFAssignment.get(ass.PTF_MicroWallet__c) : new List<Assignment__c>());
                lAss.add(ass);
                mPTFAssignment.put(ass.PTF_MicroWallet__c,lAss);                
            }
        }
        if (!mPTFAssignment.isEmpty()) {
            Integer num = 0;
            Integer numUnder1K = 0;
            // obtain number of records
            List<AggregateResult> aggR = [
                SELECT	COUNT(Id) num, PTF_Portafoglio__c
                FROM Account
                WHERE PTF_Portafoglio__c!=null
                AND PTF_Portafoglio__c IN:mPTFAssignment.keySet()
                GROUP BY PTF_Portafoglio__c
            ];
            if (aggR!=null && aggR.size()>0) {
                for (AggregateResult agg : aggR) {
                    Integer n = (agg.get('num')==null ? 0 : Integer.valueOf(agg.get('num')));
                    if (n>0 && n<1000) {
                        numUnder1K += n;
                        idMicroWalletUnder1K.add((Id)agg.get('PTF_Portafoglio__c'));
                    }
                    else if (n>=1000) {
                        idMicroWalletOver1K.add((Id)agg.get('PTF_Portafoglio__c'));
                    }
                    num += n;
                }
                if (numUnder1K>1000) {
                    idMicroWalletOver1K.addAll(idMicroWalletUnder1K);
                    idMicroWalletUnder1K.clear();
                }
            }
            /* else{
                //idMicroWalletUnder1K.add(mPTFAssignment.keySet());
                walletToUpdate.addAll(impostaStatoWallet(mPTFAssignment.keySet()));
                if (!walletToUpdate.isEmpty()) {
                    if (walletToUpdate.size()>10000) {
                        //update walletToUpdate;
                        invokeBatch(
                            'Batch_TriggerOperation',
                            new Map<String,Object>{'sObjList'=> walletToUpdate,'operationType'=>'update','sObjectType'=>'Wallet__c'}
                        );
                    }
                    else {
                        update walletToUpdate;
                    }
                }
            } */
            if (num>=40000) {
                invokeBatch(
                    'Batch_OnAssignmentTriggerHandler',
                    new Map<String,Object>{'eventType'=> 'onAfterInsert','idMicroWalletOver1K'=>mPTFAssignment.keySet(),'mPTFAssignment'=>mPTFAssignment}
                );
            }
            else {
                if (idMicroWalletOver1K.size()>0) {
                    invokeBatch(
                        'Batch_OnAssignmentTriggerHandler',
                        new Map<String,Object>{'eventType'=> 'onAfterInsert','idMicroWalletOver1K'=>idMicroWalletOver1K,'mPTFAssignment'=>mPTFAssignment}
                    );
                }
                if (idMicroWalletUnder1K.size()>0) {
                    for (Account acc : [SELECT Id,
                                        Name,
                                        PTF_Portafoglio__c,
                                        CRM_NDG__c 
                                        FROM Account 
                                        WHERE PTF_Portafoglio__c!=null 
                                        AND PTF_Portafoglio__c IN:idMicroWalletUnder1K])
                    {
                        List<Assignment__c> lAss = mPTFAssignment.get(acc.PTF_Portafoglio__c);
                        if (lAss!=null) {
                        	storicoReferenti.addAll(creaStoricoNDGReferenti(acc,lAss,rectypeId,idRecTypePrimario,idRecTypeBackup));
                        }
                    }
                    //insert storico records
                    if (!storicoReferenti.isEmpty()) {
                        if (storicoReferenti.size()>10000) {
                            //insert storicoReferenti;
                            invokeBatch(
                                'Batch_TriggerOperation',
                                new Map<String,Object>{'sObjList'=> storicoReferenti,'operationType'=>'insert','sObjectType'=>'NDGManagementMember__c'}
                            );
                        }
                        else {
                            insert storicoReferenti;
                        }
                    }
                    /* walletToUpdate.addAll(impostaStatoWallet(idMicroWalletUnder1K));
                    if (!walletToUpdate.isEmpty()) {
                		if (walletToUpdate.size()>10000) {
                			//update walletToUpdate;
                			invokeBatch(
                                'Batch_TriggerOperation',
                                new Map<String,Object>{'sObjList'=> walletToUpdate,'operationType'=>'update','sObjectType'=>'Wallet__c'}
                            );
                		}
                		else {
                    		update walletToUpdate;
                		}
            		} */
                }
            }
        }
    }
    
    /***
    * Name          :   onAfterUpdate
    * Author        :   Ezio Dal Bo @TEN
    * Create Date   :   2020-07-30
    * Description   :   Manage after update event 
    */
    public static void onAfterUpdate(List<Assignment__c> newRecords, Map<Id, Assignment__c> oldRecordsMap) {
        Set<Id> idWallet = new Set<Id>();
        Set<Id> idAssignment = new Set<Id>();
        for (Assignment__c ass : newRecords) {
            Assignment__c oldAss = oldRecordsMap.get(ass.Id);
            if (ass.PTF_EndDate__c!=oldAss.PTF_EndDate__c) {
                if (ass.PTF_EndDate__c!=null && oldAss.PTF_EndDate__c==null && ass.PTF_MicroWallet__c!=null) {
                	idWallet.add(ass.PTF_MicroWallet__c);
                    idAssignment.add(ass.Id);
            	}
        	}
        }
        
        if (idAssignment.size()>0) {
            Integer num = 0;
            // obtain number of records
            List<AggregateResult> aggR = [
                SELECT	COUNT(Id) num
                FROM NDGManagementMember__c
                WHERE Id_oggetto_sorgente__c!=null
                AND Id_oggetto_sorgente__c IN:idAssignment
            ];
            if (aggR!=null && aggR.size()>0) {
                for (AggregateResult agg : aggR) {
                    num = (agg.get('num')==null ? 0 : Integer.valueOf(agg.get('num')));
                }
            }
            
            if (num>10000) {
                invokeBatch(
                    'Batch_OnAssignmentTriggerHandler',
                    new Map<String,Object>{'eventType'=> 'onAfterUpdate','idAssignment'=>idAssignment}
                );
            }
            else {
                // aggiorno gli ndgManagementMembers associati agli assignment
                List<NDGManagementMember__c> ndgMembers = [
                    SELECT	Id,
                    		PTF_EndDate__c,
                    		PTF_EndDate_DT__c
                    FROM NDGManagementMember__c
                    WHERE Id_oggetto_sorgente__c!=null
                    AND Id_oggetto_sorgente__c IN:idAssignment 
                ];
                
                if(ndgMembers.size() >0){
                    updateStoricoNDGReferenti(ndgMembers);
                    update ndgMembers;
                }
            }
        }
        List<Wallet__c> walletToUpdate = new List<Wallet__c>();
        /* walletToUpdate.addAll(impostaStatoWallet(idWallet));
        if (!walletToUpdate.isEmpty()) {
            if (walletToUpdate.size()>10000) {
                //update walletToUpdate;
                invokeBatch(
                    'Batch_TriggerOperation',
                    new Map<String,Object>{'sObjList'=> walletToUpdate,'operationType'=>'update','sObjectType'=>'Wallet__c'}
                );
            }
            else {
                update walletToUpdate;
            }
        } */
    }
    
    /**
     * Name         :   creaStoricoNDGReferenti 
     * Create Date  :   2020-07-30
     * Author       :   Ezio Dal Bo
     * Input        :   wrapper (List<Wrapper>)
     * Output       :   List<NDGManagementMember__c>
     * Description  :   Manage Assignment records and Account Records to generate a list of NDGManagementMember__c records
     */
    public static List<NDGManagementMember__c> creaStoricoNDGReferenti(Account acc, List<Assignment__c> lAss, Id recTypeId, Id idRecTypePrimario,Id idRecTypeBackup) {
        List<NDGManagementMember__c> managements = new List<NDGManagementMember__c>();
        for (Assignment__c ass : lAss) {
            NDGManagementMember__c ndgRef = new NDGManagementMember__c();
        	ndgRef.PTF_StartDate__c = Date.today();
        	ndgRef.PTF_StartDate_DT__c = Datetime.now();
        	ndgRef.PTF_NDG__c = acc.Id;
        	ndgRef.PTF_Gestore__c = ass.PTF_Gestore__c;
        	ndgRef.PTF_NomeNDG__c = acc.Name;
        	ndgRef.PTF_NomeReferente__c = ass.PTF_Gestore_Name__c;
        	ndgRef.RecTypeId__c = ass.RecordTypeId;
        	ndgRef.Id_oggetto_sorgente__c = ass.id;
        	if (ass.RecordTypeId==idRecTypePrimario || ass.RecordTypeId==idRecTypeBackup) {
            	ndgRef.RecTypeDevName__c = (ass.RecordTypeId==idRecTypePrimario ? 'Primario' : 'Backup');
        	}
        	ndgRef.RecordTypeId= rectypeId;
            managements.add(ndgRef);
        }
        return managements;
    }
    
    /**
     * Name         :   updateStoricoNDGReferenti 
     * Create Date  :   2020-07-30
     * Author       :   Ezio Dal Bo
     * Input        :   storicoReferenti (List<NDGManagementMember__c)
     * Output       :   list NDGManangementMember__c record updated
     * Description  :   Manage NDGManagementMember__c records
     */
    public static void updateStoricoNDGReferenti(List<NDGManagementMember__c> ndgManagements) {
        
        for (NDGManagementMember__c ndg: ndgManagements) {
            ndg.PTF_EndDate__c = Date.today();
            ndg.PTF_EndDate_DT__c = Datetime.now();
        }
    }
    
    /**
     * Name         :   impostaStatoWallet 
     * Create Date  :   2021-04-20
     * Author       :   Ezio Dal Bo
     * Input        :   idWallets (Set<Id>)
     * Output       :   List<Wallet__c>
     * Description  :   Manage Wallet__c records
     */
    /*
    public static List<Wallet__c> impostaStatoWallet(Set<Id> idWallets) {
        List<Wallet__c> wallets = new List<Wallet__c>();
        Id recordTypePrimario = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        Map<String, SObject> mapAgg = SV_Utilities.keyBy([
            SELECT COUNT(Id) numAssign, PTF_MicroWallet__c 
            FROM Assignment__c 
            WHERE PTF_MicroWallet__c IN : idWallets AND RecordTypeId =: recordTypePrimario AND PTF_EndDate__c = NULL
            GROUP BY PTF_MicroWallet__c], 'PTF_MicroWallet__c', false);
        
        for(String key : idWallets){
            Integer num = (mapAgg.get(key)==null ? 0 : (Integer)mapAgg.get(key).get('numAssign'));
            Wallet__c w = new Wallet__c();
            w.Id = key;
            w.PTF_StatoAssegnazione__c = (num==0 ? 'Non Assegnato' : (num==1 ? 'Assegnato' : 'Assegnati'));
            wallets.add(w);
        }
        return wallets;
    }
    */
    
    public static void invokeBatch(String className,Map<String,Object> parameters) {
        
        if ('Batch_TriggerOperation'.equals(className)) {
        	Batch_TriggerOperation bto = new Batch_TriggerOperation();
        	bto.sObjList = (List<sObject>)parameters.get('sObjList');
        	bto.operationType = (String)parameters.get('operationType');
        	bto.sObjectType = (String)parameters.get('sObjectType');
        	Database.executeBatch(bto,200);
        }
        if ('Batch_OnAssignmentTriggerHandler'.equals(className)) {
        	Batch_OnAssignmentTriggerHandler bto = new Batch_OnAssignmentTriggerHandler();
        	bto.eventType = (String)parameters.get('eventType');
            if (parameters.containsKey('idMicroWalletOver1K')) {
        		bto.idMicroWalletOver1K = (Set<Id>)parameters.get('idMicroWalletOver1K');
            }
            if (parameters.containsKey('mPTFAssignment')) {
        		bto.mPTFAssignment = (Map<Id,List<Assignment__c>>)parameters.get('mPTFAssignment');
            }
            if (parameters.containsKey('idAssignment')) {
        		bto.idAssignment = (Set<Id>)parameters.get('idAssignment');
            }
            
        	Database.executeBatch(bto,200);
        }
    }

    public static void setFieldsOnPTF(Map<Id, Assignment__c> newRecordsMap, Map<Id, Assignment__c> oldRecordsMap) {

        System.debug('SV setReferenteOnPTF newRecordsMap: ' + newRecordsMap);
        System.debug('SV setReferenteOnPTF oldRecordsMap: ' + oldRecordsMap);
        Id recordTypeIdPrimario = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');

        // obtain set of MicroWallets id
        Set<Id> setMicroWallet = new Set<Id>();

        for (String key : newRecordsMap.keySet()) {
            if (newRecordsMap.get(key).PTF_MicroWallet__c != NULL) {
                setMicroWallet.add(newRecordsMap.get(key).PTF_MicroWallet__c);
            }
        }

        Map<String, SObject> mapAgg = SV_Utilities.keyBy([
            SELECT COUNT(Id) numAssign, PTF_MicroWallet__c 
            FROM Assignment__c 
            WHERE PTF_MicroWallet__c IN : setMicroWallet AND RecordTypeId =: recordTypeIdPrimario AND PTF_EndDate__c = NULL
            GROUP BY PTF_MicroWallet__c], 'PTF_MicroWallet__c', false);

        List<Wallet__c> elementToUpdate = new List<Wallet__c>();
        trafficLightTrigger = true;
        for(String key : newRecordsMap.keySet()){
            Integer num = (mapAgg.get(newRecordsMap.get(key).PTF_MicroWallet__c) == NULL ? 0 : (Integer)mapAgg.get(newRecordsMap.get(key).PTF_MicroWallet__c).get('numAssign'));

            if(newRecordsMap.get(key).RecordTypeId == recordTypeIdPrimario && !newRecordsMap.get(key).PTF_IsPool__c){
                // PTF NON IN POOL
                if(newRecordsMap.get(key).PTF_EndDate__c != NULL && (oldRecordsMap != NULL && oldRecordsMap.get(key).PTF_EndDate__c == NULL)){
                    // RIMOSSO ASSIGNMENT
                    elementToUpdate.add(new Wallet__c(Id = newRecordsMap.get(key).PTF_MicroWallet__c, 
                                                        CRM_ReferentePortafoglio__c = NULL,
                                                        PTF_StatoAssegnazione__c = (num<=0 ? 'Non Assegnato' : (num==1 ? 'Assegnato' : 'Assegnati'))));

                } else if(newRecordsMap.get(key).PTF_EndDate__c == NULL && ((oldRecordsMap != NULL && oldRecordsMap.get(key).PTF_EndDate__c != NULL) || oldRecordsMap == NULL)){
                    // RIATTIVATO ASSIGNMENT - INSERISCO NEW ASSIGNMENT
                    elementToUpdate.add(new Wallet__c(Id = newRecordsMap.get(key).PTF_MicroWallet__c, 
                                                        CRM_ReferentePortafoglio__c = newRecordsMap.get(key).PTF_Gestore__c,
                                                        PTF_StatoAssegnazione__c = (num<=0 ? 'Non Assegnato' : (num==1 ? 'Assegnato' : 'Assegnati'))));

                }
            } else if(newRecordsMap.get(key).RecordTypeId == recordTypeIdPrimario && newRecordsMap.get(key).PTF_IsPool__c){
                // PTF IN POOL
                if(elementToUpdate.size() == 0){
                elementToUpdate.add(new Wallet__c(Id = newRecordsMap.get(key).PTF_MicroWallet__c, 
                                                    CRM_ReferentePortafoglio__c = NULL,
                                                    PTF_StatoAssegnazione__c = (num<=0 ? 'Non Assegnato' : (num==1 ? 'Assegnato' : 'Assegnati'))));
                }
            }

        }
        
        System.debug('SV elementToUpdate: ' + elementToUpdate);
        if(elementToUpdate.size() > 0){
            if (elementToUpdate.size() > 10000) {
                //update walletToUpdate;
                invokeBatch(
                    'Batch_TriggerOperation',
                    new Map<String,Object>{'sObjList'=> elementToUpdate,'operationType'=>'update','sObjectType'=>'Wallet__c'}
                );
            }
            else {
                update elementToUpdate;
            }
        }
    }
}