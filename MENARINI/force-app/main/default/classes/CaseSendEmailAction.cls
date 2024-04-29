public class CaseSendEmailAction {
  
    
  public class FlowInput {
      
  	@InvocableVariable(label='Case ID' description='Case ID' required=true)
  	public Id caseId;
      
  	@InvocableVariable(label='Template ID' description='Template ID' required=true)
    public Id templateId;

    @InvocableVariable(label='To Addresses' description='Specify oneor more addressses separeted by a comma' required=true)
    public String toAddresses;

    @InvocableVariable(label='CC Addresses' description='Specify one or more addressses separeted by a comma' )
    public List<String> ccAddresses;
      

  }
   
  @InvocableMethod(label='Send Case Email' description='send an email related to a Case with the specified Template' category='Case')
  public static void sendTemplateEmail(List<FlowInput> inputs) {
	system.debug('CaseSendEmailAction.sendTemplateEmail inputs.: ' + inputs);
	system.debug('CaseSendEmailAction.sendTemplateEmail inputs.size.: ' + inputs.size());
    Id recordId;
    Id templateId;
    List<String> toAddresses;
    List<String> ccAddresses;
    //List<Id> recordIdsList = new List<Id>();
    Map<String,String> caseIdToTemplateIdMap = new Map<String,String>();
    Map<String,List<String>> caseIdToAddressMap = new Map<String,List<String>>();
    Map<String,List<String>> caseIdToccAddressMap = new Map<String,List<String>>();

    for(FlowInput anInput : inputs){
        caseIdToTemplateIdMap.put(anInput.caseId,anInput.templateId);
        toAddresses = new List<String>();
        ccAddresses = new List<String>();
        if(anInput.toAddresses != null && !String.isBlank(anInput.toAddresses) ){
            for(String anAddress :anInput.toAddresses.split(',')){
                toAddresses.add(anAddress.trim());
            }
        }
		caseIdToAddressMap.put(anInput.caseId,toAddresses);
        templateId = anInput.templateId;
        ccAddresses = new List<String>();
        if(anInput.ccAddresses != null && !anInput.ccAddresses.isEmpty() ){
            for(String ccAddress :anInput.ccAddresses){
                ccAddresses.add(ccAddress.trim());
            }       
        }
        caseIdToccAddressMap.put(anInput.caseId,ccAddresses);

    }
      
       system.debug('CaseSendEmailAction.sendTemplateEmail caseIdToAddressMap.: ' + caseIdToAddressMap);
       system.debug('CaseSendEmailAction.sendTemplateEmail caseIdToccAddressMap.: ' + caseIdToccAddressMap);
       system.debug('CaseSendEmailAction.sendTemplateEmail toAddresses.: ' + toAddresses);
       system.debug('CaseSendEmailAction.sendTemplateEmail ccAddresses.: ' + ccAddresses);
       system.debug('CaseSendEmailAction.sendTemplateEmail templateId.: ' + templateId);
      
      List<String> templateIdList = caseIdToTemplateIdMap.values();
      
      Map<Id,EmailTemplate> emailTemplateMap = new Map<Id,EmailTemplate>([SELECT Id, 
                                                                          		 Name, 
                                                                          		 Subject, 
                                                                                 Body, 
                                                                                 FolderId, 
                                                                                 Folder.Name, 
                                                                                 HTMLValue, 
                                                                                 DeveloperName 
                                                                          FROM EmailTemplate 
                                                                          WHERE Id IN :templateIdList]);
      system.debug('CaseSendEmailAction.sendTemplateEmail emailTemplateMap.: ' + emailTemplateMap);
      
      Map<String,EmailTemplate> caseIdToEmailTemplateMap = new Map<String,EmailTemplate>();
      system.debug('CaseSendEmailAction.sendTemplateEmail caseIdToTemplateIdMap.size.: ' + caseIdToTemplateIdMap.keySet().size());
      for(String caseId : caseIdToTemplateIdMap.keySet()){
          caseIdToEmailTemplateMap.put(caseId,emailTemplateMap.get(caseIdToTemplateIdMap.get(caseId)));
      }
      system.debug('CaseSendEmailAction.sendTemplateEmail caseIdToEmailTemplateMap: ' + caseIdToEmailTemplateMap);

      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>{};
      system.debug('CaseSendEmailAction.sendTemplateEmail queryCase.: ' + [SELECT Id,ContactId,THR_ClientContacted__c,Status FROM Case WHERE id= :caseIdToEmailTemplateMap.keySet()]);

      for(Case currentCase : [SELECT Id,ContactId,THR_ClientContacted__c,Status FROM Case WHERE id= :caseIdToEmailTemplateMap.keySet()]) {
           system.debug('CaseSendEmailAction.sendTemplateEmail currentCase.: ' + currentCase);
              if(!test.isRunningTest()){
                 
                  message = Messaging.renderStoredEmailTemplate(caseIdToTemplateIdMap.get(currentCase.Id), currentCase.ContactId, currentCase.Id);
              }
              system.debug('CaseSendEmailAction.sendTemplateEmail renderStoreEmailTemplate.: ' + message.getHtmlBody());
              message.setTemplateId(caseIdToTemplateIdMap.get(currentCase.Id));
          	  message.setToAddresses(caseIdToAddressMap.get(currentCase.Id));
          	  message.setccAddresses(caseIdToccAddressMap.get(currentCase.Id));
              message.setSaveAsActivity(true);
              message.setTargetObjectId(currentCase.ContactId);
              message.setWhatId(currentCase.Id);
              msgList.add(message);
      }
      system.debug('CaseSendEmailAction.sendTemplateEmail msgList: ' + msgList);
      
      if (!msgList.isEmpty()) {
          Messaging.SendEmailResult[] results = new Messaging.SendEmailResult[]{};
              results = Messaging.sendEmail(msgList, false);
          	system.debug('CaseSendEmailAction.sendTemplateEmail results.size: ' + results.size());
          if (!results.isEmpty()){
              if(results[0].success) {
                  System.debug('CaseSendEmailAction.sendTemplateEmail: email was sent successfully.');
              } else {
                  System.debug('CaseSendEmailAction.sendTemplateEmail: The email failed to send: ' + results[0].errors[0].message);
                  //throw new SendForServiceMailException(results[0].errors[0].message);
              }      
          }
          else{
              system.debug('CaseSendEmailAction.sendTemplateEmail no result');
          }
      }
          
      }
        //END
    
}