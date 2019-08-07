package com.verity.www ;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class VolunteerCreateComment
 */
@WebServlet("/VolunteerCreateComment")

public class VolunteerCreateComment extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerCreateComment() {
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
			
		
		Integer volunteer_id = Integer.parseInt(session.getAttribute("volunteer_id").toString());
		Integer article_id   = Integer.parseInt(request.getParameter("article_id").toString()) ;
		Integer section_id   = Integer.parseInt(request.getParameter("section_id").toString()) ;
		String text 	    = request.getParameter("text") ;
		
		String query = "insert into comment("
				+ "section_id,article_id,text,volunteer_id) "
				+ "values (?,?,?,?) ";
		String json = DbHelper.executeUpdateJson(query, 
				new DbHelper.ParamType[] {
						DbHelper.ParamType.INT,  
						DbHelper.ParamType.INT,
						DbHelper.ParamType.STRING,  
						DbHelper.ParamType.INT,},
				new Object[] {section_id,article_id, text, volunteer_id});

		response.getWriter().print(json);
		
		// Increasing the expertise rating
try {
			
			String query4 = "select tag_id, ex_rating from volunteer_tag where volunteer_id = ? and "
					+ "tag_id in ( select tag_id from article_tag where article_id = ? ) " ;
			List<List<Object>> res4 = DbHelper.executeQueryList(query4, 
					new DbHelper.ParamType[] {
							DbHelper.ParamType.INT,  
							DbHelper.ParamType.INT,  
							},
					new Object[] {volunteer_id,article_id});
			
			System.out.println("VolunteerCreateComment res4 " + res4.toString()) ;
		
			if (res4 == null || res4.isEmpty()) {
				response.getWriter().println(DbHelper.errorJson("Couldn't update values of rating "));
				return ; 
			}
			
			for (int i=0;i<res4.size();i++) {

				double x = Double.parseDouble(String.valueOf(res4.get(i).get(1)));
				if (x == 10.0) x = 9.9 ;
				if (x == 0.0) x = 0.1 ; 
				double ex =  Math.log(x/(10.0-x)) + 10.0 ; 
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
					response.getWriter().print(DbHelper.errorJson(res5));
					return ; 
				}
			}
}
		catch(Exception e) {
			e.printStackTrace();
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
