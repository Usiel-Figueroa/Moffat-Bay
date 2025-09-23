<!--
Assignment: Moffat Bay Lodge Project
Authors: Usiel Figueroa, Ean Masoner, Keanu Foltz, and Irene Carrillo Jaramillo
Date: September 17, 2025
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
<%@ page import="java.util.*" %>
<%@ page import="com.moffatbay.util.DBUtil" %>
<%
    String ctxPath = request.getContextPath();
    String message = "";

    List<Map<String,Object>> results = new ArrayList<>();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String reservationIdParam = request.getParameter("reservation_id");
        String emailParam = request.getParameter("email");

        if ((reservationIdParam == null || reservationIdParam.trim().isEmpty()) &&
            (emailParam == null || emailParam.trim().isEmpty())) {
            message = "Please enter a Reservation ID or an Email address to search.";
        } else {
            try (Connection conn = DBUtil.getConnection()) {
                if (reservationIdParam != null && !reservationIdParam.trim().isEmpty()) {
                    // Search by reservation_id (underscore naming)
                    String sql =
                        "SELECT r.reservation_id, u.first_name, u.last_name, u.email, rm.room_type, " +
                        "r.num_guests, r.check_in, r.check_out, r.price_per_night, r.status " +
                        "FROM Reservations r " +
                        "LEFT JOIN Users u ON r.user_id = u.user_id " +
                        "JOIN Rooms rm ON r.room_id = rm.room_id " +
                        "WHERE r.reservation_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(reservationIdParam.trim()));
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                Map<String,Object> row = new HashMap<>();
                                row.put("reservation_id", rs.getInt("reservation_id"));
                                row.put("first_name", rs.getString("first_name"));
                                row.put("last_name", rs.getString("last_name"));
                                row.put("email", rs.getString("email"));
                                row.put("room_type", rs.getString("room_type"));
                                row.put("num_guests", rs.getInt("num_guests"));
                                row.put("check_in", rs.getDate("check_in"));
                                row.put("check_out", rs.getDate("check_out"));
                                row.put("price_per_night", rs.getDouble("price_per_night"));
                                row.put("status", rs.getString("status"));
                                results.add(row);
                            }
                        }
                    }
                } else {
                    // Search by email (returns all reservations for that email)
                    String sql =
                        "SELECT r.reservation_id, u.first_name, u.last_name, u.email, rm.room_type, " +
                        "r.num_guests, r.check_in, r.check_out, r.price_per_night, r.status " +
                        "FROM Reservations r " +
                        "JOIN Users u ON r.user_id = u.user_id " +
                        "JOIN Rooms rm ON r.room_id = rm.room_id " +
                        "WHERE u.email = ? " +
                        "ORDER BY r.created_at DESC";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, emailParam.trim());
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                Map<String,Object> row = new HashMap<>();
                                row.put("reservation_id", rs.getInt("reservation_id"));
                                row.put("first_name", rs.getString("first_name"));
                                row.put("last_name", rs.getString("last_name"));
                                row.put("email", rs.getString("email"));
                                row.put("room_type", rs.getString("room_type"));
                                row.put("num_guests", rs.getInt("num_guests"));
                                row.put("check_in", rs.getDate("check_in"));
                                row.put("check_out", rs.getDate("check_out"));
                                row.put("price_per_night", rs.getDouble("price_per_night"));
                                row.put("status", rs.getString("status"));
                                results.add(row);
                            }
                        }
                    }
                }

                if (results.isEmpty()) {
                    message = "No reservations found for your search.";
                }
            } catch (NumberFormatException nfe) {
                message = "Reservation ID must be a number.";
            } catch (Exception e) {
                message = "Error searching reservations: " + e.getMessage();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Reservation Lookup - Moffat Bay Lodge</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="style.css" />
  <style>
    .lookup-container { max-width: 900px; margin: 30px auto; padding: 20px; }
    .lookup-form {
      display:flex;
      gap:12px;
      flex-wrap:wrap;
      align-items:center;
      margin-bottom:18px;
    }
    .lookup-form input[type="text"] {
      padding:10px;
      border-radius:6px;
      border:1px solid #ccc;
      min-width:220px;
      flex:1 1 240px;
    }
    .lookup-form label { font-weight:bold; margin-right:6px; }
    .lookup-form button {
      padding:10px 18px;
      background:#002f4b;
      color:#fff;
      border:none;
      border-radius:6px;
      cursor:pointer;
    }
    .result-table {
      width:100%;
      border-collapse:collapse;
      margin-top:12px;
    }
    .result-table th, .result-table td {
      border:1px solid #ddd;
      padding:10px;
      text-align:left;
    }
    .result-table th {
      background:#002f4b;
      color:#fff;
    }
    .no-results { color:#0b5394; font-weight:bold; margin-top:12px; }
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
  <a href="lookup.jsp" aria-current="page">Reservation Lookup</a>
  <a href="register.jsp">Register</a>
  <a href="login.jsp">Login</a>
</nav>

<main>
  <div class="lookup-container">
    <h2>Reservation Lookup</h2>
    <p>Search by <strong>Reservation ID</strong> or by the <strong>email address</strong> used when booking.</p>

    <form method="post" class="lookup-form" action="lookup.jsp">
      <div style="display:flex; gap:8px; align-items:center;">
        <label for="reservation_id">Reservation ID</label>
        <input type="text" id="reservation_id" name="reservation_id" placeholder="e.g. 1234" value="<%= request.getParameter("reservation_id") != null ? request.getParameter("reservation_id") : "" %>">
      </div>

      <div style="display:flex; gap:8px; align-items:center;">
        <label for="email">Email</label>
        <input type="text" id="email" name="email" placeholder="you@example.com" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
      </div>

      <div style="display:flex; gap:8px; align-items:center;">
        <button type="submit">Search</button>
      </div>
    </form>

    <% if (!message.isEmpty()) { %>
      <p class="no-results"><%= message %></p>
    <% } %>

    <% if (!results.isEmpty()) { %>
      <table class="result-table" aria-live="polite">
        <thead>
          <tr>
            <th>Reservation ID</th>
            <th>Guest Name</th>
            <th>Email</th>
            <th>Room Size</th>
            <th>Guests</th>
            <th>Check-in</th>
            <th>Check-out</th>
            <th>Price / Night</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
        <%
          for (Map<String,Object> row : results) {
              Object rid = row.get("reservation_id");
              String first = row.get("first_name") == null ? "" : row.get("first_name").toString();
              String last  = row.get("last_name") == null ? "" : row.get("last_name").toString();
              String guestName = (first + " " + last).trim();
              Object email = row.get("email");
              Object room = row.get("room_type");
              Object ng  = row.get("num_guests");
              Object ci  = row.get("check_in");
              Object co  = row.get("check_out");
              Object st  = row.get("status");
              Object pr  = row.get("price_per_night");
              String ciStr = (ci == null) ? "" : ci.toString();
              String coStr = (co == null) ? "" : co.toString();
        %>
          <tr>
            <td><%= rid %></td>
            <td><%= guestName %></td>
            <td><%= email == null ? "" : email %></td>
            <td><%= room %></td>
            <td><%= ng %></td>
            <td><%= ciStr %></td>
            <td><%= coStr %></td>
            <td>
              <% if (pr != null) { %>
                $<%= String.format("%.2f", ((Number)pr).doubleValue()) %>
              <% } else { %>
                -
              <% } %>
            </td>
            <td><%= st == null ? "" : st %></td>
          </tr>
        <%
          } // end for
        %>
        </tbody>
      </table>

      <div style="margin-top:14px;">
        <a href="booking.jsp" style="text-decoration:none; color:#002f4b; font-weight:bold;">Back to Booking</a>
      </div>
    <% } %>
  </div>
</main>

<footer>
  <p>&copy; 2025 Moffat Bay Lodge. All rights reserved.</p>
</footer>
</body>
</html>
