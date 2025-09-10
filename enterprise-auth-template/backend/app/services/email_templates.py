"""
Email Template System

Provides a comprehensive template system for emails with support for
multiple template engines and customizable templates.
"""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Dict, Any, Optional
from datetime import datetime
import os

import structlog
from jinja2 import Environment, FileSystemLoader, Template, select_autoescape

logger = structlog.get_logger(__name__)


class EmailTemplate(ABC):
    """Abstract base class for email templates."""

    @abstractmethod
    def render(self, **context: Any) -> Dict[str, str]:
        """
        Render the template with given context.

        Args:
            **context: Template context variables

        Returns:
            Dict with 'html' and 'text' content
        """
        pass


class Jinja2EmailTemplate(EmailTemplate):
    """Jinja2-based email template."""

    def __init__(
        self,
        html_template: Optional[str] = None,
        text_template: Optional[str] = None,
        html_template_path: Optional[Path] = None,
        text_template_path: Optional[Path] = None,
    ):
        """
        Initialize Jinja2 email template.

        Args:
            html_template: HTML template string
            text_template: Text template string
            html_template_path: Path to HTML template file
            text_template_path: Path to text template file
        """
        self.env = Environment(
            loader=FileSystemLoader(Path(__file__).parent / "templates"),
            autoescape=select_autoescape(["html", "xml"]),
        )

        # Load templates
        if html_template:
            self.html_template: Optional[Template] = Template(html_template)
        elif html_template_path:
            self.html_template = self.env.get_template(str(html_template_path))
        else:
            self.html_template = None

        if text_template:
            self.text_template: Optional[Template] = Template(text_template)
        elif text_template_path:
            self.text_template = self.env.get_template(str(text_template_path))
        else:
            self.text_template = None

    def render(self, **context: Any) -> Dict[str, str]:
        """Render templates with context."""
        result = {}

        # Add default context
        default_context = {
            "current_year": datetime.now().year,
            "current_date": datetime.now().strftime("%Y-%m-%d"),
            "current_time": datetime.now().strftime("%H:%M:%S"),
        }
        context = {**default_context, **context}

        if self.html_template:
            result["html"] = self.html_template.render(**context)

        if self.text_template:
            result["text"] = self.text_template.render(**context)

        return result


