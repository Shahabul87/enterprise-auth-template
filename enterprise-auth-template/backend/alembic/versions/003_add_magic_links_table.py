"""Add magic links table

Revision ID: 003_add_magic_links_table
Revises: 002_add_performance_indexes
Create Date: 2025-02-09 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '003_add_magic_links_table'
down_revision: Union[str, None] = '002_add_performance_indexes'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create magic_links table
    op.create_table('magic_links',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('token', sa.String(length=255), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('is_used', sa.Boolean(), nullable=False, default=False),
        sa.Column('ip_address', sa.String(length=45), nullable=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('request_ip', sa.String(length=45), nullable=True),
        sa.Column('request_user_agent', sa.Text(), nullable=True),
        sa.Column('attempt_count', sa.Integer(), nullable=False, default=0),
        sa.Column('max_attempts', sa.Integer(), nullable=False, default=3),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('used_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('last_attempt_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes for performance
    op.create_index(op.f('ix_magic_links_id'), 'magic_links', ['id'], unique=False)
    op.create_index(op.f('ix_magic_links_token'), 'magic_links', ['token'], unique=True)
    op.create_index(op.f('ix_magic_links_user_id'), 'magic_links', ['user_id'], unique=False)
    op.create_index(op.f('ix_magic_links_email'), 'magic_links', ['email'], unique=False)
    op.create_index(op.f('ix_magic_links_expires_at'), 'magic_links', ['expires_at'], unique=False)


def downgrade() -> None:
    # Drop indexes
    op.drop_index(op.f('ix_magic_links_expires_at'), table_name='magic_links')
    op.drop_index(op.f('ix_magic_links_email'), table_name='magic_links')
    op.drop_index(op.f('ix_magic_links_user_id'), table_name='magic_links')
    op.drop_index(op.f('ix_magic_links_token'), table_name='magic_links')
    op.drop_index(op.f('ix_magic_links_id'), table_name='magic_links')
    
    # Drop table
    op.drop_table('magic_links')