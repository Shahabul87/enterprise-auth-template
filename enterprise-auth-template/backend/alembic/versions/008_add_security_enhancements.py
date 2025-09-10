"""Add security enhancements and backup code management

Revision ID: 008_add_security_enhancements
Revises: 007_add_user_settings
Create Date: 2025-01-05 18:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid
from datetime import datetime

# revision identifiers, used by Alembic.
revision = '008_add_security_enhancements'
down_revision = '007_add_user_settings'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add enhanced security features, backup codes, and device management."""
    
    # Create backup codes table for enhanced 2FA recovery
    op.create_table(
        'backup_codes',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('code_hash', sa.String(255), nullable=False, unique=True, index=True),
        sa.Column('code_prefix', sa.String(10), nullable=False, index=True),  # First few chars for identification
        sa.Column('is_used', sa.Boolean(), nullable=False, default=False, index=True),
        sa.Column('used_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('used_ip', sa.String(45), nullable=True),
        sa.Column('used_user_agent', sa.Text(), nullable=True),
        sa.Column('generation_batch_id', postgresql.UUID(as_uuid=True), nullable=False, index=True),  # Group codes generated together
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('invalidated_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('invalidated_reason', sa.String(100), nullable=True)
    )
    
    # Create trusted devices table for device-based authentication
    op.create_table(
        'trusted_devices',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('device_fingerprint', sa.String(255), nullable=False, unique=True, index=True),
        sa.Column('device_name', sa.String(200), nullable=False),
        sa.Column('device_type', sa.Enum('desktop', 'mobile', 'tablet', 'other', name='trusted_device_type'), nullable=False),
        sa.Column('browser_name', sa.String(100), nullable=True),
        sa.Column('browser_version', sa.String(50), nullable=True),
        sa.Column('os_name', sa.String(100), nullable=True),
        sa.Column('os_version', sa.String(50), nullable=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('ip_address', sa.String(45), nullable=True),
        sa.Column('location_country', sa.String(5), nullable=True),
        sa.Column('location_city', sa.String(100), nullable=True),
        sa.Column('is_trusted', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('trust_expires_at', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('last_seen_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('last_seen_ip', sa.String(45), nullable=True),
        sa.Column('access_count', sa.Integer(), nullable=False, default=1),
        sa.Column('revoked_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('revoked_reason', sa.String(200), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create security events table for tracking security-related events
    op.create_table(
        'security_events',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True, index=True),
        sa.Column('event_type', sa.Enum(
            'login_success', 'login_failed', 'password_change', 'password_reset_request', 'password_reset_complete',
            '2fa_enabled', '2fa_disabled', '2fa_failed', 'backup_code_used', 'account_locked', 'account_unlocked',
            'suspicious_activity', 'device_trust_granted', 'device_trust_revoked', 'api_key_created', 'api_key_revoked',
            'permission_granted', 'permission_revoked', 'session_terminated', 'data_export_requested',
            'security_scan_started', 'security_scan_completed', 'vulnerability_detected', 'brute_force_detected',
            name='security_event_type'
        ), nullable=False, index=True),
        sa.Column('severity', sa.Enum('info', 'low', 'medium', 'high', 'critical', name='security_event_severity'), nullable=False, default='info', index=True),
        sa.Column('source', sa.String(100), nullable=False, index=True),  # web, api, mobile_app, system, etc.
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('details', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('ip_address', sa.String(45), nullable=True, index=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('location_country', sa.String(5), nullable=True),
        sa.Column('location_city', sa.String(100), nullable=True),
        sa.Column('device_fingerprint', sa.String(255), nullable=True),
        sa.Column('session_id', sa.String(255), nullable=True, index=True),
        sa.Column('request_id', sa.String(255), nullable=True, index=True),
        sa.Column('resolved_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('resolved_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('resolution_notes', sa.Text(), nullable=True),
        sa.Column('auto_resolved', sa.Boolean(), nullable=False, default=False),
        sa.Column('suppressed', sa.Boolean(), nullable=False, default=False, index=True),
        sa.Column('suppressed_until', sa.DateTime(timezone=True), nullable=True),
        sa.Column('alert_sent', sa.Boolean(), nullable=False, default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow, index=True)
    )
    
    # Create security policies table for organization-wide security settings
    op.create_table(
        'security_policies',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=True),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('policy_type', sa.Enum('password', '2fa', 'session', 'device', 'api', 'audit', 'general', name='security_policy_type'), nullable=False, index=True),
        sa.Column('is_system_policy', sa.Boolean(), nullable=False, default=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        
        # Password policies
        sa.Column('password_min_length', sa.Integer(), nullable=True, default=8),
        sa.Column('password_require_uppercase', sa.Boolean(), nullable=True, default=True),
        sa.Column('password_require_lowercase', sa.Boolean(), nullable=True, default=True),
        sa.Column('password_require_numbers', sa.Boolean(), nullable=True, default=True),
        sa.Column('password_require_symbols', sa.Boolean(), nullable=True, default=True),
        sa.Column('password_max_age_days', sa.Integer(), nullable=True),
        sa.Column('password_history_count', sa.Integer(), nullable=True, default=5),
        sa.Column('password_lockout_attempts', sa.Integer(), nullable=True, default=5),
        sa.Column('password_lockout_duration_minutes', sa.Integer(), nullable=True, default=30),
        
        # 2FA policies
        sa.Column('require_2fa', sa.Boolean(), nullable=True, default=False),
        sa.Column('require_2fa_for_roles', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('backup_codes_required', sa.Boolean(), nullable=True, default=True),
        sa.Column('backup_codes_count', sa.Integer(), nullable=True, default=10),
        sa.Column('backup_codes_expiry_days', sa.Integer(), nullable=True),
        sa.Column('allow_remember_device', sa.Boolean(), nullable=True, default=True),
        sa.Column('device_trust_duration_days', sa.Integer(), nullable=True, default=30),
        
        # Session policies
        sa.Column('session_timeout_minutes', sa.Integer(), nullable=True, default=480),
        sa.Column('concurrent_session_limit', sa.Integer(), nullable=True),
        sa.Column('force_logout_on_password_change', sa.Boolean(), nullable=True, default=True),
        sa.Column('require_fresh_login_for_sensitive_actions', sa.Boolean(), nullable=True, default=True),
        
        # IP and location policies
        sa.Column('allowed_ip_ranges', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('blocked_ip_ranges', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('allowed_countries', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('blocked_countries', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('alert_on_new_location', sa.Boolean(), nullable=True, default=True),
        sa.Column('alert_on_suspicious_activity', sa.Boolean(), nullable=True, default=True),
        
        # API policies
        sa.Column('api_rate_limit_per_minute', sa.Integer(), nullable=True, default=1000),
        sa.Column('api_key_expiry_days', sa.Integer(), nullable=True),
        sa.Column('require_api_key_rotation', sa.Boolean(), nullable=True, default=False),
        
        sa.Column('custom_settings', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('priority', sa.Integer(), nullable=False, default=0),  # Higher priority policies override lower ones
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=False),
        sa.Column('updated_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create rate limiting table for brute force protection
    op.create_table(
        'rate_limits',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('identifier', sa.String(255), nullable=False, index=True),  # IP, user_id, api_key, etc.
        sa.Column('identifier_type', sa.Enum('ip', 'user', 'api_key', 'session', 'device', name='rate_limit_type'), nullable=False, index=True),
        sa.Column('endpoint', sa.String(200), nullable=False, index=True),
        sa.Column('method', sa.String(10), nullable=False, default='ANY'),
        sa.Column('attempts', sa.Integer(), nullable=False, default=0),
        sa.Column('max_attempts', sa.Integer(), nullable=False),
        sa.Column('window_start', sa.DateTime(timezone=True), nullable=False, index=True),
        sa.Column('window_duration_seconds', sa.Integer(), nullable=False),
        sa.Column('blocked_until', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('last_attempt_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.UniqueConstraint('identifier', 'endpoint', 'method', name='uix_rate_limit_key')
    )
    
    # Create security scans table for automated security assessments
    op.create_table(
        'security_scans',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=True),
        sa.Column('scan_type', sa.Enum('vulnerability', 'compliance', 'penetration', 'code_analysis', 'dependency_check', name='security_scan_type'), nullable=False, index=True),
        sa.Column('target', sa.String(200), nullable=False),  # What was scanned (system, app, dependency, etc.)
        sa.Column('status', sa.Enum('pending', 'running', 'completed', 'failed', 'cancelled', name='security_scan_status'), nullable=False, default='pending', index=True),
        sa.Column('progress_percentage', sa.Integer(), nullable=False, default=0),
        sa.Column('started_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('scan_config', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('results', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('vulnerabilities_found', sa.Integer(), nullable=False, default=0),
        sa.Column('critical_issues', sa.Integer(), nullable=False, default=0),
        sa.Column('high_issues', sa.Integer(), nullable=False, default=0),
        sa.Column('medium_issues', sa.Integer(), nullable=False, default=0),
        sa.Column('low_issues', sa.Integer(), nullable=False, default=0),
        sa.Column('info_issues', sa.Integer(), nullable=False, default=0),
        sa.Column('report_file_path', sa.String(500), nullable=True),
        sa.Column('report_format', sa.String(20), nullable=True),
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('scheduled_for', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('started_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('duration_seconds', sa.Integer(), nullable=True),
        sa.Column('next_scan_at', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create indexes for optimal performance
    op.create_index('idx_backup_codes_user_active', 'backup_codes', ['user_id', 'is_used'])
    op.create_index('idx_backup_codes_batch_id', 'backup_codes', ['generation_batch_id'])
    op.create_index('idx_backup_codes_expires_at', 'backup_codes', ['expires_at'])
    
    op.create_index('idx_trusted_devices_user_trusted', 'trusted_devices', ['user_id', 'is_trusted'])
    op.create_index('idx_trusted_devices_expires_at', 'trusted_devices', ['trust_expires_at'])
    op.create_index('idx_trusted_devices_last_seen', 'trusted_devices', ['last_seen_at'])
    
    op.create_index('idx_security_events_user_created', 'security_events', ['user_id', 'created_at'])
    op.create_index('idx_security_events_type_severity', 'security_events', ['event_type', 'severity', 'created_at'])
    op.create_index('idx_security_events_ip_created', 'security_events', ['ip_address', 'created_at'])
    op.create_index('idx_security_events_unresolved', 'security_events', ['resolved_at', 'severity'])
    op.create_index('idx_security_events_suppressed', 'security_events', ['suppressed', 'suppressed_until'])
    
    op.create_index('idx_security_policies_org_active', 'security_policies', ['organization_id', 'is_active'])
    op.create_index('idx_security_policies_type_priority', 'security_policies', ['policy_type', 'priority'])
    
    op.create_index('idx_rate_limits_identifier_type', 'rate_limits', ['identifier', 'identifier_type'])
    op.create_index('idx_rate_limits_blocked_until', 'rate_limits', ['blocked_until'])
    op.create_index('idx_rate_limits_window_start', 'rate_limits', ['window_start'])
    op.create_index('idx_rate_limits_endpoint', 'rate_limits', ['endpoint', 'method'])
    
    op.create_index('idx_security_scans_org_status', 'security_scans', ['organization_id', 'status'])
    op.create_index('idx_security_scans_scheduled_for', 'security_scans', ['scheduled_for'])
    op.create_index('idx_security_scans_next_scan', 'security_scans', ['next_scan_at'])
    op.create_index('idx_security_scans_type_status', 'security_scans', ['scan_type', 'status'])


def downgrade() -> None:
    """Remove security enhancements and backup code management."""
    
    # Drop indexes
    op.drop_index('idx_security_scans_type_status', table_name='security_scans')
    op.drop_index('idx_security_scans_next_scan', table_name='security_scans')
    op.drop_index('idx_security_scans_scheduled_for', table_name='security_scans')
    op.drop_index('idx_security_scans_org_status', table_name='security_scans')
    op.drop_index('idx_rate_limits_endpoint', table_name='rate_limits')
    op.drop_index('idx_rate_limits_window_start', table_name='rate_limits')
    op.drop_index('idx_rate_limits_blocked_until', table_name='rate_limits')
    op.drop_index('idx_rate_limits_identifier_type', table_name='rate_limits')
    op.drop_index('idx_security_policies_type_priority', table_name='security_policies')
    op.drop_index('idx_security_policies_org_active', table_name='security_policies')
    op.drop_index('idx_security_events_suppressed', table_name='security_events')
    op.drop_index('idx_security_events_unresolved', table_name='security_events')
    op.drop_index('idx_security_events_ip_created', table_name='security_events')
    op.drop_index('idx_security_events_type_severity', table_name='security_events')
    op.drop_index('idx_security_events_user_created', table_name='security_events')
    op.drop_index('idx_trusted_devices_last_seen', table_name='trusted_devices')
    op.drop_index('idx_trusted_devices_expires_at', table_name='trusted_devices')
    op.drop_index('idx_trusted_devices_user_trusted', table_name='trusted_devices')
    op.drop_index('idx_backup_codes_expires_at', table_name='backup_codes')
    op.drop_index('idx_backup_codes_batch_id', table_name='backup_codes')
    op.drop_index('idx_backup_codes_user_active', table_name='backup_codes')
    
    # Drop tables in reverse order
    op.drop_table('security_scans')
    op.drop_table('rate_limits')
    op.drop_table('security_policies')
    op.drop_table('security_events')
    op.drop_table('trusted_devices')
    op.drop_table('backup_codes')
    
    # Drop enum types
    op.execute('DROP TYPE IF EXISTS trusted_device_type')
    op.execute('DROP TYPE IF EXISTS security_event_type')
    op.execute('DROP TYPE IF EXISTS security_event_severity')
    op.execute('DROP TYPE IF EXISTS security_policy_type')
    op.execute('DROP TYPE IF EXISTS rate_limit_type')
    op.execute('DROP TYPE IF EXISTS security_scan_type')
    op.execute('DROP TYPE IF EXISTS security_scan_status')