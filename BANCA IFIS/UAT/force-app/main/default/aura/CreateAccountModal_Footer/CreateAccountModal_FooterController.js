({
    doInit : function (component, event, helper) {
        helper.init(component);
    },

    cancel : function (component, event, helper) {
        //closes the modal or popover from the component
        //component.find("overlayLib").notifyClose();
        helper.modalFlowPage(component, event, 'cancel');
    },

    next : function (component, event, helper) {
        helper.modalFlowPage(component, event, 'next');
    },

    back : function (component, event, helper) {
        helper.modalFlowPage(component, event, 'back');
    },
    
    submit : function (component, event, helper) {
        helper.modalFlowPage(component, event, 'submit');
    },

    manageB2F : function(component, event, helper) {
        // manage Body event
        var json = JSON.parse(event.getParam("json"));

        console.log('JSON');
        console.log(json);
        switch (json.action) {
            case 'validate':
                component.set("v.isSearchNextValid", json.isValid);
                break;
            case 'navigate-to':
                helper.goTo(component, json.target);
                helper.iterateOptions(component, component.get("v.options").find(function(op){return op.title == component.get("v.page");}));
                break;
            case 'confirm-action':
                if (json.target == 'next')
                    helper.next(component, true);
                if (json.target == 'back')
                    helper.back(component, true);

                helper.iterateOptions(component, component.get("v.options").find(function(op){return op.title == component.get("v.page");}));
                break;
        }
    }
})