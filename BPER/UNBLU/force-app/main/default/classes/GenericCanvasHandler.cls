public class GenericCanvasHandler implements Canvas.CanvasLifecycleHandler {
    
    public Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();
        return excluded;
    }
    
    public void onRender(Canvas.RenderContext renderContext) {
        System.debug('GenericCanvasHandler - onRender');
        Canvas.ApplicationContext app = renderContext.getApplicationContext();
        Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();
        system.debug('GenericCanvasHandler- app.getCanvasUrl(): '+app.getCanvasUrl());
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(env.getParametersAsJSON());
        System.debug('Environment Context custom parameters json: ' + env.getParametersAsJSON());
        String queryParams='';
        
        
        if (!params.isEmpty()) {
            System.debug('AAA queryParams '+params);
            queryParams = (String)params.get('urlCanvas');
            System.debug('AAA queryParams '+queryParams);
            try {
                app.setCanvasUrlPath(queryParams);
        	} catch (CanvasException e) {
            	// Display error to user by throwing a new CanvasRenderException
            	throw new Canvas.CanvasRenderException(e.getMessage());
        	}
        }
    }
}