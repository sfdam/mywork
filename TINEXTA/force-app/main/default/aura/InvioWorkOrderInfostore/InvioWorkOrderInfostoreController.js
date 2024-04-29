({
    doInit: function (component, event, helper) {
      var action=component.get("c.InvioWorkOrderInfostore");
      action.setParams({
          recordId: component.get("v.recordId")
      });
      action.setCallback(this, response => {
          if(response.getState() === "SUCCESS"){
              console.log('@@@ response ' , response.getReturnValue());
              component.set("v.success", response.getReturnValue() == 'OK');
              if(response.getReturnValue() != 'OK'){
                  var toast = $A.get("e.force:showToast");
                  toast.setParams({
                      title: $A.get("$Label.c.WRT_Error"),
                      message: $A.get("$Label.c.WRT_Error_Message"),
                      type: "error"
                  });
                  toast.fire();
                  console.log('@@@ errore');
  
                  component.set("v.responseStr", $A.get("$Label.c.WRT_Error_Response")+' ' + response.getReturnValue());
              } else {
                  var toast = $A.get("e.force:showToast");
                  toast.setParams({
                      title: $A.get("$Label.c.WRT_Success"),
                      message: $A.get("$Label.c.WRT_Success_message"),
                      type: "success"
                  });
                  toast.fire();
                  component.set("v.responseStr", $A.get("$Label.c.WRT_Success_message"));
              }
  
              $A.get('e.force:refreshView').fire();
  
          } else {
              var toast = $A.get("e.force:showToast");
              toast.setParams({
                  title: $A.get("$Label.c.WRT_Error"),
                  message: $A.get("$Label.c.WRT_Error_Message"),
                  variant: "error"
              });
              toast.fire();
              console.log('@@@ errore');
              component.set("v.responseStr",  $A.get("$Label.c.WRT_Error_Response"));
          }
  
          $A.util.toggleClass(component.find("loader"), 'slds-hide');
          $A.util.toggleClass(component.find("loader2"), 'slds-hide');
          $A.util.toggleClass(component.find("response"), 'slds-hide');
      });
      $A.enqueueAction(action);
    },
  
    close : function(component, event, helper){
      $A.get("e.force:closeQuickAction").fire();
    },
  });