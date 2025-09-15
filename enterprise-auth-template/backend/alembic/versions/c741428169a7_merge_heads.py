"""merge heads

Revision ID: c741428169a7
Revises: 003_consolidate_user_verification_fields, 009_add_sms_and_device_features
Create Date: 2025-09-14 15:51:30.644158

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "c741428169a7"
down_revision: Union[str, None] = (
    "003_consolidate_user_verification_fields",
    "009_add_sms_and_device_features",
)
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade database schema."""
    pass


def downgrade() -> None:
    """Downgrade database schema."""
    pass
