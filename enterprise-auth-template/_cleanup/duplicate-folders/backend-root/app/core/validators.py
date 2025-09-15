"""
Input validators for the application.
Provides reusable validation functions and schemas.
"""
import re
from typing import Optional, Any, Dict, List
from datetime import datetime, date
from email_validator import validate_email, EmailNotValidError
from pydantic import BaseModel, Field, validator, constr, EmailStr
from fastapi import HTTPException, status
import phonenumbers
from phonenumbers import NumberParseException

from app.core.constants import (
    MIN_PASSWORD_LENGTH,
    MAX_PASSWORD_LENGTH,
    PASSWORD_REQUIRE_UPPERCASE,
    PASSWORD_REQUIRE_LOWERCASE,
    PASSWORD_REQUIRE_NUMBERS,
    PASSWORD_REQUIRE_SPECIAL,
    EMAIL_REGEX,
    USERNAME_REGEX,
    PHONE_REGEX,
    URL_REGEX,
    MAX_FILE_SIZE_MB,
    ALLOWED_IMAGE_TYPES,
    ALLOWED_DOCUMENT_TYPES,
)


class PasswordValidator:
    """Password validation utility."""
    
    @staticmethod
    def validate(password: str) -> tuple[bool, List[str]]:
        """
        Validate password against security requirements.
        Returns (is_valid, list_of_errors)
        """
        errors = []
        
        if len(password) < MIN_PASSWORD_LENGTH:
            errors.append(f"Password must be at least {MIN_PASSWORD_LENGTH} characters long")
        
        if len(password) > MAX_PASSWORD_LENGTH:
            errors.append(f"Password must not exceed {MAX_PASSWORD_LENGTH} characters")
        
        if PASSWORD_REQUIRE_UPPERCASE and not re.search(r'[A-Z]', password):
            errors.append("Password must contain at least one uppercase letter")
        
        if PASSWORD_REQUIRE_LOWERCASE and not re.search(r'[a-z]', password):
            errors.append("Password must contain at least one lowercase letter")
        
        if PASSWORD_REQUIRE_NUMBERS and not re.search(r'\d', password):
            errors.append("Password must contain at least one number")
        
        if PASSWORD_REQUIRE_SPECIAL and not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            errors.append("Password must contain at least one special character")
        
        # Check for common patterns
        if password.lower() in ['password', '12345678', 'qwerty', 'admin']:
            errors.append("Password is too common")
        
        return len(errors) == 0, errors
    
    @staticmethod
    def get_strength(password: str) -> Dict[str, Any]:
        """Calculate password strength score."""
        score = 0
        feedback = []
        
        # Length score
        if len(password) >= 12:
            score += 2
        elif len(password) >= 8:
            score += 1
        
        # Complexity score
        if re.search(r'[a-z]', password):
            score += 1
        if re.search(r'[A-Z]', password):
            score += 1
        if re.search(r'\d', password):
            score += 1
        if re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            score += 1
        
        # Determine strength level
        if score < 3:
            strength = "weak"
            feedback.append("Consider using a longer password with mixed characters")
        elif score < 5:
            strength = "medium"
            feedback.append("Good password, but could be stronger")
        else:
            strength = "strong"
            feedback.append("Excellent password strength")
        
        return {
            "score": score,
            "strength": strength,
            "feedback": feedback
        }


class EmailValidator:
    """Email validation utility."""
    
    @staticmethod
    def validate(email: str) -> tuple[bool, Optional[str]]:
        """Validate email format and domain."""
        try:
            # Basic regex check
            if not re.match(EMAIL_REGEX, email):
                return False, "Invalid email format"
            
            # Advanced validation
            validation = validate_email(email, check_deliverability=False)
            normalized_email = validation.email
            
            # Check for disposable email domains (basic list)
            disposable_domains = [
                'tempmail.com', 'throwaway.email', '10minutemail.com',
                'guerrillamail.com', 'mailinator.com'
            ]
            domain = normalized_email.split('@')[1].lower()
            if domain in disposable_domains:
                return False, "Disposable email addresses are not allowed"
            
            return True, None
            
        except EmailNotValidError as e:
            return False, str(e)