class EmailTemplateManager:
    """Manages email templates and provides rendering functionality."""

    def __init__(self, template_dir: Optional[Path] = None):
        """
        Initialize template manager.

        Args:
            template_dir: Directory containing email templates
        """
        if template_dir:
            self.template_dir = template_dir
        else:
            self.template_dir = Path(__file__).parent / "templates"

        self.env = Environment(
            loader=FileSystemLoader(self.template_dir),
            autoescape=select_autoescape(["html", "xml"]),
        )

        # Predefined templates
        self.templates = {
            "verification": self._get_verification_template(),
            "password_reset": self._get_password_reset_template(),
            "welcome": self._get_welcome_template(),
            "account_locked": self._get_account_locked_template(),
            "magic_link": self._get_magic_link_template(),
            "password_changed": self._get_password_changed_template(),
            "2fa_verification": self._get_2fa_verification_template(),
            "notification": self._get_notification_template(),
        }

    def get_template(self, template_name: str) -> EmailTemplate:
        """
        Get a template by name.

        Args:
            template_name: Name of the template

        Returns:
            EmailTemplate instance
        """
        if template_name in self.templates:
            return self.templates[template_name]

        # Try to load from file
        html_path = self.template_dir / f"{template_name}.html"
        text_path = self.template_dir / f"{template_name}.txt"

        if html_path.exists() or text_path.exists():
            return Jinja2EmailTemplate(
                html_template_path=html_path if html_path.exists() else None,
                text_template_path=text_path if text_path.exists() else None,
            )

        raise ValueError(f"Template '{template_name}' not found")

    def render_template(
        self,
        template_name: str,
        **context: Any
    ) -> Dict[str, str]:
        """
        Render a template with context.

        Args:
            template_name: Name of the template
            **context: Template context variables

        Returns:
            Dict with 'html' and 'text' content
        """
        template = self.get_template(template_name)
        return template.render(**context)

    def _get_verification_template(self) -> EmailTemplate:
        """Get email verification template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 14px 35px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                  color: white; text-decoration: none; border-radius: 50px; margin: 25px 0; font-weight: 600; font-size: 16px; }
        .button:hover { opacity: 0.9; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
        .url-box { background-color: #f8f9fa; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; word-break: break-all; margin: 20px 0; font-family: monospace; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ app_name }}</h1>
            <p style="margin: 0; opacity: 0.9;">Email Verification Required</p>
        </div>
        <div class="content">
            <h2>Welcome, {{ user_name }}!</h2>
            <p>Thank you for signing up for {{ app_name }}. To complete your registration and activate your account, please verify your email address by clicking the button below:</p>

            <div style="text-align: center;">
                <a href="{{ verification_url }}" class="button">Verify Email Address</a>
            </div>

            <p>Or copy and paste this link into your browser:</p>
            <div class="url-box">{{ verification_url }}</div>

            <p style="color: #dc3545; font-weight: 500;">⏰ This link will expire in 24 hours for your security.</p>

            <p style="margin-top: 30px; padding-top: 30px; border-top: 1px solid #e0e0e0; color: #666;">
                If you didn't create an account with {{ app_name }}, please ignore this email. No action is required on your part.
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>This is an automated message, please do not reply to this email.</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Welcome to {{ app_name }}, {{ user_name }}!

Thank you for signing up. To complete your registration, please verify your email address by visiting the following link:

{{ verification_url }}

This link will expire in 24 hours.

If you didn't create an account with {{ app_name }}, please ignore this email.

Best regards,
The {{ app_name }} Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_password_reset_template(self) -> EmailTemplate:
        """Get password reset template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 14px 35px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                  color: white; text-decoration: none; border-radius: 50px; margin: 25px 0; font-weight: 600; font-size: 16px; }
        .warning { background-color: #fff3cd; border: 1px solid #ffc107; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
        .url-box { background-color: #f8f9fa; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; word-break: break-all; margin: 20px 0; font-family: monospace; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Password Reset Request</h1>
            <p style="margin: 0; opacity: 0.9;">{{ app_name }}</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}</h2>
            <p>We received a request to reset your password for your {{ app_name }} account.</p>
            <p>Click the button below to reset your password:</p>

            <div style="text-align: center;">
                <a href="{{ reset_url }}" class="button">Reset Password</a>
            </div>

            <p>Or copy and paste this link into your browser:</p>
            <div class="url-box">{{ reset_url }}</div>

            <div class="warning">
                <strong>🔒 Security Notice:</strong> This link will expire in 1 hour for your security.
                If you didn't request a password reset, please ignore this email and your password will remain unchanged.
            </div>

            <p style="margin-top: 30px; padding-top: 30px; border-top: 1px solid #e0e0e0; color: #666;">
                For security reasons, we recommend that you:
                <ul style="color: #666;">
                    <li>Use a strong, unique password</li>
                    <li>Enable two-factor authentication</li>
                    <li>Never share your password with anyone</li>
                </ul>
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>This is an automated security notification.</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Hello {{ user_name }},

We received a request to reset your password for your {{ app_name }} account.

To reset your password, visit the following link:
{{ reset_url }}

This link will expire in 1 hour for your security.

If you didn't request a password reset, please ignore this email and your password will remain unchanged.

Best regards,
The {{ app_name }} Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_welcome_template(self) -> EmailTemplate:
        """Get welcome email template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 50px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 14px 35px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                  color: white; text-decoration: none; border-radius: 50px; margin: 25px 0; font-weight: 600; font-size: 16px; }
        .feature { background-color: #f8f9fa; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #667eea; }
        .feature h3 { margin-top: 0; color: #667eea; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Welcome to {{ app_name }}!</h1>
            <p style="margin: 0; opacity: 0.9; font-size: 18px;">Your journey begins here</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}!</h2>
            <p>We're thrilled to have you join our community. Your account has been successfully created, and you now have access to all our enterprise-grade features.</p>

            <div class="feature">
                <h3>🔐 Advanced Security</h3>
                <p>Multi-factor authentication, biometric login, and enterprise-grade encryption keep your data safe.</p>
            </div>

            <div class="feature">
                <h3>🚀 Powerful Features</h3>
                <p>API keys, webhooks, team collaboration, and advanced analytics at your fingertips.</p>
            </div>

            <div class="feature">
                <h3>📊 Real-time Insights</h3>
                <p>Monitor your usage, track performance, and get actionable insights with our dashboard.</p>
            </div>

            <div style="text-align: center;">
                <a href="{{ dashboard_url }}" class="button">Go to Dashboard</a>
            </div>

            <h3>Getting Started:</h3>
            <ol>
                <li><strong>Complete your profile</strong> - Add your details and preferences</li>
                <li><strong>Enable 2FA</strong> - Secure your account with two-factor authentication</li>
                <li><strong>Explore features</strong> - Check out our API documentation and integrations</li>
                <li><strong>Join the community</strong> - Connect with other users and share experiences</li>
            </ol>

            <p style="margin-top: 30px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
                Need help? Our support team is here for you 24/7. Visit our <a href="{{ help_url }}" style="color: #667eea;">Help Center</a> or <a href="{{ support_url }}" style="color: #667eea;">Contact Support</a>.
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p><a href="{{ unsubscribe_url }}" style="color: #666;">Unsubscribe</a> | <a href="{{ privacy_url }}" style="color: #666;">Privacy Policy</a></p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Welcome to {{ app_name }}, {{ user_name }}!

We're thrilled to have you join our community. Your account has been successfully created.

What you can do now:
- Complete your profile
- Enable two-factor authentication for enhanced security
- Explore our API keys, webhooks, and integrations
- Configure your notification preferences

Get started: {{ dashboard_url }}

Need help? Visit our help center: {{ help_url }}
Or contact support: {{ support_url }}

Best regards,
The {{ app_name }} Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_account_locked_template(self) -> EmailTemplate:
        """Get account locked template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .alert { background-color: #f8d7da; border: 1px solid #dc3545; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚠️ Security Alert</h1>
            <p style="margin: 0; opacity: 0.9;">{{ app_name }}</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}</h2>

            <div class="alert">
                <strong>Your account has been temporarily locked</strong> due to {{ failed_attempts }} failed login attempts.
            </div>

            <p>For your security, your account will be locked until: <strong>{{ locked_until }}</strong></p>

            <h3>If this was you:</h3>
            <ul>
                <li>Wait until the lock expires to try again</li>
                <li>Use the "Forgot Password" option if you've forgotten your password</li>
                <li>Ensure you're using the correct email and password</li>
            </ul>

            <h3>If this wasn't you:</h3>
            <ul>
                <li>Someone may be trying to access your account</li>
                <li>Consider changing your password once the lock expires</li>
                <li>Enable two-factor authentication for added security</li>
                <li>Review your recent account activity</li>
            </ul>

            <p style="margin-top: 30px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
                If you need immediate assistance, please <a href="{{ support_url }}" style="color: #667eea;">contact our support team</a>.
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>This is an automated security notification.</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Security Alert for {{ user_name }},

Your {{ app_name }} account has been temporarily locked due to {{ failed_attempts }} failed login attempts.

Your account will be locked until: {{ locked_until }}

If this was you, please wait until the lock expires or use the "Forgot Password" option.
If this wasn't you, someone may be trying to access your account. Consider changing your password and enabling two-factor authentication.

Best regards,
The {{ app_name }} Security Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_magic_link_template(self) -> EmailTemplate:
        """Get magic link template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
                  color: white; text-decoration: none; border-radius: 50px; margin: 25px 0; font-weight: 600; font-size: 18px; }
        .security { background-color: #fef3c7; border: 1px solid #f59e0b; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
        .url-box { background-color: #f8f9fa; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; word-break: break-all; margin: 20px 0; font-family: monospace; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✨ Magic Link Sign In</h1>
            <p style="margin: 0; opacity: 0.9;">{{ app_name }}</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}!</h2>
            <p>You requested a magic link to sign in to your {{ app_name }} account. Click the button below to instantly sign in:</p>

            <div style="text-align: center;">
                <a href="{{ magic_link_url }}" class="button">🔮 Sign In with Magic Link</a>
            </div>

            <p>Or copy and paste this link into your browser:</p>
            <div class="url-box">{{ magic_link_url }}</div>

            <div class="security">
                <strong>⏱️ Security Notice:</strong> This magic link will expire in 15 minutes and can only be used once.
                If you didn't request this link, you can safely ignore this email.
            </div>

            <p style="color: #666; font-size: 14px; margin-top: 30px;">
                💡 <strong>Pro Tip:</strong> Magic links provide a secure, password-free way to sign in. No need to remember passwords!
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>This is an automated message, please do not reply.</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Hello {{ user_name }},

You requested a magic link to sign in to your {{ app_name }} account.

Click the following link to sign in instantly:
{{ magic_link_url }}

This magic link will expire in 15 minutes and can only be used once.

If you didn't request this link, you can safely ignore this email.

Best regards,
The {{ app_name }} Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_password_changed_template(self) -> EmailTemplate:
        """Get password changed notification template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .info { background-color: #d4edda; border: 1px solid #28a745; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✅ Password Changed Successfully</h1>
            <p style="margin: 0; opacity: 0.9;">{{ app_name }}</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}</h2>

            <div class="info">
                <strong>Your password has been successfully changed.</strong>
            </div>

            <p>If you made this change, no further action is required.</p>

            <h3>If you didn't make this change:</h3>
            <ul>
                <li>Your account may be compromised</li>
                <li><a href="{{ reset_password_url }}" style="color: #dc3545; font-weight: bold;">Reset your password immediately</a></li>
                <li>Review your account activity</li>
                <li>Enable two-factor authentication</li>
                <li>Contact support if you need assistance</li>
            </ul>

            <p style="margin-top: 30px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
                For additional security, we recommend:
                <ul>
                    <li>Using a unique password for each online account</li>
                    <li>Enabling two-factor authentication</li>
                    <li>Regularly reviewing your account activity</li>
                </ul>
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>This is an automated security notification.</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Hello {{ user_name }},

Your {{ app_name }} password has been successfully changed.

If you made this change, no further action is required.

If you didn't make this change, your account may be compromised.
Please reset your password immediately and contact support.

Best regards,
The {{ app_name }} Security Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_2fa_verification_template(self) -> EmailTemplate:
        """Get 2FA verification code template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .code-display { font-family: 'Courier New', monospace; font-size: 42px; font-weight: bold; color: #dc2626; letter-spacing: 10px; text-align: center; margin: 30px 0; padding: 25px; background-color: #fef3c7; border: 3px dashed #dc2626; border-radius: 10px; }
        .security-notice { background-color: #fef2f2; border: 1px solid #dc2626; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Two-Factor Authentication</h1>
            <p style="margin: 0; opacity: 0.9;">{{ app_name }}</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}!</h2>
            <p>You're attempting to sign in to your {{ app_name }} account. To complete the login process, please use the verification code below:</p>

            <h3 style="text-align: center; margin-bottom: 0;">Your Verification Code:</h3>
            <div class="code-display">{{ verification_code }}</div>

            <p style="text-align: center; font-weight: bold;">⏰ This code expires in {{ expires_in }} minutes</p>

            <div class="security-notice">
                <h3 style="color: #dc2626; margin-top: 0;">🛡️ Security Information</h3>
                <ul>
                    <li><strong>Never share this code</strong> with anyone</li>
                    <li><strong>Use only once</strong> - code becomes invalid after use</li>
                    <li><strong>Time-sensitive</strong> - expires automatically</li>
                </ul>

                <p style="margin-bottom: 0;">
                    <strong>Login Details:</strong><br>
                    Time: {{ generated_at }}<br>
                    IP Address: {{ request_ip }}<br>
                    Device: {{ user_agent }}
                </p>
            </div>

            <p style="background-color: #fef3c7; padding: 15px; border-radius: 8px;">
                <strong>Didn't request this code?</strong> If you didn't attempt to sign in, someone may be trying to access your account.
                Do not use this code and secure your account immediately.
            </p>
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>This security code was sent to {{ user_email }}</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
Hello {{ user_name }},

Your {{ app_name }} verification code is: {{ verification_code }}

This code expires in {{ expires_in }} minutes and can only be used once.

Login Details:
Time: {{ generated_at }}
IP Address: {{ request_ip }}
Device: {{ user_agent }}

If you didn't request this code, someone may be trying to access your account.
Do not use this code and secure your account immediately.

Best regards,
The {{ app_name }} Security Team

© {{ current_year }} {{ app_name }}. All rights reserved.
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )

    def _get_notification_template(self) -> EmailTemplate:
        """Get generic notification template."""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: {% if notification_type == 'success' %}linear-gradient(135deg, #10b981 0%, #059669 100%){% elif notification_type == 'warning' %}linear-gradient(135deg, #f59e0b 0%, #d97706 100%){% elif notification_type == 'danger' %}linear-gradient(135deg, #dc2626 0%, #b91c1c 100%){% else %}linear-gradient(135deg, #3b82f6 0%, #1e40af 100%){% endif %}; color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background-color: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px; }
        .notification { background-color: #f8f9fa; border-left: 4px solid {% if notification_type == 'success' %}#10b981{% elif notification_type == 'warning' %}#f59e0b{% elif notification_type == 'danger' %}#dc2626{% else %}#3b82f6{% endif %}; padding: 20px; margin: 20px 0; }
        .footer { text-align: center; padding: 30px 20px; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ notification_icon }} {{ notification_title }}</h1>
            <p style="margin: 0; opacity: 0.9;">{{ app_name }}</p>
        </div>
        <div class="content">
            <h2>Hello, {{ user_name }}!</h2>

            <div class="notification">
                {{ notification_message | safe }}
            </div>

            {% if action_url %}
            <div style="text-align: center; margin: 30px 0;">
                <a href="{{ action_url }}" style="display: inline-block; padding: 14px 35px; background: linear-gradient(135deg, #3b82f6 0%, #1e40af 100%); color: white; text-decoration: none; border-radius: 50px; font-weight: 600;">{{ action_text | default('Take Action') }}</a>
            </div>
            {% endif %}

            {% if additional_info %}
            <div style="margin-top: 30px; padding-top: 30px; border-top: 1px solid #e0e0e0;">
                {{ additional_info | safe }}
            </div>
            {% endif %}
        </div>
        <div class="footer">
            <p>&copy; {{ current_year }} {{ app_name }}. All rights reserved.</p>
            <p>Notification ID: {{ notification_id }}</p>
        </div>
    </div>
</body>
</html>
"""

        text_template = """
{{ notification_title }}

Hello {{ user_name }},

{{ notification_message }}

{% if action_url %}
{{ action_text | default('Take Action') }}: {{ action_url }}
{% endif %}

{% if additional_info %}
{{ additional_info }}
{% endif %}

Best regards,
The {{ app_name }} Team

© {{ current_year }} {{ app_name }}. All rights reserved.
Notification ID: {{ notification_id }}
"""

        return Jinja2EmailTemplate(
            html_template=html_template,
            text_template=text_template,
        )


# Singleton instance
email_template_manager = EmailTemplateManager()
