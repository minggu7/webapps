<%@ page import="java.sql.*" %> <!-- JDBC 라이브러리: DB 연결 및 쿼리 실행용 -->
<%@ page import="javax.servlet.http.*, javax.servlet.*" %> <!-- HTTP 요청/응답, 쿠키 등 웹 관련 클래스 -->
<%@ page import="io.jsonwebtoken.*" %> <!-- JWT 라이브러리: 토큰 생성/검증 -->
<%@ page import="java.util.Date" %> <!-- 날짜/시간 처리용 -->
<%@ page contentType="text/html; charset=UTF-8" language="java" %> <!-- 페이지 인코딩 설정 -->

<%@ include file="../common/dbConfig.jsp" %> <!-- 공통 DB 설정 포함 -->

<%
    request.setCharacterEncoding("UTF-8"); // 한글 깨짐 방지
    String username = request.getParameter("username"); // 로그인 폼에서 아이디 받기
    String password = request.getParameter("password"); // 로그인 폼에서 비밀번호 받기

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 드라이버 로드
        conn = DriverManager.getConnection(url, dbUser, dbPass); // DB 연결

        // 🔐 로그인 정보 확인 (※ 평문 비밀번호로 비교 중. 추후 BCrypt 적용 예정)
        String sql = "SELECT * FROM user WHERE username = ? AND password = ?";
        pstmt = conn.prepareStatement(sql); // SQL 준비
        pstmt.setString(1, username); // 첫 번째 ?에 사용자명 넣기
        pstmt.setString(2, password); // 두 번째 ?에 비밀번호 넣기
        rs = pstmt.executeQuery(); // 쿼리 실행

        if (rs.next()) { // ✅ 로그인 성공 시
            String secretKey = "MySuperSecretKey1234567890"; // 토큰 서명용 비밀키

            long nowMillis = System.currentTimeMillis(); // 현재 시간 (밀리초 단위)
            Date now = new Date(nowMillis); // Date 타입으로 변환

            // ✅ Access Token (1시간 유효)
            Date accessExp = new Date(nowMillis + 1000 * 60 * 60); // 현재 + 1시간
            String accessToken = Jwts.builder()
                .setSubject(username) // 토큰 주제: 사용자 이름
                .setIssuedAt(now) // 토큰 발급 시각
                .setExpiration(accessExp) // 토큰 만료 시각
                .signWith(SignatureAlgorithm.HS256, secretKey.getBytes("UTF-8")) // HS256 알고리즘으로 서명
                .compact(); // JWT 문자열 생성

            // ✅ Refresh Token (7일 유효)
            Date refreshExp = new Date(nowMillis + 1000L * 60 * 60 * 24 * 7); // 현재 + 7일
            String refreshToken = Jwts.builder()
                .setSubject(username) // 주제 동일
                .setIssuedAt(now) // 발급 시각
                .setExpiration(refreshExp) // 만료 시각
                .signWith(SignatureAlgorithm.HS256, secretKey.getBytes("UTF-8")) // 서명
                .compact(); // JWT 생성

            // ✅ Access Token → 쿠키에 저장
            Cookie accessCookie = new Cookie("access_token", accessToken); // 쿠키 이름 access_token
            accessCookie.setHttpOnly(true); // JavaScript 접근 금지
            accessCookie.setPath("/"); // 사이트 전체에서 사용 가능
            accessCookie.setMaxAge(60 * 60); // 1시간 유지
            response.addCookie(accessCookie); // 응답에 쿠키 추가

            // ✅ Refresh Token → 쿠키에 저장
            Cookie refreshCookie = new Cookie("refresh_token", refreshToken); // 쿠키 이름 refresh_token
            refreshCookie.setHttpOnly(true); // 보안 설정
            refreshCookie.setPath("/"); // 전체 경로 사용
            refreshCookie.setMaxAge(60 * 60 * 24 * 7); // 7일 유지
            response.addCookie(refreshCookie); // 응답에 추가

            // ✅ Refresh Token → DB에 저장 (나중에 검증/로테이션용)
            String updateSql = "UPDATE user SET refresh_token = ? WHERE username = ?";
            pstmt = conn.prepareStatement(updateSql); // 새 쿼리 준비
            pstmt.setString(1, refreshToken); // 첫 번째 ?에 refresh token
            pstmt.setString(2, username); // 두 번째 ?에 사용자명
            pstmt.executeUpdate(); // DB 업데이트

            response.sendRedirect("../home.jsp"); // 홈 화면으로 리다이렉트

        } else {
%>
            <!-- ❌ 로그인 실패 -->
            <script>
                alert("❌ 아이디 또는 비밀번호가 잘못되었습니다.");
                history.back(); // 이전 페이지로
            </script>
<%
        }

    } catch (Exception e) {
        e.printStackTrace(); // 에러 출력
%>
        <p>DB 오류 발생: <%= e.getMessage() %></p> <!-- 사용자에게 오류 메시지 출력 -->
<%
    } finally {
        // ✅ 자원 해제
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
