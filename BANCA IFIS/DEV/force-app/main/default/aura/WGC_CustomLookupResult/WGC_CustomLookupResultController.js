({
  doInit: function (component, event, helper) {
    // get the selected record from list 
    var showField = component.get('v.showField').split('|');
    var record = component.get('v.oRecord');
    console.log(showField);
    var finalValue = '';
    if (showField.length > 0 && showField[0] != '') {
      showField.forEach(function (element) {
        console.log(element);
        if(element == ' '){
          console.log('DENTRO');
          finalValue = finalValue + ' - ';
        } else {
          finalValue = finalValue + record[element];
        }
      });
    } else {
      finalValue = finalValue + record['Name'];
    }

    component.set('v.endValue', finalValue);

  },

  selectRecord: function (component, event, helper) {
    // get the selected record from list  
    var getSelectRecord = component.get("v.oRecord");
    console.log('selectRecord');
    console.log(getSelectRecord);

    // call the event   
    var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
    compEvent.setParams({ "recordByEvent": getSelectRecord });
    // fire the event  
    compEvent.fire();
  },
})