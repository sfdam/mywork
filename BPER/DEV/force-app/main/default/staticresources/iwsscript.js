var softphone_connector_initialized = false;
var softphone_listener_initialized = false;

var clickToDialInitialized = false;
var presenceStatusMap = {};
var semaforo = {};
var stato = 0;
var button = {};
var createdCaseId;
var currentMessage = {};
var accountTabId = 'none';
var caseTabId = 'none';
var campaignMemberId;
var attempt;
var intervalSchedule;
var syncConfig;
var fullSyncConfig;
var FIXED_DISPOSITION_CODE = "987b78e4-48cf-42c8-8d8c-ecb65f9f0687";

function isConnectorNotActiveVisible() {
    console.log("isConnectorNotActiveVisible : ", document.hidden);
    return document.hidden;
}
function networkError(message) {
    log.error(message);
}

function onConnectedSession(message) {
    console.log('onConnectedSession ' + JSON.stringify(message));
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateOpenCtiStatus(false);
    sfutil.updateConnectionLed("led-yellow", "Connection in standby ...");
}
function onDisconnectedSession(message) {
    sfutil.updateOpenCtiStatus(false);
    scheduleUtils.unsubscribeLMC();
    softphone_connector_initialized = false;
    sforce.console.presence.login(softphoneSettings.ER_OMNI_NOT_READY_ID, (res) => {
        logsf.info("onDisconnectedSession, set omni not ready result :", res);
    });

}
async function onActivatePureEmbeddableSessionFullPEF(message) {
    logsf.info("onActivatePureEmbeddableSessionFullPEF ", message);

    if (softphone_connector_initialized == true) {
        return;
    }

    sfutil.updateOpenCtiStatus(true);
    scheduleUtils.subscribeLMC();
    await scheduleUtils.loadSchedule(false);
    softphone_connector_initialized = true;

    if (!softphone_listener_initialized) {
        sfutil.enableClickToDial();
        sfutil.addTabFocusListener();
        sfutil.addPresenceListener();
        await sfutil.buildPresenceStatuses();
        await sfutil.getGenesysAgentId();
        //sfutil.focusOpenedTab();
        softphone_listener_initialized = true;
    }
}

async function onChannelStatus(message) {
    logsf.info("onChannelStatus : ", message);
    omniUtils.manageChangeStatusGC(message);
    sfutil.manageCTILabel(message);
}

/*function onEventEstablishedOutbound(message){
    if(message.attachdata.dialercontactid!==undefined){
        sfutil.openCampaignMember(message.attachdata.dialercontactid, message.attachdata.dialercontactlistId);
    }
}*/
function onCallbackEventEstablishedOutbound(message) {
    console.log('onCallbackEventEstablishedOutbound' + JSON.stringify(message));
    /*if(isConnectorNotActiveVisible()){
        console.log("******* RETURNING *******");
        return;
    }*/
    if (message.attachdata.esigenza_sf !== undefined) {
        var data = {};
        currentMessage = message;

        if (message.SourceMsg !== undefined && message.SourceMsg.isCallback) {
            console.log('@@@@isCallback: ' + message.SourceMsg.isCallback);
            console.log('@@@@isCallback: ' + message.SourceMsg);
            semaforo = document.getElementById('redsem1');
            semaforo.style.removeProperty('display');
            data.phone = message.SourceMsg.callbackNumbers[0].replace("tel:", "").replace("+39", "").replace("+", "");
        }
        else {
            data.phone = message.ANI.replace("tel:", "").replace("+39", "").replace("+", "");
        }

        data.autenticated = message.attachdata.crm_customerauthenticationtype;
        data.esigenza = message.attachdata.esigenza_sf;
        data.interactionId = message.InteractionID;
        //change start 26/11/2020
        if (message.attachdata.ndgid !== undefined) {
            data.ndgid = message.attachdata.ndgid;
            data.abi = message.attachdata.abi;
        }
        //change end 26/11/2020
        if (message.attachdata.caseidreal !== undefined) {
            data.caseId = message.attachdata.caseidreal;
            data.transfer = 'transfer';
        }
        console.log('@@@@ datawrapper ' + JSON.stringify(data));
        sfutil.customAction(data);
    }

    if (message.attachdata.id) {
        sfutil.openCampaignMember(message.attachdata.id);
        //sforce.console.openPrimaryTab(null, '/'+message.attachdata.id, true, 
        // name, function(success){}, 'salesforceTab');
        sfutil.updateCampaignQueue(message.attachdata.id ,message.SourceMsg.queueName,message.SourceMsg.id,sfutil.GS_AGENT_ID);
    }

    if (message.attachdata.event_id){
        sfutil.openEvent(message.attachdata.event_id);
    }
}
/*function onEventEstablishedOutbound(message){
    if(message.attachdata.id){
        sfutil.openCampaignMember(message.attachdata.id);
    }
}*/
/*function onCallbackEventRingingOutbound(message){
    if(message.attachdata.dialercontactid!==undefined){
        sfutil.openCampaignMember(message.attachdata.dialercontactid, message.attachdata.dialercontactlistId);
    }
}*/
function onCallbackEventRingingOutbound(message) {
        console.log('onCallbackEventRingingOutbound' + JSON.stringify(message));
         sfutil.manageWidgetVisibility();
    }
