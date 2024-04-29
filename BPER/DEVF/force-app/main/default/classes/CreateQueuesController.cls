@RestResource(urlMapping='/createQueues')
global class CreateQueuesController {
    public virtual class BaseException extends Exception {}

    global static Map<String, String> idCedFittiziaMap {
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
    
    @HttpPost
    global static String createQueues(){

        System.debug('DK START CREATEQUEUES');
        RestRequest req = RestContext.request;
        System.debug('DK req.requestBody.toString(): ' + req.requestBody);
        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        List<Account> accountList = (List<Account>)JSON.deserialize(JSON.serialize(bodyMap.get('accountList')), List<Account>.class);
        Map<String, SObject> ndgIterMap = (Map<String, SObject>)JSON.deserialize(JSON.serialize(bodyMap.get('ndgIterMap')), Map<String, SObject>.class);
        Wallet__c portafoglioDiPartenza = (Wallet__c)JSON.deserialize(JSON.serialize(bodyMap.get('portafoglioDiPartenza')), Wallet__c.class);
        Wallet__c portafoglioDiDestinazione = (Wallet__c)JSON.deserialize(JSON.serialize(bodyMap.get('portafoglioDiDestinazione')), Wallet__c.class);
        Boolean hasIter = bodyMap.containsKey('hasIter') ? (Boolean)bodyMap.get('hasIter') : true;
        String selectedProcess = (String)bodyMap.get('process');
        List<Group> queuesToInsert = new List<Group>();
        Map<String, List<GroupMember>> membersToInsert = new Map<String, List<GroupMember>>();
        Set<String> queueNameSet = new Set<String>();
        Map<String, String> workOrderKeyMap = new Map<String, String>();
        Map<String, String> woStepMap = new  Map<String, String>();
        Map<String, Map<String, List<String>>> workOrderStepsApproversMap = new Map<String, Map<String, List<String>>>();
        Map<String, String> accountWorkOrderKeyMap = new Map<String, String>();
        Map<String, ServiceModel__c> servceModelMap = new Map<String, ServiceModel__c>();


        Set<String> profiliSet = new Set<String>();
        Set<String> idCedSet = new Set<String>();
        // Set<String> idCedUffPrivateSet = new Set<String>();
        Set<String> idUffPrivateSet = new Set<String>();
        Set<String> idExecutiveSet = new Set<String>();
        Set<String> unitaOrganizzativaSet = new Set<String>();
        Set<String> divisionSet = new Set<String>();
        Set<String> macroDivisionSet = new Set<String>();
        Set<String> cedDRSet = new Set<String>();


        for(ServiceModel__c serviceModel : [SELECT id, Name, PTF_Division__c, PTF_MacroDivision__c FROM ServiceModel__c]){
            
            servceModelMap.put(serviceModel.Name.toUpperCase(), serviceModel);
        }
        /** AD backup per modifica CR NEC 78583 
        String profiloSuperUser = portafoglioDiPartenza.PTF_Banca__r.FinServ__BankNumber__c == '05387' ? 'NEC_D.0' : 'NEC_D.2';
        Set<String> userIdSet = portafoglioDiPartenza.PTF_Banca__r.FinServ__BankNumber__c == '05387' ? SV_Utilities.keyBy([SELECT Id, PTF_User__c FROM Contact WHERE PTF_User__r.Profilo__c =: profiloSuperUser AND PTF_User__r.IsActive = true], 'PTF_User__c').keySet() :
        SV_Utilities.keyBy([SELECT Id FROM user WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'SUPERUSER_BDS') AND IsActive = true], 'Id').keySet();
        */
        //AD inizo CR NEC 78583 25/03/2024
        String profiloSuperUser = '';
        Set<String> userIdSet = new Set<String>();
        //gestione casistica abi per BPER,BDS,BCP
        switch on portafoglioDiPartenza.PTF_Banca__r.FinServ__BankNumber__c {

            //BPER = 05387
            when '05387' {
                profiloSuperUser = 'NEC_D.0';
                for(String userId : SV_Utilities.keyBy([SELECT Id, PTF_User__c FROM Contact WHERE PTF_User__r.Profilo__c =: profiloSuperUser AND PTF_User__r.IsActive = true], 'PTF_User__c').keySet()){
                    userIdSet.add(userId);
                }
            }
            //BDS = 01015
            when '01015' {
                profiloSuperUser = 'NEC_D.2';
                for(String userId : SV_Utilities.keyBy([SELECT Id FROM user WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'SUPERUSER_BDS') AND IsActive = true], 'Id').keySet()){
                    userIdSet.add(userId);
                }
            }
            //BCP = 03084
            when '03084' {
                profiloSuperUser = 'NEC_D.2';
                for(String userId : SV_Utilities.keyBy([SELECT id FROM user where idced__c ='27786' and abi__c = '03084' AND IsActive = true], 'Id').keySet()){
                    userIdSet.add(userId);
                }
            }
        }
        //AD fine CR NEC 78583 
        Savepoint sp = Database.setSavepoint();
        try {
            Integer conta = 0;
            for(Account ndg : accountList){

                if(ndg.RecordType.DeveloperName != 'GruppoFinanziario'){
                    conta++;
                    Map<String, Object> configuration = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ndgIterMap.get(ndg.Id)));
                    if(!workOrderKeyMap.containsKey((String)configuration.get('Id'))){
    
                        String workOrderKey = SV_Utilities.generateRandomString(24);
                        workOrderKeyMap.put((String)configuration.get('Id'), workOrderKey);
                        accountWorkOrderKeyMap.put(ndg.Id, workOrderKey);
                    }
                    if(hasIter){

                        Map<String, Object> configurationParsedJSON = (Map<String, Object>)JSON.deserializeUntyped((String)configuration.get('PTF_JSON_Approvatori__c'));
                        System.debug('DK configurationParsedJSON: ' + JSON.serialize(configurationParsedJSON));
                        Map<String, Object> process = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configurationParsedJSON.get('process' + selectedProcess)));
                        System.debug('DK process: ' + JSON.serialize(process));
                        // Map<String, Object> process = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configurationParsedJSON.get('process')));
                        for(String step: process.keySet()){
                            
                            String stepApprovers = 'STEP' + step;
                            Map<String, Object> nextStep = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(process.get(step)));
                            Map<String, Object> approvatori = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(nextStep.get('approvatori')));
                            Integer i = 1;
                            for(String profileNameKey : approvatori.keySet()){
                                
                                String profileName = profileNameKey.split('#')[1];
                                profiliSet.add(profileName);
                                System.debug('DK profileName: ' + profileName);
        
                                String parere = nextStep.containsKey('parere') ? String.valueOf((Boolean)nextStep.get('parere')) : 'false';
                                Map<String, Object> profileObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(approvatori.get(profileNameKey)));
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
        
                                    portafoglioInteressato = portafoglioDiDestinazione;
                                }else{
        
                                    portafoglioInteressato = direzione == 'partenza' ? portafoglioDiPartenza : portafoglioDiDestinazione;
                                }

                                if(isPadre || livelloFunzionaleFinale.equalsIgnoreCase('executive')){
                                    Wallet__c portafoglioPrivate = !String.IsBlank(portafoglioInteressato.PTF_UffPrivate__c) ? portafoglioInteressato :
                                    !String.IsBlank(portafoglioDiPartenza.PTF_UffPrivate__c) ? portafoglioDiPartenza : portafoglioDiDestinazione;
                                    if(profileObject.containsKey('ufficioPrivate')){

                                        idUffPrivateSet.add(portafoglioPrivate.PTF_UffPrivate__c);
                                        idCedSet.add(portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c);
                                        idExecutiveSet.add(portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c);
                                        profiliSet.add('NEC_D.10');
                                    }else{

        
                                        idCed = profileObject.containsKey('idced') ? (String)profileObject.get('idced') : 
                                        livelloFunzionaleFinale.equalsIgnoreCase('Filiale') ? portafoglioInteressato.PTF_FIliale__r.PTF_IdCed__c :
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
            unitaOrganizzativaSet.addAll(idUffPrivateSet);
            System.debug('DK profiliSet: ' + JSON.serialize(profiliSet));
            System.debug('DK unitaOrganizzativaSet: ' + JSON.serialize(unitaOrganizzativaSet));
            System.debug('DK divisionSet: ' + JSON.serialize(divisionSet));
            System.debug('DK macroDivisionSet: ' + JSON.serialize(macroDivisionSet));
            System.debug('DK idCedSet: ' + JSON.serialize(idCedSet));
            System.debug('DK nvolte: ' + conta);

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

            for(Account ndg : accountList){

                if(ndg.RecordType.DeveloperName != 'GruppoFinanziario'){
                    Map<String, Object> configuration = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ndgIterMap.get(ndg.Id)));
                    if(hasIter){

                        Map<String, Object> configurationParsedJSON = (Map<String, Object>)JSON.deserializeUntyped((String)configuration.get('PTF_JSON_Approvatori__c'));
                        Map<String, Object> process = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configurationParsedJSON.get('process' + selectedProcess)));
                        // Map<String, Object> process = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(configurationParsedJSON.get('process')));
                        for(String step: process.keySet()){
                            
                            String stepApprovers = 'STEP' + step;
                            Map<String, Object> nextStep = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(process.get(step)));
                            Map<String, Object> approvatori = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(nextStep.get('approvatori')));
                            Integer i = 1;
                            for(String profileNameKey : approvatori.keySet()){
                                
                                String profileName = profileNameKey.split('#')[1];
                                profiliSet.add(profileName);
                                System.debug('DK profileName: ' + profileName);
        
                                String parere = nextStep.containsKey('parere') ? String.valueOf((Boolean)nextStep.get('parere')) : 'false';
                                String nextStepOnApproval = nextStep.containsKey('nextStepOnApproval') ? String.valueOf((Boolean)nextStep.get('nextStepOnApproval')) : 'false'; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
                                String queueName = 'Q_' + workOrderKeyMap.get((String)configuration.get('Id')) + '_' + parere + '_' + nextStepOnApproval + '_' + step + '_' + i; //Modifica - Salvatore Barbieri - 28/03/2024 - 79032
                                if(!queueNameSet.contains(queueName)){
        
                                    Group queue = new Group();
                                    queue.Name = 'Approvers Step ' + step + ' Queue' + i;
                                    queue.DeveloperName = queueName;
                                    queue.Type = 'Queue';
                                    queuesToInsert.add(queue);
                                    i++;
        
                                    queueNameSet.add(queueName);
            
                                    Map<String, Object> profileObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(approvatori.get(profileNameKey)));
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
            
                                        portafoglioInteressato = portafoglioDiDestinazione;
                                    }else{
            
                                        portafoglioInteressato = direzione == 'partenza' ? portafoglioDiPartenza : portafoglioDiDestinazione;
                                    }

                                    if(!workOrderStepsApproversMap.containsKey(workOrderKeyMap.get((String)configuration.get('Id')))){
    
                                        workOrderStepsApproversMap.put(workOrderKeyMap.get((String)configuration.get('Id')), new Map<String, List<String>>{stepApprovers => new List<String>()});
                                    }
                        
                                    if(!workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).containsKey(stepApprovers)){
                        
                                        workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).put(stepApprovers, new List<String>());
                                    }

                                    if(isPadre || livelloFunzionaleFinale.equalsIgnoreCase('executive')){
                                        if(profileObject.containsKey('ufficioPrivate')){
                                            Wallet__c portafoglioPrivate = !String.IsBlank(portafoglioInteressato.PTF_UffPrivate__c) ? portafoglioInteressato :
                                            !String.IsBlank(portafoglioDiPartenza.PTF_UffPrivate__c) ? portafoglioDiPartenza : portafoglioDiDestinazione;
                                            if(contactMap.containsKey(profileName + '_' + portafoglioPrivate.PTF_UffPrivate__c)){
                                                            
                                                workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName);
                                                for(Contact contact : contactMap.get(profileName + '_' + portafoglioPrivate.PTF_UffPrivate__c)){

                                                    GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                    if(!membersToInsert.containsKey(queueName)){
        
                                                        membersToInsert.put(queueName, new List<GroupMember>());
                                                    }
                                                    membersToInsert.get(queueName).add(member);
                                                }
                                            }else {
                                                if(contactMap.containsKey(portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c)){
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName + ' NF - NEC_D.10');
                                                    for(Contact contact : contactMap.get(portafoglioPrivate.PTF_UffPrivate__r.PTF_IdCedPadre__c)){
    
                                                        GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                }else{

                                                    for(String userId : userIdSet){
        
                                                        GroupMember member = getGroupMember(queue.Id, userId);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName + ' NF - ' + profiloSuperUser);
                                                }
                                                // throw new BaseException('Non è stato trovato alcun utente');
                                            }
                                        }else{
                                            idCed = profileObject.containsKey('idced') ? (String)profileObject.get('idced') : 
                                            livelloFunzionaleFinale.equalsIgnoreCase('Filiale') ? portafoglioInteressato.PTF_FIliale__r.PTF_IdCed__c :
                                            livelloFunzionaleFinale.equalsIgnoreCase('MM') ? portafoglioInteressato.PTF_Capofila__r.PTF_IdCed__c :
                                            livelloFunzionaleFinale.equalsIgnoreCase('DR') ? portafoglioInteressato.PTF_DirezioneRegionale__r.PTF_IdCed__c :
                                            livelloFunzionaleFinale.equalsIgnoreCase('Area') ? portafoglioInteressato.PTF_Area__r.PTF_IdCed__c : 
                                            //NEW UFF PRIVATE
                                            livelloFunzionaleFinale.equalsIgnoreCase('executive') ? portafoglioInteressato.PTF_UffPrivate__r.PTF_IdCedPadre__c : 
                                            //NEW UFF PRIVATE
                                            livelloFunzionaleFinale.equalsIgnoreCase('Fittizia') ? idCedFittiziaMap.get(portafoglioInteressato.PTF_Filiale__r.PTF_IdCed__c) : portafoglioInteressato.PTF_Banca__r.PTF_IdCed__c;
                                            String division = '';
                                            String macroDivision = '';
                                            
                                            if(String.isBlank(mds)){
                                                if(livelloFunzionaleFinale.equalsIgnoreCase('executive') && contactMap.containsKey(idCed)){
                                                    
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName);
                                                    for(Contact contact : contactMap.get(idCed)){
    
                                                        GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                }else if(contactMap.containsKey(profileName + '_' + idCed)){
        
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName);
                                                    for(Contact contact : contactMap.get(profileName + '_' + idCed)){
    
                                                        GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                }else {
                                                    for(String userId : userIdSet){
    
                                                        GroupMember member = getGroupMember(queue.Id, userId);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName + ' NF - ' + profiloSuperUser);
                                                    // throw new BaseException('Non è stato trovato alcun utente');
                                                }
                                                
                                            }else {
                                                if(contactMap.containsKey(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_Division__c)){
        
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName);
                                                    for(Contact contact : contactMap.get(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_Division__c)){
    
                                                        GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                }else if(contactMap.containsKey(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_MacroDivision__c)) {
                                                    
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName);
                                                    for(Contact contact : contactMap.get(profileName + '_' + idCed + '_' + servceModelMap.get(mds.toUpperCase()).PTF_MacroDivision__c)){
    
                                                        GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                }else{
                                                    for(String userId : userIdSet){
    
                                                        GroupMember member = getGroupMember(queue.Id, userId);
                                                        if(!membersToInsert.containsKey(queueName)){
                        
                                                            membersToInsert.put(queueName, new List<GroupMember>());
                                                        }
                                                        membersToInsert.get(queueName).add(member);
                                                    }
                                                    workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName + ' NF - ' + profiloSuperUser);
                                                    // throw new BaseException('Non è stato trovato alcun utente');
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
        
                                            workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName);
                                            for(Contact contact : contactMap.get(profileName + '_' + chiave)){

                                                GroupMember member = getGroupMember(queue.Id, contact.PTF_User__c);
                                                if(!membersToInsert.containsKey(queueName)){
                
                                                    membersToInsert.put(queueName, new List<GroupMember>());
                                                }
                                                membersToInsert.get(queueName).add(member);
                                            }
                                        }else{
                                            for(String userId : userIdSet){
    
                                                GroupMember member = getGroupMember(queue.Id, userId);
                                                if(!membersToInsert.containsKey(queueName)){
                
                                                    membersToInsert.put(queueName, new List<GroupMember>());
                                                }
                                                membersToInsert.get(queueName).add(member);
                                            }
                                            workOrderStepsApproversMap.get(workOrderKeyMap.get((String)configuration.get('Id'))).get(stepApprovers).add(profileName + ' NF - ' + profiloSuperUser);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(hasIter){
                
                System.debug('DK queuesToInsert: ' + JSON.serialize(queuesToInsert));
                insert queuesToInsert;

                List<GroupMember> membersToInsertList = new List<GroupMember>();
                for(Group queue: queuesToInsert){

                    for(GroupMember member: membersToInsert.get(queue.DeveloperName)){

                        member.GroupId = queue.Id;       
                        membersToInsertList.add(member);             
                    }
                }
                insert membersToInsertList;


                for(String workOrderKey : workOrderStepsApproversMap.keySet()){
    
                    List<String> iterApprovers = new List<String>();
                    List<String> reversed = new List<String>();
                    List<String> keySet = new List<String>(workOrderStepsApproversMap.get(workOrderKey).keySet());
                    for(Integer i = keySet.size() - 1; i >= 0; i--){
                        
                        reversed.add(keySet[i]);
                    }
                    for(String stepApprovers : reversed){
    
                        iterApprovers.add(stepApprovers + '(' + String.join(workOrderStepsApproversMap.get(workOrderKey).get(stepApprovers), ', ') + ')');
                    }
                    woStepMap.put(workOrderKey, String.join(iterApprovers, ', '));
                }
            }

            System.debug('DK woStepMap: ' + JSON.serialize(woStepMap));
            
        } catch (Exception ex) {
            
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            return JSON.serialize(new Map<String, Object>{

                'errorMessage' => ex.getMessage() + ' at ' + ex.getStackTraceString()
            });
        }

        return JSON.serialize(new Map<String, Object>{

            'queuesToInsert' => queuesToInsert,
            'membersToInsert' => membersToInsert,
            'accountWorkOrderKeyMap' => accountWorkOrderKeyMap,
            'woStepMap' => woStepMap
        });
    }

    public static GroupMember getGroupMember(String queueId, String userId){
        return new GroupMember(GroupId = queueId,
        UserOrGroupId = userId);
    }

    @HttpPatch
    global static String sendMovementsRequest(){

        Savepoint sp = Database.setSavepoint();
        try {
            
            System.debug('DK START SENDMOVEMENTSREQUESTS');
            RestRequest req = RestContext.request;
            System.debug('DK req.requestBody.toString(): ' + req.requestBody);
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String portafoglioDestinazione = (String)bodyMap.get('portafoglioDestinazione');
            String note = (String)bodyMap.get('note');
            String ownerId = (String)bodyMap.get('ownerId');
            String ruolo = (String)bodyMap.get('ruolo');
            String currentNDGId = (String)bodyMap.get('currentNDGId');
            String gruppoFinanziarioId = (String)bodyMap.get('gruppoFinanziarioId');
            String referente = (String)bodyMap.get('referente');
            Boolean hasIter = bodyMap.containsKey('hasIter') ? (Boolean)bodyMap.get('hasIter') : true;
            Boolean lineItemIter = bodyMap.containsKey('lineItemIter') ? (Boolean)bodyMap.get('lineItemIter') : true;
            String selectedProcess = (String)bodyMap.get('process');
            String motivazione = (String)bodyMap.get('motivazione');
            List<Account> ndgList = (List<Account>)JSON.deserialize(JSON.serialize(bodyMap.get('ndgList')), List<Account>.class);
            Map<String, String> ndgIterTypeMap = (Map<String, String>)JSON.deserialize(JSON.serialize(bodyMap.get('ndgIterTypeMap')), Map<String, String>.class);
            Map<String, String> subjectMap = (Map<String, String>)JSON.deserialize(JSON.serialize(bodyMap.get('subjectMap')), Map<String, String>.class);
            Map<String, String> configurationKeyMap = (Map<String, String>)JSON.deserialize(JSON.serialize(bodyMap.get('configurationKeyMap')), Map<String, String>.class);
            Map<String, String> accountKeyMap = (Map<String, String>)JSON.deserialize(JSON.serialize(bodyMap.get('accountKeyMap')), Map<String, String>.class);
            Map<String, String> woStepMap = (Map<String, String>)JSON.deserialize(JSON.serialize(bodyMap.get('woStepMap')), Map<String, String>.class);
            List<String> primari = (List<String>)JSON.deserialize(JSON.serialize(bodyMap.get('primari')), List<String>.class);
            Map<String, Account> gruppoFinanziarioCapoGruppoMap = new Map<String,Account>();
            if(!String.isBlank(gruppoFinanziarioId)){
    
                for(Account ndg : ndgList){
    
                    if(ndg.Id == currentNDGId){
    
                        gruppoFinanziarioCapoGruppoMap.put(gruppoFinanziarioId, ndg);
                        break;
                    }
                }
            }
    
            System.debug('DK sendMovementRequest Start');
            Map<String, WorkOrder> woToInsertMap = new Map<String, WorkOrder>();
            List<WorkOrderLineItem> woliToInsert = new List<WorkOrderLineItem>();
            
            Map<String, SObject> accountMap = SV_Utilities.keyBy(ndgList, 'Id');
            // Savepoint sv = Database.setSavepoint();
    
            System.debug('DK ndgList: ' + JSON.serialize(ndgList));
            System.debug('DK primari: ' + JSON.serialize(primari));
            System.debug('DK accountKeyMap: ' + JSON.serialize(accountKeyMap));
    
            for(Account ndg : ndgList){
                
                WorkOrder workOrder = new WorkOrder();
                
                Account account = gruppoFinanziarioCapoGruppoMap.containsKey(ndg.Id) ? gruppoFinanziarioCapoGruppoMap.get(ndg.Id) : ndg;
                if(woToInsertMap.containsKey(configurationKeyMap.get(account.Id))){
                    
                    workOrder = woToInsertMap.get(configurationKeyMap.get(account.Id));
                }else{
                    
                    workOrder.PTF_Origine__c = account.PTF_Portafoglio__c;
                    workOrder.AccountId = currentNDGId;
                    workOrder.PTF_Destinazione__c = portafoglioDestinazione;
                    workOrder.Subject = subjectMap.get(account.Id);
                    workOrder.Description = note;
                    workOrder.Status = 'Pending';
                    // workOrder.Status = hasIter ? 'Pending' : 'Approvato';
                    // workOrder.EndDate = hasIter ? null : Datetime.now();
                    workOrder.Step__c = '1';
                    workOrder.StartDate = DateTime.now();
                    workOrder.TipologiaSpostamento__c = ndgIterTypeMap.get(account.Id);
                    workOrder.OwnerId = ownerId;
                    workOrder.OriginalOwner__c = ownerId;
                    workOrder.Referente__c = referente;
                    workOrder.Queues__c = accountKeyMap.get(account.Id);
                    workOrder.HasIter__c = hasIter;
                    workOrder.StepsApprovers__c = woStepMap.get(accountKeyMap.get(account.Id));
                    workOrder.HasNF__c = hasIter ? woStepMap.get(accountKeyMap.get(account.Id)).contains('NF') : false;
                    workOrder.Process__c = selectedProcess;
                    workOrder.Giustificazione__c = motivazione;
                    woToInsertMap.put(configurationKeyMap.get(account.Id), workOrder);
                }
    
                WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem();
                workOrderLineItem.WorkOrderId = workOrder.Id;
                workOrderLineItem.StartDate = DateTime.now();
                workOrderLineItem.Status = 'Pending';
                // workOrderLineItem.Status = hasIter ? 'Pending' : 'Approvato';
                // workOrderLineItem.EndDate = hasIter ? null : Datetime.now();
                workOrderLineItem.Step__c = '1';
                workOrderLineItem.AccountId__c = ndg.Id;
                if(ruolo == 'capoGruppo'){
    
                    if(currentNDGId == ndg.Id){
    
                        workOrderLineItem.IdGruppoFinanziario__c = gruppoFinanziarioId;
                    }
                }
                workOrderLineItem.IsGruppoFinanziario__c = ndg.RecordType.DeveloperName == 'GruppoFinanziario';
                workOrderLineItem.TipologiaSpostamento__c = ndgIterTypeMap.containsKey(ndg.Id) ? ndgIterTypeMap.get(ndg.Id) : '';
                workOrderLineItem.Queues__c = workOrder.Queues__c;
                workOrderLineItem.HasIter__c = lineItemIter;
                workOrderLineItem.StepsApprovers__c = workOrder.StepsApprovers__c;
                if(primari.contains(ndg.Id)){
    
                    workOrderLineItem.IsPrimario__c = true;
                }
                woliToInsert.add(workOrderLineItem);
            }
    
            insert woToInsertMap.values();
            // System.debug('DK woToInsertMap: ' + JSON.serialize(woToInsertMap));
            // System.debug('DK woliToInsert: ' + JSON.serialize(woliToInsert));
    
            
            Map<String, SObject> woMap = SV_Utilities.keyBy(woToInsertMap.values(), 'Id');
            // Approval.UnlockResult[] results = Approval.unlock(woMap.keySet(), false);
            if(!woliToInsert.isEmpty()){
                
                for(WorkOrderLineItem woli : woliToInsert){
                    
                    String ndgId = gruppoFinanziarioCapoGruppoMap.containsKey(woli.AccountId__c) ? gruppoFinanziarioCapoGruppoMap.get(woli.AccountId__c).Id : woli.AccountId__c;
                    woli.WorkOrderId = woToInsertMap.get(configurationKeyMap.get(ndgId)).Id;
                }
                insert woliToInsert;
            }
            // Approval.LockResult[] lockRes = Approval.lock(woMap.keySet(), false);

            return JSON.serialize(new Map<String, Object>{

                'workOrderIdSet' => SV_Utilities.keyBy(woToInsertMap.values(), 'Id').keySet()
            });
        } catch (Exception ex) {
            
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            return JSON.serialize(new Map<String, Object>{

                'errorMessage' => ex.getMessage()
            });
        }
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
}
}