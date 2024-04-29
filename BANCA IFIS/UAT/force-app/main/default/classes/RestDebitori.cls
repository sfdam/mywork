@RestResource(urlMapping = '/debitori')
global class RestDebitori {

  global class Debitore {
    @testVisible String codiceFiscale;
    String ragioneSociale;

    public Debitore(String codiceFiscale, String ragioneSociale) {
      this.codiceFiscale = codiceFiscale;
      this.ragioneSociale = ragioneSociale;
    }
  }

  global class DebitoriResponse {
    Boolean success = true;
    String message;
    @testVisible Debitore[] debitori;

    public DebitoriResponse() {
      this.debitori = new Debitore[] {};
    }

    public void addDebitore(Debitore d) {
      this.debitori.add(d);
    }

    public void setError(String message) {
      this.success = false;
      this.message = message;
    }
  }

  @HttpGet
  global static DebitoriResponse getDebitori() {
    DebitoriResponse response = new DebitoriResponse();
    try {
      Account[] debitori = TaCtrlDettaglio.fetchDebitoriTA();
      for (Account a : debitori) {
        response.addDebitore(new Debitore(a.CF__c, a.Name));
      }
    } catch (Exception e) {
      response.setError(e.getMessage());
    }
    return response;
  }
}