public class Schedule {
    public datetime start{get; set;}
    public datetime endd{get; set;}
    public String type{get; set;}
    public String rule{get; set;}
    
     public Schedule(String startTime, String endTime, String type, String rule){
        String today = datetime.now().format('yyyy-MM-dd');
        this.start = datetime.valueOf(today + ' ' + startTime);
        this.endd = datetime.valueOf(today + ' ' + endTime);
        this.type = type;
        this.rule = rule;
    }
    //open : now >= open.START && now < open.END && now >= closed.START &&  closed.END < open.END ) 
    public Boolean isNext(){
        datetime now = datetime.now();  
        //Boolean result = now >= this.start && now < this.endd;
        Boolean result = now < this.endd;
        if ( result && type == 'open' ){
            result = checkInterval();
        }
       
        return result;
    }
    
    public Boolean isInRange(){
        datetime now = datetime.now();  
        Boolean result = now >= this.start && now < this.endd;
        if ( result && type == 'open' ){
            result = checkInterval();
        }
       
        return result;
    }
    
    public String getOpening(){
        return '09:00-20:30';
    }
    
    public Boolean isClosed(){
        datetime now = datetime.now();
        if(this.start < now && this.endd >= now) {
         System.debug('CLOSED');
            return true;
        }
        return false;
    }
    
    public Boolean isOpen(){
        datetime now = datetime.now();
        if(checkInterval() && this.start < now && this.endd > now) return true;
        return false;
    }
    
    public Boolean checkInterval(){
        datetime now = datetime.now();
        String nowDate = now.format('E').toUpperCase().substring(0,2);
        String today = now.format('dd').replaceFirst('^0+','');
        String frequence, interval, byMonthDay,byMonth;
        List<String> byDay;
        
        for(String r : this.rule.split(';')){
            switch on r.split('=')[0] {
                when 'FREQ' {       
                    frequence = r.split('=')[1];
                }   
                when 'INTERVAL' {       
                    interval = r.split('=')[1];
                }
                when 'BYDAY' {      
                    byDay = r.split('=')[1].split(',');
                }
                when 'BYMONTHDAY' {       
                    byMonthDay = r.split('=')[1];
                }
                when 'BYMONTH' {          
                    byMonth = r.split('=')[1];
                }
            }
        }
    //"rrule": "FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR"
        if(frequence != null && interval == '1'){
            switch on frequence {
                when 'WEEKLY' {     
                    if(byDay.contains(nowDate)) return true;
                }   
             /*   when 'MONTHLY' {      
                    if(byMonthDay == today) rule = true;
                }*/
                when 'YEARLY' {     
                    String month = now.format('MM').replaceFirst('^0+','');
                    if(byMonthDay == today && byMonth == month) return true;
                } 
            }   
        }       
        return false;
    }
}