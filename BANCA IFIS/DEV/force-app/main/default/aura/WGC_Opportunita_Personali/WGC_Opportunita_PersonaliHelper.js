({
    initData: function(component) {
        var h = this;
        this.callServer(component, "c.getCurrentYearAndMonthData", function(result){
            if (result.success) {
                console.log('XXX QUA');
                console.log(result);
                component.set("v.budgetYear", result.data[0].budgetYear);
                component.set("v.currentYear", result.data[0].currentYear);
                component.set("v.accordatoYear", new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format((result.data[0].accordatoYear ? result.data[0].accordatoYear : 0)));
                component.set("v.budgetMonth", result.data[0].budgetMonth);
                component.set("v.currentMonth", result.data[0].currentMonth);
                component.set("v.accordatoMonth", new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format((result.data[0].accordatoMonth ? result.data[0].accordatoMonth : 0)));
            }
        }, {});
    }
})