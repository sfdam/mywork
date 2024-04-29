public without sharing class newMiniWalletModalController {

    //AdF funzione di generazione nome nuovo mini wallet
    @AuraEnabled
    public static string generateMiniWalletName(String walletId){
        String miniWalletName = 'default';
        Wallet__c currentWallet = [SELECT Name, (SELECT Name FROM MiniWallets__r WHERE PTF_Portafoglio__c = :walletId) FROM Wallet__c WHERE id = :walletId LIMIT 1];
        Integer nameEndCode = Integer.valueOf(currentWallet.Name.substring(currentWallet.Name.length() -6, currentWallet.Name.length()));
        String tempName = currentWallet.Name.removeEnd(String.valueOf(nameEndCode));

        if(currentWallet?.MiniWallets__r.size() > 0){
            //AdF crea il nome incrementando il codice del mini wallet con codice più alto
            Integer biggestCodeMiniWalletName = nameEndCode;
            for(MiniWallet__c miniWallet : currentWallet.MiniWallets__r){
                Integer miniWalletEndCode = Integer.valueOf(miniWallet.Name.substring(miniWallet.Name.length() -6, miniWallet.Name.length()));
                if(biggestCodeMiniWalletName < miniWalletEndCode){
                    biggestCodeMiniWalletName = miniWalletEndCode;
                }
            }
            biggestCodeMiniWalletName++;
            miniWalletName = tempName + biggestCodeMiniWalletName;

        }else{
            //AdF se non sono presenti mini wallet, incrementa il codice del nome del wallet
            nameEndCode++;
            miniWalletName = tempName + nameEndCode;

        }

        return miniWalletName;
    }

    //AdF funzione di recupero Sportelli Leggeri da visualizzare nella data table
    @AuraEnabled
    public static List<Account> getSportelliLeggeri(String walletId){
        List<Account> sportelliLeggeri = new List<Account>();
        try{
            Wallet__c currentWallet = [SELECT PTF_Filiale__c FROM Wallet__c WHERE id =: walletId LIMIT 1];
            String idCED = [SELECT PTF_IdCED__c FROM Account WHERE id =: currentWallet.PTF_Filiale__c LIMIT 1].PTF_IdCED__c;
            sportelliLeggeri = [SELECT Id, Name
                                FROM Account
                                WHERE RecordType.DeveloperName = 'AltraUnitaOrganizzativa'
                                AND PTF_IdCEDPadre__c = :idCED
                                AND PTF_Livello__c = '210'
                                /*AND PTF_MiniPortafoglio__c = NULL*/];//AdF condizione aggiunta per recuperare sportelli leggeri non associati
        }catch(Exception e){
            System.debug('error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return sportelliLeggeri;
    }

    @AuraEnabled
    public static List<MiniWallet__c> getMiniWallet(String walletId){
        List<MiniWallet__c> listMiniWallet = new List<MiniWallet__c>();
        try{
            listMiniWallet = [SELECT Id, Name, PTF_SL__c
                                FROM MiniWallet__c
                                WHERE PTF_Portafoglio__c =: walletId ];
        }catch(Exception e){
            System.debug('error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return listMiniWallet;
    }

    //AdF funzione di recupero referenti da visualizzare nella data table
    @AuraEnabled
    public static List<Assignment__c> getReferenti(String walletId){
        List<Assignment__c> referenti = new List<Assignment__c>();
        referenti = [SELECT Id, PTF_Gestore__c, PTF_Gestore_Name__c, PTF_RegistrationNumber__c, PTF_Filiale__c, PTF_ModelloDiServizio__c, PTF_MiniPortafoglio__c
                    FROM Assignment__c
                    WHERE PTF_MicroWallet__c =: walletId AND
                    PTF_MiniPortafoglio__c = NULL AND 
                    PTF_EndDate__c = NULL
                    /*AND PTF_MiniPortafoglio__c = NULL*/];//AdF condizione aggiunta per recuperare referenti non associati
        return referenti;
    }

    //AdF funzione di creazione nuovo mini wallet
    @AuraEnabled
    public static String createMiniWallet(String miniWalletName, String parentWalletId, List<Account> sportelliLeggeri, List<Assignment__c> referenti, List<Assignment__c> referentePrincipaleList){
        String idToReturn = '';
        if(miniWalletName != null && parentWalletId != null && sportelliLeggeri != null && referenti != null &&
            miniWalletName != '' && parentWalletId != '' && sportelliLeggeri.size() == 1 && (referentePrincipaleList.size() == 0 || referentePrincipaleList.size() ==1))
        {

            Savepoint sp = Database.setSavepoint();

            try{
                //AdF creaione mini wallet
                MiniWallet__c newMiniWallet = new MiniWallet__c();
                newMiniWallet.Name = miniWalletName;
                newMiniWallet.PTF_Portafoglio__c = parentWalletId;
                //AdF aggiornamento lookup con sportello leggero solo se viene passato un singolo account
                if(sportelliLeggeri.size() == 1){
                    Account sportelloLeggero = sportelliLeggeri.get(0);
                    newMiniWallet.PTF_SL__c = sportelloLeggero.id;
                    //AdF se è presente un referente o se è stato selezionato un referente principale, viene impostato come principale
                    if(referenti.size() == 1){
                        String idReferente = referenti.get(0).id;
                        Assignment__c referentePrincipale = [SELECT PTF_Gestore__c FROM Assignment__c WHERE id =: idReferente LIMIT 1].get(0);
                        newMiniWallet.Referente__c = referentePrincipale.PTF_Gestore__c;
                    }else if(referentePrincipaleList.size() == 1){
                        String idReferente = referentePrincipaleList.get(0).id;
                        Assignment__c referentePrincipale = [SELECT PTF_Gestore__c FROM Assignment__c WHERE id =: idReferente LIMIT 1].get(0);
                        newMiniWallet.Referente__c = referentePrincipale.PTF_Gestore__c;
                    }
                    //AdF inserimento mini wallet
                    Insert newMiniWallet;
                    // sportelloLeggero.PTF_MiniPortafoglio__c = newMiniWallet.id;
                    // Update sportelloLeggero;

                    //AdF aggiornamento lookup a mini wallet per ogni referente passato
                    if(referenti.size() > 0){
                        for(Assignment__c referente : referenti){
                            referente.PTF_MiniPortafoglio__c = newMiniWallet.id;
                        }
                        update referenti;
                    }

                    idToReturn = String.valueOf(newMiniWallet.id);
                }else{
                    throw new AuraHandledException('Sportello Leggero non presente');
                }

            }catch(Exception e){
                System.debug('error: ' + e.getMessage());
                Database.rollback(sp);
                throw new AuraHandledException(e.getMessage());
            }

        }

        return idToReturn;
    }

}