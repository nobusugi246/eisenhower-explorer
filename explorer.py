import json
import os
from flask import Flask, jsonify, render_template, request
import subprocess


class CustomFlask(Flask):
    jinja_options = Flask.jinja_options.copy()
    jinja_options.update(dict(
        block_start_string='(%',
        block_end_string='%)',
        variable_start_string='((',
        variable_end_string='))',
        comment_start_string='(#',
        comment_end_string='#)',
    ))


app = CustomFlask(__name__)

current_dir = os.path.dirname(os.path.abspath(__file__))


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/find', methods=['POST'])
def find():
    json_data = json.loads(request.data, encoding='utf-8')
    path_name = os.path.abspath(json_data['path_name'])
    # app.logger.info(path_name)

    contents = []
    status = 'ok'
    try:
        cur = sorted(os.listdir(path_name))
        contents = [ {'size': os.stat(os.path.join(path_name, x)).st_size,
                      'name': x, 'isfile': os.path.isfile(os.path.join(path_name, x)) } for x in cur ]
    except PermissionError:
        status = 'PermissionError'
        app.logger.info('PermissionError at ' + path_name)

    # app.logger.info(contents)
    return jsonify({'current': path_name, 'contents': contents, 'status': status})


@app.route('/open', methods=['POST'])
def open():
    status = 'done: '

    json_data = json.loads(request.data, encoding='utf-8')
    path_name = json_data['path_name']
    if path_name == '':
        return

    try:
        path_name = os.path.abspath(json_data['path_name'])
    except KeyError:
        return ''
    app.logger.info(path_name)

    if os.name == 'nt':
        result = subprocess.run(['explorer', path_name])
    else:
        result = subprocess.run(['open', path_name])
        
    # app.logger.info(result)
    return jsonify( { 'status': status + str(result.returncode) } )


@app.route('/size', methods=['POST'])
def get_size():
    json_data = json.loads(request.data, encoding='utf-8')
    start_path = os.path.abspath(json_data['path_name'])
    list_name = json_data['list_name']
    lindex = json_data['index']
    app.logger.info("get_size: " + start_path)
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(start_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            total_size += (os.path.getsize(fp) if os.path.isfile(fp) else 0)
    return jsonify( { 'size': total_size, 'list_name': list_name, 'index': lindex} )


if __name__ == "__main__":
    app.run(debug=True, threaded=False)
