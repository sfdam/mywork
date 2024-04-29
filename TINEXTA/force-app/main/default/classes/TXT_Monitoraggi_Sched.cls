public without sharing class TXT_Monitoraggi_Sched implements Schedulable {
    
    public List<Map<String,String>> note_REA;
    public Integer nPag;
    public String ticketId;

    public TXT_Monitoraggi_Sched(List<Map<String,String>> note_REA, Integer nPag, String ticketId) {
        this.note_REA = note_REA;
        this.nPag = nPag;
        this.ticketId = ticketId;
    }

    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new TXT_Monitoraggi(note_REA, nPag, ticketId));
        // TXT_Monitoraggi_Sched.abort(ctx.getTriggerId());
    }

    // @future
    // public static void abort(Id jobId){
    //     System.abortJob(jobId);
    // }
}