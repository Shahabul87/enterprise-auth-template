"""Add audit enhancements and compliance features

Revision ID: 006_add_audit_enhancements
Revises: 005_add_webhooks
Create Date: 2025-01-05 14:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid
from datetime import datetime

# revision identifiers, used by Alembic.
revision = '006_add_audit_enhancements'
down_revision = '005_add_webhooks'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add enhanced audit logging and compliance tracking features."""
    
    # Create audit trails table for detailed action tracking
    op.create_table(
        'audit_trails',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('session_id', sa.String(255), nullable=True, index=True),  # Track user session
        sa.Column('request_id', sa.String(255), nullable=True, index=True),  # Track specific request
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True, index=True),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='SET NULL'), nullable=True),
        sa.Column('impersonated_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),  # Admin impersonation tracking
        
        # Event details
        sa.Column('event_type', sa.String(100), nullable=False, index=True),
        sa.Column('event_category', sa.Enum('authentication', 'authorization', 'data_access', 'data_modification', 'configuration', 'security', 'compliance', name='audit_event_category'), nullable=False, index=True),
        sa.Column('severity', sa.Enum('low', 'medium', 'high', 'critical', name='audit_severity'), nullable=False, default='medium', index=True),
        sa.Column('action', sa.String(100), nullable=False, index=True),
        sa.Column('resource_type', sa.String(100), nullable=True, index=True),
        sa.Column('resource_id', sa.String(255), nullable=True, index=True),
        sa.Column('resource_name', sa.String(255), nullable=True),
        
        # Context and metadata
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('old_values', postgresql.JSONB(), nullable=True),  # Before state
        sa.Column('new_values', postgresql.JSONB(), nullable=True),  # After state
        sa.Column('metadata', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('tags', postgresql.JSONB(), nullable=True, default=list),  # For categorization and filtering
        
        # Request context
        sa.Column('ip_address', sa.String(45), nullable=True, index=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('referer', sa.String(500), nullable=True),
        sa.Column('method', sa.String(10), nullable=True),
        sa.Column('endpoint', sa.String(500), nullable=True, index=True),
        sa.Column('status_code', sa.Integer(), nullable=True),
        sa.Column('response_time_ms', sa.Integer(), nullable=True),
        
        # Compliance and retention
        sa.Column('retention_policy', sa.String(50), nullable=False, default='standard'),  # standard, extended, permanent
        sa.Column('compliance_tags', postgresql.JSONB(), nullable=True, default=list),  # GDPR, SOX, HIPAA, etc.
        sa.Column('is_sensitive', sa.Boolean(), nullable=False, default=False, index=True),
        sa.Column('is_exportable', sa.Boolean(), nullable=False, default=True),
        sa.Column('archived_at', sa.DateTime(timezone=True), nullable=True),
        
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow, index=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create data access logs for GDPR and compliance tracking
    op.create_table(
        'data_access_logs',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True),
        sa.Column('accessed_user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True, index=True),  # Whose data was accessed
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='SET NULL'), nullable=True),
        sa.Column('data_type', sa.String(100), nullable=False, index=True),  # profile, billing, activity, etc.
        sa.Column('data_categories', postgresql.JSONB(), nullable=False, default=list),  # PII, financial, health, etc.
        sa.Column('access_type', sa.Enum('view', 'download', 'export', 'modify', 'delete', name='data_access_type'), nullable=False, index=True),
        sa.Column('access_reason', sa.String(200), nullable=True),
        sa.Column('legal_basis', sa.String(100), nullable=True),  # GDPR legal basis
        sa.Column('data_fields', postgresql.JSONB(), nullable=True, default=list),  # Specific fields accessed
        sa.Column('record_count', sa.Integer(), nullable=False, default=1),
        sa.Column('query_parameters', postgresql.JSONB(), nullable=True),
        sa.Column('ip_address', sa.String(45), nullable=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('session_id', sa.String(255), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow, index=True)
    )
    
    # Create compliance reports table
    op.create_table(
        'compliance_reports',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('report_type', sa.Enum('access_log', 'audit_summary', 'data_export', 'security_incidents', 'user_activity', 'custom', name='compliance_report_type'), nullable=False, index=True),
        sa.Column('compliance_framework', sa.String(50), nullable=True, index=True),  # GDPR, SOX, HIPAA, etc.
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=True),
        sa.Column('requested_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=False),
        sa.Column('approved_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('status', sa.Enum('pending', 'generating', 'completed', 'failed', 'expired', name='compliance_report_status'), nullable=False, default='pending', index=True),
        sa.Column('filters', postgresql.JSONB(), nullable=True, default=dict),  # Query filters used
        sa.Column('date_range_start', sa.DateTime(timezone=True), nullable=False, index=True),
        sa.Column('date_range_end', sa.DateTime(timezone=True), nullable=False, index=True),
        sa.Column('format', sa.String(20), nullable=False, default='json'),  # json, csv, pdf, etc.
        sa.Column('file_path', sa.String(500), nullable=True),
        sa.Column('file_size_bytes', sa.Integer(), nullable=True),
        sa.Column('record_count', sa.Integer(), nullable=True),
        sa.Column('checksum', sa.String(255), nullable=True),  # File integrity verification
        sa.Column('encryption_key_id', sa.String(100), nullable=True),  # For encrypted reports
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('downloaded_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('download_count', sa.Integer(), nullable=False, default=0),
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True)
    )
    
    # Create audit configurations table
    op.create_table(
        'audit_configurations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), nullable=False, unique=True, index=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=True),
        sa.Column('is_global', sa.Boolean(), nullable=False, default=False),  # System-wide config
        sa.Column('event_types', postgresql.JSONB(), nullable=False, default=list),  # Which events to log
        sa.Column('severity_threshold', sa.String(20), nullable=False, default='low'),  # Minimum severity to log
        sa.Column('data_retention_days', sa.Integer(), nullable=False, default=365),
        sa.Column('sensitive_data_retention_days', sa.Integer(), nullable=False, default=90),
        sa.Column('auto_archive_enabled', sa.Boolean(), nullable=False, default=True),
        sa.Column('real_time_alerts', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('compliance_settings', postgresql.JSONB(), nullable=True, default=dict),
        sa.Column('anonymization_rules', postgresql.JSONB(), nullable=True, default=list),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=False),
        sa.Column('updated_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Add additional columns to existing audit_logs table for backward compatibility
    op.add_column('audit_logs', sa.Column('session_id', sa.String(255), nullable=True))
    op.add_column('audit_logs', sa.Column('request_id', sa.String(255), nullable=True))
    op.add_column('audit_logs', sa.Column('organization_id', postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column('audit_logs', sa.Column('severity', sa.String(20), nullable=True))
    op.add_column('audit_logs', sa.Column('compliance_tags', postgresql.JSONB(), nullable=True))
    
    # Add foreign key constraints for new columns
    op.create_foreign_key('fk_audit_logs_organization', 'audit_logs', 'organizations', ['organization_id'], ['id'], ondelete='SET NULL')
    
    # Create performance indexes
    op.create_index('idx_audit_trails_user_created', 'audit_trails', ['user_id', 'created_at'])
    op.create_index('idx_audit_trails_org_created', 'audit_trails', ['organization_id', 'created_at'])
    op.create_index('idx_audit_trails_event_severity', 'audit_trails', ['event_type', 'severity', 'created_at'])
    op.create_index('idx_audit_trails_resource', 'audit_trails', ['resource_type', 'resource_id', 'created_at'])
    op.create_index('idx_audit_trails_compliance', 'audit_trails', ['compliance_tags'], postgresql_using='gin')
    op.create_index('idx_audit_trails_tags', 'audit_trails', ['tags'], postgresql_using='gin')
    op.create_index('idx_audit_trails_retention', 'audit_trails', ['retention_policy', 'created_at'])
    
    op.create_index('idx_data_access_logs_user_created', 'data_access_logs', ['user_id', 'created_at'])
    op.create_index('idx_data_access_logs_accessed_user', 'data_access_logs', ['accessed_user_id', 'created_at'])
    op.create_index('idx_data_access_logs_data_type', 'data_access_logs', ['data_type', 'access_type', 'created_at'])
    op.create_index('idx_data_access_logs_categories', 'data_access_logs', ['data_categories'], postgresql_using='gin')
    
    op.create_index('idx_compliance_reports_org_status', 'compliance_reports', ['organization_id', 'status', 'created_at'])
    op.create_index('idx_compliance_reports_date_range', 'compliance_reports', ['date_range_start', 'date_range_end'])
    op.create_index('idx_compliance_reports_expires_at', 'compliance_reports', ['expires_at'])
    
    op.create_index('idx_audit_configs_org_active', 'audit_configurations', ['organization_id', 'is_active'])
    
    # Add indexes to existing audit_logs table for new columns
    op.create_index('idx_audit_logs_session_id', 'audit_logs', ['session_id'])
    op.create_index('idx_audit_logs_request_id', 'audit_logs', ['request_id'])
    op.create_index('idx_audit_logs_organization_id', 'audit_logs', ['organization_id'])
    op.create_index('idx_audit_logs_severity', 'audit_logs', ['severity', 'created_at'])


def downgrade() -> None:
    """Remove audit enhancements and compliance features."""
    
    # Drop indexes from audit_logs table
    op.drop_index('idx_audit_logs_severity', table_name='audit_logs')
    op.drop_index('idx_audit_logs_organization_id', table_name='audit_logs')
    op.drop_index('idx_audit_logs_request_id', table_name='audit_logs')
    op.drop_index('idx_audit_logs_session_id', table_name='audit_logs')
    
    # Drop indexes for new tables
    op.drop_index('idx_audit_configs_org_active', table_name='audit_configurations')
    op.drop_index('idx_compliance_reports_expires_at', table_name='compliance_reports')
    op.drop_index('idx_compliance_reports_date_range', table_name='compliance_reports')
    op.drop_index('idx_compliance_reports_org_status', table_name='compliance_reports')
    op.drop_index('idx_data_access_logs_categories', table_name='data_access_logs')
    op.drop_index('idx_data_access_logs_data_type', table_name='data_access_logs')
    op.drop_index('idx_data_access_logs_accessed_user', table_name='data_access_logs')
    op.drop_index('idx_data_access_logs_user_created', table_name='data_access_logs')
    op.drop_index('idx_audit_trails_retention', table_name='audit_trails')
    op.drop_index('idx_audit_trails_tags', table_name='audit_trails')
    op.drop_index('idx_audit_trails_compliance', table_name='audit_trails')
    op.drop_index('idx_audit_trails_resource', table_name='audit_trails')
    op.drop_index('idx_audit_trails_event_severity', table_name='audit_trails')
    op.drop_index('idx_audit_trails_org_created', table_name='audit_trails')
    op.drop_index('idx_audit_trails_user_created', table_name='audit_trails')
    
    # Drop foreign key constraints
    op.drop_constraint('fk_audit_logs_organization', 'audit_logs', type_='foreignkey')
    
    # Drop new columns from audit_logs table
    op.drop_column('audit_logs', 'compliance_tags')
    op.drop_column('audit_logs', 'severity')
    op.drop_column('audit_logs', 'organization_id')
    op.drop_column('audit_logs', 'request_id')
    op.drop_column('audit_logs', 'session_id')
    
    # Drop tables in reverse order
    op.drop_table('audit_configurations')
    op.drop_table('compliance_reports')
    op.drop_table('data_access_logs')
    op.drop_table('audit_trails')
    
    # Drop enum types
    op.execute('DROP TYPE IF EXISTS audit_event_category')
    op.execute('DROP TYPE IF EXISTS audit_severity')
    op.execute('DROP TYPE IF EXISTS data_access_type')
    op.execute('DROP TYPE IF EXISTS compliance_report_type')
    op.execute('DROP TYPE IF EXISTS compliance_report_status')