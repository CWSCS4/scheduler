<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<%
if (false) { // [areyzin] disabled emails
//if (request.getParameter("submitted3") == null || !request.getParameter("submitted3").equals("yes")) {
%>
<h2>Final Options (Step 3 of 3)</h2>
<form action="request3.jsp" method="post">
<%
ResultSet results = state.executeQuery("SELECT email FROM students WHERE studentID = " + studentID);
results.first();
%>
<p>Please enter the email address at which you would like to receive messages
regarding your conference schedule:</p>
<p><input type="text" name="email" value="<%= results.getString(1) == null ? "" : results.getString(1) %>" /></p>
<!-- <p>If you want to change your password, here is your opportunity:
<br><input type="password" name="oldpasswd" /> Old Password
<br><input type="password" name="newpasswd" /> New Password
<br><input type="password" name="confirmpasswd" /> Repeat New Password -->
<p><input type="submit" value="Finish" /></p>
<input type="hidden" name="submitted3" value="yes" />
</form>
<% } else {

boolean errors = false;

ResultSet results = state.executeQuery("SELECT studentID, email FROM students WHERE studentID = " + studentID);
results.first();

// [areyzin] String email = request.getParameter("email");
String email = "areyzin@commschool.org"; // [areyzin] emailing is disabled
if (email.equals("") || email == null || email.equals("null")) {
   errors = true;
   %><p>You did not enter an email address.<%
}
results.updateString(2, email);
results.updateRow();

/* 

String oldpasswd = request.getParameter( "oldpasswd" );
String newpasswd = request.getParameter( "newpasswd" );
String confirmpasswd = request.getParameter( "confirmpasswd" );

results = state.executeQuery( "SELECT PASSWORD('" + oldpasswd + "')" );
results.first();
String oldpasswdh = results.getString( 1 );

results = state.executeQuery( "SELECT PASSWORD('" + newpasswd + "')" );
results.first();
String newpasswdh = results.getString( 1 );

results = state.executeQuery( "SELECT studentID, password FROM students WHERE studentID = " + studentID );
results.first();

if ( results.getString( 2 ).equals( oldpasswdh ) && newpasswd.equals( confirmpasswd ) ) {
   results.updateString( 2, newpasswdh );
   results.updateRow();
} */

%>
<% if (errors) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.
<% } else { %>
<jsp:forward page="confirm.jsp" />
<% } %>
<% } %>
</body>
</html>
