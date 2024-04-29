({
    doInit: function (cmp, event, helper) {
        try {
			
            /*
            var action = cmp.get("c.isMessageListenerActive");
            action.setCallback(this, function (response) {
                console.log("callback response : ", response);
                var state = response.getState();
                console.log("state : ", response.getState());
                var result = response.getReturnValue();
                console.log("Message timeout enabled : ", result);
                if (!result) {
                    console.log("***Message timeout disabled .. ");
                } else {
                    console.log("***Adding  message event listener ");
                    window.addEventListener("message", $A.getCallback(function (event) {
                        console.log("***Handle message ", event.data);
                        if (!event.data.startsWith("{")) {
                            console.log("***the message is not an object, returning... ");
                            return;
                        }

                        try {
                            var data = JSON.parse(event.data);
                            if (data && data.arguments &&
                                data.arguments.messageType == "Conversational/ConversationMessage" &&
                                data.arguments.data && data.arguments.data.workId) {
                                var payload = { "command": "resetWzTimeout", "work_item_id": data.arguments.data.workId };
                                console.log("calling sampleMessageChannel ,payload : ", payload);
                                try {
                                    cmp.find("sampleMessageChannel").publish(payload);
                                    console.log("called sampleMessageChannel");
                                } catch (e) {
                                    console.log("error sampleMessageChannel: ", e);
                                }
                            }
                        } catch (e) {
                            console.log("error jsom sampleMessageChannel: ", e);
                        }


                    }), false);

                }

            });
            $A.enqueueAction(action);
			*/
            console.log("***doInit adding listener ");
            const channel = '/event/connector_load_schedule_event__e';
            const replayId = -1;
            const empApi = cmp.find('empApi');
            empApi.setDebugFlag(true);
            empApi.onError($A.getCallback(error => {
                // Error can be any type of error (subscribe, unsubscribe...)
                console.error('EMP API error: ', JSON.stringify(error));
            }));
                
            empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
                console.log('Received event ', JSON.stringify(eventReceived));
                if ( eventReceived && eventReceived.data && eventReceived.data.payload && eventReceived.data.payload.schedule__c){
                var schedule = eventReceived.data.payload.schedule__c;
                var payload = { "command": "reloadSchedule","schedule":schedule };
                console.log("calling sampleMessageChannel ,payload : ", payload);
                try {
                    cmp.find("sampleMessageChannel").publish(payload);
                    console.log("called sampleMessageChannel");
                } catch (e) {
                    console.log("error sampleMessageChannel: ", e);
                }
               
            }
                
               
            }))
                .then(subscription => {
                    console.log('Received event ');
                });
                
        } catch (e) {
            console.log("error : ", e)
        }
        
    },
    handleMessage: function (cmp, message, helper) {
        console.log("handle message", message);
        try {
            var utilityAPI = cmp.find("GcContextLiveIxn");
            var command = message.getParam("command");
            console.log("handle message command :", command);

            var id = message.getParam("id");
            console.log("handle message id :", id);

            var modalBody = message.getParam("body");
            var modalTitle = message.getParam("title");

            switch (command) {
                case "openDialog":
                    var refresh = message.getParam("refresh");
                    var modalFooter;
                    $A.createComponents([
                        ["c:ConnectorModalFooter", {}]
                    ],
                        function (components, status, errorMessage) {
                            if (status === "SUCCESS") {
                                modalFooter = components[0];
                                cmp.find('overlayLib').showCustomModal({
                                    header: modalTitle,
                                    body: modalBody,
                                    footer: modalFooter,
                                    showCloseButton: false,
                                    closeCallback: function () {
                                        if (refresh) {
                                            window.location.reload();
                                        }
                                    }
                                })
                            } else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            } else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        });
                    break;

                case "reloadSchedule":
                    break;
            }
        } catch (e) {
            console.log("error : ", e)
        }
    },


})