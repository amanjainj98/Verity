package com.verity.www ;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class VolunteerRemoveArticle
 */
@WebServlet("/VolunteerRemoveArticle")
public class VolunteerRemoveArticle extends HttpServlet {
	private static final long serialVersionUID = 1L;
//	private static final String limit_val = "10" ; 
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public VolunteerRemoveArticle() {
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
		Integer article_id = Integer.parseInt(request.getParameter("article_id").toString()) ;
		
		System.out.println(volunteer_id) ;
		String query = "delete from article_volunteer where volunteer_id = ? and article_id = ?";
		String res = DbHelper.executeUpdateJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT}, 
				new Integer[] {volunteer_id, article_id});
		
		PrintWriter out = response.getWriter();
		System.out.println(res) ;
		out.print(res);
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
		new VolunteerRemoveArticle().doGet(null, null);
	}

}
