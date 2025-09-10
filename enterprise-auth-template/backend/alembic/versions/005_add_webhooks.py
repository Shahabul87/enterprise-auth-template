"""Add webhooks and event system tables

Revision ID: 005_add_webhooks
Revises: 004_add_comprehensive_rbac_and_features
Create Date: 2025-01-05 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid
from datetime import datetime

# revision identifiers, used by Alembic.
revision = '005_add_webhooks'
down_revision = '004_add_comprehensive_rbac_and_features'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add webhook and event system tables for real-time notifications."""
    
    # Create webhook endpoints table
    op.create_table(
        'webhook_endpoints',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('url', sa.String(500), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('secret', sa.String(255), nullable=False),  # HMAC secret for signature verification
        sa.Column('events', postgresql.JSONB(), nullable=False, default=list),  # List of subscribed events
        sa.Column('headers', postgresql.JSONB(), nullable=True, default=dict),  # Custom headers to send
        sa.Column('timeout_seconds', sa.Integer(), nullable=False, default=10),
        sa.Column('max_retries', sa.Integer(), nullable=False, default=3),
        sa.Column('retry_backoff_seconds', sa.Integer(), nullable=False, default=60),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('last_success_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('last_failure_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('failure_count', sa.Integer(), nullable=False, default=0),
        sa.Column('total_deliveries', sa.Integer(), nullable=False, default=0),
        sa.Column('successful_deliveries', sa.Integer(), nullable=False, default=0),
        sa.Column('failed_deliveries', sa.Integer(), nullable=False, default=0),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('organization_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('organizations.id', ondelete='CASCADE'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create webhook events table for tracking individual webhook calls
    op.create_table(
        'webhook_events',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('webhook_endpoint_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('webhook_endpoints.id', ondelete='CASCADE'), nullable=False),
        sa.Column('event_type', sa.String(100), nullable=False, index=True),
        sa.Column('event_data', postgresql.JSONB(), nullable=False),
        sa.Column('payload', postgresql.JSONB(), nullable=False),  # Full payload sent to webhook
        sa.Column('signature', sa.String(255), nullable=False),  # HMAC signature
        sa.Column('status', sa.Enum('pending', 'sending', 'delivered', 'failed', 'cancelled', name='webhook_event_status'), nullable=False, default='pending', index=True),
        sa.Column('http_status_code', sa.Integer(), nullable=True),
        sa.Column('response_body', sa.Text(), nullable=True),
        sa.Column('response_headers', postgresql.JSONB(), nullable=True),
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('delivery_attempts', sa.Integer(), nullable=False, default=0),
        sa.Column('max_attempts', sa.Integer(), nullable=False, default=3),
        sa.Column('next_retry_at', sa.DateTime(timezone=True), nullable=True, index=True),
        sa.Column('sent_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('delivered_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('failed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('cancelled_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow, index=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create webhook delivery logs for detailed tracking
    op.create_table(
        'webhook_delivery_logs',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('webhook_event_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('webhook_events.id', ondelete='CASCADE'), nullable=False),
        sa.Column('attempt_number', sa.Integer(), nullable=False),
        sa.Column('status_code', sa.Integer(), nullable=True),
        sa.Column('response_time_ms', sa.Integer(), nullable=True),
        sa.Column('response_body', sa.Text(), nullable=True),
        sa.Column('response_headers', postgresql.JSONB(), nullable=True),
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('request_headers', postgresql.JSONB(), nullable=True),
        sa.Column('started_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create event triggers table for system events that can trigger webhooks
    op.create_table(
        'event_triggers',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(100), nullable=False, unique=True, index=True),
        sa.Column('display_name', sa.String(150), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('category', sa.Enum('auth', 'user', 'organization', 'billing', 'security', 'system', name='event_category'), nullable=False, index=True),
        sa.Column('payload_schema', postgresql.JSONB(), nullable=True),  # JSON schema for validation
        sa.Column('is_system', sa.Boolean(), nullable=False, default=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True, index=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow)
    )
    
    # Create webhook endpoint subscriptions (many-to-many relationship)
    op.create_table(
        'webhook_subscriptions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('webhook_endpoint_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('webhook_endpoints.id', ondelete='CASCADE'), nullable=False),
        sa.Column('event_trigger_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('event_triggers.id', ondelete='CASCADE'), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, default=True),
        sa.Column('filter_conditions', postgresql.JSONB(), nullable=True),  # Optional filtering conditions
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, default=datetime.utcnow),
        sa.UniqueConstraint('webhook_endpoint_id', 'event_trigger_id', name='uix_webhook_event_subscription')
    )
    
    # Create indexes for better performance
    op.create_index('idx_webhook_endpoints_user_id', 'webhook_endpoints', ['user_id'])
    op.create_index('idx_webhook_endpoints_organization_id', 'webhook_endpoints', ['organization_id'])
    op.create_index('idx_webhook_endpoints_active', 'webhook_endpoints', ['is_active', 'created_at'])
    
    op.create_index('idx_webhook_events_endpoint_id', 'webhook_events', ['webhook_endpoint_id'])
    op.create_index('idx_webhook_events_status_created', 'webhook_events', ['status', 'created_at'])
    op.create_index('idx_webhook_events_retry_queue', 'webhook_events', ['status', 'next_retry_at'])
    op.create_index('idx_webhook_events_event_type', 'webhook_events', ['event_type', 'created_at'])
    
    op.create_index('idx_webhook_delivery_logs_event_id', 'webhook_delivery_logs', ['webhook_event_id', 'attempt_number'])
    op.create_index('idx_webhook_delivery_logs_started_at', 'webhook_delivery_logs', ['started_at'])
    
    op.create_index('idx_webhook_subscriptions_endpoint', 'webhook_subscriptions', ['webhook_endpoint_id', 'is_active'])
    op.create_index('idx_webhook_subscriptions_event', 'webhook_subscriptions', ['event_trigger_id', 'is_active'])


def downgrade() -> None:
    """Remove webhook and event system tables."""
    
    # Drop indexes
    op.drop_index('idx_webhook_subscriptions_event', table_name='webhook_subscriptions')
    op.drop_index('idx_webhook_subscriptions_endpoint', table_name='webhook_subscriptions')
    op.drop_index('idx_webhook_delivery_logs_started_at', table_name='webhook_delivery_logs')
    op.drop_index('idx_webhook_delivery_logs_event_id', table_name='webhook_delivery_logs')
    op.drop_index('idx_webhook_events_event_type', table_name='webhook_events')
    op.drop_index('idx_webhook_events_retry_queue', table_name='webhook_events')
    op.drop_index('idx_webhook_events_status_created', table_name='webhook_events')
    op.drop_index('idx_webhook_events_endpoint_id', table_name='webhook_events')
    op.drop_index('idx_webhook_endpoints_active', table_name='webhook_endpoints')
    op.drop_index('idx_webhook_endpoints_organization_id', table_name='webhook_endpoints')
    op.drop_index('idx_webhook_endpoints_user_id', table_name='webhook_endpoints')
    
    # Drop tables in reverse order of creation
    op.drop_table('webhook_subscriptions')
    op.drop_table('event_triggers')
    op.drop_table('webhook_delivery_logs')
    op.drop_table('webhook_events')
    op.drop_table('webhook_endpoints')
    
    # Drop enum types
    op.execute('DROP TYPE IF EXISTS webhook_event_status')
    op.execute('DROP TYPE IF EXISTS event_category')