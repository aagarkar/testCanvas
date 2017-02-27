<%@ page import="canvas.SignedRequest" %>
<%@ page import="java.util.Map" %>
<%
    // Pull the signed request out of the request body and verify/decode it.
    Map<String, String[]> parameters = request.getParameterMap();
    String[] signedRequest = parameters.get("signed_request");
    if (signedRequest == null) {%>
        This App must be invoked via a signed request!<%
        return;
    }
    String yourConsumerSecret=System.getenv("CANVAS_CONSUMER_SECRET");
    //String yourConsumerSecret="1818663124211010887";
    String signedRequestJson = SignedRequest.verifyAndDecodeAsJson(signedRequest[0], yourConsumerSecret);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>

    <title>Hello World Canvas Example</title>

    <link rel="stylesheet" type="text/css" href="/canvas.css" />

    <!-- Include all the canvas JS dependencies in one file -->
    <script type="text/javascript" src="/js/canvas-all.js"></script>
    <!-- Third part libraries, substitute with your own -->
    <script type="text/javascript" src="/scripts/json2.js"></script>

    <script>
        if (self === top) {
            // Not in Iframe
            alert("This canvas app must be included within an iframe");
        }
  Sfdc.canvas
(function() 
	{
	   var sr = JSON.parse('<%=signedRequestJson%>');
	   // Save the token
	   Sfdc.canvas.oauth.token(sr.oauthToken);
	   Sfdc.canvas.byId('username').innerHTML = sr.context.user.fullName;
       Sfdc.canvas.byId('profileId').innerHTML = sr.context.user.profileId;
	   Sfdc.canvas.byId('email').innerHTML = sr.context.user.email;
				
	   //Prepare a query url to query leads data from Salesforce
	   var queryUrl = sr.context.links.queryUrl+"?q=SELECT+id+,+name+,+company+,+phone+from+Lead";
	  	
	  
	  
	   //Retrieve data using Ajax call
	   Sfdc.canvas.client.ajax(queryUrl, 
								{	client : sr.client,
									method: "GET",
									contentType: "application/json",
									success : function(data)
									{
										
										var returnedLeads = data.payload.records;
										var optionStr = '<table border="1"><tr><th></th><th>Id</th><th>Name</th><th>Company</th><th>Phone</th></tr>';
										for (var leadPos=0; leadPos < returnedLeads.length; leadPos = leadPos + 1) 
										{
											optionStr = optionStr + '<tr><td><input type="checkbox" onclick="setCheckedValues(\''+returnedLeads[leadPos].Name+'\',\''+returnedLeads[leadPos].Phone+'\');" name="checkedLeads" value="'+returnedLeads[leadPos].Id+'"></td><td>'+ returnedLeads[leadPos].Id + '</td><td>' + returnedLeads[leadPos].Name + '</td><td>' + returnedLeads[leadPos].Company + '</td><td>' + returnedLeads[leadPos].Phone + '</td></tr>';} //end for
										optionStr=optionStr+'</table>';
		   
										Sfdc.canvas.byId('leaddetails').innerHTML = optionStr;
									}
								}
							); //end success callback
	 }
 );
    </script>
</head>
<body>
    <br/>
	
    <h1>Hello <span id='username'></span></h1>
    <div>
	    <h3>Profile: <span id='profileId'></span></h3>
	    <h3>Email: <span id='email'></span></h3>
    </div>
    <h3>Lead Details: </h3><br/>
     <span id='leaddetails'></span>
</body>
</html>
