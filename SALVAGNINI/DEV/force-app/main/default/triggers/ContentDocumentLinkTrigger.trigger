trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    ContentDocumentLinkTriggerHandler.prepareFilesForSP(Trigger.new);
    //https://salvagninigroup.sharepoint.com/sites/SGSalesDocsTS/2023/QUOTE/C000042715/OPP-000000696/Q-000000244

}