#!/usr/bin/env python3
"""
Simple Flask API for Network Learning Lab
Demonstrates service-to-service communication and database connectivity
"""

import os
import socket
from flask import Flask, jsonify, request

app = Flask(__name__)

# Database configuration from environment
DB_CONFIG = {
    'host': os.environ.get('DATABASE_HOST', 'database'),
    'port': os.environ.get('DATABASE_PORT', '5432'),
    'name': os.environ.get('DATABASE_NAME', 'labdb'),
    'user': os.environ.get('DATABASE_USER', 'labuser'),
}


@app.route('/')
def index():
    """Root endpoint with API information"""
    return jsonify({
        'service': 'Network Lab API',
        'version': '1.0.0',
        'hostname': socket.gethostname(),
        'endpoints': {
            '/': 'This help message',
            '/health': 'Health check endpoint',
            '/info': 'Container network information',
            '/echo': 'Echo back request details',
            '/db/status': 'Database connectivity check',
        }
    })


@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'hostname': socket.gethostname()
    })


@app.route('/info')
def info():
    """Return network information about this container"""
    hostname = socket.gethostname()

    # Get all IP addresses
    ips = []
    try:
        # Get IPs for all interfaces
        import subprocess
        result = subprocess.run(
            ['hostname', '-I'],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            ips = result.stdout.strip().split()
    except Exception:
        # Fallback to socket method
        try:
            ips = [socket.gethostbyname(hostname)]
        except socket.gaierror:
            ips = ['unknown']

    return jsonify({
        'hostname': hostname,
        'ip_addresses': ips,
        'database_config': {
            'host': DB_CONFIG['host'],
            'port': DB_CONFIG['port'],
            'database': DB_CONFIG['name'],
        }
    })


@app.route('/echo', methods=['GET', 'POST'])
def echo():
    """Echo back request information - useful for debugging"""
    return jsonify({
        'method': request.method,
        'path': request.path,
        'headers': dict(request.headers),
        'args': dict(request.args),
        'remote_addr': request.remote_addr,
        'host': request.host,
    })


@app.route('/db/status')
def db_status():
    """Check database connectivity"""
    try:
        import psycopg2
        conn = psycopg2.connect(
            host=DB_CONFIG['host'],
            port=DB_CONFIG['port'],
            dbname=DB_CONFIG['name'],
            user=DB_CONFIG['user'],
            password=os.environ.get('DATABASE_PASSWORD', ''),
            connect_timeout=5
        )
        conn.close()
        return jsonify({
            'status': 'connected',
            'database': DB_CONFIG['name'],
            'host': DB_CONFIG['host']
        })
    except ImportError:
        return jsonify({
            'status': 'unavailable',
            'error': 'psycopg2 not installed',
            'note': 'Database connectivity demo requires psycopg2'
        }), 503
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e),
            'host': DB_CONFIG['host']
        }), 503


@app.route('/resolve/<hostname>')
def resolve(hostname):
    """Resolve a hostname to IP address"""
    try:
        ip = socket.gethostbyname(hostname)
        return jsonify({
            'hostname': hostname,
            'ip': ip,
            'resolved': True
        })
    except socket.gaierror as e:
        return jsonify({
            'hostname': hostname,
            'resolved': False,
            'error': str(e)
        }), 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
