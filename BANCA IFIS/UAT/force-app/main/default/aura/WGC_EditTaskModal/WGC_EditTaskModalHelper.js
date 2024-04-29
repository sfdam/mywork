({
	getActivity : function(component, event) {
		var recordId = component.get('v.recordId');

		var action = component.get("c.getActivity");
        action.setParams({
            "accountId": recordId
        });
        //Setting the Callback
        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                console.log("SUCCESS");
                var result = response.getReturnValue();
                console.log('NEW OBJ:');
                console.log(result);

                component.set('v.result', result.data[0]);
            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
		
	}
})