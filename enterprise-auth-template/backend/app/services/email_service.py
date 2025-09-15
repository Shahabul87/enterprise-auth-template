"""
Email Service

Handles all email communications including verification emails,
password reset emails, and notifications with proper templates.
"""

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Optional, Protocol, Dict, Any
from datetime import datetime
import uuid

import structlog

from app.core.config import get_settings
from app.services.email_providers import (
    EmailProvider,
    EmailProviderFactory,
    EmailResult,
)
from app.services.email_templates import email_template_manager

settings = get_settings()
logger = structlog.get_logger(__name__)


class TemplateEnv(Protocol):
    """Protocol for template environment objects."""

    def get_template(self, name: str): ...


class EmailError(Exception):
    """Email service related errors."""

    pass


class EmailService:
    """
    Email service for sending transactional emails.

    Provides methods for sending verification emails, password resets,
    and other notifications using configurable email providers.
    """

    def __init__(self) -> None:
        """Initialize email service with configuration."""
        self.from_email: str = settings.EMAIL_FROM or "noreply@enterprise-auth.com"
        self.from_name: str = settings.EMAIL_FROM_NAME or "Enterprise Auth"
        self.app_name: str = settings.PROJECT_NAME or "Enterprise Auth"
        self.frontend_url: str = str(settings.FRONTEND_URL) or "http://localhost:3000"

        # Initialize email provider based on configuration
        self.provider = self._initialize_provider()

        # Check if email service is configured
        self.is_configured: bool = self.provider.is_configured() if self.provider else False

        # Template manager
        self.template_manager = email_template_manager

    def _initialize_provider(self) -> Optional[EmailProvider]:
        """Initialize the email provider based on configuration."""
        try:
            provider_type = settings.EMAIL_PROVIDER or "console"

            config = {}

            if provider_type == "smtp":
                config = {
                    "host": settings.SMTP_HOST,
                    "port": settings.SMTP_PORT,
                    "username": settings.SMTP_USER,
                    "password": settings.SMTP_PASSWORD,
                    "use_tls": settings.SMTP_TLS,
                    "use_ssl": settings.SMTP_SSL,
                }
            elif provider_type == "sendgrid":
                config = {
                    "api_key": settings.SENDGRID_API_KEY,
                }
            elif provider_type == "aws_ses":
                config = {
                    "access_key_id": getattr(settings, "AWS_ACCESS_KEY_ID", None),
                    "secret_access_key": getattr(settings, "AWS_SECRET_ACCESS_KEY", None),
                    "region": getattr(settings, "AWS_REGION", "us-east-1"),
                }

            provider = EmailProviderFactory.create_provider(provider_type, config)

            logger.info(
                "Email provider initialized",
                provider_type=provider_type,
                configured=provider.is_configured(),
            )

            return provider

        except Exception as e:
            logger.error(
                "Failed to initialize email provider",
                error=str(e),
            )
            # Fall back to console provider
            return EmailProviderFactory.create_provider("console", {})

    async def _send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        tags: Optional[list] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> bool:
        """
        Send an email using the configured provider.

        Args:
            to_email: Recipient email address
            subject: Email subject
            html_content: HTML email content
            text_content: Plain text content (optional)
            tags: Email tags for tracking
            metadata: Additional metadata

        Returns:
            bool: True if email sent successfully

        Raises:
            EmailError: If sending fails
        """
        if not self.is_configured:
            logger.warning(
                "Email service not configured, skipping email",
                to_email=to_email,
                subject=subject,
            )
            return False

        try:
            if not self.provider:
                logger.error("Email provider is not configured")
                return False

            result = await self.provider.send_email(
                to_email=to_email,
                subject=subject,
                html_content=html_content,
                text_content=text_content,
                from_email=self.from_email,
                from_name=self.from_name,
                tags=tags,
                metadata=metadata,
            )

            if result.success:
                logger.info(
                    "Email sent successfully",
                    to_email=to_email,
                    subject=subject,
                    provider=result.provider,
                    message_id=result.message_id,
                )
                return True
            else:
                logger.error(
                    "Failed to send email",
                    to_email=to_email,
                    subject=subject,
                    error=result.error,
                    provider=result.provider,
                )
                raise EmailError(f"Failed to send email: {result.error}")

        except Exception as e:
            logger.error(
                "Failed to send email",
                to_email=to_email,
                subject=subject,
                error=str(e),
            )
            raise EmailError(f"Failed to send email: {str(e)}")

    async def send_verification_email(
        self, to_email: str, user_name: str, verification_token: str
    ) -> bool:
        """
        Send email verification link.

        Args:
            to_email: Recipient email address
            user_name: User's name
            verification_token: Email verification token

        Returns:
            bool: True if email sent successfully
        """
        verification_url = (
            f"{self.frontend_url}/auth/verify?token={verification_token}"
        )
        subject = f"Verify your {self.app_name} account"

        # Use template manager
        try:
            template_content = self.template_manager.render_template(
                "verification",
                app_name=self.app_name,
                user_name=user_name,
                verification_url=verification_url,
                frontend_url=self.frontend_url,
            )

            return await self._send_email(
                to_email,
                subject,
                template_content.get("html", ""),
                template_content.get("text"),
                tags=["verification", "registration"],
                metadata={"user_name": user_name, "token": verification_token[:8] + "..."},
            )
        except Exception as e:
            logger.error(f"Failed to render template: {e}")
            # Fallback to inline template
            html_content = self._get_inline_verification_html(
                user_name, verification_url
            )

            text_content = f"""
            Welcome to {self.app_name}, {user_name}!

            Please verify your email address by visiting the following link:
            {verification_url}

            This link will expire in 24 hours.

            If you didn't create an account with {self.app_name}, please ignore this email.

            Best regards,
            The {self.app_name} Team
            """

            return await self._send_email(to_email, subject, html_content, text_content)

    def _get_inline_verification_html(
        self, user_name: str, verification_url: str
    ) -> str:
        """Get inline HTML template for verification email."""
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: #4A90E2; color: white; padding: 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .button {{ display: inline-block; padding: 12px 30px; background-color: #4A90E2;
                          color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>{self.app_name}</h1>
                </div>
                <div class="content">
                    <h2>Welcome, {user_name}!</h2>
                    <p>Thank you for signing up for {self.app_name}. To complete your registration,
                       please verify your email address by clicking the button below:</p>
                    <div style="text-align: center;">
                        <a href="{verification_url}" class="button">Verify Email Address</a>
                    </div>
                    <p>Or copy and paste this link into your browser:</p>
                    <p style="word-break: break-all; background-color: #fff; padding: 10px; border: 1px solid #ddd;">
                        {verification_url}
                    </p>
                    <p>This link will expire in 24 hours.</p>
                    <p>If you didn't create an account with {self.app_name},
                       please ignore this email.</p>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                    <p>This is an automated message, please do not reply to this email.</p>
                </div>
            </div>
        </body>
        </html>
        """

    async def send_password_reset_email(
        self, to_email: str, user_name: str, reset_token: str
    ) -> bool:
        """
        Send password reset email.

        Args:
            to_email: Recipient email address
            user_name: User's name
            reset_token: Password reset token

        Returns:
            bool: True if email sent successfully
        """
        reset_url = f"{self.frontend_url}/auth/reset-password?token={reset_token}"

        subject = f"Reset your {self.app_name} password"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: #E74C3C; color: white; padding: 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .button {{ display: inline-block; padding: 12px 30px; background-color: #E74C3C;
                          color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
                .warning {{ background-color: #FFF3CD; border: 1px solid #FFC107; padding: 15px;
                           border-radius: 5px; margin: 20px 0; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Password Reset Request</h1>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}</h2>
                    <p>We received a request to reset your password for your {self.app_name} account.</p>
                    <p>Click the button below to reset your password:</p>
                    <div style="text-align: center;">
                        <a href="{reset_url}" class="button">Reset Password</a>
                    </div>
                    <p>Or copy and paste this link into your browser:</p>
                    <p style="word-break: break-all; background-color: #fff; padding: 10px; border: 1px solid #ddd;">
                        {reset_url}
                    </p>
                    <div class="warning">
                        <strong>Security Notice:</strong> This link will expire in 1 hour
                        for your security. If you didn't request a password reset,
                        please ignore this email and your password will remain unchanged.
                    </div>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                    <p>This is an automated message, please do not reply to this email.</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Hello {user_name},

        We received a request to reset your password for your {self.app_name} account.

        To reset your password, visit the following link:
        {reset_url}

        This link will expire in 1 hour for your security.

        If you didn't request a password reset, please ignore this email and your password will remain unchanged.

        Best regards,
        The {self.app_name} Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    async def send_account_locked_email(
        self,
        to_email: str,
        user_name: str,
        locked_until: str,
        failed_attempts: int,
    ) -> bool:
        """
        Send account locked notification.

        Args:
            to_email: Recipient email address
            user_name: User's name
            locked_until: Lock expiration time
            failed_attempts: Number of failed login attempts

        Returns:
            bool: True if email sent successfully
        """
        subject = f"Security Alert: Your {self.app_name} account has been locked"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: #DC3545; color: white; padding: 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .alert {{ background-color: #F8D7DA; border: 1px solid #DC3545; padding: 15px;
                         border-radius: 5px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Security Alert</h1>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}</h2>
                    <div class="alert">
                        <strong>Your account has been temporarily locked</strong> due to
                        {failed_attempts} failed login attempts.
                    </div>
                    <p>For your security, your account will be locked until: <strong>{locked_until}</strong></p>
                    <p>If this was you:</p>
                    <ul>
                        <li>Wait until the lock expires to try again</li>
                        <li>Use the "Forgot Password" option if you've forgotten your password</li>
                    </ul>
                    <p>If this wasn't you:</p>
                    <ul>
                        <li>Someone may be trying to access your account</li>
                        <li>Consider changing your password once the lock expires</li>
                        <li>Enable two-factor authentication for added security</li>
                    </ul>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                    <p>This is an automated security notification.</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Security Alert for {user_name},

        Your {self.app_name} account has been temporarily locked due to {failed_attempts} failed login attempts.

        Your account will be locked until: {locked_until}

        If this was you, please wait until the lock expires or use the "Forgot Password" option.
        If this wasn't you, someone may be trying to access your account. Consider changing your password.

        Best regards,
        The {self.app_name} Security Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    async def send_magic_link_email(
        self, to_email: str, user_name: str, magic_link_token: str
    ) -> bool:
        """
        Send magic link email for passwordless authentication.

        Args:
            to_email: Recipient email address
            user_name: User's name
            magic_link_token: Magic link token

        Returns:
            bool: True if email sent successfully
        """
        magic_link_url = f"{self.frontend_url}/auth/magic-link?token={magic_link_token}"
        subject = f"Sign in to {self.app_name}"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: #6366F1; color: white; padding: 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .button {{ display: inline-block; padding: 14px 35px; background-color: #6366F1;
                          color: white; text-decoration: none; border-radius: 8px; margin: 20px 0;
                          font-weight: bold; font-size: 16px; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
                .security {{ background-color: #FEF3C7; border: 1px solid #F59E0B; padding: 15px;
                            border-radius: 5px; margin: 20px 0; }}
                .code {{ background-color: #fff; padding: 15px; border: 2px dashed #6366F1;
                        border-radius: 8px; font-size: 18px; text-align: center; margin: 20px 0;
                        font-family: monospace; letter-spacing: 2px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>✨ Magic Link Sign In</h1>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}!</h2>
                    <p>You requested a magic link to sign in to your {self.app_name} account.
                       Click the button below to instantly sign in:</p>
                    <div style="text-align: center;">
                        <a href="{magic_link_url}" class="button">🔮 Sign In with Magic Link</a>
                    </div>
                    <p>Or copy and paste this link into your browser:</p>
                    <p style="word-break: break-all; background-color: #fff; padding: 10px; border: 1px solid #ddd;">
                        {magic_link_url}
                    </p>
                    <div class="security">
                        <strong>⏱️ Security Notice:</strong> This magic link will expire in 15 minutes
                        and can only be used once. If you didn't request this link,
                        you can safely ignore this email.
                    </div>
                    <p style="color: #666; font-size: 14px;">
                        💡 <strong>Tip:</strong> Magic links provide a secure, password-free way to sign in.
                        No need to remember passwords!
                    </p>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                    <p>This is an automated message, please do not reply to this email.</p>
                    <p>Sent to {to_email}</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Hello {user_name},

        You requested a magic link to sign in to your {self.app_name} account.

        Click the following link to sign in instantly:
        {magic_link_url}

        This magic link will expire in 15 minutes and can only be used once.

        If you didn't request this link, you can safely ignore this email.

        Best regards,
        The {self.app_name} Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    async def send_password_changed_email(self, to_email: str, user_name: str) -> bool:
        """
        Send password changed notification.

        Args:
            to_email: Recipient email address
            user_name: User's name

        Returns:
            bool: True if email sent successfully
        """
        subject = f"Your {self.app_name} password has been changed"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: #28A745; color: white; padding: 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .info {{ background-color: #D4EDDA; border: 1px solid #28A745; padding: 15px;
                        border-radius: 5px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Password Changed Successfully</h1>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}</h2>
                    <div class="info">
                        <strong>Your password has been successfully changed.</strong>
                    </div>
                    <p>If you made this change, no further action is required.</p>
                    <p>If you didn't make this change:</p>
                    <ul>
                        <li>Your account may be compromised</li>
                        <li>Reset your password immediately</li>
                        <li>Review your account activity</li>
                        <li>Contact support if you need assistance</li>
                    </ul>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                    <p>This is an automated security notification.</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Hello {user_name},

        Your {self.app_name} password has been successfully changed.

        If you made this change, no further action is required.

        If you didn't make this change, your account may be compromised.
        Please reset your password immediately and contact support.

        Best regards,
        The {self.app_name} Security Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    async def send_welcome_email(self, to_email: str, user_name: str) -> bool:
        """
        Send welcome email for new users.

        Args:
            to_email: Recipient email address
            user_name: User's name

        Returns:
            bool: True if email sent successfully
        """
        from datetime import datetime

        dashboard_url = f"{self.frontend_url}/dashboard"
        help_url = f"{self.frontend_url}/help"
        support_url = f"{self.frontend_url}/support"
        docs_url = f"{self.frontend_url}/docs"
        unsubscribe_url = f"{self.frontend_url}/settings/notifications"
        privacy_url = f"{self.frontend_url}/privacy"

        subject = f"Welcome to {self.app_name}! 🎉"

        # Try to use template if available
        if hasattr(self.template_manager, 'env') and self.template_manager.env:
            try:
                template = self.template_manager.env.get_template("welcome.html")
                html_content = template.render(
                    app_name=self.app_name,
                    user_name=user_name,
                    user_email=to_email,
                    dashboard_url=dashboard_url,
                    help_url=help_url,
                    support_url=support_url,
                    docs_url=docs_url,
                    unsubscribe_url=unsubscribe_url,
                    privacy_url=privacy_url,
                    current_year=datetime.now().year,
                )
            except Exception as e:
                logger.warning(f"Failed to load welcome template: {e}, using inline template")
                html_content = self._get_inline_welcome_html(user_name, dashboard_url)
        else:
            html_content = self._get_inline_welcome_html(user_name, dashboard_url)

        text_content = f"""
        Welcome to {self.app_name}, {user_name}!

        Thank you for joining our secure authentication platform. Your account has been successfully created.

        What you can do now:
        - Set up two-factor authentication for enhanced security
        - Connect your social media accounts for easy sign-in
        - Explore our API keys, webhooks, and integrations
        - Configure your notification preferences

        Get started: {dashboard_url}

        Need help? Visit our help center: {help_url}
        Or contact support: {support_url}

        Best regards,
        The {self.app_name} Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    def _get_inline_welcome_html(self, user_name: str, dashboard_url: str) -> str:
        """Get inline HTML template for welcome email."""
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .button {{ display: inline-block; padding: 12px 30px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
                .feature {{ background-color: #fff; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 4px solid #667eea; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🎉 Welcome to {self.app_name}!</h1>
                    <p>Your secure authentication platform</p>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}!</h2>
                    <p>Thank you for joining {self.app_name}. Your account has been successfully created and you now have access to our enterprise-grade authentication features.</p>

                    <div class="feature">
                        <strong>🔐 Multi-Factor Authentication</strong><br>
                        Secure your account with 2FA, WebAuthn, and biometric authentication
                    </div>

                    <div class="feature">
                        <strong>🚀 Single Sign-On (SSO)</strong><br>
                        Connect with Google, GitHub, Discord, and other providers
                    </div>

                    <div class="feature">
                        <strong>🔑 Magic Link Login</strong><br>
                        Passwordless authentication for ultimate convenience
                    </div>

                    <div style="text-align: center;">
                        <a href="{dashboard_url}" class="button">🎯 Go to Dashboard</a>
                    </div>

                    <h3>Quick Start:</h3>
                    <ol>
                        <li>Set up two-factor authentication in Security Settings</li>
                        <li>Connect your social media accounts for easy sign-in</li>
                        <li>Explore our API keys, webhooks, and integrations</li>
                        <li>Configure your notification preferences</li>
                    </ol>

                    <p><strong>💡 Pro Tip:</strong> Enable WebAuthn (passkeys) for the most secure and convenient authentication experience!</p>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """

    async def send_2fa_verification_email(
        self, to_email: str, user_name: str, verification_code: str, expires_in: int = 5
    ) -> bool:
        """
        Send 2FA verification code via email.

        Args:
            to_email: Recipient email address
            user_name: User's name
            verification_code: 6-digit verification code
            expires_in: Code expiration time in minutes

        Returns:
            bool: True if email sent successfully
        """
        from datetime import datetime

        backup_codes_url = f"{self.frontend_url}/settings/security/backup-codes"
        support_url = f"{self.frontend_url}/support"
        security_settings_url = f"{self.frontend_url}/settings/security"
        privacy_url = f"{self.frontend_url}/privacy"

        subject = f"Your {self.app_name} verification code: {verification_code}"

        # Try to use template if available
        if hasattr(self.template_manager, 'env') and self.template_manager.env:
            try:
                template = self.template_manager.env.get_template("2fa_verification.html")
                html_content = template.render(
                    app_name=self.app_name,
                    user_name=user_name,
                    user_email=to_email,
                    verification_code=verification_code,
                    expires_in=expires_in,
                    generated_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
                    login_location="Your current location",  # This would come from request data
                    backup_codes_url=backup_codes_url,
                    support_url=support_url,
                    security_settings_url=security_settings_url,
                    privacy_url=privacy_url,
                    current_year=datetime.now().year,
                    request_ip="XXX.XXX.XXX.XXX",  # This would come from request data
                    user_agent="Your Browser",  # This would come from request data
                    timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
                    session_id="XXXX-XXXX-XXXX",  # This would come from session data
                )
            except Exception as e:
                logger.warning(f"Failed to load 2FA template: {e}, using inline template")
                html_content = self._get_inline_2fa_html(
                    user_name, verification_code, expires_in
                )
        else:
            html_content = self._get_inline_2fa_html(
                user_name, verification_code, expires_in
            )

        text_content = f"""
        Hello {user_name},

        Your {self.app_name} verification code is: {verification_code}

        This code expires in {expires_in} minutes and can only be used once.

        Enter this code in your authenticator app or login form to complete the sign-in process.

        If you didn't request this code, someone may be trying to access your account.
        Do not use this code and secure your account immediately.

        Best regards,
        The {self.app_name} Security Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    def _get_inline_2fa_html(
        self, user_name: str, verification_code: str, expires_in: int
    ) -> str:
        """Get inline HTML template for 2FA verification email."""
        from datetime import datetime

        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 40px 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .code-display {{ font-family: 'Courier New', monospace; font-size: 36px; font-weight: bold;
                               color: #dc2626; letter-spacing: 8px; text-align: center; margin: 20px 0;
                               padding: 20px; background-color: #fef3c7; border: 2px dashed #dc2626; border-radius: 8px; }}
                .security-notice {{ background-color: #fef2f2; border: 1px solid #dc2626; padding: 20px;
                                   border-radius: 8px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔐 Two-Factor Authentication</h1>
                    <p>Secure login verification</p>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}!</h2>
                    <p>You're attempting to sign in to your {self.app_name} account. To complete the login process, please use the verification code below:</p>

                    <h3 style="text-align: center;">Your Verification Code:</h3>
                    <div class="code-display">{verification_code}</div>

                    <p style="text-align: center;"><strong>⏰ This code expires in {expires_in} minutes</strong></p>
                    <p style="text-align: center; color: #666;">Generated at {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}</p>

                    <div class="security-notice">
                        <h3 style="color: #dc2626;">🛡️ Security Information</h3>
                        <ul>
                            <li><strong>Never share this code</strong> with anyone</li>
                            <li><strong>Use only once</strong> - code becomes invalid after use</li>
                            <li><strong>Time-sensitive</strong> - expires automatically</li>
                        </ul>
                    </div>

                    <p style="background-color: #fef3c7; padding: 15px; border-radius: 8px;">
                        <strong>Didn't request this code?</strong> If you didn't attempt to sign in,
                        someone may be trying to access your account. Do not use this code and
                        secure your account immediately.
                    </p>
                </div>
                <div class="footer">
                    <p>&copy; {datetime.now().year} {self.app_name}. All rights reserved.</p>
                    <p>This security code was sent to {user_name}</p>
                </div>
            </div>
        </body>
        </html>
        """

    async def send_account_notification(
        self,
        to_email: str,
        user_name: str,
        notification_type: str,
        notification_title: str,
        notification_message: str,
        **kwargs
    ) -> bool:
        """
        Send account notification email.

        Args:
            to_email: Recipient email address
            user_name: User's name
            notification_type: Type of notification (success, warning, danger, info)
            notification_title: Notification title
            notification_message: Notification message
            **kwargs: Additional template variables

        Returns:
            bool: True if email sent successfully
        """
        from datetime import datetime
        import uuid

        # Set notification icons based on type
        icons = {
            'success': '✅',
            'warning': '⚠️',
            'danger': '🚨',
            'info': 'ℹ️'
        }

        notification_icon = icons.get(notification_type, 'ℹ️')
        subject = f"{notification_icon} {notification_title} - {self.app_name}"

        # Default URLs
        template_vars = {
            'app_name': self.app_name,
            'user_name': user_name,
            'user_email': to_email,
            'notification_type': notification_type,
            'notification_title': notification_title,
            'notification_message': notification_message,
            'notification_icon': notification_icon,
            'notification_id': str(uuid.uuid4()),
            'sent_at': datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
            'current_year': datetime.now().year,
            'dashboard_url': f"{self.frontend_url}/dashboard",
            'security_settings_url': f"{self.frontend_url}/settings/security",
            'activity_log_url': f"{self.frontend_url}/settings/activity",
            'support_url': f"{self.frontend_url}/support",
            'help_center_url': f"{self.frontend_url}/help",
            'change_password_url': f"{self.frontend_url}/settings/password",
            'unsubscribe_url': f"{self.frontend_url}/settings/notifications",
            'privacy_url': f"{self.frontend_url}/privacy",
            'security_guide_url': f"{self.frontend_url}/help/security",
            **kwargs  # Include any additional variables passed
        }

        # Try to use template if available
        if hasattr(self.template_manager, 'env') and self.template_manager.env:
            try:
                template = self.template_manager.env.get_template("account_notification.html")
                html_content = template.render(**template_vars)
            except Exception as e:
                logger.warning(f"Failed to load notification template: {e}, using inline template")
                html_content = self._get_inline_notification_html(**template_vars)
        else:
            html_content = self._get_inline_notification_html(**template_vars)

        text_content = f"""
        {notification_title}

        Hello {user_name},

        {notification_message}

        Notification Type: {notification_type.upper()}
        Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

        For more details, visit your dashboard: {self.frontend_url}/dashboard

        Best regards,
        The {self.app_name} Team
        """

        return await self._send_email(to_email, subject, html_content, text_content)

    def _get_inline_notification_html(self, **kwargs) -> str:
        """Get inline HTML template for account notifications."""
        notification_type = kwargs.get('notification_type', 'info')
        user_name = kwargs.get('user_name', '')
        notification_message = kwargs.get('notification_message', '')
        notification_icon = kwargs.get('notification_icon', 'ℹ️')

        # Color scheme based on notification type
        colors = {
            'success': {'bg': '#10b981', 'border': '#10b981', 'text': '#166534'},
            'warning': {'bg': '#f59e0b', 'border': '#f59e0b', 'text': '#92400e'},
            'danger': {'bg': '#dc2626', 'border': '#dc2626', 'text': '#b91c1c'},
            'info': {'bg': '#3b82f6', 'border': '#3b82f6', 'text': '#1e40af'}
        }

        color = colors.get(notification_type, colors['info'])

        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background-color: {color['bg']}; color: white; padding: 40px 20px; text-align: center; }}
                .content {{ background-color: #f9f9f9; padding: 30px; }}
                .notification {{ background-color: #fff; border-left: 4px solid {color['border']}; padding: 20px; margin: 20px 0; }}
                .footer {{ text-align: center; padding: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>{notification_icon} Account Notification</h1>
                    <p>{self.app_name}</p>
                </div>
                <div class="content">
                    <h2>Hello, {user_name}!</h2>
                    <div class="notification">
                        <p style="color: {color['text']}; font-weight: bold;">{notification_message}</p>
                    </div>
                    <p>For more information, please visit your dashboard or contact our support team.</p>
                </div>
                <div class="footer">
                    <p>&copy; 2024 {self.app_name}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """


# Singleton instance
email_service = EmailService()
