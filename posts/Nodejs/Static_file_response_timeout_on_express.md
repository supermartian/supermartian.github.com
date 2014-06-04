date: 2014-06-04
title: Static file response timeout on Express 

This was a really weird issue.

These days I've trying [MEAN.io](http://mean.io/). BTW this is a really decent fullstack solution, which allows you to build a site entirely in Javascript. Things happened when I finished a demo by the instructions shown in the document, I was not able to open the site on the browser, either Chrome and Safari cannot load the page. When I stopped the loading process, in the console of Nodejs it showed:

    GET /public/system/lib/angular-resource/angular-resource.js 200 1487.247 ms - -
    GET /public/system/lib/jquery/dist/jquery.min.js 200 1489.591 ms - -
    GET /public/system/lib/angular-bootstrap/ui-bootstrap.js 200 1419.806 ms - -
    GET /public/system/lib/angular-mocks/angular-mocks.js 200 1518.837 ms - -
    GET /public/system/lib/angular-ui-router/release/angular-ui-router.js 200 1493.526 ms - -
    GET /public/system/lib/angular/angular.js 200 1548.968 ms - -

It seemed that the server was able to send a response but cannot return the content of these files, so it stalled here until it reached its timeout. Then I tried to fetch these files using curl, to my suprise curl successfully grabbed those! So it has to be something wrong with the request header.(In curl's head: It's the rest of the world that is evil, I'm the only justice.)

After trying different modifications to the request header by using [ModHeader](https://chrome.google.com/webstore/detail/modheader/idgpnmonknjnojddfkpgkljpfnnfcklj), it turned out that something was wrong with the compression after I deleted this:

    Accept-Encoding:gzip,deflate,sdch

The middleware which is in charge of compression is [compression](https://github.com/expressjs/compression), the version I was using that has this issue is 1.0.4. So I just update it to the newest version(1.0.6), then problem solved.

I took a look at the commit history, the author updates very frequently. The commit that solved the problem should be [@3fc6b35199](https://github.com/expressjs/compression/commit/3fc6b3519934a6692023c2da62bcd6ce676ffb30).
