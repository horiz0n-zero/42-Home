// home42/JSONResources.js
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

const client_id = 'API_UID'
const client_secret = 'API_SECRET'

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

const roots = [
    {
        'path': '/v2/expertises',
        'filename': 'res/json/expertises.json',
        'pageSize': 100
    },
    {
        'path': '/v2/campus',
        'filename': 'res/json/campus.json',
        'pageSize': 100
    },
    {
        'path': '/v2/blocs',
        'filename': 'res/json/blocs.json',
        'pageSize': 100
    },
    {
        'path': '/v2/products',
        'filename': 'res/json/products.json',
        'pageSize': 100
    },
    {
        'path': '/v2/titles',
        'filename': 'res/json/titles.json',
        'pageSize': 100
    },
    {
        'path': '/v2/groups',
        'filename': 'res/json/groups.json',
        'pageSize': 100
    },
    {
        'path': '/v2/skills',
        'filename': 'res/json/skills.json',
        'pageSize': 100
    },
    {
        'path': '/v2/projects',
        'filename': 'res/json/projects.json',
        'pageSize': 30
    },
    {
        'path': '/v2/achievements',
        'filename': 'res/json/achievements.json',
        'pageSize': 100
    },
    {
        'path': '/v2/languages',
        'filename': 'res/json/languages.json',
        'pageSize': 100
    }
]

async function makeRequest(token, path, pageSize, pageIndex) {
    const params = {
        'page[size]': pageSize,
        'page[number]': pageIndex
    }
    const options = {
        host: 'api.intra.42.fr',
        path: path + '?' + querystring.unescape(querystring.stringify(params)),
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
        var root;
        var pageIndex;
        var elements;
        var newElements;
        var counter = 0;

        if (token.access_token === undefined) {
            throw Error(JSON.stringify(token))
        }
        token = token.access_token
        console.log("/oauth/token", token)

        for (const index in roots) {
            root = roots[index];
            pageIndex = 1;
            elements = undefined;
            while (true) {
                newElements = await makeRequest(token, root.path, root.pageSize, pageIndex);
                counter += 1;
                if (counter >= 8) {
                    counter = 0;
                    await sleep(1000);
                }
                if (elements === undefined)
                    elements = newElements;
                else
                    elements = elements.concat(newElements);
                console.log(root.path, elements.length);
                if (newElements.length == root.pageSize) {
                    pageIndex += 1
                    continue
                }
                else {
                    await saveElementsInFile(root.filename, elements)
                    break
                }
            }
        }
    }
    catch(e) {
        console.log("error", e)
        process.exit(1)
    }
}

main()
