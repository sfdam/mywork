global class InboundSocialPostHandlerImpl extends Social.InboundSocialPostHandlerImpl implements Social.InboundSocialPostHandler {   
    
    // If true, use the active case assignment rule if one is found
    global override Boolean getUsingCaseAssignmentRule(){
        return true;
    }
    
    global override Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 0;
    }
    
    private Case findParentCase(SocialPost post, SocialPersona persona) {
        Case parentCase = null;
        if (!isChat(post) && (isReplyingToOutboundPost(post) && (isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) || (!isReplyingToOutboundPost(post) && isReplyingToSelf(post,persona)))) {
            System.debug('node 1');
            parentCase = findParentCaseFromPostReply(post);
            if (isParentCaseValid(parentCase)) { 
                return parentCase;
            }
        }
        
        if (!isChat(post)){
            System.debug('Is not chat');
            
            parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
        }else{
            System.debug('Is chat');
            
            parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);	
        }
        
        return parentCase;
    }
    
    private boolean isChat(SocialPost post) {
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }
    
    private boolean isParentCaseValid(Case parentCase) {
        return parentCase != null && (!parentCase.IsClosed || caseShouldBeReopened(parentCase));
    }
    
    // reply to outbound post
    private boolean isReplyingToOutboundPost(SocialPost post) {
        return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }
    
    // replyTo.recipient == inboundSocialPost.persona.externalId
    @TestVisible
    private boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient, SocialPersona persona) {
        return (postWithRecipient != null && postWithRecipient.Recipient == persona.ExternalId);
    }
    
    private Case findParentCaseFromPostReply(SocialPost post) {
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestReplyToPost = findLatestInboundChatPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestReplyToPost != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestReplyToPost.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    private SocialPost findLatestInboundChatPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona){
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false AND MessageType = :post.MessageType ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }
    
    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false AND MessageType not in ('Private', 'Direct') ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }
    
    // is replying to self
    private boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
        return (post != null && 
                persona != null && 
                String.isNotBlank(persona.Id) && 
                post.ReplyTo != null &&
                String.isNotBlank(post.ReplyTo.PersonaId) &&
                post.ReplyTo.PersonaId == persona.id);
    }
    
    @TestVisible
    private boolean caseShouldBeReopened(Case c){
        return c.id != null && c.isClosed && c.closedDate != null && System.now() < c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }
}