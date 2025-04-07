<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">

<div class="bg-white p-8 rounded shadow-md w-full max-w-md">
    <h2 class="text-2xl font-bold mb-6 text-center">회원가입</h2>

    <form action="register_process.jsp" method="post" class="space-y-4">
        <div>
            <label class="block text-sm font-medium">아이디</label>
            <input type="text" name="username" required class="w-full border p-2 rounded"/>
        </div>
        <div>
            <label class="block text-sm font-medium">비밀번호</label>
            <input type="password" name="password" required class="w-full border p-2 rounded"/>
        </div>
        <div class="text-center">
            <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                회원가입
            </button>
        </div>
    </form>
</div>

</body>
</html>
