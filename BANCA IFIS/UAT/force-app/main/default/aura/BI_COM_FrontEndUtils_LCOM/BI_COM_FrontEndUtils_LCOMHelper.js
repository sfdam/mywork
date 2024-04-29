({
	showSpinner: function (cmp, event) {
		var spinner = cmp.find("mySpinner");
		var button = cmp.find("buttonUpdateFD");

		button.set('v.disabled',true);
		console.log('spinner', spinner);
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
		var spinner = cmp.find("mySpinner");
        var button = cmp.find("buttonUpdateFD");

		button.set('v.disabled',false);
        $A.util.addClass(spinner, "slds-hide");

    },
})