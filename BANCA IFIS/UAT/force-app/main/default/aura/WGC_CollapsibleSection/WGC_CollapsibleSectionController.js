({
    handleSectionHeaderClick : function(component, event, helper) {
        event.preventDefault();
        event.stopPropagation();

        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));

        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, "slds-is-open");
    }
})