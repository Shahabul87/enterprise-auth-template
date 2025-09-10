"""Add SMS authentication and device fingerprinting features

Revision ID: 009_add_sms_and_device_features
Revises: 008_add_security_enhancements
Create Date: 2025-09-10 18:30:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid

# revision identifiers, used by Alembic.
revision = '009_add_sms_and_device_features'
down_revision = '008_add_security_enhancements'
branch_labels = None
depends_on = None


def upgrade():
    """Add SMS authentication and device fingerprinting fields"""
    
    # Add phone number fields to users table
    op.add_column('users', sa.Column('phone_number', sa.String(length=20), nullable=True))
    op.add_column('users', sa.Column('is_phone_verified', sa.Boolean(), nullable=False, server_default='false'))
    op.add_column('users', sa.Column('phone_verified_at', sa.DateTime(timezone=True), nullable=True))
    
    # Add new OAuth provider fields
    op.add_column('users', sa.Column('facebook_id', sa.String(length=255), nullable=True))
    op.add_column('users', sa.Column('apple_id', sa.String(length=255), nullable=True))
    op.add_column('users', sa.Column('microsoft_id', sa.String(length=255), nullable=True))
    
    # Create unique indexes for phone numbers and new OAuth providers
    op.create_index('ix_users_phone_number', 'users', ['phone_number'], unique=True)
    op.create_index('ix_users_facebook_id', 'users', ['facebook_id'], unique=True)
    op.create_index('ix_users_apple_id', 'users', ['apple_id'], unique=True)
    op.create_index('ix_users_microsoft_id', 'users', ['microsoft_id'], unique=True)
    
    # Create user_devices table
    op.create_table('user_devices',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('device_hash', sa.String(length=64), nullable=False, index=True),
        sa.Column('device_name', sa.String(length=100), nullable=True),
        sa.Column('device_type', sa.String(length=20), nullable=False),
        sa.Column('browser', sa.String(length=50), nullable=True),
        sa.Column('browser_version', sa.String(length=20), nullable=True),
        sa.Column('os', sa.String(length=50), nullable=True),
        sa.Column('os_version', sa.String(length=20), nullable=True),
        sa.Column('fingerprint_data', postgresql.JSONB, nullable=True, default={}),
        sa.Column('last_ip_address', sa.String(length=45), nullable=True),
        sa.Column('last_country', sa.String(length=2), nullable=True),
        sa.Column('last_city', sa.String(length=100), nullable=True),
        sa.Column('is_trusted', sa.Boolean(), nullable=False, default=False),
        sa.Column('trust_score', sa.Integer(), nullable=False, default=50),
        sa.Column('is_verified', sa.Boolean(), nullable=False, default=False),
        sa.Column('verified_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('verification_method', sa.String(length=20), nullable=True),
        sa.Column('first_seen_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('last_seen_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('seen_count', sa.Integer(), nullable=False, default=1),
        sa.Column('is_blocked', sa.Boolean(), nullable=False, default=False),
        sa.Column('blocked_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('blocked_reason', sa.Text(), nullable=True),
        sa.Column('push_token', sa.String(length=255), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()'))
    )
    
    # Create indexes for user_devices
    op.create_index('ix_user_devices_id', 'user_devices', ['id'])
    op.create_index('ix_user_devices_user_id', 'user_devices', ['user_id'])
    op.create_index('ix_user_devices_device_hash', 'user_devices', ['device_hash'])


def downgrade():
    """Remove SMS authentication and device fingerprinting features"""
    
    # Drop user_devices table
    op.drop_table('user_devices')
    
    # Remove indexes from users table
    op.drop_index('ix_users_microsoft_id', 'users')
    op.drop_index('ix_users_apple_id', 'users')
    op.drop_index('ix_users_facebook_id', 'users')
    op.drop_index('ix_users_phone_number', 'users')
    
    # Remove columns from users table
    op.drop_column('users', 'microsoft_id')
    op.drop_column('users', 'apple_id')
    op.drop_column('users', 'facebook_id')
    op.drop_column('users', 'phone_verified_at')
    op.drop_column('users', 'is_phone_verified')
    op.drop_column('users', 'phone_number')