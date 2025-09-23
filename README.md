# Moffat Bay Lodge Project

## 📌 Project Overview
This project was developed as part of **CSD 460 Capstone in Software Development**.  
The goal of the project is to simulate an online resort reservation system for **Moffat Bay Lodge** on Joviedsa Island, Washington State.  

The application allows users to:
- Explore **About Us** and **Attractions** pages.
- **Register** for a free account.
- **Log in** securely with password hashing.
- **Book rooms** (with live preview and dynamic pricing).
- **Review reservation details** on the Summary page.
- **Lookup past reservations** by reservation ID or email address.
- **Cancel or confirm reservations** before saving to the database.

All data is stored in a **MySQL database** and accessed via **JSP pages with JDBC (DBUtil helper class)**.

---

## 🛠️ Technologies Used
- **Frontend:** HTML, CSS, JSP
- **Backend:** Java, JSP, Servlets
- **Database:** MySQL (InnoDB engine)
- **Security:** SHA-256 password hashing, regex validation for email/password
- **Server:** Apache Tomcat 10
- **IDE:** Eclipse IDE

---

## 📂 Project Structure
MoffatBayLodge/
│── webapp/
│ ├── index.html
│ ├── aboutus.html
│ ├── attractions.html
│ ├── booking.jsp
│ ├── summary.jsp
│ ├── lookup.jsp
│ ├── login.jsp
│ ├── register.jsp
│ ├── style.css
│ └── images/
│ ├── Moffat_Bay_Lodge_Logo.PNG
│ ├── default_room.jpg
│ ├── room_queen.jpg
│ ├── room_king.jpg
│ └── (other room images)
|
└── ── src/com/moffatbay/dao/
|  ├── ReservationDAO.java
|   ├── UserDAO.java
│── src/com/moffatbay/util/
│ ├── DBUtil.java
│ 
│
│── sql/
│ └── MoffatBayLodge.sql
│
└── README.md

yaml
Copy code

---

## ⚙️ Database Setup

Create the database:

CREATE DATABASE MoffatBayLodge;
USE MoffatBayLodge;
Import the schema:

bash
Copy code
mysql -u root -p MoffatBayLodge < MoffatBayLodge.sql
Create a database user:

sql
Copy code
CREATE USER 'moffat_user'@'localhost
GRANT ALL PRIVILEGES ON MoffatBayLodge.* TO 'moffat_user'@'localhost';
FLUSH PRIVILEGES;
🔐 Security Features
Password hashing: All user passwords are stored using SHA-256 hash.

Validation:

Email addresses must follow standard format (e.g., name@example.com).

Passwords must be at least 8 characters and include:

One uppercase letter

One lowercase letter

One number

Session management ensures users must log in before confirming reservations.

🚀 Running the Project
Clone the repository:

bash
Copy code
git clone https://github.com/YOUR-USERNAME/MoffatBayLodge.git
Import the project into Eclipse (as a Dynamic Web Project).

Configure Tomcat 10 in Eclipse.

Deploy the project:

Right-click → Run As → Run on Server → Select Tomcat.

Open in browser:

arduino
Copy code
http://localhost:8080/MoffatBayLodge/

👥 Team Members

Usiel Figueroa

Ean Masoner

Keanu Foltz

Irene Carrillo Jaramillo

📖 References
OWASP Password Storage Guidelines

Java MessageDigest (SHA-256)

MySQL Documentation – Foreign Keys & InnoDB

📌 Notes
This project is for educational purposes. It simulates a real-world hotel booking system but does not process payments.

Users must log in or register before confirming reservations.

Reservation IDs and emails are required for looking up past bookings.




