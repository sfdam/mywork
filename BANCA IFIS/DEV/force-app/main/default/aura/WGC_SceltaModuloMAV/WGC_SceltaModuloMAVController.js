({
    doInit: function(component, event, helper){
        const values = [
            {'label': 'In Bonis', 'value': 'CC'},
            {'label': 'Procedura', 'value': 'CE'}
        ];
 
        component.set('v.tipologiaMav', values);
    },

    selezionaTipologia : function(component, event, helper){
        var tipologia = component.get("v.tipologiaScelta");
        component.set("v.referenceAttribute", tipologia);
        component.find('overlayLib').notifyClose();
    },

    close : function(component, event, helper){
        component.find('overlayLib').notifyClose();
    },

    typeSelected : function(component, event, helper){
        component.set("v.disableButton",false);
    }
})