({
	init : function(component) {
		var h = this;
		this.callServer(component, "c.getTotalAndPerMonthData", function (result) {
			if (result.success) {
				component.set("v.totaleAccordatoINT", (result.data[0].totaleAccordato ? new Intl.NumberFormat('it-IT', {}).format(parseInt(result.data[0].totaleAccordato)) : 0));
				component.set("v.totaleAccordatoDEC", (result.data[0].totaleAccordato ? (((result.data[0].totaleAccordato % 1).toFixed(2) * 100).toFixed(0) < 10 ? "0"+String(((result.data[0].totaleAccordato % 1).toFixed(2) * 100).toFixed(0)) : String(((result.data[0].totaleAccordato % 1).toFixed(2) * 100).toFixed(0))) : 0));
				component.set("v.totaleOppty", result.data[0].totaleOppty);
				component.set("v.totaleAccordatoPesatoINT", (result.data[0].totaleAccordatoPesato ? new Intl.NumberFormat('it-IT', {}).format(parseInt(result.data[0].totaleAccordatoPesato)) : 0));
				component.set("v.totaleAccordatoPesatoDEC", (result.data[0].totaleAccordatoPesato ? (((result.data[0].totaleAccordatoPesato % 1).toFixed(2) * 100).toFixed(0) < 10 ? "0"+String(((result.data[0].totaleAccordatoPesato % 1).toFixed(2) * 100).toFixed(0)) : String(((result.data[0].totaleAccordatoPesato % 1).toFixed(2) * 100).toFixed(0))) : 0));
				

				let perMonthData = result.data[0].perMonthData;
				perMonthData.forEach(pmd => {
					let month = new Date(Date.UTC(2000, pmd.month-1, 1, 0, 0, 0));
					pmd.month = month.toLocaleDateString('it-IT', {month: "long"}).toUpperCase();
                    pmd.amount = new Intl.NumberFormat('it-IT', { maximumSignificantDigits: 2 }).format(pmd.amount / 1000);
                    pmd.pesato = new Intl.NumberFormat('it-IT', { maximumSignificantDigits: 2 }).format(pmd.pesato / 1000);
                	// TODO: GESTIONE M,K,... PER VISUALIZZAZIONE AMOUNT/PESATO PER MONTH
				});
				component.set("v.perMonthData", perMonthData);
				
                // component.set("v.currentYear", result.data.currentYear);
                // component.set("v.accordatoYear", new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format((result.data.accordatoYear ? result.data.accordatoYear : 0)));
                // component.set("v.budgetMonth", result.data.budgetMonth);
                // component.set("v.currentMonth", result.data.currentMonth);
                // component.set("v.accordatoMonth", new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format((result.data.accordatoMonth ? result.data.accordatoMonth : 0)));
            }
            else
                h.showToast(component, "Errore", result.message, "error");
		}, {});

		
	}
})