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
var counter = 0

const client_id = 'API_KEY_UID'
const client_secret = 'API_KEY_SECRET'

function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}

function saveElementsInFile(filename, elements, rootModel) {
    
    var cleanElements = [];
    
    function purify(element, model) {
        var clean = {}
        
        function purifyArray(arrayElements, arrayModel) {
            var results = []
            
            for (const arrayElement of arrayElements) {
                results.push(purify(arrayElement, arrayModel))
            }
            return results
        }
        
        for (const [key, value] of Object.entries(model)) {
            if (element[key] === undefined || element[key] === null) {
                continue
            }
            if (value.constructor === Object) {
                if (element[key].constructor === Array) {
                    clean[key] = purifyArray(element[key], value)
                }
                else {
                    clean[key] = purify(element[key], value)
                }
            }
            else {
                clean[key] = element[key]
            }
        }
        return clean
    }
    
    for (const element of elements) {
        cleanElements.push(purify(element, rootModel))
    }
    fs.writeFileSync(filename, JSON.stringify(cleanElements));
    console.log('>', filename, elements.length);
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

async function shopHandler(token, model) {
    var pageIndex;
    var elements;
    var newElements;
    var allcampus = JSON.parse(fs.readFileSync('res/json/campus.json'))
    const root = {}
    var allElements = []
    
    for (const index in allcampus) {
        campus = allcampus[index]
        pageIndex = 1;
        elements = undefined;
        while (true) {
            newElements = await makeRequest(token, `/v2/campus/${campus.id}/products`, 100, pageIndex);
            counter += 1;
            if (counter >= 8) {
                counter = 0;
                await sleep(1000);
            }
            if (elements === undefined)
                elements = newElements;
            else
                elements = elements.concat(newElements);
            console.log(`/v2/campus/${campus.id}/products`, elements.length);
            if (newElements.length == 100) {
                pageIndex += 1
                continue
            }
            else {
                allElements = allElements.concat(elements.map((element, index) => {
                    element.campus_name = campus.name
                    element.campus_id = campus.id
                    return element
                }))
                break
            }
        }
    }
    await saveElementsInFile('res/json/products.json', allElements.sort((a, b) => {
        return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    }), model)
}

const roots = [
    {
        'path': '/v2/expertises',
        'filename': 'res/json/expertises.json',
        'pageSize': 100,
        'model': {
            'id': true, 'kind': true, 'name': true
        }
    },
    {
        'path': '/v2/campus',
        'filename': 'res/json/campus.json',
        'pageSize': 100,
        'model': {
            'id': true, 'name': true, 'users_count': true, 'country': true, 'city': true, 'website': true
        }
    },
    {
        'path': '/v2/blocs',
        'filename': 'res/json/blocs.json',
        'pageSize': 100,
        'model': {
            'id': true, 'campus_id': true, 'cursus_id': true, 'coalitions': {
                'id': true, 'name': true, 'slug': true, 'image_url': true, 'cover_url': true, 'color': true, 'score': true
            }
        }
    },
    {
        'filename': 'res/json/products.json',
        'handler': shopHandler,
        'model': {
            'id': true, 'name': true, 'description': true, 'price': true, 'quantity': true, 'is_uniq': true, 'image': true, 'campus_id': true, 'campus_name': true
        }
    },
    {
        'path': '/v2/titles',
        'filename': 'res/json/titles.json',
        'pageSize': 100,
        'model': {
            'id': true, 'name': true
        }
    },
    {
        'path': '/v2/groups',
        'filename': 'res/json/groups.json',
        'pageSize': 100,
        'model': {
            'id': true, 'name': true
        }
    },
    {
        'path': '/v2/skills',
        'filename': 'res/json/skills.json',
        'pageSize': 100,
        'model': {
            'id': true, 'name': true
        }
    },
    {
        'path': '/v2/projects',
        'filename': 'res/json/projects.json',
        'pageSize': 30,
        'model': {
            'id': true, 'name': true, 'exam': true, 'parent': {
                'id': true, 'name': true
            },
            'cursus': {
                'id': true, 'name': true
            },
            'skills': {
                'id': true, 'name': true
            },
            'children': {
                'id': true, 'name': true
            },
            'project_sessions': {
                'id': true, 'max_people': true, 'solo': true, 'difficulty': true, 'cursus_id': true, 'campus_id': true,
                'scales': {
                    'id': true, 'correction_number': true, 'is_primary': true
                }
            }
        }
    },
    {
        'path': '/v2/achievements',
        'filename': 'res/json/achievements.json',
        'pageSize': 100,
        'model': {
            'id': true, 'description': true, 'image': true, 'name': true, 'nbr_of_success': true, 'visible': true
        }
    },
    {
        'path': '/v2/languages',
        'filename': 'res/json/languages.json',
        'pageSize': 100,
        'model': {
            'id': true, 'name': true, 'identifier': true
        }
    },
    {
        'path': '/v2/cursus',
        'filename': 'res/json/cursus.json',
        'pageSize': 100,
        'model': {
            'id': true, 'name': true
        }
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

        if (token.access_token === undefined) {
            throw Error(JSON.stringify(token))
        }
        token = token.access_token
        console.log("/oauth/token", token)

        for (const index in roots) {
            root = roots[index]
            if (fs.existsSync(root.filename))
                fs.unlinkSync(root.filename)
        }
        
        for (const index in roots) {
            root = roots[index];
            if (root.handler != undefined) {
                await root.handler(token, root.model);
                continue
            }
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
                    await saveElementsInFile(root.filename, elements, root.model)
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
