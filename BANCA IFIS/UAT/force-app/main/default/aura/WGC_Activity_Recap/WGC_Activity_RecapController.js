({
  doInit: function (component, event, helper) {
    // alert($A.get("$Browser.formFactor"));
    if (window.innerWidth < 480) {
      component.set("v.iPhone", true);
    } else {
      helper.initialize(component, event, helper);
    }
  },

  changeTab: function (component, event, helper) {
    var selected = event.currentTarget.getAttribute("data-tab");
    var idSelected = event.currentTarget.id;

    var a = component.find("container");

    a.forEach((item, index) => {
      if (index == idSelected) {
        $A.util.addClass(item, "active");
      } else {
        $A.util.removeClass(item, "active");
      }
    });

    var lista = component.get("v.dati");
    console.log("@@@ lista ", JSON.stringify(lista));

    for (var key in lista) {
      if (key == selected) {
        component.set("v.objectName", selected);
        component.set("v.listaDati", lista[key]);
      }
    }

    //console.log('@@@ selected first ' , selected);
  }
});