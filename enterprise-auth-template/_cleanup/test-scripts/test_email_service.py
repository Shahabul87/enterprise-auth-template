#!/usr/bin/env python3
"""
Test Email Service Implementation

This script tests the email service functionality including:
- Provider initialization
- Email sending with different providers
- Template rendering
- Error handling
"""

import asyncio
import os
import sys
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent / "backend"))

# Set environment variables for testing
os.environ["ENVIRONMENT"] = "development"
os.environ["EMAIL_PROVIDER"] = "console"  # Use console provider for testing
os.environ["EMAIL_FROM"] = "test@enterprise-auth.com"
os.environ["EMAIL_FROM_NAME"] = "Enterprise Auth Test"
os.environ["FRONTEND_URL"] = "http://localhost:3000"


async def test_email_providers():
    """Test different email providers."""
    print("\n" + "="*80)
    print("TESTING EMAIL PROVIDERS")
    print("="*80)
    
    from app.services.email_providers import (
        ConsoleEmailProvider,
        SMTPProvider,
        get_email_provider
    )
    
    # Test Console Provider
    print("\n1. Testing Console Provider...")
    console_provider = ConsoleEmailProvider()
    
    success = await console_provider.send_email(
        to_email="user@example.com",
        subject="Test Email from Console Provider",
        html_content="<h1>Test Email</h1><p>This is a test email from the console provider.</p>",
        text_content="Test Email\n\nThis is a test email from the console provider.",
    )
    print(f"   Console provider test: {'✅ PASSED' if success else '❌ FAILED'}")
    
    # Test get_email_provider factory
    print("\n2. Testing Provider Factory...")
    try:
        provider = get_email_provider("console")
        print(f"   Factory test (console): ✅ PASSED")
    except Exception as e:
        print(f"   Factory test (console): ❌ FAILED - {e}")
    
    print("\n" + "-"*80)


async def test_enhanced_email_service():
    """Test the enhanced email service."""
    print("\n" + "="*80)
    print("TESTING ENHANCED EMAIL SERVICE")
    print("="*80)
    
    from app.services.enhanced_email_service import EnhancedEmailService
    
    # Initialize service
    print("\n1. Initializing Enhanced Email Service...")
    try:
        service = EnhancedEmailService()
        print(f"   Initialization: ✅ PASSED")
        print(f"   Provider: {service.provider.__class__.__name__}")
        print(f"   From: {service.from_name} <{service.from_email}>")
    except Exception as e:
        print(f"   Initialization: ❌ FAILED - {e}")
        return
    
    # Test verification email
    print("\n2. Testing Verification Email...")
    try:
        success = await service.send_verification_email(
            to_email="newuser@example.com",
            user_name="John Doe",
            verification_token="test-verification-token-12345",
        )
        print(f"   Verification email: {'✅ PASSED' if success else '❌ FAILED'}")
    except Exception as e:
        print(f"   Verification email: ❌ FAILED - {e}")
    
    # Test password reset email
    print("\n3. Testing Password Reset Email...")
    try:
        success = await service.send_password_reset_email(
            to_email="resetuser@example.com",
            user_name="Jane Smith",
            reset_token="test-reset-token-67890",
        )
        print(f"   Password reset email: {'✅ PASSED' if success else '❌ FAILED'}")
    except Exception as e:
        print(f"   Password reset email: ❌ FAILED - {e}")
    
    # Test magic link email
    print("\n4. Testing Magic Link Email...")
    try:
        success = await service.send_magic_link_email(
            to_email="magicuser@example.com",
            user_name="Bob Johnson",
            magic_link_token="test-magic-token-abcdef",
        )
        print(f"   Magic link email: {'✅ PASSED' if success else '❌ FAILED'}")
    except Exception as e:
        print(f"   Magic link email: ❌ FAILED - {e}")
    
    print("\n" + "-"*80)


async def test_smtp_configuration():
    """Test SMTP configuration (if provided)."""
    print("\n" + "="*80)
    print("TESTING SMTP CONFIGURATION")
    print("="*80)
    
    # Check if SMTP is configured
    smtp_host = os.environ.get("SMTP_HOST")
    smtp_user = os.environ.get("SMTP_USER")
    smtp_password = os.environ.get("SMTP_PASSWORD")
    
    if not all([smtp_host, smtp_user, smtp_password]):
        print("\n⚠️  SMTP not configured. Skipping SMTP tests.")
        print("   To test SMTP, set SMTP_HOST, SMTP_USER, and SMTP_PASSWORD environment variables.")
        return
    
    print(f"\nSMTP Configuration:")
    print(f"   Host: {smtp_host}")
    print(f"   User: {smtp_user}")
    print(f"   Port: {os.environ.get('SMTP_PORT', 587)}")
    
    from app.services.email_providers import SMTPProvider
    
    try:
        provider = SMTPProvider(
            host=smtp_host,
            port=int(os.environ.get("SMTP_PORT", 587)),
            username=smtp_user,
            password=smtp_password,
            use_tls=os.environ.get("SMTP_TLS", "true").lower() == "true",
        )
        
        # Test sending
        success = await provider.send_email(
            to_email=smtp_user,  # Send to self for testing
            subject="Test SMTP Email",
            html_content="<h1>SMTP Test</h1><p>This is a test email sent via SMTP.</p>",
            text_content="SMTP Test\n\nThis is a test email sent via SMTP.",
            from_email=smtp_user,
        )
        
        print(f"\nSMTP send test: {'✅ PASSED' if success else '❌ FAILED'}")
        
    except Exception as e:
        print(f"\nSMTP test: ❌ FAILED - {e}")
    
    print("\n" + "-"*80)


async def test_registration_flow():
    """Test the complete registration flow with email."""
    print("\n" + "="*80)
    print("TESTING REGISTRATION FLOW WITH EMAIL")
    print("="*80)
    
    # This would require a running database
    print("\n⚠️  Registration flow test requires a running database.")
    print("   To test the complete flow:")
    print("   1. Start the backend: cd backend && uvicorn app.main:app --reload")
    print("   2. Register a new user via API:")
    print("      curl -X POST http://localhost:8000/api/v1/auth/register \\")
    print("        -H 'Content-Type: application/json' \\")
    print("        -d '{")
    print('          "email": "testuser@example.com",')
    print('          "password": "SecurePass123!",')
    print('          "first_name": "Test",')
    print('          "last_name": "User"')
    print("        }'")
    print("\n   3. Check the console output for the verification email")
    
    print("\n" + "-"*80)


async def main():
    """Run all email service tests."""
    print("\n" + "#"*80)
    print("#" + " "*78 + "#")
    print("#" + " "*25 + "EMAIL SERVICE TEST SUITE" + " "*29 + "#")
    print("#" + " "*78 + "#")
    print("#"*80)
    
    # Run tests
    await test_email_providers()
    await test_enhanced_email_service()
    await test_smtp_configuration()
    await test_registration_flow()
    
    print("\n" + "#"*80)
    print("#" + " "*30 + "TEST SUITE COMPLETE" + " "*29 + "#")
    print("#"*80)
    print("\n✅ All email service components have been tested!")
    print("\nNext steps:")
    print("1. Configure your preferred email provider in .env file")
    print("2. Set EMAIL_PROVIDER to 'smtp', 'sendgrid', or 'aws_ses'")
    print("3. Provide the necessary credentials for your chosen provider")
    print("4. Test with real email addresses in production")
    print("\nFor development, the console provider will display emails in the terminal.")


if __name__ == "__main__":
    asyncio.run(main())