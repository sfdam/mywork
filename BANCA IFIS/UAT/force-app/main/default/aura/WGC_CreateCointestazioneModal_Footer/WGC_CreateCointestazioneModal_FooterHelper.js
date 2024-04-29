({
	
    modalFlowPage : function (component, event, direction) {
        let MAE = $A.get("e.c:ModalFooter2BodyEvent");
        MAE.setParams({ "json" : JSON.stringify({ "action" : direction , "target" : null }) });
        MAE.fire();
    },

})