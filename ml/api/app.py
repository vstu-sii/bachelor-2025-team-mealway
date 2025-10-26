import os
from flask import Flask, request, jsonify
from models.baseline import Model, DB
from thread import Lock

app = Flask(__name__)

def get_env_or( env_name, default_value ):
    try:
        env = os.environ[env_name]
    except:
        pass
    if not env:
        return default_value
    
m = Model( get_env_or("MEALWAY_MODEL", "LiquidAI/LFM2-1.2B"), None )
m.db = DB(m)
mLock = Lock()

@app.route('/generate_meal_plan', methods=['POST'])
def meal_plan():
    data = request.get_json()
    forbidden_products = data.get('forbidden_products', [])
    available_products = data.get('available_products', [])
    target_calories = data.get('target_calories', 'medium')
    mLock.acquire()
    plan = m.gen_meal_plan( forbidden_products, available_products, target_calories)
    mLock.release()
    return jsonify(plan)

@app.route('/generate_recipe', methods=['POST'])
def recipe():
    data = request.get_json()
    product = data.get('product')
    forbidden_products = data.get('forbidden_products', [])
    mLock.acquire()
    recipe_text = m.gen_receipt( product, forbidden_products )
    mLock.release()
    return jsonify({"recipe": recipe_text})

@app.route('/generate_shopping_list', methods=['POST'])
def shopping_list():
    data = request.get_json()
    dishes = data.get('dishes', [])
    forbidden_products = data.get('forbidden_products', [])
    
    shopping_list = []
    for dish in dishes:
      mLock.acquire()
      sl = m.gen_shopping_list( dish, forbidden_products)
      mLock.release()
      shopping_list += sl
    shopping_list = list(set(shopping_list))
    return jsonify({"shopping_list": shopping_list})

def get_host():
  return get_env_or('MEALWAY_HOST', '0.0.0.0')

def get_port():
  try:
    port = int( os.environ['MEALWAY_PORT'] )
  except:
    port = 0
  if port < 80:
    port = 5000
  return port

if __name__ == '__main__':
    app.run(host=get_host(), port=get_port())
