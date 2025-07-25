from abc import ABC, abstractmethod
from typing import Dict, List, Any


class ManagedPrivateEndpointManager(ABC):
    @abstractmethod
    def get(self, private_endpoint_name: str) -> Dict[str, Any]:
        """
            Get the specified managed private endpoint for the underlying resource
        """
        pass

    @abstractmethod
    def get_all(self) -> List[Dict[str, Any]]:
        """
            Get all managed private endpoints associated with the underlying resource
        """
        pass
