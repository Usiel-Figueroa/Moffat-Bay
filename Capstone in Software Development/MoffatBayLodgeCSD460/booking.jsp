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

    // Show logged-in user's first name
    String welcomeName = null;
    Integer sessionUserId = (Integer) session.getAttribute("user_id");
    if (sessionUserId != null) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT first_name FROM Users WHERE user_id=?")) {
            stmt.setInt(1, sessionUserId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                welcomeName = rs.getString("first_name");
            }
        } catch (Exception e) {
            welcomeName = "Guest";
        }
    }

    // Handle POST submission → store in session → redirect to summary.jsp
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String roomId  = request.getParameter("room");
        String checkin = request.getParameter("checkin");
        String checkout= request.getParameter("checkout");
        String guests  = request.getParameter("guests");

        session.setAttribute("pending_roomId", roomId);
        session.setAttribute("pending_checkin", checkin);
        session.setAttribute("pending_checkout", checkout);
        session.setAttribute("pending_guests", guests);

        response.sendRedirect("summary.jsp");
        return;
    }

    // Today's date for min attribute
    java.time.LocalDate today = java.time.LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Booking - Moffat Bay Lodge</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="style.css" />
  <style>
    .booking-container { display:flex; gap:30px; margin-top:20px; flex-wrap:wrap; }
    .room-preview, .booking-form-wrapper { flex:1; min-width:280px; }
    .room-preview img { width:100%; max-width:800px; height:660px; object-fit:cover;
                        border-radius:10px; box-shadow:0 4px 10px rgba(0,0,0,0.2);
                        margin-bottom:12px; display:block; }
    .room-preview h3 { margin:8px 0; color:#002f4b; }
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
  <a href="booking.jsp" aria-current="page">Booking</a>
  <a href="summary.jsp">Reservation Summary</a>
  <a href="lookup.jsp">Reservation Lookup</a>
  <a href="register.jsp">Register</a>
  <a href="login.jsp">Login</a>
</nav>

<main>
  <% if (welcomeName != null) { %>
    <h2>Welcome, <%=welcomeName%>!</h2>
  <% } %>

  <h2>Book Your Stay</h2>
  <p>
    Please select your room and see the details (photo + description) on the left.  
    <strong>Note:</strong> To confirm your reservation, you must 
    <a href="login.jsp">log in</a> or 
    <a href="register.jsp">register</a> for free.
  </p>

  <div class="booking-container">
    <!-- Preview area -->
    <div class="room-preview" id="roomPreview">
      <img id="previewImg" src="<%=ctxPath%>/images/default_room.jpg" alt="Preview image">
      <h3 id="previewTitle">Welcome!</h3>
      <p id="previewDesc">Please choose a room to see an image and full description.</p>
    </div>

    <!-- Booking form -->
    <div class="booking-form-wrapper">
      <form method="post" action="booking.jsp" class="booking-form">
        <label for="room">Select Room:</label>
        <select name="room" id="room" required>
          <%
            try (Connection conn = DBUtil.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT room_id, room_type, price_per_night FROM Rooms")) {
                while (rs.next()) {
                    int rid = rs.getInt("room_id");
                    String type = rs.getString("room_type");
                    double price = rs.getDouble("price_per_night");
          %>
            <option value="<%=rid%>"
              data-image="<%=ctxPath%>/images/room_<%=type.toLowerCase().replace(' ','_')%>.jpg"
              data-desc="Enjoy our <%=type%> with modern amenities and cozy comfort.">
              <%=type%> - $<%=price%>/night
            </option>
          <%
                }
            } catch (Exception e) {
                out.println("<option disabled>Error loading rooms</option>");
            }
          %>
        </select>

        <label>Check-in:</label>
        <input type="date" name="checkin" required min="<%=today%>">

        <label>Check-out:</label>
        <input type="date" name="checkout" required min="<%=today%>">

        <label>Guests:</label>
        <input type="number" name="guests" min="1" max="10" required>

        <button type="submit">Proceed to Summary</button>
      </form>
    </div>
  </div>
</main>

<footer>
  <p>&copy; 2025 Moffat Bay Lodge. All rights reserved.</p>
</footer>

<script>
  function updatePreviewFromSelect() {
    const sel = document.getElementById('room');
    const opt = sel.options[sel.selectedIndex];
    const imgUrl = opt.getAttribute('data-image');
    const desc = opt.getAttribute('data-desc');
    const title = opt.text;

    document.getElementById('previewImg').src = imgUrl;
    document.getElementById('previewTitle').textContent = title;
    document.getElementById('previewDesc').textContent = desc;
  }
  document.getElementById('room').addEventListener('change', updatePreviewFromSelect);
  document.addEventListener('DOMContentLoaded', updatePreviewFromSelect);
</script>
</body>
</html>
