public with sharing class EnhancedRecordListControllerWithS {
    @AuraEnabled
    public static Integer getTotalRecords(String targetObject, List<EnhancedRecordListController.FilterGroup> filterGroups) {
        return EnhancedRecordListController.getTotalRecords(targetObject, filterGroups);
    }

    @AuraEnabled
    public static EnhancedRecordListController.EnhancedRecordList getEnhancedRecordList(String targetObject, List<EnhancedRecordListController.TargetField> targetFields, List<EnhancedRecordListController.FilterGroup> filterGroups, String distinctTargetOrderByField, String targetOrderByField, Boolean ascending, Integer entriesForPage, List<EnhancedRecordListController.Filter> firstValueOfSortedFields, List<EnhancedRecordListController.Filter> lastValueOfSortedFields, Boolean nullsFirst) {
        return EnhancedRecordListController.getEnhancedRecordList(targetObject, targetFields, filterGroups, distinctTargetOrderByField, targetOrderByField, ascending, entriesForPage, firstValueOfSortedFields, lastValueOfSortedFields, nullsFirst);
    }
}