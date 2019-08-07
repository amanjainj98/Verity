package com.verity.www;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

/**
 * Servlet implementation class VolunteerProfile
 */
@WebServlet("/VolunteerProfile")
public class VolunteerProfile extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerProfile() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		///response.getWriter().append("Served at: ").append(request.getContextPath());
		
		HttpSession session = request.getSession();
		
		if(session.getAttribute("volunteer_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		try {
		
		Integer volunteer_id = Integer.parseInt(session.getAttribute("volunteer_id").toString());
		System.out.println("V_ID"+volunteer_id);
		
		
		
		String query = "select * from volunteer where volunteer_id = ? ";
		String res = DbHelper.executeQueryJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {volunteer_id});
		
		PrintWriter out = response.getWriter();
		System.out.println("VolunteerProfile q1 "+res) ;
//		out.print(res);
		
		JSONObject j = new JSONObject(res) ;
		
		if (j.get("status").toString() == "false") {
			out.println(res);
			return ; 
		}
		
		String query2 = "select tag_id,tag_name,ex_rating,acc_rating from tag natural join volunteer_tag where volunteer_id = ?";
		String res2 = DbHelper.executeQueryJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {volunteer_id});
	
		JSONObject j2 = new JSONObject(res2) ;
				
		System.out.println("VolunteerProfile q2 " + res2) ;
		
		if (j2.get("status").toString() == "false") {		
			out.print(res2); 
			return ; 
		}
		
		JSONObject output = new JSONObject() ; 
		output.put("status","true") ;
		output.put("data", j.get("data")) ;
		output.put("tags", j2.get("data")) ;

		out.print(output.toString());
		
		}
		catch(Exception e) {
			e.printStackTrace();
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
