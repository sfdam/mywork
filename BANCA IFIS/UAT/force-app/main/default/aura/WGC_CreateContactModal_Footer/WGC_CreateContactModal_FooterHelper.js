({
    init : function (component) {
        component.set("v.page", component.get("v.options")[0].title);
        component.set("v.optionsLength", component.get("v.options").length);
        this.iterateOptions(component, component.get("v.options").find(function(op){return op.title == component.get("v.options")[0].title;}));
    },

    iterateOptions : function (component, options) {
        // iterate through options and find the currentPage options
        // then manage the buttons options
        var buttonOptions = options.buttons;

        if (buttonOptions != undefined) {
            buttonOptions.forEach(bo => {
                var cssClass = "";

                if (bo.visible != undefined && bo.visible === false)
                    cssClass = "slds-hide";

                component.set("v."+bo.type+"Classes", cssClass);
            });
        }
    },

    modalFlowPage : function (component, event, direction) {
        var target;

        if (direction == 'next') // NEXT ACTION
            target = this.next(component, false);
        else if (direction == 'back') // BACK ACTION
            target = this.back(component, false);
        else if (direction == 'cancel') // CANCEL ACTION
            target = this.cancel(component, false);
        else if (direction == 'submit') // SUBMIT ACTION
            target = this.submit(component, false);
		// da gestire target = null
        var MAE = $A.get("e.c:ModalFooter2BodyEvent");
        MAE.setParams({ "json" : JSON.stringify({ "action" : direction , "target" : target }) });
        MAE.fire();
    },

    next : function (component, isConfirmed) {
        var options = component.get("v.options");
        var flow = [];
        options.forEach(element => { flow.push(element.title); });
        console.log(flow);
        var breadcrumb = component.get("v.breadcrumb");
        var target = null;
        var index = flow.indexOf(component.get("v.page"));

        if ( (index+1) <= flow.length ) {
            index++;
            target = flow[index];
            breadcrumb.push(component.get("v.page"));

            if ( isConfirmed == true ) {
                component.set("v.breadcrumb", breadcrumb);
                component.set("v.page", target);
            }
        }
        
        return target;
    },
                                    
    submit : function (component, isConfirmed) {
        return 'end';
    },
                                    
    goTo : function (component, navPage) {
        var breadcrumb = component.get("v.breadcrumb");
        breadcrumb.push(component.get("v.page"));
        component.set("v.breadcrumb", breadcrumb);
        component.set("v.page", navPage);
    },

    back : function (component, isConfirmed) {
        var options = component.get("v.options");
        var flow = [];
        options.forEach(element => { flow.push(element.title); });
        var breadcrumb = component.get("v.breadcrumb");
        var target = null;
        var index = flow.indexOf(component.get("v.page"));

        if (breadcrumb.length > 0) {
            target = breadcrumb.pop();

            if ( isConfirmed == true ) {
                component.set("v.breadcrumb", breadcrumb);
                component.set("v.page", target);
            }    
        }
        
        return target;
    },
                                    
    cancel : function (component, isConfirmed) {
        
        return null;
    }
})