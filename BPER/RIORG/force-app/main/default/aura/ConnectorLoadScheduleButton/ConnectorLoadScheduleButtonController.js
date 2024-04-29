({
	loadSchedule : function(component, event, helper) {
        /*var payload = {"command": "reloadSchedule"};
            console.log("calling sampleMessageChannel ,payload : ", payload);
        try{
            component.find("messageChannelScheduleButton").publish(payload);
            console.log("called messageChannelScheduleButton");
        }catch(e){
            console.log("error messageChannelScheduleButton: ", e);
        }*/
        console.log("loadSchedule submitted");
        var action = component.get("c.createMessagesEvent");
        action.setCallback(this, function(response){
            //debugger;
            var state = response.getState();
            console.log("loadSchedule result state : ", response.getState());
        });
	 $A.enqueueAction(action);
    }
})