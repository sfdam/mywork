public without sharing class TrgLead {

  /**
   * Al cambio di stato in 'Da qualificare' faccio partire il batch di conversione lead
   * Quando: after insert/update
   * D: Michele Triaca
   */
  public static void startConversionBatch(T tu) {
    Lead[] lL = tu.filter('Status', 'Da qualificare').getChanged('Status');
    if(!lL.isEmpty()) {
      BI_COM_ConversioneLead_BTCH b = new BI_COM_ConversioneLead_BTCH(U.getIdSet(lL, 'Id'));
      Database.executeBatch(b, 1);
    }
  }

}