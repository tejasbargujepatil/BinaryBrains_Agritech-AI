from abc import ABC, abstractmethod
from datetime import datetime
from app import db
from app.models import AgentLog
import time

class BaseAgent(ABC):
    """Base class for all AI agents"""
    
    def __init__(self, agent_type: str):
        self.agent_type = agent_type
        self.execution_start = None
    
    @abstractmethod
    def execute(self, **kwargs) -> dict:
        """Execute agent logic - must be implemented by subclasses"""
        pass
    
    def log_execution(self, user_id: int = None, crop_id: int = None, 
                     action: str = None, input_data: dict = None, 
                     output_data: dict = None, status: str = 'success'):
        """Log agent execution to database"""
        execution_time = time.time() - self.execution_start if self.execution_start else 0
        
        log = AgentLog(
            agent_type=self.agent_type,
            user_id=user_id,
            crop_id=crop_id,
            action=action,
            input_data=input_data,
            output_data=output_data,
            status=status,
            execution_time=execution_time
        )
        db.session.add(log)
        try:
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            print(f"Failed to log agent execution: {e}")
    
    def run(self, **kwargs) -> dict:
        """Wrapper to execute agent with logging"""
        self.execution_start = time.time()
        
        try:
            result = self.execute(**kwargs)
            self.log_execution(
                user_id=kwargs.get('user_id'),
                crop_id=kwargs.get('crop_id'),
                action=f"{self.agent_type}_executed",
                input_data=kwargs,
                output_data=result,
                status='success'
            )
            return result
        except Exception as e:
            self.log_execution(
                user_id=kwargs.get('user_id'),
                crop_id=kwargs.get('crop_id'),
                action=f"{self.agent_type}_failed",
                input_data=kwargs,
                output_data={'error': str(e)},
                status='error'
            )
            raise
