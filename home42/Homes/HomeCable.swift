// home42/HomeCable.swift
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ *
+
+      :::       ::::::::
+     :+:       :+:    :+:
+    +:+   +:+        +:+
+   +#+   +:+       +#+
+  +#+#+#+#+#+    +#+
+       #+#     #+#
+      ###    ######## H O M E
+
+   Copyright Antoine Feuerstein. All rights reserved.
+
* ++++++++++++++++++++++++++++++++++++++++++++++++++++ */

import Foundation
import UIKit

/*
 Origin: https://meta.intra.42.fr
 Pragma: no-cache
 Sec-WebSocket-Protocol: actioncable-v1-json, actioncable-unsupported
 Sec-WebSocket-Key: 6N/Y9IaX5gomozNO15/o1w==
 Sec-WebSocket-Version: 13
 Upgrade: websocket
 Sec-WebSocket-Extensions: permessage-deflate
 User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15
 Cache-Control: no-cache
 Connection: Upgrade
 */

final class HomeCable: NSObject, URLSessionWebSocketDelegate {
    
    private let webSocketTask: URLSessionWebSocketTask
    
    override init() {
        let request = "wss://profile.intra.42.fr/cable".request
        
        self.webSocketTask = URLSession.shared.webSocketTask(with: request)
       
        /* ***
         ** **
         *** */
        super.init()
    
        self.webSocketTask.resume()
        
    }
    
    // "{\"command\":\"subscribe\",\"identifier\":\"{\\\"channel\\\":\\\"LocationChannel\\\",\\\"user_id\\\":20091}\"}"
    // -> "{\"identifier\":\"{\\\"channel\\\":\\\"LocationChannel\\\",\\\"user_id\\\":20091}\",\"type\":\"confirm_subscription\"}"
    // -> "{\"type\":\"ping\",\"message\":1644050414}"
    // -> "{\"identifier\":\"{\\\"channel\\\":\\\"LocationChannel\\\",\\\"user_id\\\":20091}\",\"message\":{\"location\":{\"id\":14021525,\"user_id\":106914,\"begin_at\":\"2022-02-05 08:40:15 UTC\",\"end_at\":null,\"primary\":true,\"host\":\"c7r2s9\",\"campus_id\":29,\"login\":\"haneulee\",\"image\":\"https://cdn.intra.42.fr/users/haneulee.jpg\"},\"id\":16652020}}" =
    
    deinit {
        self.webSocketTask.cancel()
    }
    
}
