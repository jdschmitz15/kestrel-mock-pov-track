"""Kestrel Point Claims API. Runs on kp-web01 behind nginx and reads from SQL Express on kp-sql01."""
import os
import pymssql
from flask import Flask, jsonify

app = Flask(__name__)
DB = dict(server=os.environ.get("CLAIMS_DB_HOST", "kp-sql01"), port=1433,
          user="kpapp", password=os.environ.get("CLAIMS_DB_PASSWORD", "Kestrel-Claims-2026!"),
          database="claims", login_timeout=5, timeout=5)


@app.get("/")
def index():
    try:
        with pymssql.connect(**DB) as conn, conn.cursor(as_dict=True) as cur:
            cur.execute("SELECT TOP 10 claim_id, policy, status, amount FROM claims ORDER BY claim_id DESC")
            rows = cur.fetchall()
        for r in rows:
            r["amount"] = float(r["amount"])
        return jsonify(app="claims", db="ok", claims=rows)
    except Exception as exc:  # the page still answers so the learner can see the DB is down
        return jsonify(app="claims", db="error", error=str(exc)), 503


@app.get("/health")
def health():
    return "ok"
