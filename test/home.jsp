<%-- 
  프로젝트 전체구조
  1. Tailwind CDN 포함
  2. jQuery 포함
  3. 전체 구조만 뼈대 잡기 (스타일은 나중에)
--%>

<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.auth.JwtUtil" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="java.util.Optional" %>
<%
    String accessToken = null;
    String refreshToken = null;
    boolean isAuthenticated = false;

    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("accessToken".equals(cookie.getName())) {
                accessToken = cookie.getValue();
            } else if ("refreshToken".equals(cookie.getName())) {
                refreshToken = cookie.getValue();
            }
        }
    }

    if (accessToken != null && JwtUtil.isValid(accessToken)) {
        isAuthenticated = true;
    } else if (refreshToken != null && JwtUtil.isValid(refreshToken)) {
        // Refresh 토큰으로 Access 토큰 재발급
        String newAccessToken = JwtUtil.reissueAccessToken(refreshToken);
        if (newAccessToken != null) {
            Cookie newAccessCookie = new Cookie("accessToken", newAccessToken);
            newAccessCookie.setPath("/");                // 쿠키가 모든 경로에서 사용 가능하도록 설정
            newAccessCookie.setHttpOnly(true);           // JavaScript에서 쿠키를 읽을 수 없도록 설정
            newAccessCookie.setSecure(true);             // HTTPS에서만 쿠키가 전송되도록 설정
            newAccessCookie.setSameSite("Strict");       // 타 사이트에서 쿠키 전송을 막음
            response.addCookie(newAccessCookie);         // 응답에 쿠키 추가
    isAuthenticated = true;
        }
    }
%>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>커뮤니티 홈</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- jQuery CDN -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body class="bg-gray-100 text-gray-900">

    <!-- ✅ Header -->
    <header class="bg-white shadow p-4 flex items-center relative">
      <%-- 
        bg-white : 배경 흰색
        shadow : 그림자
        p-4 : 패딩 16px
        flex : flexbox 사용
        items-center : 수직 중앙 정렬
        relative : 자기 자신의 원래 위치를 기준으로 이동
        즉, relative를 써도 눈에는 변화가 없음
        단, 자식 요소가 absolute일 때 기준점 역할을 해줌
      --%>
        <!-- 사이트 이름 -->
        <h1 class="text-2xl font-bold absolute left-1/2 transform -translate-x-1/2">📰 My 커뮤니티</h1>
        <%--
            text-2xl : 글자 크기
            font-bold : 굵게
            absolute : 절대 위치
            가장 가까운 relative나 absolute 또는 fixed 조상 요소를 기준으로 위치함
            그게 없으면 <body> 기준
            left-1/2 : 왼쪽에서 50%
            transform -translate-x-1/2 : 자기 크기의 절반만큼 왼쪽으로 이동해서 중앙 정렬
        --%>

        <!-- 🔐 로그인/회원가입 or 로그아웃 메뉴 -->
        <div class="ml-auto mr-4">
            <% if (isAuthenticated) { %>
                <a href="user/logout.jsp" class="text-sm text-red-600 hover:underline">로그아웃</a>
            <% } else { %>
                <a href="user/login.jsp" class="text-sm text-blue-600 hover:underline mr-4">로그인</a>
                <a href="user/register.jsp" class="text-sm text-gray-600 hover:underline">회원가입</a>
            <% } %>
        </div>
    </header>

    <!-- ✅ Main content -->
    <main class="p-6">
        <!-- 게시판 리스트 영역 -->
        <section class="mb-8">
            <h2 class="text-xl font-semibold mb-4">📌 최신 게시글</h2>
            <div class="border rounded-lg p-4 bg-white">
                <!-- 여기에 게시글 리스트 표시될 예정 -->
                <p>게시글 리스트 자리</p>
            </div>
        </section>

        <!-- 공지사항 영역 -->
        <section class="mb-8">
            <h2 class="text-xl font-semibold mb-4">📢 공지사항</h2>
            <div class="border rounded-lg p-4 bg-white">
                <!-- 공지사항 리스트 자리 -->
                <p>공지사항 자리</p>
            </div>
        </section>

        <!-- 인기글 영역 -->
        <section>
            <h2 class="text-xl font-semibold mb-4">🔥 인기글</h2>
            <div class="border rounded-lg p-4 bg-white">
                <!-- 인기글 리스트 자리 -->
                <p>인기글 자리</p>
            </div>
        </section>
    </main>

    <!-- ✅ Footer -->
    <footer class="bg-white border-t p-4 mt-8 text-center text-sm text-gray-600">
        &copy; 2025 My Community. All rights reserved.
    </footer>

</body>
</html>