function onEventRingingInbound(message) {
    console.log('@@@@message: ' + JSON.stringify(message));
    if (message.attachdata.esigenza_sf !== undefined) {
        if (message.attachdata.crm_customerauthenticationtype === "Cliente anonimo") {
            semaforo = document.getElementById('redsem1');
        }
        else if (message.attachdata.crm_customerauthenticationtype === "Cliente da disambiguare") {
            semaforo = document.getElementById('redsem2');
        }
        else if (message.attachdata.crm_customerauthenticationtype === "Cliente riconosciuto") {
            semaforo = document.getElementById('yellowsem');
        }
        if (message.attachdata.crm_customerauthenticationtype === "Cliente autenticato") {
            semaforo = document.getElementById('greensem');
        }
        semaforo.style.removeProperty('display');
    }

    sfutil.manageWidgetVisibility();
}
function onEventRingingInternal(message) {
}
function onEventRingingConsult(message) {
}
function onEventRingingOutbound(message) {
    console.log('onEventRingingOutbound: ' + JSON.stringify(message));
    sfutil.pickupInteractionCampaign(message);
}

function onEventGenericOutbound(message) {
        console.log('onEventGenericOutbound: ' + JSON.stringify(message));
     //   sfutil.pickupInteractionCampaign(message);
}        

function onEventEstablishedInbound(message) {
    console.log('OnEventInbound' + JSON.stringify(message));
    /*if(isConnectorNotActiveVisible()){
        console.log("******* RETURNING *******");
        return;
    }*/
    if (message.attachdata.esigenza_sf !== undefined) {
        var data = {};
        currentMessage = message;

        if (message.SourceMsg !== undefined && message.SourceMsg.isCallback) {
            console.log('@@@@isCallback: ' + message.SourceMsg.isCallback);
            console.log('@@@@isCallback: ' + message.SourceMsg);
            semaforo = document.getElementById('redsem1');
            semaforo.style.removeProperty('display');
            data.phone = message.SourceMsg.callbackNumbers[0].replace("tel:", "").replace("+39", "").replace("+", "");
        }
        else {
            data.phone = message.ANI.replace("tel:", "").replace("+39", "").replace("+", "");
        }

        data.autenticated = message.attachdata.crm_customerauthenticationtype;
        data.esigenza = message.attachdata.esigenza_sf;
        data.interactionId = message.InteractionID;
        //change start 26/11/2020
        if (message.attachdata.ndgid !== undefined) {
            data.ndgid = message.attachdata.ndgid;
            data.abi = message.attachdata.abi;
        }
        //change end 26/11/2020
        if (message.attachdata.caseidreal !== undefined) {
            data.caseId = message.attachdata.caseidreal;
            data.transfer = 'transfer';
        }
        console.log('@@@@ datawrapper ' + JSON.stringify(data));
        sfutil.customAction(data);
    }

    /*logsf.info("onEventEstablishedInbound , message : ", message);
    sfutil.createTask(message, 'Phone', message.ANI.replace("tel:", ""), message.MediaType + " - " + message.ConnectionID || message.callId);*/
}



