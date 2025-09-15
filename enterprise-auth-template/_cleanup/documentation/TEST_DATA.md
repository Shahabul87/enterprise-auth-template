# Authentication Test Data & Instructions

## 📱 Test Credentials

### New User Registration Data:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "name": "John Doe"
}
```

### Existing User Login Data:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!"
}
```

### Alternative Test Users:
1. **User 2 (Mobile Tester)**:
   - Email: `mobile.user@example.com`
   - Password: `MobileTest456!`
   - Name: `Mobile User`

2. **User 3 (Admin Tester)**:
   - Email: `admin@example.com`
   - Password: `AdminPass789!`
   - Name: `Admin User`

---

## 🌐 Frontend Web Testing

### 1. Access the Application
- URL: `http://localhost:3000`
- The application should load the login page

### 2. Test Registration
1. Click on **"Sign Up"** or **"Create Account"** link
2. Enter the following data:
   - **Email**: `john.doe@example.com`
   - **Password**: `SecurePass123!`
   - **Confirm Password**: `SecurePass123!`
   - **Name**: `John Doe`
3. Click **"Register"** button
4. **Expected Result**:
   - Successful registration message
   - Redirect to dashboard
   - Welcome message showing "Welcome, John Doe"

### 3. Test Login
1. If already logged in, click **"Logout"**
2. On login page, enter:
   - **Email**: `john.doe@example.com`
   - **Password**: `SecurePass123!`
3. Click **"Login"** button
4. **Expected Result**:
   - Successful login
   - Redirect to dashboard
   - User profile visible in header

### 4. Test Error Scenarios
- **Invalid Password**: Use `wrongpass` → Should show "Invalid credentials"
- **Non-existent Email**: Use `notexist@example.com` → Should show "Invalid credentials"
- **Weak Password**: Use `123` → Should show password requirements
- **Duplicate Registration**: Register same email twice → Should show "Email already exists"

---

## 📱 Mobile Flutter Testing

### 1. Start Flutter App
```bash
cd flutter_auth_template
flutter run
```
Choose your device:
- **1** for iOS Simulator
- **2** for Android Emulator
- **3** for Chrome (Web)

### 2. Test Registration
1. Tap **"Sign Up"** button
2. Enter:
   - **Email**: `mobile.user@example.com`
   - **Password**: `MobileTest456!`
   - **Name**: `Mobile User`
3. Tap **"Register"**
4. **Expected Result**:
   - Success animation
   - Automatic login
   - Navigate to home screen

### 3. Test Login
1. If logged in, tap menu → **"Logout"**
2. On login screen, enter:
   - **Email**: `mobile.user@example.com`
   - **Password**: `MobileTest456!`
3. Tap **"Login"**
4. **Expected Result**:
   - Loading indicator while authenticating
   - Success message
   - Navigate to home screen

### 4. Test Biometric Login (if available)
1. After successful login, go to Settings
2. Enable **"Biometric Authentication"**
3. Logout and return to login
4. Tap **"Login with Biometrics"**
5. Authenticate with fingerprint/Face ID

---

## 🔧 Backend API Testing

### Direct API Registration Test:
```bash
curl -X POST http://localhost:8000/api/v1/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "api.test@example.com",
    "password": "ApiTest123!",
    "name": "API Test User"
  }'
```

### Direct API Login Test:
```bash
curl -X POST http://localhost:8000/api/v1/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "api.test@example.com",
    "password": "ApiTest123!"
  }'
```

---

## ✅ Test Validation Checklist

### Registration Tests:
- [ ] New user can register successfully
- [ ] Duplicate email shows proper error
- [ ] Weak password shows requirements
- [ ] Invalid email format shows error
- [ ] All fields are required validation
- [ ] Success redirects to dashboard

### Login Tests:
- [ ] Valid credentials login successfully
- [ ] Invalid password shows error
- [ ] Non-existent email shows error
- [ ] Remember me functionality works
- [ ] Logout clears session properly

### Cross-Platform Tests:
- [ ] User registered on web can login on mobile
- [ ] User registered on mobile can login on web
- [ ] Session management works across platforms
- [ ] Password reset works on both platforms

### Error Handling Tests:
- [ ] Network timeout shows retry option
- [ ] Server error shows friendly message
- [ ] Rate limiting shows countdown
- [ ] Account locked shows unlock options

---

## 🎯 Expected Responses

### Successful Registration Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-here",
      "email": "john.doe@example.com",
      "name": "John Doe",
      "isEmailVerified": false,
      "roles": ["user"]
    },
    "message": "Registration successful! Please check your email to verify your account."
  }
}
```

### Successful Login Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid-here",
      "email": "john.doe@example.com",
      "name": "John Doe",
      "isEmailVerified": true,
      "roles": ["user"]
    },
    "accessToken": "jwt-token-here",
    "refreshToken": "refresh-token-here",
    "expiresIn": 900
  }
}
```

### Error Response Examples:
```json
{
  "success": false,
  "error": {
    "code": "EMAIL_ALREADY_EXISTS",
    "message": "This email is already registered",
    "suggestion": "Try logging in instead, or use password recovery if you forgot your password",
    "action": "redirect_to_login",
    "severity": "low"
  },
  "feedback": {
    "retry_allowed": false,
    "retry_after": 0
  }
}
```

---

## 🚀 Quick Test Commands

### Test Everything Quickly:
```bash
# 1. Test Backend Registration
./test_auth.sh register

# 2. Test Backend Login
./test_auth.sh login

# 3. Open Frontend
open http://localhost:3000

# 4. Open API Docs
open http://localhost:8000/docs
```

---

## 📊 Monitoring

### Check Backend Logs:
```bash
# View real-time logs
tail -f backend/logs/app.log

# Check for errors
grep ERROR backend/logs/app.log
```

### Check Frontend Console:
1. Open browser DevTools (F12)
2. Go to Console tab
3. Look for any red errors
4. Network tab shows API calls

### Check Mobile Logs:
```bash
# For Flutter debug output
flutter logs
```

---

## 🔄 Reset Test Data

If you need to start fresh:

```bash
# Clear database
PGPASSWORD=enterprise_password_2024 psql -h localhost -U enterprise_user -d enterprise_auth -c "DELETE FROM users WHERE email LIKE '%example.com';"

# Clear Redis cache
redis-cli FLUSHALL

# Restart services
pkill uvicorn
pkill node
make dev-up
```