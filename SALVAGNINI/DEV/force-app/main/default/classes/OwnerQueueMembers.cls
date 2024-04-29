public without sharing class OwnerQueueMembers {
    @AuraEnabled
     
    public static List<User> OwnerQueueMember(id recordId) {

        system.debug(' sono nel metodo e pesco l\' id');
        List<User> ListUser;

        //List<id> idQueue= [select id from Group where Type = 'Queue'].id;

        List<Group> GroupQueue= [select id from Group where Type = 'Queue'];

        List<id> idQueue= new List<id>();
        
        for(Group u: GroupQueue){
            idQueue.add(u.id);
        }

        String IdPrefix = String.valueOf(recordId).substring(0,3);
        boolean OwnerIsQueue =false;

            if (IdPrefix == 'a00'){
                system.debug(' l\' oggetto è una SER');

                id RecordOwner= [select OwnerId from SER__c where id =:recordId].OwnerId;

                //system.debug('L\'id da ricercare è '  + RecordOwner);

                OwnerIsQueue = serchidInList (idQueue, RecordOwner);

                //system.debug('trovato l\'id, ' + OwnerIsQueue);

                if(OwnerIsQueue){
                
                    //id CodaOwnerId = [select id, type from Group where id =: recordId and Type = 'Queue'].id;
                    
                    List<GroupMember> ListaUtenti = [Select UserOrGroupId From GroupMember where GroupId =:RecordOwner];

                    system.debug('la lista utenti è ' +ListaUtenti);
                        List<Id> userIds = new List<Id>();

                        for(GroupMember u: ListaUtenti){
                            userIds.add(u.UserOrGroupId);
                        }
                        ListUser = [select firstName, lastName from User where id IN :userIds];
                }else{
                    system.debug('l\'owner non è una Coda');
                }
            
            } else if (IdPrefix == '00B'){
                system.debug(' l\' oggetto è una Task');

                id RecordOwner= [select OwnerId from Task where id =:recordId].id;

                OwnerIsQueue = serchidInList (idQueue, RecordOwner);

                if(OwnerIsQueue){
                
                    //id CodaOwnerId = [select id, type from Group where id =: recordId and Type = 'Queue'].id;
                    List<GroupMember> ListaUtenti = [Select UserOrGroupId From GroupMember where GroupId =:RecordOwner];
                    
                    List<Id> userIds = new List<Id>();
                    
                    for(GroupMember u: ListaUtenti){
                        userIds.add(u.UserOrGroupId);
                    }
                    ListUser = [select firstName, lastName from User where id IN :userIds];
                    
                }
            else{
                system.debug('l\'owner non è una Coda');
            }
        }

        return ListUser;
    }

    private static Boolean serchidInList (list<id> idQueue, id RecordOwner){

        system.debug('sto cercando l\' id della quote');
        Boolean trovato= false;
        for( id identificativo : idQueue){
            if( identificativo == RecordOwner){
                trovato= true;
                break;
            }
        }

        return trovato;
    }
}