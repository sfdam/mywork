({
  scriptsLoaded: function (c, e, h) {
    c.set('v.scriptsLoaded', true)
    h.initVue(c, h)
  },
  handleDestroy: function (c, e, h) {
    var theView = c.get('v.theView')
    if (theView) theView.$destroy()
  },
  refreshView: function (c, e) {
    var theView = c.get('v.theView')
    if (theView) theView.$emit('refreshView')
  }
})