class PhoneValidator:
    """Phone number validation utility."""
    
    @staticmethod
    def validate(phone: str, country_code: Optional[str] = None) -> tuple[bool, Optional[str]]:
        """Validate phone number format."""
        try:
            # Basic regex check
            if not re.match(PHONE_REGEX, phone):
                return False, "Invalid phone format"
            
            # Parse phone number
            if country_code:
                phone_number = phonenumbers.parse(phone, country_code)
            else:
                phone_number = phonenumbers.parse(phone, None)
            
            # Validate
            if not phonenumbers.is_valid_number(phone_number):
                return False, "Invalid phone number"
            
            return True, None
            
        except NumberParseException:
            return False, "Invalid phone number format"


class UsernameValidator:
    """Username validation utility."""
    
    @staticmethod
    def validate(username: str) -> tuple[bool, Optional[str]]:
        """Validate username format."""
        if not username:
            return False, "Username is required"
        
        if len(username) < 3:
            return False, "Username must be at least 3 characters long"
        
        if len(username) > 30:
            return False, "Username must not exceed 30 characters"
        
        if not re.match(USERNAME_REGEX, username):
            return False, "Username can only contain letters, numbers, underscores, and hyphens"
        
        # Check for reserved usernames
        reserved = ['admin', 'root', 'system', 'api', 'test', 'user']
        if username.lower() in reserved:
            return False, "This username is reserved"
        
        return True, None


class URLValidator:
    """URL validation utility."""
    
    @staticmethod
    def validate(url: str) -> tuple[bool, Optional[str]]:
        """Validate URL format."""
        if not url:
            return False, "URL is required"
        
        if not re.match(URL_REGEX, url):
            return False, "Invalid URL format"
        
        # Check for localhost in production
        if 'localhost' in url.lower() or '127.0.0.1' in url:
            return False, "Local URLs are not allowed"
        
        return True, None


class FileValidator:
    """File validation utility."""
    
    @staticmethod
    def validate_image(filename: str, file_size: int) -> tuple[bool, Optional[str]]:
        """Validate image file."""
        if not filename:
            return False, "Filename is required"
        
        # Check file extension
        ext = filename.lower().split('.')[-1] if '.' in filename else ''
        if f".{ext}" not in ALLOWED_IMAGE_TYPES:
            return False, f"Invalid image type. Allowed types: {', '.join(ALLOWED_IMAGE_TYPES)}"
        
        # Check file size
        max_size_bytes = MAX_FILE_SIZE_MB * 1024 * 1024
        if file_size > max_size_bytes:
            return False, f"File size exceeds {MAX_FILE_SIZE_MB}MB limit"
        
        return True, None
    
    @staticmethod
    def validate_document(filename: str, file_size: int) -> tuple[bool, Optional[str]]:
        """Validate document file."""
        if not filename:
            return False, "Filename is required"
        
        # Check file extension
        ext = filename.lower().split('.')[-1] if '.' in filename else ''
        if f".{ext}" not in ALLOWED_DOCUMENT_TYPES:
            return False, f"Invalid document type. Allowed types: {', '.join(ALLOWED_DOCUMENT_TYPES)}"
        
        # Check file size
        max_size_bytes = MAX_FILE_SIZE_MB * 1024 * 1024
        if file_size > max_size_bytes:
            return False, f"File size exceeds {MAX_FILE_SIZE_MB}MB limit"
        
        return True, None


class DateValidator:
    """Date validation utility."""
    
    @staticmethod
    def validate_date_range(start_date: date, end_date: date) -> tuple[bool, Optional[str]]:
        """Validate date range."""
        if start_date > end_date:
            return False, "Start date must be before end date"
        
        # Check if dates are not too far in the past
        from datetime import timedelta
        min_date = date.today() - timedelta(days=365 * 10)  # 10 years ago
        if start_date < min_date:
            return False, "Date is too far in the past"
        
        # Check if dates are not too far in the future
        max_date = date.today() + timedelta(days=365 * 10)  # 10 years from now
        if end_date > max_date:
            return False, "Date is too far in the future"
        
        return True, None
    
    @staticmethod
    def validate_birth_date(birth_date: date) -> tuple[bool, Optional[str]]:
        """Validate birth date."""
        today = date.today()
        age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
        
        if age < 13:
            return False, "Must be at least 13 years old"
        
        if age > 120:
            return False, "Invalid birth date"
        
        return True, None


# Pydantic Models for Request Validation

