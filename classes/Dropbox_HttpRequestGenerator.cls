public class Dropbox_HttpRequestGenerator {

    public static HTTPResponse generateRequest(String endpoint, String method, Map<String, String> headers, String body, Blob blobBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        for (String key : headers.keySet()) req.setHeader(key, headers.get(key));
        if (body != null) req.setBody(body);
        if (blobBody != null) req.setBodyAsBlob(blobBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

}