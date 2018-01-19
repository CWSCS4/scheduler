<%@ page isErrorPage="true" %>

<%@ page import="java.io.*" %>

<%@ include file="/include/doctype.jsp" %>

<html>
<head>
<title>Error</title>
<%@ include file="/include/meta.jsp" %>
<style type="text/css">
h1 {
	font-size: x-large;
	font-weight: bold;
}

.important { 
	font-size: large;
	font-weight: bold;
}
</style>
</head>
<body>
<%@ include file="/include/error_header.jsp" %>
<h1>We're sorry, an error has occured.</h1>
<p class="important">It's not your fault, it's ours.  Really.</p>
<p>You can try using the Back button and trying again.  If that doesn't work,
double-check that you haven't confused the scheduler by doing something like
entering letters where it was expecting a number.  (It should catch these 
things, but nothing's perfect.)</p>
<p class="important">If you're still having trouble, please email Alice Reyzin at <a href="mailto:areyzin@commschool.org">areyzin@commschool.org</a>.</p>
<p>Please explain what you were trying to do, and copy and paste the following
text.  (Please scroll down to get the entire message if it's longer than one
screen--it's all important.)  This will greatly help us to fix the problem.</p>
<form method="post" action="exception.jsp">
<textarea name="exception" style="width: 700px; height: 15em;">
<% 
PrintWriter pw = new PrintWriter(out, true);
int i = 0;
Throwable e = exception;
StackTraceElement[] s;
do {
	out.println(e.getClass().getName() + ": " + e.getMessage());
	s = e.getStackTrace();
	for (i = 0; i < s.length; i++) {
		out.println(" at " + s[i]);
	}
} while ((e = e.getCause()) != null);
// exception.printStackTrace(pw);
%>
</textarea>
</form>
<p class="important">We apologize for the inconvenience, and thank you for
your patience and cooperation.</p>
</body>
</html>