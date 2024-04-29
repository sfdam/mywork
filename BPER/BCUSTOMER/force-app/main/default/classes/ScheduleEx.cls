public class ScheduleEx {
    private static String returnFormat = 'HH:mm';
    public datetime openStart{get; set;}
    public datetime openEnd{get; set;}
    public datetime closedStart{get; set;}
    public datetime closedEnd{get; set;}
    public Boolean valid{get; set;}
    public Boolean open{get; set;}
    
    
     public ScheduleEx(Schedule open, Schedule closed){
          System.debug('ScheduleEx , open=' + open 
                      + ',closed='+closed);
         
        datetime now = datetime.now();
         if ( open != null ){
            this.openStart = open.start;
            this.openEnd = open.endd;
         }
         if ( closed != null ) {
             this.closedStart = closed.start;
            this.closedEnd = closed.endd;
         }
         //now >= open.START && now < open.END && now >= closed.START &&  closed.END < open.END )
         //now >= open.START && now < open.END && ( now < closed.START && now > closed.END ) 
         
         //this.valid = now >= this.openStart && now < this.openEnd; 
         //
         this.valid = now < this.openEnd;
          this.open = now >= this.openStart && this.valid;
         System.debug('ScheduleEx , valid=' + this.valid 
                      + ',open='+this.open);
         
         if ( this.valid && this.closedStart != null && this.closedEnd != null ){
            
             this.valid =  this.closedEnd < this.openEnd;
             this.open = now < this.closedStart;
              System.debug('ScheduleEx inner, valid=' + this.valid 
                      + ',open='+this.open);
         } 
         
         System.debug('ScheduleEx built, openStart=' + this.openStart 
                      + ',openEnd='+this.openEnd
                      +' closedStart='+this.closedStart
                      +',closedEnd='+this.closedEnd
                      +',valid='+this.valid
                      +',open='+this.open);
         //17:44:37:853 USER_DEBUG [42]|DEBUG|ScheduleEx built, 
         //openStart=2022-03-17 23:00:00,
         //openEnd=2022-03-18 19:00:00 
         //closedStart=2022-03-18 16:45:00,
         //closedEnd=2022-03-18 16:48:00,
         //valid=false,
         //open=false
     }
//!isValid = undefined
//now < closed.START? now
//now >= closed.START && now < closed.END? closed.END
//now >= closed.END? now    
    public datetime getScheduleStart(){
        if ( !this.valid ) return null;
        if ( this.closedStart == null ) return this.openStart;
        datetime now = datetime.now();
        System.debug('getScheduleStart, now='+now+',this.closedStart='+ this.closedStart + ',this.closedEnd='+this.closedEnd);
       
        if (now < this.closedStart || now >= this.closedEnd ) return now;
        if ( now >= this.closedStart && now < this.closedEnd ) return this.closedEnd;
        return null;
        
    }
 //!isValid = undefined
//now >= closed.END ? open.END
//now < closed.END  && now < closed.START ? closed.START
//now < closed.END  && now >= closed.START ? open.END   
// now=2022-02-04 15:49:24,this.closedStart=null,this.closedEnd=null
    public datetime getScheduleEnd(){
        if ( !this.valid ) return null;
        if ( this.closedStart == null ) return this.openEnd;
        datetime now = datetime.now();
        System.debug('getScheduleEnd, now='+now+',this.closedStart='+ this.closedStart 
                     + ',this.closedEnd='+this.closedEnd
                     + ',this.openEnd='+this.openEnd);
   
        if (now >= this.closedEnd ) return this.openEnd;
        if ( now < this.closedEnd && now < this.closedStart ) return this.closedStart;
        if ( now < this.closedEnd && now >= this.closedStart ) return this.openEnd;
        return null;
    }
    
    public String getCurrentSchedule(){
        datetime startTime = getScheduleStart();
        datetime endTime = getScheduleEnd();
        System.debug('getCurrentSchedule, startTime='+startTime+',endTime=' + endTime);
        if ( startTime != null && endTime != null ){
            return startTime.format(returnFormat) + '-' + endTime.format(returnFormat);
        }
        return null;
    }
    
    public  Map<String, Object> toJSON(){
        Map<String, Object> result = new Map<String, Object>();
        result.put('open', false);
        if ( this.valid){
            result.put('open', this.open);
            result.put('schedule',getCurrentSchedule());
            result.put('start',getScheduleStart());
            result.put('end',getScheduleEnd());
        }
        return result;
    }
}