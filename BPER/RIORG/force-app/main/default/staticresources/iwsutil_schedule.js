const LMC_CONNECTOR = 'softphone_it__LMC_Connector__c';
var _evtSubscription;
class IwsSchedule {

    mapWhatsappInteractions = {};

    subscribeLMC() {
        sforce.opencti.subscribe({
            channelName: LMC_CONNECTOR,
            listener: (m) => this.listenerSubscribe(m),
            callback: function (result) {
                if (!result.success) {
                    logsf.info("dbg", "Failed to subscribe to event channel", LMC_CONNECTOR, result.errors);
                } else {
                    _evtSubscription = result.subscription;
                }
            }
        });
    }

    unsubscribeLMC() {
        if (_evtSubscription) {
            sforce.opencti.unsubscribe({ subscription: _evtSubscription, callback: (res) => logsf.info("unsubscribe result :", res) });
            _evtSubscription = null;
        }
    }
    listenerSubscribe(msg) {
        logsf.info("listenerSubscribe, received event : ", msg);
        switch (msg.command) {
            case "reloadSchedule":
                logsf.info("listenerSubscribe, reloadSchedule received, reloading ...");
                this.buildScheduleSettings(JSON.parse(msg.schedule), true,false);
                break;
            case "resetWzTimeout":
                logsf.info("TIMEOUT resetWzTimeout received, resetting timeout ...");
                var interaction = this.findInteractionByWorkId(msg.work_item_id);
                this.clearWzTimeout(interaction);
                this.manageWhatsappTimeout(interaction);
                break;
            case "refreshTab":
                if (!msg.id) {
                    logsf.info("REFRESHING error, the id is null");
                    return;
                }
                logsf.info("listenerSubscribe,REFRESHING tab : ", msg.id);
                sfutil.refreshTabAndScreenpop(msg.id, false)
                break;
            /*case "closeCaseTab":
                if(msg.interactionId){
                    iwscommand.updateStatePEF(msg.interactionId,'disconnect'); 
                }
                logsf.info("listenerSubscribe,CLOSING Interaction : ", msg.interactionId);
                break;*/
        }

    }

    clearWzTimeout(interaction) {
        logsf.info("TIMEOUT clearing for interaction :", interaction);
        if (interaction) {
            logsf.info("TIMEOUT interaction found :", interaction);
            var interval = this.mapWhatsappInteractions[interaction.InteractionID];
            logsf.info("TIMEOUT cleared for interactionId :", interaction.InteractionID);
            clearInterval(interval);
            delete this.mapWhatsappInteractions[interaction.InteractionID];
        }
    }

    findInteractionByWorkId(work_item_id) {
        for (var i in iwscore.mapInteractions) {
            if (iwscore.mapInteractions[i] && iwscore.mapInteractions[i].attachdata && iwscore.mapInteractions[i].attachdata.work_item_id) {
                if (iwscore.mapInteractions[i].attachdata.work_item_id.indexOf(work_item_id) >= 0) {
                    return iwscore.mapInteractions[i];
                }
            }
        }
    }

    async loadSchedule(showDialog,silent) {
        logsf.info("loadSchedule,start showdialog: "+ showDialog+ ",silent: "+silent );
        try {
            var queuesIds = await this.buildQueuesId();
            logsf.info("loadSchedule,queuesIds: ", queuesIds);
            if (!queuesIds || queuesIds.length == 0) {
                logsf.info("loadSchedule, cannot retrieve the Genesys queues of the agent, returning");
                return;
            }
            var result = await omniUtils.callApiSync(ConnectorScheduleBuilder.buildScheduleSettings, queuesIds);
            await this.buildScheduleSettings(result, showDialog,silent);
            //syncConfig = await omniUtils.callApiSync(ConnectorScheduleBuilder.checkQueues, queuesIds);
            //logsf.info("loadSchedule,syncConfig: ", syncConfig);
            //this.manageSchedule(showDialog);
        } catch (e) {
            console.error("loadSchedule,error loading schedule : ", e);
        }
    }

    async buildQueuesId() {
        var queues = await pClient.routingApi.getRoutingQueuesMe();
        if (!queues || !queues.entities) {
            this.showDialog("Attenzione", "Non e' stato possibile recuperare le code Genesys di appartenenza.Si prega di refreshare il browser");
            return;

        }
        var ids = [];
        queues.entities.forEach(q => {
            if (q.joined) {
                ids.push(q.id);
            }
        });
        return ids;
    }

