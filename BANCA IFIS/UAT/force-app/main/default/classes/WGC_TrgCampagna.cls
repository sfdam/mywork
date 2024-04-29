public class WGC_TrgCampagna {

    //Metodo per fare l'update di una global picklist dopo l'inserimento di una nuova campagna (Tramite future callout)
    @Future(callout=true)
    public static void updateCampaignPicklist(){
        List<Map<String,Object>> newCustomValues = new List<Map<String,Object>>();
        List<Campaign> cmps = new List<Campaign>();

        try{
            cmps = [SELECT Id, Name, IsActive FROM Campaign ORDER BY Name LIMIT 50000];

            for(Campaign c : cmps){
                Map<String,Object> pickvalue = createCustomValue(c.Name, c.Name.normalizeSpace());
                System.debug('pickvalue: '+pickvalue);
                if(!newCustomValues.contains(pickvalue)) newCustomValues.add(pickvalue);
            }

            String fieldDef = '{"Metadata":{"customValue":'+JSON.serialize(newCustomValues)+',"description":null,"masterLabel":"CampagnaFD","sorted":false,"urls":null},"FullName":"CampagnaFD"}';
            System.debug('@@@ fieldDef ' + fieldDef);
            HttpRequest req = new HttpRequest();
            req.setBody(fieldDef);
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setEndpoint('callout:TestNamedCredential/services/data/v41.0/tooling/sobjects/GlobalValueSet/'+Impostazioni__c.getOrgDefaults().Id_Campagna_FD__c+'?_HttpMethod=PATCH');
            req.setMethod('POST');
            Http httpreq = new Http();
            HttpResponse res  = httpreq.send(req);

            System.debug('newCustomValues: '+newCustomValues);
            updateAssignRt(newCustomValues);
        }
        catch(Exception e){
            System.debug('@@@ eccezione ' + e.getMessage() + ' -- ' + e.getStackTraceString());
        }
    }

    public static Map<String,Object> createCustomValue(String label, String valueName){
        Map<String,Object> customValue = new Map<String,Object>();
        customValue.put('color',null);
        customValue.put('default',false);
        customValue.put('description',null);
        customValue.put('isActive',true);
        customValue.put('label',label);
        customValue.put('urls',null);
        customValue.put('valueName',valueName);

        return customValue;
    }

    public static void updateAssignRt(List<Map<String,Object>> picklistValues){

        for(Map<String,Object> val : picklistValues){
            val.remove('label');
            val.remove('urls');
        }

        RecordType RtDettaglioVisite = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'WGC_Dettaglio_Visite__c' AND DeveloperName = 'Dettaglio_Visita' LIMIT 1];
        String bodyReq = '{"attributes": {"type": "RecordType","url": "/services/data/v41.0/tooling/sobjects/RecordType/'+RtDettaglioVisite.Id+'"},"Metadata": {"active": true,"businessProcess": null,"compactLayoutAssignment": null,"description": null,"label": "Dettaglio Visita","picklistValues": [{"picklist": "Campagna_Aggiornata__c","values": '+JSON.serialize(picklistValues)+'}]},"FullName": "WGC_Dettaglio_Visite__c.Dettaglio_Visita"}';
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint('callout:TestNamedCredential/services/data/v41.0/tooling/sobjects/RecordType/'+RtDettaglioVisite.Id+'?_HttpMethod=PATCH');
        req.setMethod('POST');
        req.setBody(bodyReq);
        Http httpreq = new Http();
        HttpResponse res  = httpreq.send(req);
        System.debug('@@@ req.getBody ' + req.getBody());
    }
}