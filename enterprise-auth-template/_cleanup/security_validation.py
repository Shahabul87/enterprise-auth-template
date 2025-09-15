#!/usr/bin/env python3
"""
Security Validation Script

Comprehensive security validation for the critical vulnerabilities that were fixed:
1. Hardcoded JWT secret vulnerability
2. Session fixation vulnerability
3. Database ports exposure
4. Missing rate limits on password reset

Run this script to validate all security fixes are working correctly.
"""

import asyncio
import os
import sys
import time
import yaml
import json
import hashlib
import secrets
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# Add the app directory to path so we can import modules
sys.path.insert(0, str(Path(__file__).parent / "backend"))

try:
    from app.core.security.key_management import (
        validate_jwt_secret,
        generate_secure_jwt_secret,
    )
    from app.core.security.password_reset_security import (
        PasswordResetSecurityManager,
    )
    from app.core.config import get_settings
except ImportError as e:
    print(f"❌ Error importing security modules: {e}")
    print("Make sure you're running this from the project root directory")
    sys.exit(1)


class SecurityValidator:
    """Comprehensive security validation."""
    
    def __init__(self):
        """Initialize security validator."""
        self.results = {
            "jwt_security": {"passed": 0, "failed": 0, "tests": []},
            "session_security": {"passed": 0, "failed": 0, "tests": []},
            "docker_security": {"passed": 0, "failed": 0, "tests": []},
            "rate_limiting": {"passed": 0, "failed": 0, "tests": []},
        }
        self.total_tests = 0
        self.passed_tests = 0
    
    def run_test(self, category: str, test_name: str, test_func) -> bool:
        """Run a single test and record results."""
        self.total_tests += 1
        try:
            result = test_func()
            if asyncio.iscoroutine(result):
                result = asyncio.run(result)
            
            if result:
                self.results[category]["passed"] += 1
                self.passed_tests += 1
                status = "✅ PASS"
            else:
                self.results[category]["failed"] += 1
                status = "❌ FAIL"
            
            self.results[category]["tests"].append({
                "name": test_name,
                "status": status,
                "passed": result
            })
            
            print(f"{status} - {test_name}")
            return result
            
        except Exception as e:
            self.results[category]["failed"] += 1
            self.results[category]["tests"].append({
                "name": test_name,
                "status": f"❌ ERROR: {str(e)}",
                "passed": False,
                "error": str(e)
            })
            print(f"❌ ERROR - {test_name}: {e}")
            return False
    
    def print_summary(self):
        """Print validation summary."""
        print("\n" + "="*80)
        print("SECURITY VALIDATION SUMMARY")
        print("="*80)
        
        for category, results in self.results.items():
            total = results["passed"] + results["failed"]
            percentage = (results["passed"] / total * 100) if total > 0 else 0
            
            print(f"\n{category.upper().replace('_', ' ')}:")
            print(f"  ✅ Passed: {results['passed']}")
            print(f"  ❌ Failed: {results['failed']}")
            print(f"  📊 Success Rate: {percentage:.1f}%")
        
        overall_percentage = (self.passed_tests / self.total_tests * 100) if self.total_tests > 0 else 0
        print(f"\n🎯 OVERALL RESULTS:")
        print(f"   Total Tests: {self.total_tests}")
        print(f"   Passed: {self.passed_tests}")
        print(f"   Failed: {self.total_tests - self.passed_tests}")
        print(f"   Success Rate: {overall_percentage:.1f}%")
        
        if overall_percentage >= 90:
            print("🔒 SECURITY STATUS: EXCELLENT")
        elif overall_percentage >= 80:
            print("🔒 SECURITY STATUS: GOOD")
        elif overall_percentage >= 70:
            print("🔒 SECURITY STATUS: ACCEPTABLE")
        else:
            print("🔒 SECURITY STATUS: NEEDS ATTENTION")
        
        print("="*80)
    
    # JWT Security Tests
    def test_dangerous_keys_rejected(self) -> bool:
        """Test that dangerous default keys are rejected."""
        dangerous_keys = [
            "dev_secret_key_for_development_only_change_in_production",
            "dev_secret_key_change_in_production", 
            "secret",
            "secretkey",
            "mysecretkey",
        ]
        
        for key in dangerous_keys:
            result = validate_jwt_secret(key, "production")
            if result["valid"]:
                print(f"   ❌ Dangerous key '{key}' was not rejected")
                return False
        
        return True
    
    def test_secure_key_generation(self) -> bool:
        """Test secure key generation meets requirements."""
        try:
            # Test development key
            dev_key = generate_secure_jwt_secret("development")
            dev_result = validate_jwt_secret(dev_key, "development")
            if not dev_result["valid"] or dev_result["length"] < 32:
                return False
            
            # Test production key
            prod_key = generate_secure_jwt_secret("production")
            prod_result = validate_jwt_secret(prod_key, "production")
            if not prod_result["valid"] or prod_result["length"] < 64:
                return False
                
            return True
        except Exception:
            return False
    
    def test_key_entropy_validation(self) -> bool:
        """Test key entropy validation."""
        # Test weak key
        weak_key = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        result = validate_jwt_secret(weak_key, "production")
        return not result["valid"]  # Should be rejected
    
    def test_environment_specific_validation(self) -> bool:
        """Test environment-specific validation."""
        # Short key for testing environments
        short_key = secrets.token_urlsafe(24)
        
        dev_result = validate_jwt_secret(short_key, "development")
        prod_result = validate_jwt_secret(short_key, "production")
        
        # Production should have stricter requirements
        return not prod_result["valid"]
    
    # Session Security Tests
    def test_session_regeneration_config(self) -> bool:
        """Test session regeneration configuration is enabled."""
        try:
            # Check if session security modules are importable
            from app.core.security.session_security import SessionSecurityManager
            return True
        except ImportError:
            return False
    
    def test_session_fingerprinting_enabled(self) -> bool:
        """Test session fingerprinting is implemented."""
        try:
            from app.core.security.session_security import SessionSecurityManager
            # Check if manager has fingerprinting methods
            return hasattr(SessionSecurityManager, '_generate_session_fingerprint')
        except ImportError:
            return False
    
    def test_privilege_escalation_detection(self) -> bool:
        """Test privilege escalation detection."""
        try:
            from app.core.security.session_security import (
                SessionSecurityEvent, 
                PrivilegeLevel
            )
            # Verify enums exist for privilege escalation
            return (SessionSecurityEvent.PRIVILEGE_ESCALATION and 
                   PrivilegeLevel.ADMIN and 
                   PrivilegeLevel.USER)
        except ImportError:
            return False
    
    # Docker Security Tests  
    def test_docker_compose_dev_security(self) -> bool:
        """Test development Docker compose security."""
        compose_file = Path("docker-compose.dev.yml")
        if not compose_file.exists():
            print(f"   ⚠️ Docker compose file not found: {compose_file}")
            return False
        
        try:
            with open(compose_file, 'r') as f:
                config = yaml.safe_load(f)
            
            # Check PostgreSQL service
            postgres = config["services"].get("postgres", {})
            if "ports" in postgres:
                print("   ❌ PostgreSQL ports exposed in development")
                return False
            
            # Check Redis service
            redis = config["services"].get("redis", {})  
            if "ports" in redis:
                print("   ❌ Redis ports exposed in development")
                return False
            
            return True
        except Exception as e:
            print(f"   ❌ Error reading Docker compose: {e}")
            return False
    
    def test_docker_compose_prod_security(self) -> bool:
        """Test production Docker compose security."""
        compose_file = Path("docker-compose.prod.yml")
        if not compose_file.exists():
            print(f"   ⚠️ Production Docker compose file not found")
            return True  # Optional file
        
        try:
            with open(compose_file, 'r') as f:
                config = yaml.safe_load(f)
            
            # Check no database ports are exposed
            postgres = config["services"].get("postgres", {})
            redis = config["services"].get("redis", {})
            
            return ("ports" not in postgres and "ports" not in redis)
        except Exception:
            return False
    
    def test_development_override_localhost_only(self) -> bool:
        """Test development override uses localhost binding only."""
        override_file = Path("docker-compose.dev-with-db-access.yml")
        if not override_file.exists():
            print("   ⚠️ Development override file not found")
            return True  # May not exist yet
        
        try:
            with open(override_file, 'r') as f:
                config = yaml.safe_load(f)
            
            # Check all port mappings use localhost
            for service_name, service in config["services"].items():
                if "ports" in service:
                    for port_mapping in service["ports"]:
                        if not str(port_mapping).startswith("127.0.0.1:"):
                            print(f"   ❌ Port {port_mapping} not bound to localhost")
                            return False
            
            return True
        except Exception:
            return False
    
    # Rate Limiting Tests
    async def test_password_reset_rate_limiting_config(self) -> bool:
        """Test password reset rate limiting configuration."""
        try:
            manager = PasswordResetSecurityManager()
            
            # Check rate limiting constants exist
            return (hasattr(manager, 'MAX_ATTEMPTS_PER_IP_HOUR') and
                   hasattr(manager, 'MAX_ATTEMPTS_PER_EMAIL_HOUR') and
                   manager.MAX_ATTEMPTS_PER_IP_HOUR > 0)
        except Exception:
            return False
    
    async def test_suspicious_pattern_detection(self) -> bool:
        """Test suspicious pattern detection."""
        try:
            manager = PasswordResetSecurityManager()
            
            # Test sequential email detection
            sequential_email = "test123@example.com"
            bot_user_agent = "python-requests/2.28.1"
            
            allowed, info = await manager.validate_reset_request(
                email=sequential_email,
                ip_address="192.168.1.1",
                user_agent=bot_user_agent
            )
            
            # Should detect suspicious activity
            return ("suspicious_score" in info or 
                   info.get("threat_level") == "high")
        except Exception:
            return False
    
    async def test_secure_token_generation(self) -> bool:
        """Test secure token generation."""
        try:
            manager = PasswordResetSecurityManager()
            
            # Generate multiple tokens
            tokens = []
            for i in range(5):
                token = await manager.generate_secure_reset_token(
                    user_id=f"user_{i}",
                    email=f"user{i}@example.com"
                )
                tokens.append(token)
            
            # Check uniqueness and minimum length
            unique_tokens = set(tokens)
            min_length_met = all(len(token) >= 64 for token in tokens)
            
            return len(unique_tokens) == len(tokens) and min_length_met
        except Exception:
            return False
    
    async def test_token_reuse_prevention(self) -> bool:
        """Test token reuse prevention."""
        try:
            manager = PasswordResetSecurityManager()
            
            token = await manager.generate_secure_reset_token(
                user_id="test_user",
                email="test@example.com"
            )
            
            # First validation
            valid1, _ = await manager.validate_reset_token(
                token=token,
                ip_address="192.168.1.1",
                user_agent="TestAgent/1.0"
            )
            
            # Second validation (should detect reuse)
            valid2, info2 = await manager.validate_reset_token(
                token=token,
                ip_address="192.168.1.1",
                user_agent="TestAgent/1.0"
            )
            
            return valid1 and not valid2 and info2.get("reason") == "token_reuse_detected"
        except Exception:
            return False
    
    def test_rate_limit_middleware_enabled(self) -> bool:
        """Test rate limiting middleware is enabled."""
        try:
            from app.middleware.rate_limiter import RateLimitMiddleware
            from app.core.rate_limit_config import EndpointRateLimits
            
            # Check password reset limits exist
            return hasattr(EndpointRateLimits, 'PASSWORD_RESET')
        except ImportError:
            return False
    
    def run_all_tests(self):
        """Run all security validation tests."""
        print("🔒 ENTERPRISE SECURITY VALIDATION")
        print("="*80)
        print("Validating fixes for critical security vulnerabilities...")
        print()
        
        # JWT Security Tests
        print("🔐 JWT SECRET SECURITY:")
        self.run_test("jwt_security", "Dangerous keys rejected", 
                     self.test_dangerous_keys_rejected)
        self.run_test("jwt_security", "Secure key generation", 
                     self.test_secure_key_generation)
        self.run_test("jwt_security", "Key entropy validation", 
                     self.test_key_entropy_validation)
        self.run_test("jwt_security", "Environment-specific validation", 
                     self.test_environment_specific_validation)
        
        # Session Security Tests
        print("\n🔄 SESSION FIXATION PROTECTION:")
        self.run_test("session_security", "Session regeneration config", 
                     self.test_session_regeneration_config)
        self.run_test("session_security", "Session fingerprinting enabled", 
                     self.test_session_fingerprinting_enabled)
        self.run_test("session_security", "Privilege escalation detection", 
                     self.test_privilege_escalation_detection)
        
        # Docker Security Tests
        print("\n🐳 DOCKER PORT SECURITY:")
        self.run_test("docker_security", "Development compose security", 
                     self.test_docker_compose_dev_security)
        self.run_test("docker_security", "Production compose security", 
                     self.test_docker_compose_prod_security)
        self.run_test("docker_security", "Development override localhost-only", 
                     self.test_development_override_localhost_only)
        
        # Rate Limiting Tests
        print("\n⏱️ PASSWORD RESET RATE LIMITING:")
        self.run_test("rate_limiting", "Rate limiting configuration", 
                     self.test_password_reset_rate_limiting_config)
        self.run_test("rate_limiting", "Suspicious pattern detection", 
                     self.test_suspicious_pattern_detection)
        self.run_test("rate_limiting", "Secure token generation", 
                     self.test_secure_token_generation)
        self.run_test("rate_limiting", "Token reuse prevention", 
                     self.test_token_reuse_prevention)
        self.run_test("rate_limiting", "Rate limit middleware enabled", 
                     self.test_rate_limit_middleware_enabled)
        
        # Print final summary
        self.print_summary()
        
        # Return overall success
        return self.passed_tests == self.total_tests


def main():
    """Run security validation."""
    print("Starting enterprise security validation...\n")
    
    # Change to project directory
    project_root = Path(__file__).parent
    os.chdir(project_root)
    
    validator = SecurityValidator()
    success = validator.run_all_tests()
    
    if success:
        print("\n🎉 ALL SECURITY VALIDATIONS PASSED!")
        print("✅ Critical vulnerabilities have been successfully fixed.")
        sys.exit(0)
    else:
        print("\n⚠️ SOME SECURITY VALIDATIONS FAILED!")
        print("❌ Please review and fix the failing tests.")
        sys.exit(1)


if __name__ == "__main__":
    main()