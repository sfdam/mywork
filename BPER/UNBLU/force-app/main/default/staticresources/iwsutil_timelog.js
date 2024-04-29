class TimeLogUtil {
    constructor() {
    }
    createConnectorEventTimeLog(event) {
        var callTime = Date.now();
        var AgentId = event.AgentID ? event.AgentID : '';
        var objToCreate = { interactionId: event.InteractionID, callTime: callTime, agentId: AgentId, callType: event.CallType, mediaType: event.MediaType };
        ConnectorEntityController.createConnectorEventTimeLog(objToCreate, function (result, req) {
            console.log("createConnectorEventTimeLog result : ", result);
            console.log("createConnectorEventTimeLog req : ", req);
            if (req.statusCode == 200) {
                console.log("req.statusCode : ", req.statusCode);
            }
        });
    }
    updateConnectorEventTimeLog(msg) {
        if (!msg || !msg.EVENT) {
            console.log("invalid object, and event are mandatory,returning ...");
            return;
        }
        var callTime = Date.now();
        var objToUpdate = { interactionId: msg.InteractionID, callTime: callTime };
        switch (msg.EVENT) {
            case 'EventEstablished':
            case 'EmailEventEstablished':
            case 'ChatEventEstablished':
                objToUpdate.field = 'softphone_it__Established_Time__c';
                objToUpdate.caseId = msg.caseId || msg.attachdata.case_id;
                objToUpdate.contactId = msg.contactId || msg.attachdata.contact_id;
                objToUpdate.parentId = msg.parentId || msg.attachdata.parent_id;
                break;
            case 'EventReleased':
            case 'EmailEventReleased':
            case 'ChatEventReleased':
                objToUpdate.field = 'softphone_it__Released_Time__c';
                objToUpdate.state = msg.interactionState || (msg.CallState && msg.CallState == 22 ? "rejected" : "answered");
                objToUpdate.caseId = msg.caseId || msg.attachdata.case_id;
                objToUpdate.contactId = msg.contactId || msg.attachdata.contact_id;
                objToUpdate.parentId = msg.parentId || msg.attachdata.parent_id;
                if (msg.SourceMsg) {
                    objToUpdate.interactionDuration = msg.SourceMsg.interactionDurationSeconds;
                    objToUpdate.totalAcdDuration = msg.SourceMsg.totalAcdDurationSeconds;
                    objToUpdate.totalIvrDuration = msg.SourceMsg.totalIvrDurationSeconds;
                }
                break;
            case 'EventMarkDone':
            case 'EmailEventMarkDone':
            case 'ChatEventMarkDone':
                objToUpdate.field = 'softphone_it__MarkDone_Time__c';
                objToUpdate.disposition = msg.disposition || msg.attachdata.DispositionCode || "";
                if (msg.SourceMsg) {
                    objToUpdate.dispositionDuration = msg.SourceMsg.dispositionDurationSeconds;
                }
                break;
            case 'EventAbandoned':
            case 'EmailEventAbandoned':
            case 'ChatEventAbandoned':
                objToUpdate.field = 'softphone_it__Released_Time__c';
                objToUpdate.state = "abandoned";
                break;
        }
        ConnectorEntityController.updateConnectorEventTimeLog(objToUpdate, function (result, req) {
            console.log("updateConnectorEventTimeLog result : ", result);
            console.log("updateConnectorEventTimeLog req : ", req);
            if (req.statusCode == 200) {
                console.log("req.statusCode : ", req.statusCode);
            }
        });
    }
}
const timeLogUtil = new TimeLogUtil();
