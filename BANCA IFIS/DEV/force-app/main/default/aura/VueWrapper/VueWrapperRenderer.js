({
  render: function (c, h) {
    var ret = this.superRender()
    c.set('v.rendered', true)
    h.initVue(c, h)
    return ret
  }
})