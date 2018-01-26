<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= teacherName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>
<h2>Confirmation</h2>
<p>Please confirm that the following information is correct. </p>
<%
ResultSet results = state.executeQuery( "SELECT * FROM teachers WHERE teacherID = " + teacherID );
if (results.first()) {
    if (results.getInt(7)==0){
    %>
        <p>You have indicated that you will not be availible for conferences.</p>

    <% } else { %>
<p>You have indicated that you will be available for the following time
slots:</p>
<ul>
<%
results = state.executeQuery("SELECT start, end FROM available WHERE type = 1 AND ID = " + teacherID);

while(results.next()) { 
        DateFormat tdf = new SimpleDateFormat("h:mm a");
        DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format(results.getTimestamp(1)) + " " + tdf.format(results.getTimestamp(1)) %> - <%= tdf.format(results.getTimestamp(2)) %></li>
<% } %>
</ul>

<p>You have selected that you would like to meet with the following students in
the priority listed: (9 is highest priority)</p>

<%
results = state.executeQuery("SELECT students.name, rank, max_conferences FROM preferences LEFT JOIN students ON preferences.withID = students.studentID WHERE isTeacher = 1 AND ID = " + teacherID + " ORDER BY preferences.rank");
%>
<table>
<tr><th>Importance</th><th>Student</th></tr>
<%
while(results.next()) { %>
    <tr><td><% 
                
        switch(results.getInt(2)){
           case 1:
                %>Not Important<%
                break;
           case 3:
                %>Somewhat Important<%
                break;
           case 5:
                %>Important<%
                break;
           case 7:
                %>Very Important<%
                break;
           case 9:
                %>Urgent<%
                break;  
        }
        %><%= results.getInt(3) > 1 ? " (2 conferences)" : "" %></td><td><%= results.getString(1) %></td></tr>
<% } %>
</table>
<%}%>
<%}%>
<!-- [areyzin] disabled emails
<p>You have indicated that you wish your final schedule to be emailed to
"<%= teacherEmail %>".</p>
-->
<p>Please click <a href="/teacher/request.jsp">here</a> if you would like to
change this information by redoing the signup procedure. Otherwise, please check back the day before the conferences to see your schedule.</p>
</body>
</html>
