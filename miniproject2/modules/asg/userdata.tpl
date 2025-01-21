#!/bin/bash

sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel

sudo systemctl enable --now httpd

cat << \EOF > /var/www/html/index.php
<?php
// 데이터베이스 연결 설정
$host = '$';
$username = '${db_username}';
$password = '${db_password}';
$dbname = 'dinner_menu';

$conn = mysqli_connect($host, $username, $password, $dbname);

if (!$conn) {
  die("데이터베이스 연결 실패: " . mysqli_connect_error());
}

mysqli_set_charset($conn, "utf8");

// 메뉴 추가 처리
if (isset($_POST['add_menu'])) {
  $new_menu = trim($_POST['new_menu']);
  $category = $_POST['category'];

  if (!empty($new_menu)) {
    $add_query = "INSERT INTO menus (menu_name, category) VALUES ('$new_menu', '$category')";
    mysqli_query($conn, $add_query);
  }
}

// 메뉴 삭제 처리
if (isset($_POST['delete_menu'])) {
  $menu_id = $_POST['menu_id'];
  $delete_query = "DELETE FROM menus WHERE id = $menu_id";
  mysqli_query($conn, $delete_query);
}

// 랜덤 메뉴 선택
$random_menu_query = "SELECT * FROM menus ORDER BY RAND() LIMIT 1";
$random_result = mysqli_query($conn, $random_menu_query);
$random_menu = mysqli_fetch_assoc($random_result);

// 전체 메뉴 목록 조회
$menu_list_query = "SELECT * FROM menus ORDER BY category, menu_name";
$menu_list_result = mysqli_query($conn, $menu_list_query);
?>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>오늘 저녁 메뉴 추천</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .random-menu {
      background-color: #f0f0f0;
      padding: 20px;
      text-align: center;
      margin-bottom: 20px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 8px;
      text-align: left;
    }
  </style>
</head>
<body>
  <div class="random-menu">
    <h1>오늘의 저녁 메뉴</h1>
    <?php if ($random_menu): ?>
      <h2><?= htmlspecialchars($random_menu['menu_name']) ?></h2>
      <p>카테고리: <?= htmlspecialchars($random_menu['category']) ?></p>
    <?php endif; ?>

    <form method="post">
      <button type="submit" name="random_menu">다른 메뉴 추천받기</button>
    </form>
  </div>

  <h2>메뉴 추가</h2>
  <form method="post">
    <input type="text" name="new_menu" placeholder="새 메뉴 이름" required>
    <select name="category">
      <option value="한식">한식</option>
      <option value="중식">중식</option>
      <option value="양식">양식</option>
      <option value="일식">일식</option>
      <option value="기타">기타</option>
    </select>
    <button type="submit" name="add_menu">메뉴 추가</button>
  </form>

  <h2>메뉴 목록</h2>
  <table>
    <tr>
      <th>메뉴</th>
      <th>카테고리</th>
      <th>삭제</th>
    </tr>
    <?php while ($menu = mysqli_fetch_assoc($menu_list_result)): ?>
      <tr>
        <td><?= htmlspecialchars($menu['menu_name']) ?></td>
        <td><?= htmlspecialchars($menu['category']) ?></td>
        <td>
          <form method="post">
            <input type="hidden" name="menu_id" value="<?= $menu['id'] ?>">
            <button type="submit" name="delete_menu">삭제</button>
          </form>
        </td>
      </tr>
    <?php endwhile; ?>
  </table>
</body>
</html>

<?php
// 데이터베이스 연결 종료
mysqli_close($conn);
?>
EOF
