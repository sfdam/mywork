({
	showSpinner: function (cmp, event) {
		console.log('CAVVVVVV');
		var spinner = cmp.find("mySpinner");
		console.log('spinner', spinner);
        $A.util.removeClass(spinner, "slds-hide");

    },

    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
})