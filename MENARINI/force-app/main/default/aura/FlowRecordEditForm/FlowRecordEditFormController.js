({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            cmp.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            cmp.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            cmp.set("v.canFinish", true);
         }
      }
    
      var requestedFields = cmp.get('v.REQ_fields');
      var readOnlyFields = cmp.get('v.RO_fields');
      var fields = cmp.get('v.fields').split(',');
      var fieldsArray= [];
       for (var i = 0; i < fields.length; i++) {
           fieldsArray[i] = new Object();
           fieldsArray[i].Name = fields[i].trim();
           fieldsArray[i].Required = ( requestedFields.includes(fieldsArray[i].Name) ? true : false);
           fieldsArray[i].ReadOnly = ( readOnlyFields.includes(fieldsArray[i].Name)  ? true : false);
           console.log('fieldsArray[i].Name : ' + fieldsArray[i].Name );
           console.log('fieldsArray[i].required : ' +  fieldsArray[i].Required );
           console.log('fieldsArray[i].ReadOnly : ' +  fieldsArray[i].ReadOnly );
           console.log('fieldsArray.length : ' + fieldsArray.length  );
      }
      
      cmp.set('v.OBJ_fields', fieldsArray );
   },
        
   onButtonPressed: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   },
    
   onSuccess: function(cmp, event, helper) {
      // Figure out which action was called
      var actionClicked;
      // Fire that action
      var navigate = cmp.get('v.navigateFlow');
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "NEXT") {
            actionClicked = availableActions[i];
         }
      }
      navigate(actionClicked);
   }
})