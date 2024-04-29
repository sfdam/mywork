global with sharing class ExtSfdcLookup {
  public ExtSfdcLookup() {}
  public ExtSfdcLookup(ApexPages.StandardController ctrl) {}
  public ExtSfdcLookup(CtrlWizardAccount ctrl) {}
  public ExtSfdcLookup(CtrlFiloDiretto ctrl) {}

  @RemoteAction
  global static SObject[] searchComuni(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
    return search(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude, '(FlagStorico__c = FALSE AND StatoEstero__c = FALSE)');
  }

  @RemoteAction
  global static SObject[] search(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
    return search(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude, '');
  }

  @RemoteAction
  global static SObject[] searchEquals(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
    return search(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude, '', true);
  }

  public static SObject[] search(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude, String filters) {
    return search(fieldLabel, fieldValue, otherFields, targetObj, value, valuesToExclude, filters, false);
  }

  public static SObject[] search(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String v, String[] valuesToExclude, String filters, Boolean equals) {
    String value = String.isBlank(v) ? '' : (equals ? v : (v.replace('*', '%') + '%'));

    String[] fields = new String[]{fieldValue, fieldLabel};
    fields.addAll(otherFields);

    String q = QueryBuilder.newInstance(targetObj, fields)
    .beginFilter()
      .add(fieldLabel, equals ? QBOp.QEQUAL : QBOp.QLIKE, value)
      .add(fieldValue, QBOp.QNOT_IN, valuesToExclude)
      .addUntyped(filters, String.isNotBlank(filters))
    .endFilter()
    .setLimit(100)
    .getQuery();

    return Database.query(q);
  }

  @RemoteAction
  global static SObject[] searchFactoringUsers(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value, String[] valuesToExclude) {
    String v = String.isBlank(value) ? '' : '%' + (value.replace('*', '%') + '%');

    String[] fields = new String[]{fieldValue, fieldLabel};
    fields.addAll(otherFields);

    String q = QueryBuilder.newInstance('User', fields)
    .beginFilter()
      .add(fieldLabel, QBOp.QLIKE, v)
      .add(fieldValue, QBOp.QNOT_IN, valuesToExclude)
    .endFilter()
    .setLimit(100)
    .getQuery();

    User[] users = Database.query(q);
    User[] results = new User[]{};
    for (User u : users) {
      if (CU.isFactoring(u.Id)) results.add(u);
    }

    return results;
  }

  @RemoteAction
  global static SObject inverseLookup(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String value) {
    String[] fields = new String[]{fieldValue, fieldLabel};
    fields.addAll(otherFields);

    try {
      String q = QueryBuilder.newInstance(targetObj, fields)
        .beginFilter()
          .add(fieldValue, QBOp.QEQUAL, value, true)
        .endFilter()
        .getQuery();

      // System.debug('QUERY!!! ' + q);
      return Database.query(q)[0];
    } catch(Exception e) {
      return null;
    }
  }

  @RemoteAction
  global static String[] fetchStatiEsteri() {
    Comune__c[] tL = [SELECT Id, Name FROM Comune__c WHERE StatoEstero__c = TRUE AND FlagStorico__c = FALSE AND CodiceLingua__c = NULL ORDER BY Name];
    String[] res = new String[]{};
    for(Comune__c t : tL) {
      res.add(t.Name);
    }

    return res;
  }

  @RemoteAction
  global static Comune__c[] fetchStatiEsteriFull() {
    return [SELECT Id, Name, GruppoSAE__c FROM Comune__c WHERE StatoEstero__c = TRUE AND FlagStorico__c = FALSE AND CodiceLingua__c = NULL ORDER BY Name];
  }

  @RemoteAction
  global static String searchCodiceCatastaleComune(String city, String state) {

    Comune__c[] comuni = [SELECT CodiceCatastale__c FROM Comune__c
      WHERE Provincia__c = :state
      AND Name = :city
      AND FlagStorico__c = FALSE
      AND StatoEstero__c = FALSE
    ];

    return (!comuni.isEmpty()) ? comuni[0].CodiceCatastale__c : '';
  }

  @RemoteAction
  global static Map<String, String> getPicklistMap(String fieldName, String objectName) {
    Schema.SObjectField f = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
    return U.getPicklistMap(f);
  }

  @RemoteAction
  global static SObject[] searchRecent(String fieldLabel, String fieldValue, String[] otherFields, String targetObj, String[] valuesToExclude) {
    String[] fields = new String[]{fieldValue, fieldLabel};
    fields.addAll(otherFields);

    return Database.query(
      QueryBuilder.newInstance(targetObj, fields)
        .beginFilter()
          .add(fieldValue, QBOp.QNOT_IN, valuesToExclude)
        .endFilter()
        .setLimit(10)
        .orderBy(new String[]{'LastViewedDate DESC'})
        .getQuery()
    );
  }
}