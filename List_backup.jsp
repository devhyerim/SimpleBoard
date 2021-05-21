<%@page import="java.net.URLDecoder"%>
<%@page import="com.test.BoardDTO"%>
<%@page import="java.util.List"%>
<%@page import="com.test.BoardDAO_backup"%>
<%@page import="com.util.MyUtil"%>
<%@page import="com.util.DBConn"%>
<%@page import="java.sql.Connection"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
	String cp = request.getContextPath(); 
	// 서블릿 컨텍스트: 환경설정, 자원관리.
	// 서블릿 컨테이너 안에서 자원 경로를 얻어내겠다.
	// cp 경로 확인 : /WebApp20
%>

<%
	// 이전 페이지(최초 요청일 때는 → ??? 알 수 없음.)로부터 수신(X)
	// 이전 페이지(페이징 접근 → List.jsp) 요청 →           (pageNum 수신)
	
	// EX) 글을 클릭해서 보고, '목록으로' 를 누르면
	//     1페이지가 아니라 원래 있었던 페이지로 가야 한다.
	//     따라서 넘어온 페이지 번호를 저장해놓고 목록으로 눌렀을 때 해당 페이지로 가게 해야한다.
	// 넘어온 페이지 번호 확인
	String pageNum = request.getParameter("pageNum");
	int currentPage = 1;	//-- 현재 표시되어야 하는 (머무르고 있는) 페이지
	
	if(pageNum != null)
		currentPage = Integer.parseInt(pageNum); 
	
	// 검색 기능 추가
	// → 검색키와 검색값 수신
	String searchKey = request.getParameter("searchKey");
	String searchValue = request.getParameter("searchValue");
	
	if (searchKey!=null) //-- 검색 기능을 통해 페이지가 요청되었을 때
	{
		// 넘어온 값이 GET 방식이라면
		// → GET은 한글 문자열을 인코딩해서 보내기 때문에, 디코딩 처리 필요
		//    (url에 subject=음식 이런식으로 나온다.)
		
		// 요청된 방식이 get 방식인지 확인
		if(request.getMethod().equalsIgnoreCase("GET"))	//대문자, 소문자 상관없이 비교하기 위해 ignorecase 사용!!!
		{
	// 디코딩 처리
	searchValue = URLDecoder.decode(searchValue, "UTF-8");
		}
		
	}else				//-- 검색이 아닌 기본적인 페이지 요청이 이뤄졌을 때
	{
		searchKey = "subject";
		searchValue = "";
	}
	
	
	// DAO에는 기본 생성자가 없고, 사용자 정의 생성자로 Connection을 넘겨주게 되어 있으므로
	// 여기서 생성해 보낸다.
	Connection conn = DBConn.getConnection();
	BoardDAO_backup dao = new BoardDAO_backup(conn);
	MyUtil myUtil = new MyUtil();
	
	// 검색기능 추가하면서 메소드 매개변수 추가
	// 전체 데이터 개수 구하기
	// int dataCount = dao.getDataCount();
	int dataCount = dao.getDataCount(searchKey, searchValue);
	
	// 전체 페이지를 기준으로 총 페이지 수 계산
	int numPerPage = 10;	//-- 한 페이지에 표시할 데이터 개수 (한 페이지에 게시물 10개씩)
	int totalPage = myUtil.getPageCount(numPerPage, dataCount);
	
	// 11 페이지 있다가, 글이 삭제되어서 totalPage가 8로 줄어든다면
	// 11 페이지에 있던 사람은 목록으로 가거나 새로고침 했을 때 8페이지로 가야 한다.
	// 전체 페이지 수보다 표시할 페이지가 큰 경우 표시할 페이지를 전체 페이지로 처리
	//- 한마디로, 데이터를 삭제해서 페이지가 줄었을 경우
	if(currentPage > totalPage)
		currentPage = totalPage;
	
	// 데이터베이스에서 가져올 시작과 끝 위치
	int start = (currentPage-1) * numPerPage + 1;
	int end = currentPage * numPerPage;
	
	// 검색 기능 추가하면서 메소드 매개변수 변경
	// 실제 리스트 가져오기
	// List<BoardDTO> lists = dao.getLists(start, end);
	List<BoardDTO> lists = dao.getLists(start, end, searchKey, searchValue);
	
	// 페이징 처리
	String param = ""; //-- 검색할 시, searchKey=name&searchValue='홍길동' 처럼 문자열 붙이기 위해 구성
	
	// 검색 기능 추가.. → param 구성
	// 검색값이 존재한다면
	if(!searchValue.equals(""))    //searchValue가 비어있지 않다면 (검색값이 존재)
	{
		param += "?searchKey=" + searchKey;
		param += "&searchValue=" + searchValue;
	}
	
	
	String listUrl = "List.jsp" + param;
	String pageIndexList = myUtil.pageIndexList(currentPage, totalPage, listUrl);
	
	// 글 내용보기 눌렀을 때 주소로 연결
	String articleUrl = cp + "/Article.jsp?"; //cp=WebApp20
	
	if(param.equals(""))		// 아직 검색한 내용 없는 경우
		articleUrl = articleUrl + "?pageNum=" + currentPage;	
	else						// 검색한 내용이 있는 경우
		articleUrl = articleUrl + param + "&pageNum=" + currentPage;
	
	DBConn.close();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>List.jsp</title>
