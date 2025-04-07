<%@ page import="java.sql.*" %> <%-- JDBC를 사용하기 위해 java.sql 패키지를 import --%>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %> <%-- HttpServletRequest, HttpSession 등 사용을 위한 import --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %> <%-- 응답 콘텐츠 타입과 문자 인코딩 설정 --%>

<%-- ✅ 공통 DB 설정 파일 불러오기 (URL, 아이디, 비밀번호 포함) --%>
<%@ include file="../common/dbConfig.jsp" %>

<%
    // ✅ 1. 사용자 입력 받기
    request.setCharacterEncoding("UTF-8"); // 한글 입력을 정상적으로 처리하기 위해 요청의 인코딩을 UTF-8로 설정
    String username = request.getParameter("username"); // 로그인 폼에서 전송된 username 파라미터 받기
    String password = request.getParameter("password"); // 로그인 폼에서 전송된 password 파라미터 받기

    // ✅ 2. DB 연결을 위한 객체 선언
    Connection conn = null; // 데이터베이스 연결을 위한 Connection 객체
    PreparedStatement pstmt = null; // SQL 실행을 위한 PreparedStatement 객체
    ResultSet rs = null; // 쿼리 결과를 저장할 ResultSet 객체

    try {
        // ✅ 3. JDBC 드라이버 로드 및 DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL JDBC 드라이버를 메모리에 로드
        conn = DriverManager.getConnection(url, dbUser, dbPass); // 공통설정에서 가져온 DB 정보로 연결

        // ✅ 4. 사용자 정보 조회 SQL 실행
        String sql = "SELECT * FROM user WHERE username = ? AND password = ?"; // 입력값과 일치하는 유저 조회 쿼리
        pstmt = conn.prepareStatement(sql); // 쿼리 준비
        pstmt.setString(1, username); // 첫 번째 물음표(?)에 username 바인딩
        pstmt.setString(2, password); // 두 번째 물음표(?)에 password 바인딩
        rs = pstmt.executeQuery(); // 쿼리 실행 후 결과 반환

        if (rs.next()) {
            // ✅ 로그인 성공 시
            session.setAttribute("username", username); // 세션에 username 저장 (로그인 상태 유지용)

            response.sendRedirect("../home.jsp"); // 홈 페이지로 리다이렉션 (로그인 성공)
        } else {
            // ❌ 로그인 실패 시: 자바스크립트 alert 띄우고 뒤로가기
%>
            <script>
                alert("❌ 아이디 또는 비밀번호가 잘못되었습니다."); // 사용자에게 오류 메시지 보여줌
                history.back(); // 이전 페이지로 이동 (로그인 폼으로)
            </script>
<%
        }

    } catch (Exception e) {
        // ⚠️ DB 연결 또는 SQL 실행 중 예외 발생 시
        e.printStackTrace(); // 서버 콘솔에 에러 로그 출력
%>
        <p>DB 오류 발생: <%= e.getMessage() %></p> <%-- 에러 메시지를 사용자에게 표시 --%>
<%
    } finally {
        // ✅ 사용한 자원 정리 (메모리 누수 방지)
        try { if (rs != null) rs.close(); } catch (Exception e) {} // ResultSet 닫기
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {} // PreparedStatement 닫기
        try { if (conn != null) conn.close(); } catch (Exception e) {} // Connection 닫기
    }
%>
