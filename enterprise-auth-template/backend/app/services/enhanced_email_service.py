"""
Enhanced Email Service with Provider Abstraction

Handles all email communications with support for multiple providers,
template management, and proper error handling.
"""

import os
from pathlib import Path
from typing import Dict, Optional, Any

import structlog
from jinja2 import Environment, FileSystemLoader, Template

from app.core.config import get_settings
from app.services.email_providers import EmailProvider, get_email_provider

settings = get_settings()
logger = structlog.get_logger(__name__)


class EnhancedEmailService:
    """
    Enhanced email service with provider abstraction and template support.

    Features:
    - Multiple provider support (SMTP, SendGrid, AWS SES, etc.)
    - Template management with Jinja2
    - Automatic fallback to console provider in development
    - Comprehensive error handling and logging
    """

    def __init__(self):
        """Initialize enhanced email service."""
        self.settings = settings
        self.provider = self._initialize_provider()
        self.template_env = self._initialize_templates()
        self.from_email = settings.EMAIL_FROM or "noreply@enterprise-auth.com"
        self.from_name = settings.EMAIL_FROM_NAME or "Enterprise Auth"
        self.frontend_url = str(settings.FRONTEND_URL) or "http://localhost:3000"

    def _initialize_provider(self) -> EmailProvider:
        """
        Initialize the email provider based on configuration.

        Returns:
            EmailProvider: Configured email provider instance
        """
        provider_type = settings.EMAIL_PROVIDER or "console"

        # In development, use console provider if email not configured
        if settings.ENVIRONMENT == "development" and not self._is_email_configured():
            logger.info("Using console email provider for development")
            return get_email_provider("console")

        try:
            # Get provider based on configuration
            if provider_type == "smtp":
                provider = get_email_provider(
                    provider_type="smtp",
                    smtp_host=settings.SMTP_HOST,
                    smtp_port=settings.SMTP_PORT,
                    smtp_username=settings.SMTP_USER,
                    smtp_password=settings.SMTP_PASSWORD,
                    smtp_use_tls=settings.SMTP_TLS,
                    smtp_use_ssl=settings.SMTP_SSL,
                )
            elif provider_type == "sendgrid":
                provider = get_email_provider(
                    provider_type="sendgrid",
                    sendgrid_api_key=settings.SENDGRID_API_KEY,
                )
            elif provider_type == "aws_ses":
                provider = get_email_provider(
                    provider_type="aws_ses",
                    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                    aws_region=settings.AWS_REGION,
                )
            elif provider_type == "console":
                provider = get_email_provider(provider_type="console")
            else:
                logger.warning(f"Unknown provider type: {provider_type}, using console")
                provider = get_email_provider("console")

            logger.info(f"Email provider initialized: {provider_type}")
            return provider

        except Exception as e:
            logger.error(f"Failed to initialize email provider: {e}")
            # Fallback to console provider
            return get_email_provider("console")

    def _initialize_templates(self) -> Optional[Environment]:
        """
        Initialize Jinja2 template environment.

        Returns:
            Optional[Environment]: Jinja2 environment or None if templates not found
        """
        try:
            # Look for templates directory
            template_dirs = [
                Path(__file__).parent.parent / "templates" / "email",
                Path(__file__).parent.parent / "templates",
                Path("/app/templates/email"),  # Docker path
                Path("/app/templates"),  # Docker path
            ]

            for template_dir in template_dirs:
                if template_dir.exists():
                    logger.info(f"Using email templates from: {template_dir}")
                    return Environment(
                        loader=FileSystemLoader(str(template_dir)),
                        autoescape=True,
                    )

            logger.warning("No email template directory found, using inline templates")
            return None

        except Exception as e:
            logger.error(f"Failed to initialize templates: {e}")
            return None

    def _is_email_configured(self) -> bool:
        """Check if email service is properly configured."""
        if settings.EMAIL_PROVIDER == "smtp":
            return bool(
                settings.SMTP_HOST and settings.SMTP_USER and settings.SMTP_PASSWORD
            )
        elif settings.EMAIL_PROVIDER == "sendgrid":
            return bool(getattr(settings, "SENDGRID_API_KEY", None))
        elif settings.EMAIL_PROVIDER == "aws_ses":
            return bool(
                getattr(settings, "AWS_ACCESS_KEY_ID", None)
                and getattr(settings, "AWS_SECRET_ACCESS_KEY", None)
            )
        return False

    def _render_template(
        self,
        template_name: str,
        context: Dict[str, Any],
        inline_template: Optional[str] = None,
    ) -> str:
        """
        Render an email template with context.

        Args:
            template_name: Name of the template file
            context: Template context variables
            inline_template: Inline template to use if file not found

        Returns:
            str: Rendered template content
        """
        # Add common context
        context.update(
            {
                "app_name": self.from_name,
                "frontend_url": self.frontend_url,
                "current_year": 2024,
            }
        )

        # Try to load template from file
        if self.template_env:
            try:
                template = self.template_env.get_template(template_name)
                return template.render(**context)
            except Exception as e:
                logger.warning(f"Failed to load template {template_name}: {e}")

        # Fall back to inline template
        if inline_template:
            template = Template(inline_template, autoescape=True)
            return template.render(**context)

        # Last resort: basic template
        return f"""
        <html>
        <body>
            <h1>{context.get('title', 'Email from ' + self.from_name)}</h1>
            <p>{context.get('message', 'No message content')}</p>
        </body>
        </html>
        """

    async def send_email(
        self,
        to_email: str,
        subject: str,
        template_name: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        html_content: Optional[str] = None,
        text_content: Optional[str] = None,
    ) -> bool:
        """
        Send an email using the configured provider.

        Args:
            to_email: Recipient email address
            subject: Email subject
            template_name: Template file name (optional)
            context: Template context (optional)
            html_content: Direct HTML content (optional)
            text_content: Plain text content (optional)

        Returns:
            bool: True if email sent successfully
        """
        try:
            # Render template if provided
            if template_name and context:
                html_content = self._render_template(template_name, context)

            # Ensure we have content to send
            if not html_content and not text_content:
                logger.error("No email content provided")
                return False

            # Send email through provider
            success = await self.provider.send_email(
                to_email=to_email,
                subject=subject,
                html_content=html_content or "",
                text_content=text_content,
                from_email=self.from_email,
                from_name=self.from_name,
            )

            if success:
                logger.info(
                    "Email sent successfully",
                    to_email=to_email,
                    subject=subject,
                    provider=self.provider.__class__.__name__,
                )

            return success

        except Exception as e:
            logger.error(
                "Failed to send email",
                to_email=to_email,
                subject=subject,
                error=str(e),
            )
            return False

    async def send_verification_email(
        self,
        to_email: str,
        user_name: str,
        verification_token: str,
    ) -> bool:
        """Send email verification link."""
        verification_url = f"{self.frontend_url}/auth/verify?token={verification_token}"

        context = {
            "user_name": user_name,
            "verification_url": verification_url,
            "title": "Verify Your Email",
            "message": "Please verify your email address to activate your account.",
        }

        # Inline template as fallback
        inline_template = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                         color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }
                .button { display: inline-block; padding: 14px 35px;
                         background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                         color: white; text-decoration: none; border-radius: 50px;
                         margin: 20px 0; font-weight: bold; }
                .footer { text-align: center; margin-top: 30px; color: #6c757d; font-size: 14px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Welcome to {{ app_name }}!</h1>
                </div>
                <div class="content">
                    <h2>Hello {{ user_name }},</h2>
                    <p>Thank you for signing up! To get started, please verify your email address by clicking the button below:</p>
                    <div style="text-align: center;">
                        <a href="{{ verification_url }}" class="button">Verify Email Address</a>
                    </div>
                    <p style="margin-top: 30px;">Or copy and paste this link into your browser:</p>
                    <p style="background: white; padding: 10px; border: 1px solid #dee2e6;
                              border-radius: 5px; word-break: break-all;">{{ verification_url }}</p>
                    <p style="margin-top: 20px; color: #6c757d;">
                        This link will expire in 24 hours. If you didn't create an account,
                        you can safely ignore this email.
                    </p>
                </div>
                <div class="footer">
                    <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Welcome to {self.from_name}!

        Hello {user_name},

        Please verify your email address by visiting:
        {verification_url}

        This link will expire in 24 hours.

        If you didn't create an account, please ignore this email.

        Best regards,
        The {self.from_name} Team
        """

        return await self.send_email(
            to_email=to_email,
            subject=f"Verify your {self.from_name} account",
            template_name="verification.html",
            context=context,
            html_content=self._render_template(
                "verification.html", context, inline_template
            ),
            text_content=text_content,
        )

    async def send_password_reset_email(
        self,
        to_email: str,
        user_name: str,
        reset_token: str,
    ) -> bool:
        """Send password reset email."""
        reset_url = f"{self.frontend_url}/auth/reset-password?token={reset_token}"

        context = {
            "user_name": user_name,
            "reset_url": reset_url,
            "title": "Reset Your Password",
            "message": "You requested to reset your password.",
        }

        inline_template = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: #dc3545; color: white; padding: 30px;
                         text-align: center; border-radius: 10px 10px 0 0; }
                .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }
                .button { display: inline-block; padding: 14px 35px; background: #dc3545;
                         color: white; text-decoration: none; border-radius: 50px;
                         margin: 20px 0; font-weight: bold; }
                .warning { background: #fff3cd; border: 1px solid #ffc107;
                          padding: 15px; border-radius: 5px; margin: 20px 0; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Password Reset Request</h1>
                </div>
                <div class="content">
                    <h2>Hello {{ user_name }},</h2>
                    <p>We received a request to reset your password. Click the button below to set a new password:</p>
                    <div style="text-align: center;">
                        <a href="{{ reset_url }}" class="button">Reset Password</a>
                    </div>
                    <p>Or copy this link: <code>{{ reset_url }}</code></p>
                    <div class="warning">
                        <strong>Security Notice:</strong> This link expires in 1 hour.
                        If you didn't request this, please ignore this email.
                    </div>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Password Reset Request

        Hello {user_name},

        Reset your password by visiting:
        {reset_url}

        This link expires in 1 hour.

        If you didn't request this, please ignore this email.

        Best regards,
        The {self.from_name} Team
        """

        return await self.send_email(
            to_email=to_email,
            subject=f"Reset your {self.from_name} password",
            template_name="password_reset.html",
            context=context,
            html_content=self._render_template(
                "password_reset.html", context, inline_template
            ),
            text_content=text_content,
        )

    async def send_magic_link_email(
        self,
        to_email: str,
        user_name: str,
        magic_link_token: str,
    ) -> bool:
        """Send magic link for passwordless authentication."""
        magic_url = f"{self.frontend_url}/auth/magic-link?token={magic_link_token}"

        context = {
            "user_name": user_name,
            "magic_url": magic_url,
            "title": "Sign In with Magic Link",
        }

        inline_template = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
                         color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 10px 10px; }
                .button { display: inline-block; padding: 16px 40px;
                         background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
                         color: white; text-decoration: none; border-radius: 50px;
                         margin: 20px 0; font-weight: bold; font-size: 18px; }
                .security { background: #e7f3ff; border: 1px solid #0066cc;
                           padding: 15px; border-radius: 5px; margin: 20px 0; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>✨ Magic Link Sign In</h1>
                </div>
                <div class="content">
                    <h2>Hello {{ user_name }}!</h2>
                    <p>Click the button below to instantly sign in to your account:</p>
                    <div style="text-align: center;">
                        <a href="{{ magic_url }}" class="button">🔮 Sign In Now</a>
                    </div>
                    <div class="security">
                        <strong>⏱️ Security:</strong> This link expires in 15 minutes and can only be used once.
                    </div>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Magic Link Sign In

        Hello {user_name},

        Sign in to your account:
        {magic_url}

        This link expires in 15 minutes.

        Best regards,
        The {self.from_name} Team
        """

        return await self.send_email(
            to_email=to_email,
            subject=f"Sign in to {self.from_name}",
            template_name="magic_link.html",
            context=context,
            html_content=self._render_template(
                "magic_link.html", context, inline_template
            ),
            text_content=text_content,
        )


# Singleton instance
enhanced_email_service = EnhancedEmailService()
