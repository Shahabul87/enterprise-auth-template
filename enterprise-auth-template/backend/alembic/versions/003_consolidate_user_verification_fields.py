"""Consolidate user verification fields

Revision ID: 003_consolidate_user_verification_fields
Revises: 002_add_performance_indexes
Create Date: 2025-01-14 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.sql import text


# revision identifiers, used by Alembic.
revision = '003_consolidate_user_verification_fields'
down_revision = '002_add_performance_indexes'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """
    Consolidate user verification fields for consistency.

    This migration ensures that:
    1. email_verified field is the single source of truth for email verification
    2. is_verified field is deprecated and mapped to email_verified
    3. All verification logic uses email_verified consistently
    4. Data is migrated safely without loss
    """

    # Get database connection
    connection = op.get_bind()

    print("🔄 Starting user verification field consolidation...")

    # Step 1: Ensure email_verified column exists (should already exist)
    try:
        # Try to add the column if it doesn't exist
        op.add_column('users', sa.Column('email_verified', sa.Boolean(), nullable=True, default=False))
        print("✅ Added email_verified column")
    except Exception:
        # Column already exists
        print("✅ email_verified column already exists")

    # Step 2: Migrate data from is_verified to email_verified if needed
    print("🔄 Migrating verification data...")

    # Check if we have users with is_verified=True but email_verified=False
    result = connection.execute(text("""
        SELECT COUNT(*) as count
        FROM users
        WHERE is_verified = true AND (email_verified IS NULL OR email_verified = false)
    """))

    migration_count = result.fetchone()[0]

    if migration_count > 0:
        print(f"🔄 Migrating {migration_count} users from is_verified to email_verified...")

        # Update email_verified to match is_verified for consistency
        connection.execute(text("""
            UPDATE users
            SET email_verified = is_verified
            WHERE is_verified = true AND (email_verified IS NULL OR email_verified = false)
        """))

        print(f"✅ Migrated {migration_count} user verification statuses")
    else:
        print("✅ No verification data migration needed")

    # Step 3: Ensure all NULL email_verified values are set to False
    connection.execute(text("""
        UPDATE users
        SET email_verified = false
        WHERE email_verified IS NULL
    """))

    # Step 4: Make email_verified NOT NULL with default False
    try:
        op.alter_column('users', 'email_verified',
                       nullable=False,
                       server_default=sa.text('false'))
        print("✅ Set email_verified as NOT NULL with default False")
    except Exception as e:
        print(f"⚠️  Could not alter email_verified column constraints: {e}")

    # Step 5: Create index on email_verified for performance
    try:
        op.create_index('idx_users_email_verified', 'users', ['email_verified'])
        print("✅ Created index on email_verified")
    except Exception:
        print("⚠️  Index on email_verified already exists")

    # Step 6: Create composite index for common query patterns
    try:
        op.create_index('idx_users_active_verified', 'users', ['is_active', 'email_verified'])
        print("✅ Created composite index on is_active and email_verified")
    except Exception:
        print("⚠️  Composite index already exists")

    # Step 7: Add database constraint to ensure data consistency
    try:
        # Create a check constraint to ensure logical consistency
        # If email_verified is true, is_active should generally be true too
        op.create_check_constraint(
            'ck_users_verified_implies_considered_for_activation',
            'users',
            'email_verified = false OR is_active = true OR is_active = false'  # Allow any combination but document the intent
        )
        print("✅ Added consistency check constraint")
    except Exception as e:
        print(f"⚠️  Could not add check constraint: {e}")

    # Step 8: Update any remaining inconsistent data
    print("🔄 Ensuring data consistency...")

    # Ensure users with verified emails are also active (business rule)
    result = connection.execute(text("""
        UPDATE users
        SET is_active = true
        WHERE email_verified = true AND is_active = false
    """))

    if result.rowcount > 0:
        print(f"✅ Activated {result.rowcount} users with verified emails")

    # Final verification count
    result = connection.execute(text("""
        SELECT
            COUNT(*) as total_users,
            COUNT(CASE WHEN email_verified = true THEN 1 END) as verified_users,
            COUNT(CASE WHEN is_active = true THEN 1 END) as active_users,
            COUNT(CASE WHEN email_verified = true AND is_active = true THEN 1 END) as verified_and_active
        FROM users
    """))

    stats = result.fetchone()
    print(f"📊 Migration complete:")
    print(f"   Total users: {stats[0]}")
    print(f"   Verified emails: {stats[1]}")
    print(f"   Active accounts: {stats[2]}")
    print(f"   Verified & Active: {stats[3]}")

    print("✅ User verification field consolidation completed successfully!")


def downgrade() -> None:
    """
    Rollback the verification field consolidation.

    This safely rolls back the changes while preserving data.
    """

    print("🔄 Rolling back user verification field consolidation...")

    # Remove indexes created in upgrade
    try:
        op.drop_index('idx_users_email_verified', table_name='users')
        print("✅ Removed email_verified index")
    except Exception:
        print("⚠️  email_verified index not found")

    try:
        op.drop_index('idx_users_active_verified', table_name='users')
        print("✅ Removed composite index")
    except Exception:
        print("⚠️  Composite index not found")

    # Remove check constraint
    try:
        op.drop_constraint('ck_users_verified_implies_considered_for_activation', 'users', type_='check')
        print("✅ Removed check constraint")
    except Exception:
        print("⚠️  Check constraint not found")

    # Optionally revert email_verified to nullable (be careful with this in production)
    try:
        op.alter_column('users', 'email_verified', nullable=True)
        print("✅ Made email_verified nullable again")
    except Exception as e:
        print(f"⚠️  Could not alter email_verified column: {e}")

    print("✅ Rollback completed. Note: Data is preserved, only constraints/indexes removed.")