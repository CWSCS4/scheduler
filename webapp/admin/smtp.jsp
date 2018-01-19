<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
int numberOfTimeSlots = 0;
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>SMTP Settings</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<h2>SMTP Settings</h2>

<form action="smtp.jsp" method="post">
<%
ResultSet results = state.executeQuery( "SELECT SMTPserver, mailFrom FROM config" );
results.first();
%>
<p><input type="text" name="server" value="<%= results.getString( 1 ) == null ? "" : results.getString( 1 ) %>"/> SMTP Server</p>
<p><input type="text" name="from" value="<%= results.getString( 2 ) == null ? "" : results.getString( 2 ) %>"/> Return address for all messages</p>
<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>

<% } else { %>

<%
ResultSet results = state.executeQuery( "SELECT priKey, SMTPserver, mailFrom FROM config" );
results.first();

results.updateString( 2, request.getParameter( "server" ) );
results.updateString( 3, request.getParameter( "from" ) );
results.updateRow();

results.close();

%><jsp:forward page="/admin/" /><%

} %>
</body>
</html>
