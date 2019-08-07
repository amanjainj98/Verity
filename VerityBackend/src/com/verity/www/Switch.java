package com.verity.www;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;
/**
 * Servlet implementation class Switch
 */
@WebServlet("/Switch")
public class Switch extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Switch() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		
		int p = Integer.parseInt(request.getParameter("switchto"));
		HttpSession session = request.getSession();
		String username = session.getAttribute("username").toString();
		
		if(p==0) {
			String query2 = "select * from writer where username = ?";
			String json = DbHelper.executeQueryJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
					new Object[] {username});
			//System.out.print(json);

			try {
				JSONObject j1 = new JSONObject(json) ;
				JSONArray ja = new JSONArray(j1.get("data").toString()) ;
				System.out.print(ja.length());
				if(ja.length()!=0) {

					JSONObject j = ja.getJSONObject(0);

					String writer_id = j.get("writer_id").toString() ;
					String name = j.get("name").toString(); 

					session.setAttribute("writer_id", writer_id);
					session.setAttribute("name", name);

					response.getWriter().print("{\"data\":[\"writer\"],\"status\":true}");
				}
				else {
					response.getWriter().print("{\"data\":[\"writer\"],\"status\":false}");
				}
			}
			catch (Exception e)
			{
				response.getWriter().print(DbHelper.errorJson("Error in Servlet/Database").toString());
			}
		}

			
		else {
			
			String query2 = "select * from volunteer where username = ?";
			String json = DbHelper.executeQueryJson(query2, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
					new Object[] {username});
			//System.out.print(json);

			try {
				JSONObject j1 = new JSONObject(json) ;
				JSONArray ja = new JSONArray(j1.get("data").toString()) ;
				System.out.print(ja.length());
				if(ja.length()!=0) {

					JSONObject j = ja.getJSONObject(0);

					String volunteer_id = j.get("volunteer_id").toString() ;
					String name = j.get("name").toString(); 

					session.setAttribute("volunteer_id", volunteer_id);
					session.setAttribute("name", name);

					response.getWriter().print("{\"data\":[\"volunteer\"],\"status\":true}");
				}
				else {
					response.getWriter().print("{\"data\":[\"volunteer\"],\"status\":false}");
				}
			}
			catch (Exception e)
			{
				response.getWriter().print(DbHelper.errorJson("Error in Servlet/Database").toString());
			}
			
		}
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
