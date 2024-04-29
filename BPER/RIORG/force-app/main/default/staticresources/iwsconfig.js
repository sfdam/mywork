log.setLogLevel(enumloglevel.error);
if (softphoneSettings.GEN_LOG_LEVEL == 'Debug') {
    log.setLogLevel(enumloglevel.debug);
}
switch (softphoneSettings.GEN_INTEGRATION_TYPE) {
    case "PURECLOUD":
        loadPureRequestConfig();
        break;
    case "WDE":
        loadWDE();
        break;
    case "WWE":
        loadWWE();
        break;
}
var GC_ENVIRONMENT = softphoneSettings.PEF_GC_ENVIRONMENT;
function loadWDE() {
    iwscore.getLayoutParams().integrationType = "wde";
    iwscore.createConnection(softphoneSettings.WDE_HOST, softphoneSettings.WDE_PORT, { 'protocol': softphoneSettings.WDE_PROTOCOL });
}
function loadPureRequestConfig() {
    var auth = {
        environment: softphoneSettings.PEF_GC_ENVIRONMENT,
        notReadyPresenceId: softphoneSettings.PEF_NOT_READY_ID,
        onQueuePresenceId: softphoneSettings.PEF_ON_QUEUE_ID
    };
    var params = {
        customInteractionAttributes: ["CRM_CustomerAuthenticationType", "esigenza_SF","ndgId","secureflow","caseidreal","accountid","accountname","casenumber", "abi","callbacknumbers","dialercampaignId","dialercontactId","dialercontactlistId","dialerinteractionid","scriptid","voicemail","Id","CRM_NumeroTentativi__c",
                                     "sfdc_id","case_id","task_id","contact_id","context.prechat_id","context.livechat_id","service_channel_id","work_item_id","id","psr_id","ani","motivo_chat","codice_fiscale","media_type","name"],
        settings: {
            sso: false,
            embedWebRTCByDefault: softphoneSettings.PEF_EMBED_WEB_RTC_BY_DEFAULT == "true",
            hideWebRTCPopUpOption: softphoneSettings.PEF_HIDE_WEB_RTC_POP_UP_OPTION == "true",
            enableCallLogs: softphoneSettings.PEF_ENABLE_CALL_LOGS == "true",
            hideCallLogSubject: softphoneSettings.PEF_HIDE_CALL_LOG_SUBJECT == "true",
            hideCallLogContact: softphoneSettings.PEF_HIDE_CALL_LOG_CONTACT == "true",
            hideCallLogRelation: softphoneSettings.PEF_HIDE_CALL_LOG_RELATION == "true",
            enableTransferContext: softphoneSettings.PEF_ENABLE_TRANSFER_CONTEXT == "true",
            dedicatedLoginWindow: softphoneSettings.PEF_DEDICATED_LOGIN_WINDOW == "true",
            embeddedInteractionWindow: softphoneSettings.PEF_EMBEDDED_INTERACTION_WINDOW == "true",
            enableConfigurableCallerId: softphoneSettings.PEF_ENABLE_CONFIGURABLE_CALLER_ID == "true",
            enableServerSideLogging: softphoneSettings.PEF_ENABLE_SERVER_SIDE_LOGGING = "true",
            enableCallHistory: softphoneSettings.PEF_ENABLE_CALL_HISTORY == "true",
            display: {
                "interactionDetails": {
                    "call": [
                        "participant.name",
                        "framework.DisplayAddress",                      
                        "call.RemoteName",
                        "call.State",
                        "call.QueueName",
                        "framework.CallTimeElapsed",
                        "participant.TicketNumber"
                    ],
                    "callback": [
                        "participant.name",
                        "framework.DisplayAddress",                        
                        "call.RemoteName",
                        "call.State",
                        "call.QueueName",
                        "framework.CallTimeElapsed",
                        "participant.TicketNumber"
                    ],
                    "chat": [
                        "framework.DisplayAddress",
                        "call.RemoteName",
                        "participant.motivo_chat",
                        "participant.codice_fiscale",
                        "call.State",
                        "call.QueueName",
                        "framework.CallTimeElapsed"
                    ],
                    "email": [
                        "participant.customer_name",
                        "call.RemoteName",
                        "participant.motivo_chat",
                        "participant.codice_fiscale",
                        "call.State",
                        "call.QueueName",
                        "framework.CallTimeElapsed"
                    ]
                }
            },
            theme: {
                primary: "#HHH",
                text: "#FFF"
            }
        },
        clientIds: {
            "mypurecloud.de": "2850f585-583d-4c3d-8dfc-2ff77aa41c11"
        },
        helpLinks: {}
    };
    logsf.info("params : ", params);
    var url = `https://apps.${softphoneSettings.PEF_GC_ENVIRONMENT}/crm/softphoneGenericCRM/index.html?request_configuration=true&crm_domain=${window.location.origin}&full_PEF=true`;
    logsf.info("url : ", url);
    var config = {
        context: window,
        layoutType: "frame",
        integrationType: "pure-embeddable",
        url: url,
        auth: auth,
        pefParams: params
    };
    iwscore.initCTI(config);
    iwscore.enableCTI();
}
function loadPure() {
    var auth = {
        environment: softphoneSettings.PEF_GC_ENVIRONMENT,
        notReadyPresenceId: softphoneSettings.PEF_NOT_READY_ID,
        onQueuePresenceId: softphoneSettings.PEF_ON_QUEUE_ID
    };
    var params = "?crm_domain=" + window.location.origin;
    params += "&dedicatedLoginWindow=" + softphoneSettings.PEF_DEDICATED_LOGIN_WINDOW;
    params += "&enableCallLogs=" + softphoneSettings.PEF_ENABLE_CALL_LOGS;
    params += "&hideCallLogContact=" + softphoneSettings.PEF_HIDE_CALL_LOG_CONTACT;
    params += "&hideCallLogRelation=" + softphoneSettings.PEF_HIDE_CALL_LOG_RELATION;
    params += "&hideCallLogSubject=" + softphoneSettings.PEF_HIDE_CALL_LOG_SUBJECT;
    params += "&hideWebRTCPopUpOption=" + softphoneSettings.PEF_HIDE_WEB_RTC_POP_UP_OPTION;
    params += "&embedWebRTCByDefault=" + softphoneSettings.PEF_EMBED_WEB_RTC_BY_DEFAULT;
    logsf.info("params : ", params);
    iwscore.initCTI({
        context: window,
        layoutType: "frame",
        integrationType: "pure-embeddable",
        url: "https://apps.mypurecloud.com/crm/softphoneGenericCRM/index.html" + params,
        auth: auth
    });
    iwscore.enableCTI();
}
function loadWWE() {
    iwscore.initCTI({
        context: window,
        integrationType: "wwe",
        layoutType: "frame",
        url: softphoneSettings.wweUrl
    });
    iwscore.enableCTI();
}
