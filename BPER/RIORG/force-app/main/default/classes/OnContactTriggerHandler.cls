public class OnContactTriggerHandler {
    
    public static void handleAfterInsert(List<Contact> contactList){
        if (FollowUp.invokeUpdateDefaultManagers) {
            updateWalletDefaultManagers(contactList,null, 'onInsert');
        }
    }
    
    public static void handleAfterUpdate(List<Contact> contactList, Map<Id, Contact> oldContactMap){
        if (FollowUp.invokeUpdateDefaultManagers) {
            updateWalletDefaultManagers(contactList,oldContactMap, 'onUpdate');
        }
    }
    
    public static void handleBeforeDelete(List<Contact> contactList){
        if (FollowUp.invokeUpdateDefaultManagers) {
            updateWalletDefaultManagers(contactList,null, 'onDelete');
        }
    }
    
    public static void handleBeforeInsert(List<Contact> newRecord){
        impostaElegibile(newRecord);
    }
    
    public static void handleBeforeUpdate(List<Contact> newRecord,Map<Id,Contact> oldRecord){
        impostaElegibile(newRecord);
        setCloseDate(newRecord, oldRecord);
    }

    public static void setCloseDate(List<Contact> newRecords, Map<Id,Contact> oldRecord){
        for(Contact c:newRecords){
            if(!c.PTF_ReferenteElegibile__c && oldRecord.get(c.Id).PTF_ReferenteElegibile__c){
                c.PTF_Closed_Date_Referente__c=System.now();
            }
            else if(c.PTF_ReferenteElegibile__c && !oldRecord.get(c.Id).PTF_ReferenteElegibile__c){
                c.PTF_Closed_Date_Referente__c=null;
            }
        }
    }
    
    /*public static void updateDefaultManagers(List<Contact> contactList, String method){
        
        String mwRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        String primarioRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        Set<String> filialeSet = new Set<String>();
        Set<String> roleSet = new Set<String>();
        Map<String, Set<String>> branchRoleMap = new Map<String, Set<String>>();
        Map<String, List<Contact>> accountContactMap = new Map<String, List<Contact>>();
        List<Assignment__c> assignmentsToInsert = new List<Assignment__c>(); 
        List<Assignment__c> assignmentsToUpdate = new List<Assignment__c>(); 
        Map<String, SObject> contactMap = SV_Utilities.keyBy(contactList, 'Id');
        
        if(method == 'onInsert' || method == 'onUpdate') {
            Set<Id> contactIds = new Set<Id>();
            for(Contact contact: contactList) {
                contactIds.add(contact.Id);
                filialeSet.add(contact.AccountId);
                roleSet.add(contact.PTF_TipologiaRuolo__c);
                if(!accountContactMap.containsKey(contact.AccountId)){
                    
                    accountContactMap.put(contact.AccountId, new List<Contact>());
                }
                accountContactMap.get(contact.AccountId).add(contact);
            }
            
            for(RoleMDS__c roleMDS : [SELECT Id, PTF_BranchTypology__c, PTF_RoleTypology__c, PTF_ServiceModel__r.Name FROM RoleMDS__c WHERE PTF_RoleTypology__c IN: roleSet]){
                
                String key = roleMDS.PTF_BranchTypology__c + '' + roleMDS.PTF_ServiceModel__r.Name;
                if(!branchRoleMap.containsKey(key)){
                    
                    branchRoleMap.put(key, new Set<String>());
                }
                branchRoleMap.get(key).add(roleMDS.PTF_RoleTypology__c);
            }
            
            Map<String,sObject> mAssignmentContact = SV_Utilities.keyBy([
                SELECT PTF_StartDate__c,PTF_EndDate__c,PTF_MicroWallet__c,PTF_Gestore__c,Id,RecordTypeId
                FROM Assignment__c
                WHERE RecordTypeId =:primarioRecordTypeId
                AND PTF_Gestore__c IN:contactIds
                AND PTF_EndDate__c = null
            ],'{PTF_Gestore__c}_{PTF_MicroWallet__c}',true);
            
            for(Wallet__c wallet : [SELECT id, PTF_ModelloDiServizio__c, PTF_Filiale__r.PTF_BranchTypology__c FROM Wallet__c WHERE PTF_Pool__c = true AND RecordTypeId =: mwRecordTypeId AND PTF_Filiale__c IN: filialeSet AND PTF_DeletionDate__c=null]){
                
                if(accountContactMap.containsKey(wallet.PTF_Filiale__c)){
                    
                    for(Contact contact : accountContactMap.get(wallet.PTF_Filiale__c)){
                        
                        String key = wallet.PTF_Filiale__r.PTF_BranchTypology__c + '' + wallet.PTF_ModelloDiServizio__c;
                        if(branchRoleMap.containsKey(key)){
                            
                            if(branchRoleMap.get(key).contains(contact.PTF_TipologiaRuolo__c)){
                                if (!mAssignmentContact.containsKey(contact.Id+'_'+wallet.Id)) {
                                    assignmentsToInsert.add(new Assignment__c(
                                        PTF_StartDate__c = Date.today(),
                                        PTF_MicroWallet__c = wallet.Id,
                                        PTF_Gestore__c = contact.Id,
                                        RecordTypeId = primarioRecordTypeId
                                    ));
                                }
                            }
                        }
                    }
                }
            }
        }
        
        System.debug('contactMap: ' + JSON.serializePretty(contactMap));
        if(method == 'onDelete'){
            
            for(Assignment__c assignment : [SELECT id, PTF_Gestore__c, PTF_EndDate__c FROM Assignment__c WHERE PTF_Gestore__c IN: contactMap.keySet()]){
                
                assignment.PTF_EndDate__c = Date.today();
                assignmentsToUpdate.add(assignment);
            }
        } else if(method == 'onUpdate'){
            
            for(Assignment__c assignment : [SELECT id, PTF_Gestore__c, PTF_EndDate__c FROM Assignment__c WHERE PTF_Gestore__c IN: contactMap.keySet() AND PTF_MicroWallet__r.PTF_Pool__c = true]){
                
                assignment.PTF_EndDate__c = Date.today();
                assignmentsToUpdate.add(assignment);
            }
        }
        
        System.debug('assignmentsToUpdate: ' + JSON.serializePretty(assignmentsToUpdate));
        if(!assignmentsToUpdate.isEmpty()){
            
            update assignmentsToUpdate;
        }
        
        if(!assignmentsToInsert.isEmpty()){
            
            insert assignmentsToInsert;
        }
    }*/
    
    public static void impostaElegibile(List<Contact> newRecords) {
        String recTypeFiliale = SV_Utilities.getRecordTypeByDeveloperName('Account', 'FilialeDiRelazione');
        Set<String> idcedDR = SV_Utilities.getSet([SELECT Id FROM Account WHERE CRM_Nome__c LIKE 'uff. sviluppo%'], 'Id');
        Set<String> idcedPrivate= SV_Utilities.getSet([SELECT PTF_IdCEDUffPrivate__c FROM ConfigUffPrivateDR__c], 'PTF_IdCEDUffPrivate__c');
        for(Account filiale : [SELECT PTF_IdCedUffPrivate__c FROM Account WHERE PTF_IdCedUffPrivate__c != '' AND RecordTypeName__c = 'Filiale Di relazione']){
            idcedPrivate.addAll(filiale.PTF_IdCedUffPrivate__c.replace('|', ';').split(';'));
        }
        Set<String> profili = new set<String>{'NEC_CR','NEC_A.5','NEC_CF','NEC_F.1','NEC_F.2','NEC_D.4','NEC_D.5','NEC_D.6','NEC_D.7','NEC_D.9','NEC_F.9','NEC_F.10','NEC_T.4','NEC_T.7','NEC_T.8','NEC_T.10','NEC_D.10'};
        Set<Id> idAccounts = new Set<Id>();
        Set<Id> idRoleTypologies = new Set<Id>();
        Map<Id,Contact> mValidContact = new Map<Id,Contact>();
        Set<String> matricole = new Set<String>();
        
        
        for (Contact c :newRecords) {
            if (c.AccountId!=null && !String.isBlank(c.PTF_RegistrationNumber__c) && !String.isBlank(c.PTF_ProfiloLDAP__c) && profili.contains(c.PTF_ProfiloLDAP__c) && c.PTF_TipologiaRuolo__c!=null) {
                mValidContact.put(c.Id,c);
                idAccounts.add(c.AccountId);
                idRoleTypologies.add(c.PTF_TipologiaRuolo__c);
                matricole.add('U'+c.PTF_RegistrationNumber__c);
            }
            else {
                c.PTF_ReferenteElegibile__c = false;
            }
        }
        
        if (!mValidContact.isEmpty()) {
            Map<Id,RoleTypology__c> mRoleTypology = new Map<Id,RoleTypology__c>();
            Map<Id,Account> mAccounts = new Map<Id,Account>();
            Map<String,LDAP__c> mLDAPs = new Map<String,LDAP__c>();
            Map<Id,Set<String>> mFiliere = new Map<Id,Set<String>>();
            Map<Id,Set<String>> mMacrofiliere = new Map<Id,Set<String>>();
            
            for (LDAP__c ldap : [SELECT Id,Vicario__c,IdCed__c,Matricola__c FROM LDAP__c WHERE Matricola__c IN:matricole]) {
                mLDAPs.put(ldap.Matricola__c,ldap);
            }
            for (RoleTypology__c rtyp : [SELECT Id,Name,PTF_Code__c FROM RoleTypology__c WHERE Id IN:idRoleTypologies]) {
                mRoleTypology.put(rtyp.Id,rtyp);
            }
            for (Account acc : [SELECT Id,FinServ__BankNumber__c,RecordTypeId FROM Account WHERE Id IN:idAccounts]) {
                mAccounts.put(acc.Id,acc);
            }
            
            List<RoleMDS__c> roleMDS = [
                SELECT  Id,
                        PTF_RoleTypology__c,
                        PTF_StartDate__c,
                        PTF_EndDate__c,
                        PTF_MacroDivision__c,
                        PTF_Division__c
                FROM RoleMDS__c
                WHERE PTF_StartDate__c<=:date.today()
                AND (PTF_EndDate__c=null OR PTF_EndDate__c>=:Date.today())
            ];
            if (roleMDS!=null && roleMDS.size()>0) {
                for (RoleMDS__c mds : roleMDS) {
                    Set<String> filiere = (mFiliere.containsKey(mds.PTF_RoleTypology__c) ? mFiliere.get(mds.PTF_RoleTypology__c):new Set<String>());
                    Set<String> macrofiliere = (mMacrofiliere.containsKey(mds.PTF_RoleTypology__c) ? mMacrofiliere.get(mds.PTF_RoleTypology__c):new Set<String>());
                    filiere.add(mds.PTF_Division__c);
                    mFiliere.put(mds.PTF_RoleTypology__c,filiere);
                    macrofiliere.add(mds.PTF_MacroDivision__c);
                    mMacrofiliere.put(mds.PTF_RoleTypology__c,macrofiliere);
                }
            }
            Set<String> p05387 = new Set<String>{'NEC_D.4','NEC_D.5','NEC_D.6','NEC_D.7','NEC_D.9'};
            Set<String> p01015 = new Set<String>{'NEC_A.5','NEC_D.4','NEC_D.5','NEC_D.9'};
            Set<String> pAltri = new Set<String>{'NEC_F.1','NEC_F.2','NEC_F.9','NEC_F.10','NEC_T.4','NEC_T.7','NEC_T.8','NEC_T.10','NEC_CF','NEC_CR','NEC_D.10'};
            for (Id idc : mValidContact.keySet()) {
                Contact c = mValidContact.get(idc);
                Account acc = mAccounts.get(c.AccountId);
                if ('05387'.equals(acc.FinServ__BankNumber__c) && p05387.contains(c.PTF_ProfiloLDAP__c)) {
                    if ('NEC_D.4'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c =(
                            ('F_143'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || ('F_912'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) &&
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('WM') && 
                            ('6116'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) || '10736'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)))
                        );
                    }
                    else if ('NEC_D.5'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            ('050'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) )||
                            ('F_903'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || ('F_910'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) &&
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('ET') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('IC') && 
                            '6859'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)) ||
                           ('065'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) && 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('WM') && 
                            '6116'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c))
                        );
                    }
                    else if ('NEC_D.6'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            ('F_902'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)||
                            '031'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) &&
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('KI') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('IC') && 
                            // DK - MODIFICA KCI 13/12 - 5806 => 21709
                            (/*'5806'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||*/
                             '21707'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '21708'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '21709'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '7111'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '7114'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) 
                            )
                        );
                    }
                    else if ('NEC_D.7'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            ('F_907'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                             'F_908'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            'F_141'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || 
                            '300'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) &&
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('KI') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('IC') && 
                            // DK - MODIFICA KCI 13/12 - 5806 => 21709
                            (/*'5806'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||*/
                             '21707'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '21708'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '21709'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '7111'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) ||
                             '7114'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c) 
                            )
                        );
                    }
                    else if ('NEC_D.9'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            ('F_904'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || ('F_910'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) &&
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('ET') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('IC') && 
                            '6859'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c))
                        );
                    }
                    else {
                        c.PTF_ReferenteElegibile__c = false;
                    }
                }
                else if ('01015'.equals(acc.FinServ__BankNumber__c) && p01015.contains(c.PTF_ProfiloLDAP__c)) {
                    if ('NEC_A.5'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c)) {
                        c.PTF_ReferenteElegibile__c = ('042'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c));
                    }
                    else if ('NEC_D.4'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            'F_140'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) && 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                            '5690'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                        );
                    }
                    else if ('NEC_D.5'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                       c.PTF_ReferenteElegibile__c = (
                           ('050'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) && 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('ET') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('IC') 
                             /*&& '5692'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)*/) ||
                           (('069'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || ('F_905'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) && 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                            '5690'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c))
                        )||
                           ('065'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) && 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('WM') && 
                            '21025'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c))
                       ); // Aggiunto blocco '065' per BDS 24/06/2021 VP
                       
                    }
                    else if ('NEC_D.9'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            'F_909'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) && 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('ET') && 
                            mMacroFiliere.get(c.PTF_TipologiaRuolo__c).contains('IC') && 
                            '5692'.equals(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                        );
                    }
                    else {
                        c.PTF_ReferenteElegibile__c = false;
                    }
                }
                else if (pAltri.contains(c.PTF_ProfiloLDAP__c)) {
                    
                    if ('NEC_F.1'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = ( !String.isBlank(c.PTF_IsVice__c) || 'Titolare'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).Name)); 
                    }
                    else if ('NEC_F.2'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c =  (
                            recTypeFiliale.equals(acc.RecordTypeId)
                            // && (
                           //(mRoleTypology.get(c.PTF_TipologiaRuolo__c).Name.startsWith('Referente') || mRoleTypology.get(c.PTF_TipologiaRuolo__c).Name.startsWith('Collaboratore')) ||
                           // '037'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                           // '039'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                           // '040'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'028'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)   
                          //  )
                        );
                    }
                    else if ('NEC_F.9'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (String.isBlank(c.PTF_IsVice__c) && mRoleTypology.get(c.PTF_TipologiaRuolo__c).Name.startsWith('Coordinatore'));
                    }
                    else if ('NEC_F.10'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = true; 
                        //(
                        //    'Titolare'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).Name) ||
                         //   '039'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                         //   '040'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) 
                        //);
                    }
                    else if ('NEC_T.4'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            'Titolare'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).Name) &&
                            idcedDR.contains(c.AccountId)
                        );
                    }
                    else if ('NEC_T.7'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c)) {
                        c.PTF_ReferenteElegibile__c = true; //((
                            // START DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                            // MS - rimosso il check sul ruolo per il profilo NEC_T.8 per determinare se il referente è elegibile
                            //('100'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)||'F_140'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || '144'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c))&& 
                           // mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                           // mMacrofiliere.get(c.PTF_TipologiaRuolo__c).contains('WM') && 
                           // idcedPrivate.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)) ||
                           // ('F_143'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) && '21025'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)||
                           // ('F_144'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) && 
                           /** ('21025'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                              ||'21717'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                              ||'21718'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                              ||'21719'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                              ||'21720'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                            ||'21716'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                            ||'21715'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                            ||'21713'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c))
                            ); **/
                            // END DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                    }
                    else if ('NEC_D.10'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c)  && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        System.debug('MC NEC_D.10');
                        c.PTF_ReferenteElegibile__c = (
                            ('F_144'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) && 
                            (
                                '21717'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21718'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21719'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21720'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21716'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21715'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21713'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                                ||'21859'.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                            )
                            );
                    }
                    else if ('NEC_T.8'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c)) {
                        System.debug('DK code: ' + mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c);
                        System.debug('DK mFiliere: ' + mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR'));
                        System.debug('DK mMacrofiliere: ' + mMacrofiliere.get(c.PTF_TipologiaRuolo__c).contains('WM'));
                        System.debug('DK idced: ' + mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c);
                        System.debug('DK idcedPrivate: ' + idcedPrivate.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c));
                        c.PTF_ReferenteElegibile__c = (
                            // START DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                            // MS - rimosso il check sul ruolo per il profilo NEC_T.8 per determinare se il referente è elegibile
                            //('069'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) || '038'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c))&& 
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('PR') && 
                            mMacrofiliere.get(c.PTF_TipologiaRuolo__c).contains('WM') //&& 
                            //idcedPrivate.contains(mLDAPs.get('U'+c.PTF_RegistrationNumber__c).IdCed__c)
                           );
                            // END DK 02/09 - REEFERENTE COORDINATORE ASSISTENTE
                    }
                    else if ('NEC_T.10'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            idcedDR.contains(c.AccountId) &&
                            ('041'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            '042'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) 
                        );
                    }
                    else if ('NEC_CF'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c) && mMacroFiliere.containsKey(c.PTF_TipologiaRuolo__c) && mFiliere.containsKey(c.PTF_TipologiaRuolo__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            mFiliere.get(c.PTF_TipologiaRuolo__c).contains('CF') && 
                            mMacrofiliere.get(c.PTF_TipologiaRuolo__c).contains('WM') && 
                            ('990'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            '991'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)) 
                        );
                    }
                    // ADD NEC_CR 14.01
                    else if ('NEC_CR'.equals(c.PTF_ProfiloLDAP__c) && mRoleTypology.containsKey(c.PTF_TipologiaRuolo__c) && mLDAPs.containsKey('U'+c.PTF_RegistrationNumber__c)) {
                        c.PTF_ReferenteElegibile__c = (
                            recTypeFiliale.equals(acc.RecordTypeId)
                           // MS - rimosso il check sul ruolo per il profilo NEC_CR per determinare se il referente è elegibile    
                           // (
                            //recTypeFiliale.equals(acc.RecordTypeId) && (
                            //('000'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'052'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'054'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'055'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'056'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'074'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'095'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c) ||
                            //'097'.equals(mRoleTypology.get(c.PTF_TipologiaRuolo__c).PTF_Code__c)
                            //))
                            );
                          
                    }
                    // END ADD NEC_CR 14.01
                    else {
                        c.PTF_ReferenteElegibile__c = false;
                    }
                }
                else {
                    c.PTF_ReferenteElegibile__c = false;
                }
            }
        }
    }
    
    public static void updateWalletDefaultManagers(List<Contact> newContacts,Map<Id,Contact> oldContacts, String operation) {
        System.debug('updateWalletDefaultManagers start');
        System.debug('newContacts'+ newContacts);
        System.debug('oldContacts'+ oldContacts);
        System.debug('operation'+ operation);

        Map<String,EscludiUtenzaDaSgancio__c> mEscludiDaSgancio = EscludiUtenzaDaSgancio__c.getAll();
        Map<String, SObject> assignmentsToInsert = new Map<String, SObject> (); 
        Map<String, SObject> assignmentsToUpdate = new Map<String, SObject> ();
        //List<Assignment__c> assignmentsToUpdateList = new List<Assignment__c>();
        //List<Assignment__c> assignmentsToInsertList = new List<Assignment__c>();
        List<Contact> contactToInsert = new List<Contact>();
        Set<Id> idsContacts = new Set<Id>();
        
        if ('onDelete'.equals(operation)) {
            for (Contact c : newContacts) {
                idsContacts.add(c.Id);
            }
            
            if (idsContacts.size()>0) {
                for(Assignment__c assignment : [SELECT id, PTF_Gestore__c, PTF_EndDate__c, PTF_EndDate_DT__c,PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c IN: idsContacts AND PTF_EndDate__c=null]){
                    assignment.PTF_EndDate__c = Date.today();
                    assignment.PTF_EndDate_DT__c = Datetime.now();
                    assignmentsToUpdate.put(assignment.PTF_Gestore__c + '_'+ assignment.PTF_MicroWallet__c,assignment);
                }
            }
        }
        else {
            if ('onInsert'.equals(operation)) {
                assignmentsToInsert = manageWallet(newContacts,null,operation);
            }
            else if ('onUpdate'.equals(operation)) {
                List<Contact> contactChangeIdCed = new List<Contact>();
                List<Contact> contactChangeTipologiaRuolo = new List<Contact>();
                List<Contact> contactActivated = new List<Contact>();
                List<Contact> contactDeactivated = new List<Contact>();
                for (Contact c : newContacts) {
                    Contact oldc = oldContacts.get(c.Id);
                    if(String.isNotBlank(c.PTF_ProfiloLDAP__c) && String.isBlank(oldc.PTF_ProfiloLDAP__c)){
                        contactActivated.add(c);
                        System.debug('contactActivated'+ contactActivated);
                    }
                    else if(String.isBlank(c.PTF_ProfiloLDAP__c) && String.isNotBlank(oldc.PTF_ProfiloLDAP__c)){
                        contactDeactivated.add(c);
                        System.debug('contactDeactivated'+ contactDeactivated);
                    }
                    else if (c.AccountId!=oldc.AccountId) {
                        if (!mEscludiDaSgancio.containsKey(c.PTF_RegistrationNumber__c)) {
                            contactChangeIdCed.add(oldc);
                            System.debug('contactChangeIdCed'+ contactChangeIdCed);
                        }
                        contactToInsert.add(c);
                        System.debug('contactToInsert'+ contactToInsert);
                    }
                    else if (c.PTF_TipologiaRuolo__c!=oldc.PTF_TipologiaRuolo__c) {
                        if (!mEscludiDaSgancio.containsKey(c.PTF_RegistrationNumber__c)) {
                            contactChangeTipologiaRuolo.add(oldc);
                            System.debug('contactChangeTipologiaRuolo'+ contactChangeTipologiaRuolo);
                        }
                        contactToInsert.add(c);
                        System.debug('contactToInsert'+ contactToInsert);
                    }
                }
                if (contactActivated.size()>0) {
                    assignmentsToInsert = manageWallet(newContacts,null,'onInsert');
                    System.debug('assignmentsToInsert'+ assignmentsToInsert);
                }
                if (contactDeactivated.size()>0) {
                    for (Contact c : contactDeactivated) {
                        idsContacts.add(c.Id);
                    }
                    for(Assignment__c assignment : [SELECT id, PTF_Gestore__c, PTF_EndDate__c, PTF_EndDate_DT__c,PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__c IN: idsContacts AND  PTF_MicroWallet__r.PTF_Pool__c = true AND PTF_EndDate__c=null]){
                        assignment.PTF_EndDate__c = Date.today();
                        assignment.PTF_EndDate_DT__c = Datetime.now();
                        assignmentsToUpdate.put(assignment.PTF_Gestore__c + '_'+ assignment.PTF_MicroWallet__c,assignment);
                    }
                }
                if (contactChangeIdCed.size()>0) {
                    assignmentsToUpdate = manageWallet(contactChangeIdCed,null,'onChangeIDCED');
                }
                if (contactChangeTipologiaRuolo.size()>0) {
                    assignmentsToUpdate = manageWallet(contactToInsert,contactChangeTipologiaRuolo,'onChangeTipologiaRuolo');
                }
            }
        }
        
        if(!assignmentsToUpdate.isEmpty()){
            update assignmentsToUpdate.values();
            System.debug('assignmentsToUpdate'+ assignmentsToUpdate);
            if (contactToInsert.size()>0) {
                updateWalletDefaultManagers(contactToInsert,null,'onInsert');
            }
        }
        
        if(!assignmentsToInsert.isEmpty()){
            insert assignmentsToInsert.values();
            System.debug('assignmentsToInsert'+ assignmentsToInsert);
        }
    }
    
    public static Map<String, SObject> manageWallet(List<Contact> newContacts,List<Contact> oldContacts,String operation) {
        System.debug('manageWallet start');
        System.debug('newContacts'+ newContacts);
        System.debug('oldContacts'+ oldContacts);
        System.debug('operation'+ operation);
        String mwRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
        String primarioRecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario'); 
        Set<String> roleSet = new Set<String>();
        Set<Id> contactsIds = new Set<Id>();
        Map<String, Set<String>> branchRoleMap = new Map<String, Set<String>>();
        Map<String, List<Contact>> accountContactMap = new Map<String, List<Contact>>();
        Map<String, SObject> assigmentsToManage = new Map<String, SObject>();
        List<Assignment__c> assigmentsToManageList = new List<Assignment__c> ();
        
        if ('onChangeIDCED'.equals(operation)) {
            Set<Id> accountsIds = new Set<Id>();
            for (Contact c : newContacts) {
                contactsIds.add(c.Id);
                accountsIds.add(c.AccountId);
            }
            
            if (contactsIds.size()>0) {
                for(Assignment__c assignment : [SELECT Id, PTF_Gestore__c, PTF_EndDate__c, PTF_EndDate_DT__c, PTF_MicroWallet__c, PTF_MicroWallet__r.PTF_Filiale__c, RecordTypeId FROM Assignment__c WHERE PTF_Gestore__c IN: contactsIds AND PTF_MicroWallet__r.PTF_Filiale__c IN:accountsIds AND PTF_MicroWallet__r.PTF_Pool__c = true AND PTF_EndDate__c=null]){
                    assignment.PTF_EndDate__c = Date.today();
                    assignment.PTF_EndDate_DT__c = Datetime.now();
                    assigmentsToManage.put(assignment.PTF_Gestore__c + '_'+ assignment.PTF_MicroWallet__c,assignment);
                }
            }
        }
        if ('onChangeTipologiaRuolo'.equals(operation)) {
            Map<Id,Id> mContactToRoleTypologyOld = new Map<Id,Id>();
            Map<Id,Id> mContactToRoleTypologyNew = new Map<Id,Id>();
            for(Contact c: newContacts) {
                if (c.PTF_TipologiaRuolo__c!=null) {
                    mContactToRoleTypologyNew.put(c.Id,c.PTF_TipologiaRuolo__c);
                    roleSet.add(c.PTF_TipologiaRuolo__c);
                }
            }
            for(Contact c: oldContacts) {
                if (c.PTF_TipologiaRuolo__c!=null) {
                    mContactToRoleTypologyOld.put(c.Id,c.PTF_TipologiaRuolo__c);
                    roleSet.add(c.PTF_TipologiaRuolo__c);
                }
            }
            
            Map<Id,Set<String>> serviceModelNames = new Map<Id,Set<String>>();
            for(RoleMDS__c roleMDS : [SELECT Id, PTF_BranchTypology__c, PTF_RoleTypology__c, PTF_ServiceModel__r.Name FROM RoleMDS__c WHERE PTF_RoleTypology__c IN: roleSet]){
                Set<String> sm = (serviceModelNames.containsKey(roleMDS.PTF_RoleTypology__c) ? serviceModelNames.get(roleMDS.PTF_RoleTypology__c) : new Set<String>());
                sm.add(roleMDS.PTF_ServiceModel__r.Name);
                serviceModelNames.put(roleMDS.PTF_RoleTypology__c,sm);
            }
            
            Map<Id,Set<String>> mContactToOldSM = new Map<Id,Set<String>>();
            Set<String> ServiceModelToRemove = new Set<String>();
            for(Id contId: mContactToRoleTypologyOld.keySet()) {
                Id oldRoleTypology = mContactToRoleTypologyOld.get(contId);
                Id newRoleTypology = mContactToRoleTypologyNew.get(contId);
                Set<String> smOld = (serviceModelNames.containsKey(oldRoleTypology) ? serviceModelNames.get(oldRoleTypology) : new Set<String>());
                Set<String> smNew = (serviceModelNames.containsKey(newRoleTypology) ? serviceModelNames.get(newRoleTypology) : new Set<String>());
                for (String sm : smOld) {
                    if (!smNew.contains(sm)) {
                        ServiceModelToRemove.add(sm);
                        Set<String> smToRemove = (mContactToOldSM.containsKey(contId) ? mContactToOldSM.get(contId) : new Set<String>());
                        smToRemove.add(sm);
                        mContactToOldSM.put(contId,smToRemove);
                    }
                }
            }
            if (!mContactToOldSM.isEmpty()) {
                for(Assignment__c assignment : [SELECT Id, PTF_Gestore__c, PTF_EndDate__c, PTF_EndDate_DT__c, PTF_MicroWallet__c, PTF_MicroWallet__r.PTF_Filiale__c,RecordTypeId,PTF_MicroWallet__r.PTF_ModelloDiServizio__c FROM Assignment__c WHERE PTF_Gestore__c IN: mContactToOldSM.keySet() AND PTF_MicroWallet__r.PTF_ModelloDiServizio__c IN:ServiceModelToRemove AND PTF_MicroWallet__r.PTF_Pool__c = true AND PTF_EndDate__c=null]){
                    Set<String> smToRemove = (mContactToOldSM.containsKey(assignment.PTF_Gestore__c) ? mContactToOldSM.get(assignment.PTF_Gestore__c) : new Set<String>());
                    if (smToRemove.contains(assignment.PTF_MicroWallet__r.PTF_ModelloDiServizio__c)) {
                        assignment.PTF_EndDate__c = Date.today();
                        assignment.PTF_EndDate_DT__c = Datetime.now();
                        assigmentsToManage.put(assignment.PTF_Gestore__c + '_'+ assignment.PTF_MicroWallet__c,assignment);
                    }
                }
            }
        }
        if ('onInsert'.equals(operation)) {
            for(Contact c: newContacts) {
                roleSet.add(c.PTF_TipologiaRuolo__c);
                contactsIds.add(c.Id);
                List<Contact> lContacts = (accountContactMap.containsKey(c.AccountId) ? accountContactMap.get(c.AccountId) : new List<Contact>());
                lContacts.add(c);
                accountContactMap.put(c.AccountId,lContacts);
            }
            for(RoleMDS__c roleMDS : [SELECT Id, PTF_BranchTypology__c, PTF_RoleTypology__c, PTF_ServiceModel__r.Name FROM RoleMDS__c WHERE PTF_RoleTypology__c IN: roleSet]){
                String key = roleMDS.PTF_BranchTypology__c + '' + roleMDS.PTF_ServiceModel__r.Name;
                if(!branchRoleMap.containsKey(key)){
                    branchRoleMap.put(key, new Set<String>());
                }
                branchRoleMap.get(key).add(roleMDS.PTF_RoleTypology__c);
            }
            
            Map<String,sObject> mAssignmentContact = SV_Utilities.keyBy([
                SELECT  PTF_StartDate__c,
                        PTF_StartDate_DT__c,
                        PTF_EndDate__c,
                        PTF_MicroWallet__c,
                        PTF_Gestore__c,
                        Id,
                        RecordTypeId
                FROM Assignment__c
                WHERE RecordTypeId =:primarioRecordTypeId
                AND PTF_Gestore__c IN:contactsIds
                AND PTF_EndDate__c = null
            ],'{PTF_Gestore__c}_{PTF_MicroWallet__c}',true);
            
            for(Wallet__c wallet : [SELECT  Id, 
                                            PTF_ModelloDiServizio__c,
                                            PTF_Filiale__r.PTF_BranchTypology__c 
                                    FROM Wallet__c 
                                    WHERE PTF_Pool__c = true 
                                    AND RecordTypeId =: mwRecordTypeId 
                                    AND PTF_Filiale__c IN: accountContactMap.keySet() 
                                    AND PTF_DeletionDate__c=null]){
                if(accountContactMap.containsKey(wallet.PTF_Filiale__c)){
                    for(Contact contact : accountContactMap.get(wallet.PTF_Filiale__c)){
                        String key = wallet.PTF_Filiale__r.PTF_BranchTypology__c + '' + wallet.PTF_ModelloDiServizio__c;
                        if(branchRoleMap.containsKey(key)){
                            if(branchRoleMap.get(key).contains(contact.PTF_TipologiaRuolo__c)){
                                if (!mAssignmentContact.containsKey(contact.Id+'_'+wallet.Id)) {
                                    assigmentsToManageList.add(new Assignment__c(
                                        PTF_StartDate__c = Date.today(),
                                        PTF_StartDate_DT__c = Datetime.now(),
                                        PTF_MicroWallet__c = wallet.Id,
                                        PTF_Gestore__c = contact.Id,
                                        RecordTypeId = primarioRecordTypeId
                                    ));
                                    
                                }
                            }
                        }
                    }
                }
            }
            assigmentsToManage =  SV_Utilities.keyBy(assigmentsToManageList,'{PTF_Gestore__c}_{PTF_MicroWallet__c}',true);
        }
        System.debug('assigmentsToManage'+ assigmentsToManage);
        return assigmentsToManage;

    }
    
}