package jspproject;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/jspproject/userPost")
public class UserPost extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, 
			HttpServletResponse response) throws ServletException, IOException {
		JspMgr jmgr = new JspMgr();
		if(jmgr.insertUser(request)) {
			response.sendRedirect("login.jsp");
		}else {
			response.sendRedirect("register.jsp");
		}
	}

}
