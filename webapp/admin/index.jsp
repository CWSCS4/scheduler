<%@ include file="/include/init.jsp" %>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Administrative Options</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<h2>Administrative Options</h2>
<ul>
<li><a href="/admin/setperiod.jsp">Set conference period</a></li>
<li><a href="/admin/adminpasswd.jsp">Set admin password</a></li>
<li><a href="/admin/add_conference.jsp">Add conference</a></li>
<li><a href="/admin/su.jsp">Login as user</a></li>
<li><a href="/admin/removal.jsp">Remove a student/conference/teacher</a></li>
<li><a href="/admin/smtp.jsp">Adjust SMTP settings</a></li>
<li><a href="/admin/template.jsp">Set mail templates</a></li>
<li><a href="/admin/Duplicate_Student.jsp">Duplicate Student</a></li>

<li><a href="/admin/viewAllSchedules.jsp">View all student schedules (for printing)</a></li>
<li>Send email:
<a href="/admin/send_mail.jsp?type=schedule">Schedule</a>
<a href="/admin/send_mail.jsp?type=reminder">Reminder</a>
</li>
</ul>
</body>
</html>
