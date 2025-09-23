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
<%@ page import="java.util.regex.*" %>
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
        response.sendRedirect("register.jsp");
        return;
    }

    // Handle registration
    if ("POST".equalsIgnoreCase(request.getMethod()) && session.getAttribute("user_id") == null) {
        String firstName = request.getParameter("firstName");
        String lastName  = request.getParameter("lastName");
        String email     = request.getParameter("email");
        String phone     = request.getParameter("phone");
        String password  = request.getParameter("password");

        // Email validation
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        if (!Pattern.matches(emailRegex, email)) {
            message = "Invalid email format. Example: bob@something.com";
        }

        // Password validation
        String passRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$";
        if (message.isEmpty() && !Pattern.matches(passRegex, password)) {
            message = "Password must be at least 8 characters long and include one number, one uppercase, and one lowercase letter.";
        }

        if (message.isEmpty()) {
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(
                     "INSERT INTO Users (first_name, last_name, email, telephone, password_hash) VALUES (?, ?, ?, ?, ?)",
                     Statement.RETURN_GENERATED_KEYS)) {

                String hashedPass = hashPassword(password);

                stmt.setString(1, firstName);
                stmt.setString(2, lastName);
                stmt.setString(3, email);
                stmt.setString(4, phone);
                stmt.setString(5, hashedPass);

                int inserted = stmt.executeUpdate();
                if (inserted > 0) {
                    ResultSet keys = stmt.getGeneratedKeys();
                    if (keys.next()) {
                        session.setAttribute("user_id", keys.getInt(1));
                    }
                    response.sendRedirect("booking.jsp");
                    return;
                } else {
                    message = "Failed to register. Please try again.";
                }
            } catch (SQLIntegrityConstraintViolationException e) {
                message = "Email already registered. Please log in.";
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Register - Moffat Bay Lodge</title>
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
    .register-form {
      background: #fff;
      padding: 30px 40px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      max-width: 450px;
      width: 100%;
    }
    .register-form label {
      display: block;
      margin-top: 10px;
      font-weight: bold;
      text-align: left;
    }
    .register-form input {
      width: 100%;
      padding: 10px;
      margin-top: 5px;
      border: 1px solid #ccc;
      border-radius: 6px;
    }
    .register-form button {
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
    .register-form button:hover {
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
  <a href="register.jsp" aria-current="page">Register</a>
  <a href="login.jsp">Login</a>
  <% if (session.getAttribute("user_id") != null) { %>
    <a href="register.jsp?action=logout" style="color: #ffdddd;">Logout</a>
  <% } %>
</nav>

<main>
  <div class="center-container">
    <div class="register-form">
      <% if (session.getAttribute("user_id") == null) { %>
        <h2>Register</h2>
        <p>Create a free account to confirm reservations.</p>

        <% if (!message.isEmpty()) { %>
          <p style="color:red;"><%=message%></p>
        <% } %>

        <form method="post" action="register.jsp">
          <label>First Name:</label>
          <input type="text" name="firstName" required>

          <label>Last Name:</label>
          <input type="text" name="lastName" required>

          <label>Email:</label>
          <input type="email" name="email" required>

          <label>Phone:</label>
          <input type="tel" name="phone" required>

          <label>Password:</label>
          <input type="password" name="password" required>

          <button type="submit">Register</button>
        </form>

        <div class="extra-links">
          <p>Already have an account? <a href="login.jsp">Login here</a></p>
        </div>
      <% } else { %>
        <h2>You are already logged in</h2>
        <form method="get" action="register.jsp">
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