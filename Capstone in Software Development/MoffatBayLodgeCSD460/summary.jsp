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
<%@ page import="com.moffatbay.util.DBUtil" %>
<%
    String ctxPath = request.getContextPath();
    String message = "";

    // Require login
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get user's first name
    String welcomeName = null;
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "SELECT first_name FROM Users WHERE user_id=?")) {
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            welcomeName = rs.getString("first_name");
        }
    } catch (Exception e) {
        welcomeName = "Guest";
    }

    // Get pending reservation details from session
    String roomId  = (String) session.getAttribute("pending_roomId");
    String checkin = (String) session.getAttribute("pending_checkin");
    String checkout= (String) session.getAttribute("pending_checkout");
    String guests  = (String) session.getAttribute("pending_guests");

    String roomType = "";
    double price = 0.0;

    if (roomId != null) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT room_type, price_per_night FROM Rooms WHERE room_id=?")) {
            stmt.setInt(1, Integer.parseInt(roomId));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                roomType = rs.getString("room_type");
                price = rs.getDouble("price_per_night");
            }
        } catch (Exception e) {
            message = "<span style='color:red'>Error: " + e.getMessage() + "</span>";
        }
    }

    // Handle form submission
    String action = request.getParameter("action");
    if ("confirm".equals(action)) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO Reservations (user_id, room_id, num_guests, check_in, check_out, price_per_night, status) " +
                 "VALUES (?, ?, ?, ?, ?, ?, 'confirmed')",
                 Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, Integer.parseInt(roomId));
            stmt.setInt(3, Integer.parseInt(guests));
            stmt.setDate(4, Date.valueOf(checkin));
            stmt.setDate(5, Date.valueOf(checkout));
            stmt.setDouble(6, price);

            int inserted = stmt.executeUpdate();
            if (inserted > 0) {
                int reservationId = 0;
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        reservationId = keys.getInt(1);
                    }
                }

                String userEmail = "";
                try (PreparedStatement uStmt = conn.prepareStatement(
                        "SELECT email FROM Users WHERE user_id=?")) {
                    uStmt.setInt(1, userId);
                    ResultSet rsU = uStmt.executeQuery();
                    if (rsU.next()) {
                        userEmail = rsU.getString("email");
                    }
                }

                message = "<div style='color:green; padding:15px; border:1px solid #ccc; background:#f9fff9; border-radius:8px;'>" +
                          "<h3>Reservation Confirmed!</h3>" +
                          "<p>Thank you, <strong>" + welcomeName + "</strong>. Your reservation has been successfully confirmed.</p>" +
                          "<p><strong>Reservation ID:</strong> " + reservationId + "<br>" +
                          "<strong>Email:</strong> " + userEmail + "</p>" +
                          "<p>We are delighted to welcome you to <strong>Moffat Bay Lodge</strong> from <strong>" + checkin + "</strong> to <strong>" + checkout + "</strong> in our <strong>" + roomType + "</strong>.</p>" +
                          "<p>Our team is committed to ensuring you enjoy a relaxing and memorable stay. If you have any special requests, please contact us prior to your arrival. We look forward to hosting you soon!</p>" +
                          "<p style='margin-top:10px;'><em>Sincerely,<br>The Moffat Bay Lodge Team</em></p>" +
                          "</div>";

                // Clear pending session data
                session.removeAttribute("pending_roomId");
                session.removeAttribute("pending_checkin");
                session.removeAttribute("pending_checkout");
                session.removeAttribute("pending_guests");
            } else {
                message = "<span style='color:red'>Failed to confirm reservation.</span>";
            }
        } catch (Exception e) {
            message = "<span style='color:red'>Error: " + e.getMessage() + "</span>";
        }
    } else if ("cancel".equals(action)) {
        session.removeAttribute("pending_roomId");
        session.removeAttribute("pending_checkin");
        session.removeAttribute("pending_checkout");
        session.removeAttribute("pending_guests");
        response.sendRedirect("booking.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Reservation Summary - Moffat Bay Lodge</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="style.css" />
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
  <a href="summary.jsp" aria-current="page">Reservation Summary</a>
  <a href="lookup.jsp">Reservation Lookup</a>
  <a href="register.jsp">Register</a>
  <a href="login.jsp">Login</a>
</nav>

<main>
  <% if (welcomeName != null) { %>
    <h2>Welcome, <%=welcomeName%>!</h2>
  <% } %>

  <h2>Reservation Summary</h2>
  <% if (!message.isEmpty()) { %>
    <p><%=message%></p>
  <% } else if (roomId == null) { %>
    <!-- Fallback after refresh -->
    <p style="color:blue;">
      You have no pending reservations to confirm.<br>
      To view your confirmed bookings, please visit the 
      <a href="lookup.jsp">Reservation Lookup</a> page.
    </p>
  <% } else { %>
    <!-- Standard review before confirm -->
    <p>Please review your reservation details before confirming.</p>

    <table border="1" cellpadding="8" cellspacing="0" style="margin-top:15px; border-collapse:collapse;">
      <tr><th>Room</th><td><%=roomType%></td></tr>
      <tr><th>Check-in</th><td><%=checkin%></td></tr>
      <tr><th>Check-out</th><td><%=checkout%></td></tr>
      <tr><th>Guests</th><td><%=guests%></td></tr>
      <tr><th>Price per Night</th><td>$<%=price%></td></tr>
    </table>

    <form method="post" style="margin-top:20px;">
      <button type="submit" name="action" value="confirm" 
              style="padding:10px 20px;margin-right:10px;background:#002f4b;color:white;border:none;border-radius:6px;">
        Confirm Reservation
      </button>
      <button type="submit" name="action" value="cancel" 
              style="padding:10px 20px;background:#a00;color:white;border:none;border-radius:6px;">
        Cancel
      </button>
    </form>
  <% } %>
</main>

<footer>
  <p>&copy; 2025 Moffat Bay Lodge. All rights reserved.</p>
</footer>
</body>
</html>
