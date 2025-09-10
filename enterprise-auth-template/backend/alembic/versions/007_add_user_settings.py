"""Add user settings and preferences tables

Revision ID: 007_add_user_settings
Revises: 006_add_audit_enhancements
Create Date: 2025-01-05 16:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid
from datetime import datetime

# revision identifiers, used by Alembic.
revision = '007_add_user_settings'
down_revision = '006_add_audit_enhancements'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add user settings, preferences, and customization tables."""
    
    # Create user settings table for application preferences
    op.create_table(
        'user_settings',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, unique=True),
        
        # UI/UX Preferences
        sa.Column('theme', sa.String(20), nullable=False, default='system'),  # light, dark, system
        sa.Column('language', sa.String(10), nullable=False, default='en-US'),
        sa.Column('timezone', sa.String(50), nullable=False, default='UTC'),
        sa.Column('date_format', sa.String(20), nullable=False, default='YYYY-MM-DD'),
        sa.Column('time_format', sa.String(10), nullable=False, default='24h'),  # 12h, 24h
        sa.Column('number_format', sa.String(20), nullable=False, default='1,234.56'),
        sa.Column('currency', sa.String(10), nullable=False, default='USD'),
        
        # Dashboard and Layout Preferences
        sa.Column('sidebar_collapsed', sa.Boolean(), nullable=False, default=False),
        sa.Column('dashboard_layout', postgresql.JSONB(), nullable=True, default=dict),  # Widget positions and sizes
        sa.Column('table_page_size', sa.Integer(), nullable=False, default=25),
        sa.Column('default_landing_page', sa.String(100), nullable=True),
        
        # Notification Preferences
        sa.Column('email_notifications', sa.Boolean(), nullable=False, default=True),
        sa.Column('push_notifications', sa.Boolean(), nullable=False, default=True),
        sa.Column('sms_notifications', sa.Boolean(), nullable=False, default=False),
        sa.Column('marketing_emails', sa.Boolean(), nullable=False, default=False),
        sa.Column('security_alerts', sa.Boolean(), nullable=False, default=True),
        sa.Column('notification_frequency', sa.Enum('immediate', 'hourly', 'daily', 'weekly', name='notification_frequency'), nullable=False, default='immediate'),
        sa.Column('quiet_hours_start', sa.Time(), nullable=True),
        sa.Column('quiet_hours_end', sa.Time(), nullable=True),
        sa.Column('quiet_hours_timezone', sa.String(50), nullable=True),
        
        # Privacy and Security Preferences
        sa.Column('profile_visibility', sa.Enum('public', 'organization', 'private', name='profile_visibility'), nullable=False, default='organization'),
        sa.Column('activity_logging', sa.Boolean(), nullable=False, default=True),
        sa.Column('data_sharing', sa.Boolean(), nullable=False, default=False),
        sa.Column('analytics_tracking', sa.Boolean(), nullable=False, default=True),
        sa.Column('session_timeout_minutes', sa.Integer(), nullable=False, default=480),  # 8 hours default
        sa.Column('require_password_change', sa.Boolean(), nullable=False, default=False),
        sa.Column('password_change_interval_days', sa.Integer(), nullable=True),
        
        # API and Integration Preferences
        sa.Column('api_rate_limit_override', sa.Integer(), nullable=True),
        sa.Column('webhook_preferences', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('integration_settings', postgresql.JSONB(), nullable=True, default=dict),
        
        # Accessibility Settings
        sa.Column('high_contrast', sa.Boolean(), nullable=False, default=False),
        sa.Column('large_text', sa.Boolean(), nullable=False, default=False),
        sa.Column('reduce_motion', sa.Boolean(), nullable=False, default=False),
        sa.Column('screen_reader_optimized', sa.Boolean(), nullable=False, default=False),
        sa.Column('keyboard_navigation', sa.Boolean(), nullable=False, default=False),
        
        # Custom Settings (flexible JSON for feature-specific settings)
        sa.Column('custom_settings', postgresql.JSONB(), nullable=True, default=dict),
        
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create user preferences table for granular notification preferences
    op.create_table(
        'user_notification_preferences',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('notification_type', sa.String(100), nullable=False, index=True),  # matches notification categories
        sa.Column('channel', sa.Enum('email', 'sms', 'push', 'in_app', name='notification_channel'), nullable=False),
        sa.Column('enabled', sa.Boolean(), nullable=False, default=True),
        sa.Column('frequency', sa.Enum('immediate', 'hourly', 'daily', 'weekly', 'never', name='preference_frequency'), nullable=False, default='immediate'),
        sa.Column('conditions', postgresql.JSONB(), nullable=True, default=dict),  # Conditional preferences (e.g., only high priority)
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.UniqueConstraint('user_id', 'notification_type', 'channel', name='uix_user_notification_preference')
    )
    
    # Create user sessions extended table for session management preferences
    op.create_table(
        'user_session_preferences',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('device_name', sa.String(200), nullable=True),
        sa.Column('device_type', sa.Enum('desktop', 'mobile', 'tablet', 'other', name='device_type'), nullable=True),
        sa.Column('browser', sa.String(100), nullable=True),
        sa.Column('os', sa.String(100), nullable=True),
        sa.Column('trusted_device', sa.Boolean(), nullable=False, default=False),
        sa.Column('auto_logout_enabled', sa.Boolean(), nullable=False, default=True),
        sa.Column('remember_me_enabled', sa.Boolean(), nullable=False, default=False),
        sa.Column('two_factor_trusted', sa.Boolean(), nullable=False, default=False),
        sa.Column('trusted_until', sa.DateTime(timezone=True), nullable=True),
        sa.Column('location_country', sa.String(5), nullable=True),
        sa.Column('location_city', sa.String(100), nullable=True),
        sa.Column('ip_whitelist', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('last_location_update', sa.DateTime(timezone=True), nullable=True),
        sa.Column('security_warnings_enabled', sa.Boolean(), nullable=False, default=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create user custom fields table for flexible user data
    op.create_table(
        'user_custom_fields',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=True),
        sa.Column('field_name', sa.String(100), nullable=False, index=True),
        sa.Column('field_type', sa.Enum('text', 'number', 'boolean', 'date', 'datetime', 'json', 'file_url', name='custom_field_type'), nullable=False),
        sa.Column('field_value', sa.Text(), nullable=True),
        sa.Column('json_value', postgresql.JSONB(), nullable=True),  # For complex data types
        sa.Column('is_searchable', sa.Boolean(), nullable=False, default=False),
        sa.Column('is_public', sa.Boolean(), nullable=False, default=False),
        sa.Column('is_required', sa.Boolean(), nullable=False, default=False),
        sa.Column('validation_rules', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('display_order', sa.Integer(), nullable=False, default=0),
        sa.Column('category', sa.String(50), nullable=True),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.UniqueConstraint('user_id', 'field_name', name='uix_user_custom_field')
    )
    
    # Create organization settings template table
    op.create_table(
        'organization_settings_templates',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=False),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('settings_template', postgresql.JSONB(), nullable=False, default=dict),  # Default settings for new users
        sa.Column('is_default', sa.Boolean(), nullable=False, default=False),
        sa.Column('applies_to_roles', postgresql.JSONB(), nullable=True, default=list),  # Which roles get this template
        sa.Column('required_fields', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('allowed_overrides', postgresql.JSONB(), nullable=True, default=list),  # Which settings users can override
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=False),
        sa.Column('updated_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create indexes for performance
    op.create_index('idx_user_settings_user_id', 'user_settings', ['user_id'])
    op.create_index('idx_user_settings_theme_language', 'user_settings', ['theme', 'language'])
    
    op.create_index('idx_user_notification_prefs_user', 'user_notification_preferences', ['user_id', 'enabled'])
    op.create_index('idx_user_notification_prefs_type', 'user_notification_preferences', ['notification_type', 'channel', 'enabled'])
    
    op.create_index('idx_user_session_prefs_user', 'user_session_preferences', ['user_id'])
    op.create_index('idx_user_session_prefs_trusted', 'user_session_preferences', ['user_id', 'trusted_device'])
    op.create_index('idx_user_session_prefs_trusted_until', 'user_session_preferences', ['trusted_until'])
    
    op.create_index('idx_user_custom_fields_user', 'user_custom_fields', ['user_id', 'field_name'])
    op.create_index('idx_user_custom_fields_org', 'user_custom_fields', ['organization_id', 'field_name'])
    op.create_index('idx_user_custom_fields_searchable', 'user_custom_fields', ['field_name', 'is_searchable'])
    op.create_index('idx_user_custom_fields_public', 'user_custom_fields', ['is_public', 'field_name'])
    
    op.create_index('idx_org_settings_templates_org', 'organization_settings_templates', ['organization_id', 'is_active'])
    op.create_index('idx_org_settings_templates_default', 'organization_settings_templates', ['organization_id', 'is_default'])


def downgrade() -> None:
    """Remove user settings and preferences tables."""
    
    # Drop indexes
    op.drop_index('idx_org_settings_templates_default', table_name='organization_settings_templates')
    op.drop_index('idx_org_settings_templates_org', table_name='organization_settings_templates')
    op.drop_index('idx_user_custom_fields_public', table_name='user_custom_fields')
    op.drop_index('idx_user_custom_fields_searchable', table_name='user_custom_fields')
    op.drop_index('idx_user_custom_fields_org', table_name='user_custom_fields')
    op.drop_index('idx_user_custom_fields_user', table_name='user_custom_fields')
    op.drop_index('idx_user_session_prefs_trusted_until', table_name='user_session_preferences')
    op.drop_index('idx_user_session_prefs_trusted', table_name='user_session_preferences')
    op.drop_index('idx_user_session_prefs_user', table_name='user_session_preferences')
    op.drop_index('idx_user_notification_prefs_type', table_name='user_notification_preferences')
    op.drop_index('idx_user_notification_prefs_user', table_name='user_notification_preferences')
    op.drop_index('idx_user_settings_theme_language', table_name='user_settings')
    op.drop_index('idx_user_settings_user_id', table_name='user_settings')
    
    # Drop tables in reverse order
    op.drop_table('organization_settings_templates')
    op.drop_table('user_custom_fields')
    op.drop_table('user_session_preferences')
    op.drop_table('user_notification_preferences')
    op.drop_table('user_settings')
    
    # Drop enum types
    op.execute('DROP TYPE IF EXISTS notification_frequency')
    op.execute('DROP TYPE IF EXISTS profile_visibility')
    op.execute('DROP TYPE IF EXISTS notification_channel')
    op.execute('DROP TYPE IF EXISTS preference_frequency')
    op.execute('DROP TYPE IF EXISTS device_type')
    op.execute('DROP TYPE IF EXISTS custom_field_type')