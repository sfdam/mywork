public class WGC_Chart_Callable implements Callable {

    //CALLABLE METHODS
    
    public class CallableResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String msg;
        @AuraEnabled public Boolean success;

        public CallableResponse(){
            this.data = new List<Object>();
            this.msg = '';
            this.success = true;
        }
    }

    //Add more method to get and manipulate data for the charts

    public CallableResponse call(String action, Map<String, Object> args) {
        switch on action {
          when 'Account_Posizione_Cliente'{
            return WGC_Chart_Controller.Account_Posizione_Cliente(args);
          }
          when 'Account_Posizione_OutstandingDeb'{
            return WGC_Chart_Controller.Account_Posizione_OutstandingDeb(args);
          }
          when 'Account_Posizione_PlafondDeb'{
            return WGC_Chart_Controller.Account_Posizione_PlafondDeb(args);
          }
          when 'Account_Monitoraggio_Impiego'{
            return WGC_Chart_Controller.Account_Monitoraggio_Impiego(args);
          }
          when 'Account_Monitoraggio_Mdi'{
            return WGC_Chart_Controller.Account_Monitoraggio_Mdi(args);
          }
          when 'Account_Monitoraggio_TurnoverCliente'{
            return WGC_Chart_Controller.Account_Monitoraggio_TurnoverCliente(args);
          }
          when 'Account_Monitoraggio_Outstanding'{
            return WGC_Chart_Controller.Account_Monitoraggio_Outstanding(args);
          }
          when 'Account_Monitoraggio_Plafond'{
            return WGC_Chart_Controller.Account_Monitoraggio_Plafond(args);
          }
          when 'Account_Monitoraggio_TurnoverDebitore'{
            return WGC_Chart_Controller.Account_Monitoraggio_TurnoverDebitore(args);
          }
          when 'Opportunity_Monitoraggio_Redditivita'{
            return WGC_Chart_Controller.Opportunity_Monitoraggio_Redditivita(args);
          }
          when 'Opportunity_Monitoraggio_Volumi'{
            return WGC_Chart_Controller.Opportunity_Monitoraggio_Volumi(args);
          }
          when 'Tab_Monitoraggio_Impiego'{
            return WGC_Chart_Controller.Tab_Monitoraggio_Impiego(args);
          }
          when 'Tab_Monitoraggio_Turnover'{
            return WGC_Chart_Controller.Tab_Monitoraggio_Turnover(args);
          }
          when 'Tab_Monitoraggio_MDI'{
            return WGC_Chart_Controller.Tab_Monitoraggio_MDI(args);
          }
          when 'Base_Clienti_HP'{
            return WGC_Chart_Controller.Base_Clienti_HP(args);
          }
          when 'Clienti_Operativi_Factoring'{
            return WGC_Chart_Controller.Clienti_Operativi_Factoring(args);
          }
          when else {
            throw new Ex.GenericException('Method not implemented');
          }
        }
    }
}