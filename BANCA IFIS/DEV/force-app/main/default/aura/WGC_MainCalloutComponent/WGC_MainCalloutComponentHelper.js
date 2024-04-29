({
    isFastFinanceProfile: function (component){
        var action = component.get("c.getUserProfile");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var risposta = response.getReturnValue();
                if(risposta.includes("Valutazione Fast Finance")){
                    component.set("v.isFastFinance",true);
                }
            }
        });

        $A.enqueueAction(action);
    }
})