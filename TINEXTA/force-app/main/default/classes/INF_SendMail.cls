public class INF_SendMail {
    public static void sendOppScheduleMail(Map<Id,OpportunityLineItemSchedule> schedMap){

        List<Id> oppLineItemIds = new List<Id>();
        for(OpportunityLineItemSchedule item : schedMap.values()){
            oppLineItemIds.add(item.OpportunityLineItemId);
        }
        Messaging.reserveSingleEmailCapacity(5);
        String BodyData = '';
        List<Id> oppIds = new List<Id>();
        Map<String,sObject> OppLineItemMap = Utilities.keyby([SELECT Id,Name, Description,OpportunityId,ProductName__c FROM OpportunityLineItem WHERE Id IN: oppLineItemIds ],'Id');
        for(sObject oppIt : OppLineItemMap.values()){
          oppIds.add((Id)oppIt.get('OpportunityId'));
        }
        Map<String,sObject> OppMap = Utilities.keyby([SELECT Id,Name,StageName,OwnerId,Note__c, Reseller_Partner__c, Referral_Partner_InfoCert__c, AccountId,OpportunityNumber__c, CicloAttivoFascicolo__c, Owner.Email, Famiglia_Prodotto__c, Codice_Cliente__c, Codice_Cliente__r.Name FROM Opportunity WHERE Id IN: oppIds ],'AccountId');
        Map<String,sObject> accMap = Utilities.keyby([SELECT Id,Name,Codice_Cliente_X3__c, Responsabile_Infocert__c FROM Account WHERE Id IN: OppMap.keySet() ],'Id');
        Map<string,sObject> slaveMap = Utilities.keyby([SELECT Id,Name,Account__c,Id_Esterno__c,Codice_Cliente_X3__c FROM Slave_Data__c WHERE Account__c IN: accMap.keySet() ],'Id');
        Set<Id> PartnerIds = new Set<Id>();
        Set<Id> UserList = new Set<Id>();
        for(sObject opp : OppMap.values()){
          PartnerIds.add((Id)opp.get('Reseller_Partner__c'));
          PartnerIds.add((Id)opp.get('Referral_Partner_InfoCert__c'));
          UserList.add((Id)opp.get('OwnerId'));
        }
        for(sObject acc : accMap.values()){
          UserList.add((Id)acc.get('Responsabile_Infocert__c'));
        }
      

        
        Map<string,sObject> PartnerMap = Utilities.keyby([SELECT Id,Name,Responsabile_Infocert__c FROM Account WHERE Id IN: PartnerIds ],'Id');
        for(sObject part : PartnerMap.values()){
          UserList.add((Id)part.get('Responsabile_Infocert__c'));
        }

        Map<String,sObject> userMap = Utilities.keyby([SELECT Id,Name FROM User WHERE Id IN: UserList ],'Id');

        string Quantity;
        string heading = '';
        String moreInfo = '';
        Boolean fatturaPartner;
        String RespInfoPartner;
        String PartnerName;
        String Note;
        String CodCliX3 = '';
        Decimal totalRevenue= 0;
        Decimal prezzoTotaleOpp = 0;
        Boolean referral= false;
        Boolean reseller= false;
        String subject='';
        List<Schema.PicklistEntry> oppStageValues = Opportunity.StageName.getDescribe().getPicklistValues();
        Map<String,String> stageValuesMap = new Map<String,String>();
        for(Schema.PicklistEntry a : oppStageValues){
          if(a.isActive()){
            stageValuesMap.put(a.getValue(),a.getLabel());
          }
        }
       /* for(sObject acc : accMap.values()){
          fatturaPartner = (OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c') != null || OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c') != null) ? 'Sì' : 'No';
          if( OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c') != null){
            PartnerName = (String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c')).get('Name');
            RespInfoPartner = (String)userMap.get((String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c')).get('Responsabile_Infocert__c')).get('Name');
          }else if( OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c') != null){
            RespInfoPartner = (String)userMap.get((String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c')).get('Responsabile_Infocert__c')).get('Name');            
            PartnerName = '-';
          }else{
            RespInfoPartner = '-';
            PartnerName = '-';
          }
          for(sObject slave : slaveMap.values()){
            if(slave.get('Account__c')==acc.get('Id')){
              CodCliX3 = CodCliX3 + (String)slave.get('Id_Esterno__c');              
            }
          }
          if(CodCliX3 =='null')CodCliX3='-';
          Note = OppMap.get((String)acc.get('Id')).get('Note__c') != null ? (String)OppMap.get((String)acc.get('Id')).get('Note__c') : '-';
          
          heading = heading + '<ul>'+
                      '<li>Account: '+ acc.get('Name')+ '</li>'+
                      '<li>Codice Cliente: '+ CodCliX3+ '</li>'+
                      '<li>Note: '+ Note + '</li>'+
                      '<li>Reseller Partner : '+ PartnerName + '</li>'+
                      '<li>Fattura Partner : '+ fatturaPartner + '</li>'+
                      '</ul>';
          moreInfo = moreInfo + '<ul>'+
                        '<li>Opportunità: '+  OppMap.get((String)acc.get('Id')).get('Name')+ '</li>'+
                        '<li>Stage: '+ OppMap.get((String)acc.get('Id')).get('StageName')+ '</li>'+
                        '<li>Titolare: '+ (String)userMap.get((String)OppMap.get((String)acc.get('Id')).get('OwnerId')).get('Name') + '</li>'+
                        '<li>Responsabile Infocert Account: '+(String)userMap.get((String)acc.get('Responsabile_Infocert__c')).get('Name') + '</li>'+
                        '<li>Responsabile Infocert Partner: '+ RespInfoPartner + '</li>'+
                        '</ul>';
        }
        */

      //Creazione Ticket VTE Fatturazione
      String partnerFattura = '';
      Boolean fatturaDaPartner = false;
      Id oppId;
      
      for(sObject acc : accMap.values()){
          fatturaPartner = (OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c') != null || OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c') != null) ? true : false;
          if( OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c') != null){
            reseller=true;
            PartnerName = (String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c')).get('Name');
            RespInfoPartner = (String)userMap.get((String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Reseller_Partner__c')).get('Responsabile_Infocert__c')).get('Name');
          }else if( OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c') != null){
            referral=true;
            RespInfoPartner = (String)userMap.get((String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c')).get('Responsabile_Infocert__c')).get('Name');            
            PartnerName = (String)PartnerMap.get((String)OppMap.get((String)acc.get('Id')).get('Referral_Partner_InfoCert__c')).get('Name');
          }else{
            RespInfoPartner = '-';
            PartnerName = '-';
          }

          Opportunity opp = (Opportunity)OppMap.get((String)acc.get('Id'));

          CodCliX3 = opp.Codice_Cliente__c != null ? opp.Codice_Cliente__r.Name : '';

          // for(sObject slave : slaveMap.values()){
          //   if(slave.get('Account__c')==acc.get('Id')){
          //     if((String)slave.get('Id_Esterno__c')!= null){
          //       CodCliX3 = CodCliX3 + (String)slave.get('Id_Esterno__c');
          //     }
              
          //     }              
          //   }
          //   CodCliX3.removeEnd(',');
          //   if(CodCliX3!=''){
          //       CodCliX3= ' con Codice Cliente X3 '+CodCliX3;
          // }

          if(CodCliX3 =='null')CodCliX3='-';
          Note = OppMap.get((String)acc.get('Id')).get('Note__c') != null ? 'con note: '+(String)OppMap.get((String)acc.get('Id')).get('Note__c') : '';
          
          
          subject = 'SF n. '+ OppMap.get((String)acc.get('Id')).get('OpportunityNumber__c')+' '+ acc.get('Name') ;
          oppId = (Id)OppMap.get((String)acc.get('Id')).get('Id');
          
          heading = '<p>'+
                      'Gentile Billing InfoCert,<br/><br/>'+
                      'è stata inviata una richiesta di fatturazione per l’Opportunità \''+  OppMap.get((String)acc.get('Id')).get('Name')+ '\' n°'+ OppMap.get((String)acc.get('Id')).get('OpportunityNumber__c')+
                      ' in Stato \''+stageValuesMap.get((String)OppMap.get((String)acc.get('Id')).get('StageName'))+ '\'  in titolarità a '+(String)userMap.get((String)OppMap.get((String)acc.get('Id')).get('OwnerId')).get('Name')+ note+'.'+ '<br/><br/>'+
                      'L’Opportunità è sul cliente \''+acc.get('Name')+'\' assegnato in Salesforce a '+(String)userMap.get((String)acc.get('Responsabile_Infocert__c')).get('Name') + ' ' + CodCliX3+'.'+ '<br/><br/>';
          if(fatturaPartner){
            if(reseller){
              heading+= 'Da fatturare al Partner \''+ PartnerName +'\' assegnato a '+RespInfoPartner+'.'+ '<br/><br/>';
              partnerFattura = 'Da fatturare al Partner \''+ PartnerName +'\' assegnato a '+RespInfoPartner+'.';
            }
            heading+='Fattura da Partner: Sì'+ '<br/><br/>';
            fatturaPartner = true;
            fatturaDaPartner = true;
          }
          else{
            heading+='Fattura da Partner: No'+ '<br/><br/>';
            fatturaPartner = false;
            fatturaDaPartner = false;
          }
          
          // if(OppMap.get((String)acc.get('Id')).get('CicloAttivoFascicolo__c')!=null ){
          //   heading += 'Link Sharepoint: '+'<a href="'+OppMap.get((String)acc.get('Id')).get('CicloAttivoFascicolo__c')+'">'+OppMap.get((String)acc.get('Id')).get('CicloAttivoFascicolo__c')+'</a>'+'<br/><br/>';
          // }else{
          //   heading += 'Link Sharepoint: '+'-'+'<br/><br/>';
          // }

          //SM - TEN Aggiunte informazioni per VTE Billing
          // heading += 'Id Opportunità: ' + (String)oppMap.get((String)acc.get('Id')).get('Id') + '<br/><br/>';
          // heading += 'Email Commerciale: ' + (String)oppMap.get((String)acc.get('Id')).getSobject('Owner').get('Email') + '<br/><br/>';
          // if(oppMap.get((String)acc.get('Id')).get('Famiglia_Prodotto__c') != null)
          //   heading += 'Famiglia Prodotto: ' + (String)oppMap.get((String)acc.get('Id')).get('Famiglia_Prodotto__c') + '<br/><br/>';
          // else
          //   heading += 'Famiglia Prodotto: - ' + '<br/><br/>';

            heading += 'Di seguito i dettagli di fatturazione.'+ '<br/><br/></p>';
        }


        for(sObject item : OppLineItemMap.values()){
          BodyData +=      '<table>'+
                              '<tr style="background-color: gainsboro;">'+
                                '<th width="30%">Nome Articolo</th>'+
                                '<th width="15%">Importo</th>'+                               
                                '<th width="20%">Data Pianificata</th>'+
                                '<th>Descrizione</th>'+
                                '<th>Commenti</th>'+                                
                              '</tr>';
          for(OpportunityLineItemSchedule schItem : schedMap.values()){
            if(schItem.OpportunityLineItemId == item.get('Id')){
              Quantity= schItem.Quantity != null ?   String.valueOf(schItem.Quantity) : '0';
              schItem.Description = schItem.Description != null ? schItem.Description : '-';
              String itemDescr = item.get('Description')!= null ? (String)item.get('Description') : '-';
              totalRevenue+= schItem.Revenue;
                BodyData = BodyData+ '<tr>'+
                                '<td>'+item.get('ProductName__c') + '</td>'+                                
                                '<td style="text-align: right;">'+ schItem.Revenue +'€'+'</td>'+                               
                                '<td>'+ schItem.ScheduleDate.day() + '/' + schItem.ScheduleDate.month() + '/' + schItem.ScheduleDate.year() +'</td>'+
                                '<td>'+ itemDescr +'</td>'+
                                '<td>'+ schItem.Description +'</td>'+
                                '</tr>';
            }
          }
          BodyData += '<tr style="background-color: gainsboro;">' +
                          '<td><strong>PREZZO TOTALE: </strong>'+ '</td>'+  
                          '<td style="text-align: right;"><strong>'+totalRevenue+ +'€'+'</strong></td>'+                        
                          '<td></td>'+
                          '<td></td>'+
                          '<td></td>'+
                      '</tr>'+
                    '</table>';
          prezzoTotaleOpp += totalRevenue;
          totalRevenue=0;
        }
        
        moreInfo = '<br/> <b>Prezzo totale articoli: ' + prezzoTotaleOpp + '<b/>';

        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // List<String> toAddresses = new List<String>{'andrean.lobo@infocert.it', 'mattia.vastalegna@tengroup.it'};
        // List<String> toAddresses = new List<String>{'katia.ragone@infocert.it'};
        // mail.setToAddresses(toAddresses);

        //SM - TEN Eliminata logica di utilizzo metadato per creazione ticket VTE
        sObject mailMdt = [SELECT DeveloperName,SendTo__c,CarbonCopy__c,BlindCarbonCopy__c FROM TXT_EmailAddresses__mdt WHERE DeveloperName = 'InfoCertFatturabile' LIMIT 1];

        List<String> toAddresses = ((String)mailMdt.get('SendTo__c')).split('\\|');
        //  // Assign the addresses for the To and CC lists to the mail object.
         mail.setToAddresses(toAddresses);

        // if(mailMdt.get('BlindCarbonCopy__c')!= null){
        //   List<String> bccAddresses = ((String)mailMdt.get('BlindCarbonCopy__c')).split('\\|');
        //   mail.setBccAddresses(bccAddresses);
        // }

        // if(mailMdt.get('CarbonCopy__c')!= null){
        //   List<String> ccAddresses = ((String)mailMdt.get('CarbonCopy__c')).split('\\|');
        //   mail.setCcAddresses(ccAddresses);
        // }  
        
       
        
        // Specify the address used when the recipients reply to the email. 
       // mail.setReplyTo('support@acme.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName(UserInfo.getName());
        
        // Specify the subject line for your email address.
        mail.setSubject(subject);
        
        // Set to True if you want to BCC yourself on the email.
       // mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
       // mail.setUseSignature(false);
        
        // Specify the text content of the email.
        //mail.setPlainTextBody('ciao');
        
        mail.setHtmlBody('<!DOCTYPE html>' +
                '<html>' +
                '<head>'+
                '<style>'+
                'table {'+
                  'font-family: arial, sans-serif;'+
                  'border-collapse: collapse;'+
                  'width: 100%;'+
                  'margin-bottom: 30px;'+
                '}'+
                
                'td, th {'+
                  'border: 1px solid #dddddd;'+
                  'text-align: left;'+
                  'padding: 8px;'+
                '}'+
                
                'tr:nth-child(even) {'+
                 ' background-color: #dddddd;'+
                '}'+
                '</style>'+
                '</head>'+
                '<body>'+
                heading+

                
                
                
                
                BodyData + 
                moreInfo+
                '<br/><br/>'+
                'Buona Giornata,'+
                '<br/><br/>'+
                
                UserInfo.getName()+

                
                '</body>'+
                '</html>');
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        //SM - Creazione Ticket VTE Fatturazione
        INF_integrationVTEController.createTicketFatturazione(oppId, heading+BodyData+moreInfo, fatturaDaPartner, partnerFattura, prezzoTotaleOpp);
    }

}