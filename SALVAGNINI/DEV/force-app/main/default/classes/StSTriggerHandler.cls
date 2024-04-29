public class StSTriggerHandler {
    public static void sendRecords(List<String> recordIds){ 
         
        string networkId = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection
                            where ConnectionStatus = 'Accepted' LIMIT 1]?.Id;
        List<PartnerNetworkRecordConnection> PNRecordList = new List<PartnerNetworkRecordConnection>();
        for(string recordId  : recordIds){
            PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
            newrecord.ConnectionId = networkId;
            newrecord.LocalRecordId = recordId;
            //newrecord.RelatedRecords = 'Contact';
            //newrecord.SendClosedTasks = true;
            //newrecord.SendOpenTasks = true;
            PNRecordList.add(newrecord);
        }
        insert PNRecordList;
    }
}