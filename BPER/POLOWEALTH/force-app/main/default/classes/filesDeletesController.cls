public without sharing class filesDeletesController {


    @AuraEnabled(cacheable=true)
    public static Object getFilesByKnowledgeId(String recordId){
        Map<String,Object> response = new Map<String,Object>();
        List<ContentDocumentLink> files =new List<ContentDocumentLink>();
        List<ContentDocument> contentDocs =new List<ContentDocument>();
        Set <Id> cntDocId= new Set <Id> ();
        try {
            files =[select  Id, LinkedEntity.name,ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility,ContentDocument.Title,ContentDocument.FileType, ContentDocument.CreatedDate,ContentDocument.Owner.name,ContentDocument.ContentSize
            from ContentDocumentLink where LinkedEntityId =:recordId];
            for(ContentDocumentLink cntl : files){
                cntDocId.add(cntl.ContentDocumentId);
            }
            contentDocs =[SELECT id, Title,FileType, CreatedDate,Owner.Name,ContentSize  FROM  ContentDocument WHERE id IN: cntDocId];
            response.put('files', files);
            response.put('contentDocs', contentDocs);
            response.put('error',false);
        } catch (QueryException e) {
            response.put('error',true);
            response.put('errorMsg',e.getMessage());
            response.put('errorStackTrace',e.getStackTraceString());
        }
        return response;
    }


    @AuraEnabled
    public static Object deleteFilesSelected(List<String> selectedRows) {
        Map<String,Object> response = new Map<String,Object>();
        try{
        String newOwnerId = UserInfo.getUserId();
        List<ContentDocument> filesToUpdate = new List<ContentDocument> ();
        response.put('error',false);
        if (!selectedRows.isEmpty() ) {
            filesToUpdate = [SELECT Id, OwnerId ,Owner.Name FROM ContentDocument WHERE Id IN :selectedRows];
            for (ContentDocument file : filesToUpdate) {
                file.OwnerId = newOwnerId;
            }
            update filesToUpdate;
            system.debug('filesToUpdate' +filesToUpdate);
        }
        delete filesToUpdate;
        }catch (DmlException e) {
         response.put('error',true);
         response.put('errorMsg',e.getMessage());
         response.put('errorStackTrace',e.getStackTraceString());
        }
        return response;
    }

    @AuraEnabled
    public static Boolean showDeleteButtonMethod() {
        String currentUserId = UserInfo.getUserId();
        String GroupId = 'Delete Files Knowledge';
        Boolean gruppoDeleteFiles = false;
        List<GroupMember> groupMember =[select Id, GroupId,Group.Name,  UserOrGroupId, SystemModstamp from GroupMember where Group.Name =:GroupId];
        for (GroupMember gr: GroupMember){
            if(gr.UserOrGroupId  == currentUserId){
            gruppoDeleteFiles = true;
        }
    }
    return gruppoDeleteFiles;
    }

    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
          ContentVersion cv = createContentVersion(base64, filename);
          ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
          if (cv == null || cdl == null) { return null; }
          return cdl.Id;
    }

    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }

      public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
          ContentDocumentLink cdl = new ContentDocumentLink();
          cdl.ContentDocumentId = [
              SELECT ContentDocumentId 
              FROM ContentVersion 
              WHERE Id =: contentVersionId
          ].ContentDocumentId;
          cdl.LinkedEntityId = recordId;
          cdl.ShareType = 'V';
          try {
              insert cdl;
              return cdl;
          } catch(DMLException e) {
              System.debug(e);
              return null;
          }
	 }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getExistingFiles(Id recordId, String filename) {
        List<ContentDocumentLink> existingFiles = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId AND ContentDocument.LatestPublishedVersion.Title = :filename
        ];
        
        return existingFiles;
    }
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getStatusKnowledge(Id recordId) {
        List<Knowledge__kav> StatusKnowledge = [
            SELECT Id, PublishStatus
            FROM Knowledge__kav
            WHERE id = :recordId AND (PublishStatus='Online' OR PublishStatus='Archived')
        ];
        
        return StatusKnowledge;
    }
  
    
}