<link rel="stylesheet" type="text/css" href="<%=cp %>/css/style.css">
<link rel="stylesheet" type="text/css" href="<%=cp %>/css/list.css">

<script type="text/javascript">

	// 검색
	function sendIt()
	{
		var f = document.searchForm;
		
		// 검색 키워드에 대한 유효성 검사 코드 활용 가능!!!
		f.action = "<%=cp%>/List.jsp";
		f.submit();
	}

</script>

</head>
<body>

<div id="bbsList">
	
	<div id="bbsList_title">
		게 시 판 (JDBC 연동 버전)
	</div>
	
	<div id="bbsList_header">
		
		<div id="leftHeader">
			<form action = "" name="searchForm" method="post">
				<select name="searchKey" class="selectField">
					<option value="subject">제목</option>
					<option value="name">작성자</option>
					<option value="content">내용</option>
				</select>
				<input type="text" name="searchValue" class="textField">
				<input type="button" value="검색" class="btn2" onclick="sendIt()">
			</form>
		</div><!-- #leftHeader -->
		
		<div id="rightHeader">
			<input type="button" value="글올리기" class="btn2"
			onclick="javascript:location.href='<%=cp%>/Created.jsp'">
		</div>
	
	</div><!-- #bbsList_header -->
	
	<div id="bbsList_list">
		<div id="title">
			<dl>
				<dt class="num">번호</dt>
				<dt class="subject">제목</dt>
				<dt class="name">작성자</dt>
				<dt class="created">작성일</dt>
				<dt class="hitCount">조회수</dt>
			</dl>
		</div><!-- #title -->
		
		<div id="lists">
			<!-- 예시 데이터
			<dl>
				<dd class="num">1</dd>
				<dd class="subject">안녕하세요</dd>
				<dd class="name">이희주</dd>
				<dd class="created">2021-05-21</dd>
				<dd class="hitCount">0</dd>
			</dl>
			-->
			
			<%
			for (BoardDTO dto : lists)
			{
			%>
			<dl>
				<dd class="num"><%=dto.getNum() %></dd>
				<dd class="subject">
					<a href="<%=articleUrl%>&num=<%=dto.getNum()%>">
					<%=dto.getSubject() %>
					</a>
				</dd>
				<dd class="name"><%=dto.getName() %></dd>
				<dd class="created"><%=dto.getCreated() %></dd>
				<dd class="hitCount"><%=dto.getHitCount() %></dd>
			</dl>
			<%
			}
			%>
			
			
		</div><!-- #lists-->
		
		<div id="footer">
			<!-- <p>1 Prev 21 22 23 24 25 26 27 28 29 30 Next 63</p> -->
			
			<p>
			<%
			if(dataCount != 0)
			{
			%>
				<%=pageIndexList %>
			<%
			}
			else
			{
			%>
				등록된 게시물이 존재하지 않습니다.
			<%
			}
			%>
			</p>
			
		</div>
		
	</div><!-- #bbsList_list -->
	
</div><!-- #bbsList -->

</body>
</html>