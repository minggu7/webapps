<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <!-- ✅ Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center h-screen">
    
    <!-- 🔐 로그인 카드 -->
    <div class="bg-white p-8 rounded-xl shadow-md w-full max-w-sm">
        <h2 class="text-2xl font-bold text-center mb-6">🔐 로그인</h2>
        
        <!-- ✅ 로그인 폼 -->
        <form action="login_process.jsp" method="post" class="space-y-4">
            
            <!-- 🔹 아이디 입력 -->
            <div>
                <label for="username" class="block text-sm font-medium text-gray-700">아이디</label>
                <input type="text" name="username" id="username"
                    class="mt-1 block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    placeholder="아이디를 입력하세요" required>
            </div>
            
            <!-- 🔹 비밀번호 입력 -->
            <div>
                <label for="password" class="block text-sm font-medium text-gray-700">비밀번호</label>
                <input type="password" name="password" id="password"
                    class="mt-1 block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    placeholder="비밀번호를 입력하세요" required>
            </div>
            
            <!-- 🔐 로그인 버튼 -->
            <div>
                <button type="submit"
                    class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition">
                    로그인
                </button>
            </div>
        </form>
        
        <!-- 🔗 추가 링크 -->
        <div class="mt-4 text-center text-sm text-gray-600">
            아직 회원이 아니신가요?
            <a href="register.jsp" class="text-blue-600 hover:underline">회원가입</a>
        </div>
    </div>

</body>
</html>
