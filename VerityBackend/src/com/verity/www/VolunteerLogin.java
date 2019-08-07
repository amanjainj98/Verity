package com.verity.www ;

import java.io.Console;
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

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/VolunteerLogin")
public class VolunteerLogin extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public VolunteerLogin() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		doPost(request,response) ; 

		HttpSession session = request.getSession();
		if(session.getAttribute("volunteer_id") != null) { // logged in
			response.getWriter().print(DbHelper.okJson().toString());
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

		String query = "select password from password where username = ?";
		List<List<Object>> res = DbHelper.executeQueryList(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
				new Object[] {username});

		String dbPass = res.isEmpty()? null : (String)res.get(0).get(0);
		if(dbPass != null && dbPass.equals(password)) {

			String query2 = "select * from volunteer where username = ?";
			String json = DbHelper.executeQueryJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
					new Object[] {username});
			System.out.print(json);

			try {
				JSONObject j1 = new JSONObject(json) ;
				JSONArray ja = new JSONArray(j1.get("data").toString()) ;
				System.out.print(ja.length());
				if(ja.length()!=0) {

					JSONObject j = ja.getJSONObject(0);

					String volunteer_id = j.get("volunteer_id").toString() ;
					String name = j.get("name").toString(); 

					session.setAttribute("volunteer_id", volunteer_id);
					session.setAttribute("username",  username);
					session.setAttribute("name", name);

					response.getWriter().print("{\"data\":[\"volunteer\"],\"status\":true}");
				}
				else {
					String query3 = "select * from writer where username = ?";
					String json2 = DbHelper.executeQueryJson(query3, 
							new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
							new Object[] {username});
					System.out.print(json2);


					JSONObject j12 = new JSONObject(json2) ;
					JSONArray ja2 = new JSONArray(j12.get("data").toString()) ;
					System.out.print(ja2.length());

					JSONObject j2 = ja2.getJSONObject(0);

					String writer_id = j2.get("writer_id").toString() ;
					String name = j2.get("name").toString(); 

					session.setAttribute("writer_id", writer_id);
					session.setAttribute("username",  username);
					session.setAttribute("name", name);

					response.getWriter().print("{\"data\":[\"writer\"],\"status\":true}");


				}
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