class PaginationParams(BaseModel):
    """Pagination parameters."""
    page: int = Field(1, ge=1, description="Page number")
    page_size: int = Field(20, ge=1, le=100, description="Items per page")
    sort_by: Optional[str] = Field(None, description="Field to sort by")
    sort_order: Optional[str] = Field("asc", regex="^(asc|desc)$", description="Sort order")


class SearchParams(BaseModel):
    """Search parameters."""
    query: str = Field(..., min_length=1, max_length=255, description="Search query")
    fields: Optional[List[str]] = Field(None, description="Fields to search in")
    exact_match: bool = Field(False, description="Exact match search")


class DateRangeParams(BaseModel):
    """Date range parameters."""
    start_date: date = Field(..., description="Start date")
    end_date: date = Field(..., description="End date")
    
    @validator('end_date')
    def validate_date_range(cls, v, values):
        if 'start_date' in values and v < values['start_date']:
            raise ValueError('End date must be after start date')
        return v


class UserRegistrationValidator(BaseModel):
    """User registration validation schema."""
    email: EmailStr
    password: constr(min_length=MIN_PASSWORD_LENGTH, max_length=MAX_PASSWORD_LENGTH)
    username: Optional[constr(regex=USERNAME_REGEX)]
    first_name: Optional[constr(min_length=1, max_length=50)]
    last_name: Optional[constr(min_length=1, max_length=50)]
    phone: Optional[str]
    terms_accepted: bool
    
    @validator('password')
    def validate_password(cls, v):
        is_valid, errors = PasswordValidator.validate(v)
        if not is_valid:
            raise ValueError('; '.join(errors))
        return v
    
    @validator('phone')
    def validate_phone(cls, v):
        if v:
            is_valid, error = PhoneValidator.validate(v)
            if not is_valid:
                raise ValueError(error)
        return v
    
    @validator('terms_accepted')
    def validate_terms(cls, v):
        if not v:
            raise ValueError('Terms and conditions must be accepted')
        return v


class PasswordResetValidator(BaseModel):
    """Password reset validation schema."""
    token: str = Field(..., min_length=32)
    new_password: constr(min_length=MIN_PASSWORD_LENGTH, max_length=MAX_PASSWORD_LENGTH)
    confirm_password: str
    
    @validator('new_password')
    def validate_password(cls, v):
        is_valid, errors = PasswordValidator.validate(v)
        if not is_valid:
            raise ValueError('; '.join(errors))
        return v
    
    @validator('confirm_password')
    def passwords_match(cls, v, values):
        if 'new_password' in values and v != values['new_password']:
            raise ValueError('Passwords do not match')
        return v


class ProfileUpdateValidator(BaseModel):
    """Profile update validation schema."""
    first_name: Optional[constr(min_length=1, max_length=50)]
    last_name: Optional[constr(min_length=1, max_length=50)]
    phone: Optional[str]
    bio: Optional[constr(max_length=500)]
    avatar_url: Optional[str]
    timezone: Optional[str]
    language: Optional[constr(regex='^[a-z]{2}$')]
    
    @validator('phone')
    def validate_phone(cls, v):
        if v:
            is_valid, error = PhoneValidator.validate(v)
            if not is_valid:
                raise ValueError(error)
        return v
    
    @validator('avatar_url')
    def validate_avatar_url(cls, v):
        if v:
            is_valid, error = URLValidator.validate(v)
            if not is_valid:
                raise ValueError(error)
        return v


def validate_request_data(data: Dict[str, Any], required_fields: List[str]) -> None:
    """
    Validate that required fields are present in request data.
    Raises HTTPException if validation fails.
    """
    missing_fields = [field for field in required_fields if field not in data or data[field] is None]
    
    if missing_fields:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Missing required fields: {', '.join(missing_fields)}"
        )


def sanitize_input(input_string: str) -> str:
    """
    Sanitize user input to prevent XSS and injection attacks.
    """
    if not input_string:
        return input_string
    
    # Remove HTML tags
    import html
    sanitized = html.escape(input_string)
    
    # Remove potentially dangerous characters
    dangerous_chars = ['<', '>', '"', "'", '&', '%', '=', '(', ')', '{', '}', '[', ']', '`']
    for char in dangerous_chars:
        sanitized = sanitized.replace(char, '')
    
    # Trim whitespace
    sanitized = sanitized.strip()
    
    return sanitized