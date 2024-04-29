public without sharing class CommunityPromotionsController {

    public class Promotions {
        @AuraEnabled
        public List<CampaignMember> campaignMembers {get; set;}
        @AuraEnabled
        public List<ContentDocumentLink> contentDocumentLinks {get; set;}
    }

    @AuraEnabled
    public static Promotions getPromotions() {
        return getPromotionsByUserId(UserInfo.getUserId());
    }

    @AuraEnabled
    public static Promotions getPromotionsByUserId(String userId) {
        Promotions promotions = new Promotions();

       /*
        if(String.isNotBlank(userId)) {
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :userId AND ContactId != NULL LIMIT 1];

            if (!users.isEmpty()) {
                Set<String> campaignIds = new Set<String>();
                promotions.campaignMembers = new List<CampaignMember>();

                for(CampaignMember campaignMember : [SELECT Id, CampaignId, Campaign.Name, Campaign.IsActive, Campaign.StartDate, Campaign.EndDate, ContactId, Contact.Name, Campaign.Division__c, Campaign.Company__c FROM CampaignMember WHERE ContactId = :users[0].ContactId AND Campaign.IsActive = TRUE AND Campaign.StartDate <= TODAY AND Campaign.EndDate >= TODAY ORDER BY Campaign.EndDate, Campaign.StartDate LIMIT 100]) {
                    campaignIds.add(campaignMember.CampaignId);
                    promotions.campaignMembers.add(campaignMember);
                }

                if(!campaignIds.isEmpty()) {
                    promotions.contentDocumentLinks = [SELECT LinkedEntityId, ContentDocument.Title, ContentDocumentId, ContentDocument.FileType, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN :campaignIds];
                }
            }
        }*/

        //NEW VERSION
        if(String.isNotBlank(userId)) {
            List<User> users = [SELECT Id, ContactId, Contact.Account.THR_CustomerIdentificationCode__c  FROM User WHERE Id = :userId AND ContactId != NULL AND Contact.Account.THR_CustomerIdentificationCode__c  != NULL LIMIT 1];

            if (!users.isEmpty()) {
                Set<Id> campaignIds = new Set<Id>();
                promotions.campaignMembers = new List<CampaignMember>();

                for(CampaignMember campaignMember : [SELECT Id, CampaignId, Campaign.Name, Campaign.IsActive, Campaign.StartDate, Campaign.EndDate, ContactId, Contact.Name, Campaign.Division__c, Campaign.Company__c FROM CampaignMember WHERE THR_Account_Key_Formula__c = :users[0].Contact.Account.THR_CustomerIdentificationCode__c  AND Campaign.IsActive = TRUE AND Campaign.StartDate <= TODAY AND Campaign.EndDate >= TODAY ORDER BY Campaign.EndDate, Campaign.StartDate LIMIT 100]) {
                    if(!campaignIds.contains(campaignMember.CampaignId)) {
                        promotions.campaignMembers.add(campaignMember);
                    }
                    campaignIds.add(campaignMember.CampaignId);
                }

                if(!campaignIds.isEmpty()) {
                    promotions.contentDocumentLinks = [SELECT LinkedEntityId, ContentDocument.Title, ContentDocumentId, ContentDocument.FileType, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN :campaignIds];
                }
            }
        }

        return promotions;
    }

    @AuraEnabled
    public static String getBase64File(String contentDocumentId) {
        String base64File;

        if(String.isNotBlank(contentDocumentId)) {
            ContentVersion contentVersion = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];

            if(contentVersion != null && contentVersion.VersionData != null) {
                base64File =  EncodingUtil.base64Encode(contentVersion.VersionData);
            }
        }

        return base64File;
    }

}