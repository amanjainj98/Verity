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

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet implementation class VolunteerSubmitArticle
 */
@WebServlet("/VolunteerSubmitArticle")

public class VolunteerSubmitArticle extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerSubmitArticle() {
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
	
		PrintWriter out = response.getWriter() ;
		Integer volunteer_id = Integer.parseInt(session.getAttribute("volunteer_id").toString());
		Integer article_id   = Integer.parseInt(request.getParameter("article_id").toString()) ;
		
		String query = "update article_volunteer "
				+ "set status = ? where article_id = ? and volunteer_id = ? ";
		String json = DbHelper.executeUpdateJson(query, 
				new DbHelper.ParamType[] {
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,
						DbHelper.ParamType.INT,},
				new Object[] {3,article_id, volunteer_id});
		
		try {
			JSONObject j = new JSONObject(json) ;
			if (j.get("status").toString() == "false") {
				out.print(json);
				return ; 
			}
			
			// Experience rating increase
			String query4 = "select tag_id, ex_rating from volunteer_tag where volunteer_id = ? and "
					+ "tag_id in ( select tag_id from article_tag where article_id = ?)";
			List<List<Object>> res4 = DbHelper.executeQueryList(query4, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,  
							},
					new Object[] {volunteer_id,article_id});
			
			System.out.println("VolunteerGetSections res4 " + res4.toString()) ;
		
			if (res4 == null || res4.isEmpty()) {
				out.println(DbHelper.errorJson("Couldn't update values of rating "));
				return ; 
			}
			
			for (int i=0;i<res4.size();i++) {

				double x = Double.parseDouble(String.valueOf(res4.get(i).get(1)));
				if (x == 10.0) x = 9.9 ;
				if (x == 0.0) x = 0.1 ; 
				double ex =  Math.log(x/(10.0-x)) + 1.0 ; 
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
					out.println(DbHelper.errorJson(res5));
					return ; 
				}
			}
			
			String query5 = "select max_users from article where article_id = ? ";
			String res = DbHelper.executeQueryJson(query5, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT}, 
					new Integer[] {article_id});

			JSONObject j5 = new JSONObject(res) ;
			
			JSONArray jj5 = new JSONArray(j5.get("data").toString()) ;
			JSONObject jo5 = jj5.getJSONObject(0) ;
			int max_users = Integer.parseInt(jo5.get("max_users").toString()) ;
			
			System.out.println(String.valueOf(max_users)) ;
			
			
			
			String query3 = "select count(*) from article_volunteer "
					+ "where article_id = ? and status=3";
			String json3 = DbHelper.executeQueryJson(query3, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,},
					new Object[] {article_id});
			
			System.out.println("VolunteerGetSections " + json3);
			
			
			JSONObject j3 = new JSONObject(json3) ;
			
			JSONArray jj3 = new JSONArray(j3.get("data").toString()) ;
			JSONObject jo3 = jj3.getJSONObject(0) ;
			int total_submitted = Integer.parseInt(jo3.get("count").toString()) ;
			
			System.out.print(total_submitted);
			
			
			if(total_submitted >= max_users) {
				return;
			}
			
			System.out.println("Routing further");
			
			
			String query2 = "update article_volunteer "
					+ "set status = 0 where article_id = ? and "
					+ "now() < (select end_time from article where article_id = ?) and "
					+ "volunteer_id = (select volunteer_id from article_volunteer where"
					+ " status = 4 and rating = (select max(rating) from article_volunteer where article_id = ? and status = 4 ) limit 1 ) ";
			String json2 = DbHelper.executeUpdateJson(query2, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,
							DbHelper.ParamType.INT,},
					new Object[] {article_id,article_id,article_id});
			
			JSONObject j2 = new JSONObject(json2) ;
			
			out.print(DbHelper.okJson());
			
		}
		catch (Exception e) {
			
		}

	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		doGet(request, response);
	}

}
