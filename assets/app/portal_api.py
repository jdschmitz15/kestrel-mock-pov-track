"""Kestrel Point Portal API. Runs on kp-papp01/02 in AWS and reads from RDS Postgres."""
import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)


def conn():
    return psycopg2.connect(host=os.environ["PORTAL_DB_HOST"], dbname="portal", user="portal",
                            password=os.environ["PORTAL_DB_PASSWORD"], connect_timeout=5)


@app.get("/")
def index():
    try:
        with conn() as c, c.cursor() as cur:
            cur.execute("CREATE TABLE IF NOT EXISTS visits (id serial PRIMARY KEY, at timestamptz DEFAULT now())")
            cur.execute("INSERT INTO visits DEFAULT VALUES RETURNING id")
            visit = cur.fetchone()[0]
        return jsonify(app="portal", db="ok", visit=visit, server=os.uname().nodename)
    except Exception as exc:
        return jsonify(app="portal", db="error", error=str(exc)), 503


@app.get("/health")
def health():
    return "ok"
