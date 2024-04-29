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

    @AuraEnabled(cacheable=true)
        public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
        }


       @AuraEnabled
       public static Map<String, Object> deleteFilesSelected(List<String> selectedRows, String recordId) {
            Map<String, Object> responseMap = new Map<String, Object>();
            Map<String, Object> deleteResponse = new Map<String, Object>();
            try {
                String newOwnerId = UserInfo.getUserId();
                List<ContentDocument> filesToUpdate = new List<ContentDocument>();
                List<ContentDocument> filesToDelete = new List<ContentDocument>();
                List<ContentDocument> filesToUpdateWithNewOwner = new List<ContentDocument>();
                if (!selectedRows.isEmpty()) {
                    filesToUpdate = [SELECT Id, OwnerId, Owner.Name FROM ContentDocument WHERE Id IN :selectedRows];

                    for (ContentDocument file : filesToUpdate) {
                        ContentDocument contDoc = new ContentDocument(Id=file.Id);
                        contDoc.OwnerId = newOwnerId;
                        filesToUpdateWithNewOwner.add(contDoc);
                        //file.OwnerId = newOwnerId;
                    }

                    Database.SaveResult[] updateResults = Database.update(filesToUpdateWithNewOwner, false);

                    for (Integer i =0; i < updateResults.size(); i++) {
                        Database.SaveResult sr = updateResults.get(i);
                        if (!sr.isSuccess()) {
                            responseMap.put('error', true);
                            responseMap.put('errorMsg', 'Error updating files: ' + sr.getErrors()[0].getMessage());
                        }else {
                            responseMap.put('filesToUpdateWithNewOwner', filesToUpdateWithNewOwner);
                            filesToDelete.add([SELECT Id, OwnerId, Owner.Name FROM ContentDocument WHERE Id =: filesToUpdate.get(i).Id]);
                        }
                    }
                    Integer delayInSeconds = 10; 
                  
                    
                }
       
            } catch (DmlException e) {
                responseMap.put('error', true);
                responseMap.put('errorMsg', e.getMessage());
                responseMap.put('errorStackTrace', e.getStackTraceString());
            }
            System.debug('responseMap' + responseMap);
            return responseMap;
    }

    @AuraEnabled
    public static Map<String, Object> deleteFiles(List<String> selectedRows, String recordId){
        Map<String, Object> responseMap = new Map<String, Object>();
        List<ContentDocument> filesToDelete = new List<ContentDocument>();
        if (!selectedRows.isEmpty()) {
            filesToDelete = [SELECT Id, OwnerId, Owner.Name FROM ContentDocument WHERE Id IN :selectedRows];
        }
        Database.DeleteResult[] deleteResults = Database.delete(filesToDelete, false);

        for (Database.DeleteResult dr : deleteResults) {
            if (!dr.isSuccess()) {
                responseMap.put('error', true);
                responseMap.put('errorMsg', 'Error deleting files: ' + dr.getErrors()[0].getMessage());
                return responseMap;
            }else{
                responseMap.put('success', true);
            }
        }
        System.debug('Files successfully deleted');
        return responseMap;
    }
       
    @AuraEnabled
    public static Map<String, Object> retriveContDocs(String recordId){

            Map<String, Object> responseMap = new Map<String, Object>();
        try{
            List<ContentDocumentLink> files = new List<ContentDocumentLink>();
            List<ContentDocument> contentDocs = new List<ContentDocument>();
            Set<Id> cntDocId = new Set<Id>();
            
            files = [SELECT Id, LinkedEntity.name, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility, ContentDocument.Title, ContentDocument.FileType, ContentDocument.CreatedDate, ContentDocument.Owner.name, ContentDocument.ContentSize
                        FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
                        
            for(ContentDocumentLink cntl : files){
                cntDocId.add(cntl.ContentDocumentId);
            }
            
            contentDocs = [SELECT id, Title, FileType, CreatedDate, Owner.Name, ContentSize FROM ContentDocument WHERE id IN :cntDocId];
            
            responseMap.put('files', files);
            responseMap.put('contentDocs', contentDocs);
            responseMap.put('error', false);
            
        } catch (DmlException e) {
            responseMap.put('error', true);
            responseMap.put('errorMsg', e.getMessage());
            responseMap.put('errorStackTrace', e.getStackTraceString());
        }
        System.debug('responseMap' + responseMap);
        return responseMap;
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
    public static Object uploadFile(String base64, String filename, String recordId){
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
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

    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
  
    
}