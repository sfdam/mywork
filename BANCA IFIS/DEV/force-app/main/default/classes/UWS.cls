public without sharing class UWS {
  public static Database.SaveResult[] updateObjs(SObject[] objs, Boolean allOrNone) {
    return Database.update(objs, allOrNone);
  }
  public static Database.SaveResult[] insertObjs(SObject[] objs, Boolean allOrNone) {
    return Database.insert(objs, allOrNone);
  }
}