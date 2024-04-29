({
    doInit : function(component, event, helper) {
        var navService = component.find("navService");
        var sObjectName = component.get("v.sObjectName");
        var recordId = component.get("v.recordId");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId:recordId,
                objectApiName: sObjectName,
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
	}
})