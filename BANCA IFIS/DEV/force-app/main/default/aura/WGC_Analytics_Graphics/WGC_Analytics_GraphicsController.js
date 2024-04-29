({
	doInit : function(component, event, helper) {
        if(window.innerWidth < 480){
          component.set('v.iPhone', true);
        }
        var flip = component.get('v.Flip');
        if(flip == 'disattivo') component.set('v.IsCollapsed', false);

        helper.apex(component, event, 'getUserInformation', {})
            .then(function (result) {
                console.log('SV result Analytics: ', result);
                component.set('v.currentUser', result.data[0].userInfo);

            }).finally($A.getCallback(function () {

              var filter = component.get('v.Filtro');
              let result = (filter) ? filter.match(/\#\#\#(.*?)\#\#\#/ig) : null;

              if(result){
                  result.forEach(function(element) {
                      let expression = element.replace(/###/g, '');
                      switch(expression) {
                        case 'userId':
                          // code block
                          filter = filter.replace(/###userId###/g, component.get('v.currentUser').Id);
                          break;
                        case 'currentYear':
                          // code block
                          filter = filter.replace(/###currentYear###/g, $A.localizationService.formatDate(new Date(), "YYYY"));
                          break;
                        case 'NDGutente':
                          // code block
                          filter = filter.replace(/###NDGutente###/g, component.get('v.currentUser').NDGGruppo__c);
                          break;
                        case 'recordId':
                          // code block
                          filter = filter.replace(/###recordId###/g, component.get('v.recordId'));
                          break;
                        default:
                          // code block
                      }
                  });    
              }      
              
              console.log(filter);
              component.set('v.Filtro', filter);
              component.set('v.calculateParametersInFilter', true);
                
            }));
	},
    
    collapse: function (component, event, helper) {
        component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));
    },

    navigateToComponent: function(component, event, helper){
      var evt = $A.get("e.force:navigateToComponent");
      
      // if(component.get("v.title")=="BASE CLIENTI"){
      //   evt.setParams({
      //     componentDef: "c:WGC_BaseClienti_DetailComponent",
      //     componentAttributes: {
      //         title: "Le tue opportunità"
      //     }
      //   });
      //   evt.fire();
      // }
      // else if(component.get("v.title")=="MONITORAGGIO"){
        var navigator = component.find("navService");
        //"type": "standard__navItemPage", "attributes": { "apiName": "MyCustomTabName" }
        var pg = {
          "type": "standard__navItemPage",
          "attributes": {
            "apiName": component.get('v.TabApiName')
          }
        };
        navigator.navigate(pg);  
        // }
      //alert(component.get("v.title"));
    }, 
})