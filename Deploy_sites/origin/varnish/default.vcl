vcl 4.0;

import directors;

backend nginx {
    .host = "127.0.0.1";
    .port = "82";
    .probe = {
        .url = "/test.tst";
        .timeout = 1s;
        .interval = 1s;
        .window = 3;
        .threshold = 1;
    }
}

backend default {
    .host = "127.0.0.1";
    .port = "83";
    .probe = {
        .url = "/";
        .timeout = 1s;
        .interval = 1s;
        .window = 3;
        .threshold = 1;
    }
}

sub vcl_init {
    new test = directors.round_robin();
    test.add_backend(nginx);
    test.add_backend(default);
}

sub vcl_recv {

    if (req.http.host ~ "example.com") {
        if (req.http.cookie ~ "^\s*$") {
           unset req.http.cookie;
           }
        if (req.http.Cache-Control ~ "(?i)no-cache") {
           return (pass);
           }
        if (req.url ~ "(7z|avi|bz2|flac|flv|gz|mka|mkv|mov|mp3|mp4|mpeg|png|mpg|ogg|ogm|opus|rar|tar|tgz|tbz|txz|wav|webm|xz|zip)") {
           unset req.http.Cookie;
           return (hash);
           } else {
           return (pass);
           } 
    unset req.http.X-Forwarded-For;
    set req.http.X-Forwarded-For = client.ip;
    set req.backend_hint = test.backend();
    }
}


sub vcl_backend_response {
    if (bereq.url ~ "(7z|avi|bz2|flac|flv|gz|mka|mkv|mov|mp3|mp4|mpeg|png|mpg|ogg|ogm|opus|rar|tar|tgz|tbz|txz|wav|webm|xz|zip)") {
        unset beresp.http.cookie;
        set beresp.http.cache-control = "static, max-age=600";
        set beresp.storage_hint = "static";
        set beresp.http.x-storage = "static";
        set beresp.ttl = 5m;
        }
}

sub vcl_deliver {
    unset resp.http.Via;
    unset resp.http.X-Whatever;
    unset resp.http.X-Varnish;
    unset resp.http.Age;
}
