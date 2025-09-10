"""Add comprehensive RBAC and features tables

Revision ID: 004_add_comprehensive_rbac_and_features
Revises: 003_add_magic_links_table
Create Date: 2025-01-05

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid
from datetime import datetime

# revision identifiers
revision = '004_add_comprehensive_rbac_and_features'
down_revision = '003_add_magic_links_table'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add comprehensive RBAC, Organization, API Keys, and Notification tables."""
    
    # Create Organizations table
    op.create_table(
        'organizations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('slug', sa.String(100), unique=True, nullable=False, index=True),
        sa.Column('display_name', sa.String(150), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('email', sa.String(255), nullable=False),
        sa.Column('phone', sa.String(50), nullable=True),
        sa.Column('website', sa.String(255), nullable=True),
        sa.Column('logo_url', sa.String(500), nullable=True),
        sa.Column('settings', postgresql.JSONB(), nullable=True, default={}),
        sa.Column('plan_type', sa.String(50), nullable=False, default='free'),
        sa.Column('max_users', sa.Integer(), nullable=False, default=5),
        sa.Column('max_api_keys', sa.Integer(), nullable=False, default=2),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('is_verified', sa.Boolean(), nullable=False, default=False),
        sa.Column('owner_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('verified_at', sa.DateTime(timezone=True), nullable=True)
    )
    
    # Add organization_id to users table
    op.add_column('users', sa.Column('organization_id', postgresql.UUID(as_uuid=True), 
                                     sa.ForeignKey('organizations.id'), nullable=True))
    
    # Create enhanced Roles table (if it doesn't exist or needs updates)
    op.create_table(
        'roles_enhanced',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(50), unique=True, nullable=False, index=True),
        sa.Column('display_name', sa.String(100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_system', sa.Boolean(), nullable=False, default=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('priority', sa.Integer(), nullable=False, default=0),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create enhanced Permissions table
    op.create_table(
        'permissions_enhanced',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), unique=True, nullable=False, index=True),
        sa.Column('display_name', sa.String(150), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('resource', sa.String(50), nullable=False, index=True),
        sa.Column('action', sa.String(50), nullable=False, index=True),
        sa.Column('scope', sa.String(50), nullable=True),
        sa.Column('is_system', sa.Boolean(), nullable=False, default=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create role_permissions association table
    op.create_table(
        'role_permissions_enhanced',
        sa.Column('role_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('roles_enhanced.id'), primary_key=True),
        sa.Column('permission_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('permissions_enhanced.id'), primary_key=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create user_roles association table
    op.create_table(
        'user_roles_enhanced',
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), primary_key=True),
        sa.Column('role_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('roles_enhanced.id'), primary_key=True),
        sa.Column('assigned_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('assigned_by', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True)
    )
    
    # Create API Keys table
    op.create_table(
        'api_keys',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('key_prefix', sa.String(10), nullable=False, index=True),
        sa.Column('key_hash', sa.String(255), nullable=False, unique=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('scopes', postgresql.JSONB(), nullable=False, default=list),
        sa.Column('rate_limit', sa.Integer(), nullable=False, default=1000),
        sa.Column('allowed_ips', postgresql.JSONB(), nullable=True),
        sa.Column('last_used_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('last_used_ip', sa.String(45), nullable=True),
        sa.Column('usage_count', sa.Integer(), nullable=False, default=0),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('revoked_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('revoked_reason', sa.Text(), nullable=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create Notifications table
    op.create_table(
        'notifications',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('title', sa.String(200), nullable=False),
        sa.Column('message', sa.Text(), nullable=False),
        sa.Column('data', postgresql.JSONB(), nullable=True),
        sa.Column('type', sa.Enum('email', 'sms', 'push', 'in_app', 'webhook', name='notification_type'), nullable=False),
        sa.Column('category', sa.Enum('security', 'account', 'billing', 'system', 'marketing', 'general', name='notification_category'), nullable=False),
        sa.Column('priority', sa.Enum('low', 'normal', 'high', 'urgent', name='notification_priority'), nullable=False, default='normal'),
        sa.Column('status', sa.Enum('pending', 'sent', 'delivered', 'failed', 'cancelled', 'read', name='notification_status'), nullable=False, default='pending'),
        sa.Column('action_url', sa.String(500), nullable=True),
        sa.Column('action_text', sa.String(100), nullable=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False, index=True),
        sa.Column('channel_data', postgresql.JSONB(), nullable=True),
        sa.Column('delivery_attempts', sa.Integer(), nullable=False, default=0),
        sa.Column('last_attempt_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('delivered_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('read_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('scheduled_for', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create Notification Templates table
    op.create_table(
        'notification_templates',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), unique=True, nullable=False, index=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('title_template', sa.String(500), nullable=False),
        sa.Column('message_template', sa.Text(), nullable=False),
        sa.Column('type', sa.Enum('email', 'sms', 'push', 'in_app', 'webhook', name='notification_type'), nullable=False),
        sa.Column('category', sa.Enum('security', 'account', 'billing', 'system', 'marketing', 'general', name='notification_category'), nullable=False),
        sa.Column('default_priority', sa.Enum('low', 'normal', 'high', 'urgent', name='notification_priority'), nullable=False, default='normal'),
        sa.Column('required_variables', postgresql.JSONB(), nullable=False, default=list),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create indexes for better performance
    op.create_index('idx_api_keys_user_id', 'api_keys', ['user_id'])
    op.create_index('idx_api_keys_organization_id', 'api_keys', ['organization_id'])
    op.create_index('idx_notifications_user_status', 'notifications', ['user_id', 'status'])
    op.create_index('idx_notifications_scheduled', 'notifications', ['scheduled_for', 'status'])
    op.create_index('idx_organizations_slug', 'organizations', ['slug'])
    op.create_index('idx_users_organization', 'users', ['organization_id'])
    
    # Add foreign key constraints for user table relationships
    op.create_foreign_key('fk_user_owned_orgs', 'users', 'organizations', 
                         ['organization_id'], ['id'], ondelete='SET NULL')


def downgrade() -> None:
    """Remove comprehensive RBAC, Organization, API Keys, and Notification tables."""
    
    # Drop foreign key constraints
    op.drop_constraint('fk_user_owned_orgs', 'users', type_='foreignkey')
    
    # Drop indexes
    op.drop_index('idx_users_organization', 'users')
    op.drop_index('idx_organizations_slug', 'organizations')
    op.drop_index('idx_notifications_scheduled', 'notifications')
    op.drop_index('idx_notifications_user_status', 'notifications')
    op.drop_index('idx_api_keys_organization_id', 'api_keys')
    op.drop_index('idx_api_keys_user_id', 'api_keys')
    
    # Drop tables
    op.drop_table('notification_templates')
    op.drop_table('notifications')
    op.drop_table('api_keys')
    op.drop_table('user_roles_enhanced')
    op.drop_table('role_permissions_enhanced')
    op.drop_table('permissions_enhanced')
    op.drop_table('roles_enhanced')
    
    # Drop organization_id column from users
    op.drop_column('users', 'organization_id')
    
    op.drop_table('organizations')
    
    # Drop enum types
    op.execute('DROP TYPE IF EXISTS notification_type')
    op.execute('DROP TYPE IF EXISTS notification_category')
    op.execute('DROP TYPE IF EXISTS notification_priority')
    op.execute('DROP TYPE IF EXISTS notification_status')