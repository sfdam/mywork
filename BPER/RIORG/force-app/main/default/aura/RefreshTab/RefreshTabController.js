({
    refreshTab: function(cmp, message, helper) {
        console.log("RefreshTab message", message);
        try {
            var payload = {"command": "refreshTab","id" : cmp.get("v.recordId")};
            console.log("calling messageChannelRefreshTab ,payload : ", payload);
            cmp.find("messageChannelRefreshTab").publish(payload);
        } catch (e) {
            console.log("RefreshTab Error : ", e)
        }
    }
})