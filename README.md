# syncskills

# 🧠 SyncSkills — Skills Audit System

**SyncSkills** is a digital Skills Audit System designed to help organizations efficiently manage and track employee competencies, qualifications, and training records. The platform provides a secure and centralized way to assess staff capabilities, identify skill gaps, and support informed decision-making for workforce development.

---

## 🚀 Features

- 🔐 **Role-based access control**  
  - Two roles: **Admin** (web access) and **Employee** (mobile app access)
- 👥 **User Management** — centralized `users` table for all users  
- 🎓 **Employee Records** — capture qualifications, skills, and training  
- 🧾 **Admin Dashboard** — view and manage employee data from the web  
- 📱 **Employee App (Flutter)** — employees can view and update their own skills and training  
- 🛡️ **Row-level Security** — ensures each user only sees their own records  
- 🗃️ **Organized Database Design**
  - `users` — general user data  
  - `admin_details` — admin-specific data  
  - `employee_details` — employee-specific data  
  - `skills`, `qualifications`, `trainings` — records linked to users  

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend (Mobile)** | Flutter |
| **Backend (Web Admin)** | Web-based interface (e.g., React, HTML/CSS, or other) |
| **Database** | PostgreSQL with Row-Level Security |
| **API / Server** | Supabase / Node.js / or other REST backend (depending on setup) |
| **Version Control** | Git & GitHub |

---

## 🗄️ Database Structure Overview

| Table | Description |
|--------|-------------|
| **users** | General user info (`id`, `email`, `role`, `created_at`) |
| **admin_details** | Admin-specific info (linked to `users.id`) |
| **employee_details** | Employee-specific info (linked to `users.id`) |
| **skills** | Skills linked to users |
| **qualifications** | Qualifications linked to users |
| **trainings** | Training records linked to users |

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/TauJamesMarake/synckills.git
cd synckills


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
