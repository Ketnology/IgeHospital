class ApiEndpoints {
  static const String baseUrl = "https://api.igehospital.com/api";

  // ========== AUTHENTICATION ==========
  static const String login = "$baseUrl/auth/login";
  static const String validateToken = "$baseUrl/auth/validate-token";
  static const String logout = "$baseUrl/auth/logout";

  // ========== DASHBOARD ==========
  static const String dashboard = "$baseUrl/admin/dashboard";

  // ========== APPOINTMENTS ==========
  static const String appointmentEndpoint = "$baseUrl/appointments";
  // GET/POST: $baseUrl/appointments
  // GET: $baseUrl/appointments/{id}
  // PUT: $baseUrl/appointments/{id}
  // DELETE: $baseUrl/appointments/{id}

  // ========== PATIENTS ==========
  static const String patientEndpoint = "$baseUrl/patient";
  static const String patientsEndpoint = "$baseUrl/patients";
  // GET: $baseUrl/patient (list with filters)
  // GET: $baseUrl/patient/{id} (details)
  // POST: $baseUrl/patient (create)
  // PUT: $baseUrl/patient/{id} (update)
  // DELETE: $baseUrl/patient/{id} (delete)
  // GET: $baseUrl/patients/{patientId}/vital-signs/staff (vital signs for staff)

  // ========== DOCTORS ==========
  static const String doctorEndpoint = "$baseUrl/doctor";
  static const String doctorDepartmentsEndpoint = "$baseUrl/doctor-departments";
  // GET: $baseUrl/doctor (list with filters)
  // GET: $baseUrl/doctor/{id} (details)
  // POST: $baseUrl/doctor (create)
  // PUT: $baseUrl/doctor/{id} (update)
  // DELETE: $baseUrl/doctor/{id} (delete)

  // ========== NURSES/RECEPTIONISTS ==========
  static const String nursesEndpoint = "$baseUrl/receptionist";
  // GET: $baseUrl/receptionist (list with filters)
  // GET: $baseUrl/receptionist/{id} (details)
  // POST: $baseUrl/receptionist (create)
  // PUT: $baseUrl/receptionist/{id} (update)
  // DELETE: $baseUrl/receptionist/{id} (delete)

  // ========== ADMINS ==========
  static const String adminsEndpoint = "$baseUrl/admin";
  // GET: $baseUrl/admin (list with filters)
  // GET: $baseUrl/admin/{id} (details)
  // POST: $baseUrl/admin (create)
  // PUT: $baseUrl/admin/{id} (update)
  // DELETE: $baseUrl/admin/{id} (delete)

  // ========== STAFF ==========
  static const String staffEndpoint = "$baseUrl/staff";

  // ========== USER PROFILE ==========
  static const String userProfile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/profile/update";

  // ========== LIVE CONSULTATIONS ==========
  static const String liveConsultationsEndpoint = "$baseUrl/live-consultations";
  static const String upcomingConsultationsEndpoint = "$baseUrl/live-consultations/upcoming";
  static const String todaysConsultationsEndpoint = "$baseUrl/live-consultations/today";
  static const String consultationStatisticsEndpoint = "$baseUrl/live-consultations/statistics";
  // GET: $baseUrl/live-consultations (list with filters)
  // GET: $baseUrl/live-consultations/{id} (details)
  // POST: $baseUrl/live-consultations (create)
  // PUT: $baseUrl/live-consultations/{id} (update)
  // DELETE: $baseUrl/live-consultations/{id} (delete)
  // POST: $baseUrl/live-consultations/{id}/join (join consultation)
  // POST: $baseUrl/live-consultations/{id}/start (start consultation)
  // POST: $baseUrl/live-consultations/{id}/end (end consultation)
  // PATCH: $baseUrl/live-consultations/{id}/status (change status)
  // GET: $baseUrl/live-consultations/upcoming (upcoming consultations)
  // GET: $baseUrl/live-consultations/today (today's consultations)
  // GET: $baseUrl/live-consultations/statistics (consultation statistics)

  // ========== VITAL SIGNS ==========
  static const String vitalSignsEndpoint = "$baseUrl/vital-signs";
  // GET: $baseUrl/patients/{patientId}/vital-signs/staff (get vital signs for patient)
  // GET: $baseUrl/vital-signs/{id} (get vital sign details)
  // POST: $baseUrl/vital-signs (create vital signs)
  // PUT: $baseUrl/vital-signs/{id} (update vital signs)
  // DELETE: $baseUrl/vital-signs/{id} (delete vital signs)

  // ========== ACCOUNTING ==========
  // Accounts
  static const String accountingAccountsEndpoint = "$baseUrl/accounting/accounts";
  // GET: $baseUrl/accounting/accounts (list with filters)
  // GET: $baseUrl/accounting/accounts/{id} (details)
  // POST: $baseUrl/accounting/accounts (create)
  // PUT: $baseUrl/accounting/accounts/{id} (update)
  // DELETE: $baseUrl/accounting/accounts/{id} (delete)
  // PATCH: $baseUrl/accounting/accounts/{id}/toggle-status (toggle status)

  // Payments
  static const String accountingPaymentsEndpoint = "$baseUrl/accounting/payments";
  // GET: $baseUrl/accounting/payments (list with filters)
  // POST: $baseUrl/accounting/payments (create)

  // Bills
  static const String accountingBillsEndpoint = "$baseUrl/accounting/bills";
  // GET: $baseUrl/accounting/bills (list with filters)
  // GET: $baseUrl/accounting/bills/{id} (details)
  // POST: $baseUrl/accounting/bills (create)
  // PUT: $baseUrl/accounting/bills/{id} (update)
  // DELETE: $baseUrl/accounting/bills/{id} (delete)
  // PATCH: $baseUrl/accounting/bills/{id}/status (update status)

  // Dashboard
  static const String accountingDashboardEndpoint = "$baseUrl/accounting/dashboard";
  static const String accountingFinancialOverviewEndpoint = "$baseUrl/accounting/dashboard/financial-overview";
  // GET: $baseUrl/accounting/dashboard (accounting dashboard)
  // GET: $baseUrl/accounting/dashboard/financial-overview (financial overview)

  // ========== LOGIN RECORDS ==========
  static const String loginRecordsEndpoint = "$baseUrl/login-records";
  static const String myLoginRecordsEndpoint = "$baseUrl/login-records/my-records";
  static const String loginStatisticsEndpoint = "$baseUrl/login-records/statistics";
}
