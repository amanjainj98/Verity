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
 * Servlet implementation class WriterSectionDetails
 */
@WebServlet("/WriterSectionDetails")
public class WriterSectionDetails extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public WriterSectionDetails() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		if(session.getAttribute("writer_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}


		Integer article_id = Integer.parseInt(request.getParameter("article_id").toString());
		Integer section_id = Integer.parseInt(request.getParameter("section_id").toString());
		String query = "select c.comment_id, c.text , coalesce(avg(rating),0) as avg, count(rating) as cnt "
				+ "from comment as c left outer join comment_rating as cr on "
				+ "c.comment_id = cr.comment_id and c.article_id=cr.article_id "
				+ "where c.article_id = ? and c.section_id = ? "
				+ "group by c.comment_id, c.text "
				+ "order by cnt desc";
		String res = DbHelper.executeQueryJson(query, 
				new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT}, 
				new Integer[] {article_id, section_id});
		
		PrintWriter out = response.getWriter();
		out.print(res);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response) ; 
	}
}
