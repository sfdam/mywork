global class Batch_ReassignFromD0 implements Schedulable, Database.Batchable<sObject>,Database.stateful{
    private static final String COD_CLASSE = 'GR004';
    private static final String COD_SVILUPPATORI = 'DEVELOPER';
    private static final String NOME_CLASSE = 'Batch_ReassignFromD0';
    global Boolean errorOnCreate = false;
    global String testoMail ='';

    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();

    global Debug__mdt debug = (Debug__mdt)MetadataUtility.getRecordByName('Debug__mdt', COD_CLASSE);

    public static Map<String, SObject> configurazioniMap{
        get{

            if(configurazioniMap != null){

                return configurazioniMap;
            }

            configurazioniMap = new Map<String, SObject>();
            configurazioniMap = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_MDS_End__c, PTF_MDS_Start__c,
            PTF_Abi__c, Finestra_Temporale__c, Iter_Approvativo__c,
            PTF_Filiale_End__c, PTF_Filiale_Start__c, PTF_JSON_Approvatori__c, PTF_StessoReferente__c,
            PTF_CheckNaturaGiuridica__c, PTF_CheckCedSpecifico__c, PTF_CheckTipologiaFilialeDestinazione__c, PTF_CheckTipologiaFilialePartenza__c, Tipo_di_Spostamento__c
            ,PTF_SuperUsers__c
            FROM ConfigurazioneSpostamenti__mdt
            WHERE PTF_IsActive__c = true], 'MasterLabel');
            return configurazioniMap;
        }set;
    }

    public String today = DateTime.now().formatGMT('dd/MM/yyyy');

    public Set<String> pendingPIWActorSet{

        get{

            if(pendingPIWActorSet != null){

                return pendingPIWActorSet;
            }
            pendingPIWActorSet = SV_Utilities.keyBy([SELECT ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status = 'Pending'], 'ActorId').keySet();
            return pendingPIWActorSet;
        }set;
    }

    public static Map<String, String> idCedFittiziaMap {
        get{
            if(idCedFittiziaMap != null){
                return idCedFittiziaMap;
            }

            idCedFittiziaMap = new Map<String, String>();
            for(Struttura_Banca__c sb : [SELECT Id, IdCed__c, IDCed_Fittizia__c FROm STRUTTURA_BANCA__c WHERE IDCed_Fittizia__c  != '']){
                idCedFittiziaMap.put(sb.IdCed__c, sb.IDCed_Fittizia__c);
            }
            return idCedFittiziaMap;
        }set;
    }

    public static Map<String, String> idFittiziaMap {
        get{
            if(idFittiziaMap != null){
                return idFittiziaMap;
            }

            idFittiziaMap = new Map<String, String>();
            Map<String, String> idcedMap = new Map<String, String>();
            for(Struttura_Banca__c sb : [SELECT Id, IdCed__c, IDCed_Fittizia__c FROm STRUTTURA_BANCA__c WHERE IDCed_Fittizia__c  != '']){
                idcedMap.put(sb.IDCed_Fittizia__c, sb.IdCed__c);
            }
            for(Account account : [SELECT Id, PTF_IdCed__c FROM Account WHERE PTF_IdCed__c IN: idcedMap.keySet()]){

                idFittiziaMap.put(idcedMap.get(account.PTF_IdCed__c), account.Id);
            }
            return idFittiziaMap;
        }set;
    }

    public List<WorkOrder> woToUpdate = new List<WorkOrder>();


    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator('SELECT Id, Step__c, Queues__c, Subject, PTF_Origine__c, PTF_Origine__r.PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Destinazione__c, PTF_Destinazione__r.PTF_DirezioneRegionale__r.PTF_IdCed__c, StepsApprovers__c, Process__c FROM WorkOrder WHERE Status = \'Pending\' AND Subject != \'SUPERUSER\' AND HasNF__c = true ORDER BY PTF_Origine__r.PTF_Banca__c DESC');
    }

    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) {
        
        try {
            
            List<WorkOrder> woList = new List<WorkOrder>();
            for(WorkOrder wo : scope){
                if(wo.StepsApprovers__c.contains('NF')){
                    woList.add(wo);
                }
            }
    
            System.debug('DK woList: ' + woList);
    
            if(!woList.isEmpty()){
    
                Map<String, SObject> workOrderQueueMap = SV_Utilities.keyBy(woList, '%{Queues__c}%', true);
                Map<String, SObject> woMap = SV_Utilities.keyBy(woList, 'Id');
                Set<String> ptfIdSet = new Set<String>();
                Set<String> profiliSet = new Set<String>();
                Set<String> idCedSet = new Set<String>();
                // Set<String> idCedUffPrivateSet = new Set<String>();
                Set<String> idUffPrivateSet = new Set<String>();
                Set<String> idExecutiveSet = new Set<String>();
                Set<String> unitaOrganizzativaSet = new Set<String>();
                Set<String> divisionSet = new Set<String>();
                Set<String> macroDivisionSet = new Set<String>();
                Set<String> cedDRSet = new Set<String>();
                Map<String, ServiceModel__c> servceModelMap = new Map<String, ServiceModel__c>();
                for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_Division__c, PTF_MacroDivision__c FROM ServiceModel__c]){
                    
                    servceModelMap.put(serviceModel.Name.toUpperCase(), serviceModel);
                }
                for(WorkOrder wo : woList){
        
                    ptfIdSet.add(wo.PTF_Origine__c);
                    ptfIdSet.add(wo.PTF_Destinazione__c);
                    cedDRSet.add(wo.PTF_Origine__r.PTF_DirezioneRegionale__r.PTF_IdCed__c);
                    cedDRSet.add(wo.PTF_Destinazione__r.PTF_DirezioneRegionale__r.PTF_IdCed__c);
                }
                Map<String, SObject> ufficiPrivateMap = SV_Utilities.keyBy([SELECT Id, PTF_IdCEDDR__c, PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c WHERE PTF_IdCEDDR__c IN: cedDRSet], 'PTF_IdCEDDR__c');
                Map<String, SObject> ptfMap = SV_Utilities.keyBy([SELECT Id, Name, PTF_ModelloDiServizio__c,PTF_Pool__c,PTF_Banca__r.FinServ__BankNumber__c,PTF_UffPrivate__c, PTF_Filiale__r.PTF_UffPrivate__c, PTF_UffPrivate__r.PTF_IdCedPadre__c, PTF_Filiale__r.PTF_UffPrivate__r.PTF_IdCedPadre__c,
                PTF_Filiale__c, PTF_FIliale__r.PTF_IdCed__c, PTF_Capofila__c, PTF_Capofila__r.PTF_IdCed__c,
                PTF_Banca__c, PTF_Banca__r.PTF_IdCed__c, PTF_DirezioneRegionale__c, PTF_DirezioneRegionale__r.PTF_IdCed__c, PTF_Area__c, PTF_Area__r.PTF_IdCed__c
                FROM Wallet__c WHERE Id IN: ptfIdSet], 'Id');
                List<Group> queueList = [SELECT id, Name, DeveloperName FROM Group WHERE DeveloperName like: workOrderQueueMap.keySet()];
                
                Map<String, List<Group>> workOrderApproversMap = new Map<String, List<Group>>();
                for(Group queue : queueList){
    
                    String workOrderKey = queue.DeveloperName.split('_')[1];
                    // String parere = queue.DeveloperName.split('_')[2];
                    String step = queue.DeveloperName.split('_')[3];
                    if(pendingPIWActorSet.contains(queue.Id) || Integer.valueOf(step) >= Integer.valueOf((String)workOrderQueueMap.get('%' + workOrderKey + '%').get('Step__c'))){
    
                        if(!workOrderApproversMap.containsKey((String)workOrderQueueMap.get('%' + workOrderKey + '%').get('Id'))){
                            workOrderApproversMap.put((String)workOrderQueueMap.get('%' + workOrderKey + '%').get('Id'), new List<Group>());
                        }
                        workOrderApproversMap.get((String)workOrderQueueMap.get('%' + workOrderKey + '%').get('Id')).add(queue);
                    }
                }
    
                for(WorkOrder wo : woList){
    
                    List<String> stepsApprovers = wo.StepsApprovers__c.split('\\), ');
                    String selectedProcess = !String.isBlank(wo.Process__c) ? wo.Process__c : '';
                    ConfigurazioneSpostamenti__mdt configuration = (ConfigurazioneSpostamenti__mdt)configurazioniMap.get(wo.Subject);
                    Map<String, Object> configurationParsedJSON = (Map<String, Object>)JSON.deserializeUntyped((String)configuration.get('PTF_JSON_Approvatori__c'));
                    Map<String, Object> process = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configurationParsedJSON.get('process' + selectedProcess)));
                    Map<String, SObject> queueWoMap = SV_Utilities.keyBy(workOrderApproversMap.get(wo.Id), 'Name');
                    for(Integer i = 0; i < stepsApprovers.size(); i++){
    
                        if(stepsApprovers[i].contains('NF')){
    
                            List<String> stepApproversSplit = stepsApprovers[i].split(', ');
                            for(Integer k = 0; k < stepApproversSplit.size(); k++){
    
                                if(stepApproversSplit[k].contains('NF')){
                                    if(queueWoMap.containsKey('Approvers Step ' + String.valueOf(i + 1) + ' Queue' + String.valueOf(k + 1))){
    
                                        Map<String, Object> nextStep = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(process.get(String.valueOf(i+1))));
                                        Map<String, Object> approvatori = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(nextStep.get('approvatori')));
                                        List<String> approvatoriNameList = new List<String>(approvatori.keySet());
                                        String approvatoriKey = approvatoriNameList[k];
                                        //aggiungo profilo a Set
                                        profiliSet.add(approvatoriKey.split('#')[1]);
        
                                        Map<String, Object> profileObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(approvatori.get(approvatoriKey)));
                                        String livelloFunzionale = (String)profileObject.get('livelloFunzionale');
                                        String livelloFunzionalePadre = (String)profileObject.get('livelloFunzionalePadre');
                                        String direzione = profileObject.containsKey('direzione') ? (String)profileObject.get('direzione') : '';
                                        String campoFunzionale = '';
                                        String livelloFunzionaleFinale = '';
                                        String mds = '';
                                        String idCed = '';
                                        Wallet__c portafoglioInteressato;
                                        List<String> ruoloLDAP = !String.isBlank((String)profileObject.get('PTF_RuoloLDAP__c')) ? ((String)profileObject.get('PTF_RuoloLDAP__c')).split(',') : new List<String>();
                                        Boolean isPadre;
                                        if(!String.isBlank(livelloFunzionale)){
                
                                            isPadre = false;
                                            livelloFunzionaleFinale = livelloFunzionale;
                                        }else{
                
                                            isPadre = true;
                                            livelloFunzionaleFinale = livelloFunzionalePadre;
                                            System.debug('SV profileObject: ' + (String)profileObject.get('mds'));
                
                                            mds = profileObject.containsKey('mds') ? ((String)profileObject.get('mds')) : null;
                                        }
                                        
                                        if(String.isBlank(direzione)){
                
                                            portafoglioInteressato = (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
                                        }else{
                
                                            portafoglioInteressato = direzione == 'partenza' ? (Wallet__c)ptfMap.get(wo.PTF_Origine__c) : (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
                                        }
                                        
                                        if(isPadre || livelloFunzionaleFinale.equalsIgnoreCase('executive')){
                                            Wallet__c portafoglioPrivate = !String.IsBlank(portafoglioInteressato.PTF_UffPrivate__c) ? portafoglioInteressato :
                                            !String.IsBlank(((Wallet__c)ptfMap.get(wo.PTF_Origine__c)).PTF_UffPrivate__c) ? (Wallet__c)ptfMap.get(wo.PTF_Origine__c) : (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
                                            if(profileObject.containsKey('ufficioPrivate')){
                                                
                                                idUffPrivateSet.add(portafoglioInteressato.PTF_UffPrivate__c);
                                                idCedSet.add(portafoglioInteressato.PTF_UffPrivate__r.PTF_IdCedPadre__c);
                                                profiliSet.add('NEC_D.10');
                                            }else{
                                                
                                                idCed = livelloFunzionaleFinale.equalsIgnoreCase('Filiale') ? portafoglioInteressato.PTF_FIliale__r.PTF_IdCed__c :
                                                livelloFunzionaleFinale.equalsIgnoreCase('MM') ? portafoglioInteressato.PTF_Capofila__r.PTF_IdCed__c :
                                                livelloFunzionaleFinale.equalsIgnoreCase('DR') ? portafoglioInteressato.PTF_DirezioneRegionale__r.PTF_IdCed__c :
                                                livelloFunzionaleFinale.equalsIgnoreCase('Area') ? portafoglioInteressato.PTF_Area__r.PTF_IdCed__c :
                                                //NEW UFF PRIVATE
                                                livelloFunzionaleFinale.equalsIgnoreCase('executive') ? portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c : 
                                                //NEW UFF PRIVATE
                                                livelloFunzionaleFinale.equalsIgnoreCase('Fittizia') ? idCedFittiziaMap.get(portafoglioInteressato.PTF_Filiale__r.PTF_IdCed__c) : portafoglioInteressato.PTF_Banca__r.PTF_IdCed__c;
                                                idCedSet.add(idCed);
                                                if(livelloFunzionaleFinale.equalsIgnoreCase('executive')){
                                                    profiliSet.add('NEC_T.7');
                                                    idExecutiveSet.add(idCed);
                                                }
                                                String division = '';
                                                String macroDivision = '';
                        
                                                if(!String.isBlank(mds)){
                        
                                                    divisionSet.add(servceModelMap.get(mds.toUpperCase()).PTF_Division__c);
                                                    macroDivisionSet.add(servceModelMap.get(mds.toUpperCase()).PTF_MacroDivision__c);
                                                }
                                            }
                                        }else{
                                            
                                            //aggiungo IDCED a Set
                                            campoFunzionale = livelloFunzionaleFinale.equalsIgnoreCase('DR') ? 'PTF_DirezioneRegionale__c' : 
                                            livelloFunzionaleFinale.equalsIgnoreCase('Banca') ? 'PTF_Banca__c' :
                                            livelloFunzionaleFinale.equalsIgnoreCase('Area') ? 'PTF_Area__c' : 
                                            livelloFunzionaleFinale.equalsIgnoreCase('MM') ? 'PTF_Capofila__c' : 'PTF_Filiale__c';
                                            if(livelloFunzionaleFinale.equalsIgnoreCase('MM') && String.isBlank((String)portafoglioInteressato.get(campoFunzionale))){
                    
                                                campoFunzionale = 'PTF_Filiale__c';
                                            }
                                            if(campoFunzionale != 'Fittizia'){
    
                                                unitaOrganizzativaSet.add((String)portafoglioInteressato.get(campoFunzionale));
                                            }else{
    
                                                unitaOrganizzativaSet.add(idFittiziaMap.get(portafoglioInteressato.PTF_Filiale__r.PTF_idCed__c));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                unitaOrganizzativaSet.addAll(idUffPrivateSet);
                System.debug('DK profiliSet: ' + JSON.serialize(profiliSet));
                System.debug('DK unitaOrganizzativaSet: ' + JSON.serialize(unitaOrganizzativaSet));
                System.debug('DK divisionSet: ' + JSON.serialize(divisionSet));
                System.debug('DK macroDivisionSet: ' + JSON.serialize(macroDivisionSet));
                System.debug('DK idCedSet: ' + JSON.serialize(idCedSet));
                // System.debug('DK idCedUffPrivateSet: ' + JSON.serialize(idCedUffPrivateSet));
                // idCedSet.addAll(idCedUffPrivateSet);
                List<Contact> contactList = [SELECT id, AccountId, Account.FinServ__BankNumber__c, Account.PTF_MacroDivision__c, Account.PTF_Division__c, PTF_User__c, PTF_User__r.Profilo__c, PTF_User__r.PTF_RuoloLDAP__c, Account.PTF_Idced__c, Account.PTF_IdcedPadre__c, Account.PTF_UffPrivate__c
                FROM Contact 
                WHERE PTF_User__r.Profilo__c IN: profiliSet AND 
                PTF_User__r.isActive = true
                AND (
                    AccountId IN: unitaOrganizzativaSet 
                    OR (
                        (Account.PTF_Division__c IN: divisionSet OR Account.PTF_MacroDivision__c IN: macroDivisionSet) OR (Account.PTF_IdcedPadre__c IN: idCedSet)
                    )
                    OR Account.PTF_Idced__c IN: idCedSet
                )];
    
                System.debug('DK contactList.size: ' + contactList.size());
                System.debug('DK contactList: ' + JSON.serialize(contactList));
    
                Map<String, List<Contact>> contactMap = new map<String, List<Contact>>();
                for(Contact contact : contactList){
    
                    //LIVELLO FUNZIONALE BASE/ UFF PRIVATE
                    if(!contactMap.containsKey(contact.PTF_User__r.Profilo__c + '_' + contact.AccountId)){
    
                        contactMap.put(contact.PTF_User__r.Profilo__c + '_' + contact.AccountId, new List<Contact>());
                    }
                    contactMap.get(contact.PTF_User__r.Profilo__c + '_' + contact.AccountId).add(contact);

                    //LIVELLO EXECUTIVE
                    if(idExecutiveSet.contains(contact.Account.PTF_IdCed__c)){

                        if(!contactMap.containsKey(contact.Account.PTF_IdCed__c)){
        
                            contactMap.put(contact.Account.PTF_IdCed__c, new List<Contact>());
                        }
                        contactMap.get(contact.Account.PTF_IdCed__c).add(contact);
                    }
    
                    //LIVELLO BASE 2 - valutare rimozione
                    if(!contactMap.containsKey(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdCed__c)){

                        contactMap.put(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdCed__c, new List<Contact>());
                    }
                    contactMap.get(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdCed__c).add(contact);
    
                    //LIVELLO FUNZIONALE PADRE
                    if(!contactMap.containsKey(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c)){
    
                        contactMap.put(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c, new List<Contact>());
                    }
                    contactMap.get(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c).add(contact);
    
                    //LIVELLO FUNZIONALE PADRE DIVISION
                    if(!contactMap.containsKey(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c + '_' + contact.Account.PTF_Division__c)){
    
                        contactMap.put(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c + '_' + contact.Account.PTF_Division__c, new List<Contact>());
                    }
                    contactMap.get(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c + '_' + contact.Account.PTF_Division__c).add(contact);
    
                    //LIVELLO FUNZIONALE PADRE MACRODIVISION
                    if(!contactMap.containsKey(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c + '_' + contact.Account.PTF_MacroDivision__c)){
    
                        contactMap.put(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c + '_' + contact.Account.PTF_MacroDivision__c, new List<Contact>());
                    }
                    contactMap.get(contact.PTF_User__r.Profilo__c + '_' + contact.Account.PTF_IdcedPadre__c + '_' + contact.Account.PTF_MacroDivision__c).add(contact);
                }
                
                System.debug('DK contactMap: ' + JSON.serialize(contactMap));
                List<GroupMember> membersToInsert = new List<GroupMember>();
                Set<String> queueIdToEmptySet = new Set<String>(); 
                for(WorkOrder wo : woList){
    
                    String selectedProcess = !String.isBlank(wo.Process__c) ? wo.Process__c : '';
                    List<String> stepsApprovers = wo.StepsApprovers__c.split('\\), ');
                    System.debug('DK stepsApprovers: ' + JSON.serialize(stepsApprovers));
                    ConfigurazioneSpostamenti__mdt configuration = (ConfigurazioneSpostamenti__mdt)configurazioniMap.get(wo.Subject);
                    Map<String, Object> configurationParsedJSON = (Map<String, Object>)JSON.deserializeUntyped((String)configuration.get('PTF_JSON_Approvatori__c'));
                    Map<String, Object> process = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configurationParsedJSON.get('process' + selectedProcess)));
                    Map<String, SObject> queueWoMap = SV_Utilities.keyBy(workOrderApproversMap.get(wo.Id), 'Name');
                    // System.debug('DK queueMap: ' + JSOn.serialize(queueWoMap));
                    for(Integer i = 0; i < stepsApprovers.size(); i++){
    
                        if(stepsApprovers[i].contains('NF')){
    
                            List<String> stepApproversSplit = stepsApprovers[i].split(', ');
                            for(Integer k = 0; k < stepApproversSplit.size(); k++){
    
                                if(stepApproversSplit[k].contains('NF')){
    
                                    // System.debug('DK queueName: Approvers Step ' + String.valueOf(i + 1) + ' Queue' + String.valueOf(k + 1));
                                    if(queueWoMap.containsKey('Approvers Step ' + String.valueOf(i + 1) + ' Queue' + String.valueOf(k + 1))){
                                        
                                        Group queue = (Group)queueWoMap.get('Approvers Step ' + String.valueOf(i + 1) + ' Queue' + String.valueOf(k + 1));
                                        Map<String, Object> nextStep = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(process.get(String.valueOf(i+1))));
                                        Map<String, Object> approvatori = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(nextStep.get('approvatori')));
                                        List<String> approvatoriNameList = new List<String>(approvatori.keySet());
                                        String profileName = approvatoriNameList[k].split('#')[1];
                                        Map<String, Object> profileObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(approvatori.get(approvatoriNameList[k])));
                                        String livelloFunzionale = (String)profileObject.get('livelloFunzionale');
                                        String livelloFunzionalePadre = (String)profileObject.get('livelloFunzionalePadre');
                                        String direzione = profileObject.containsKey('direzione') ? (String)profileObject.get('direzione') : '';
                                        String campoFunzionale = '';
                                        String livelloFunzionaleFinale = '';
                                        String mds = '';
                                        String idCed = '';
                                        Wallet__c portafoglioInteressato;
                                        List<String> ruoloLDAP = !String.isBlank((String)profileObject.get('PTF_RuoloLDAP__c')) ? ((String)profileObject.get('PTF_RuoloLDAP__c')).split(',') : new List<String>();
                                        Boolean isPadre;
                                        if(String.isBlank(direzione)){
                                            portafoglioInteressato = (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
                                        }else{
                                            portafoglioInteressato = direzione == 'partenza' ? (Wallet__c)ptfMap.get(wo.PTF_Origine__c) : (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
                                        }
        
                                        if(!String.isBlank(livelloFunzionale)){
                                            isPadre = false;
                                            livelloFunzionaleFinale = livelloFunzionale;
                                        }else{
                                            isPadre = true;
                                            livelloFunzionaleFinale = livelloFunzionalePadre;
                                            // System.debug('SV profileObject: ' + (String)profileObject.get('mds'));
                                            mds = profileObject.containsKey('mds') ? ((String)profileObject.get('mds')) : null;
                                        }
                                        
                                        if(isPadre || livelloFunzionaleFinale.equalsIgnoreCase('executive')){
                                            if(profileObject.containsKey('ufficioPrivate')){
                                                Wallet__c portafoglioPrivate = !String.IsBlank(portafoglioInteressato.PTF_UffPrivate__c) ? portafoglioInteressato :
                                                !String.IsBlank(((Wallet__c)ptfMap.get(wo.PTF_Origine__c)).PTF_UffPrivate__c) ? (Wallet__c)ptfMap.get(wo.PTF_Origine__c) : (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
                                                if(contactMap.containsKey(profileName + '_' + portafoglioPrivate.PTF_UffPrivate__c)){
                                                        
                                                    for(Contact contact : contactMap.get(profileName + '_' + portafoglioPrivate.PTF_UffPrivate__c)){
    
                                                        GroupMember member = new GroupMember();
                                                        member.GroupId = queue.Id;
                                                        member.UserOrGroupId = contact.PTF_User__c;
                                                        membersToInsert.add(member);
                                                    }
                                                    queueIdToEmptySet.add(queue.Id);
                                                    stepApproversSplit[k] = profileName + ' RS - ' + today;
                                                }else if(stepApproversSplit[k].contains('NF - NEC_D.0') && contactMap.containsKey(portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c)){
                                                    for(Contact contact : contactMap.get(portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c)){
    
                                                        GroupMember member = new GroupMember();
                                                        member.GroupId = queue.Id;
                                                        member.UserOrGroupId = contact.PTF_User__c;
                                                        membersToInsert.add(member);
                                                    }
                                                    queueIdToEmptySet.add(queue.Id);
                                                    stepApproversSplit[k] = profileName + ' NF - NEC_D.10';
                                                }else{
                                                    stepApproversSplit[k] = stepApproversSplit[k].contains(' RS') ? stepApproversSplit[k].substringBefore(' RS') : stepApproversSplit[k];
                                                    stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringBefore(')') : stepApproversSplit[k];
                                                    stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringAfterLast('(') : stepApproversSplit[k];
                                                    if(stepApproversSplit[k].contains('STEP' + (i+1))){
                                                        stepApproversSplit[k] = stepApproversSplit[k].replaceAll('STEP' + (i+1), '');
                                                    }
                                                }
                                            }else{

                                                Wallet__c portafoglioPrivate = !String.IsBlank(portafoglioInteressato.PTF_UffPrivate__c) ? portafoglioInteressato :
                                                !String.IsBlank(((Wallet__c)ptfMap.get(wo.PTF_Origine__c)).PTF_UffPrivate__c) ? (Wallet__c)ptfMap.get(wo.PTF_Origine__c) : (Wallet__c)ptfMap.get(wo.PTF_Destinazione__c);
        
                                                idCed = livelloFunzionaleFinale.equalsIgnoreCase('Filiale') ? portafoglioInteressato.PTF_FIliale__r.PTF_IdCed__c :
                                                livelloFunzionaleFinale.equalsIgnoreCase('MM') ? portafoglioInteressato.PTF_Capofila__r.PTF_IdCed__c :
                                                livelloFunzionaleFinale.equalsIgnoreCase('DR') ? portafoglioInteressato.PTF_DirezioneRegionale__r.PTF_IdCed__c :
                                                livelloFunzionaleFinale.equalsIgnoreCase('Area') ? portafoglioInteressato.PTF_Area__r.PTF_IdCed__c : 
                                                //NEW UFF PRIVATE
                                                livelloFunzionaleFinale.equalsIgnoreCase('executive') ? portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c : 
                                                livelloFunzionaleFinale.equalsIgnoreCase('Fittizia') ? idCedFittiziaMap.get(portafoglioInteressato.PTF_Filiale__r.PTF_IdCed__c) : portafoglioInteressato.PTF_Banca__r.PTF_IdCed__c;
                                                //NEW UFF PRIVATE
                                                String division = '';
                                                String macroDivision = '';
                                                System.debug('DK livelloFunzionaleFinale: ' + livelloFunzionaleFinale);
                                                System.debug('DK idCed: ' + idCed);
                                                System.debug('DK portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c: ' + portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c);
                                                System.debug('DK mds: ' + mds);
                                                System.debug('DK PRESENTE: ' + (livelloFunzionaleFinale.equalsIgnoreCase('executive') && contactMap.containsKey(idCed)));
                                                
                                                if(String.isBlank(mds)){
        
                                                    if(livelloFunzionaleFinale.equalsIgnoreCase('executive') && contactMap.containsKey(idCed)){
                                                    
                                                        for(Contact contact : contactMap.get(idCed)){
        
                                                            GroupMember member = new GroupMember();
                                                            member.GroupId = queue.Id;
                                                            member.UserOrGroupId = contact.PTF_User__c;
                                                            membersToInsert.add(member);
                                                        }
                                                        queueIdToEmptySet.add(queue.Id);
                                                        stepApproversSplit[k] = 'NEC_D.10' + ' RS - ' + today;
                                                    }else if(contactMap.containsKey(profileName + '_' + idCed)){
        
                                                        for(Contact contact : contactMap.get(profileName + '_' + idCed)){
        
                                                            GroupMember member = new GroupMember();
                                                            member.GroupId = queue.Id;
                                                            member.UserOrGroupId = contact.PTF_User__c;
                                                            membersToInsert.add(member);
                                                        }
                                                        queueIdToEmptySet.add(queue.Id);
                                                        stepApproversSplit[k] = profileName + ' RS - ' + today;
                                                    }else{
                                                        stepApproversSplit[k] = stepApproversSplit[k].contains(' RS') ? stepApproversSplit[k].substringBefore(' RS') : stepApproversSplit[k];
                                                        stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringBefore(')') : stepApproversSplit[k];
                                                        stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringAfterLast('(') : stepApproversSplit[k];
                                                        if(stepApproversSplit[k].contains('STEP' + (i+1))){
                                                            stepApproversSplit[k] = stepApproversSplit[k].replaceAll('STEP' + (i+1), '');
                                                        }
                                                    }
                                                }else{
                        
                                                    if(contactMap.containsKey(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_Division__c)){
        
                                                        for(Contact contact : contactMap.get(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_Division__c)){
        
                                                            GroupMember member = new GroupMember();
                                                            member.GroupId = queue.Id;
                                                            member.UserOrGroupId = contact.PTF_User__c;
                                                            membersToInsert.add(member);
                                                        }
                                                        queueIdToEmptySet.add(queue.Id);
                                                        stepApproversSplit[k] = profileName + ' RS - ' + today;
                                                    }else if(contactMap.containsKey(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_MacroDivision__c)) {
                                                        
                                                        for(Contact contact : contactMap.get(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_MacroDivision__c)){
        
                                                            GroupMember member = new GroupMember();
                                                            member.GroupId = queue.Id;
                                                            member.UserOrGroupId = contact.PTF_User__c;
                                                            membersToInsert.add(member);
                                                        }
                                                        queueIdToEmptySet.add(queue.Id);
                                                        stepApproversSplit[k] = profileName + ' RS - ' + today;
                                                    }else{
                                                        stepApproversSplit[k] = stepApproversSplit[k].contains(' RS') ? stepApproversSplit[k].substringBefore(' RS') : stepApproversSplit[k];
                                                        stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringBefore(')') : stepApproversSplit[k];
                                                        stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringAfterLast('(') : stepApproversSplit[k];
                                                        if(stepApproversSplit[k].contains('STEP' + (i+1))){
                                                            stepApproversSplit[k] = stepApproversSplit[k].replaceAll('STEP' + (i+1), '');
                                                        }
                                                    }
                                                }
                                            }
                                        }else{
                                            
                                            //aggiungo IDCED a Set
                                            campoFunzionale = livelloFunzionaleFinale.equalsIgnoreCase('DR') ? 'PTF_DirezioneRegionale__c' : 
                                            livelloFunzionaleFinale.equalsIgnoreCase('Banca') ? 'PTF_Banca__c' :
                                            livelloFunzionaleFinale.equalsIgnoreCase('Area') ? 'PTF_Area__c' : 
                                            livelloFunzionaleFinale.equalsIgnoreCase('MM') ? 'PTF_Capofila__c' : 'PTF_Filiale__c';
                                            if(livelloFunzionaleFinale.equalsIgnoreCase('MM') && String.isBlank((String)portafoglioInteressato.get(campoFunzionale))){
                    
                                                campoFunzionale = 'PTF_Filiale__c';
                                            }
        
                                            String chiave = campoFunzionale != 'Fittizia' ?(String)portafoglioInteressato.get(campoFunzionale) : idFittiziaMap.get(portafoglioInteressato.PTF_Filiale__r.PTF_idCed__c);
                                            if(contactMap.containsKey(profileName + '_' + chiave)){
        
                                                for(Contact contact : contactMap.get(profileName + '_' + chiave)){
        
                                                    GroupMember member = new GroupMember();
                                                    member.GroupId = queue.Id;
                                                    member.UserOrGroupId = contact.PTF_User__c;
                                                    membersToInsert.add(member);
                                                }
                                                queueIdToEmptySet.add(queue.Id);
                                                stepApproversSplit[k] = profileName + ' RS - ' + today;
                                            }else{
                                                stepApproversSplit[k] = stepApproversSplit[k].contains(' RS') ? stepApproversSplit[k].substringBefore(' RS') : stepApproversSplit[k];
                                                stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringBefore(')') : stepApproversSplit[k];
                                                stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringAfterLast('(') : stepApproversSplit[k];
                                                if(stepApproversSplit[k].contains('STEP' + (i+1))){
                                                    stepApproversSplit[k] = stepApproversSplit[k].replaceAll('STEP' + (i+1), '');
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    
                                    stepApproversSplit[k] = stepApproversSplit[k].contains(' RS') ? stepApproversSplit[k].substringBefore(' RS') : stepApproversSplit[k];
                                    stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringBefore(')') : stepApproversSplit[k];
                                    stepApproversSplit[k] = stepApproversSplit[k].contains('(') ? stepApproversSplit[k].substringAfterLast('(') : stepApproversSplit[k];
                                    if(stepApproversSplit[k].contains('STEP' + (i+1))){
                                        stepApproversSplit[k] = stepApproversSplit[k].replaceAll('STEP' + (i+1), '');
                                    }
                                }
                            }
                            List<String> listSplit = new List<String>(); 
                            for(string approverString : stepApproversSplit){
                                listSplit.add(approverString.replaceAll('STEP' + (i+1) + '\\(', ''));
                            }
                            
                            System.debug('DK stepApproversSplit: ' + JSON.serialize(listSplit));
                            stepsApprovers[i] = 'STEP' + (i+1) + '(' + String.join(listSplit, ', ');
                            if((i + 1) == stepsApprovers.size()){

                                stepsApprovers[i] += ')';
                            }
                        }
                    }
    
                    String stepsApproversString = String.join(stepsApprovers, '), ');
                    woToUpdate.add(new WorkOrder(Id = wo.Id, StepsApprovers__c = stepsApproversString, HasNF__c = stepsApproversString.contains('NF')));
                }
    
                System.debug('DK membersToInsert: ' + JSON.serialize(membersToInsert));
                System.debug('DK queueIdToEmptySet: ' + JSON.serialize(queueIdToEmptySet));
                System.debug('DK woToUpdate: ' + JSON.serialize(woToUpdate));
        
                Savepoint sp = Database.setSavepoint();
                try {
                    
                    delete [SELECT Id FROM GroupMember WHERE GroupId IN: queueIdToEmptySet];
                    insert membersToInsert;
                    /*if(!woToUpdate.isEmpty()){
                
                        update woToUpdate;
                    }*/
                } catch (Exception ex) {
                    Database.rollback(sp);
                    System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
                }
            }
        } catch (Exception exc) {
            // intercept the error
            // set a boolean variable to true so the process is "blocked"
            System.debug(NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage() + ' at: ' + exc.getStackTraceString());
            testoMail = NOME_CLASSE+' - An exception occurred during create records : '+exc.getMessage()+'<br/>'+exc.getStackTraceString();
            mandaMail('Errore',testoMail);
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

        if(!woToUpdate.isEmpty()){
            OnWorkOrderTriggerHandler.skip = true;
            update woToUpdate;
            OnWorkOrderTriggerHandler.skip = false;
        }

        testoMail = testoMail + NOME_CLASSE + ' Apex job ha processato '+a.TotalJobItems+' job con '+a.NumberOfErrors+' errori.<br/>';
        
        if (debug.Verbose__c) {
        	mandaMail('Recap',testoMail);
        }
    }

    global void execute(SchedulableContext SC) {
        
        Id batchJobId = Database.executeBatch(new Batch_ReassignFromD0(), 5);
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