
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var addGender = function (params) {
    if (params.gender == 'male'){
        params['they'] = 'he';
        params['they have'] = 'he has';
        params['they are'] = 'he is';
        params['their'] = 'his';
        params['them'] = 'him';
    } else if (params.gender == 'female'){
        params['they'] = 'she';
        params['they have'] = 'she has';
        params['they are'] = 'she is';
        params['their'] = 'her';
        params['them'] = 'her';
    }
    return params;
};

// Include the Twilio Cloud Module and initialize it
var twilio = require("twilio");
twilio.initialize("AC1f69822a3e9feb75d73bd2adaa5b446a","6c1ec43a58557f8035ece577e0738308");

// Create the Cloud Function
Parse.Cloud.define("inviteWithTwilio", function(request, response) {
  //var params = addGender(request.params);
  //var miles = request.params.miles;
  var msg = "";
  // Use the Twilio Cloud Module to send an SMS
  twilio.sendSMS({
    From: "+12407125104",
    To: "3122135143", //request.params.phonenum
    Body: "HI"
  }, {
    success: function(httpResponse) { response.success("SMS sent!"); },
    error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
  });
});