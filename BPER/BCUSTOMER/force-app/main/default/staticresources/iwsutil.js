class Util {
    constructor() {
        this.mapDelegated = {};
        this.mapInteractions = {};
    }

    FIXED_DISPOSITION_CODE = "987b78e4-48cf-42c8-8d8c-ecb65f9f0687";
    PRESENCE_STATUSES = {};
    GS_AGENT_ID = undefined;

    async unbluPersonSearch(){
        
        try{
            var userId = await sfutil.callApiSync(UnbluController.unbluUserSearch,window["gcUser"].username);
           /*
            if ( !userId ){
                userId = await sfutil.callApiSync(UnbluController.createUser,window["gcUser"].username,window["gcUser"].name);
            }
            */
            if ( !userId ){
                scheduleUtils.showDialog("Attenzione", "Non è stato possibile recuperare unblu person id.Si prega di contattare un amministratore.",true)
                return;
            }
            var id = await sfutil.callApiSync(UnbluController.unbluPersonSearch,userId);
           
            logsf.info("getUnbluPersonId,unbluPersonId : ",id);
            return id;
        }catch(e){
            logsf.info("getUnbluPersonId,error",e);
            scheduleUtils.showDialog("Attenzione", "Non è stato possibile recuperare unblu person id.Si prega di contattare un amministratore.",true)
            return;
        }
    }

    async unbluInviteAgentToConversation(unbluConvId){
        
        try{
            var result = await sfutil.callApiSync(UnbluController.unbluInviteAgentToConversation,unbluConvId,unbluPersonId);
            logsf.info("unbluInviteAgentToConversation,result : ",result);
            return result;
            
        }catch(e){
            logsf.info("unbluInviteAgentToConversation,error",e);
            scheduleUtils.showDialog("Attenzione", "Non è stato possibile recuperare unblu person id.Si prega di contattare un amministratore.")
           
        }
        return undefined;
    }

    async unbluAddParticipant(unbluConvId){
        
        try{
            var result = await sfutil.callApiSync(UnbluController.unbluAddParticipant,unbluConvId,unbluPersonId);
            logsf.info("unbluAddParticipant,result : ",result);
            return result;
            
        }catch(e){
            logsf.info("unbluAddParticipant,error",e);
            scheduleUtils.showDialog("Attenzione", "Non è stato possibile aggiungerti alla conversazione.Si prega di contattare un amministratore.")
           
        }
        return undefined;
    }

    async unbluSetAssigneePerson(unbluConvId){
        
        try{
            var result = await sfutil.callApiSync(UnbluController.unbluSetAssigneePerson,unbluConvId,unbluPersonId);
            logsf.info("unbluSetAssigneePerson,result : ",result);
            return result;
            
        }catch(e){
            logsf.info("unbluSetAssigneePerson,error",e);
            scheduleUtils.showDialog("Attenzione", "Non è stato possibile assegnarti alla conversazione.Si prega di contattare un amministratore.")
           
        }
        return undefined;
    }

    async unbluEndConversation(unbluConvId){
        
        try{
            var result = await sfutil.callApiSync(UnbluController.unbluEndConversation,unbluConvId);
            logsf.info("unbluEndConversation,result : ",result);
            return result;
            
        }catch(e){
            logsf.info("unbluEndConversation,error",e);
            scheduleUtils.showDialog("Attenzione", "Non è stato possibile assegnarti alla conversazione.Si prega di contattare un amministratore.")
           
        }
        return undefined;
    }

    async updateUnbluChatAccepted(caseId,interactionId){
        try{
            var result = await sfutil.callApiSync(UnbluController.updateUnbluChatAccepted,caseId,interactionId);
            logsf.info("updateUnbluChatAccepted,result : ",result);
            return result;
        }catch(e){
            logsf.info("updateUnbluChatAccepted,error",e);
        }
        return undefined;
    }
    async updateUnbluChatEnded(caseId){
        try{
            var result = await sfutil.callApiSync(UnbluController.updateUnbluChatEnded,caseId);
            logsf.info("updateUnbluChatEnded,result : ",result);
            return result;
        }catch(e){
            logsf.info("updateUnbluChatEnded,error",e);
        }
        return undefined;
    }

    async unbluRequeueConversation(unbluConvId){
        try{
            var result = await sfutil.callApiSync(UnbluController.unbluRequeueConversation,unbluConvId);
            logsf.info("unbluRequeueConversation,result : ",result);
            return result;
        }catch(e){
            logsf.info("unbluRequeueConversation,error",e);
        }
        return undefined;
    }
    
     getGenesysAgentId() {
		logsf.info("getGenesysAgentId,START");
        
        try{
            this.GS_AGENT_ID = window["gcUser"].id;
            logsf.info("getGenesysAgentId,GS_AGENT_ID : ",this.GS_AGENT_ID);
        }catch(e){
            logsf.info("getGenesysAgentId,error",e);
            scheduleUtils.showDialog("Attenzione", "Non � stato possibile connecttersi a Genesys.Si prega di refreshare il browser.")
            return;
        }
        
        
    }
    
    focusOpenedTab() {
        sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB, (ta) => {
            logsf.info("opened tab : ", ta);
            sforce.console.focusPrimaryTabById(ta.id, res => logsf.info("focusOpenedTab focused tab result", res), true);
        });
    }

    manageCTILabel(message) {
        if (message && message.attachdata && message.attachdata.status) {
            var label = message.attachdata.status;
            if (this.PRESENCE_STATUSES[message.attachdata.id]) {
                label = this.PRESENCE_STATUSES[message.attachdata.id];
            }
            if (message.attachdata.sub_status) {
                label += " - " + message.attachdata.sub_status;
            }
            this.updateOpenCtiLabel(label);
        }
    }
    async buildPresenceStatuses() {
        var presenceApi = new pClient.platformClient.PresenceApi();
        var res = await presenceApi.getPresencedefinitions({ pageSize: 99 });
        if (res && res.entities) {
            res.entities.forEach(x => this.PRESENCE_STATUSES[x.id] = x.systemPresence);
        }
        logsf.info("presences : ", this.PRESENCE_STATUSES);
    }
    /*async getAgentId(message) {
        let res = await pClient.conversationApi.getConversation(message.InteractionID);
        if (res && res.participants) {
            for (var i = res.participants.length - 1; i >= 0; i--) {
                const agent = res.participants[i];
                if (agent && agent.purpose == "agent" && agent.endTime) {
                    return agent.id;
                }
            }

        } else {
            console.log("no active conversation, cannot retrieve agent.");
            return null;
        }
    }*/
    async getAgentId(message) {
        let res = await pClient.conversationApi.getConversation(message.InteractionID);
        if (res && res.participants) {
            for (var i = res.participants.length - 1; i >= 0; i--) {
                const agent = res.participants[i];
                if (agent && this.GS_AGENT_ID && agent.userId == this.GS_AGENT_ID && agent.endTime) {
                    return agent.id;
                }
            }
        }
        else {
            console.log("no active conversation, cannot retrieve agent.");
            return null;
        }
    }

    async getAgentIdFromExternalRoutingBean(message) {
        if (!message || !message.attachdata || !message.attachdata.work_item_id) {
            logsf.info("Error in getAgentIdFromExternalRoutingBean, the message is not valid :", message);
            return;
        }
        try {

            let res = await sfutil.callApiSync(ConnectorEntityController.getExternalRoutingBean, message.attachdata.work_item_id);
            if (res && res.Agent_Id__c) {
                return res.Agent_Id__c;
            }
        } catch (e) {
            logsf.info("error, cannot find externalroutingbean : ", e);
        }
        return undefined;
    }

    async markdoneInteraction(message, timeout) {
        logsf.info("markdoneInteraction timeout = " + timeout + ", message: ", message);
        var agentId;
        try{
            agentId = await this.getAgentId(message);
            if ( !agentId ){
                logsf.info("markdoneInteraction agentId is null, returning.. ");
                return;
            }
            setTimeout(async () => {
                try{
                	var res = await pClient.patchConversationParticipant(agentId, message.InteractionID, message.MediaType, { wrapup: { code: this.FIXED_DISPOSITION_CODE } });
                    logsf.info("markdoneInteraction result ", res);
                }catch(e1){
                    logsf.info("markdoneInteraction error: ", e1);
                }
                
            }, timeout);
        }catch(e){
            logsf.info("markdoneInteraction error: ", e);
        }
    }

    async pickupInteraction(message) {
        setTimeout(() => iwscommand.updateStatePEF(message.InteractionID, "pickup"), 5000);
    }
    async pickupInteractionCampaign(message) {
        setTimeout(() => iwscommand.updateStatePEF(message.InteractionID, "pickup"), 500);
    }
    manageWidgetVisibility() {

        let callback = function (response) {
            if (response.success) {
                logsf.info('API method call executed successfully! returnValue:', response.returnValue);
            }
            else {
                console.error('Something went wrong! Errors:', response.errors);
            }
        };
        let isVisibleCallback = function (response) {
            if (response.success) {
                if (!response.returnValue.visible) {
                    sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
                }
                else {
                    logsf.info('Softphone Panel is open: ', response.returnValue.visible);
                }
            }
            else {
                console.error('Something went wrong! Errors:', response.errors);
            }
        };
        sforce.opencti.isSoftphonePanelVisible({ callback: isVisibleCallback });
    }

    addTabClosedListener(){
        sforce.console.addEventListener(sforce.console.ConsoleEvent.CLOSE_TAB, (tab) => {
            logsf.info("tab : ", tab);
        });
    }
    async addTabFocusListener() {

        sforce.console.onFocusedPrimaryTab(listened => {
            logsf.info("addTabFocusListener listened objectId: ", listened.id);

            if (listened && listened.id) {
                for (let key in iwscore.mapInteractions) {
                    let ixn = iwscore.mapInteractions[key];
                    let id = (ixn && ixn.attachdata) ? ixn.attachdata.contact_id || ixn.attachdata.sfdc_id || ixn.attachdata.case_id ||ixn.attachdata["context.livechat_id"] || ixn.attachdata['context.work_item_id'] : undefined;
                    if (id && listened.objectId.startsWith(id)) {
                        iwscommand.SetInteractionOnWde(ixn.InteractionID || ixn.ConnectionID);
                    }
                }
            }
        });
    }

    clickToDialCb(payload) {

        log.info('Clicked phone number: ' + JSON.stringify(payload));
        if (!payload || !payload.number) {
            log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
            return;
        }
        let call = {
            number: payload.number,
            type: "call",
            autoPlace: true,
            attributes: {}
        };
        var key = (payload.objectType + "_id").toLowerCase();
        call.attributes[key] = payload.recordId;
        iwscommand.clickToDialPEF(call);
    }

    enableClickToDial() {
        var callback = (res) => {
            log.info("click to dial response=" + JSON.stringify(res));
        };
        log.info("enabling click to dial");

        sforce.opencti.onClickToDial({
            listener: this.clickToDialCb
        });
        sforce.opencti.enableClickToDial({ callback: callback });

    }

    checkExists(event) {
        logsf.info("checkExists, event:", event);
        if (!event.attachdata) {
            logsf.info("the event has no attachdata, returning");
            return;
        }
        let id = event.attachdata.CONTACT_ID || event.attachdata.SFDC_ID || event.attachdata.WorkItemId || event.attachdata['context.WorkItemId'];
        if (id) {
            log.infoFormat("There is already an item associated to this interaction : {0}, opening it", id);
            this.refreshTabAndScreenpop(id);
            return true;
        }
        return false;
    }
    async refreshTabAndScreenpop(id) {
        var tabIds = await this.callApiSync(sforce.console.getPrimaryTabIds);
        var refresh = false;
        if (tabIds.success && tabIds.ids) {
            for (var i = 0; i < tabIds.ids.length; i++) {
                var tabId = tabIds.ids[i];
                logsf.info("refreshTabAndScreenpop cycling tab : ", tabId)
                var objectId = await this.callApiSync(sforce.console.getPageInfo, tabId);
                if (objectId.success) {
                    var pageInfo = JSON.parse(objectId.pageInfo);
                    if (pageInfo.objectId && pageInfo.objectId.startsWith(id)) {
                        sforce.console.refreshPrimaryTabById(tabId, true, res => logsf.info("refreshTabAndScreenpop refresh tab result", res), true);
                        refresh = true;
                        return;
                    }
                }
            }

        }
        logsf.info("refreshTabAndScreenpop toRefresh : ", refresh)
        if (refresh) {
            return;
        }
        this.screenpop(id);
    }

    async focusTab(id) {
        var tabIds = await this.callApiSync(sforce.console.getPrimaryTabIds);
        if (tabIds.success && tabIds.ids) {
            for (var i = 0; i < tabIds.ids.length; i++) {
                var tabId = tabIds.ids[i];
                logsf.info("focusTab cycling tab : ", tabId)
                var objectId = await this.callApiSync(sforce.console.getPageInfo, tabId);
                if (objectId.success) {
                    var pageInfo = JSON.parse(objectId.pageInfo);
                    if (pageInfo.objectId && pageInfo.objectId.startsWith(id)) {
                        sforce.console.focusPrimaryTabById(tabId, res => logsf.info("focusTab focused tab result", res), true);
                        return;
                    }
                }
            }
        }
    }

    screenpop(id) {
        if (isLightning) {
            sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id } });
        }
        else {
            sforce.interaction.screenPop('/' + id, true, undefined);
        }
    }

    screenpopFlow(id) {
        sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.FLOW, params: { flowDevName: id } });
    }
    manageSwitchInteraction(event) {
        if ( !event || !event.attachdata ){
            logsf.info("manageSwitchInteraction exit, no attachdata");
            return;
        }
        let id = event.attachdata.contact_id || event.attachdata.sfdc_id || event.attachdata.case_id || event.attachdata["context.livechat_id"] || event.attachdata['context.work_item_id'];
        if (id) {
            this.focusTab(id);
        }
    }
    callApiSync(api, ...params) {
        return $.Deferred((dfrd) => {
            if (params) {
                api(...params, dfrd.resolve);
            }
            else {
                api(dfrd.resolve);
            }
        }).promise();
    }
    createTask(event, field, id, subject) {
        if (this.checkExists(event)) {
            return;
        }
        var task = new sforce.SObject("task");
        task.Subject = subject;
        task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        ConnectorEntityController.createTask(task, field, id, (result, req) => {
            logsf.info("result : ", result);
            logsf.info("req : ", req);
            if (req.statusCode == 200) {
                var params = { "SFDC_ID": result.Id };
                if (result.WhoId) {
                    params.CONTACT_ID = result.WhoId;
                }
                iwscommand.SetAttachdataById(event.ConnectionID, params);
                event.attachdata = Object.assign(event.attachdata, params);
                iwscore.addJSONObjectInMemory(event);
                let idToScreen = result.WhoId ? result.WhoId : result.Id;
                logsf.info("idToScreen :", idToScreen);
                this.refreshTabAndScreenpop(idToScreen);
            }
        });
    }
    createCase(event, field, id, subject) {
        if (this.checkExists(event)) {
            return;
        }
        var obj = new sforce.SObject("case");
        obj.Subject = subject;
        obj.IWS_Interaction_ID__c = event.ConnectionID;
        obj.IWS_Media_Name__c = event.MediaType;
        ConnectorEntityController.createCase(obj, field, id, function (result, req) {
            logsf.info("result : ", result);
            logsf.info("req : ", req);
            if (req.statusCode == 200) {
                var params = { "SFDC_ID": result.Id };
                if (result.ContactId) {
                    params.CONTACT_ID = result.WhoId;
                }
                iwscommand.SetAttachdataById(event.ConnectionID, params);
                event.attachdata = Object.assign(event.attachdata, params);
                iwscore.addJSONObjectInMemory(event);
                let idToScreen = result.ContactId ? result.ContactId : result.Id;
                logsf.info("idToScreen :", idToScreen);
                this.refreshTabAndScreenpop(idToScreen);
            }
        });
    }

    updateConnectionLed(clazz, msg) {
        $("#led").removeClass();
        $("#led").addClass(clazz);
        $(".led-msg p").text(msg);
    }
    updateOpenCtiStatus(connected) {
        if (isLightning) {
            let icon = connected ? 'call' : 'end_call';
            sforce.opencti.setSoftphoneItemIcon({ key: icon, callback: (res) => logsf.info("result change icon : ", res) });
            sforce.opencti.setSoftphonePanelIcon({ key: icon, callback: (res) => logsf.info("result change icon : ", res) });
            if (!connected) {
                this.updateOpenCtiLabel("Phone");
            }
        }
    }

    updateOpenCtiLabel(label) {
        if (isLightning) {
            sforce.opencti.setSoftphoneItemLabel({ label: label, callback: (res) => logsf.info("result change icon : ", res) });
            sforce.opencti.setSoftphonePanelLabel({ label: label, callback: (res) => logsf.info("result change icon : ", res) });
        }
    }
    customAction(data) {
        console.log('GB Data json: ' + JSON.stringify(data));
        console.log('GB Data typeCall: ' + JSON.stringify(data.typeCall));
        if (data.typeCall !== 'outbound') {
            if (isLightning) {
                ConnectorEntityController.customAction(data, function (result, req) {
                    if (req.statusCode == 200) {
                        console.log('@@@result: ' + JSON.stringify(result));
                        console.log('@@@req: ' + JSON.stringify(req));
                        createdCaseId = result.caseId;
                        var params = { "caseidreal": result.caseId };
                        params.casenumber = result.caseNumber;
                        if (result.accountId) {
                            params.accountid = result.accountId;
                            params.accountname = result.accountName;
                        }
                        iwscommand.SetAttachdataById(currentMessage.ConnectionID, params);
                        if (semaforo.children !== undefined) {
                            semaforo.children[0].children[0].style.removeProperty('display');
                        }

                        /*if(result.accountId!==undefined){
                            var openSub = function openSuccess(resub) {
                            //Report whether we succeeded in opening the subtab
                                if (resub.success == true) {
                                    caseTabId=resub.id;
                                } 
                                else {
                                    console.log('subtab cannot be opened '+JSON.stringify(resub));
                                }
                            };
                            var openSuccess = function openSuccess(resultTab) {
                                accountTabId=resultTab.id;
                            //Report whether opening the new tab was successful
                                if (resultTab.success == true) {
                                    sforce.console.openSubtab(resultTab.id , '/'+result.caseId, true, 
                                                            result.caseNumber, null, openSub , 'salesforceSubtab');
                                } else {
                                    console.log('Primary tab cannot be opened '+JSON.stringify(resultTab));
                                }
                            };
                            sforce.console.openPrimaryTab(null, '/'+result.accountId, false, 
                                                        result.accountName, openSuccess, 'salesforceTab');
                        }*/

                        var openSuccess = function openSuccess(resultTab) {
                            caseTabId = resultTab.id;
                            //Report whether opening the new tab was successful
                            if (resultTab.success == true) {
                                console.log('tab opened');
                            } else {
                                console.log('Primary tab cannot be opened ' + JSON.stringify(resultTab));
                            }
                        };
                        sforce.console.openPrimaryTab(null, '/' + result.caseId, true,
                            result.caseNumber, openSuccess, 'salesforceTab');


                    }
                    else {
                        console.log('@@@error ' + JSON.stringify(req));
                    }
                });
            }
        } else {
            console.log('GB Semaforo: ' + semaforo.children);
            semaforo.children[0].children[0].style.removeProperty('display');
        }
    }
    updateCampaignMember(id, attempt) {
        var cm = new sforce.SObject("CampaignMember");
        cm.id = id;
        cm.CRM_NumeroTentativi__c = attempt == null ? 1 : parseInt(attempt) + 1;
        let result = sforce.connection.update([cm], undefined);
        if (result[0].getBoolean("success")) {
            log.info("cm with id " + result[0].id + " updated");
        }
        else {
            log.error("failed to update cm " + result[0]);
        }

    }
    openCampaignMember(cId) {
        
        var callback = function (queryResult, source) {
            var id;
            var name;
            var attemptNumber;
            console.log('@@@@queryResult' + JSON.stringify(queryResult));
            /*if (queryResult.size === "1") {
                console.log('@@@@ifMethod');
                id = queryResult.records.Id;
                name = queryResult.records.Contact.Name;
                if (queryResult.records.CRM_NumeroTentativi__c === null) {
                    attemptNumber = 0;
                }
                else {
                    attemptNumber = queryResult.records.CRM_NumeroTentativi__c;
                }
            }
            else {
                console.log('@@@@elseMethod');
                console.log('@@@@elseMethodId'+queryResult.Id);
                id = queryResult.records[0].Id;
                name = queryResult.records[0].Contact.Name;
                if (queryResult.records[0].CRM_NumeroTentativi__c === null) {
                    attemptNumber = 0;
                }
                else {
                    attemptNumber = queryResult[0].records.CRM_NumeroTentativi__c;
                }
            }*/
            id = queryResult.Id;
                name = queryResult.Contact.Name;
                if (queryResult.CRM_NumeroTentativi__c === null) {
                    attemptNumber = 0;
                }
                else {
                    attemptNumber = queryResult.CRM_NumeroTentativi__c;
                }
            campaignMemberId = id;
            attempt = attemptNumber;
            var openSuccess = function openSuccess(resultTab) {

                //Report whether opening the new tab was successful
                if (resultTab.success == true) {
                    console.log('tab opened');
                } else {
                    console.log('Primary tab cannot be opened ' + JSON.stringify(resultTab));
                }
            };
            sforce.console.openPrimaryTab(null, '/' + id, true,
                name, openSuccess, 'salesforceTab');


        };
        ConnectorEntityController.findCampaignMember (cId, callback);
        /*sforce.connection.query(
            "select Id, Contact.Name, CRM_NumeroTentativi__c from CampaignMember where Id = '" + cId + "'",
            callback);*/
    }

    openEvent(eId) {
        
        var callback = function (queryResult, source) {
            var id;
            var subject;
            console.log('@@@@queryResult' + JSON.stringify(queryResult));
            
            id = queryResult.Id;
            subject = queryResult.Subject;
            var openSuccess = function openSuccess(resultTab) {

                //Report whether opening the new tab was successful
                if (resultTab.success == true) {
                    console.log('tab opened');
                } else {
                    console.log('Primary tab cannot be opened ' + JSON.stringify(resultTab));
                }
            };
            sforce.console.openPrimaryTab(null, '/' + id, true,
                subject, openSuccess, 'salesforceTab');


        };
        ConnectorEntityController.findEvent(eId, callback);
        
    }
    
    updateCase(caseId, aut, ndgId, abi) {
        ConnectorEntityController.updateCase(caseId, aut, ndgId, abi, function (result, req) {


            if (req.statusCode == 200) {
                console.log('@@@@@updateSuccess');
                console.log(accountTabId);
                console.log(caseTabId);
                /*if(accountTabId!==undefined){
                    sforce.console.refreshSubtabById(caseTabId, true);
                }
                else{*/
                sforce.console.refreshPrimaryTabById(caseTabId, true);
                //}
            }
            else {
                console.log('@@@updateError ' + JSON.stringify(req));
            }
        });


    }
    changeStatus() {
        var callback = function (queryResult, source) {
            var busyStatusId;
            console.log('@@@@queryResult' + JSON.stringify(queryResult));
            queryResult.records.forEach(element => {
                if (element.DeveloperName === 'Busy') {
                    busyStatusId = element.Id.slice(0, -3);
                }
                console.log('busyStatusId ' + busyStatusId);
            });

            sforce.console.presence.getServicePresenceStatusId(function (result) {
                if (result.success) {
                    console.log('servicepresencestatus: ' + JSON.stringify(result));
                    if (result.statusApiName === 'Online') {
                        sforce.console.presence.setServicePresenceStatus(busyStatusId, function (result) {
                            if (result.success) {
                                console.log('@@@@@successStatus');
                            } else {
                                console.log('Set status failed' + JSON.stringify(result));
                            }
                        });
                    }

                } else {
                    console.log('@@@@getStatusFailed')
                }
            });

        };
        sforce.connection.query(
            "Select Id, DeveloperName From ServicePresenceStatus",
            callback);
    }

    async openLiveChat(message, maxRetry) {
        logsf.info("openLiveChat start");
        var max = maxRetry || 3;
        var pr = await omniUtils.tryGetLiveChat(message, 0, max);
        if (!pr) {
            logsf.info("openLiveChat, Cannot find the pending request!");
            scheduleUtils.showDialog("Attenzione", "La chat non e' piu' disponibile, la conversazione verra' disconnessa.")
            iwscommand.updateStatePEF(message.InteractionID, "disconnect");
            return;
        }
        iwscommand.SetAttachdataById(message.InteractionID, {
            work_item_id: pr.WorkItemId,
            service_channel_id: pr.ServiceChannelId,
            queue_id: pr.QueueId,
            psr_id: pr.Id
        });
        message.attachdata.work_item_id = pr.WorkItemId;
        message.attachdata.service_channel_id = pr.ServiceChannelId;
        message.attachdata.queue_id = pr.QueueId;
        message.attachdata.psr_id = pr.Id;
        iwscore.addJSONObjectInMemory(message);
        try{
            var agentWork = await this.createAgentWork(message);
            logsf.info("openLiveChat insertAgentWork result :", agentWork);
    
            if (!agentWork || !agentWork.WorkItemId) {
                this.manageInsertAgentWorkError();
                return;
            } 
            if (message.attachdata.media_type == "chat") {
                this.updateExternalRoutingBeanWithAgentId(message);
            }
        }catch(e){
            logsf.info("openLiveChat error insertAgentWork :", e);
            this.manageInsertAgentWorkError(message);
        }
    }

	manageInsertAgentWorkError(message){
    	iwscommand.updateStatePEF(message.InteractionID, "disconnect");
        iwscommand.NotReadyAll();
        scheduleUtils.showDialog("Attenzione", "Si e' verificato un errore nella creazione della chat e sei stato reso non disponibile su Genesys. Si prega di concludere le interazioni attive e refreshare il browser.");
        this.markdoneInteraction(message, 500);
	}

    async updateCaseRoutingStatus(caseId,status){
        logsf.info("START updateCaseRoutingStatus, caseId : ", caseId);
        try{
            var result = await this.callApiSync(ConnectorEntityController.updateCaseRoutingStatus, caseId,status);
            logsf.info("END updateCaseRoutingStatus, result : ", result);
        }catch(e){
            logsf.info("END updateCaseRoutingStatus, error : ", e);
            scheduleUtils.showDialog("Attenzione", "Non � stato possibile aggiornare il flag CRM_OnQueue per il caseId : " + caseId + ". Contattare l'amministrazione.")
            
        }
       
        
    }

    async createAgentWork(event) {

        logsf.info("createAgentWork start");
        let ad = event['attachdata'];
        if (ad.tabId) {
            logsf.info("agent work already created... returning");
            return;
        }
        let channelId = ad.service_channel_id || ad.ServiceChannelId;
        let workItemId = ad.work_item_id || ad.WorkItemId;
        let pendingServiceRoutingId = ad.psr_id || ad.Id;
        if (!channelId) {
            console.warn("The channelId is null!, cannot createAgentWork...");
            return;
        }
        if (!workItemId) {
            console.warn("The workItemId is null!, cannot createAgentWork...");
            return;
        }
        if (!pendingServiceRoutingId) {
            console.warn("The pendingServiceRoutingId is null!, cannot createAgentWork...");
            return;
        }
        logsf.info(`createAgentWork calling insertAgentWork channelId=${channelId} workItemId=${workItemId} pendingServiceRoutingId=${pendingServiceRoutingId}`);
        return omniUtils.callApiSync(softphoneerc.InsertAgentWork.insertWorkRemote, channelId, workItemId, pendingServiceRoutingId, event.ConnectionID);
    }

    async updateExternalRoutingBeanWithAgentId(message) {
        var conv = await pClient.conversationApi.getConversation(message.InteractionID);
        if (!conv) {
            logsf.info("cannot updateExternalRoutingBean, conversation is null");
            return;
        }
        var agent = conv.participants[conv.participants.length - 1];
        if (!agent) {
            logsf.info("cannot updateExternalRoutingBean, agent is null");
            return;
        }
        ConnectorEntityController.updateExternalRoutingBean(message.InteractionID, agent.id, res => logsf.info("updateExternalRoutingBean result :", res));
    }

    async addPresenceListener() {
        omniUtils.syncEnabled = true;

        sforce.console.addEventListener(sforce.console.ConsoleEvent.PRESENCE.WORK_CLOSED, (res) => {
            logsf.info("PRESENCE.WORK_CLOSED, received : ", res);
            if (res && res.workItemId) {
                let interaction = null;
                logsf.info("PRESENCE.WORK_CLOSED,searching for workitemId : " + res.workItemId + ", on  interactions : ", iwscore.mapInteractions);
                for (let x in iwscore.mapInteractions) {
                    let interaction = iwscore.mapInteractions[x];
                    let wId = interaction && interaction.attachdata ? interaction.attachdata.work_item_id : undefined;
                    logsf.info("PRESENCE.WORK_CLOSED,checking interaction wi : " + wId);

                    if (wId) {
                        if (wId.startsWith(res.workItemId)) {
                            logsf.info("PRESENCE.WORK_CLOSED,starting timeout, interaction found : ", interaction);
                            setTimeout(() => {
                                logsf.info("PRESENCE.WORK_CLOSED,timeout expired, closing interaction : ", interaction.InteractionID);
                                iwscommand.updateStatePEF(interaction.InteractionID, "disconnect");
                            }, 4900);
                            return;
                        }
                    }
                }


            }
        });


    }

    // Closes the agent work tab, and send the delegat command to the wwe
    async closeTab(workItemId) {
        logsf.info("closeTab, workItemId=", workItemId);
        if (!workItemId) {
            console.warn("closeTab The workItemID is null!, cannot perform closeTab...");
            return;
        }
        try {
            let tabIds = await this.callApiSync(sforce.console.getPrimaryTabIds);
            logsf.info("closeTab, getPrimaryTabIds=", tabIds);
            if (tabIds.success) {
                for (var i = 0; i < tabIds.ids.length; i++) {
                    var tabId = tabIds.ids[i];
                    var objectId = await this.callApiSync(sforce.console.getPageInfo, tabId);
                    logsf.info("closeTab, tabDetail=", objectId);
                    if (objectId.success) {
                        var pageInfo = JSON.parse(objectId.pageInfo);
                        if (pageInfo.objectId && pageInfo.objectId.startsWith(workItemId)) {
                            sforce.console.closeTab(tabId, (res) => { logsf.info("closeTab,closed tab : ", res); });
                            return;
                        }
                    }
                }
            }
        } catch (e) { 
            logsf.info("closeTab, error=", e);
        }
        logsf.info("closeTab, no tab found on Salesforce");
    }

    updateCampaignQueue(campaignMemberId, queue, interactionId, agentId) {
        logsf.info("updateCampaignQueue start");
        logsf.info("updateCampaignQueue start");
        console.log("updateCampaignQueue");
        try {
            ConnectorEntityController.updateQueue(campaignMemberId, queue, interactionId, agentId, function (result, req) {
                logsf.info("updateCampaignQueue result : ", result);
                logsf.info("updateCampaignQueue req status : ", JSON.stringify(req));
        });
            } catch (e) { 
                logsf.info("updateCampaignQueue, error=", e);
        }
    }
                                                                     
    updateCaseInteraction(livechatId, interactionId, mediaType) {
        console.log("updateCaseInteraction");
		console.log("livechatId: "+livechatId); 
        console.log("interactionId: "+interactionId); 
       	console.log("mediaType: "+mediaType); 
        try {
            ConnectorEntityController.updateCaseInteraction (livechatId, interactionId, mediaType, function (result, req) {
                logsf.info("updateCaseInteraction result : ", result);
                logsf.info("updateCaseInteraction req status : ", JSON.stringify(req));
        });
            } catch (e) { 
                logsf.info("updateCampaignQueue, error=", e);
        }
    }
 
    updateCaseOwner(caseId) {
        logsf.info("updateCaseOwner start");
        console.log("updateCaseOwner");
        try {
            ConnectorEntityController.updateCaseOwner(caseId,this.GS_AGENT_ID, (result, req) => {
                logsf.info("updateCaseOwner result : ", result);
                logsf.info("updateCaseOwner req status : ", JSON.stringify(req));
                //this.refreshTabAndScreenpop(caseId);                                                    
        });
            } catch (e) { 
                logsf.info("updateCaseOwner, error=", e);
                                                                     
        }
    }

    updateCampaignMemberAgentId(campaignMemberId, agentId) {
		
        console.log('campaignMemberId iwsutil: '+campaignMemberId);
        console.log('agentId iwsutil: ' + agentId);
        logsf.info("updateCampaignMember start");
        console.log("updateCampaignMember");

        try {
            ConnectorEntityController.updateCampaignMember(campaignMemberId, agentId, function (result, req) {
                console.log("updateCampaignMember result: ",result);
				logsf.info("updateCampaignMember result : ", result);
                logsf.info("updateCampaignMember req status : ", JSON.stringify(req));
            });
        }catch(e) { 
            logsf.info("updateCampaignMember, error=", e);
        }
    }

}
const sfutil = new Util();