function onEventEstablishedOutbound(message) {
    console.log('onEventEstablishedOutbound: ' + JSON.stringify(message));
    logsf.info('onEventEstablishedOutbound: ' + JSON.stringify(message));
        sfutil.manageWidgetVisibility();

    var data = {};
    currentMessage = message;
    semaforo = document.getElementById('redsem1');
    console.log('semaforo: ' + semaforo);
	if (!message.attachdata.event_id) {
		semaforo.style.removeProperty('display');
		console.log('semaforo: ' + semaforo);
	}
    
    logsf.info("message.attachdata.id: ",message.attachdata.id);
    logsf.info("message.queueName: ",message.SourceMsg.queueName);

    if (message.attachdata.id) {
        sfutil.openCampaignMember(message.attachdata.id);
        //sfutil.updateCampaignMemberAgentId(message.attachdata.id ,sfutil.GS_AGENT_ID);
        sfutil.updateCampaignQueue(message.attachdata.id ,message.SourceMsg.queueName,message.SourceMsg.id,sfutil.GS_AGENT_ID);

    }


    if (message.attachdata.esigenza_sf !== undefined) {

        if (message.SourceMsg !== undefined && message.SourceMsg.isCallback) {
            console.log('@@@@isCallback: ' + message.SourceMsg.isCallback);
            console.log('@@@@isCallback: ' + message.SourceMsg);
            semaforo = document.getElementById('redsem1');
            semaforo.style.removeProperty('display');
            data.phone = message.SourceMsg.callbackNumbers[0].replace("tel:", "").replace("+39", "").replace("+", "");
        }
        else {
            data.typeCall = 'outbound';
            data.phone = message.ANI.replace("tel:", "").replace("+39", "").replace("+", "");
        }

        data.autenticated = message.attachdata.crm_customerauthenticationtype;
        data.esigenza = message.attachdata.esigenza_sf;
        data.interactionId = message.InteractionID;
        //change start 26/11/2020
        if (message.attachdata.ndgid !== undefined) {
            data.ndgid = message.attachdata.ndgid;
            data.abi = message.attachdata.abi;
        }
        //change end 26/11/2020
        if (message.attachdata.caseidreal !== undefined) {
            data.caseId = message.attachdata.caseidreal;
            data.transfer = 'transfer';
        }
        console.log('@@@@ datawrapper ' + JSON.stringify(data));
        sfutil.customAction(data);
    }
    else if (!message.attachdata.event_id) {
        data.typeCall = 'outbound';
        data.phone = message.ANI.replace("tel:", "").replace("+39", "").replace("+", "");
        console.log('@@@@ datawrapper ' + JSON.stringify(data));
        sfutil.customAction(data);
    }

}

function onEventReleasedInbound(message) {
    semaforo.style.display = "none";
    createdCaseId = null;
    accountTabId = null;
    caseTabId = null;
    currentMessage = {};
    if (button.disabled !== undefined) {
        button.style.display = "none";
        button.disabled = false;
    }
    button = {};
    stato = 0;
}

function onEventReleasedOutbound(message) {
    campaignMemberId = null;
    attempt = null;
    semaforo.style.display = "none";
    createdCaseId = null;
    accountTabId = null;
    caseTabId = null;
    currentMessage = {};
    if (button.disabled !== undefined) {
        button.style.display = "none";
        button.disabled = false;
    }
    button = {};
    stato = 0;
}

function onEventDialingOutbound(message) {
    console.log('@@@onEventDialingOutbound, message ' + JSON.stringify(message));
    console.log('@@@onEventDialingOutbound, attempt ' + attempt);
    if (message.attachdata.id !== undefined) {
        sfutil.updateCampaignMember(message.attachdata.id, attempt);
    }

}
async function onChatEventRingingInbound(message) {
    sfutil.manageWidgetVisibility();
    console.log('onChatEventRingingInbound: '+JSON.stringify(message));
    sfutil.updateCaseInteraction(message.attachdata["context.livechat_id"], message.SourceMsg.id, message.attachdata["media_type"]);
    sfutil.pickupInteraction(message);
}

