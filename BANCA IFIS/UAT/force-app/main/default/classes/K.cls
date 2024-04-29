public with sharing class K {
  public K(ApexPages.StandardController ctrl) {}
  public K() {}

  //Codici prodotto usati per logiche particolari nel codice
  public static final String CODPROD_FIDO = 'Fido';
  public static final String CODPROD_IFIS_IMPRESA = 'IfisImpresa';
  // MB - TEN: Aggiunto codice "C/C Imprese non Residente Euro"
  public static final String CODPROD_IFIS_IMPRESA_NON_RESIDENTE = 'IfisImpresaNonResidente';
  public static final String CODPROD_IFIS_IMPRESA_NON_AFFIDATO = 'IfisImpresaNonAffidato';
  public static final String CODPROD_MUTUO = 'Mutuo';
  public static final String CODPROD_MUTUO_BRT = 'MutuoBRT';
  public static final String CODPROD_MUTUO_PCNSA = 'MutuoPCNSA'; //Mutuo MCC NSA
  public static final String CODPROD_MUTUO_PCNSASA = 'MutuoPCNSASA'; //Mutuo MCC NSA Assicurativo
  public static final String CODPROD_CON_PROROGA = 'ConProroga';
  public static final String CODPROD_STANDARD = 'Standard';

  //Codici consensi privacy webservices
  public final static String CONSENSO_PROFILAZIONE = '6020';
  public final static String CONSENSO_PROD_MKT = '6021';
  public final static String CONSENSO_PROD_TERZI = '6022';
  public final static String CONSENSO_PROMOZ_MKT = '6023';
  public final static String CONSENSO_PROMOZ_TERZI = '6024';
  public final static String CONSENSO_MOD_TRADIZ = '6025';
  public final static String CONSENSO_BENEFONDI = '6026';

  @RemoteAction
  public static Map<String, String> getCostanti() {
    return new Map<String, String>{
      'CODPROD_FIDO' => CODPROD_FIDO,
      'CODPROD_IFIS_IMPRESA' => CODPROD_IFIS_IMPRESA,
      'CODPROD_IFIS_IMPRESA_NON_AFFIDATO' => CODPROD_IFIS_IMPRESA_NON_AFFIDATO,
      'CODPROD_MUTUO' => CODPROD_MUTUO,
      'CODPROD_CON_PROROGA' => CODPROD_CON_PROROGA,
      'CODPROD_STANDARD' => CODPROD_STANDARD
    };
  }
}