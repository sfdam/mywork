window._snapinsSnippetSettingsFile = (function() {
console.log("Snippet settings file loaded.");	// Logs that the snippet settings file was loaded successfully

embedded_svc.snippetSettingsFile.extraPrechatInfo = [{
  "entityFieldMaps": [{
    "doCreate":false,
"doFind":true,
"fieldName":"FirstName",
"isExactMatch":true,
"label":"Nome"
}, {
"doCreate":false,
"doFind":true,
"fieldName":"LastName",
"isExactMatch":true,
"label":"Cognome"
  }, 
  {
    "doCreate":false,
    "doFind":true,
    "fieldName":"Email",
    "isExactMatch":true,
    "label":"Email"
  }],
  "entityName":"Contact"
}];
})();
