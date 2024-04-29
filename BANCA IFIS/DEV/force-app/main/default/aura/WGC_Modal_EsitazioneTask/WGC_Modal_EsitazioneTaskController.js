({
    doInit : function(component, event, helper) {
        helper.loadLabels(component);
        helper.loadPicklistValues(component);
    },

    onChangePicklist : function(component, event, helper){
        helper.onChangePicklist(component, event);
        helper.calculateValid(component);
    },

    onChangeField : function(component, event, helper){
        helper.calculateValid(component);
    }
})