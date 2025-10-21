"""
Vector store integration using ChromaDB for semantic search and RAG
"""
import chromadb
from chromadb.config import Settings as ChromaSettings
from chromadb.utils import embedding_functions
from typing import List, Dict, Any, Optional
from core.config import settings
import uuid


class VectorStore:
    """Manages vector embeddings and semantic search"""

    def __init__(self):
        """Initialize ChromaDB client and collections"""
        self.client = chromadb.PersistentClient(
            path=settings.CHROMA_PERSIST_DIRECTORY,
            settings=ChromaSettings(
                anonymized_telemetry=False,
                allow_reset=True
            )
        )

        # Initialize embedding function
        self.embedding_function = embedding_functions.SentenceTransformerEmbeddingFunction(
            model_name=settings.EMBEDDING_MODEL
        )

        # Initialize collections for different data types
        self.collections = {
            "knowledge_base": self._get_or_create_collection("knowledge_base"),
            "proposals": self._get_or_create_collection("proposals"),
            "case_studies": self._get_or_create_collection("case_studies"),
            "research_insights": self._get_or_create_collection("research_insights"),
            "interactions": self._get_or_create_collection("interactions"),
        }

    def _get_or_create_collection(self, name: str):
        """Get or create a collection"""
        return self.client.get_or_create_collection(
            name=name,
            embedding_function=self.embedding_function,
            metadata={"hnsw:space": "cosine"}
        )

    async def add_document(
        self,
        collection_name: str,
        document: str,
        metadata: Dict[str, Any],
        doc_id: Optional[str] = None
    ) -> str:
        """Add a document to a collection"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]
        doc_id = doc_id or str(uuid.uuid4())

        collection.add(
            documents=[document],
            metadatas=[metadata],
            ids=[doc_id]
        )

        return doc_id

    async def add_documents(
        self,
        collection_name: str,
        documents: List[str],
        metadatas: List[Dict[str, Any]],
        doc_ids: Optional[List[str]] = None
    ) -> List[str]:
        """Add multiple documents to a collection"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]
        doc_ids = doc_ids or [str(uuid.uuid4()) for _ in documents]

        collection.add(
            documents=documents,
            metadatas=metadatas,
            ids=doc_ids
        )

        return doc_ids

    async def search(
        self,
        collection_name: str,
        query: str,
        n_results: int = 5,
        where: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Search for similar documents"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]

        results = collection.query(
            query_texts=[query],
            n_results=n_results,
            where=where
        )

        return {
            "ids": results["ids"][0] if results["ids"] else [],
            "documents": results["documents"][0] if results["documents"] else [],
            "metadatas": results["metadatas"][0] if results["metadatas"] else [],
            "distances": results["distances"][0] if results["distances"] else [],
        }

    async def get_document(
        self,
        collection_name: str,
        doc_id: str
    ) -> Optional[Dict[str, Any]]:
        """Get a specific document by ID"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]

        try:
            result = collection.get(ids=[doc_id])
            if result["ids"]:
                return {
                    "id": result["ids"][0],
                    "document": result["documents"][0],
                    "metadata": result["metadatas"][0]
                }
        except Exception:
            pass

        return None

    async def update_document(
        self,
        collection_name: str,
        doc_id: str,
        document: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ):
        """Update a document"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]

        update_params = {"ids": [doc_id]}
        if document is not None:
            update_params["documents"] = [document]
        if metadata is not None:
            update_params["metadatas"] = [metadata]

        collection.update(**update_params)

    async def delete_document(
        self,
        collection_name: str,
        doc_id: str
    ):
        """Delete a document"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]
        collection.delete(ids=[doc_id])

    async def count(self, collection_name: str) -> int:
        """Count documents in a collection"""
        if collection_name not in self.collections:
            raise ValueError(f"Collection {collection_name} not found")

        collection = self.collections[collection_name]
        return collection.count()

    def reset(self):
        """Reset all collections (use with caution)"""
        self.client.reset()


# Global vector store instance
vector_store = VectorStore()
