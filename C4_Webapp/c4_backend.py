from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

def get_db_connection():
    conn = sqlite3.connect('c4_server.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/api/status/<component>', methods=['GET'])
def get_status(component):
    # Example to fetch status from the database
    conn = get_db_connection()
    status = conn.execute('SELECT status FROM server_components WHERE name = ?', (component,)).fetchone()
    conn.close()

    if status:
        return jsonify({'status': status['status']})
    else:
        return jsonify({'status': 'Unknown'}), 404

@app.route('/api/configure', methods=['POST'])
def configure_server():
    data = request.form
    server_ip = data.get('server_ip')
    apache_port = data.get('apache_port')
    mysql_port = data.get('mysql_port')

    # Update the server configuration in the database (Example)
    conn = get_db_connection()
    conn.execute('UPDATE server_components SET ip_address = ?, port = ? WHERE name = "Apache"', (server_ip, apache_port))
    conn.execute('UPDATE server_components SET ip_address = ?, port = ? WHERE name = "MySQL"', (server_ip, mysql_port))
    conn.commit()
    conn.close()

    return jsonify({'status': 'Configuration updated'})

@app.route('/api/connections', methods=['GET'])
def get_connections():
    conn = get_db_connection()
    connections = conn.execute('SELECT sc.name AS component_name, a.agent_name, c.status '
                               'FROM connections c '
                               'JOIN server_components sc ON c.component_id = sc.id '
                               'JOIN agents a ON c.agent_id = a.id').fetchall()
    conn.close()

    return jsonify([dict(row) for row in connections])

if __name__ == '__main__':
    app.run(debug=True)
