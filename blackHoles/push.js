#!/bin/env node
var http = require('http');
var config = require('./pushConfig.json');

var listenIp = config.ip   || "127.0.0.1";
var port     = config.port || 1337;

function hasAtLeast(obj, min, fieldList)
{
	var count = 0;
	for(var m = 0; m < fieldList.length; m++)
	{
		var field = fieldList[m];
		if(Array.isArray(field))
		{
			if(hasAtLeast(obj, 1, field))
			{
				count++;
			}
		}
		else
		{
			if(obj[field] !== undefined)
			{
				count++;
			}
		}
	}
	return count >= min;
}

function has(obj, field)
{
	return hasAtLeast(obj, 1, [field]);
}

function hasAtMost(obj, max, fieldList)
{
	var count = 0;
	//console.log("Checking", obj, "for:");
	for(var m = 0; m < fieldList.length; m++)
	{
		var field = fieldList[m];
		//console.log("-->", field);
		if(Array.isArray(field))
		{
			if(hasAtLeast(obj, 1, field))
			{
				count++;
				if(count > max)
				{
					return false;
				}
			}
		}
		else
		{
			if(obj[field] !== undefined)
			{
				count++;
				if(count > max)
				{
					return false;
				}
			}
		}
	}
	return true;
}

function isOneOf(value, listOfValues)
{
	for(var m = 0; m < listOfValues.length; m++)
	{
		var testValue = listOfValues[m];
		if(value == testValue)
		{
			return true;
		}
	}
	return false;
}

function validateContent(content)
{
	if(typeof content != typeof {})
	{
		return 'Content must be an object.';
	}

	var possibleFields = {
		'subject' : true,
		'message' : true,
		'action': true,
		'rich' : true,
		'payload' : true,
		'sound' : true,
		'badge' : true
	};
	
	var unexpected = firstUnlisted(content, possibleFields);
	if(unexpected != null)
	{
		return 'Unexpected field "' + unexpected + '" found in content.';
	}

	return null;

}

function validateAction(action, isRich)
{
	isRich = isRich || false;
	if(isRich && action == null)
	{
		return null;
	}

	if(typeof action != typeof {})
	{
		var error = 'Action must be an object.';
		if(isRich)
		{
			error = 'Rich ' + error;
		}
		return error;
	}

	var possibleFields = {
		'type' : true,
		'data' : true,
		'label': true
	};
	
	var unexpected = firstUnlisted(action, possibleFields);
	if(unexpected != null)
	{
		return 'Unexpected field "' + unexpected + '" found in action.';
	}

	if(!has(action, 'type'))
	{
		return 'No "type" specified in action.';
	}

	var possibleActionTypes;
	if(isRich)
	{
		possibleActionTypes = [
			'WEB',
			'CST',
			'PHN',
			'DEFAULT', 
			'NONE',
		];
	}
	else
	{
		possibleActionTypes = [
			'URL',
			'RICH',
			'CUSTOM',
			'PHONE',
			'DEFAULT', 
			'NONE',
		];
	}

	if(!isOneOf(action.type, possibleActionTypes))
	{
		var error = 'Action type is unrecognized value "' + action.type + '".';
		if(isRich)
		{
			error = 'Rich ' + error;
		}
		return error;
	}

	return null;
}

function firstUnlisted(obj, fieldMap)
{
	for(field in obj)
	{
		if( ! (field in fieldMap) )
		{
			console.log("PROBLEM:", field);
			console.log("FieldMap:", fieldMap);
			console.log("Obj:", obj);
			return field;
		}
	}
	return null;
}

function validatePushRequest(request)
{
	var valid = true;

	var selectorFields = [
		'xids', 
		['hasTags', 'notTags'],
		'sendAll'
	];
	
	var possibleFields = {
		'apiKey' : true, 
		'appKey' : true,
		'xids' : true,
		'hasTags': true,
		'notTags' : true,
		'sendAll' : true,
		'inboxOnly' : true,
		'content' : true
	};

	var unlisted;
	var contentError;
	var actionError;
	var tests = [
		{
			'failed'  : !has(request, 'apiKey'),
			'status'  : 400,
			'message' : 'No apiKey was specified.'
		},
		{
			'failed'  : !has(request, 'appKey'),
			'status'  : 400,
			'message' : 'No appKey was specified.'
		},
		{
			'failed'  : !has(request, 'content'),
			'status'  : 400,
			'message' : 'No content was specified.'
		},
		{
			'failed'  : !hasAtMost(request, 1, selectorFields),
			'status'  : 400,
			'message' : 'Only "xids", "sendAll" or the combination of "hasTags" and "notTags" should be specified. Too many provided.'
		},
		{
			'failed'  : !hasAtLeast(request, 1, selectorFields),
			'status'  : 400,
			'message' : 'You must provide at least one of "xids", "sendAll" or the combination of "hasTags" and "notTags".'
		},
		{
			'failed'  : (unlisted = firstUnlisted(request, possibleFields)) != null,
			'status'  : 400,
			'message' : 'Request contained an unrecognized field: "' + unlisted + '"'
		},
		{
			'failed'  : request.content != null &&
				    (contentError = validateContent(request.content)) != null,
			'status'  : 400,
			'message' : contentError
		},
		{
			'failed'  : request.content != null &&
			 	    request.content.action != null &&
				    (actionError = validateAction(request.content.action)) != null,
			'status'  : 400,
			'message' : actionError 
		},
		{
			'failed'  : request.content != null &&
				    request.content.rich != null &&
				    (actionError = validateAction(request.content.rich.action, true)) != null,
			'status'  : 400,
			'message' : actionError
		},
	]
	for(var m = 0; m < tests.length; m++)
	{
		var test = tests[m];
		if(test.failed)
		{
			return test;
		}
	}
	var success = {
		"status" : 202,
	}
	return success;
}

function onPushRequest(request, response)
{
	function finish(status, message)
	{
		var logMessage = message;
		if(status < 400)
		{
			message = '';
			logMessage = 'OK';
		}
		console.log(request.method + " :: " + status + " --> " + logMessage);
		response.writeHead(status, message, {"Content-Type": "text/html"});
		response.end();
	}

	if (request.method == 'POST')
	{
		var data = '';
		request.on('data', function(chunk){
			data += chunk;
		});

		request.on('end', function() {
			try
			{
				var pushRequest = JSON.parse(data);
				var result = validatePushRequest(pushRequest);
				finish(result.status, result.message);
			}
			catch(parseError)
			{
				finish(400, "Could not parse JSON paylaod: " + parseError);
			}
		});
	}
	else
	{
		finish(405, "Method not supported.");
	}	
}

http.createServer(onPushRequest).listen(port, listenIp);

console.log('Xtify Push Black Hole Server now running at http://' + listenIp + ":" + port + '/');
