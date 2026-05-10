from datetime import datetime, timezone
from typing import Any

from bson import ObjectId
from pydantic import BaseModel, ConfigDict, Field


class PyObjectId(str):
    @classmethod
    def __get_pydantic_core_schema__(cls, _source_type: Any, _handler: Any):
        from pydantic_core import core_schema

        def validate(value: Any) -> str:
            if isinstance(value, ObjectId):
                return str(value)
            if ObjectId.is_valid(value):
                return str(ObjectId(value))
            raise ValueError("Invalid ObjectId")

        return core_schema.no_info_plain_validator_function(validate)


class MongoBaseModel(BaseModel):
    model_config = ConfigDict(populate_by_name=True)
    id: PyObjectId | None = Field(default=None, alias="_id")


class TimestampedModel(BaseModel):
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
