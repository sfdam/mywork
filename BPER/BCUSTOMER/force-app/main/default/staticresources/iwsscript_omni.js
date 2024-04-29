var softphone_connector_initialized = false;
var softphone_listener_initialized = false;
function onConnectedSession(message) {
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateOpenCtiStatus(false);
    sfutil.updateConnectionLed("led-yellow", "Connection in standby ...");
}
async function onDisconnectedSession(message) {
    omniUtils.manageOmniLogOff();
    $("#led").removeClass();
    $("#led").addClass("led-red");
    $(".led-msg p").text("Session disconnected");
    sfutil.updateOpenCtiStatus(false);
    softphone_connector_initialized = false;
}
async function onActivateSession(message) {
    console.log("onActivateSession ", message);
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateConnectionLed("led-green", "Connection estabilished");
    sfutil.updateOpenCtiStatus(true);
    softphone_connector_initialized = true;
    if (!softphone_listener_initialized) {
        sfutil.enableClickToDial();
        sfutil.addTabFocusListener();
        omniUtils.addPresenceListener();
        softphone_listener_initialized = true;
    }
}
async function onActivatePureEmbeddableSessionFullPEF(message) {
    console.log("onActivatePureEmbeddableSessionFullPEF ", message);
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateOpenCtiStatus(true);
    softphone_connector_initialized = true;
    if (!softphone_listener_initialized) {
        sfutil.enableClickToDial();
        sfutil.addTabFocusListener();
        sfutil.listenCallLogsMessages();
        omniUtils.addPresenceListener();
        softphone_listener_initialized = true;
    }
}
function onChannelStatus(message) {
    console.log("onChannelStatus : ", message);
    switch (softphoneSettings.GEN_INTEGRATION_TYPE) {
        case 'PURECLOUD':
            omniUtils.manageChangeStatusGC(message);
            break;
        case 'WDE':
            omniUtils.manageGetWdeStatus(message);
            break;
    }
}
function onEventAgentReady(message) {
    console.log("onEventAgentReady ", message);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(true);
    }
    var event = { Command: "MediaVoiceReady", Parameters: { Reasons: {} } };
    omniUtils.manageChannelStatusChange(event);
}
function onEventAgentNotReady(message) {
    console.log("onEventAgentReady ", message);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(true);
    }
    var reason = message.attachdata && message.attachdata.ActionCode
        ? message.attachdata.ActionCode
        : "";
    var event = {
        Command: "MediaVoiceNotReady",
        Parameters: { Reasons: { [reason]: reason } }
    };
    omniUtils.manageChannelStatusChange(event);
}
//==================================================================
// VOICE INBOUND
//==================================================================
function onEventRingingInbound(message) {
    sfutil.manageWidgetVisibility();
    timeLogUtil.createConnectorEventTimeLog(message);
}
function onPreEventEstablishedInbound(message) {
    console.log("onPreEventEstablishedInbound , message : ", message);
    iwscore.addJSONObjectInMemory(message, undefined);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(false);
    }
}
function onEventEstablishedInbound(message) {
    logsf.info("onEventEstablishedInbound , message : ", message);
    sfutil.createTask(message, 'Phone', message.ANI.replace("tel:", ""), message.MediaType + " - " + message.ConnectionID || message.callId);
}
function onEventReleasedInbound(message) {
    logsf.info("onEventReleasedInbound , message : ", message);
    timeLogUtil.updateConnectorEventTimeLog(message);
}
function onEventMarkDoneInbound(message) {
    logsf.info("onEventMarkDoneInbound , message : ", message);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(true);
    }
    timeLogUtil.updateConnectorEventTimeLog(message);
}
//==================================================================
// VOICE OUTBOUND
//==================================================================
function onEventDialingOutbound(message) {
    logsf.info("onEventDialingOutbound , message : ", message);
    sfutil.manageWidgetVisibility();
    timeLogUtil.createConnectorEventTimeLog(message);
}
function onEventEstablishedOutbound(message) {
    logsf.info("onEventReleasedOutbound , message : ", message);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(false);
    }
    timeLogUtil.updateConnectorEventTimeLog(message);
}
function onEventReleasedOutbound(message) {
    logsf.info("onEventReleasedOutbound , message : ", message);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(true);
    }
    timeLogUtil.updateConnectorEventTimeLog(message);
}
//==================================================================
// CHAT
//==================================================================
function onChatEventRingingInbound(message) {
    sfutil.manageWidgetVisibility();
    timeLogUtil.createConnectorEventTimeLog(message);
}
function onChatEventEstablishedInbound(message) {
    logsf.info("onChatEventEstablishedInbound , message : ", message);
    if (message.attachdata["context.prechat_id"]) {
        omniUtils.openLiveChat(message, 3);
    }
    else {
        let email = message.attachdata["context.email"] || message.attachdata.EmailAddress || message.ANI;
        sfutil.createCaseObject(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
    }
}
function onChatEventReleasedInbound(message) {
    logsf.info("onChatEventReleasedInbound , message : ", message);
    timeLogUtil.updateConnectorEventTimeLog(message);
}
function onChatEventMarkDoneInbound(message) {
    logsf.info("onChatEventMarkDoneInbound , message : ", message);
    var workItemId = message.attachdata.work_item_id;
    if (workItemId) {
        omniUtils.closeTab(workItemId, undefined);
    }
    timeLogUtil.updateConnectorEventTimeLog(message);
}
function onEmailEventRingingInbound(message) { }
function onEmailEventEstablishedInbound(message) {
    console.log("onEmailEventEstablishedInbound , message : ", message);
    let email = message.attachdata["context.email"] || message.attachdata.EmailAddress || message.ANI;
    sfutil.createTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onEmailEventReleasedInbound(message) {
}
function onWorkitemEventEstablishedInbound(message) {
    logsf.debug("Called onWorkitemEventEstablishedInbound: ");
    console.log(message);
    omniUtils.createAgentWork(message);
}
function onWorkitemEventMarkDoneInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventReleasedInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventRingingInbound(message) {
    logsf.debug("Called onWorkitemEventRingingInbound: ");
    sfutil.manageWidgetVisibility();
}
function onSmsEventRingingInbound(message) {
    logsf.info("onSmsEventRingingInbound , message : ", message);
    sfutil.manageWidgetVisibility();
}
function onSmsEventEstablishedInbound(message) {
    logsf.info("onSmsEventEstablishedInbound : ", message);
    var ani = message.ANI || message.remoteName;
    sfutil.createTask(message, 'Phone', ani.replace("tel:", ""), message.MediaType + " - " + message.ConnectionID || message.callId);
}
function onSmsEventReleasedInbound(message) {
    logsf.info("onSmsEventReleasedInbound : ", message);
}
function onSmsEventMarkDoneInbound(message) {
    logsf.info("onSmsEventMarkDoneInbound : ", message);
}
function onWhatsappEventRingingInbound(message) {
    logsf.info("onWhatsappEventRingingInbound : ", message);
    sfutil.manageWidgetVisibility();
}
function onWhatsappEventEstablishedInbound(message) {
    logsf.info("onWhatsappEventEstablishedInbound : ", message);
    sfutil.createTask(message, 'Phone', message.ANI.replace("tel:", ""), message.MediaType + " - " + message.ConnectionID || message.callId);
}
function onWhatsappEventReleasedInbound(message) {
    logsf.info("onWhatsappEventReleasedInbound : ", message);
}
function onWhatsappEventMarkDoneInbound(message) {
    logsf.info("onWhatsappEventMarkDoneInbound : ", message);
}
function onFacebookEventRingingInbound(message) {
    logsf.info("onFacebookEventRingingInbound : ", message);
    sfutil.manageWidgetVisibility();
}
function onFacebookEventEstablishedInbound(message) {
    logsf.info("onFacebookEventEstablishedInbound : ", message);
    let email = message.Service == "PureCloud" ? message.attachdata.sender_address_info : message.attachdata.EmailAddress;
    sfutil.createTask(message, 'Email', email || "noid", message.MediaType + " - " + message.ConnectionID);
}
function onFacebookEventReleasedInbound(message) {
    logsf.info("onFacebookEventReleasedInbound : ", message);
}
function onFacebookEventMarkDoneInbound(message) {
    logsf.info("onFacebookEventMarkDoneInbound : ", message);
}
function onWebmessagingEventRingingInbound(message) {
    logsf.info("onWebmessagingEventRinging : ", message);
    sfutil.manageWidgetVisibility();
}
function onWebmessagingEventEstablishedInbound(message) {
    logsf.info("onWebmessagingEventEstablished : ", message);
    let email = message.Service == "PureCloud" ? message.EmailAddress : message.attachdata.EmailAddress;
    sfutil.createTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onWebmessagingEventReleasedInbound(message) {
    logsf.info("onWebmessagingEventReleased : ", message);
}
function onWebmessagingEventMarkDoneInbound(message) {
    logsf.info("onWebmessagingEventMarkDoneInbound : ", message);
}
function onCallbackEventRingingOutbound(message) {
    logsf.info("onCallbackEventRingingOutbound : ", message);
    sfutil.manageWidgetVisibility();
}
function onCallbackEventEstablishedOutbound(message) {
    logsf.info("onCallbackEventRingingOutbound : ", message);
    let ani = message.SourceMsg.callbackNumbers;
    sfutil.searchContactAndScreenpop("Phone", ani[0]);
}
async function onDelegateCommand(message) {
    console.log("onDelegateCommand : ", message);
    omniUtils.manageDelegate(message);
}
function onRegisterCommand(message) {
    console.log("onRegisterCommand : ", message);
    if (!message || !message.ChainName) {
        console.log("invalid message, returning ...");
        return;
    }
    switch (message.ChainName) {
        case "AgentLogout":
            sforce.console.presence.logout(function (res) {
                console.log(res);
            });
            break;
    }
}
function onInhibitCommand(message) {
    logsf.debug("======= onInhibitCommand ==========");
    if (message.Parameters.Device) {
        logsf.debugFormat("Device Name: {0}", message.Parameters.Device.Name);
    }
}
function onWdeSwitchInteraction(message) {
    logsf.info("Called onWdeSwitchInteraction: ", message);
    sfutil.manageSwitchInteraction(message);
}
function onSwitchInteractionPEF(message) {
    logsf.info("Called onSwitchInteractionPEF: ", message);
    sfutil.manageSwitchInteraction(message);
}
function onMediaVoiceNotReady(message) {
    console.log("onMediaVoiceNotReady :", message);
}
function onMediaVoiceReady(message) {
    console.log("onMediaVoiceReady :", message);
}
function onMediaOpenMediaReady(message) {
    console.log("onMediaOpenMediaReady :", message);
    omniUtils.manageChannelStatusChange(message);
}
function onMediaOpenMediaNotReady(message) {
    console.log("onMediaOpenMediaNotReady :", message);
    omniUtils.manageChannelStatusChange(message);
}
function onMediaVoiceLogOff(message) {
    console.log("onMediaVoiceLogOff :", message);
    omniUtils.manageChannelStatusChange(message);
}
function onMediaVoiceLogOn(message) {
    console.log("onMediaVoiceLogOn :", message);
    omniUtils.manageChannelStatusChange(message);
}
function onMediaOpenMediaLogOff(message) {
    console.log("onMediaOpenMediaLogOff :", message);
    omniUtils.manageChannelStatusChange(message);
}
function onMediaOpenMediaLogOn(message) {
    console.log("onMediaOpenMediaLogOn :", message);
    omniUtils.manageChannelStatusChange(message);
}
function onPreEventEstablishedConsult(message) {
    console.log("onPreEventEstablishedConsult , message : ", message);
    iwscore.addJSONObjectInMemory(message, undefined);
    if (softphoneSettings.GEN_EXTERNAL_ROUTING) {
        omniUtils.manageVoiceBusy(false);
    }
}