    buildFullSyncSettings(settings) {
        logsf.info("loadSchedule.buildFullSyncSettings,start ");
        fullSyncConfig = {};
        for (var q in settings) {
            var channel = JSON.parse(JSON.stringify(settings[q]));
            delete channel.attributes;
            // logsf.info(`buildFullSyncSettings, cycling key=${q}, channel=`,channel);
            fullSyncConfig = Object.assign(channel, fullSyncConfig);
        }
        logsf.info("loadSchedule.buildFullSyncSettings,fullSyncConfig: ", fullSyncConfig);
    }
    async buildScheduleSettings(settings, showDialog,silent) {
        logsf.info("loadSchedule.buildScheduleSettings,start  silent :" + silent + ",settings: ", settings);
        syncConfig = {};
            
        try {
            if (Object.keys(settings).length === 0) {
                this.showDialog("Attenzione", "Non e' stato possibile recuperare gli orari di apertura. Si prega di refreshare il browser.");
                return;
            }
            this.buildFullSyncSettings(settings);
        
            var queuesIds = await this.buildQueuesId();
            logsf.info("loadSchedule.buildScheduleSettings, queues :", queuesIds);
            if (!queuesIds || queuesIds.length == 0) {
                logsf.info("loadSchedule.buildScheduleSettings, cannot retrieve the Genesys queues of the agent, returning");
                return;
            }
            for (var i = 0; i < queuesIds.length; i++) {
                var q = queuesIds[i];
                var channel = settings[q];
                if (channel) {
                    syncConfig = Object.assign(channel, syncConfig);
                }
            }

            logsf.info("loadSchedule.buildScheduleSettings, appSettings :", syncConfig);
            if (syncConfig && syncConfig.chatSchedule) {
                if (syncConfig.chatSchedule.start) {
                    syncConfig.chatSchedule.start = new Date(syncConfig.chatSchedule.start).getTime();
                }
                if (syncConfig.chatSchedule.end) {
                    syncConfig.chatSchedule.end = new Date(syncConfig.chatSchedule.end).getTime();
                }
            }
            this.manageSchedule(showDialog,silent);
        } catch (e) {
            console.error("loadSchedule.buildScheduleSettings error :", e);
            this.showDialog("Attenzione", "Non e' stato possibile recuperare gli orari di apertura. Si prega di refreshare il browser.");
            return;
        }


    }

    manageSchedule(showDialog,silent) {
        logsf.info("loadSchedule.manageSchedule start ,silent :" + silent +", syncConfig :", syncConfig);

        if (!syncConfig) {
            logsf.info("loadSchedule.manageSchedule, error syncConfig is null, returning ");
            this.showDialog("Attenzione", "Non � stato possibile recuperare gli orari di apertura. Si prega di refreshare il browser.");
            return;
        }
        if ( !silent ){
            logsf.info("loadSchedule.manageSchedule, setting genesys and omni not ready");
            sforce.console.presence.login(softphoneSettings.ER_OMNI_NOT_READY_ID, function (res) { logsf.info("manageSchedule, set not ready result :", res); });
            iwscommand.NotReadyAll();    
        }
        
        softphoneSettings.ER_SYNC_WDE_TO_OMNI = (fullSyncConfig.whatsapp != null || fullSyncConfig.chat != null);
        if (syncConfig.chatSchedule && syncConfig.chatSchedule.open) {
            logsf.info("loadSchedule.manageSchedule, setting ER_OMNI_READY_ID to chat");
            softphoneSettings.ER_OMNI_READY_ID = syncConfig.chat.S_OMNI_ID__c;
        } else if (syncConfig.whatsapp) {
            logsf.info("loadSchedule.manageSchedule, setting ER_OMNI_READY_ID to whatsapp");
            softphoneSettings.ER_OMNI_READY_ID = syncConfig.whatsapp.S_OMNI_ID__c;
        } else {
            logsf.info("loadSchedule.manageSchedule, setting ER_OMNI_READY_ID to notready");
            softphoneSettings.ER_OMNI_READY_ID = softphoneSettings.ER_OMNI_NOT_READY_ID;
        }
        logsf.info("loadSchedule.manageSchedule, ER_SYNC_WDE_TO_OMNI=" + softphoneSettings.ER_SYNC_WDE_TO_OMNI + ",ER_OMNI_READY_ID=" + softphoneSettings.ER_OMNI_READY_ID);

        if (syncConfig.chatSchedule) {
            this.manageScheduleTimeout();
        }
        if (showDialog) {
            this.showDialog("Attenzione", "Sei stato reso automaticamente non disponibile su Genesys. Riporta il tuo stato a quello precedente.");
        }
    }

