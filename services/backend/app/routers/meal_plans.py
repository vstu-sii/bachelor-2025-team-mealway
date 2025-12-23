from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Literal

router = APIRouter()

GoalType = Literal["weight_loss", "weight_gain", "healthy_diet"]


class MealPlanCreate(BaseModel):
    user_id: int
    plan_name: str
    goal_type: GoalType
    weekly_budget: float


class MealPlanOut(BaseModel):
    plan_id: int
    user_id: int
    plan_name: str
    goal_type: GoalType
    weekly_budget: float
    total_calories: Optional[float] = None
    total_cost: Optional[float] = None


# Fake in-memory database
_fake_plans_db: List[MealPlanOut] = []
_next_plan_id: int = 1


@router.post("/", response_model=MealPlanOut)
def create_plan(plan: MealPlanCreate) -> MealPlanOut:
    """
    Создание нового плана питания.
    """
    global _next_plan_id
    new_plan = MealPlanOut(
        plan_id=_next_plan_id,
        user_id=plan.user_id,
        plan_name=plan.plan_name,
        goal_type=plan.goal_type,
        weekly_budget=plan.weekly_budget,
        total_calories=None,
        total_cost=None,
    )
    _fake_plans_db.append(new_plan)
    _next_plan_id += 1
    return new_plan


@router.get("/", response_model=List[MealPlanOut])
def list_plans() -> List[MealPlanOut]:
    """
    Получить все планы питания пользователя.
    """
    return _fake_plans_db


@router.get("/{plan_id}", response_model=MealPlanOut)
def get_plan(plan_id: int) -> MealPlanOut:
    """
    Получить план питания по ID.
    """
    for p in _fake_plans_db:
        if p.plan_id == plan_id:
            return p
    raise HTTPException(status_code=404, detail="Plan not found")
