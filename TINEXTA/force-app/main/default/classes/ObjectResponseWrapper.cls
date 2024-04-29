global class ObjectResponseWrapper extends ResponseWrapper {
    global String message{get;set;}
    global Boolean success{get;set;}
    global Map<String,Object> data{get;set;}

    global ObjectResponseWrapper(){
        this.message = '';
        this.success = true;
    }
}