    async manageAgentStatus(message){
        var currentStatus = await omniUtils.callApiSync(sforce.console.presence.getServicePresenceStatusId);        
        logsf.info("onChatEventRingingInbound.manageAgentStatus , current omni status : ", currentStatus);
        var currentStatusId = currentStatus.statusId || softphoneSettings.ER_OMNI_NOT_READY_ID;
        var changeStatus = false;
        var omniReadyId;
        try{
            if ( message.attachdata.media_type == "chat" && fullSyncConfig.chat.S_OMNI_ID__c ){
                omniReadyId = fullSyncConfig.chat.S_OMNI_ID__c;
                if ( currentStatusId != omniReadyId ){
                    changeStatus = true;             
                }

            }else if( message.attachdata.media_type == "whatsapp" && fullSyncConfig.whatsapp.S_OMNI_ID__c  ){
                omniReadyId = fullSyncConfig.whatsapp.S_OMNI_ID__c;
                if ( currentStatusId != omniReadyId && currentStatusId != fullSyncConfig.chat.S_OMNI_ID__c){
                    changeStatus = true;             
                }
            }
            if ( changeStatus ){
                logsf.info(`onChatEventRingingInbound.manageAgentStatus , currentStatusId=${currentStatusId} and channelStatusId=${omniReadyId} are different, setting channelStatusId"`);
                var updateStatus = await omniUtils.callApiSync(sforce.console.presence.login,omniReadyId);
                logsf.info("onChatEventRingingInbound.manageAgentStatus , updateStatus result : ", updateStatus);
                logsf.info("onChatEventRingingInbound.manageAgentStatus , reloading schedule");
                this.loadSchedule(false,true);
            }
           
           
        }catch(e){
            console.error("error in onChatEventEstablishedInbound :",e);
        }
    }

    openTab(id){
        sforce.opencti.publish({
            channelName: 'softphone_it__LMC_Connector__c',
            message: {
                "command": "openTab",
                "id": id
            }, callback: (res) => console.log("*** callback result :", res)
        });
    }
    showDialog(title, body, refresh) {
        sforce.opencti.publish(
            {
                channelName: 'softphone_it__LMC_Connector__c',
                message: {
                    "command": "openDialog",
                    "refresh": refresh,
                    "title": title,
                    "body": body
                }, callback: (res) => console.log("*** callback result :", res)
            });
    }
    manageScheduleTimeout() {
        logsf.info("manageScheduleTimeout, start");
        clearInterval(intervalSchedule);
        var start = -1;
        var now = new Date().getTime();
        if (syncConfig.chatSchedule.open) {
            start = syncConfig.chatSchedule.end - now;
        } else {
            if (syncConfig.chatSchedule.start) {
                start = syncConfig.chatSchedule.start - now;
            }
        }
        logsf.info("manageScheduleTimeout,open=" + syncConfig.chatSchedule.open + ",syncConfig.chatSchedule.start=" + syncConfig.chatSchedule.start
            + ",syncConfig.chatSchedule.end" + syncConfig.chatSchedule.end + "chatSchedule, difftimeout = " + start);
        if (start > 0) {
            intervalSchedule = setTimeout(() => {
                logsf.info("manageScheduleTimeout, scheduleTimeout expired, reloading ..");
                this.loadSchedule(true);
            }, start);
        };
    }

    manageWhatsappTimeout(message) {
        if (!syncConfig.whatsapp || !syncConfig.whatsapp.S_MESSAGES_TIMEOUT__c) {
            logsf.info("cannot manage whatsapp timeout, bad configuration  :  ", syncConfig);
            return;
        }
        if (syncConfig.whatsapp.S_MESSAGES_TIMEOUT__c <= 0) {
            logsf.info("TIMEOUT whatsapp is disabled, returning .. ");
            return;
        }
        logsf.info("TIMEOUT START of " + syncConfig.whatsapp.S_MESSAGES_TIMEOUT__c + " seconds, for interaction : " + message.InteractionID);
        var interval = setTimeout(() => {
            logsf.info("TIMEOUT EXPIRED, closing whatsapp interaction :  ", message);
            iwscommand.updateStatePEF(message.InteractionID, "disconnect");
            delete this.mapWhatsappInteractions[message.InteractionID];
            this.showDialog("Attenzione", "La sessione Whatsapp con l'utente " + message.attachdata.ani + " e' scaduta.");

        }, syncConfig.whatsapp.S_MESSAGES_TIMEOUT__c * 1000);

        this.mapWhatsappInteractions[message.InteractionID] = interval;
    }
}
var scheduleUtils = new IwsSchedule();
