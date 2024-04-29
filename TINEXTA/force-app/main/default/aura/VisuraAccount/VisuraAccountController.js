({
    doInit: function (component, event, helper) {
        
        var actionAccount=component.get("c.getAccount");
        actionAccount.setParams({
            recordId: component.get("v.recordId")
        });
        actionAccount.setCallback(this, response => {
            console.log('response account ', response);
            if(response.getState() === "SUCCESS"){
                console.log('account ', response.getReturnValue());
                component.set("v.accountName", response.getReturnValue()["Name"]);
            }
            else {
            }
        });
        $A.enqueueAction(actionAccount);

        var action=component.get("c.getVisuraCamerale");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, response => {
            if(response.getState() === "SUCCESS"){
                console.log('@@@ response ' , response.getReturnValue());
                component.set("v.success", response.getReturnValue().substring(0,2) == 'OK');
                if(response.getReturnValue().substring(0,2) != 'OK'){
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        title: $A.get("$Label.c.WRT_Error"),
                        message: $A.get("$Label.c.WRT_Visura_Error"),
                        type: "error"
                    });
                    toast.fire();
                    console.log('@@@ errore');
    
                    component.set("v.responseStr", $A.get("$Label.c.WRT_Error_Response")+' ' + response.getReturnValue());
                } else {
                var res = response.getReturnValue().slice(3);
                //console.log('@@@ response 2 ' , response.getReturnValue());
                let downloadLink = document.createElement("a");
                downloadLink.href = "data:application/pdf;base64,"+res;
                console.log(component.get("v.simpleRecord"));
                downloadLink.download = component.get("v.accountName")+" - VisuraCamerale.pdf";
                downloadLink.click();
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: $A.get("$Label.c.WRT_Success"),
                    message: $A.get("$Label.c.WRT_Download_Visura_Success_message"),
                    type: "success"
                });
                toast.fire();
                component.set("v.responseStr", $A.get("$Label.c.WRT_Download_Visura_Success_message"));
                }

                $A.get('e.force:refreshView').fire();

            } else {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: $A.get("$Label.c.WRT_Error"),
                    message: $A.get("$Label.c.WRT_Visura_Error"),
                    variant: "error"
                });
                toast.fire();
                console.log('@@@ errore');
                component.set("v.responseStr",  $A.get("$Label.c.WRT_Visura_Error"));
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