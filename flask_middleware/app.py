from flask import Flask, jsonify, request, make_response
import requests
from flask_cors import CORS


app = Flask(__name__)
CORS(app, supports_credentials=True, resources={r"/*": {"origins": ["http://localhost", "http://localhost:80"]}})

CODEIGNITER_API_BASE = "http://localhost/Counselign/public/index.php"


def build_codeigniter_cookies(codeigniter_response):
    forwarded_cookies = {}

    for cookie in codeigniter_response.cookies:
        forwarded_cookies[cookie.name] = cookie.value

    return forwarded_cookies


def json_proxy_get(endpoint, params=None):
    try:
        codeigniter_response = requests.get(
            f"{CODEIGNITER_API_BASE}{endpoint}",
            params=params or {},
            cookies=request.cookies,
            headers={
                "Accept": "application/json",
                "X-Requested-With": "XMLHttpRequest",
            },
            timeout=30,
        )

        # Check if response is JSON
        if 'application/json' in codeigniter_response.headers.get('content-type', ''):
            try:
                payload = codeigniter_response.json()
            except ValueError:
                # Not valid JSON, return error
                payload = {
                    "success": False,
                    "message": "Invalid JSON response from CodeIgniter",
                    "raw_response": codeigniter_response.text[:500]  # First 500 chars
                }
        else:
            # Not JSON response, return error
            payload = {
                "success": False,
                "message": f"Non-JSON response from CodeIgniter (status: {codeigniter_response.status_code})",
                "content_type": codeigniter_response.headers.get('content-type'),
                "raw_response": codeigniter_response.text[:500]  # First 500 chars
            }

        response = make_response(jsonify(payload), codeigniter_response.status_code)

        for name, value in build_codeigniter_cookies(codeigniter_response).items():
            response.set_cookie(name, value, httponly=True, samesite="Lax")

        return response
    except requests.RequestException as e:
        return jsonify({
            "success": False,
            "message": f"Request failed: {str(e)}"
        }), 500
    except Exception as e:
        return jsonify({
            "success": False,
            "message": f"Unexpected error: {str(e)}"
        }), 500


@app.get("/health")
def health_check():
    return jsonify(
        {
            "status": "ok",
            "service": "flask-middleware",
            "codeigniter_api": CODEIGNITER_API_BASE,
        }
    )


@app.route("/health", methods=["OPTIONS"])
def health_check_options():
    return ("", 204)


@app.get("/api/admin/appointments")
def admin_appointments():
    time_range = request.args.get("timeRange", "weekly")

    return json_proxy_get(
        "/admin/appointments/get_all_appointments",
        {"timeRange": time_range},
    )


@app.get("/api/admin/session-check")
def admin_session_check():
    return json_proxy_get("/admin/session/check")


@app.route("/api/admin/appointments", methods=["OPTIONS"])
def admin_appointments_options():
    return ("", 204)


@app.route("/api/admin/session-check", methods=["OPTIONS"])
def admin_session_check_options():
    return ("", 204)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
