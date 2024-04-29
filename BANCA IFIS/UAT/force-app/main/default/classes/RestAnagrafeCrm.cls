@RestResource(urlMapping = '/AnagrafeCrm')
global with sharing class RestAnagrafeCrm {
  private RestAnagrafeCrm() {}

  // global class DatiAnagraficiInputPayload {
  //   DatiAnagraficiCedacriGlobal datiAnagraficiCedacri;
  // }

  global class DatiAnagraficiCedacriGlobal extends WsAnagrafe.DatiAnagraficiCedacri {}

  @HttpPost
  global static RestCommon.ResponseObject updateNdg(
    RestCommon.TechInfo techInfo,
    // MB - TEN: Modificato parametro in input per gestione nodo "paylaod"
    DatiAnagraficiCedacriGlobal payload
  ) {
    String resultMessage;
    String codice;

    try {
      WsAnagraficaBeanIn b = new WsAnagraficaBeanIn(payload);
      SObject obj = b.getObj();
      if (obj.getSObjectType() == Account.SObjectType) {
        Account[] aL = [
          SELECT Id
          FROM Account
          WHERE NDGGruppo__c = :String.valueOf(obj.get('NDGGruppo__c'))
          AND CodiceIstituto3N__c = :String.valueOf(b.getDa().codiceIstituto3N)
        ];
        obj.put('CI3N_NDGGruppo__c', TrgAccount.getCI3N_NDGGruppo((String) obj.get('CodiceIstituto3N__c'), (String) obj.get('NDGGruppo__c')));
        obj.put('PIVACF__c', TrgAccount.getPIVACF((String) obj.get('PIVA__c'), (String) obj.get('CF__c')));
        obj.put('CI3N_PIVA_CF__c', TrgAccount.getCI3N_PIVA_CF((String) obj.get('CodiceIstituto3N__c'), (String) obj.get('PIVACF__c')));
        if (!aL.isEmpty()) {
          Database.upsert(obj, Account.CI3N_NDGGruppo__c);
        }
      } else {
        Contact c = (Contact) obj;
        c.CI3N_CF__c = TrgContact.getCI3N_CF(c);
        Contact[] cL = [
          SELECT Id
          FROM Contact
          WHERE CI3N_CF__c = :c.CI3N_CF__c
        ];
        if (!cL.isEmpty()) {
          Database.upsert(c, Contact.CI3N_CF__c);
        }
      }
      codice = RestCommon.NESSUN_ERRORE;
    } catch (Exception e) {
      resultMessage = e.getMessage();
      codice = RestCommon.ERRORE_GENERICO;
    }
    RestCommon.ResponseObject response = new RestCommon.ResponseObject(codice, resultMessage);

    RestCommon.logInboundMessage('AnagrafeCrm Inbound', new Object[] {payload}, response);

    return response;
  }

}