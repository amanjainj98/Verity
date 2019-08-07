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
 * Servlet implementation class VolunteerSignUp
 */
@WebServlet("/VolunteerSignUp")
public class VolunteerSignUp extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerSignUp() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request,response) ; 

		}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		if(session.getAttribute("writer_id") == null) { // logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in"));
			return ;		
			}
		
		
		String username = session.getAttribute("username").toString();
		String name = session.getAttribute("name").toString();
		String tags = (String) request.getParameter("tags");

				
		String query = "insert into volunteer (username,name) values(?,?) returning volunteer_id";
		
		String res = DbHelper.executeQueryJson (query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.STRING,DbHelper.ParamType.STRING}, 
				new Object[] {username,name});
		
		System.out.println("VolunteerSignUp: " + res) ;
		
		try {
		
		JSONObject j = new JSONObject(res) ;
		
		if (j.get("status").toString() == "true") {
			JSONArray ja = new JSONArray(j.get("data").toString()) ;
			JSONObject jj = ja.getJSONObject(0);
			Integer volunteer_id = Integer.parseInt(jj.get("volunteer_id").toString());
			session.setAttribute("volunteer_id", volunteer_id);
			
			//System.out.println("WriterSignUp: Writer_id = " + String.valueOf(writer_id)) ;
			System.out.println("VolunteerSignUp: " + res) ;
			//session.setAttribute("username", username);
			//session.setAttribute("name", name);
			
			String json3 = "" ;
			JSONArray j3 = new JSONArray(tags) ;
			
			for (int i=0;i<j3.length();i++) {
				String query3 = "insert into volunteer_tag values (?, (select tag_id from tag where tag_name=?),5.0,5.0)";
				json3 = DbHelper.executeUpdateJson(query3, 
						new DbHelper.ParamType[] {DbHelper.ParamType.INT,  DbHelper.ParamType.STRING},
						new Object[] { volunteer_id, j3.get(i) });	
				JSONObject temp = new JSONObject(json3) ;
				if (temp.get("status").toString() == "false")
				{
					response.getWriter().print(DbHelper.errorJson("Error inserting tags into database"));
					return ;
				}
			}
			
		}
		response.getWriter().println(DbHelper.okJson()) ;		
		}
		catch(Exception e) {
			e.printStackTrace();
		}

		
	}

}
