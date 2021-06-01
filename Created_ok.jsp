<%@page import="com.test.BoardDAO"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.util.DBConn"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String cp = request.getContextPath();
%>

<jsp:useBean id="dto" class="com.test.BoardDTO" scope="page"></jsp:useBean>
<jsp:setProperty property="*" name="dto"/>

<%
	//Created_ok.jsp
	Connection conn = DBConn.getConnection();
	BoardDAO dao = new BoardDAO(conn);
	
	// 시퀀스 사용 대신, 현재 게시물의 최대값 얻어오기
	// → 최대값에 1을 더해서 set 해야하므로
	int maxNum = dao.getMaxNum();
	dto.setNum(maxNum+1);
	
	// ipaddress set하기
	dto.setIpAddr(request.getRemoteAddr());
	
	// 데이터베이스 액션 처리
	dao.insertData(dto);
	
	DBConn.close();
	
	// List.jsp 요청할 수 있도록 안내
	response.sendRedirect("List.jsp");
%>