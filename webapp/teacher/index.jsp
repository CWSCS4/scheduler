<%@ include file="/include/init.jsp" %>

<%
ResultSet results;
if (schedulingDone) response.sendRedirect("/teacher/conferences.jsp");
if (!teacherHasSetAvail) response.sendRedirect("/teacher/request.jsp");
if (!teacherHasSetPrefs) response.sendRedirect("/teacher/request2.jsp");
if (!teacherHasSetEmail) response.sendRedirect("/teacher/request3.jsp");
response.sendRedirect("/teacher/view.jsp");
%>
