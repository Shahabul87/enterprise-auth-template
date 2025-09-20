"""
Email Provider Implementations

Provides different email provider implementations with a common interface
for sending transactional emails. Supports SMTP, SendGrid, AWS SES, and more.
"""

import json
import os
import smtplib
from abc import ABC, abstractmethod
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from typing import Dict, List, Optional, Any, Union
import uuid
from datetime import datetime

import structlog

logger = structlog.get_logger(__name__)


class EmailResult:
    """Result object for email sending operations."""

    def __init__(
        self,
        success: bool,
        provider: str,
        message_id: Optional[str] = None,
        error: Optional[str] = None,
        status_code: Optional[int] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        self.success = success
        self.provider = provider
        self.message_id = message_id
        self.error = error
        self.status_code = status_code
        self.metadata = metadata or {}
        self.timestamp = datetime.utcnow()

    def to_dict(self) -> Dict[str, Any]:
        """Convert result to dictionary."""
        return {
            "success": self.success,
            "provider": self.provider,
            "message_id": self.message_id,
            "error": self.error,
            "status_code": self.status_code,
            "metadata": self.metadata,
            "timestamp": self.timestamp.isoformat(),
        }


class EmailProvider(ABC):
    """Abstract base class for email providers."""

    @abstractmethod
    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        from_email: Optional[str] = None,
        from_name: Optional[str] = None,
        reply_to: Optional[str] = None,
        cc: Optional[List[str]] = None,
        bcc: Optional[List[str]] = None,
        attachments: Optional[List[Dict[str, Any]]] = None,
        headers: Optional[Dict[str, str]] = None,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> EmailResult:
        """
        Send an email through the provider.

        Args:
            to_email: Recipient email address
            subject: Email subject
            html_content: HTML email content
            text_content: Plain text content (optional)
            from_email: Sender email address (optional)
            from_name: Sender name (optional)
            reply_to: Reply-to email address
            cc: CC recipients
            bcc: BCC recipients
            attachments: List of attachments
            headers: Custom email headers
            tags: Email tags for tracking
            metadata: Additional metadata

        Returns:
            EmailResult: Result object with send status
        """
        pass

    @abstractmethod
    async def verify_configuration(self) -> bool:
        """Verify provider configuration is valid."""
        pass

    @abstractmethod
    def is_configured(self) -> bool:
        """Check if the provider is properly configured."""
        pass


class SMTPProvider(EmailProvider):
    """SMTP email provider implementation."""

    def __init__(
        self,
        host: str,
        port: int,
        username: str,
        password: str,
        use_tls: bool = True,
        use_ssl: bool = False,
        timeout: int = 30,
    ):
        """
        Initialize SMTP provider.

        Args:
            host: SMTP server host
            port: SMTP server port
            username: SMTP username
            password: SMTP password
            use_tls: Use TLS encryption
            use_ssl: Use SSL encryption
            timeout: Connection timeout in seconds
        """
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.use_tls = use_tls
        self.use_ssl = use_ssl
        self.timeout = timeout

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        from_email: Optional[str] = None,
        from_name: Optional[str] = None,
        reply_to: Optional[str] = None,
        cc: Optional[List[str]] = None,
        bcc: Optional[List[str]] = None,
        attachments: Optional[List[Dict[str, Any]]] = None,
        headers: Optional[Dict[str, str]] = None,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> EmailResult:
        """Send email via SMTP."""
        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["To"] = to_email
            msg["Message-ID"] = f"<{uuid.uuid4()}@{self.host}>"

            # Set from address
            if from_email:
                if from_name:
                    msg["From"] = f"{from_name} <{from_email}>"
                else:
                    msg["From"] = from_email
            else:
                msg["From"] = self.username

            # Set reply-to
            if reply_to:
                msg["Reply-To"] = reply_to

            # Set CC and BCC
            if cc:
                msg["Cc"] = ", ".join(cc)

            # Add custom headers
            if headers:
                for key, value in headers.items():
                    msg[key] = value

            # Add tags as custom header
            if tags:
                msg["X-Tags"] = ", ".join(tags)

            # Add metadata as custom header
            if metadata:
                msg["X-Metadata"] = json.dumps(metadata)

            # Add text content if provided
            if text_content:
                text_part = MIMEText(text_content, "plain", "utf-8")
                msg.attach(text_part)

            # Add HTML content
            html_part = MIMEText(html_content, "html", "utf-8")
            msg.attach(html_part)

            # Handle attachments
            if attachments:
                for attachment in attachments:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(attachment.get("content", b""))
                    encoders.encode_base64(part)
                    part.add_header(
                        "Content-Disposition",
                        f'attachment; filename="{attachment.get("filename", "attachment")}"',
                    )
                    msg.attach(part)

            # Connect and send
            server: Union[smtplib.SMTP, smtplib.SMTP_SSL]
            if self.use_ssl:
                server = smtplib.SMTP_SSL(self.host, self.port, timeout=self.timeout)
            else:
                server = smtplib.SMTP(self.host, self.port, timeout=self.timeout)
                if self.use_tls:
                    server.starttls()

            server.login(self.username, self.password)

            # Combine all recipients
            all_recipients = [to_email]
            if cc:
                all_recipients.extend(cc)
            if bcc:
                all_recipients.extend(bcc)

            server.send_message(msg, to_addrs=all_recipients)
            message_id = msg.get("Message-ID", "")
            server.quit()

            logger.info(
                "Email sent via SMTP",
                to_email=to_email,
                subject=subject,
                message_id=message_id,
                provider="smtp",
            )

            return EmailResult(
                success=True,
                provider="smtp",
                message_id=message_id,
                metadata={"to": to_email, "subject": subject},
            )

        except Exception as e:
            logger.error(
                "Failed to send email via SMTP",
                to_email=to_email,
                subject=subject,
                error=str(e),
                provider="smtp",
            )
            return EmailResult(
                success=False,
                provider="smtp",
                error=str(e),
                metadata={"to": to_email, "subject": subject},
            )

    async def verify_configuration(self) -> bool:
        """Verify SMTP configuration."""
        try:
            server: Union[smtplib.SMTP, smtplib.SMTP_SSL]
            if self.use_ssl:
                server = smtplib.SMTP_SSL(self.host, self.port, timeout=10)
            else:
                server = smtplib.SMTP(self.host, self.port, timeout=10)
                if self.use_tls:
                    server.starttls()

            server.login(self.username, self.password)
            server.quit()

            logger.info("SMTP configuration verified successfully")
            return True

        except Exception as e:
            logger.error("SMTP configuration verification failed", error=str(e))
            return False

    def is_configured(self) -> bool:
        """Check if SMTP is configured."""
        return bool(self.host and self.username and self.password)


class SendGridProvider(EmailProvider):
    """SendGrid email provider implementation."""

    def __init__(self, api_key: str):
        """
        Initialize SendGrid provider.

        Args:
            api_key: SendGrid API key
        """
        self.api_key = api_key
        self._client = None

    def _get_client(self):
        """Get or create SendGrid client."""
        if not self._client:
            try:
                from sendgrid import SendGridAPIClient  # type: ignore[import-not-found]

                self._client = SendGridAPIClient(self.api_key)
            except ImportError:
                raise ImportError(
                    "SendGrid library not installed. Run: pip install sendgrid"
                )
        return self._client

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        from_email: Optional[str] = None,
        from_name: Optional[str] = None,
        reply_to: Optional[str] = None,
        cc: Optional[List[str]] = None,
        bcc: Optional[List[str]] = None,
        attachments: Optional[List[Dict[str, Any]]] = None,
        headers: Optional[Dict[str, str]] = None,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> EmailResult:
        """Send email via SendGrid."""
        try:
            from sendgrid.helpers.mail import Mail, From, To, Cc, Bcc, Content, ReplyTo  # type: ignore[import-not-found]

            client = self._get_client()

            # Build message
            from_addr = From(
                email=from_email or "noreply@example.com", name=from_name or "No Reply"
            )
            to_addr = To(email=to_email)

            message = Mail(
                from_email=from_addr,
                to_emails=to_addr,
                subject=subject,
            )

            if text_content:
                message.content = [
                    Content("text/plain", text_content),
                    Content("text/html", html_content),
                ]
            else:
                message.content = Content("text/html", html_content)

            # Add reply-to
            if reply_to:
                message.reply_to = ReplyTo(reply_to)

            # Add CC recipients
            if cc:
                message.cc = [Cc(email) for email in cc]

            # Add BCC recipients
            if bcc:
                message.bcc = [Bcc(email) for email in bcc]

            # Add custom headers
            if headers:
                message.headers = headers

            # Add categories (tags)
            if tags:
                message.categories = tags

            # Add custom args (metadata)
            if metadata:
                message.custom_args = metadata

            # Send message
            response = client.send(message)

            logger.info(
                "Email sent via SendGrid",
                to_email=to_email,
                subject=subject,
                status_code=response.status_code,
                message_id=response.headers.get("X-Message-Id"),
                provider="sendgrid",
            )

            return EmailResult(
                success=response.status_code in (200, 201, 202),
                provider="sendgrid",
                message_id=response.headers.get("X-Message-Id", ""),
                status_code=response.status_code,
                metadata={"to": to_email, "subject": subject},
            )

        except Exception as e:
            logger.error(
                "Failed to send email via SendGrid",
                to_email=to_email,
                subject=subject,
                error=str(e),
                provider="sendgrid",
            )
            return EmailResult(
                success=False,
                provider="sendgrid",
                error=str(e),
                metadata={"to": to_email, "subject": subject},
            )

    async def verify_configuration(self) -> bool:
        """Verify SendGrid configuration."""
        try:
            client = self._get_client()
            # Test API key by getting account info
            response = client.client.api_keys._(self.api_key.split(".")[-1]).get()
            return response.status_code == 200
        except Exception as e:
            logger.error("SendGrid configuration verification failed", error=str(e))
            return False

    def is_configured(self) -> bool:
        """Check if SendGrid is configured."""
        return bool(self.api_key)


class AWSEmailProvider(EmailProvider):
    """AWS SES email provider implementation."""

    def __init__(
        self,
        aws_access_key_id: str,
        aws_secret_access_key: str,
        aws_region: str = "us-east-1",
    ):
        """
        Initialize AWS SES provider.

        Args:
            aws_access_key_id: AWS access key ID
            aws_secret_access_key: AWS secret access key
            aws_region: AWS region for SES
        """
        self.aws_access_key_id = aws_access_key_id
        self.aws_secret_access_key = aws_secret_access_key
        self.aws_region = aws_region
        self._client = None

    def _get_client(self):
        """Get or create AWS SES client."""
        if not self._client:
            try:
                import boto3

                self._client = boto3.client(
                    "ses",
                    region_name=self.aws_region,
                    aws_access_key_id=self.aws_access_key_id,
                    aws_secret_access_key=self.aws_secret_access_key,
                )
            except ImportError:
                raise ImportError("Boto3 library not installed. Run: pip install boto3")
        return self._client

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        from_email: Optional[str] = None,
        from_name: Optional[str] = None,
        reply_to: Optional[str] = None,
        cc: Optional[List[str]] = None,
        bcc: Optional[List[str]] = None,
        attachments: Optional[List[Dict[str, Any]]] = None,
        headers: Optional[Dict[str, str]] = None,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> EmailResult:
        """Send email via AWS SES."""
        try:
            client = self._get_client()

            # Build source address
            if from_email:
                if from_name:
                    source = f"{from_name} <{from_email}>"
                else:
                    source = from_email
            else:
                source = "noreply@example.com"

            # Build destination
            destination = {"ToAddresses": [to_email]}
            if cc:
                destination["CcAddresses"] = cc
            if bcc:
                destination["BccAddresses"] = bcc

            # Build message
            message = {
                "Subject": {"Data": subject, "Charset": "UTF-8"},
                "Body": {},
            }

            if text_content:
                message["Body"]["Text"] = {"Data": text_content, "Charset": "UTF-8"}  # type: ignore

            message["Body"]["Html"] = {"Data": html_content, "Charset": "UTF-8"}  # type: ignore

            # Prepare request parameters
            params: Dict[str, Any] = {
                "Source": source,
                "Destination": destination,
                "Message": message,
            }

            # Add reply-to
            if reply_to:
                params["ReplyToAddresses"] = [reply_to]

            # Add tags
            if tags or metadata:
                tag_list: List[Dict[str, str]] = []
                if tags:
                    for tag in tags:
                        tag_list.append({"Name": "tag", "Value": tag})
                if metadata:
                    for key, value in metadata.items():
                        tag_list.append({"Name": key, "Value": str(value)})
                params["Tags"] = tag_list

            # Send email
            response = client.send_email(**params)

            logger.info(
                "Email sent via AWS SES",
                to_email=to_email,
                subject=subject,
                message_id=response.get("MessageId"),
                provider="aws_ses",
            )

            return EmailResult(
                success=True,
                provider="aws_ses",
                message_id=response.get("MessageId"),
                metadata={"to": to_email, "subject": subject},
            )

        except Exception as e:
            logger.error(
                "Failed to send email via AWS SES",
                to_email=to_email,
                subject=subject,
                error=str(e),
                provider="aws_ses",
            )
            return EmailResult(
                success=False,
                provider="aws_ses",
                error=str(e),
                metadata={"to": to_email, "subject": subject},
            )

    async def verify_configuration(self) -> bool:
        """Verify AWS SES configuration."""
        try:
            client = self._get_client()
            # Test credentials by getting send quota
            response = client.get_send_quota()
            return "Max24HourSend" in response
        except Exception as e:
            logger.error("AWS SES configuration verification failed", error=str(e))
            return False

    def is_configured(self) -> bool:
        """Check if AWS SES is configured."""
        return bool(self.aws_access_key_id and self.aws_secret_access_key)


class ConsoleEmailProvider(EmailProvider):
    """Console email provider for development/testing."""

    async def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        from_email: Optional[str] = None,
        from_name: Optional[str] = None,
        reply_to: Optional[str] = None,
        cc: Optional[List[str]] = None,
        bcc: Optional[List[str]] = None,
        attachments: Optional[List[Dict[str, Any]]] = None,
        headers: Optional[Dict[str, str]] = None,
        tags: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> EmailResult:
        """Print email to console instead of sending."""
        message_id = str(uuid.uuid4())

        print("\n" + "=" * 80)
        print("📧 EMAIL SENT (Console Provider - Development Mode)")
        print("=" * 80)
        print(f"Message ID: {message_id}")
        print(f"Timestamp: {datetime.now().isoformat()}")
        print(f"From: {from_name or 'System'} <{from_email or 'noreply@example.com'}>")
        print(f"To: {to_email}")
        if cc:
            print(f"CC: {', '.join(cc)}")
        if bcc:
            print(f"BCC: {', '.join(bcc)}")
        if reply_to:
            print(f"Reply-To: {reply_to}")
        print(f"Subject: {subject}")
        if tags:
            print(f"Tags: {', '.join(tags)}")
        if metadata:
            print(f"Metadata: {json.dumps(metadata, indent=2)}")
        print("-" * 80)

        if text_content:
            print("TEXT CONTENT:")
            print(text_content[:500] + ("..." if len(text_content) > 500 else ""))
            print("-" * 80)

        print("HTML CONTENT (Preview):")
        # Strip HTML tags for console preview
        import re

        text_preview = re.sub("<[^<]+?>", "", html_content)
        print(text_preview[:500] + ("..." if len(text_preview) > 500 else ""))
        print("=" * 80 + "\n")

        logger.info(
            "Email printed to console",
            provider="console",
            to_email=to_email,
            subject=subject,
            message_id=message_id,
        )

        return EmailResult(
            success=True,
            provider="console",
            message_id=message_id,
            metadata={"to": to_email, "subject": subject},
        )

    async def verify_configuration(self) -> bool:
        """Console provider is always configured."""
        return True

    def is_configured(self) -> bool:
        """Console provider is always configured."""
        return True


class EmailProviderFactory:
    """Factory for creating email providers based on configuration."""

    @staticmethod
    def create_provider(provider_type: str, config: Dict[str, Any]) -> EmailProvider:
        """
        Create an email provider instance.

        Args:
            provider_type: Type of provider (smtp, sendgrid, aws_ses, console)
            config: Provider configuration

        Returns:
            EmailProvider instance

        Raises:
            ValueError: If provider type is not supported
        """
        provider_type = provider_type.lower()

        if provider_type == "smtp":
            return SMTPProvider(
                host=config.get("host", ""),
                port=config.get("port", 587),
                username=config.get("username", ""),
                password=config.get("password", ""),
                use_tls=config.get("use_tls", True),
                use_ssl=config.get("use_ssl", False),
                timeout=config.get("timeout", 30),
            )

        elif provider_type == "sendgrid":
            api_key = config.get("api_key", "")
            if not api_key:
                raise ValueError("SendGrid API key is required")
            return SendGridProvider(api_key)

        elif provider_type == "aws_ses":
            return AWSEmailProvider(
                aws_access_key_id=config.get("access_key_id", ""),
                aws_secret_access_key=config.get("secret_access_key", ""),
                aws_region=config.get("region", "us-east-1"),
            )

        elif provider_type == "console":
            return ConsoleEmailProvider()

        else:
            raise ValueError(f"Unsupported email provider type: {provider_type}")


def get_email_provider(
    provider_type: str,
    smtp_host: Optional[str] = None,
    smtp_port: Optional[int] = None,
    smtp_username: Optional[str] = None,
    smtp_password: Optional[str] = None,
    smtp_use_tls: bool = True,
    smtp_use_ssl: bool = False,
    sendgrid_api_key: Optional[str] = None,
    aws_access_key_id: Optional[str] = None,
    aws_secret_access_key: Optional[str] = None,
    aws_region: str = "us-east-1",
) -> EmailProvider:
    """
    Factory function to get the appropriate email provider.

    Args:
        provider_type: Type of provider (smtp, sendgrid, aws_ses, console)
        **kwargs: Provider-specific configuration

    Returns:
        EmailProvider: Configured email provider instance

    Raises:
        ValueError: If provider type is unknown or configuration is invalid
    """
    provider_type = provider_type.lower()

    if provider_type == "smtp":
        if not all([smtp_host, smtp_port, smtp_username, smtp_password]):
            raise ValueError(
                "SMTP provider requires host, port, username, and password"
            )
        # Type narrowing: after the check above, these are guaranteed to be non-None
        assert smtp_host is not None and smtp_port is not None
        assert smtp_username is not None and smtp_password is not None
        return SMTPProvider(
            host=smtp_host,
            port=smtp_port,
            username=smtp_username,
            password=smtp_password,
            use_tls=smtp_use_tls,
            use_ssl=smtp_use_ssl,
        )

    elif provider_type == "sendgrid":
        if not sendgrid_api_key:
            raise ValueError("SendGrid provider requires API key")
        return SendGridProvider(api_key=sendgrid_api_key)

    elif provider_type == "aws_ses":
        if not all([aws_access_key_id, aws_secret_access_key]):
            raise ValueError("AWS SES provider requires access key ID and secret")
        # Type narrowing: after the check above, these are guaranteed to be non-None
        assert aws_access_key_id is not None and aws_secret_access_key is not None
        return AWSEmailProvider(
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            aws_region=aws_region,
        )

    elif provider_type == "console":
        return ConsoleEmailProvider()

    else:
        raise ValueError(f"Unknown email provider type: {provider_type}")
