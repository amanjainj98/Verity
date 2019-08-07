package com.verity.www ;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.*;

/**
 * Servlet implementation class VolunteerGetSections
 */
@WebServlet("/VolunteerGetSections")
public class VolunteerGetSections extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerGetSections() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		if(session.getAttribute("volunteer_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		
		Integer article_id = Integer.parseInt(request.getParameter("article_id").toString());
		Integer volunteer_id = Integer.parseInt(session.getAttribute("volunteer_id").toString());
		PrintWriter out = response.getWriter();
		
		int max_users = 0;
		
		try {


		String query = "select body from article where article_id = ? ";
		String res = DbHelper.executeQueryJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});

		JSONObject j = new JSONObject(res) ;
		
		
		
		if (j.get("status").toString() == "false") {		
			out.print(res); 
			return ; 
		}
		


		
		
		String query2 = "select section_id, length "
				+ "from section "
				+ "where article_id = ? ";
		String res2 = DbHelper.executeQueryJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
				new Integer[] {article_id});
		
		JSONObject j2 = new JSONObject(res2) ;

		if (j2.get("status").toString() == "false") {		
			out.print(res2); 
			return ; 
		}
		
		JSONObject output = new JSONObject() ;
		output.put("status", "true");
		output.put("body", j.get("data")) ;
		output.put("section", j2.get("data")) ;
		
		out.print(output) ;
		
		System.out.println(output);
		}
		
		catch (Exception e) {
			
			e.printStackTrace();
		}
		
		

		
		try {
			
			String query4 = "select tag_id, ex_rating from volunteer_tag where volunteer_id = ? and "
					+ "tag_id in ( select tag_id from article_tag where article_id = ?) and 0 in"
					+ " (select status from article_volunteer where article_id = ? and volunteer_id = ?)" ;
			List<List<Object>> res4 = DbHelper.executeQueryList(query4, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,
							},
					new Object[] {volunteer_id,article_id, article_id, volunteer_id});
			
			System.out.println("VolunteerGetSections res4 " + res4.toString()) ;
		
//			if (res4 == null || res4.isEmpty()) {
//				System.out.println(DbHelper.errorJson("Couldn't update values of rating "));
//				return ; 
//			}
			
			for (int i=0;i<res4.size();i++) {

				double x = Double.parseDouble(String.valueOf(res4.get(i).get(1)));
				if (x == 10.0) x = 9.9 ;
				if (x == 0.0) x = 0.1 ; 
				double ex =  Math.log(x/(10.0-x)) + 1 ; 
				double ans = 10.0 / (1 + Math.exp(-ex)) ;

				System.out.println("New Value of tag + " + String.valueOf(ans)) ; 
				
				String query5 = "update volunteer_tag set ex_rating = cast (? as float) "
						+ " where tag_id = ? and volunteer_id = ?" ;
				String res5 = DbHelper.executeUpdateJson(query5, 
						new DbHelper.ParamType[] {
								DbHelper.ParamType.STRING,  
								DbHelper.ParamType.INT,  
								DbHelper.ParamType.INT,
								},
						new Object[] {String.valueOf(ans), 
								Integer.parseInt(String.valueOf(res4.get(i).get(0))), 
								volunteer_id});
							
				if (res5.contains("false")) {
					System.out.println(DbHelper.errorJson(res5));
					return ; 
				}
			}
				
		String query = "update article_volunteer "
				+ "set status = ? where article_id = ? and volunteer_id = ? ";
		String json = DbHelper.executeUpdateJson(query, 
				new DbHelper.ParamType[] {
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,
						DbHelper.ParamType.INT,},
				new Object[] {2,article_id, volunteer_id});
		
		System.out.println("VolunteerGetSections " + json);
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
	
	/**
	 * For testing other methods in this class.
	 */
	public static void main(String[] args) throws ServletException, IOException {
		new VolunteerGetSections().doGet(null, null);
	}

}