async function onChatEventEstablishedInbound(message) {
    logsf.info("onChatEventEstablishedInbound , message : ", message);
        console.log('onChatEventEstablishedInbound: '+JSON.stringify(message));
    if (message.attachdata["context.livechat_id"] || message.attachdata["context.prechat_id"]) {
        try {
            await scheduleUtils.manageAgentStatus(message,true);
            await sfutil.openLiveChat(message, 3);
        } catch (e) {
            console.error("error in onChatEventEstablishedInbound :", e);
        }
    } else {
        let email = message.attachdata["context.email"] || message.attachdata.EmailAddress || message.ANI;
        sfutil.createCaseObject(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
    }
}

function onChatEventReleasedInbound(message) {
    logsf.info("onChatEventReleasedInbound , message : ", message);
    onChatEventReleased(message)    
}
        
function onChatEventReleasedOutbound(message) {
    logsf.info("onChatEventReleasedOutbound , message : ", message);
     onChatEventReleased(message)  
}

  function onChatEventReleased(message) {
    logsf.info("onChatEventReleasedOutbound , message : ", message);
    var workItemId = message.attachdata.work_item_id;
    if (workItemId) {
        sfutil.closeTab(workItemId);
    }
    if (message.attachdata.media_type == "whatsapp") {
        scheduleUtils.clearWzTimeout(message);
    }
/*
    if (message.attachdata.media_type == "whatsapp" || message.attachdata.media_type == "chat") {
        sfutil.markdoneInteraction(message, 5000);
    }
*/
}
        
function onChatEventMarkDoneInbound(message) {
    logsf.info("onChatEventMarkDoneInbound , message : ", message);

    //    timeLogUtil.updateConnectorEventTimeLog(message);
}

function onEmailEventRingingInbound(message) {
   sfutil.manageWidgetVisibility();
   console.log('onEmailEventRingingInbound - parameters: ',message.attachdata.case_id,' - ', message.SourceMsg.id, ' - ',message.attachdata["media_type"]);
   sfutil.updateCaseInteraction(message.attachdata.case_id, message.SourceMsg.id, message.attachdata["media_type"]);
   sfutil.pickupInteraction(message);
}
        
function onEmailEventEstablishedInbound(message) {
    logsf.info("onEmailEventEstablishedInbound , message : ", message);
    if ( message && message.attachdata && message.attachdata.case_id ){
        sfutil.updateCaseOwner(message.attachdata.case_id);    
        sfutil.updateCaseRoutingStatus(message.attachdata.case_id,false); 
        if (Object.keys(iwscore.mapInteractions).length == 1) {
            sfutil.refreshTabAndScreenpop(message.attachdata.case_id);
        } else {
            scheduleUtils.openTab(message.attachdata.case_id);
        }
    }  
    
}
function onEmailEventReleasedInbound(message) {
    logsf.info("onEmailEventReleasedInbound , message : ", message);
    if ( message && message.attachdata && message.attachdata.case_id ){   
        //sfutil.markdoneInteraction(message, 5000);
        sfutil.closeTab(message.attachdata.case_id);
    }  
}

function onEmailEventMarkDoneInbound(message) {
    logsf.info("onEmailEventMarkDoneInbound , message : ", message);
    
}


function onSwitchInteractionPEF(message) {
    log.debug("Called onSwitchInteractionInbound ");
    logsf.info("Called onSwitchInteractionInbound: ", message);
    logsf.info("Called onWdeSwitchInteraction: ", message);
    let id = message.ConnectionID || message.InteractionID;
    if (!id) {
        logsf.info("interaction id null... returning");
        return;
    }
    var event = iwscore.mapInteractions[id.toLowerCase()];
    var pop = true;
    if (event) {
        if (event.EVENT == 'ChatEventEstablished' && event.ConnectedTime) {
            var time = new Date().getTime();
            var conn = new Date(event.ConnectedTime).getTime();
            var diff = (time - conn) / 1000;
            if (diff < 2) {
                pop = false;
            }
        }
    }
    if (pop) {
        sfutil.manageSwitchInteraction(event);
    }
}

function onInteractionChange(message) {
    console.log('@@@inboundLuca' + stato);
    if (stato === 1) {
        if (message.SourceMsg.new.id !== undefined && message.SourceMsg.new.id === currentMessage.InteractionID) {
            if (message.SourceMsg.new.attributes.secureflow !== undefined && message.SourceMsg.new.attributes.secureflow === 'eseguito') {
                console.log('@@@@@@flussosicuro');
                stato = 2;
                semaforo.style.display = 'none';
                console.log('@@@@@@messageflusso: ' + JSON.stringify(message));
                if (!message.SourceMsg.new.attributes.hasOwnProperty('crm_customerauthenticationtype')) {
                    console.log('@@@@@@crm_customerauthenticationtype: VUOTO');
                    semaforo = document.getElementById('redsem1');
                    semaforo.style.removeProperty('display');
                    semaforo.children[0].children[0].style.removeProperty('display');
                    semaforo.children[0].children[0].setAttribute("style", "display: none;");
                    semaforo.children[0].children[0].disabled = false;
                } else {
                    console.log(message.SourceMsg.new.attributes.crm_customerauthenticationtype);
                    if (message.SourceMsg.new.attributes.crm_customerauthenticationtype === "Cliente anonimo") {
                        semaforo = document.getElementById('redsem1');
                        semaforo.style.removeProperty('display');
                        semaforo.children[0].children[0].style.removeProperty('display');
                        semaforo.children[0].children[0].disabled = false;
                    }
                    else if (message.SourceMsg.new.attributes.crm_customerauthenticationtype === "Cliente da disambiguare") {
                        semaforo = document.getElementById('redsem2');
                        semaforo.style.removeProperty('display');
                        semaforo.children[0].children[0].style.removeProperty('display');
                        semaforo.children[0].children[0].disabled = false;
                    }
                    else if (message.SourceMsg.new.attributes.crm_customerauthenticationtype === "Cliente riconosciuto") {
                        semaforo = document.getElementById('yellowsem');
                        semaforo.style.removeProperty('display');
                        semaforo.children[0].children[0].style.removeProperty('display');
                        semaforo.children[0].children[0].disabled = false;
                    }
                    else if (message.SourceMsg.new.attributes.crm_customerauthenticationtype === "Cliente autenticato") {
                        semaforo = document.getElementById('greensem');
                        semaforo.style.removeProperty('display');
                    }
                }

                if (message.SourceMsg.new.attributes.ndgid !== undefined) {
                    sfutil.updateCase(createdCaseId, message.SourceMsg.new.attributes.crm_customerauthenticationtype, message.SourceMsg.new.attributes.ndgid, message.SourceMsg.new.attributes.abi);
                }


            }
        }
    }
}
function sendCaseId(event) {
    console.log('@@@@createdCaseId' + createdCaseId);
    console.log('@@@@@currentMessage ' + JSON.stringify(currentMessage));

    let body = {
        //flowId : "442531ef-fc23-4479-afde-916a06c32544",
        flowId: "ebee9b11-3830-4cff-a9c5-55d940eaa615",
        disconnect: false,
        userData: Boolean(createdCaseId) ? createdCaseId : '123',
        phone: currentMessage.ANI
    };

    console.log('@@@body ', body);
    console.log('@@@@@currentMessage ' + JSON.stringify(currentMessage));

    pClient.conversationApi.getConversationsCall(currentMessage.InteractionID).then(conversation => {
        if (conversation && conversation.participants) {
            var customerId;
            conversation.participants.forEach(element => {
                if (element.purpose === "customer" /*&& currentMessage.SourceMsg.direction!=="Outbound"*/) {
                    customerId = element.id;
                }
                else if (element.purpose === "external" /*&& currentMessage.SourceMsg.direction==="Outbound"*/) {
                    customerId = element.id;
                }
            });
            console.log('@@@customerId: ' + customerId);
            console.log('@@@conversation: ' + JSON.stringify(conversation));
            var params = {};
            params.secureflow = "";
            params.phone = body.phone;
            iwscommand.SetAttachdataById(currentMessage.ConnectionID, params);
            return pClient.conversationApi.postConversationParticipantSecureivrsessions(currentMessage.InteractionID, customerId, { body: body });
        }
    }).then(res => {
        console.log('@@@@@then', res);
        button = event;
        stato = 1;
    });


}