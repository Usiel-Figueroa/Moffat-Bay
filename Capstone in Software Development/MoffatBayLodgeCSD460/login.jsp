<!--
Assignment: Moffat Bay Lodge Project
Authors: Usiel Figueroa, Ean Masoner, Keanu Foltz, and Irene Carrillo Jaramillo
Date: August 20, 2025
Professor: Adam Bailey
Course: CSD 460 Capstone in Software Development

Purpose of Website Project:
Customers can view all aspects of the Lodge website without being logged in. 
To book their vacation (lodge reservation), they must be logged in/registered. 
In other words, to submit a reservation, prompt users to log in or register for a free account. 
There are no requirements for payment, but users must “click” a button to confirm their reservation. 
Once a reservation is confirmed, send the record to the database for insertion. 
The reservations you save in the database will be used to populate the Reservation Lookup page. 
All registered users should be saved to a table in the database. This table will be used during the 
login process to validate their access.
-->
<%@ page import="java.sql.*" %>
<%@ page import="java.security.*" %>
<%@ page import="com.moffatbay.util.DBUtil" %>

<%! 
    // Helper: Hash password with SHA-256
    public String hashPassword(String password) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes());
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
%>

<%
    String ctxPath = request.getContextPath();
    String message = "";

    // Handle logout
    if ("logout".equals(request.getParameter("action"))) {
        session.invalidate();
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle login form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT user_id, password_hash FROM Users WHERE email=?")) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password_hash");
                String inputHash = hashPassword(password);

                if (storedHash.equals(inputHash)) {
                    session.setAttribute("user_id", rs.getInt("user_id"));
                    response.sendRedirect("booking.jsp");
                    return;
                } else {
                    message = "Invalid password.";
                }
            } else {
                message = "No user found with that email.";
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Login - Moffat Bay Lodge</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="style.css" />
  <style>
    .center-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 70vh;
      flex-direction: column;
      text-align: center;
    }
    .login-form {
      background: #fff;
      padding: 30px 40px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      max-width: 400px;
      width: 100%;
    }
    .login-form label {
      display: block;
      margin-top: 10px;
      font-weight: bold;
      text-align: left;
    }
    .login-form input {
      width: 100%;
      padding: 10px;
      margin-top: 5px;
      border: 1px solid #ccc;
      border-radius: 6px;
    }
    .login-form button {
      margin-top: 15px;
      width: 100%;
      padding: 10px;
      background-color: #002f4b;
      color: #fff;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 1rem;
    }
    .login-form button:hover {
      background-color: #004b75;
    }
    .logout-btn {
      margin-top: 15px;
      width: 100%;
      padding: 10px;
      background-color: #a00;
      color: #fff;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 1rem;
    }
    .logout-btn:hover {
      background-color: #c00;
    }
    .extra-links {
      margin-top: 15px;
      font-size: 0.9rem;
    }
    .extra-links a {
      color: #002f4b;
      font-weight: bold;
      text-decoration: none;
    }
    .extra-links a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
<header>
  <img src="<%=ctxPath%>/images/Moffat_Bay_Lodge_Logo.PNG" alt="Moffat Bay Lodge Logo"
       style="height:90px;display:block;margin:0 auto;">
  <h1 style="text-align:center;margin-top:6px;">Moffat Bay Lodge</h1>
</header>

<nav>
  <a href="index.html">Home</a>
  <a href="aboutus.html">About Us</a>
  <a href="attractions.html">Attractions</a>
  <a href="booking.jsp">Booking</a>
  <a href="summary.jsp">Reservation Summary</a>
  <a href="lookup.jsp">Reservation Lookup</a>
  <a href="register.jsp">Register</a>
  <a href="login.jsp" aria-current="page">Login</a>
  
  <% if (session.getAttribute("user_id") != null) { %>
    <a href="login.jsp?action=logout" style="color: #ffdddd;">Logout</a>
  <% } %>
</nav>

<main>
  <div class="center-container">
    <div class="login-form">
      <h2>Login</h2>
      <p>Please log in to confirm your reservation.</p>

      <% if (!message.isEmpty()) { %>
        <p style="color:red;"><%=message%></p>
      <% } %>

      <% if (session.getAttribute("user_id") == null) { %>
        <!-- Show login form only if not logged in -->
        <form method="post" action="login.jsp">
          <label>Email:</label>
          <input type="email" name="email" required>

          <label>Password:</label>
          <input type="password" name="password" required>

          <button type="submit">Login</button>
        </form>

        <div class="extra-links">
          <p>New user? <a href="register.jsp">Register here</a></p>
        </div>
      <% } else { %>
        <!-- Show logout button if logged in -->
        <h3>You are already logged in.</h3>
        <form method="get" action="login.jsp">
          <input type="hidden" name="action" value="logout">
          <button type="submit" class="logout-btn">Logout</button>
        </form>
      <% } %>
    </div>
  </div>
</main>

<footer>
  <p>&copy; 2025 Moffat Bay Lodge. All rights reserved.</p>
</footer>
</body>
</html>