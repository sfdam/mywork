public with sharing class OpportunitaDaPianificareController {
    public OpportunitaDaPianificareController() {
    }

    @AuraEnabled
    public static List<Opportunity> getOpps(){
        
        List<Opportunity> opps = [SELECT Id, Name, NGR_del_cliente__c, Presentato_da__c, CIB_PresentatoDaId__c, AccountId, StageName, Informazioni_Privilegiate__c, 
                                    CIB_Nome_Opportunita__c, OraInizioIBC__c, OraFineIBC__c, Dati_Cliente__c, ProgressivoIBC__c
                                    FROM Opportunity WHERE OpportunitComitato__c = '' AND Memo_CIB_Saved__c = true AND Data_investment_committee__c = null];
        return opps;
    }

    @AuraEnabled
    public static Map<String,Object> getUsers(List<String> presentatiDa){
        Map<String,Object> userMap = new Map<String,Object>();
        Set<Id> QueueUserIds = getSelectedUsers();
        Set<Id> selectedUserIds = new Set<Id>();

        userMap.put('QueueUser', QueueUserIds);
        selectedUserIds.addAll(QueueUserIds);
        
        for(String userId : presentatiDa){
            selectedUserIds.add(userId);
        }

        //List<User> users = [SELECT Id, Name, Email FROM User WHERE Id IN :userIds ORDER BY Name];
        //users.addAll([SELECT Id, Name, Email FROM User WHERE Profile.UserLicense.Name = 'Salesforce' ORDER BY Name LIMIT 20]);
        List<User> users = [SELECT Id, Name, Email FROM User WHERE CRM_PermissionSet__c like '%CIB%' OR Id in :selectedUserIds ORDER BY Name];

        List<User> selectedUsers = new List<User>();
        List<User> otherUsers = new List<User>();
        for (User u : users) {
            if (selectedUserIds.contains(u.Id)) {
                selectedUsers.add(u);
            }
            else {
                otherUsers.Add(u);
            }
        }
        users = selectedUsers;
        users.addAll(otherUsers);

        userMap.Put('AllUsers', users);
        userMap.Put('SelectedUsers', selectedUserIds);
        return userMap;
    }

    @AuraEnabled
    public static Id assignOpps(List<Opportunity> opps, Datetime startDate, Datetime endDate){

        System.debug('TEST opps --> ' + opps);
        System.debug('TEST startDate --> ' + startDate);
        System.debug('TEST endDate --> ' + endDate);
        System.debug('TEST startDate.date() --> ' + startDate.date());

        TimeZone tz = TimeZone.getTimeZone('Europe/Rome');
        System.debug('Display name: ' + tz.getDisplayName());
        startDate = startDate.addSeconds(-tz.getOffset(startDate)/1000);
        endDate = endDate.addSeconds(-tz.getOffset(endDate)/1000);
        System.debug('TEST startDate --> ' + startDate);
        System.debug('TEST endDate --> ' + endDate);
        
        CIB_OpportunitaComitato__c comitato = new CIB_OpportunitaComitato__c(
            StartDateTime__c = startDate,
            DueDateTime__c = endDate
        );
        insert comitato;

        for (Opportunity opp : opps) {
            opp.OpportunitComitato__c = comitato.Id;
            opp.Data_investment_committee__c = startDate.date();
        }
        update opps;
        return comitato.Id;
    }

    @AuraEnabled
    public static void createEvents(List<Id> userIds, Datetime startDate, Datetime endDate, Id comitatoId){

        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Evento_Comitato_CIB'].Id;
        Integer durationInMinutes = (Integer)(endDate.getTime() - startDate.getTime()) / (1000 * 60);

        // Datetime startDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), startDate.hour(), startDate.minute(), startDate.second());
        // Datetime endDate = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), endDate.hour(), endDate.minute(), endDate.second());
        System.debug('TEST startDate --> ' + startDate);
        System.debug('TEST endDate --> ' + endDate);

        TimeZone tz = TimeZone.getTimeZone('Europe/Rome');
        System.debug('Display name: ' + tz.getDisplayName());
        startDate = startDate.addSeconds(-tz.getOffset(startDate)/1000);
        endDate = endDate.addSeconds(-tz.getOffset(endDate)/1000);
        System.debug('TEST startDate --> ' + startDate);
        System.debug('TEST endDate --> ' + endDate);
        

        userIds.Add(UserInfo.getUserId());
        List<Event> events = new List<Event>();
        for (Id userId : userIds) {
            events.Add(new Event(
                OwnerId = userId,
                StartDateTime = startDate,
                EndDateTime = endDate,
                DurationInMinutes = durationInMinutes,
                RecordTypeId = recordTypeId,
                WhatId = comitatoId,
                Subject = 'IB Committee meeting'
            ));
        }
        insert events;
    }

    public static Set<Id> getSelectedUsers() {
        Set<Id> users = new Set<Id>();

        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'CIB_GruppoComitato1'];

        for (GroupMember member : groupMembers) {
            if (member.UserOrGroupId.getSObjectType() == User.SObjectType) {
                users.add(member.UserOrGroupId);
            }
        }
        
        return users;
    }
}