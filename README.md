# NGINX HTTP2 Fingerprinting

A fork of NGINX, implementing [Akamai's whitepaper on HTTP2 client fingerprinting](https://blogs.akamai.com/2017/06/passive-http2-client-fingerprinting-white-paper.html).

## Usage
```nginx
http {
    server {
        listen              443 ssl http2;
        server_name         localhost;
        ssl_certificate     cert.pem;
        ssl_certificate_key rsa.key;

        location / {
            # Add the fingerprint string to the forwarded headers
            proxy_set_header X-Http-Fingerprint $http2_fingerprint;
            # Proxy the request to the origin
            proxy_pass http://localhost:8000;
        }
    }
}
```

An example client fingerprint looks like `1:65536;4:131072;5:16384|12517377|3:0:0:201|m,p,a,s`. You can learn more about the format [by reading Akamai's research paper.](https://www.akamai.com/uk/en/multimedia/documents/white-paper/passive-fingerprinting-of-http2-clients-white-paper.pdf)

Because http2 connections are reused between multiple requests, the [priority frames](https://datatracker.ietf.org/doc/html/rfc7540#section-5.3) in the fingerprint might change between requests made on the same reused connection. I'm not sure if this is an intended effect or if the researchers at Akamai intended to only fingerprint the priority of frames sent in the initial connection.  It's currently set to only collect data of the initial connection so fingerprints don't change within the same connection and shouldn't, in theory, change between new connections made by the same client either.

## Variables

`$http2_fingerprint` Contains the formatted fingerprint for the connection.

## Limitations

You must be using SSL with at least a self-signed cert. Not really a limitation of the implementation, but browsers generally don't support http2 over cleartext for good reason.

You can generate a new self-signed certificate pair for testing with:
> openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout rsa.key -out cert.pem

Directives are not supported, so every request gets frame information collected even if the `$http2_fingerprint` variable is not used, which could be a potential performance problem.

Connections must be upgraded to http2 in order for the fingerprint to get collected, otherwise the variable is omitted.

This module is absolutely not production-ready; chances are there are multiple bombs waiting to go off in the code somewhere. Use with caution, preferably not at all.

## Why a fork and not a module?
NGINX doesn't collect frame details of http2 connections after parsing them, so a module cannot construct the fingerprint just by injecting itself into the end of the request lifecycle.
