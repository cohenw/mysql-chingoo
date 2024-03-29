<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String table = request.getParameter("table");
	Connect cn = (Connect) session.getAttribute("CN");

	String catalog = null;
	String tname = table;
	
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	
	if (catalog==null) catalog = cn.getSchemaName();
	
	if (table==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}
	
	String divId="div_" + table;
	divId = divId.replaceAll("\\.","-");

	ArrayList<String> pk = cn.getPrimaryKeys(catalog, tname);
	List<TableCol> cols = cn.getTableDetail(catalog, tname);

	if (cols.size()==0) return;
%>

<div id="<%= divId %>">
<a href="Javascript:copyPaste('<%=table %>');"><b><%= table %></b></a> <span class="rowcountstyle"><%= cn.getTableRowCount(table) %></span> <a href="Javascript:removeDiv('<%= divId %>')">x</a> 
&nbsp;&nbsp;&nbsp;<a href="pop.jsp?key=<%= table %>" target="_blank" title="view detail"><img src="image/sql.png"></a>

<table border=0 width=780>
<tr>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
</tr>
<tr>
<%	
	for (int i=0; i<cols.size();i++) {
		TableCol col = cols.get(i);
		String colName = col.getName();
		String colDisp = col.getName(); //.toLowerCase();
		//if (pk.contains(colName)) colDisp = "<b>" + colDisp + "</b>";
		if (pk.contains(colName)) colDisp = "<span class='pk'>" + colDisp + "</span>";
		
		String tooltip = col.getTypeName();
		String comment = cn.getComment(tname, colName);
		if (comment != null && comment.length() > 0) tooltip += " " + comment;
%>
<td>&nbsp;<a href="Javascript:copyPaste('<%=colName%>');" title="<%= tooltip %>"><%= colDisp%></a></td>
<%
		if ((i+1)%5==0) out.println("</tr><tr>");
	}
	
%>

</tr></table>
<br/>
</div>
