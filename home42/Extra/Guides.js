// home42/Guides.js
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

const https = require('https')
const querystring = require('querystring')
const fs = require('fs')

const client_id = 'CLIENT_UID'
const client_secret = 'CLIENT_SECRET'

function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}

function saveElementsInFile(filename, elements) {
    console.log('>', filename, elements.length);
    fs.writeFileSync(filename, JSON.stringify(elements));
}

async function basicRequest(options, params) {
    return new Promise((resolve, reject) => {
        var data = ""
        const req = https.request(options, (res) => {
            res.on('data', (newData) => {
                data += newData
            })
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data))
                }
                catch(error) {
                    console.log(options, params)
                    console.log(data)
                    reject(error)
                }
            })
        })

        req.on('error', (error) => {
            reject(error)
        })
        req.write(params);
        req.end()
    })
}

async function authRequest() {
    const params = JSON.stringify({
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
    })
    const options = {
        host: 'api.intra.42.fr',
        path: '/oauth/token',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': params.length
        }
    }
    return basicRequest(options, params);
}

const guides = [
    {
        'title': 'guides.cluster.title',
        'description': 'guides.cluster',
        'video': 'https://www.youtube.com/watch?v=UWMElUxbP-E',
        'version': '1.0',
        'coalitionId': '45'
        // id: 45 - name: "The Federation" - slug: "42cursus-paris-the-federation"
    },
    {
        'title': 'guides.languages.title',
        'description': 'guides.languages',
        'video': 'https://www.youtube.com/watch?v=zQe1UKE_dSc',
        'version': '1.0',
        'coalitionId': '46'
        // id: 46 - name: "The Alliance" - slug: "42cursus-paris-the-alliance"
    }
    /*,
    {
        'title': 'guides.cluster.title',
        'description': 'guides.cluster',
        'filename': 'add_cluster.pdf',
        'version': '1.0',
        'coalitionId': '48'
        //id: 48 - name: "The Assembly" - slug: "42cursus-paris-the-assembly"
    },
    {
        'title': 'guides.cluster.title',
        'description': 'guides.cluster',
        'filename': 'add_cluster.pdf',
        'version': '1.0',
        'coalitionId': '47'
        //id: 47 - name: "The Order" - slug: "42cursus-paris-the-order"
    }*/
]

async function makeRequest(token, path) {
    const options = {
        host: 'api.intra.42.fr',
        path: path, //+ '?' + querystring.unescape(querystring.stringify(params)),
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        }
    }
    return basicRequest(options, "");
}

async function main() {
    try {
        var token = await authRequest()
        var guide;
        var elements = [];
        var newElement;
        var coalition;

        if (token.access_token === undefined) {
            throw Error(JSON.stringify(token))
        }
        token = token.access_token
        console.log("/oauth/token", token)

        for (const index in guides) {
            guide = guides[index];
            coalition = await makeRequest(token, '/v2/coalitions/' + guide.coalitionId);
            newElement = {
                'title': guide.title,
                'description': guide.description,
                'video': guide.video,
                'version': guide.version,
                'coalition': coalition
            }
            elements.push(newElement)
        }
        await saveElementsInFile('res/guides/guides.json', elements);
    }
    catch(e) {
        console.log("error", e)
        process.exit(1)
    }
}

main()
