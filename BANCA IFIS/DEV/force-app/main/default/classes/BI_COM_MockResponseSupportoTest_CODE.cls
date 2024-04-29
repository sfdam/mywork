@isTest
public class BI_COM_MockResponseSupportoTest_CODE  {

  public BI_COM_MockResponseSupportoTest_CODE() {
  }

 public class HTTPCalloutMockImplementazione implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected List<String> bodies;
    protected Map<String, String> responseHeaders;
    protected Integer step = 0;

    public HTTPCalloutMockImplementazione(Integer code, String status, String body, Map<String, String> responseHeaders) {
      this(code, status, new List<String> {body}, responseHeaders);
    }

    public HTTPCalloutMockImplementazione(Integer code, String status, List<String> bodies, Map<String, String> responseHeaders) {
      this.code = code;
      this.status = status;
      this.bodies = bodies;
      this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      for (String key : this.responseHeaders.keySet()) {
        res.setHeader(key, this.responseHeaders.get(key));
      }
      res.setBody(this.bodies[step]);
      if (step + 1 < this.bodies.size())
        step++;
      res.setStatusCode(this.code);
      res.setStatus(this.status);
      return res;
    }

  }

  public static HttpCalloutMock creaMockRispostaOk(String body) {
    return creaMockRispostaOk(new List<String> {body});
  }

  public static HttpCalloutMock creaMockRispostaOk(List<String> bodies) {
    // Specifico i valori che riceverò dal mock fingendo di far chiamate HTTP
    Map<String, String> responseHeaders = new Map<String, String>();
    responseHeaders.put('Content-Type', 'application/json');
    return new HTTPCalloutMockImplementazione(200, 'OK', bodies, responseHeaders);
  }

}