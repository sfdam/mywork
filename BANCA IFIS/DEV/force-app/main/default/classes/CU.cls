public with sharing class CU {
  private static Map<Id, String> userRoleMap = new Map<Id, String>();

  public static void addToCache(Set<Id> userIds) {
    Set<Id> realUserIds = new Set<Id>();
    for (Id uId : userIds) {
      if (!userRoleMap.containsKey(uId)) realUserIds.add(uId);
    }

    if (!realUserIds.isEmpty()) {
      Map<Id, User> uLMap = new Map<Id, User>([SELECT UserRole.DeveloperName, NDGGruppo__c FROM User WHERE Id IN :userIds]);
      for (Id uId : userIds) {
        User u = ulMap.get(uId);
        String ruolo = u == null || u.UserRole == null ? '' : u.UserRole.DeveloperName;
        userRoleMap.put(uId, ruolo);
      }
    }
  }

  //dato l'id di un ruolo, restituisce la lista degli id di tutti i ruoli padri di esso
  public static Set<Id> getUserParentsRoleHierarchy(Id userRoleId){
    Map<Id,UserRole> userRoles = new Map<Id,UserRole>([SELECT Id, ParentRoleId FROM UserRole]);
    Set<Id> listHierarchy = new Set<Id>();

    while(userRoles.get(userRoleId).ParentRoleId != null){
      listHierarchy.add(userRoles.get(userRoleId).ParentRoleId);
      userRoleId = userRoles.get(userRoleId).ParentRoleId;
    }
    return listHierarchy;
  }

  private static String getUserRole(Id userId) {
    if (String.isBlank(userId)) return '';
    if (!userRoleMap.containsKey(userId)) addToCache(new Set<Id> {userId});
    return userRoleMap.get(userId);
  }

  public static Boolean isFiloDiretto() {
    return isFiloDiretto(UserInfo.getUserId());
  }

  public static Boolean isCommerciale() {
    return isCommerciale(UserInfo.getUserId());
  }

  public static Boolean isResponsabileFiliale() {
    return isResponsabileFiliale(UserInfo.getUserId());
  }

  public static Boolean isGestoreDebitori() {
    return isGestoreDebitori(UserInfo.getUserId());
  }

  public static Boolean isLeasing() {
    return isLeasing(UserInfo.getUserId());
  }

  public static Boolean isLeasingCommerciale() {
    return isLeasingCommerciale(UserInfo.getUserId());
  }

  public static Boolean isLeasingSuperuser() {
    return isLeasingSuperuser(UserInfo.getUserId());
  }

  public static Boolean isFastFinance() {
    return isFastFinance(UserInfo.getUserId());
  }

  public static Boolean isFastFinanceCommerciale() {
    return isFastFinanceCommerciale(UserInfo.getUserId());
  }

  public static Boolean isFastFinanceSuperuser() {
    return isFastFinanceSuperuser(UserInfo.getUserId());
  }

  public static Boolean isLending() {
    return isLending(UserInfo.getUserId());
  }

  public static Boolean isLendingCommerciale() {
    return isLendingCommerciale(UserInfo.getUserId());
  }

  public static Boolean isLendingSuperuser() {
    return isLendingSuperuser(UserInfo.getUserId());
  }

  public static Boolean isFinance() {
    return isFinance(UserInfo.getUserId());
  }

  public static Boolean isFinanceCommerciale() {
    return isFinanceCommerciale(UserInfo.getUserId());
  }

  public static Boolean isFinanceSuperuser() {
    return isFinanceSuperuser(UserInfo.getUserId());
  }

  public static Boolean isFinanzaStrutturata() {
    return isFinanzaStrutturata(UserInfo.getUserId());
  }

  public static Boolean isFinanzaStrutturataCommerciale() {
    return isFinanzaStrutturataCommerciale(UserInfo.getUserId());
  }

  public static Boolean isFinanzaStrutturataSuperuser() {
    return isFinanzaStrutturataSuperuser(UserInfo.getUserId());
  }

  public static Boolean isInternational() {
    return isInternational(UserInfo.getUserId());
  }

  public static Boolean isFactoring() {
    return isFactoring(UserInfo.getUserId());
  }

  public static Boolean isFactoring(Id userId) {
    return isFiloDiretto(userId) || isCommerciale(userId) || isGestoreDebitori(userId) || isInternational(userId);
  }

  public static Boolean isFiloDiretto(Id userId) {
    return getUserRole(userId).containsIgnoreCase('FiloDiretto');
  }

  public static Boolean isResponsabileFiliale(Id userId) {
    return getUserRole(userId).containsIgnoreCase('ResponsabileFiliale');
  }

  public static Boolean isCommerciale(Id userId) {
    return getUserRole(userId).containsIgnoreCase('Commerciale') || isResponsabileFiliale(userId);
  }

  public static Boolean isGestoreDebitori(String value) {
    return getUserRole(value).containsIgnoreCase('Debitori');
  }

  public static Boolean isLeasing(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('Leasing');
  }

  public static Boolean isLeasingCommerciale(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('CommLeasing');
  }

  public static Boolean isLeasingSuperuser(String userId) {
    return getUserRole(userId).containsIgnoreCase('RespLeasing');
  }

  public static Boolean isFastFinance(String userId) {
    return getUserRole(userId).containsIgnoreCase('FastFinance');
  }

  public static Boolean isFastFinanceCommerciale(String userId) {
    return getUserRole(userId).containsIgnoreCase('CommFastFinance');
  }

  public static Boolean isFastFinanceSuperuser(String userId) {
    return getUserRole(userId).containsIgnoreCase('RespFastFinance');
  }

  public static Boolean isLending(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('Lending');
  }

  public static Boolean isLendingCommerciale(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('CommLending');
  }

  public static Boolean isLendingSuperuser(String userId) {
    return getUserRole(userId).containsIgnoreCase('RespLending');
  }

  public static Boolean isFinance(String userId) {
    return isFinanceCommerciale(userId) || isFinanceSuperuser(userId);
  }

  public static Boolean isFinanceCommerciale(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('CommFinance');
  }

  public static Boolean isFinanceSuperuser(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('RespFinance');
  }

  public static Boolean isFinanzaStrutturata(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('FinanzaStrutturata');
  }

  public static Boolean isFinanzaStrutturataCommerciale(String userId) {
    String userRole = getUserRole(userId);
    return userRole.containsIgnoreCase('CommFinanzaStrutturata');
  }

  public static Boolean isFinanzaStrutturataSuperuser(String userId) {
    return getUserRole(userId).containsIgnoreCase('RespFinanzaStrutturata');
  }

  public static Boolean isInternational(String value) {
    return getUserRole(value).containsIgnoreCase('International');
  }
}