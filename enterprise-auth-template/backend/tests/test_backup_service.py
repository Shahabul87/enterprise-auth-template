"""
Backup Service Tests

Comprehensive tests for backup service including database backups,
file backups, backup scheduling, restoration, and backup verification.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, patch, mock_open
from typing import Dict, List, Any
import json
import gzip
import os

from app.services.backup_service import (
    BackupService,
    BackupType,
    BackupStatus,
    BackupSchedule,
    CompressionType,
)


@pytest.fixture
def backup_service():
    """Create backup service instance."""
    return BackupService()


@pytest.fixture
def database_backup_config() -> Dict[str, Any]:
    """Sample database backup configuration."""
    return {
        "backup_type": BackupType.DATABASE,
        "name": "daily_db_backup",
        "description": "Daily database backup",
        "tables": ["users", "roles", "permissions", "sessions", "audit_logs"],
        "compression": CompressionType.GZIP,
        "encryption": True,
        "storage_location": "s3://backups-bucket/database/",
        "retention_days": 30,
        "schedule": {
            "frequency": "daily",
            "time": "02:00",
            "timezone": "UTC",
        },
    }


@pytest.fixture
def file_backup_config() -> Dict[str, Any]:
    """Sample file backup configuration."""
    return {
        "backup_type": BackupType.FILES,
        "name": "application_files_backup",
        "description": "Application files and uploads backup",
        "paths": [
            "/app/uploads/",
            "/app/logs/",
            "/app/config/",
        ],
        "exclude_patterns": [
            "*.tmp",
            "*.log",
            "__pycache__/",
            ".DS_Store",
        ],
        "compression": CompressionType.ZIP,
        "encryption": True,
        "storage_location": "s3://backups-bucket/files/",
        "retention_days": 7,
    }


@pytest.fixture
def mock_backup_metadata() -> Dict[str, Any]:
    """Mock backup metadata."""
    return {
        "id": "backup-123",
        "name": "daily_db_backup",
        "type": BackupType.DATABASE,
        "status": BackupStatus.COMPLETED,
        "created_at": datetime.utcnow(),
        "completed_at": datetime.utcnow() + timedelta(minutes=15),
        "size_bytes": 125000000,  # 125 MB
        "compressed_size_bytes": 45000000,  # 45 MB
        "file_count": 5,
        "checksum": "sha256:abc123def456...",
        "storage_location": "s3://backups-bucket/database/backup-123.sql.gz",
        "encryption_key_id": "key-456",
        "metadata": {
            "database_version": "PostgreSQL 15.2",
            "tables_backed_up": 5,
            "records_backed_up": 150000,
            "compression_ratio": 0.36,
        },
    }


class TestBackupService:
    """Test backup service core functionality."""

    @pytest.mark.asyncio
    async def test_create_database_backup_success(
        self, backup_service: BackupService, database_backup_config: Dict[str, Any]
    ) -> None:
        """Test successful database backup creation."""
        with patch.object(backup_service, "_validate_backup_config") as mock_validate:
            mock_validate.return_value = True
            
            with patch.object(backup_service, "_create_database_dump") as mock_dump:
                mock_dump.return_value = {
                    "dump_file": "/tmp/backup-123.sql",
                    "size_bytes": 125000000,
                    "table_count": 5,
                    "record_count": 150000,
                }
                
                with patch.object(backup_service, "_compress_backup") as mock_compress:
                    mock_compress.return_value = {
                        "compressed_file": "/tmp/backup-123.sql.gz",
                        "compressed_size": 45000000,
                        "compression_ratio": 0.36,
                    }
                    
                    with patch.object(backup_service, "_upload_backup") as mock_upload:
                        mock_upload.return_value = {
                            "success": True,
                            "storage_location": "s3://backups-bucket/database/backup-123.sql.gz",
                            "upload_time": 30.5,
                        }
                        
                        with patch.object(backup_service, "_save_backup_metadata") as mock_save:
                            mock_save.return_value = "backup-123"
                            
                            result = await backup_service.create_backup(
                                **database_backup_config
                            )

                            assert result["success"] is True
                            assert result["backup_id"] == "backup-123"
                            assert result["type"] == BackupType.DATABASE
                            assert result["size_bytes"] == 125000000
                            assert result["compressed_size_bytes"] == 45000000
                            assert result["storage_location"].endswith(".sql.gz")

    @pytest.mark.asyncio
    async def test_create_file_backup_success(
        self, backup_service: BackupService, file_backup_config: Dict[str, Any]
    ) -> None:
        """Test successful file backup creation."""
        with patch.object(backup_service, "_validate_backup_config") as mock_validate:
            mock_validate.return_value = True
            
            with patch.object(backup_service, "_create_file_archive") as mock_archive:
                mock_archive.return_value = {
                    "archive_file": "/tmp/backup-456.zip",
                    "size_bytes": 250000000,
                    "file_count": 1250,
                    "included_paths": ["/app/uploads/", "/app/config/"],
                    "excluded_files": ["temp.tmp", ".DS_Store"],
                }
                
                with patch.object(backup_service, "_upload_backup") as mock_upload:
                    mock_upload.return_value = {
                        "success": True,
                        "storage_location": "s3://backups-bucket/files/backup-456.zip",
                        "upload_time": 45.2,
                    }
                    
                    with patch.object(backup_service, "_save_backup_metadata") as mock_save:
                        mock_save.return_value = "backup-456"
                        
                        result = await backup_service.create_backup(
                            **file_backup_config
                        )

                        assert result["success"] is True
                        assert result["backup_id"] == "backup-456"
                        assert result["type"] == BackupType.FILES
                        assert result["file_count"] == 1250

    @pytest.mark.asyncio
    async def test_create_backup_validation_failure(
        self, backup_service: BackupService, database_backup_config: Dict[str, Any]
    ) -> None:
        """Test backup creation with validation failure."""
        database_backup_config["tables"] = []  # Invalid empty tables list
        
        with patch.object(backup_service, "_validate_backup_config") as mock_validate:
            mock_validate.side_effect = ValueError("Tables list cannot be empty")
            
            result = await backup_service.create_backup(
                **database_backup_config
            )

            assert result["success"] is False
            assert "Tables list cannot be empty" in result["error"]

    @pytest.mark.asyncio
    async def test_create_backup_dump_failure(
        self, backup_service: BackupService, database_backup_config: Dict[str, Any]
    ) -> None:
        """Test backup creation with database dump failure."""
        with patch.object(backup_service, "_validate_backup_config") as mock_validate:
            mock_validate.return_value = True
            
            with patch.object(backup_service, "_create_database_dump") as mock_dump:
                mock_dump.side_effect = Exception("Database connection failed")
                
                result = await backup_service.create_backup(
                    **database_backup_config
                )

                assert result["success"] is False
                assert "Database connection failed" in result["error"]

    @pytest.mark.asyncio
    async def test_create_backup_upload_failure(
        self, backup_service: BackupService, database_backup_config: Dict[str, Any]
    ) -> None:
        """Test backup creation with upload failure."""
        with patch.object(backup_service, "_validate_backup_config") as mock_validate:
            mock_validate.return_value = True
            
            with patch.object(backup_service, "_create_database_dump") as mock_dump:
                mock_dump.return_value = {
                    "dump_file": "/tmp/backup-123.sql",
                    "size_bytes": 125000000,
                }
                
                with patch.object(backup_service, "_compress_backup") as mock_compress:
                    mock_compress.return_value = {
                        "compressed_file": "/tmp/backup-123.sql.gz",
                        "compressed_size": 45000000,
                    }
                    
                    with patch.object(backup_service, "_upload_backup") as mock_upload:
                        mock_upload.side_effect = Exception("S3 upload failed")
                        
                        result = await backup_service.create_backup(
                            **database_backup_config
                        )

                        assert result["success"] is False
                        assert "S3 upload failed" in result["error"]


class TestBackupRestoration:
    """Test backup restoration functionality."""

    @pytest.mark.asyncio
    async def test_restore_database_backup_success(
        self, backup_service: BackupService, mock_backup_metadata: Dict[str, Any]
    ) -> None:
        """Test successful database backup restoration."""
        backup_id = "backup-123"
        restore_options = {
            "target_database": "test_restore_db",
            "overwrite_existing": True,
            "restore_tables": ["users", "roles", "permissions"],
        }

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = mock_backup_metadata
            
            with patch.object(backup_service, "_download_backup") as mock_download:
                mock_download.return_value = {
                    "local_file": "/tmp/restore-backup-123.sql.gz",
                    "download_time": 15.3,
                }
                
                with patch.object(backup_service, "_decompress_backup") as mock_decompress:
                    mock_decompress.return_value = {
                        "decompressed_file": "/tmp/restore-backup-123.sql",
                        "size_bytes": 125000000,
                    }
                    
                    with patch.object(backup_service, "_verify_backup_integrity") as mock_verify:
                        mock_verify.return_value = {"valid": True, "checksum_match": True}
                        
                        with patch.object(backup_service, "_restore_database") as mock_restore:
                            mock_restore.return_value = {
                                "success": True,
                                "restored_tables": 3,
                                "restored_records": 85000,
                                "restoration_time": 120.5,
                            }
                            
                            result = await backup_service.restore_backup(
                                backup_id, **restore_options
                            )

                            assert result["success"] is True
                            assert result["backup_id"] == backup_id
                            assert result["restored_tables"] == 3
                            assert result["restored_records"] == 85000

    @pytest.mark.asyncio
    async def test_restore_file_backup_success(
        self, backup_service: BackupService
    ) -> None:
        """Test successful file backup restoration."""
        backup_id = "backup-456"
        file_backup_metadata = {
            "id": backup_id,
            "type": BackupType.FILES,
            "status": BackupStatus.COMPLETED,
            "storage_location": "s3://backups-bucket/files/backup-456.zip",
            "file_count": 1250,
        }
        restore_options = {
            "target_directory": "/app/restore/",
            "overwrite_existing": True,
            "restore_paths": ["/app/uploads/", "/app/config/"],
        }

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = file_backup_metadata
            
            with patch.object(backup_service, "_download_backup") as mock_download:
                mock_download.return_value = {
                    "local_file": "/tmp/restore-backup-456.zip",
                    "download_time": 25.8,
                }
                
                with patch.object(backup_service, "_extract_files") as mock_extract:
                    mock_extract.return_value = {
                        "success": True,
                        "extracted_files": 850,
                        "skipped_files": 400,  # Due to path filtering
                        "extraction_time": 45.2,
                    }
                    
                    result = await backup_service.restore_backup(
                        backup_id, **restore_options
                    )

                    assert result["success"] is True
                    assert result["backup_id"] == backup_id
                    assert result["extracted_files"] == 850
                    assert result["skipped_files"] == 400

    @pytest.mark.asyncio
    async def test_restore_backup_not_found(
        self, backup_service: BackupService
    ) -> None:
        """Test restoration of non-existent backup."""
        backup_id = "non-existent-backup"

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.side_effect = ValueError("Backup not found")
            
            result = await backup_service.restore_backup(backup_id)

            assert result["success"] is False
            assert "Backup not found" in result["error"]

    @pytest.mark.asyncio
    async def test_restore_backup_integrity_check_failure(
        self, backup_service: BackupService, mock_backup_metadata: Dict[str, Any]
    ) -> None:
        """Test restoration with backup integrity check failure."""
        backup_id = "backup-123"

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = mock_backup_metadata
            
            with patch.object(backup_service, "_download_backup") as mock_download:
                mock_download.return_value = {
                    "local_file": "/tmp/backup-123.sql.gz",
                }
                
                with patch.object(backup_service, "_verify_backup_integrity") as mock_verify:
                    mock_verify.return_value = {
                        "valid": False,
                        "checksum_match": False,
                        "error": "Backup file is corrupted",
                    }
                    
                    result = await backup_service.restore_backup(backup_id)

                    assert result["success"] is False
                    assert "Backup file is corrupted" in result["error"]


class TestBackupScheduling:
    """Test backup scheduling functionality."""

    @pytest.mark.asyncio
    async def test_schedule_backup_success(
        self, backup_service: BackupService, database_backup_config: Dict[str, Any]
    ) -> None:
        """Test successful backup scheduling."""
        with patch.object(backup_service, "_validate_schedule") as mock_validate:
            mock_validate.return_value = True
            
            with patch.object(backup_service, "_save_backup_schedule") as mock_save:
                mock_save.return_value = "schedule-123"
                
                result = await backup_service.schedule_backup(
                    **database_backup_config
                )

                assert result["success"] is True
                assert result["schedule_id"] == "schedule-123"
                assert result["name"] == database_backup_config["name"]
                assert result["frequency"] == "daily"

    @pytest.mark.asyncio
    async def test_get_scheduled_backups(
        self, backup_service: BackupService
    ) -> None:
        """Test retrieval of scheduled backups."""
        with patch.object(backup_service, "_get_all_schedules") as mock_get_schedules:
            mock_schedules = [
                {
                    "id": "schedule-1",
                    "name": "daily_db_backup",
                    "type": BackupType.DATABASE,
                    "frequency": "daily",
                    "time": "02:00",
                    "active": True,
                    "last_run": "2024-01-01T02:00:00Z",
                    "next_run": "2024-01-02T02:00:00Z",
                    "success_count": 30,
                    "failure_count": 1,
                },
                {
                    "id": "schedule-2",
                    "name": "weekly_files_backup",
                    "type": BackupType.FILES,
                    "frequency": "weekly",
                    "time": "03:00",
                    "active": True,
                    "last_run": "2024-01-01T03:00:00Z",
                    "next_run": "2024-01-08T03:00:00Z",
                    "success_count": 8,
                    "failure_count": 0,
                },
            ]
            mock_get_schedules.return_value = mock_schedules
            
            result = await backup_service.get_scheduled_backups()

            assert result["success"] is True
            assert len(result["schedules"]) == 2
            assert result["schedules"][0]["name"] == "daily_db_backup"
            assert result["schedules"][1]["frequency"] == "weekly"

    @pytest.mark.asyncio
    async def test_execute_scheduled_backups(
        self, backup_service: BackupService
    ) -> None:
        """Test execution of scheduled backups."""
        with patch.object(backup_service, "_get_due_schedules") as mock_get_due:
            mock_due_schedules = [
                {
                    "id": "schedule-1",
                    "name": "daily_db_backup",
                    "config": {"backup_type": BackupType.DATABASE, "tables": ["users"]},
                },
                {
                    "id": "schedule-2",
                    "name": "hourly_logs_backup",
                    "config": {"backup_type": BackupType.FILES, "paths": ["/app/logs/"]},
                },
            ]
            mock_get_due.return_value = mock_due_schedules
            
            with patch.object(backup_service, "create_backup") as mock_create:
                mock_create.side_effect = [
                    {"success": True, "backup_id": "backup-789"},
                    {"success": False, "error": "Storage quota exceeded"},
                ]
                
                with patch.object(backup_service, "_update_schedule_status") as mock_update:
                    mock_update.return_value = True
                    
                    result = await backup_service.execute_scheduled_backups()

                    assert result["success"] is True
                    assert result["processed_schedules"] == 2
                    assert result["successful_backups"] == 1
                    assert result["failed_backups"] == 1
                    assert len(result["results"]) == 2

    @pytest.mark.asyncio
    async def test_update_backup_schedule(
        self, backup_service: BackupService
    ) -> None:
        """Test backup schedule update."""
        schedule_id = "schedule-123"
        update_data = {
            "frequency": "weekly",
            "time": "04:00",
            "active": False,
            "retention_days": 60,
        }

        with patch.object(backup_service, "_get_schedule_by_id") as mock_get:
            mock_schedule = {
                "id": schedule_id,
                "name": "daily_db_backup",
                "frequency": "daily",
                "active": True,
            }
            mock_get.return_value = mock_schedule
            
            with patch.object(backup_service, "_update_schedule") as mock_update:
                mock_update.return_value = True
                
                result = await backup_service.update_backup_schedule(
                    schedule_id, **update_data
                )

                assert result["success"] is True
                assert result["schedule_id"] == schedule_id
                assert result["frequency"] == "weekly"
                assert result["active"] is False

    @pytest.mark.asyncio
    async def test_delete_backup_schedule(
        self, backup_service: BackupService
    ) -> None:
        """Test backup schedule deletion."""
        schedule_id = "schedule-123"

        with patch.object(backup_service, "_get_schedule_by_id") as mock_get:
            mock_schedule = {"id": schedule_id, "name": "test_schedule"}
            mock_get.return_value = mock_schedule
            
            with patch.object(backup_service, "_delete_schedule") as mock_delete:
                mock_delete.return_value = True
                
                result = await backup_service.delete_backup_schedule(schedule_id)

                assert result["success"] is True
                assert result["schedule_id"] == schedule_id
                assert "deleted successfully" in result["message"]


class TestBackupManagement:
    """Test backup management functionality."""

    @pytest.mark.asyncio
    async def test_list_backups_success(
        self, backup_service: BackupService
    ) -> None:
        """Test successful backup listing."""
        with patch.object(backup_service, "_get_all_backups") as mock_get_all:
            mock_backups = [
                {
                    "id": "backup-1",
                    "name": "daily_db_backup",
                    "type": BackupType.DATABASE,
                    "status": BackupStatus.COMPLETED,
                    "created_at": "2024-01-01T02:00:00Z",
                    "size_bytes": 125000000,
                    "compressed_size_bytes": 45000000,
                    "retention_expires_at": "2024-01-31T02:00:00Z",
                },
                {
                    "id": "backup-2",
                    "name": "weekly_files_backup",
                    "type": BackupType.FILES,
                    "status": BackupStatus.COMPLETED,
                    "created_at": "2024-01-01T03:00:00Z",
                    "size_bytes": 250000000,
                    "compressed_size_bytes": 180000000,
                    "retention_expires_at": "2024-01-08T03:00:00Z",
                },
                {
                    "id": "backup-3",
                    "name": "manual_backup",
                    "type": BackupType.DATABASE,
                    "status": BackupStatus.FAILED,
                    "created_at": "2024-01-01T15:30:00Z",
                    "error": "Disk space insufficient",
                },
            ]
            mock_get_all.return_value = {
                "backups": mock_backups,
                "total_count": 3,
                "total_size": 375000000,
                "completed_count": 2,
                "failed_count": 1,
            }
            
            result = await backup_service.list_backups()

            assert result["success"] is True
            assert len(result["backups"]) == 3
            assert result["total_count"] == 3
            assert result["completed_count"] == 2
            assert result["failed_count"] == 1

    @pytest.mark.asyncio
    async def test_list_backups_with_filters(
        self, backup_service: BackupService
    ) -> None:
        """Test backup listing with filters."""
        filters = {
            "type": BackupType.DATABASE,
            "status": BackupStatus.COMPLETED,
            "start_date": "2024-01-01",
            "end_date": "2024-01-31",
        }

        with patch.object(backup_service, "_get_filtered_backups") as mock_get_filtered:
            mock_backups = [
                {
                    "id": "backup-1",
                    "name": "daily_db_backup",
                    "type": BackupType.DATABASE,
                    "status": BackupStatus.COMPLETED,
                    "created_at": "2024-01-01T02:00:00Z",
                }
            ]
            mock_get_filtered.return_value = {
                "backups": mock_backups,
                "total_count": 1,
                "filters_applied": filters,
            }
            
            result = await backup_service.list_backups(**filters)

            assert result["success"] is True
            assert len(result["backups"]) == 1
            assert result["backups"][0]["type"] == BackupType.DATABASE

    @pytest.mark.asyncio
    async def test_get_backup_details(
        self, backup_service: BackupService, mock_backup_metadata: Dict[str, Any]
    ) -> None:
        """Test backup details retrieval."""
        backup_id = "backup-123"

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = mock_backup_metadata
            
            with patch.object(backup_service, "_get_backup_verification_history") as mock_get_history:
                mock_history = [
                    {
                        "timestamp": "2024-01-01T12:00:00Z",
                        "result": "passed",
                        "checksum_valid": True,
                        "size_valid": True,
                    },
                    {
                        "timestamp": "2024-01-02T12:00:00Z",
                        "result": "passed",
                        "checksum_valid": True,
                        "size_valid": True,
                    },
                ]
                mock_get_history.return_value = mock_history
                
                result = await backup_service.get_backup_details(backup_id)

                assert result["success"] is True
                assert result["backup"]["id"] == backup_id
                assert result["backup"]["status"] == BackupStatus.COMPLETED
                assert len(result["verification_history"]) == 2

    @pytest.mark.asyncio
    async def test_delete_backup_success(
        self, backup_service: BackupService, mock_backup_metadata: Dict[str, Any]
    ) -> None:
        """Test successful backup deletion."""
        backup_id = "backup-123"

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = mock_backup_metadata
            
            with patch.object(backup_service, "_delete_backup_files") as mock_delete_files:
                mock_delete_files.return_value = {
                    "success": True,
                    "deleted_files": ["backup-123.sql.gz"],
                    "freed_space": 45000000,
                }
                
                with patch.object(backup_service, "_delete_backup_metadata") as mock_delete_metadata:
                    mock_delete_metadata.return_value = True
                    
                    result = await backup_service.delete_backup(backup_id)

                    assert result["success"] is True
                    assert result["backup_id"] == backup_id
                    assert result["freed_space"] == 45000000

    @pytest.mark.asyncio
    async def test_cleanup_expired_backups(
        self, backup_service: BackupService
    ) -> None:
        """Test cleanup of expired backups."""
        with patch.object(backup_service, "_get_expired_backups") as mock_get_expired:
            mock_expired = [
                {
                    "id": "backup-old-1",
                    "name": "expired_backup_1",
                    "created_at": "2023-12-01T02:00:00Z",
                    "retention_expires_at": "2023-12-31T02:00:00Z",
                    "size_bytes": 100000000,
                },
                {
                    "id": "backup-old-2",
                    "name": "expired_backup_2",
                    "created_at": "2023-12-15T02:00:00Z",
                    "retention_expires_at": "2024-01-14T02:00:00Z",
                    "size_bytes": 75000000,
                },
            ]
            mock_get_expired.return_value = mock_expired
            
            with patch.object(backup_service, "delete_backup") as mock_delete:
                mock_delete.side_effect = [
                    {"success": True, "freed_space": 100000000},
                    {"success": True, "freed_space": 75000000},
                ]
                
                result = await backup_service.cleanup_expired_backups()

                assert result["success"] is True
                assert result["deleted_count"] == 2
                assert result["total_freed_space"] == 175000000
                assert mock_delete.call_count == 2


class TestBackupVerification:
    """Test backup verification functionality."""

    @pytest.mark.asyncio
    async def test_verify_backup_success(
        self, backup_service: BackupService, mock_backup_metadata: Dict[str, Any]
    ) -> None:
        """Test successful backup verification."""
        backup_id = "backup-123"

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = mock_backup_metadata
            
            with patch.object(backup_service, "_verify_backup_integrity") as mock_verify:
                mock_verify.return_value = {
                    "valid": True,
                    "checksum_match": True,
                    "size_match": True,
                    "compression_valid": True,
                    "accessibility_check": "passed",
                    "verification_time": 5.2,
                }
                
                with patch.object(backup_service, "_save_verification_result") as mock_save:
                    mock_save.return_value = True
                    
                    result = await backup_service.verify_backup(backup_id)

                    assert result["success"] is True
                    assert result["backup_id"] == backup_id
                    assert result["verification_result"]["valid"] is True
                    assert result["verification_result"]["checksum_match"] is True

    @pytest.mark.asyncio
    async def test_verify_backup_corruption_detected(
        self, backup_service: BackupService, mock_backup_metadata: Dict[str, Any]
    ) -> None:
        """Test backup verification with corruption detection."""
        backup_id = "backup-123"

        with patch.object(backup_service, "_get_backup_metadata") as mock_get_metadata:
            mock_get_metadata.return_value = mock_backup_metadata
            
            with patch.object(backup_service, "_verify_backup_integrity") as mock_verify:
                mock_verify.return_value = {
                    "valid": False,
                    "checksum_match": False,
                    "size_match": True,
                    "corruption_detected": True,
                    "error": "Checksum mismatch - backup may be corrupted",
                }
                
                result = await backup_service.verify_backup(backup_id)

                assert result["success"] is False
                assert "corruption" in result["error"].lower()
                assert result["verification_result"]["corruption_detected"] is True

    @pytest.mark.asyncio
    async def test_verify_all_backups(
        self, backup_service: BackupService
    ) -> None:
        """Test verification of all backups."""
        with patch.object(backup_service, "_get_all_backup_ids") as mock_get_ids:
            mock_get_ids.return_value = ["backup-1", "backup-2", "backup-3"]
            
            with patch.object(backup_service, "verify_backup") as mock_verify:
                mock_verify.side_effect = [
                    {"success": True, "verification_result": {"valid": True}},
                    {"success": True, "verification_result": {"valid": True}},
                    {"success": False, "error": "Backup corrupted"},
                ]
                
                result = await backup_service.verify_all_backups()

                assert result["success"] is True
                assert result["total_backups"] == 3
                assert result["valid_backups"] == 2
                assert result["invalid_backups"] == 1
                assert mock_verify.call_count == 3


class TestBackupEncryption:
    """Test backup encryption functionality."""

    @pytest.mark.asyncio
    async def test_encrypt_backup_success(
        self, backup_service: BackupService
    ) -> None:
        """Test successful backup encryption."""
        backup_file = "/tmp/backup-123.sql"
        encryption_key = "test-encryption-key"

        with patch.object(backup_service, "_encrypt_file") as mock_encrypt:
            mock_encrypt.return_value = {
                "encrypted_file": "/tmp/backup-123.sql.enc",
                "encryption_algorithm": "AES-256-GCM",
                "key_id": "key-456",
                "encryption_time": 2.5,
            }
            
            result = await backup_service._encrypt_backup(backup_file, encryption_key)

            assert result["encrypted_file"] == "/tmp/backup-123.sql.enc"
            assert result["encryption_algorithm"] == "AES-256-GCM"
            assert result["key_id"] == "key-456"

    @pytest.mark.asyncio
    async def test_decrypt_backup_success(
        self, backup_service: BackupService
    ) -> None:
        """Test successful backup decryption."""
        encrypted_file = "/tmp/backup-123.sql.enc"
        decryption_key = "test-encryption-key"

        with patch.object(backup_service, "_decrypt_file") as mock_decrypt:
            mock_decrypt.return_value = {
                "decrypted_file": "/tmp/backup-123.sql",
                "decryption_time": 1.8,
                "integrity_verified": True,
            }
            
            result = await backup_service._decrypt_backup(encrypted_file, decryption_key)

            assert result["decrypted_file"] == "/tmp/backup-123.sql"
            assert result["integrity_verified"] is True

    @pytest.mark.asyncio
    async def test_decrypt_backup_wrong_key(
        self, backup_service: BackupService
    ) -> None:
        """Test backup decryption with wrong key."""
        encrypted_file = "/tmp/backup-123.sql.enc"
        wrong_key = "wrong-encryption-key"

        with patch.object(backup_service, "_decrypt_file") as mock_decrypt:
            mock_decrypt.side_effect = Exception("Decryption failed - invalid key")
            
            with pytest.raises(Exception) as exc_info:
                await backup_service._decrypt_backup(encrypted_file, wrong_key)

            assert "Decryption failed" in str(exc_info.value)


# Performance and integration tests
@pytest.mark.performance
class TestBackupPerformance:
    """Performance tests for backup service."""

    @pytest.mark.asyncio
    async def test_large_database_backup_performance(
        self, backup_service: BackupService
    ) -> None:
        """Test performance of large database backup."""
        large_db_config = {
            "backup_type": BackupType.DATABASE,
            "name": "large_db_backup",
            "tables": ["large_table_1", "large_table_2"],
        }

        with patch.object(backup_service, "_create_database_dump") as mock_dump:
            mock_dump.return_value = {
                "dump_file": "/tmp/large-backup.sql",
                "size_bytes": 5000000000,  # 5 GB
                "table_count": 2,
                "record_count": 50000000,  # 50 million records
                "dump_time": 300,  # 5 minutes
            }
            
            with patch.object(backup_service, "_compress_backup") as mock_compress:
                mock_compress.return_value = {
                    "compressed_file": "/tmp/large-backup.sql.gz",
                    "compressed_size": 1500000000,  # 1.5 GB
                    "compression_ratio": 0.3,
                    "compression_time": 120,  # 2 minutes
                }
                
                with patch.object(backup_service, "_upload_backup") as mock_upload:
                    mock_upload.return_value = {
                        "success": True,
                        "storage_location": "s3://backups-bucket/large-backup.sql.gz",
                        "upload_time": 180,  # 3 minutes
                    }
                    
                    with patch.object(backup_service, "_save_backup_metadata") as mock_save:
                        mock_save.return_value = "large-backup-id"
                        
                        result = await backup_service.create_backup(**large_db_config)

                        assert result["success"] is True
                        assert result["size_bytes"] == 5000000000
                        assert result["compressed_size_bytes"] == 1500000000
                        # Total time should be reasonable for large backup
                        total_time = 300 + 120 + 180  # dump + compress + upload
                        assert total_time <= 600  # Should complete within 10 minutes

    @pytest.mark.asyncio
    async def test_concurrent_backup_operations(
        self, backup_service: BackupService
    ) -> None:
        """Test concurrent backup operations."""
        import asyncio
        
        async def create_backup_task(backup_name):
            """Create a single backup task."""
            config = {
                "backup_type": BackupType.DATABASE,
                "name": backup_name,
                "tables": ["test_table"],
            }
            return await backup_service.create_backup(**config)

        with patch.object(backup_service, "create_backup") as mock_create:
            mock_create.side_effect = lambda **kwargs: {
                "success": True,
                "backup_id": f"backup-{kwargs['name']}",
                "name": kwargs["name"],
            }
            
            # Create 5 backups concurrently
            tasks = [create_backup_task(f"concurrent_backup_{i}") for i in range(5)]
            results = await asyncio.gather(*tasks)

            assert len(results) == 5
            assert all(result["success"] for result in results)
            assert mock_create.call_count == 5

    @pytest.mark.asyncio
    async def test_backup_cleanup_performance(
        self, backup_service: BackupService
    ) -> None:
        """Test performance of backup cleanup operations."""
        with patch.object(backup_service, "_get_expired_backups") as mock_get_expired:
            # Simulate 100 expired backups
            mock_expired = [
                {
                    "id": f"backup-old-{i}",
                    "size_bytes": 10000000,  # 10 MB each
                }
                for i in range(100)
            ]
            mock_get_expired.return_value = mock_expired
            
            with patch.object(backup_service, "delete_backup") as mock_delete:
                mock_delete.return_value = {
                    "success": True,
                    "freed_space": 10000000,
                }
                
                result = await backup_service.cleanup_expired_backups()

                assert result["success"] is True
                assert result["deleted_count"] == 100
                assert result["total_freed_space"] == 1000000000  # 1 GB total
                assert mock_delete.call_count == 100