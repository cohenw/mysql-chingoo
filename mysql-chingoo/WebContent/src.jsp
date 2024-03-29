<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
	private static int countLines(String str){
		   String[] lines = str.split("\r\n|\r|\n");
		   return  lines.length;
		}
%>
<%
	String name = request.getParameter("name");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();

	String q = "SELECT DISTINCT TYPE FROM USER_SOURCE WHERE NAME='" + name +"'  ORDER BY TYPE";
	if (owner != null) q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE";

	List<String[]> types = cn.query(q);
	int lines_pkg = 0;
	int lines_pkgbody = 0;
	int lines_procedure = 0;
	int lines_function = 0;
%>
<html>
<head>
	<title>Source for <%= name %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
	
</head>
<body>


<img src="image/icon_query.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h2><%= name %></h2>

<%
for (int k=0;k<types.size();k++) {
	String type = types.get(k)[1];

	String qry = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	if (owner != null) qry = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";

	List<String[]> list = cn.query(qry, 10000, false);
	
	String text = "";
	for (int i=0;i<list.size();i++) {
		String ln = list.get(i)[3];
		if (!ln.endsWith("\n")) ln += "\n";
		//text += Util.escapeHtml(ln);
		text += ln;
		
	}

	
	if (type.equals("PACKAGE"))
		lines_pkg =  countLines(text);
	else if (type.equals("PACKAGE BODY"))
		lines_pkgbody =  countLines(text);
	else if (type.equals("PROCEDURE"))
		lines_procedure =  countLines(text);
	else if (type.equals("FUNCTION"))
		lines_function =  countLines(text);
%>

<b><a href="javascript:tDiv('div-<%=k%>')"><%= type %></a></b><br/>
<div id="div-<%=k%>" style="display: block;">

<table>
<td valign=top align=right><pre style="font-family: Consolas; color: gray;"><span id="colnum_<%=type.replace(" ","")%>" ></span></pre></td>
<td bgcolor="green"></td>
<td valign=top><pre style="font-family: Consolas;"><%= new HyperSyntax().getHyperSyntax(cn, text, type)%></pre></td>
</table>

</div>
<br/>
<%
}
%>


<br/></br/>
<a href="javascript:window.close()">Close</a>

</body>
</html>

<script type="text/javascript">
  function tDiv(id) {
	  $("#"+id).toggle();
  }

  if ($.browser.msie) return;
  
  lines="";
  for (var i=1;i <= <%=lines_pkg%>;i++)
	  lines += i + "\n";
  $("#colnum_PACKAGE").html('   ' + lines);
  
  lines="";
  for (var i=1;i <= <%=lines_pkgbody%>;i++)
	  lines += i + "\n";
  $("#colnum_PACKAGEBODY").html('   ' + lines);

  lines="";
  for (var i=1;i <= <%=lines_procedure%>;i++)
	  lines += i + "\n";
  $("#colnum_PROCEDURE").html('   ' + lines);

  lines="";
  for (var i=1;i <= <%=lines_function%>;i++)
	  lines += i + "\n";
  $("#colnum_FUNCTION").html('   ' + lines);

 </script>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  _gaq.push(['_trackEvent', 'Src', 'Src <%= name %>']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>

