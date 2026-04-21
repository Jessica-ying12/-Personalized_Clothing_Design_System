from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.service.chat_service import PcdsChatService
from utils.response_util import ResponseUtil

chat_controller = APIRouter(prefix='/api/chat')


class ChatRequest(BaseModel):
    message: str


@chat_controller.post('/ask', summary='服装 AI 问答')
async def ask(
    req: ChatRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    reply = await PcdsChatService.ask(req.message)
    return ResponseUtil.success(data={'reply': reply})
