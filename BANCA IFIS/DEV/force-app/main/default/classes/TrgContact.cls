/**
* Progetto:         Banca IFIS
* Descrizione:      Classe handler del trigger Contact.trigger
* Sviluppata il:    03/01/2017
* Developer:        Michele Triaca
*/
public class TrgContact {
  public static Boolean skipCheckCodiceFiscale = false;

  /**
  * Metodo che controlla la coerenza tra cf, nome, cognome, data di nascita, sesso e località di nascita
  **/
  public static void checkCodiceFiscale(T tu) {
    if(skipCheckCodiceFiscale) return;

    Contact[] cL = tu
      .filter('CF__c', (String) null, false)
      .filter('MailingState', 'EE', false)
      .getChanged(new String[]{
        'LastName',
        'FirstName',
        'Birthdate',
        'Sesso__c',
        'CodCatastalLocNascita__c',
        'CF__c'
      });

    UtilCodiceFiscale utilCf = new UtilCodiceFiscale();
    for(Contact c : cL) {
      Boolean checkCf = true;

      if(String.isBlank(c.FirstName)) {
        c.FirstName.addError('Nome obbligatorio se presente il codice fiscale');
        checkCf = false;
      }
      if(c.Birthdate == null) {
        c.Birthdate.addError('Data di nascita obbligatoria se presente il codice fiscale');
        checkCf = false;
      }
      if(String.isBlank(c.Sesso__c)) {
        c.Sesso__c.addError('Sesso obbligatorio se presente il codice fiscale');
        checkCf = false;
      }
      if(String.isBlank(c.CodCatastaleLocNascita__c)) {
        c.LuogoNascita__c.addError('Località di nascita obbligatoria se presente il codice fiscale');
        checkCf = false;
      }

      if(checkCf) {
        String cf = utilCf.calculateCodiceFiscale(
          c.LastName,
          c.FirstName,
          c.BirthDate,
          c.Sesso__c,
          c.CodCatastaleLocNascita__c
        );

        if(!utilCf.checkOmocodia(c.CF__c, cf)) {
          c.CF__c.addError('Codice fiscale invalido o non coerente con i dati anagrafici');
        }
      }
    }
  }

  public static void associaAccountDiDefault(T tu) {
    for(Contact c : (Contact[]) tu.filter('AccountId', (String) null).triggerNew) {
      c.AccountId = UtenzeDefault__c.getInstance().IdAccountDiDefault__c;
    }
  }

  public static void ricalcolaIndirizzoCompleto(T tu) {
    Contact[] consChanged = (Contact[]) tu.getChanged(new String[] {'MailingStreetName__c', 'MailingStreetNumber__c', 'MailingStreetType__c'});
    for (Contact c : consChanged) {
      c.MailingStreet = UtilAnagrafiche.getIndirizzoCompleto(c.MailingStreetType__c, c.MailingStreetName__c, c.MailingStreetNumber__c);
    }
  }

  public static void truncateFields(T tu) {
    for(Contact c : (Contact[]) tu.triggerNew) {
      UtilAnagrafiche.truncateInSObject(c, new String[]{
        'MailingStreetName__c',
        'MailingState',
        'MailingCountry'
      }, 24);
    }
  }

  public static void inizializzaDati(T tu) {
    for (Contact c : (Contact[]) tu.triggerNew) {
      if (String.isBlank(c.CodiceIstituto3N__c)) c.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
      c.CI3N_CF__c = getCI3N_CF(c);
      if (String.isNotBlank(c.NDGGruppo__c)) c.CI3N_NDGGruppo__c = getCI3N_NDGGruppo(c);
    }
  }

  public static String getCI3N_CF(Contact c) {
    return getCI3N_CF(c.CodiceIstituto3N__c, c.CF__c);
  }

  public static String getCI3N_NDGGruppo(Contact c) {
    return getCI3N_NDGGruppo(c.CodiceIstituto3N__c, c.NDGGruppo__c);
  }

  public static String getCI3N_CF(String codiceIstituto3N, String cf) {
    if (String.isNotBlank(codiceIstituto3N) && String.isNotBlank(cf)) return codiceIstituto3N + '-' + cf;
    return null;
  }

  public static String getCI3N_NDGGruppo(String codiceIstituto3N, String ndgGruppo) {
    if (String.isNotBlank(codiceIstituto3N) && String.isNotBlank(ndgGruppo)) return codiceIstituto3N + '-' + ndgGruppo;
    return null;
  }
    
  //A.M. -> Start
  //Gestione Phone come campo concatenato di prefisso e numero (Before Insert e Update)
  public static void AggiornaTeleContact(T tu) {
    Contact[] ContChangedTel = new List <Contact>((Contact[]) tu.getChanged(new String[]{'TelefonoPrefisso__c', 'TelefonoNumero__c'}));
    if(ContChangedTel.isEmpty()) return;    
      
    for(Contact c : ContChangedTel){
      If (c.TelefonoPrefisso__c == null) {
          c.TelefonoPrefisso__c = ' ';
      } 
      If (c.TelefonoNumero__c == null) {
            c.TelefonoNumero__c = ' ';
      }
      c.Phone = c.TelefonoPrefisso__c + c.TelefonoNumero__c;
      System.debug('AM - Phone ' + c.Phone);   
    }
  }
  //A.M. -> End         
}