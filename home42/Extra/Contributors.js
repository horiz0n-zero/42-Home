// home42/Contributors.js
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

const client_id = 'API_KEY_UID'
const client_secret = 'API_KEY_SECRET'

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

async function makeRequest(token, path) {
    const options = {
        host: 'api.intra.42.fr',
        path: path,
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        }
    }
    return basicRequest(options, "");
}

const home42 = "42 Home Owner";
const home42MapBuilder = '42 Home Map Builder';
const home42NotAfraidByTheDarkLord = "NotAfraidByThe Dark Lord";
const home42Contributor = "42 Home Contributor";
const home42Cobay = "42 Home Cobaye";
const home42HeadHunter = "42 Home HeadHunter";
const home42Tester = "42 Home Tester";
const home42Spellchecker = "42 Home Master Spellchecker"

const datas = [
   {
       'login': 'afeuerst',
       'groups': [home42, home42MapBuilder]
   },
   {
       'login': 'abrabant',
       'groups': [home42Tester]
   },
   {
       'login': 'mlormois',
       'groups': [home42Cobay, home42NotAfraidByTheDarkLord]
   },
   {
       'login': 'asurrel',
       'groups': [home42Tester, home42Cobay]
   },
   {
       'login': 'gkitoko',
       'groups': [home42Tester, home42HeadHunter]
   },
   {
       'login': 'lpassera',
       'groups': [home42Tester, home42Contributor]
   },
   {
       'login': 'afrangio',
       'groups': [home42Tester]
   },
   {
       'login': 'agautier',
       'groups': [home42Tester]
   },
   {
       'login': 'agunesli',
       'groups': [home42Tester]
   },
   {
       'login': 'asurrel',
       'groups': [home42Tester, home42Cobay, home42Spellchecker]
   },
   {
       'login': 'bcano',
       'groups': [home42Tester]
   },
   {
       'login': 'cbertran',
       'groups': [home42Tester]
   },
   {
       'login': 'cchicote',
       'groups': [home42Tester]
   },
   {
       'login': 'cgranja',
       'groups': [home42Tester]
   },
   {
       'login': 'clucien',
       'groups': [home42Tester]
   },
   {
       'login': 'earnaud',
       'groups': [home42Tester, home42Cobay]
   },
   {
       'login': 'efouille',
       'groups': [home42Tester, home42Spellchecker]
   },
   {
       'login': 'emaugale',
       'groups': [home42Tester, home42HeadHunter]
   },
   {
       'login': 'fgarault',
       'groups': [home42Tester]
   },
   {
       'login': 'fjallet',
       'groups': [home42Tester]
   },
   {
       'login': 'gmorange',
       'groups': [home42Tester]
   },
   {
       'login': 'jbach',
       'groups': [home42Tester]
   },
   {
       'login': 'jbatoro',
       'groups': [home42Tester]
   },
   {
       'login': 'jboisser',
       'groups': [home42Tester]
   },
   {
       'login': 'jdidier',
       'groups': [home42Tester]
   },
   {
       'login': 'jecolmou',
       'groups': [home42Tester]
   },
   {
       'login': 'jpeyron',
       'groups': [home42Tester]
   },
   {
       'login': 'ldinaut',
       'groups': [home42Tester]
   },
   {
       'login': 'lguillau',
       'groups': [home42Tester]
   },
   {
       'login': 'llescure',
       'groups': [home42Tester]
   },
   {
       'login': 'mielee',
       'groups': [home42Tester]
   },
   {
       'login': 'mvue',
       'groups': [home42Tester]
   },
   {
       'login': 'ngiroux',
       'groups': [home42Tester]
   },
   {
       'login': 'ple-stra',
       'groups': [home42Tester]
   },
   {
       'login': 'shocquen',
       'groups': [home42Tester]
   },
   {
       'login': 'tyuan',
       'groups': [home42Tester]
   },
   {
       'login': 'vfurmane',
       'groups': [home42Tester]
   },
   {
       'login': 'wdebotte',
       'groups': [home42Tester]
   },
   {
       'login': 'gemartin',
       'groups': [home42Contributor, home42Spellchecker]
   },
   {
       'login': 'malzubai',
       'groups': [home42Contributor, home42MapBuilder]
   },
   {
       'login': 'hahseo',
       'groups': [home42Contributor, home42Spellchecker]
   },
   {
       'login': 'dangonza',
       'groups': [home42Contributor, home42Spellchecker]
   },
   {
       'login': 'mgraf',
       'groups': [home42Contributor, home42Spellchecker]
   },
   {
       'login': 'dlanotte',
       'groups': [home42Contributor, home42Spellchecker]
   }
];

async function main() {
    try {
        var token = await authRequest()
        var data;
        var user;
        var output = [];
        var groups = [];

        if (token.access_token === undefined) {
            throw Error(JSON.stringify(token))
        }
        token = token.access_token
        console.log("/oauth/token", token)

        for (const index in datas) {
            data = datas[index];
            user = await makeRequest(token, '/v2/users/' + data.login);
            output.push({
                        'login': data.login,
                        'id': user.id,
                        'image': user.image,
                        'groups': data.groups
                        });
            for (const i in data.groups) {
                if (!groups.includes(data.groups[i]))
                    groups.push(data.groups[i])
            }
            console.log(data.login);
        }
        await saveElementsInFile('res/contributors/contributors.json', output);
        await saveElementsInFile('res/contributors/groups.json', groups);
    }
    catch(e) {
        console.log("error", e)
        process.exit(1)
    }
}

main()

