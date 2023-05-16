let https = require('https');

let brandIdMap = {
    "SNYK":"net.brand",
}

let pass = {
    user: "tester",
    password: "jnnb9snYHGYGGYbh^%^&"
}

function adjustFormat(timestamp){
    let newTimestamp = timestamp;
    newTimestamp = insert(newTimestamp, 4, "-");
    newTimestamp = insert(newTimestamp, 7, "-");
    newTimestamp = insert(newTimestamp, 10, "T");
    newTimestamp = insert(newTimestamp, 13, ":");
    newTimestamp = insert(newTimestamp, 16, ":");
    newTimestamp = insert(newTimestamp, 19, ".000");
    return newTimestamp;
}

function insert(str, index, insertion){
    let newStr = str.split('');
    newStr.splice(index, 0, insertion);
    return newStr.join('');
}

exports.handler = function(input, context) {

    let inputBody = input.Records[0].body;
    console.log("Raw input: ", inputBody);

    let bodyJson = JSON.parse(inputBody);
    bodyJson.brandIds[0] = brandIdMap[bodyJson.brandIds[0]];
    bodyJson.timestamp = adjustFormat(bodyJson.timestamp);
    console.log("Processed input: ", bodyJson);

    let request = {
        host: "snyk.api.test.safety-first",
        method: 'POST',
        input: pass,
        path: '/snyk',
        headers: {
            'Content-Type': 'application/json',
            'x-api-key': 'TNihmSqqFQ4Q5GZRE3CXP2Q1nhE2881M4ZcYyxhM'
        }
    };

    context.succeed = function (success) {

    };
    let r = https.request(request, function(response) {
        if(response.statusCode === 202 || response.statusCode === 200) {
            context.succeed('Success');
        }
        else {
            console.log(response.statusCode);
            response.on('data', function(data) {
                console.log(data.toString());
            });
            context.fail();
        }
    })
    r.on('error', function(e) {
        context.fail(JSON.stringify(e));
    });
    r.end(JSON.stringify(bodyJson));
};
