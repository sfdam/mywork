public class Ex {
  public class WSException extends Exception {}
  public class WSCalloutException extends Exception {}
  public class DocumentaleException extends Exception {}
  public class RibesException extends Exception {}
  public class AnagrafeDiGruppoException extends Exception {}
  public class CedacriInputException extends Exception {}
  public class RibesInputException extends Exception {}
  public class BtcConvertLeadException extends Exception {}
  public class PdfException extends Exception {}
  public class RestStatoOpportunitaException extends Exception {}
  public class GenericException extends Exception {}

  public static String getReadableMessage(Exception e) {
    String tmp = e.getMessage();
    if (tmp.contains('Your password must be at least 8 characters long')) return 'La password deve essere lunga almeno 8 caratteri e contenere una combinazione di lettere e numeri.';
    if (tmp.contains('Your password must have a mix of letters and numbers')) return 'La password deve essere lunga almeno 8 caratteri e contenere una combinazione di lettere e numeri.';
    if (tmp.contains('Invalid email address')) return 'Inserire un indirizzo email valido.';
    if (tmp.contains('Read timed out') || tmp.contains('Errore servizi') || tmp.contains('404 Not Found') || tmp.contains('il servizio non ha resituito un json valido')) return 'ERRORE_SERVIZI';
    if (tmp.contains('DUPLICATE_USERNAME')) return 'Esiste già un utente con lo stesso username. Contatta Banca IFIS per maggiori informazioni.';
    if (tmp.contains('LICENSE_LIMIT_EXCEEDED')) return 'In questo momento non è possibile completare la registrazione. Contatta Banca IFIS per maggiori informazioni.';
    if (tmp.contains('DUPLICATE_VALUE, duplicate value found: CF__c')) return 'Esiste già un contatto con questo codice fiscale.';

    Pattern myPattern = Pattern.compile('FIELD_CUSTOM_VALIDATION_EXCEPTION, ([^:]+)');
    Matcher myMatcher = myPattern.matcher(tmp);
    if (myMatcher.find()) {
      String regexResult = myMatcher.group(1);
      if (String.isNotBlank(regexResult)) return regexResult;
    }

    return tmp;
  }
}