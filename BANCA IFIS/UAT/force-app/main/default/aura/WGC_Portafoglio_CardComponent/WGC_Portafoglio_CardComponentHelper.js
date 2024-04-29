({
	CountNumberOfTab : function(component) {
        var count = component.get("v.NumTab");
        var tab1 = component.get("v.Tab_1");
        var tab2 = component.get("v.Tab_2");
        var tab3 = component.get("v.Tab_3");
        var tab4 = component.get("v.Tab_4");

        if(typeof tab1 !== 'undefined'){
            count = count + 1;
        }
        if(typeof tab2 !== 'undefined'){
            count = count + 1;
        }
        if(typeof tab3 !== 'undefined'){
            count = count + 1;
        }
        if(typeof tab4 !== 'undefined'){
            count = count + 1;
        }

        component.set("v.NumTab", count);
        component.set("v.WidthTab", 100/count);
        
	}
})