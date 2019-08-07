package com.verity.www ;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/WriterLogin")
public class WriterLogin extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public WriterLogin() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		
		HttpSession session = request.getSession();
		if(session.getAttribute("writer_id") != null) { // logged in
			response.getWriter().print(DbHelper.okJson().toString());
			doPost(request,response) ; 

		}
		else {
			response.getWriter().print(DbHelper.errorJson("Not logged in"));
		}
		return;
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
				
		System.out.println("WriterLogin username = " + username ) ;
		System.out.println("WriterLogin password = " + password ) ;
		
		String query = "select password from password where username = ?";
		List<List<Object>> res = DbHelper.executeQueryList(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
				new Object[] {username});
		
		String dbPass = res.isEmpty()? null : (String)res.get(0).get(0);
		if(dbPass != null && dbPass.equals(password)) {
			
			String query2 = "select * from writer where username = ?";
			String json = DbHelper.executeQueryJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
					new Object[] {username});
			
			try {
				JSONObject j1 = new JSONObject(json) ;
				JSONArray  ja = new JSONArray(j1.get("data").toString()) ;
				JSONObject j  = ja.getJSONObject(0);
				
				String writer_id = j.get("writer_id").toString() ;
				String name = j.get("name").toString(); 
				
				session.setAttribute("writer_id", writer_id);
				session.setAttribute("username",  username);
				session.setAttribute("name", name);
				
				System.out.println("Writer Login Successful");
							
				response.getWriter().print(DbHelper.okJson().toString());
			}
			catch (Exception e)
			{
				response.getWriter().print(DbHelper.errorJson("Error in Servlet/Database").toString());
			}

		}
		else {
			response.getWriter().print(DbHelper.errorJson("Username/password incorrect").toString());
		}
	}

}
