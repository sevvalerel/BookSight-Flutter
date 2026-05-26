from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import numpy as np
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="BookSight NLP Service",
    description="Türkçe kitap yorumu analizi — BERTurk tabanlı 13 etiket sınıflandırması",
    version="1.0.0"
)

# ── Sabitler ──────────────────────────────────────────────────────────────────
MODEL_PATH = "./model"  # Colab'dan indirilen model klasörü
LABELS = [
    "akici_ve_surukleyici", "psikolojik_derinlik", "duygusal_yogunluk",
    "felsefi", "toplumsal_elestiri", "tarihsel", "karamsar", "ask",
    "macera", "bilimkurgu_distopya", "gizem_polisiye", "ogretici_farkindalik", "mizah"
]

THRESHOLDS = {
    "akici_ve_surukleyici": 0.30,
    "psikolojik_derinlik":  0.45,
    "duygusal_yogunluk":    0.40,
    "felsefi":              0.45,
    "toplumsal_elestiri":   0.35,
    "tarihsel":             0.60,
    "karamsar":             0.30,
    "ask":                  0.30,
    "macera":               0.35,
    "bilimkurgu_distopya":  0.45,
    "gizem_polisiye":       0.30,
    "ogretici_farkindalik": 0.30,
    "mizah":                0.30,
}

# ── Model yükleme ─────────────────────────────────────────────────────────────
tokenizer = None
model = None
device = None

@app.on_event("startup")
async def load_model():
    global tokenizer, model, device
    logger.info("Model yükleniyor...")
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    logger.info(f"Device: {device}")
    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
    model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)
    model.to(device)
    model.eval()
    logger.info("Model hazır ✓")

# ── Şemalar ───────────────────────────────────────────────────────────────────
class AnalyzeRequest(BaseModel):
    review_id: Optional[str] = None
    text: str

class LabelResult(BaseModel):
    label: str
    confidence: float
    detected: bool

class AnalyzeResponse(BaseModel):
    review_id: Optional[str]
    labels: List[LabelResult]
    detected_labels: List[str]
    processed_at: str

class BatchRequest(BaseModel):
    reviews: List[AnalyzeRequest]

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    device: str
    timestamp: str

# ── Yardımcı fonksiyon ────────────────────────────────────────────────────────
def predict(text: str) -> List[LabelResult]:
    inputs = tokenizer(
        text,
        return_tensors="pt",
        max_length=512,
        truncation=True,
        padding=True
    )
    inputs = {k: v.to(device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.sigmoid(outputs.logits).cpu().numpy()[0]

    results = []
    for label, prob in zip(LABELS, probs):
        threshold = THRESHOLDS[label]
        results.append(LabelResult(
            label=label,
            confidence=round(float(prob), 4),
            detected=bool(prob >= threshold)
        ))
    return results

# ── Endpoint'ler ──────────────────────────────────────────────────────────────
@app.get("/api/nlp/health", response_model=HealthResponse)
async def health():
    return HealthResponse(
        status="ok",
        model_loaded=model is not None,
        device=str(device) if device else "unknown",
        timestamp=datetime.utcnow().isoformat()
    )

@app.post("/api/nlp/analyze", response_model=AnalyzeResponse)
async def analyze(req: AnalyzeRequest):
    if not model:
        raise HTTPException(status_code=503, detail="Model henüz yüklenmedi")
    if len(req.text.strip()) < 10:
        raise HTTPException(status_code=400, detail="Yorum çok kısa (min 10 karakter)")

    label_results = predict(req.text)
    detected = [r.label for r in label_results if r.detected]

    return AnalyzeResponse(
        review_id=req.review_id,
        labels=label_results,
        detected_labels=detected,
        processed_at=datetime.utcnow().isoformat()
    )

@app.post("/api/nlp/analyze/batch")
async def analyze_batch(req: BatchRequest):
    if not model:
        raise HTTPException(status_code=503, detail="Model henüz yüklenmedi")
    if len(req.reviews) > 50:
        raise HTTPException(status_code=400, detail="Batch en fazla 50 yorum")

    results = []
    for review in req.reviews:
        label_results = predict(review.text)
        detected = [r.label for r in label_results if r.detected]
        results.append(AnalyzeResponse(
            review_id=review.review_id,
            labels=label_results,
            detected_labels=detected,
            processed_at=datetime.utcnow().isoformat()
        ))
    return {"results": results, "count": len(results)}