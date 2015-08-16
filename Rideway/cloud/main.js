var http = require('http');
var querystring = require('querystring');
var Buffer = require('buffer').Buffer;
    
// var twilio_cred = require('cloud/config').keys.twilio;
// var client = require('twilio')(twilio_cred.AccountSID, twilio_cred.AuthToken);

///////////////////////////
///// PARSE FUNCTIONS /////
///////////////////////////

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
      var newACL = new Parse.ACL();

      newACL.setPublicReadAccess(false);
      // newACL.setRoleWriteAccess("Administrator", true);
      // newACL.setRoleReadAccess("Administrator",  true);

      request.object.setACL(newACL);
      response.success();
});


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var twilio = require("twilio");
twilio.initialize("AC4b1ffd82634bdb9f7ae3a832ae48a88c","8e1f2683bf7c93ec948cbbf18e09bd5d");

Parse.Cloud.define("SMS", function(request, response) {
	var fromName = request.params.fromName;
	var miles = request.params.miles;
	var msg = "Good afternoon! "+fromName+" is "+miles+" miles away!";
	// Use the Twilio Cloud Module to send an SMS
	twilio.sendSMS({
	  From: "+18725298584",
	  To: request.params.toNum,
	  Body: msg
	}, {
	    success: function(httpResponse) {
	      console.log(httpResponse);
	      response.success("SMS sent!");
	    },
	    error: function(httpResponse) {
	      console.log(httpResponse);
	      response.error(httpResponse);
	    }
	});
});