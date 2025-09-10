"""Add performance indexes

Revision ID: 002_add_performance_indexes
Revises: 001_initial_schema_with_2fa
Create Date: 2025-01-15 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '002_add_performance_indexes'
down_revision: Union[str, None] = '001_initial_schema_with_2fa'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add performance indexes for critical database operations."""
    
    # Add composite index for user_roles table (fixes N+1 queries)
    op.create_index(
        'idx_user_roles_composite',
        'user_roles',
        ['user_id', 'role_id'],
        unique=True
    )
    
    # Add composite index for role_permissions table (fixes N+1 queries)
    op.create_index(
        'idx_role_permissions_composite',
        'role_permissions',
        ['role_id', 'permission_id'],
        unique=True
    )
    
    # Add indexes for audit_logs performance (when enabled)
    op.create_index(
        'idx_audit_logs_created_at',
        'audit_logs',
        ['created_at']
    )
    
    op.create_index(
        'idx_audit_logs_user_id_created_at',
        'audit_logs',
        ['user_id', 'created_at']
    )
    
    op.create_index(
        'idx_audit_logs_action',
        'audit_logs',
        ['action']
    )
    
    # Add index for email lookup performance with active status
    op.create_index(
        'idx_users_email_active',
        'users',
        ['email', 'is_active']
    )
    
    # Add index for user sessions performance
    op.create_index(
        'idx_user_sessions_user_id_active',
        'user_sessions',
        ['user_id', 'is_active']
    )
    
    op.create_index(
        'idx_user_sessions_expires_at',
        'user_sessions',
        ['expires_at']
    )
    
    # Add index for refresh tokens cleanup
    op.create_index(
        'idx_refresh_tokens_expires_at',
        'refresh_tokens',
        ['expires_at']
    )
    
    op.create_index(
        'idx_refresh_tokens_user_id_revoked',
        'refresh_tokens',
        ['user_id', 'is_revoked']
    )
    
    # Add index for failed login tracking
    op.create_index(
        'idx_users_locked_until',
        'users',
        ['locked_until']
    )
    
    # Add index for permission lookups
    op.create_index(
        'idx_permissions_resource_action',
        'permissions',
        ['resource', 'action']
    )


def downgrade() -> None:
    """Remove performance indexes."""
    
    # Drop indexes in reverse order
    op.drop_index('idx_permissions_resource_action', table_name='permissions')
    op.drop_index('idx_users_locked_until', table_name='users')
    op.drop_index('idx_refresh_tokens_user_id_revoked', table_name='refresh_tokens')
    op.drop_index('idx_refresh_tokens_expires_at', table_name='refresh_tokens')
    op.drop_index('idx_user_sessions_expires_at', table_name='user_sessions')
    op.drop_index('idx_user_sessions_user_id_active', table_name='user_sessions')
    op.drop_index('idx_users_email_active', table_name='users')
    op.drop_index('idx_audit_logs_action', table_name='audit_logs')
    op.drop_index('idx_audit_logs_user_id_created_at', table_name='audit_logs')
    op.drop_index('idx_audit_logs_created_at', table_name='audit_logs')
    op.drop_index('idx_role_permissions_composite', table_name='role_permissions')
    op.drop_index('idx_user_roles_composite', table_name='user_roles')