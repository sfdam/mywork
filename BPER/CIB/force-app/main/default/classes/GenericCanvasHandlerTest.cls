@isTest
private class GenericCanvasHandlerTest {
    
    @isTest
    static void testDefaultMockValues(){
        // Test handler using the default mock RenderContext Canvas.Test creates
        GenericCanvasHandler handler = new GenericCanvasHandler();
        Canvas.Test.testCanvasLifecycle(handler,null);
    }
    
    @isTest
    static void testOverriddenAppValues(){
        // Test handler with some mock application context values
        Map<String,String> appValues = new Map<String,String>();
        appValues.put(Canvas.Test.KEY_CANVAS_URL,'https://myserver.com:6000/myAppPath');
        appValues.put(Canvas.Test.KEY_VERSION,'3.0');
        
        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(appValues,null);
        GenericCanvasHandler handler = new GenericCanvasHandler();
        Canvas.Test.testCanvasLifecycle(handler,mock);
    }
    
    @isTest
    static void testOverriddenEnvironmentValues(){
        // Test handler with some mock environment context values
        Map<String,String> envValues = new Map<String,String>();
        envValues.put(Canvas.Test.KEY_DISPLAY_LOCATION,'Chatter');
        envValues.put(Canvas.Test.KEY_LOCATION_URL,
            'https://myinstance.salesforce.com/_ui/core/chatter/ui/ChatterPage');
        GenericCanvasHandler handler = new GenericCanvasHandler();
        handler.excludeContextTypes();
        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(null,envValues);
        // Directly update the mock RenderContext and set the custom parameters
        mock.getEnvironmentContext().setParametersAsJSON(
            '{\"one\":1,\"two\":2,\"bool\":true,\"stringVal\":\"some string\"}');
        Canvas.Test.testCanvasLifecycle(handler,mock);
    }
}