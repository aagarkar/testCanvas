<%@ page import="canvas.SignedRequest" %>
<%@ page import="java.util.Map" %>
<%
    // Pull the signed request out of the request body and verify/decode it.
    Map<String, String[]> parameters = request.getParameterMap();
    String[] signedRequest = parameters.get("signed_request");
  
    String yourConsumerSecret=System.getenv("CANVAS_CONSUMER_SECRET");
    //String yourConsumerSecret="1818663124211010887";
    String signedRequestJson = SignedRequest.verifyAndDecodeAsJson(signedRequest[0], yourConsumerSecret);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <script type="text/javascript" src="https://cs60.salesforce.com/canvas/sdk/js/canvas-all.js"></script>
</head>
<body>
    <script>

        function loginHandler(e) {
            var uri;
            if (! Sfdc.canvas.oauth.loggedin()) {
                uri = Sfdc.canvas.oauth.loginUrl();
                Sfdc.canvas.oauth.login(
                    {uri : uri,
                        params: {
                            response_type : "token",
                            client_id : "3MVG9oZtFCVWuSwPlTH3Qlf_bJ03KlVa2NageMQvCFtjSOAsjGQjUi1KI0RE.163eWgrj9LXtVwmOKPQc8B7Z",
                            redirect_uri : encodeURIComponent(
                                "https://herokuemulator.herokuapp.com/callback.html")
                        }});
            }
            else {
                Sfdc.canvas.oauth.logout();
                login.innerHTML = "Login";
                Sfdc.canvas.byId("oauth").innerHTML = "";
            }
            return false;
        }

        
         if (self === top) {
            // Not in Iframe
            alert("This canvas app must be included within an iframe");
        }
        // Bootstrap the page once the DOM is ready.
        Sfdc.canvas(function() {
            // On Ready...
            var login    = Sfdc.canvas.byId("login"),
                loggedIn = Sfdc.canvas.oauth.loggedin(),
                token = Sfdc.canvas.oauth.token()
            login.innerHTML = (loggedIn) ? "Logout" : "Login";
            if (loggedIn) {
                 // Only displaying part of the OAuth token for better formatting.
                Sfdc.canvas.byId("oauth").innerHTML = Sfdc.canvas.oauth.token()
                    .substring(1,40) + "…";
            }
            login.onclick=loginHandler;
       
        
        
        //added code
        
        
          //var sr = JSON.parse('<%=signedRequestJson%>');
   // Save the token
           var sr = JSON.parse(msg);
  
   Sfdc.canvas.byId('username').innerHTML =  Sfdc.canvas.oauth.token(sr.oauthToken);
            
   //Prepare a query url to query leads data from Salesforce
   var queryUrl = sr.context.links.queryUrl+"?q=SELECT+id+,+name+,+company+,+phone+from+Lead";
            
   //Retrieve data using Ajax call
   Sfdc.canvas.client.ajax(queryUrl, {client : sr.client,
                 method: "GET",
                 contentType: "application/json",
                 success : function(data){
                    var returnedLeads = data.payload.records;
                    var optionStr = '<table border="1"><tr><th></th><th>Id</th><th>Name</th><th>Company</th><th>Phone</th></tr>';
                    for (var leadPos=0; leadPos < returnedLeads.length; leadPos = leadPos + 1) {
                      optionStr = optionStr + '<tr><td><input type="checkbox" onclick="setCheckedValues(\''+returnedLeads[leadPos].Name+'\',\''+returnedLeads[leadPos].Phone+'\');" name="checkedLeads" value="'+returnedLeads[leadPos].Id+'"></td><td>'+ returnedLeads[leadPos].Id + '</td><td>' + returnedLeads[leadPos].Name + '</td><td>' + returnedLeads[leadPos].Company + '</td><td>' + returnedLeads[leadPos].Phone + '</td></tr>';
                   } //end for
                   leadStr=leadStr+'</table>';
       
                   Sfdc.canvas.byId('leaddetails').innerHTML = leadStr;
                 }}); //end success callback
        
        
        
        });
        
        
        
        
       
       
      

    </script>
    <h1 id="header">Force.com Canvas OAuth App</h1>
    <div>
        Access Token = <span id="oauth"></span>
    </div>
    <div>
        <a id="login" href="#">Login</a><br/>
        <h1>Hello <span id='username'></span></h1><br/>
        <span id='leaddetails'></span><br/>
    <a id="ctxlink" href="#">Get Context</a>
    </div>
</body>
</html>
