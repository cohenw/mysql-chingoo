<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.mysql.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String title = "Chingoo " + cn.getUrlString();
	String addedHistory = cn.getAddedHistory();
%>

<html>
<head> 
	<title><%= title %></title>

	<meta name="description" content="Chingoo is an open-source, web based MySQL database schema navigator." />
	<meta name="keywords" content="MySQL Web Database OpenSource JDBC" />
	<meta name="author" content="Spencer Hwang" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
	
	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getBuildNo() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getBuildNo() %>'>

	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
	
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

<%--
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
--%>
    
<script type="text/javascript">
var CATALOG="";
var to;
var to2;
var stack = [];
var stackFwd = [];

$(window).resize(function() {
	checkResize();
});
	
$(document).ready(function(){

	$('#searchFilter1').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter1(filter);
	})
	$('#hideEmpty').change(function(){
		var filter = $('#searchFilter1').val().toUpperCase();
		searchWithFilter1(filter);
	})
	
	$('#searchFilter2').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter2(filter);
 	})
	$('#searchFilter3').change(function(){
		var filter = $(this).val().toUpperCase();
		searchWithFilter3(filter);
 	})

	initLoad();
	checkResize();
	CATALOG = "<%= cn.getSchemaName()%>";
//	toggleKeepAlive();
	callserver();

	
	$('#globalSearch').change(function(){
 		var keyword = $(this).val().toLowerCase();
 		globalSearch(keyword);
 	})
 	
	
	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				loadObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
//			.append( "<a>" + item.label + "</a>" )
			.appendTo( ul );
		};
	});	
})

	function aboutChingoo() {
		// a workaround for a flaw in the demo system (http://dev.jqueryui.com/ticket/4375), ignore!
		$( "#dialog:ui-dialog" ).dialog( "destroy" );
	
		$( "#dialog-modal" ).dialog({
			height: 470,
			width: 500,
			modal: true,
			buttons: {
				Ok: function() {
					$( this ).dialog( "close" );
				}
			}			
		});
	}
	
	function toggleKeepAlive() {
		var t = $("#keepalivelink").html();
		if (t=="Off") {
			$("#keepalivelink").html("On");
			setTimeout("callserver()",1000);
		} else {
			$("#keepalivelink").html("Off");
			clearTimeout(to);
		}
	}

	function checkResize() {
		var w = $(window).width();
		var h = $(window).height();
	
		if (h > 500) {
//			var diff = $('#outer-table').position().top - $('#outer-result1').position().top;
			//alert(diff);
			var newH = h - 80;

			var tmp = w - $('#tabs').width() - $('#outer-result2').width() - 45; 
			if (!$("#outer-result2").is(":visible"))
				tmp = w - $('#tabs').width() - 45;

//			$('#outer-table').height(newH-diff);
			$('#outer-result1').height(newH);
			$('#outer-result2').height(newH);
			$('#tabs').height(newH-4);
			$('#tabs2').height(newH-40);
			
			if (tmp < 660) tmp = 660;
			$('#outer-result1').width(tmp);
			
			
/*			
			var diff = $('#outer-table').position().top - $('#outer-result1').position().top;
			//alert(diff);
			var newH = h - 80;

			var tmp = w - $('#outer-table').width() - $('#outer-result2').width() - 45; 

			$('#outer-table').height(newH-diff);
			$('#outer-result1').height(newH);
			$('#outer-result2').height(newH);
			
			if (tmp < 660) tmp = 660;
			$('#outer-result1').width(tmp);
*/			
		}
	}
	
function callserver() {
	var remoteURL = 'ping.jsp';
	$.get(remoteURL, function(data) {
		if (data.indexOf("true")>0)
			to = setTimeout("callserver()",600000);
		else {
			$("#inner-result1").html("Connection Closed.");
		}
	});
}	

$(function() {
	$( "#tabs" ).tabs();
});	

