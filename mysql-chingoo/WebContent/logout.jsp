<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.Connect" 
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	if (cn!=null) {
		try {
			cn.disconnect();
		} catch (Exception e) {}
	}
	
	session.removeAttribute("CN");
%>

<html>
  <head>
    <title>Chingoo for MySQL</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
  </head>

 <img src="image/chingoo.png"/>

<h2>Disconnected. Good Bye!</h2>

<br/>
<a href="index.jsp">Home</a>

</html>