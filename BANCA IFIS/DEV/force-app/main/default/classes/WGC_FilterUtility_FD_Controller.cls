public class WGC_FilterUtility_FD_Controller {

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT Id, Name, Profile.Name, Alias FROM User WHERE Id =: UserInfo.getUserId()];    
    }

    @AuraEnabled
    public static WrapperResponse getFilterValues(){
        WrapperResponse response = new WrapperResponse();

        try{
            List<User> uList = new List<User>([SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null]);
            Set<String> teamSet = new Set<String>();
            List<Filter> fListUtenti = new List<Filter>();
            List<Filter> fListTeam = new List<Filter>();

            for(User u : uList){
                Filter f = new Filter(String.valueOf(u.Id), u.Name, false);
                fListUtenti.add(f);

                //Setto anche i team
                teamSet.add(u.WGC_Team_Filo_Diretto__c);
            }

            for(String team : teamSet){
                Filter f = new Filter(team, team, true);
                fListTeam.add(f);
            }

            FilterGroup gruppoUtenti = new FilterGroup('Per Utente', fListUtenti);

            FilterGroup gruppoTeam = new FilterGroup('Per Team', fListTeam);

            List<FilterGroup> listaFinal = new List<FilterGroup>();
            listaFinal.add(gruppoTeam);
            listaFinal.add(gruppoUtenti);

            response.data.add(listaFinal);

        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class FilterGroup{
        @AuraEnabled public String gruppo;
        @AuraEnabled public List<Filter> listaFiltri;

        public FilterGroup(){
            this.gruppo = '';
            this.listaFiltri = new List<Filter>();
        }

        public FilterGroup(String gruppo, List<Filter> filtri){
            this.gruppo = gruppo;
            this.listaFiltri = filtri;
        }
    }

    public class Filter{
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean isTeam;

        public Filter(){
            this.value = '';
            this.label = '';
            this.isTeam = false;
        }

        public Filter(String value, String label, Boolean isTeam){
            this.value = value;
            this.label = label;
            this.isTeam = isTeam;
        }
    }
}