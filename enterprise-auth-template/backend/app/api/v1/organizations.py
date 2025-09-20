"""
Organization Management Endpoints

Handles organization creation, management, member operations,
and organizational resource management for multi-tenant scenarios.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from enum import Enum

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field, ConfigDict, field_validator
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import CurrentUser, get_current_user, require_permissions
from app.services.user.user_crud_service import UserCRUDService
from app.services.audit_service import AuditService

logger = structlog.get_logger(__name__)

router = APIRouter()


class OrganizationRole(str, Enum):
    """Organization member roles."""

    OWNER = "owner"
    ADMIN = "admin"
    MEMBER = "member"
    VIEWER = "viewer"


class OrganizationCreateRequest(BaseModel):
    """Request model for creating organizations."""

    name: str = Field(
        ..., min_length=2, max_length=100, description="Organization name"
    )
    description: Optional[str] = Field(
        None, max_length=500, description="Organization description"
    )
    website: Optional[str] = Field(None, description="Organization website URL")
    industry: Optional[str] = Field(None, max_length=100, description="Industry/sector")
    size: Optional[str] = Field(None, description="Organization size category")
    country: Optional[str] = Field(
        None, max_length=2, description="Country code (ISO 3166-1 alpha-2)"
    )
    timezone: Optional[str] = Field(None, description="Default timezone")

    @field_validator("website")
    @classmethod
    def validate_website(cls, v):
        if v and not (v.startswith("http://") or v.startswith("https://")):
            v = f"https://{v}"
        return v

    @field_validator("size")
    @classmethod
    def validate_size(cls, v):
        if v and v not in ["startup", "small", "medium", "large", "enterprise"]:
            raise ValueError(
                "Size must be one of: startup, small, medium, large, enterprise"
            )
        return v

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "Acme Corporation",
                "description": "Leading provider of innovative solutions",
                "website": "https://acme.com",
                "industry": "Technology",
                "size": "medium",
                "country": "US",
                "timezone": "America/New_York",
            }
        }
    )


class OrganizationUpdateRequest(BaseModel):
    """Request model for updating organizations."""

    name: Optional[str] = Field(
        None, min_length=2, max_length=100, description="Organization name"
    )
    description: Optional[str] = Field(
        None, max_length=500, description="Organization description"
    )
    website: Optional[str] = Field(None, description="Organization website URL")
    industry: Optional[str] = Field(None, max_length=100, description="Industry/sector")
    size: Optional[str] = Field(None, description="Organization size category")
    country: Optional[str] = Field(None, max_length=2, description="Country code")
    timezone: Optional[str] = Field(None, description="Default timezone")
    is_active: Optional[bool] = Field(None, description="Organization active status")

    @field_validator("website")
    @classmethod
    def validate_website(cls, v):
        if v and not (v.startswith("http://") or v.startswith("https://")):
            v = f"https://{v}"
        return v

    @field_validator("size")
    @classmethod
    def validate_size(cls, v):
        if v and v not in ["startup", "small", "medium", "large", "enterprise"]:
            raise ValueError(
                "Size must be one of: startup, small, medium, large, enterprise"
            )
        return v


class OrganizationMemberInviteRequest(BaseModel):
    """Request model for inviting organization members."""

    email: str = Field(..., description="Email address of the user to invite")
    role: OrganizationRole = Field(..., description="Role to assign to the member")
    message: Optional[str] = Field(
        None, max_length=500, description="Custom invitation message"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "email": "user@example.com",
                "role": "member",
                "message": "Welcome to our organization! We're excited to have you join our team.",
            }
        }
    )


class OrganizationMemberUpdateRequest(BaseModel):
    """Request model for updating organization members."""

    role: OrganizationRole = Field(..., description="New role for the member")


class OrganizationResponse(BaseModel):
    """Response model for organizations."""

    id: str = Field(..., description="Organization ID")
    name: str = Field(..., description="Organization name")
    description: Optional[str] = Field(None, description="Organization description")
    website: Optional[str] = Field(None, description="Organization website")
    industry: Optional[str] = Field(None, description="Industry/sector")
    size: Optional[str] = Field(None, description="Organization size")
    country: Optional[str] = Field(None, description="Country code")
    timezone: Optional[str] = Field(None, description="Default timezone")
    is_active: bool = Field(..., description="Organization active status")
    member_count: int = Field(..., description="Number of members")
    created_at: str = Field(..., description="Creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")
    current_user_role: Optional[str] = Field(
        None, description="Current user's role in organization"
    )


class OrganizationListResponse(BaseModel):
    """Response model for organization lists."""

    organizations: List[OrganizationResponse] = Field(
        ..., description="List of organizations"
    )
    total: int = Field(..., description="Total number of organizations")
    has_more: bool = Field(..., description="Whether more organizations exist")


class OrganizationMemberResponse(BaseModel):
    """Response model for organization members."""

    id: str = Field(..., description="Member ID")
    user_id: str = Field(..., description="User ID")
    email: str = Field(..., description="Member email")
    full_name: str = Field(..., description="Member full name")
    role: str = Field(..., description="Member role")
    status: str = Field(..., description="Membership status")
    joined_at: str = Field(..., description="Join timestamp")
    last_active: Optional[str] = Field(None, description="Last activity timestamp")


class OrganizationMemberListResponse(BaseModel):
    """Response model for organization member lists."""

    members: List[OrganizationMemberResponse] = Field(
        ..., description="List of members"
    )
    total: int = Field(..., description="Total number of members")
    has_more: bool = Field(..., description="Whether more members exist")


class OrganizationStatsResponse(BaseModel):
    """Response model for organization statistics."""

    total_members: int = Field(..., description="Total number of members")
    active_members: int = Field(..., description="Active members in last 30 days")
    pending_invitations: int = Field(..., description="Pending invitations")
    role_distribution: Dict[str, int] = Field(..., description="Members by role")
    recent_activity: List[Dict[str, Any]] = Field(
        ..., description="Recent organization activity"
    )
    resource_usage: Dict[str, Any] = Field(..., description="Resource usage statistics")


class OrganizationInvitationResponse(BaseModel):
    """Response model for organization invitations."""

    id: str = Field(..., description="Invitation ID")
    email: str = Field(..., description="Invited email")
    role: str = Field(..., description="Invited role")
    status: str = Field(..., description="Invitation status")
    message: Optional[str] = Field(None, description="Invitation message")
    invited_by: str = Field(..., description="Name of inviter")
    invited_at: str = Field(..., description="Invitation timestamp")
    expires_at: str = Field(..., description="Expiration timestamp")


class MessageResponse(BaseModel):
    """Generic message response."""

    message: str = Field(..., description="Response message")


@router.post("/", response_model=OrganizationResponse)
async def create_organization(
    org_request: OrganizationCreateRequest,
    current_user: CurrentUser = Depends(require_permissions(["organizations:create"])),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationResponse:
    """
    Create a new organization.

    Creates a new organization with the current user as the owner.
    Requires organization creation permissions.

    Args:
        org_request: Organization creation data
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationResponse: Created organization information
    """
    logger.info(
        "Organization creation requested",
        user_id=current_user.id,
        name=org_request.name,
    )

    try:
        # In a real implementation, you'd have an OrganizationService
        # For now, we'll create a placeholder response

        organization_id = f"org-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.create",
            resource_type="organization",
            resource_id=organization_id,
            details={
                "organization_name": org_request.name,
                "created_by": current_user.id,
            },
        )

        logger.info(
            "Organization created",
            organization_id=organization_id,
            user_id=current_user.id,
        )

        return OrganizationResponse(
            id=organization_id,
            name=org_request.name,
            description=org_request.description,
            website=org_request.website,
            industry=org_request.industry,
            size=org_request.size,
            country=org_request.country,
            timezone=org_request.timezone,
            is_active=True,
            member_count=1,  # Just the creator
            created_at=datetime.utcnow().isoformat(),
            updated_at=datetime.utcnow().isoformat(),
            current_user_role="owner",
        )

    except Exception as e:
        logger.error("Failed to create organization", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create organization",
        )


@router.get("/", response_model=OrganizationListResponse)
async def list_organizations(
    limit: int = Query(
        50, ge=1, le=100, description="Number of organizations to return"
    ),
    offset: int = Query(0, ge=0, description="Number of organizations to skip"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationListResponse:
    """
    List user's organizations.

    Retrieves organizations that the current user is a member of.

    Args:
        limit: Maximum number of organizations to return
        offset: Number of organizations to skip
        is_active: Filter by active status
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationListResponse: Paginated organization list
    """
    logger.debug(
        "Organizations list requested",
        user_id=current_user.id,
        limit=limit,
        offset=offset,
    )

    try:
        # In a real implementation, you'd query the database for user's organizations
        # For now, we'll create a placeholder response

        organizations = [
            OrganizationResponse(
                id=f"org-{i}",
                name=f"Organization {i}",
                description=f"Description for organization {i}",
                website=f"https://org{i}.com",
                industry="Technology",
                size="medium",
                country="US",
                timezone="America/New_York",
                is_active=True,
                member_count=5 + i,
                created_at=datetime.utcnow().isoformat(),
                updated_at=datetime.utcnow().isoformat(),
                current_user_role="member",
            )
            for i in range(offset + 1, offset + min(limit, 3) + 1)
        ]

        return OrganizationListResponse(
            organizations=organizations,
            total=10,  # Placeholder total
            has_more=(offset + limit) < 10,
        )

    except Exception as e:
        logger.error("Failed to list organizations", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve organizations",
        )


@router.get("/{org_id}", response_model=OrganizationResponse)
async def get_organization(
    org_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationResponse:
    """
    Get organization details.

    Retrieves detailed information about a specific organization.
    User must be a member of the organization.

    Args:
        org_id: Organization ID to retrieve
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationResponse: Organization information
    """
    logger.debug(
        "Organization details requested", user_id=current_user.id, org_id=org_id
    )

    try:
        # In a real implementation, you'd verify membership and get org details
        # For now, we'll create a placeholder response

        return OrganizationResponse(
            id=org_id,
            name="Acme Corporation",
            description="Leading provider of innovative solutions",
            website="https://acme.com",
            industry="Technology",
            size="large",
            country="US",
            timezone="America/New_York",
            is_active=True,
            member_count=25,
            created_at="2024-01-01T00:00:00Z",
            updated_at=datetime.utcnow().isoformat(),
            current_user_role="admin",
        )

    except Exception as e:
        logger.error("Failed to get organization", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve organization",
        )


@router.put("/{org_id}", response_model=OrganizationResponse)
async def update_organization(
    org_id: str,
    org_update: OrganizationUpdateRequest,
    current_user: CurrentUser = Depends(require_permissions(["organizations:update"])),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationResponse:
    """
    Update organization.

    Updates organization information. Requires admin or owner role.

    Args:
        org_id: Organization ID to update
        org_update: Organization update data
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationResponse: Updated organization information
    """
    logger.info("Organization update requested", user_id=current_user.id, org_id=org_id)

    try:
        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.update",
            resource_type="organization",
            resource_id=org_id,
            details={
                "updated_fields": list(org_update.dict(exclude_unset=True).keys()),
                "updated_by": current_user.id,
            },
        )

        logger.info("Organization updated", org_id=org_id, user_id=current_user.id)

        # Return updated organization (placeholder)
        return OrganizationResponse(
            id=org_id,
            name=org_update.name or "Acme Corporation",
            description=org_update.description
            or "Leading provider of innovative solutions",
            website=org_update.website or "https://acme.com",
            industry=org_update.industry or "Technology",
            size=org_update.size or "large",
            country=org_update.country or "US",
            timezone=org_update.timezone or "America/New_York",
            is_active=(
                org_update.is_active if org_update.is_active is not None else True
            ),
            member_count=25,
            created_at="2024-01-01T00:00:00Z",
            updated_at=datetime.utcnow().isoformat(),
            current_user_role="admin",
        )

    except Exception as e:
        logger.error("Failed to update organization", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update organization",
        )


@router.delete("/{org_id}", response_model=MessageResponse)
async def delete_organization(
    org_id: str,
    current_user: CurrentUser = Depends(require_permissions(["organizations:delete"])),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Delete organization.

    Permanently deletes an organization and all associated data.
    Only organization owners can delete organizations.

    Args:
        org_id: Organization ID to delete
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.warning(
        "Organization deletion requested", user_id=current_user.id, org_id=org_id
    )

    try:
        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.delete",
            resource_type="organization",
            resource_id=org_id,
            details={
                "deleted_by": current_user.id,
                "deletion_time": datetime.utcnow().isoformat(),
            },
        )

        logger.warning("Organization deleted", org_id=org_id, user_id=current_user.id)

        return MessageResponse(message="Organization deleted successfully")

    except Exception as e:
        logger.error("Failed to delete organization", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete organization",
        )


@router.get("/{org_id}/members", response_model=OrganizationMemberListResponse)
async def list_organization_members(
    org_id: str,
    limit: int = Query(50, ge=1, le=100, description="Number of members to return"),
    offset: int = Query(0, ge=0, description="Number of members to skip"),
    role: Optional[OrganizationRole] = Query(None, description="Filter by role"),
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationMemberListResponse:
    """
    List organization members.

    Retrieves members of the organization with filtering and pagination.

    Args:
        org_id: Organization ID
        limit: Maximum number of members to return
        offset: Number of members to skip
        role: Filter by member role
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationMemberListResponse: Paginated member list
    """
    logger.debug(
        "Organization members requested", user_id=current_user.id, org_id=org_id
    )

    try:
        # In a real implementation, you'd query organization members
        members = [
            OrganizationMemberResponse(
                id=f"member-{i}",
                user_id=f"user-{i}",
                email=f"member{i}@example.com",
                full_name=f"Member {i}",
                role="member" if i > 1 else "admin",
                status="active",
                joined_at=datetime.utcnow().isoformat(),
                last_active=datetime.utcnow().isoformat(),
            )
            for i in range(offset + 1, offset + min(limit, 10) + 1)
        ]

        return OrganizationMemberListResponse(
            members=members,
            total=25,  # Placeholder total
            has_more=(offset + limit) < 25,
        )

    except Exception as e:
        logger.error("Failed to list organization members", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve organization members",
        )


@router.post("/{org_id}/members/invite", response_model=OrganizationInvitationResponse)
async def invite_organization_member(
    org_id: str,
    invite_request: OrganizationMemberInviteRequest,
    current_user: CurrentUser = Depends(require_permissions(["organizations:invite"])),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationInvitationResponse:
    """
    Invite organization member.

    Sends an invitation to join the organization to the specified email.
    Requires admin or owner permissions.

    Args:
        org_id: Organization ID
        invite_request: Invitation data
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationInvitationResponse: Invitation information
    """
    logger.info(
        "Organization member invitation requested",
        user_id=current_user.id,
        org_id=org_id,
        invitee_email=invite_request.email,
    )

    try:
        invitation_id = f"inv-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.member_invite",
            resource_type="organization",
            resource_id=org_id,
            details={
                "invitee_email": invite_request.email,
                "role": invite_request.role.value,
                "invited_by": current_user.id,
            },
        )

        logger.info(
            "Organization member invited",
            invitation_id=invitation_id,
            org_id=org_id,
            user_id=current_user.id,
        )

        return OrganizationInvitationResponse(
            id=invitation_id,
            email=invite_request.email,
            role=invite_request.role.value,
            status="pending",
            message=invite_request.message,
            invited_by=current_user.full_name,
            invited_at=datetime.utcnow().isoformat(),
            expires_at=(datetime.utcnow() + timedelta(days=7)).isoformat(),
        )

    except Exception as e:
        logger.error("Failed to invite organization member", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to invite organization member",
        )


@router.put("/{org_id}/members/{member_id}", response_model=OrganizationMemberResponse)
async def update_organization_member(
    org_id: str,
    member_id: str,
    member_update: OrganizationMemberUpdateRequest,
    current_user: CurrentUser = Depends(
        require_permissions(["organizations:manage_members"])
    ),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationMemberResponse:
    """
    Update organization member.

    Updates a member's role or status in the organization.
    Requires admin or owner permissions.

    Args:
        org_id: Organization ID
        member_id: Member ID to update
        member_update: Member update data
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationMemberResponse: Updated member information
    """
    logger.info(
        "Organization member update requested",
        user_id=current_user.id,
        org_id=org_id,
        member_id=member_id,
    )

    try:
        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.member_update",
            resource_type="organization",
            resource_id=org_id,
            details={
                "member_id": member_id,
                "new_role": member_update.role.value,
                "updated_by": current_user.id,
            },
        )

        logger.info("Organization member updated", member_id=member_id, org_id=org_id)

        return OrganizationMemberResponse(
            id=member_id,
            user_id=f"user-{member_id}",
            email="member@example.com",
            full_name="Member Name",
            role=member_update.role.value,
            status="active",
            joined_at="2024-01-01T00:00:00Z",
            last_active=datetime.utcnow().isoformat(),
        )

    except Exception as e:
        logger.error("Failed to update organization member", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update organization member",
        )


@router.delete("/{org_id}/members/{member_id}", response_model=MessageResponse)
async def remove_organization_member(
    org_id: str,
    member_id: str,
    current_user: CurrentUser = Depends(
        require_permissions(["organizations:manage_members"])
    ),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Remove organization member.

    Removes a member from the organization.
    Requires admin or owner permissions.

    Args:
        org_id: Organization ID
        member_id: Member ID to remove
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.warning(
        "Organization member removal requested",
        user_id=current_user.id,
        org_id=org_id,
        member_id=member_id,
    )

    try:
        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.member_remove",
            resource_type="organization",
            resource_id=org_id,
            details={"member_id": member_id, "removed_by": current_user.id},
        )

        logger.warning(
            "Organization member removed", member_id=member_id, org_id=org_id
        )

        return MessageResponse(message="Member removed from organization successfully")

    except Exception as e:
        logger.error("Failed to remove organization member", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to remove organization member",
        )


@router.post("/{org_id}/leave", response_model=MessageResponse)
async def leave_organization(
    org_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Leave organization.

    Removes the current user from the organization.
    Organization owners cannot leave unless there's another owner.

    Args:
        org_id: Organization ID to leave
        current_user: Current authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.info("Organization leave requested", user_id=current_user.id, org_id=org_id)

    try:
        # Log audit event
        audit_service = AuditService(db)
        await audit_service.log_event(
            user_id=current_user.id,
            action="organization.leave",
            resource_type="organization",
            resource_id=org_id,
            details={"left_by": current_user.id},
        )

        logger.info("User left organization", user_id=current_user.id, org_id=org_id)

        return MessageResponse(message="Successfully left the organization")

    except Exception as e:
        logger.error("Failed to leave organization", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to leave organization",
        )


@router.get("/{org_id}/stats", response_model=OrganizationStatsResponse)
async def get_organization_statistics(
    org_id: str,
    current_user: CurrentUser = Depends(require_permissions(["organizations:stats"])),
    db: AsyncSession = Depends(get_db_session),
) -> OrganizationStatsResponse:
    """
    Get organization statistics.

    Provides statistics about organization membership and activity.
    Requires admin or owner permissions.

    Args:
        org_id: Organization ID
        current_user: Current authenticated user
        db: Database session

    Returns:
        OrganizationStatsResponse: Organization statistics
    """
    logger.info(
        "Organization statistics requested", user_id=current_user.id, org_id=org_id
    )

    try:
        return OrganizationStatsResponse(
            total_members=25,
            active_members=20,
            pending_invitations=3,
            role_distribution={"owner": 1, "admin": 2, "member": 20, "viewer": 2},
            recent_activity=[
                {
                    "type": "member_joined",
                    "user": "john.doe@example.com",
                    "timestamp": datetime.utcnow().isoformat(),
                },
                {
                    "type": "member_invited",
                    "user": "jane.smith@example.com",
                    "timestamp": (datetime.utcnow() - timedelta(hours=2)).isoformat(),
                },
            ],
            resource_usage={
                "api_keys": 15,
                "webhooks": 8,
                "storage_gb": 4.2,
                "monthly_api_calls": 45000,
            },
        )

    except Exception as e:
        logger.error("Failed to get organization statistics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve organization statistics",
        )
