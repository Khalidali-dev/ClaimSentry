import json
import os
import sys

# Ensure project root is in sys.path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from api.index import app, handler
from mangum import Mangum


def test_serverless_handler_instance():
    assert isinstance(handler, Mangum)
    assert app.title == "ClaimSentry"


def test_serverless_health_endpoint():
    event = {
        "version": "2.0",
        "routeKey": "GET /api/health",
        "rawPath": "/api/health",
        "rawQueryString": "",
        "headers": {"host": "claimsentry.vercel.app", "accept": "application/json"},
        "requestContext": {
            "http": {
                "method": "GET",
                "path": "/api/health",
                "protocol": "HTTP/1.1",
                "sourceIp": "127.0.0.1",
            }
        },
        "isBase64Encoded": False,
    }

    class Context:
        pass

    response = handler(event, Context())
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["status"] == "healthy"
    assert body["backend"] == "ClaimSentry Backend is online"


def test_serverless_root_endpoint():
    event = {
        "version": "2.0",
        "routeKey": "GET /api",
        "rawPath": "/api",
        "rawQueryString": "",
        "headers": {"host": "claimsentry.vercel.app", "accept": "application/json"},
        "requestContext": {
            "http": {
                "method": "GET",
                "path": "/api",
                "protocol": "HTTP/1.1",
                "sourceIp": "127.0.0.1",
            }
        },
        "isBase64Encoded": False,
    }

    class Context:
        pass

    response = handler(event, Context())
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["status"] == "ClaimSentry Backend is online"
    assert body["service"] == "ClaimSentry"
