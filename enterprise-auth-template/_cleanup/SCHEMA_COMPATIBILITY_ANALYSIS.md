# Schema Compatibility Analysis Report

## Executive Summary
This document provides a comprehensive analysis of field compatibility across database schema (SQLAlchemy), backend API schemas (Pydantic), and frontend TypeScript types for authentication features including registration, login, and password reset.

## 1. Database Schema (SQLAlchemy) - User Model

### Core Authentication Fields
```python
# From backend/app/models/user.py
- id: UUID (primary key)
- email: String(255) (unique, indexed, required)
- hashed_password: String(255) (nullable for OAuth)
- first_name: String(100) (required)
- last_name: String(100) (required)
- username: String(100) (unique, nullable)
- full_name: String(255) (nullable)
- is_active: Boolean (default: False)
- is_verified: Boolean (default: False)
- email_verified: Boolean (default: False)
- is_superuser: Boolean (default: False)
```

### Additional Security Fields
```python
- totp_secret: String(32) (nullable)
- two_factor_enabled: Boolean (default: False)
- backup_codes: Text (nullable)
- failed_login_attempts: Integer (default: 0)
- locked_until: DateTime (nullable)
```

## 2. Backend API Schemas (Pydantic)

### Registration Request
```python
# From backend/app/schemas/auth.py - RegisterRequest
- email: EmailStr (required)
- password: str (min_length=8, required)
- name: str (min_length=2, max_length=100, required) # NEW FIELD for Flutter
- first_name: Optional[str] (min_length=2, max_length=50) # BACKWARD COMPAT
- last_name: Optional[str] (min_length=2, max_length=50) # BACKWARD COMPAT
- confirm_password: Optional[str]
- agree_to_terms: Optional[bool] (default: True)
```

### Login Request
```python
# From backend/app/schemas/auth.py - LoginRequest
- email: EmailStr (required)
- password: str (min_length=1, required)
- remember_me: bool (default: False)
```

### User Response
```python
# From backend/app/schemas/auth.py - UserResponse
- id: str
- email: str
- first_name: str
- last_name: str
- full_name: Optional[str]
- name: str # Display name for Flutter compatibility
- profile_picture: Optional[str] (alias="profilePicture")
- email_verified: bool (alias="isEmailVerified")
- two_factor_enabled: bool (alias="isTwoFactorEnabled")
- roles: list[str]
- permissions: list[str]
- created_at: str (alias="createdAt")
- updated_at: str (alias="updatedAt")
- last_login_at: Optional[str] (alias="lastLoginAt")
- is_active: bool
# Deprecated fields for backward compatibility:
- is_verified: Optional[bool]
- last_login: Optional[str]
```

### Password Reset
```python
# From backend/app/schemas/auth.py
PasswordResetRequest:
- email: EmailStr

PasswordResetConfirm:
- token: str
- new_password: str (min_length=8)
- confirm_password: str
```

## 3. Frontend TypeScript Types

### User Type
```typescript
// From frontend/src/types/auth.types.ts
interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  is_active: boolean;
  is_verified: boolean;  // Maps to email_verified in DB
  is_superuser: boolean;
  failed_login_attempts: number;
  last_login: string | null;
  avatar_url?: string;
  user_metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
  roles: Role[];
}
```

### Registration Request
```typescript
// From frontend/src/types/auth.types.ts
interface RegisterRequest {
  email: string;
  password: string;
  confirm_password: string;
  name: string;  // NEW FIELD
  agree_to_terms: boolean;
}
```

### Login Request
```typescript
// From frontend/src/types/auth.types.ts
interface LoginRequest {
  email: string;
  password: string;
}
```

## 4. Field Compatibility Issues & Mismatches

### 🔴 Critical Issues

1. **Registration Name Field Mismatch**
   - Backend Schema: Has both `name` (required) and `first_name`/`last_name` (optional) for backward compatibility
   - Frontend TypeScript: Only has `name` field
   - Database: Stores `first_name` and `last_name` separately (both required)
   - **Impact**: Registration may fail if backend doesn't properly parse `name` into `first_name` and `last_name`

2. **User Verification Field Inconsistency**
   - Database: `email_verified` (boolean)
   - Backend Response: `email_verified` with alias `isEmailVerified`
   - Frontend Type: `is_verified` (should be `email_verified`)
   - **Impact**: Email verification status may not display correctly

### 🟡 Minor Issues

1. **Profile Picture Field Naming**
   - Database: `avatar_url`
   - Backend Response: `profile_picture` (aliased as `profilePicture`)
   - Frontend Type: `avatar_url`
   - **Impact**: Profile pictures may not display correctly

2. **Missing Fields in Frontend Types**
   - Frontend `User` type missing:
     - `full_name`
     - `username`
     - `phone_number` and phone verification fields
     - `two_factor_enabled`
     - OAuth provider IDs
     - `email_verified` (has `is_verified` instead)

3. **Login Remember Me**
   - Backend Schema: Has `remember_me` field
   - Frontend Type: Missing `rememberMe` in `LoginRequest`
   - **Impact**: Remember me functionality won't work

4. **Password Reset Field Names**
   - Backend uses `new_password` and `confirm_password`
   - Frontend uses `new_password` (consistent)
   - No issues here, but worth noting for completeness

### 🟢 Compatible Fields

1. **Core Authentication Fields**
   - `email` - Consistent across all layers
   - `password` - Consistent for requests (properly hashed in DB)
   - `id` - Consistent (UUID in DB, string in API/Frontend)

2. **Timestamps**
   - `created_at`, `updated_at` - Properly formatted as ISO strings

3. **Role and Permission Arrays**
   - Properly structured across all layers

## 5. Recommendations

### Immediate Fixes Required

1. **Fix Frontend User Type**
   ```typescript
   interface User {
     // ... existing fields ...
     email_verified: boolean;  // Replace is_verified
     full_name?: string;
     username?: string;
     two_factor_enabled: boolean;
     // Remove is_verified field
   }
   ```

2. **Update Registration Flow**
   - Ensure backend properly splits `name` field into `first_name` and `last_name`
   - Or update database to store a single `name` field

3. **Add Missing LoginRequest Fields**
   ```typescript
   interface LoginRequest {
     email: string;
     password: string;
     rememberMe?: boolean;  // Add this
   }
   ```

4. **Standardize Profile Picture Field**
   - Use consistent naming: either `avatar_url` or `profile_picture` everywhere

### Backend Service Layer Validation
The backend should have a service layer that:
- Validates and transforms registration data properly
- Handles the `name` → `first_name`/`last_name` split
- Ensures all required database fields are populated
- Provides proper error messages for validation failures

## 6. Current State Assessment

### Working Features ✅
- Basic login/logout flow
- Password hashing and verification
- JWT token generation
- Role and permission management

### At Risk Features ⚠️
- User registration (name field handling)
- Email verification status display
- Profile picture display
- Remember me functionality
- Two-factor authentication status

## Conclusion

The system has several field naming inconsistencies that need to be addressed for full compatibility. The most critical issue is the handling of user names during registration, where the frontend sends a single `name` field but the database expects separate `first_name` and `last_name` fields. The backend appears to have backward compatibility code but this needs verification through testing.

Priority should be given to:
1. Fixing the registration name field handling
2. Standardizing the email verification field naming
3. Ensuring profile picture fields are consistent
4. Adding missing fields to frontend types

These changes will ensure smooth data flow across all three layers of the application.