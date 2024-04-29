({
  getPendingItemsList: function (component) {
    var action = component.get('c.getPendingItems')
    action.setCallback(this, function (actionResult) {
      // console.log("ecco: "+JSON.stringify(actionResult.getReturnValue()));
      component.set('v.items', actionResult.getReturnValue())
    })
    $A.enqueueAction(action) //eslint-disable-line
  }
})