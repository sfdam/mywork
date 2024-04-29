({
  doInit: function (cmp, event, helper) {
    helper.getPendingItemsList(cmp)
  },
  openRequest: function (cmp, event, helper) {
    var id = event.target.getAttribute('data-data')
    var navEvt = $A.get('e.force:navigateToSObject') //eslint-disable-line
    navEvt.setParams({ 'recordId': id })
    navEvt.fire()
  }
})