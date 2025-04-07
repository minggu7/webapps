<%@ page import="java.sql.*" %> <!-- JDBC 라이브러리: DB 연결 및 쿼리 실행용 -->
<%@ page import="javax.servlet.http.*, javax.servlet.*" %> <!-- HTTP 요청/응답, 쿠키 등 웹 관련 클래스 -->
<%@ page import="io.jsonwebtoken.*" %> <!-- JWT 라이브러리: 토큰 생성/검증 -->
<%@ page import="java.util.Date" %> <!-- 날짜/시간 처리용 -->
<%@ page import="org.mindrot.jbcrypt.BCrypt" %> <!-- BCrypt 암호화용 -->
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

        // 🔐 비밀번호는 암호화된 값과 비교해야 함
        String sql = "SELECT * FROM user WHERE username = ?";
        pstmt = conn.prepareStatement(sql); // SQL 준비
        pstmt.setString(1, username); // 사용자명 바인딩
        rs = pstmt.executeQuery(); // 쿼리 실행

        if (rs.next()) { // ✅ 사용자 존재
            String dbHashedPw = rs.getString("password"); // DB에 저장된 암호화된 비밀번호

            if (BCrypt.checkpw(password, dbHashedPw)) { // ✅ 비밀번호 일치 시
                String secretKey = "ThisIsASecretKeyThatIsLongEnough123456!"; // 토큰 서명용 비밀키

                long nowMillis = System.currentTimeMillis(); // 현재 시간 (밀리초 단위)
                Date now = new Date(nowMillis); // Date 타입으로 변환

                // ✅ Access Token (1시간 유효)
                Date accessExp = new Date(nowMillis + 1000 * 60 * 60); // 현재 + 1시간
                String accessToken = Jwts.builder()
                    .setSubject(username) // 토큰 주제: 사용자 이름
                    .setIssuedAt(now) // 토큰 발급 시각
                    .setExpiration(accessExp) // 토큰 만료 시각
                    .signWith(SignatureAlgorithm.HS256, secretKey.getBytes("UTF-8")) // 서명
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
                Cookie accessCookie = new Cookie("access_token", accessToken);
                accessCookie.setHttpOnly(true);
                accessCookie.setPath("/");
                accessCookie.setMaxAge(60 * 60); // 1시간
                response.addCookie(accessCookie);

                // ✅ Refresh Token → 쿠키에 저장
                Cookie refreshCookie = new Cookie("refresh_token", refreshToken);
                refreshCookie.setHttpOnly(true);
                refreshCookie.setPath("/");
                refreshCookie.setMaxAge(60 * 60 * 24 * 7); // 7일
                response.addCookie(refreshCookie);

                // ✅ Refresh Token → DB에 저장
                // 먼저 기존에 username으로 등록된 토큰이 있는지 확인
                String checkSql = "SELECT COUNT(*) FROM refresh_token WHERE username = ?";
                pstmt.close();
                pstmt = conn.prepareStatement(checkSql);
                pstmt.setString(1, username);
                rs = pstmt.executeQuery();

                int count = 0;
                if (rs.next()) {
                    count = rs.getInt(1);
                }
                rs.close();
                pstmt.close();

                if (count > 0) {
                    // 이미 존재하면 업데이트
                    String updateSql = "UPDATE refresh_token SET token = ?, is_logged_in = ?, updated_at = NOW(), last_login = NOW() WHERE username = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, refreshToken);
                    pstmt.setBoolean(2, true);
                    pstmt.setString(3, username);
                } else {
                    // 없으면 삽입
                    String insertSql = "INSERT INTO refresh_token (username, token, is_logged_in, created_at, updated_at, last_login) VALUES (?, ?, ?, NOW(), NOW(), NOW())";
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setString(1, username);
                    pstmt.setString(2, refreshToken);
                    pstmt.setBoolean(3, true);
                }

                pstmt.executeUpdate();
                pstmt.close();

                response.sendRedirect("../home.jsp"); // 홈으로 이동

            } else {
%>
                <!-- ❌ 비밀번호 불일치 -->
                <script>
                    alert("❌ 아이디 또는 비밀번호가 잘못되었습니다.");
                    history.back();
                </script>
<%
            }

        } else {
%>
            <!-- ❌ 아이디 없음 -->
            <script>
                alert("❌ 존재하지 않는 계정입니다.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
        e.printStackTrace(); // 콘솔 출력용 로그
%>
        <p>⚠️ 서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.</p>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
