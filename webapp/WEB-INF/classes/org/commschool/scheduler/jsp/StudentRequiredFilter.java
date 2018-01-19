package org.commschool.scheduler.jsp;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class StudentRequiredFilter implements Filter {
	private FilterConfig config;

	public void init(FilterConfig config) {
		this.config = config;
	}

	public void destroy() {

	}

	public void doFilter(ServletRequest request,
	                     ServletResponse response,
						 FilterChain chain)
		throws ServletException, IOException {
		HttpServletRequest req = (HttpServletRequest)request;
		HttpServletResponse resp = (HttpServletResponse)response;
		if (req.getSession().getAttribute("studentID") == null) {
			resp.sendRedirect("/login.jsp");
		} else {
			chain.doFilter(request, response);
		}
	}
}
