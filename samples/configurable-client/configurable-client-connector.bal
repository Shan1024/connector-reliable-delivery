import ballerina.net.reliable.storejms;
import ballerina.net.http;
import ballerina.net.reliable.processor;
import ballerina.net.reliable.httpr;

@http:configuration {
    basePath:"/hello"
}
service<http> sampleService {
    processor:GuaranteedProcessor guaranteedConfig = {
             interval:2000,
             retryCount:5,
             config:{ "initialContextFactory":"org.apache.activemq.jndi.ActiveMQInitialContextFactory",
                        "providerUrl":"tcp://localhost:61616",
                        "connectionFactoryName":"QueueConnectionFactory"
                    },
             store: storejms:store,
             retrieve: storejms:retrieve,
             handler: httpr:handle
                                                     };
    boolean status = guaranteedConfig.startProcessor();

    @http:resourceConfig {
        methods:["POST"],
        path:"/sayHello"
    }
    resource sayHello (http:Request req, http:Response res) {
        endpoint<httpr:HttpGuaranteedClient> httpEp {
            create httpr:HttpGuaranteedClient("http://localhost:9999", {}, guaranteedConfig);
        }

        // create an endpoint with configurable httpr client connector and invoke the respective http method
        var response,_= httpEp.get("/hello/abc", req);

        // response will say whether the request is safely received or not
        _=res.forward(response);
    }

}