({
	doInit : function(component, event, helper) {
        helper.setCookie("bper","123");
        var notifiLib = component.find("notifLib");
        var action = component.get("c.getCanvas");
        var canvasParameters = {};
        var devName = component.get("v.devName");
        var sObjectId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");
        action.setParams({ 
            devName : devName,
            sObjectId : sObjectId,
            sObjectName : sObjectName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state==="SUCCESS") {
                var retValue = response.getReturnValue();
                var showCanvas = retValue.showCanvas;
                component.set("v.connectedApp",retValue.result.connected_app__c);
                canvasParameters.urlCanvas = retValue.result.url_path__c;
                if (retValue.url_parameters!=undefined && showCanvas) {
                    for (var key in retValue.url_parameters) {
                        if (!canvasParameters.urlCanvas.endsWith('?')) {
                            canvasParameters.urlCanvas += "&";
                        }
                        canvasParameters.urlCanvas += key;
                        canvasParameters.urlCanvas += '=';
                        canvasParameters.urlCanvas += retValue.url_parameters[key];
                    }
                }
                console.log('devName ',devName);
                if(devName == 'Phone_Banking_NPM_v2' || devName == 'Phone_Banking_NPM'){
                    console.log('sono in IF ');
                    var newCanvasPath = canvasParameters.urlCanvas.replace("&NDGCC=","").replace("&ABICC=","/");
                    console.log('newCanvasPath ',newCanvasPath);
                    canvasParameters.urlCanvas = newCanvasPath
                    console.log('modifica ',canvasParameters.urlCanvas);
                }
                component.set("v.canvasParameters",JSON.stringify(canvasParameters));
                component.set("v.showCanvas",showCanvas);
                component.set("v.isLoaded",true);
                console.log('canvasParameters.urlCanvas: ',canvasParameters.urlCanvas);
                console.log('JSON.stringifycanvasParameters: ',JSON.stringify(canvasParameters));
            }
            if (state==="ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        notifiLib.showToast({
                        	title:"Errore!",
                        	message:errors[0].message,
                        	variant:"error"
                    	});
                    }
                } else {
                    notifiLib.showToast({
                        title:"Errore!",
                        message:"unknown error",
                        variant:"error"
                    });
                }
            }
        });
        $A.enqueueAction(action);
	},
    onCanvasAppError: function(component,event,helper) {
	},
    onCanvasAppLoad:function(component,event,helper) {
    }
})