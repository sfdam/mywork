function onPreChannelStatus(message) {
    iwscore.setIwsInitData(message);
}
function onPreConnectedSession(message) {
    if (message.IwsApplicationName) {
        iwscore.setIwsApplicationName(message.IwsApplicationName);
    }
    iwscore.setIwsInitData(message);
    iwscore.showConnectedState();
}
function onPreDisconnectedSession(message) {
    iwscore.showDisconnectedState();
}
function onPostDisconnectedSession(message) {
}

function onPreActivatePureEmbeddableSession(message) {
    var _params = iwscore.getLayoutParams();
    if (_params.integrationType === "pure-embeddable" && message.token) {
        iwscore.initPureCloud(message.token);
    }
}
function onPreActivatePureEmbeddableSessionFullPEF(message) {
    if (message.token) {
        console.log('@@@@@@@@sonoqui');
        
        localStorage.setItem("pureCloudToken", message.token);
        pClient = new PureClientSdk();
        pClient.client.setEnvironment(softphoneSettings.PEF_GC_ENVIRONMENT);
        pClient.client.setAccessToken(message.token)
    }
}
function onPreRequestConfigurationPureEmbeddable(message) {
    var _params = iwscore.getLayoutParams();
    if (_params.integrationType === "pure-embeddable") {
        iwscore.sendPureEmbeddableConfiguration();
    }
}
function onPreActivateSession(message) {
    var _params = iwscore.getLayoutParams();
    if (_params.integrationType === "pure-embeddable" && message.token) {
        iwscore.initPureCloud(message.token);
        return;
    }
    iwscore.showActivedState();
    if (message.interactions) {
        var i;
        log.debugFormat("[onPreActivateSession] received [{0}] interaction", message.interactions.length);
        if (iwscore.isEnablePlaceHolder())
            iwscore.addEmptyOption();
        for (i = 0; i < message.interactions.length; i++) {
            if ((message.interactions[i].State == 8)
                ||
                    (message.interactions[i].State == 1)
                ||
                    (message.interactions[i].State == 2))
                continue;
            log.debug("[onPreActivateSession] Check if the interaction is a Campaign");
            if (iwscore.isCampaign(message.interactions[i])) {
                log.debug("[onPreActivateSession] The interaction is a Campaign");
                if (iwscore.isEnablePlaceHolder())
                    iwscore.addJSONObjectInMemoryCampaign(message.interactions[i], iwscore.isEnablePlaceHolderInteraction(message.interactions[i]));
                else
                    iwscore.addJSONObjectInMemoryCampaign(message.interactions[i], false);
            }
            else {
                log.debug("[onPreActivateSession] The interaction not is a Campaign");
                if (iwscore.isEnablePlaceHolder())
                    iwscore.addJSONObjectInMemory(message.interactions[i], iwscore.isEnablePlaceHolderInteraction(message.interactions[i]));
                else
                    iwscore.addJSONObjectInMemory(message.interactions[i], false);
            }
        }
        if (iwscore.isEnablePlaceHolder())
            iwscore.removeEmptyOption();
        if (iwscore.countInteractions() > 0) {
            iwscore.removeDefaultOption();
        }
    }
}
function onPreDeactivateSession(message) {
    iwscore.showConnectedState();
}
function getIdFromDelegateCommand(message) {
    var id = "";
    try {
        var sapp = message.Parameters.CommandParameter;
        var n = sapp.indexOf("/");
        id = sapp.substring(n + 1).slice(0, -1);
    }
    catch (e) {
        log.warn("getIdFromDelegateCommand: " + e.message);
    }
    log.debugFormat("[getIdFromDelegateCommand] id[{0}]", id);
    return id;
}
function onPreDelegateCommand(message) {
    try {
        var id = iwscore.getMessageId(message);
        if (id) {
            log.debugFormat("[onPreDelegateCommand] with ConnectionID [{0}]", id);
        }
        else {
            id = getIdFromDelegateCommand(message);
            if (id) {
                log.debugFormat("[onPreDelegateCommand] with ConnectionID [{0}]", id);
                message.ConnectionID = id;
                message.InteractionID = id;
            }
        }
    }
    catch (e) {
        log.warn("[onPreDelegateCommand]: " + e.message);
    }
}
function onPreEventAgentReady(message) {
}
function onPreEventEstablishedInternal(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventEstablishedConsult(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventReleasedInbound(message) {
}
function onPostEventReleasedConsult(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEventReleasedInternal(message) {
}
function onPreEventPartyChangedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.PreviousConnID);
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventPartyChangedInternal(message) {
    iwscore.removeJSONObjectInMemory(message.PreviousConnID);
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventPartyChangedOutbound(message) {
    iwscore.removeJSONObjectInMemory(message.PreviousConnID);
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventEstablishedOutbound(message) {
    if (iwscore.isCampaign(message)) {
        iwscore.addJSONObjectInMemoryCampaign(message, undefined);
        if (iwscore.isEnablePlaceHolder() && iwscore.isSelectedInteraction(message)) {
            iwscommand.SetInteractionOnWde(message.ConnectionID);
        }
    }
    else
        iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEventReleasedOutbound(message) {
}
function onPreEventMarkDoneInbound(message) {
    log.debugFormat("onPreEventMarkDoneInbound State [{0}] Name[{1}]", message.State, message.Name);
    if (message.Name != "EventReleased")
        return false;
}
function onPostEventMarkDoneInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEventMarkDoneInternal(message) {
}
function onPostEventMarkDoneInternal(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEventMarkDoneConsult(message) {
}
function onPostEventMarkDoneConsult(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEventMarkDoneOutbound(message) {
}
function onPostEventMarkDoneOutbound(message) {
    if (!iwscore.isCampaign(message)) {
        iwscore.removeJSONObjectInMemory(message.ConnectionID);
    }
    else {
        var recordhandle = "" + iwscore.getRecordHandle(message);
        iwscore.removeJSONObjectInMemory(recordhandle);
    }
}
function onPreChatEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreChatEventReleasedInbound(message) {
}
function onPostChatEventMarkDoneInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreOpenEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreOpenEventReleasedInbound(message) {
}
function onPostOpenEventMarkDoneInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreWorkitemEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreWorkitemEventOpenedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreWorkitemEventReleasedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPostWorkitemEventRevokedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEmailEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPostEmailEventReleasedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEmailEventEstablishedOutbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPostEmailEventReleasedOutbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEmailEventOpenedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEmailEventReplyEstablishedOutbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEmailEventReplyEstablished(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEmailEventReplyReleasedOutbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEmailEventReplyReleased(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEmailEventReplyCancelled(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEmailEventReplyOpened(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreEmailEventReplyOpenedOutbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreWorkbinPlacedIn(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreWorkbinTakenOut(message) {
}
function onPreSMSEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreSMSEventReleasedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreSMSEventEstablishedOutbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPreSMSEventReleasedOutbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreEventUserEvent(message) {
    try {
        var eventname = message.attachdata.GSW_USER_EVENT;
        log.debugFormat("onPreEventUserEvent: the event is {0}", eventname);
        iwscore.callSafetyFunction("onPre" + eventname + "(message);", message);
        if (iwscore.checkFunction("on" + eventname)) {
            iwscore.callSafetyFunction("on" + eventname + "(message);", message);
        }
    }
    catch (e) {
        log.error("onPreEventUserEvent: " + e.message);
    }
    return true;
}
function onPostEventUserEvent(message) {
    try {
        var eventname = message.attachdata.GSW_USER_EVENT;
        log.debugFormat("onPostEventUserEvent: the event is {0}", eventname);
        iwscore.callSafetyFunction("onPost" + eventname + "(message);", message);
    }
    catch (e) {
        log.error("onPostEventUserEvent: " + e.message);
    }
    return true;
}
function onPrePreviewRecord(message) {
    log.debug("======= onPrePreviewRecord ==========");
    iwscore.addJSONObjectInMemoryCampaign(message, undefined);
}
function onPreRecordProcessedAcknowledge(message) {
    log.debug("======= onPreRecordProcessedAcknowledge ==========");
}
function onPostRecordProcessedAcknowledge(message) {
    log.debug("======= onPostRecordProcessedAcknowledge ==========");
    var recordhandle = "" + iwscore.getRecordHandle(message);
    iwscore.removeJSONObjectInMemory(recordhandle);
}
function onPreRecordRejectAcknowledge(message) {
    log.debug("======= onPreRecordRejectAcknowledge ==========");
    var recordhandle = "" + iwscore.getRecordHandle(message);
    iwscore.removeJSONObjectInMemory(recordhandle);
}
function onPreRecordCancelAcknowledge(message) {
    log.debug("======= onPreRecordCancelAcknowledge ==========");
    var recordhandle = "" + iwscore.getRecordHandle(message);
    iwscore.removeJSONObjectInMemory(recordhandle);
}
function onPreScheduledCall(message) {
    log.debug("======= onPreScheduledCall ==========");
    iwscore.addJSONObjectInMemoryCampaign(message, undefined);
}
function onPreChainedRecordsDataEnd(message) {
    log.debug("======= onPreChainedRecordsDataEnd ==========");
    iwscore.addJSONObjectInMemoryCampaign(message, undefined);
}
function onPreOutboundpreviewEventEstablished(message) {
    log.debug("======= onPreOutboundpreviewEventEstablished ==========");
    iwscore.addJSONObjectInMemoryCampaign(message, undefined);
}
function onPreOutboundpreviewEventEstablishedInternal(message) {
    log.debug("======= onPreOutboundpreviewEventEstablishedInternal ==========");
    iwscore.addJSONObjectInMemoryCampaign(message, undefined);
}
function onPostOutboundpreviewEventReleasedInternal(message) {
    onPostOutboundpreviewEventReleased(message);
}
function onPostOutboundpreviewEventReleased(message) {
    log.debug("======= onPostOutboundpreviewEventReleased ==========");
    var recordhandle = "" + iwscore.getRecordHandle(message);
    iwscore.removeJSONObjectInMemory(recordhandle);
}
function onPreTwitterEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPostTwitterEventReleasedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreTwitterEventReplyOutbound(message) {
    try {
        var msgType = message.attachdata._twitterMsgType;
        log.debug("onPreTwitterEventReplyOutbound with " + msgType);
        if ((msgType === "Retweet") || (msgType === "DirectMessage")) {
            log.debug("onPreTwitterEventReplyOutbound with " + msgType);
            var myevent = "TwitterEvent{0}Outbound".format(msgType);
            log.debugFormat("onPreTwitterEventReply: the new event is on{0}", myevent);
            iwscore.callSafetyFunction("onPre" + myevent + "(message);", message);
            if (iwscore.checkFunction("on" + myevent)) {
                iwscore.callSafetyFunction("on" + myevent + "(message);", message);
            }
            return false;
        }
    }
    catch (e) {
        log.error("onPreTwitterEventReply: " + e.message);
    }
    return true;
}
function onPreFacebookEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPostFacebookEventReleasedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
function onPreWdeSwitchInteraction(message) {
    var mymessage = iwscore.getInteraction(message.InteractionID);
    if (mymessage) {
        var curr_message = iwscore.getSelectedInteraction();
        if (curr_message) {
            log.infoFormat("[onPreWdeSwitchInteraction] Selected Interaction [{0}] Switch Interaction[{1}] ======================", curr_message.InteractionID, mymessage.InteractionID);
            if (curr_message.InteractionID != mymessage.InteractionID) {
                iwscore.selectInteractionOptionByMessage(mymessage);
            }
        }
    }
}
function onPreWebformEventEstablishedInbound(message) {
    iwscore.addJSONObjectInMemory(message, undefined);
}
function onPostWebformEventReleasedInbound(message) {
    iwscore.removeJSONObjectInMemory(message.ConnectionID);
}
