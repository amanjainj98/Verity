package com.verity.www ;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

/**
 * Servlet implementation class VolunteerRateComment
 */
@WebServlet("/VolunteerRateComment")

public class VolunteerRateComment extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerRateComment() {
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
			
		
		Integer volunteer_id= Integer.parseInt(session.getAttribute("volunteer_id").toString());
		Integer article_id  = Integer.parseInt(request.getParameter("article_id").toString()) ;
		Integer section_id  = Integer.parseInt(request.getParameter("section_id").toString()) ;
		Integer comment_id 	= Integer.parseInt(request.getParameter("comment_id").toString()) ;
		Integer rating 		= Integer.parseInt(request.getParameter("rating").toString()) ;
		
		String query = "insert into comment_rating(comment_id,section_id,article_id,volunteer_id,rating)"
				+ "values (?,?,?,?,?) ";
		String json = DbHelper.executeUpdateJson(query, 
				new DbHelper.ParamType[] {
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,},
				new Object[] {comment_id,section_id,article_id,volunteer_id,rating});

		response.getWriter().print(json);
		
		// update my exp
		String query4 = "select tag_id, ex_rating, acc_rating from volunteer_tag where volunteer_id = ? and "
				+ "tag_id in ( select tag_id from article_tag where article_id = ? )" ;
		List<List<Object>> res4 = DbHelper.executeQueryList(query4, 
				new DbHelper.ParamType[] {
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,  
						},
				new Object[] {volunteer_id,article_id});
		
		System.out.println("VolunteerRateComment res4 " + res4.toString()) ;
	
		if (res4 == null || res4.isEmpty()) {
			response.getWriter().println(DbHelper.errorJson("Couldn't update values of rating "));
			return ; 
		}
		
		for (int i=0;i<res4.size();i++) {

			
			// 
			double x = Double.parseDouble(String.valueOf(res4.get(i).get(1)));
			if (x == 10.0) x = 9.9 ;
			if (x == 0.0) x = 0.1 ; 
			double ex1 =  Math.log(x/(10.0-x)) + 1.0 ; 
			double ans1 = 10.0 / (1 + Math.exp(-ex1)) ;

			double y = Double.parseDouble(String.valueOf(res4.get(i).get(2)));
			if (y == 10.0) x = 9.9 ;
			if (y == 0.0) x = 0.1 ; 
			double ex2 =  Math.log(x/(10.0-x)) + 1.0 ; 
			double ans2 = 10.0 / (1 + Math.exp(-ex2)) ;

			
			System.out.println("New Value of tag + " + String.valueOf(ans1) + " " + String.valueOf(ans2)) ; 
			
			String query5 = "update volunteer_tag set (ex_rating, acc_rating) = (cast (? as float), cast (? as float)) "
					+ " where tag_id = ? and volunteer_id = ? " ;
			String res5 = DbHelper.executeUpdateJson(query5, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.STRING,  
							DbHelper.ParamType.STRING,  
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,
							},
					new Object[] {
							String.valueOf(ans1),
							String.valueOf(ans2), 
							Integer.parseInt(String.valueOf(res4.get(i).get(0))), 
							volunteer_id});
			try {			
			JSONObject jj = new JSONObject(res5) ;
			if (jj.get("status").toString() == "false") {
				response.getWriter().println(DbHelper.errorJson(res5));
				System.out.println("Error + " + res5) ;
				return ; 
			}
			}
			catch (Exception e) {
				e.printStackTrace();
			}
			System.out.println("Updated tags") ;
			
		}
			
			// Now update expertise of rating whose comment it was
			String query2 = "select volunteer_id from comment where article_id = ? and section_id = ? and comment_id = ?" ;
			List<List<Object>> json2 = DbHelper.executeQueryList(query2, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,},
					new Object[] {article_id,section_id,comment_id});
			
			
			if (json2 == null || json2.size()==0) {
				response.getWriter().println(DbHelper.errorJson("VolunteerRateComment query2 error"));
				return ; 
			}
			
			
			
			// update the accuracy in this case. 
			String query6 = "select tag_id, acc_rating from volunteer_tag where volunteer_id = ? and "
					+ "tag_id in ( select tag_id from article_tag where article_id = ? ) " ;
			List<List<Object>> res6 = DbHelper.executeQueryList(query6, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT, 
							},
					new Object[] {Integer.parseInt(json2.get(0).get(0).toString()),article_id});
			
			System.out.println("Updated accuracy " + res6.toString());
			System.out.println("VolunteerRateComment res6 " + res6.toString()) ;
		
			if (res6 == null || res6.isEmpty()) {
				response.getWriter().println(DbHelper.errorJson("Couldn't update values of rating "));
				return ; 
			}
			
			for (int j=0;j<res6.size();j++) {

				double x1 = Double.parseDouble(String.valueOf(res6.get(j).get(1)));
				if (x1 == 10.0) x1 = 9.9 ;
				if (x1 == 0.0) x1 = 0.1 ; 
				double ex =  Math.log(x1/(10.0-x1)) + 1.0 ; 
				double ans = 10.0 / (1 + Math.exp(-ex)) ;

				System.out.println("New Value of tag + " + String.valueOf(ans)) ; 
				
				String query7 = "update volunteer_tag set acc_rating = cast (? as float) "
						+ " where tag_id = ? and volunteer_id = ?" ;
				String res7 = DbHelper.executeUpdateJson(query7, 
						new DbHelper.ParamType[] {
								DbHelper.ParamType.STRING,  
								DbHelper.ParamType.INT,  
								DbHelper.ParamType.INT,
								},
						new Object[] {String.valueOf(ans), 
								Integer.parseInt(String.valueOf(res6.get(j).get(0))),
								Integer.parseInt(String.valueOf(json2.get(j).get(0))),
								});
							
				if (res7.contains("false")) {
					response.getWriter().print(DbHelper.errorJson(res7));
					return ; 
				}
			}
			
			System.out.println("Done Rating");
				
		}
		

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		doGet(request, response);
	}

}
