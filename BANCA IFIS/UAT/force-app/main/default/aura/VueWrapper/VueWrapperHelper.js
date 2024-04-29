({
  initVue: function (c, helper) {
    if (c.get('v.scriptsLoaded') && c.get('v.rendered')) {
      var result = []
      var action = c.get('c.getSessionIdServerUrl')
      action.setParams({})
      action.setCallback(this, function (response) {
        var state = response.getState()
        if (c.isValid() && state === 'SUCCESS') {
          result = response.getReturnValue()
        } else {
          console.log('remoteCall sId error', response.error)
        }
        helper.buildComponent(c, result)
      })
      $A.enqueueAction(action)
    }
  },
  buildComponent: function (c, result) {
    console.log('BUILDING VUE COMPONENT')
    var appName = c.get('v.appName')
    var params = c.get('v.params')
    var rId = c.get('v.recordId')
    if (appName && Apps[appName]) {
      Apps.setVueLanguage(c.get('v.langLocale'))
      c.find('theAppInner').getElement().innerHTML = '<div></div>'
      c.set('v.theView', new Apps[appName]({ //eslint-disable-line
        methods: {
          $api: Apps.SldsApiProxy($A, c)
        },
        data: {
          labels: this.gestisciLabels(appName),
          recordId: rId,
          params: params,
          metadataApi: new Apps.MetadataApi({ //eslint-disable-line
            sessionId: result[0],
            useProxy: false,
            serverUrl: result[1]
          }),
          taImagesUrl: $A.get('$Resource.TAimages')
        },
        el: c.find('theAppInner').getElement().getElementsByTagName('div')[0],
        created: function () {
          console.log('APP CREATED')
          this.setSvgPath(c.get('v.staticUrl') + '/assets')
        }
      }))
    }
  },
  gestisciLabels: function (appName) {
    switch (appName) {
      case 'ListeHpApp':
        return {
          Dettagli: $A.get('$Label.c.Dettagli'),
          Luogo: $A.get('$Label.c.Luogo'),
          MieiAppuntamenti: $A.get('$Label.c.MieiAppuntamenti'),
          MieiContattiTel: $A.get('$Label.c.MieiContattiTel'),
          NullaPerOggi: $A.get('$Label.c.NullaPerOggi'),
          Oggi: $A.get('$Label.c.Oggi'),
          Ora: $A.get('$La,bel.c.Ora'),
          Referente: $A.get('$Label.c.Referente')
        }
      case 'RecentActivitiesApp':
        return {
          AssegnatoA: $A.get('$Label.c.AssegnatoA'),
          CommentiEsito: $A.get('$Label.c.CommentiEsito'),
          EsitoLivello: $A.get('$Label.c.EsitoLivello'),
          NessunaAttivitaPresente: $A.get('$Label.c.NessunaAttivitaPresente')
        }
      default:
        return {}
    }
  }
})