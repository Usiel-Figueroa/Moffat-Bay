/*
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
*/

package com.moffatbay.dao;

import com.moffatbay.util.DBUtil;
import java.sql.*;

public class ReservationDAO {

    public static int insertReservation(int userId, int roomId, int guests,
                                        String checkin, String checkout) {
        int rows = 0;

        try (Connection conn = DBUtil.getConnection()) {
            // Lookup room price
            double pricePerNight = 0;
            try (PreparedStatement stmt = conn.prepareStatement(
                     "SELECT price_per_night FROM Rooms WHERE room_id=?")) {
                stmt.setInt(1, roomId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    pricePerNight = rs.getDouble("price_per_night");
                }
                rs.close();
            }

            // Insert reservation
            try (PreparedStatement stmt = conn.prepareStatement(
                     "INSERT INTO Reservations " +
                     "(user_id, room_id, num_guests, check_in, check_out, price_per_night, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'pending')")) {

                stmt.setInt(1, userId);
                stmt.setInt(2, roomId);
                stmt.setInt(3, guests);
                stmt.setDate(4, Date.valueOf(checkin));
                stmt.setDate(5, Date.valueOf(checkout));
                stmt.setDouble(6, pricePerNight);

                rows = stmt.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rows;
    }
}
