({
	invoke : function(component, event, helper) {
   // Get the record ID attribute
   var record = component.get("v.recordId");
        console.log('DEBUG****** recordId is: '+record);
    
   // Get the Lightning event that opens a record in a new tab
   var navEvt = $A.get("e.force:navigateToSObject");
    
   // Pass the record ID to the event
   navEvt.setParams({
        "recordId": record,
       "slideDevName" : "detail"
    });
    navEvt.fire();
}
})