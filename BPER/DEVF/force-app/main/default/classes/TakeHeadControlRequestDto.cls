public class TakeHeadControlRequestDto {
    
    public Recipient recipient;
    
    public TakeHeadControlRequestDto(String recipientId){
        recipient = new Recipient(recipientId);
    }
    
    public String toJson(){
        JSONGenerator gen = JSON.createGenerator(true); 
        
		gen.writeObject(this);
        
        return gen.getAsString();
    }
    
    public class Recipient {
        public string id;
        
        public Recipient(String id){
            this.id = id;
        }
    }
    
}