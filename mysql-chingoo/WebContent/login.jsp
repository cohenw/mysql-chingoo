<%@ page language="java" 
	import="java.util.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>


<%
	session.removeAttribute("CN");

	String cookieName = "url";
	String email = "";
	Cookie cookies [] = request.getCookies ();
	Cookie myCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals (cookieName)) {
				myCookie = cookies[i];
				break;
			}
		}	
		for (int i = 0; i < cookies.length; i++) {
			if (cookies [i].getName().equals ("email")) {
				email = cookies[i].getValue();
				break;
			}
		}	
	}
	
	String cookieUrls = "";
	if (myCookie != null) cookieUrls = myCookie.getValue();
	
	// default login info
	String initJdbcUrl = "jdbc:mysql://localhost:3306/test";
	String initUserName = "root";
	
	// get the last login from cookie
	if (cookieUrls != null && cookieUrls.length()>1) {
		StringTokenizer st = new StringTokenizer(cookieUrls);
	    if (st.hasMoreTokens()) {
	    	String token = st.nextToken();
	    	int idx = token.indexOf("@");
	    	initUserName = token.substring(0, idx);
	    	initJdbcUrl = token.substring(idx+1);
	    }
	}
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Chingoo</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
    
	<meta name="description" content="Chingoo is an open-source, web based MySQL database schema navigator." />
	<meta name="keywords" content="MySQL Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getBuildNo() %>'> 
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script type="text/javascript">
    	function setLogin(jdbcUrl, userId) {
    		$("#url").val(jdbcUrl);
    		$("#username").val(userId);
    	}
    </script>
  </head>
  
  <body>
    <h2>Welcome to MySQL Chingoo.</h2>

   <img src="image/chingoo.png" title="<%= Util.getVersionDate() + " Build" + Util.getBuildNo() %>" width=128 height=128/>

<form action="connect_new.jsp" method="POST">


    <table border=0>
    <tr>
    	<td><span style="font-size:20px; color: blue;">JDBC URL</span></td>
    	<td><input style="font-size:20px;" size=60 name="url" id="url" value="<%= initJdbcUrl %>"/></td>
    </tr>
    <tr>
    	<td><span style="font-size:20px; color: blue;">User Name</span></td>
    	<td><input style="font-size:20px;" name="username" id="username" value="<%= initUserName %>"/></td>
    </tr>
    <tr>
    	<td><span style="font-size:20px; color: blue;">Password</span></td>
    	<td><input style="font-size:20px;" name="password" type="password"/></td>
    </tr>
    </table>
    <input type="submit" value="Connect"/>
	</form>
<br/>


<div>

<%
	StringTokenizer st = new StringTokenizer(cookieUrls);
    while (st.hasMoreTokens()) {
    	String token = st.nextToken();
    	int idx = token.indexOf("@");
    	String userid = token.substring(0, idx);
    	String jdbcUrl = token.substring(idx+1);
%>
<a href="javascript:setLogin('<%= jdbcUrl %>', '<%= userid %>')"><%= token %></a>
<a href="remove-cookie.jsp?value=<%= token %>"><img border=0 src="image/clear.gif"></a>
<br/>

<%
	}
%>
</div>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_trackPageview']);
  _gaq.push(['_setDomainName', 'none']);
  
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

  </body>
</html>
