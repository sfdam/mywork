public class WGC_EditRolesModalController {

    @AuraEnabled
    public static WrapperResponse getInformationContact(String contactId, String accountId) {
        System.debug('SV accountId: ' + accountId);
        System.debug('SV contactId: ' + contactId);
        
        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{
            List<AccountContactRelation> correlato = [ SELECT Id, WGC_Ruolo__c, Contact.NDGGruppo__c, Contact.Censimento__c FROM AccountContactRelation WHERE AccountId = : accountId AND ContactId = : contactId ];
            records.accContactRelationList = correlato;
            result.data.add(records);
        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }
        
        return result;
        
    }

    @AuraEnabled
    public static WrapperResponse updateRole(String accountId, String contactId, List<String> rolesList) {
        System.debug('SV accountId: ' + accountId);
        System.debug('SV contactId: ' + contactId);
        System.debug('SV rolesList: ' + rolesList);
        
        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{

            List<AccountContactRelation> accContactRelationList = [ SELECT Roles, AccountId, IsDirect, WGC_Ruolo__c FROM AccountContactRelation WHERE ContactId =: contactId AND AccountId =: accountId ];
            Account acc = [ SELECT Id, NDGGruppo__c FROM Account WHERE Id =: accountId ];
            Contact con = [ SELECT Id, NDGGruppo__c FROM Contact WHERE Id =: contactId ];

            Map<String, SObject> mapTipo_Rete = U.keyBy([ SELECT Label, Descrizione__c, Codice_Cedacri__c FROM WGC_Ruolo_Tipo_Azienda__mdt ], 'Label');  
            System.debug('SV mapRuolo_Tipo_Azienda: ' + mapTipo_Rete);

            WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.gestioneCollNdg(acc.NDGGruppo__c);
            System.debug('SV response gestioneCollNdg: ' + response);
            List<WsAnagrafe.ElementoNdg> ndgCollegati = new List<WsAnagrafe.ElementoNdg>();
            List<Account> accountIds = new List<Account>();

            Map<String, Integer> rolesAnagrafeCount = new Map<String, Integer>();
            for (WsAnagrafe.ElementoNdg elemento : response.payload.elementi) {
              if (elemento.Ndg != Long.valueOf(acc.NDGGruppo__c) && elemento.collegamentoAttivo == 'S'){
                  System.debug('SV ndgCollegato: ' + elemento);
                  if(rolesAnagrafeCount.containsKey(elemento.tipo)){
                  rolesAnagrafeCount.put(elemento.tipo, rolesAnagrafeCount.get(elemento.tipo) + 1);
                  }else {
                  rolesAnagrafeCount.put(elemento.tipo, 1);
                  }
                  ndgCollegati.add(elemento);
              }
            }
            System.debug('SV ndgCollegati: ' + ndgCollegati);
            System.debug('SV rolesAnagrafeCount: ' + rolesAnagrafeCount);
                
            String stringRoles = '';
            for(String selectRole : rolesList){
              stringRoles = stringRoles + selectRole + ';';
            }
            stringRoles = stringRoles.removeEnd(';');

			      System.debug('SV accContactRelationList: ' + accContactRelationList);
            for(AccountContactRelation singleRelation : accContactRelationList){
              if(singleRelation.AccountId == accountId){
                  String rolesOLD = singleRelation.WGC_Ruolo__c;
				           System.debug('SV roles OLD: ' + rolesOLD);
                  for(String singleRole : rolesList){
                    System.debug('SV singleRole: ' + singleRole);
                    if(singleRole != ''){
                      System.debug('SV Codice_Cedacri__c: ' + (String)mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c'));
                      if(!rolesAnagrafeCount.containsKey((String)mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c'))){
                        System.debug('SV RETE NON ESISTENTE');
                        if(singleRole != 'U'){  // RETE DIVERSA DA DI
                          WsAnagrafe.GestioneCollNdgResponse response_Y = WsAnagrafe.associaPfPgCollNdg(acc.NDGGruppo__c, con.NDGGruppo__c, (String)mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c'), true);
                        } else {
                          WsAnagrafe.GestioneCollNdgResponse response_Y = WsAnagrafe.associaPfPgCollNdg(acc.NDGGruppo__c, con.NDGGruppo__c, (String)mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c'), false);                        
                        }
                      } else {
                        System.debug('SV RETE ESISTENTE');
                        Boolean find = false;
                        List<WsAnagrafe.ElementoNdg> ndgToSend = new List<WsAnagrafe.ElementoNdg>();
                        for(WsAnagrafe.ElementoNdg elemento : ndgCollegati){
                          if(elemento.tipo == mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c')){

                            if(String.valueOf(elemento.ndg) == con.NDGGruppo__c){
                              System.debug('SV TROVATO CONTATTO NELLA RETE: ' + elemento);
                              find = true;
                              break;
                            }

                            ndgToSend.add(elemento);

                          }
                        }
                        System.debug('SV NDG TO SEND FOR '  + mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c') + ' : ' + ndgToSend);

                        if(!find){
                          WsAnagrafe.GestioneCollNdgResponse response_X = WsAnagrafe.WGC_variazionePfPgCollNdg(acc.NDGGruppo__c, con.NDGGruppo__c, (String)mapTipo_Rete.get(singleRole).get('Codice_Cedacri__c'), true, ndgToSend);
                        }
                      }
                    } else {
                      System.debug('SV NO RULES');
                    }

                    List<String> rolesInSingleRelation = new List<String>();
                    if(singleRelation.WGC_Ruolo__c != null){
                      rolesInSingleRelation = singleRelation.WGC_Ruolo__c.split(';');
                    }
                    
                    Boolean findRole = false;
                    for(String x : rolesInSingleRelation){
                      if(x == singleRole) findRole = true;
                    }

                    singleRelation.WGC_Ruolo__c = (singleRelation.WGC_Ruolo__c == '' || singleRelation.WGC_Ruolo__c == null) ? singleRole + ';' : !findRole ? singleRelation.WGC_Ruolo__c + ';' + singleRole + ';' : singleRelation.WGC_Ruolo__c + ';';

                  }
                  
                  singleRelation.WGC_Ruolo__c = singleRelation.WGC_Ruolo__c.removeEnd(';');

				    }
          }

          if (!accContactRelationList.isEmpty()) upsert accContactRelationList;

        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }
        
        return result;
        
    }

    @AuraEnabled
    public static Account getOriginAccount(String accountId) {
        System.debug('SV getInformationAccount: ' + accountId);

            Account acc = new Account();
            acc = [ SELECT Id, Name, Origine__c, CF__c, PIVA__c, NaturaGiuridica__c, StatoAnagrafica__c, RecordType.DeveloperName, WGC_Censimento__c
                    FROM Account 
                    WHERE Id =: accountId ];
            
        
        return acc;
        
    }
    
    @AuraEnabled
    public static Map < String, String > getCompatibleRoles(String naturaGiuridica){

        Map < String, String > allOpts = new Map < String, String > ();

        List < WGC_NaturaGiuridicaTipoRete__mdt > val_mdt = [ SELECT Id, Label, Tipo_Azienda__c FROM WGC_NaturaGiuridicaTipoRete__mdt  WHERE Label =: naturaGiuridica ];
        List < WGC_Ruolo_Tipo_Azienda__mdt > val_rolesA_mdt = [ SELECT Id, Label, Descrizione__c, Tipo_Azienda__c FROM WGC_Ruolo_Tipo_Azienda__mdt  WHERE Non_Legato_Tipo_Azienda__c = TRUE AND Label NOT IN ('Y1','W2','L2')];
        List < WGC_Ruolo_Tipo_Azienda__mdt > val_rolesB_mdt = [ SELECT Id, Label, Descrizione__c, Tipo_Azienda__c FROM WGC_Ruolo_Tipo_Azienda__mdt  WHERE Tipo_Azienda__c =: val_mdt[0].Tipo_Azienda__c ];
        List < WGC_Ruolo_Tipo_Azienda__mdt > val_rolesC_mdt = [ SELECT Id, Label, Descrizione__c, Tipo_Azienda__c FROM WGC_Ruolo_Tipo_Azienda__mdt  WHERE Non_Legato_Tipo_Azienda__c = TRUE AND Label NOT IN ('J')];

        // Add these values to the selectoption list.
        for (WGC_Ruolo_Tipo_Azienda__mdt a: val_rolesA_mdt) {
            allOpts.put(a.Label, a.Descrizione__c);
        }

        for (WGC_Ruolo_Tipo_Azienda__mdt b: val_rolesB_mdt) {
            allOpts.put(b.Label, b.Descrizione__c);
        }

        for (WGC_Ruolo_Tipo_Azienda__mdt c: val_rolesC_mdt) {
            allOpts.put(c.Label, c.Descrizione__c);
        }
        

        return allOpts;

    }

    
    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        
        @AuraEnabled public List<AccountContactRelation> accContactRelationList;
        
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

}