function initLoad() {
	loadList("ajax/list-table.jsp", "list-table");	
	loadList("ajax/list-view.jsp", "list-view");	
	loadList("ajax/list-package.jsp", "list-package");	
	loadList("ajax/list-tool.jsp", "list-tool");	
}

function loadList(url, targetDiv) {
	$.ajax({
		url: url,
		success: function(data){
			$("#" + targetDiv).html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
}

function searchWithFilter1(filter) {
	if($('#hideEmpty').attr('checked'))
		gotoUrl = "ajax/list-table.jsp?filter=" + filter+"&hideEmpty=true";
	else 
		gotoUrl = "ajax/list-table.jsp?filter=" + filter;

	$.ajax({
		url: gotoUrl,
		success: function(data){
			$("#list-table").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
	
}
function searchWithFilter2(filter) {
	if($('#hideEmpty').attr('checked'))
		gotoUrl = "ajax/list-table.jsp?filter=" + filter+"&hideEmpty=true";
	else 
		gotoUrl = "ajax/list-table.jsp?filter=" + filter;

	$.ajax({
		url: gotoUrl,
		success: function(data){
			$("#list-view").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
	
}
function searchWithFilter3(filter) {
	gotoUrl = "ajax/list-package.jsp?filter=" + filter;

	$.ajax({
		url: gotoUrl,
		success: function(data){
			$("#list-package").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});
	
}

function clearField1() {
	$("#searchFilter1").val("");
	searchWithFilter1('');
}
function clearField2() {
	$("#searchFilter2").val("");
	searchWithFilter2('');
}
function clearField3() {
	$("#searchFilter3").val("");
	searchWithFilter3('');
}

function loadSchema(sName) {
	$("#searchFilter").val("");
	$("#inner-table").html("<img src='image/loading.gif'/>");
	$.ajax({
		url: "schema.jsp?schema=" + sName + "&t=" + (new Date().getTime()),
		success: function(data){
			$("#inner-table").html(data);
			checkResize();
			//setMode('table');
			initLoad();
			CATALOG = catName;
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}

function hideHist() {
	$("#outer-result2").hide();
	checkResize();
}
</script>


</head> 

<body style="margin-top: 0px;">

<table width=100% border=0>
<td width="44">
<img align=top src="image/chingoo-small.gif" title="Oracle Chingoo - Build <%= Util.getBuildNo() %>"/>
</td>

<td><b><%= cn.getUrlString() %></b></td>

&nbsp;
<td>
<select name="schema" id="shcmeaList" onchange="loadSchema(this.options[this.selectedIndex].value);">
	<option></option>
<% for (int i=0; i<cn.getSchemas().size();i++) { %>
	<option value="<%=cn.getSchema(i)%>" <%= cn.getSchemaName().equals(cn.getSchema(i))?"SELECTED ":"" %>><%=cn.getSchema(i)%></option>
<% } %>
</select>

</td>

<td>
<!-- <a href="index.jsp">Home</a> |
 --><a href="query.jsp" target="_blank">Query</a> |
<!-- <a href="worksheet.jsp" target="_blank">Work Sheet</a> |
 --><a href="javascript:queryHistory()">History</a> |
<a href="javascript:clearCache()">Clear Cache</a> |
<a href='Javascript:aboutChingoo()'>About Chingoo</a> |
<a href="logout.jsp">Log out</a>
&nbsp;
&nbsp;

<%--
Keep Alive <a id="keepalivelink" href="Javascript:toggleKeepAlive()">Off</a>
--%>

</td>
<td align=right>
<b>Global Search</b> <input id="globalSearch" style="width: 200px;"  placeholder="table, view or package name"/>
<!-- <a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
 -->
<input type="button" value="Find" onClick="Javascript:globalSearch($('#globalSearch').val())"/>
</td>
</table>

<table border=0 cellspacing=0>
<td valign=top width=280>

<div id="tabs">
	<ul>
		<li><a href="#tabs-1">Table</a></li>
		<li><a href="#tabs-2">View</a></li>
		<li><a href="#tabs-3">Program</a></li>
		<li><a href="#tabs-4">Tool</a></li>
	</ul>
<div id="tabs2" style="overflow: auto;">
	<div id="tabs-1">
<b>Filter</b> <input id="searchFilter1" style="width: 180px;"  placeholder="table name"/>
<a href="Javascript:clearField1()"><img border=0 src="image/clear.gif"></a>
<br/><input id="hideEmpty" value="1" type="checkbox">Hide Empty tables
<div id="list-table"></div>
	</div>
	<div id="tabs-2">
<b>Filter</b> <input id="searchFilter2" style="width: 180px;"  placeholder="view name"/>
<a href="Javascript:clearField2()"><img border=0 src="image/clear.gif"></a>
<div id="list-view"></div>
	</div>
	<div id="tabs-3">
<b>Filter</b> <input id="searchFilter3" style="width: 180px;" placeholder="routine name"/>
<a href="Javascript:clearField3()"><img border=0 src="image/clear.gif"></a>
<div id="list-package"></div>
	</div>
	<div id="tabs-4">
<div id="list-tool"></div>
	</div>
</div>
</div>


</td>
<td valign=top>
<div id="outer-result1">
	<div id="inner-nav">
		<a href="Javascript:goBack()"><img id="imgBackward" src="image/blue_arrow_left.png" title="back" border="0" style="display:none;"></a>
		&nbsp;&nbsp;
		<a href="Javascript:goFoward()"><img id="imgForward" src="image/blue_arrow_right.png" title="forward" border="0" style="display:none;"></a>
	</div>
	<div id="inner-result1"><img src="image/chingoo.png"/></div>
</div>
</td>
<td valign=top>
<div id="outer-result2">
	<a href="Javascript:hideHist()" style="float:right;">hide</a>
	<div id="inner-result2"><%= addedHistory %></div>
</div>
</td>
</table>
<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>


<div id="dialog-modal" title="About MySQL Chingoo" style="display:none; background: #ffffff;">
<img src="image/chingoo.png" width=128 height=128 align="center" />
<br/>
Thanks for using MySQL Chingoo.<br/>

Chingoo is open-source web-based tool for MySQL database.<br/>
Chingoo will help you navigate through database objects and their relationships.<br/> 

<br/>
If you have any question or suggestion, please feel free to contact me.
<br/><br/>

Please download the latest version here:<br/>
<a href="http://code.google.com/p/mysql-chingoo/">http://code.google.com/p/mysql-chingoo/</a>
<br/><br/>

<%= Util.getVersionDate() %><br/>
Build: <%= Util.getBuildNo() %><br/>

Spencer Hwang - the creator of Chingoo<br/>
<a href="mailto:spencer.hwang@gmail.com">spencer.hwang@gmail.com</a>

</div>


<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_trackPageview']);
  _gaq.push(['_setDomainName', 'none']);
  
  _gaq.push(['_setCustomVar',
             1,                   // This custom var is set to slot #1.  Required parameter.
             'Database',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= cn.getUrlString() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);

  _gaq.push(['_setCustomVar',
             2,                   // This custom var is set to slot #1.  Required parameter.
             'Email',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= cn.getEmail() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);

  _gaq.push(['_setCustomVar',
             3,                   // This custom var is set to slot #1.  Required parameter.
             'IP',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= cn.getIPAddress() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);

  _gaq.push(['_setCustomVar',
             4,                   // This custom var is set to slot #1.  Required parameter.
             'BuildNo',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= Util.getBuildNo() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);
  
  _gaq.push(['_setCustomVar',
             5,                   // This custom var is set to slot #1.  Required parameter.
             'URL',     // The name acts as a kind of category for the user activity.  Required parameter.
             '<%= request.getRequestURL() %>',               // This value of the custom variable.  Required parameter.
             2                    // Sets the scope to session-level.  Optional parameter.
          ]);

  
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
	
</body>
</html>