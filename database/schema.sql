-- ==================== ТАБЛИЦА ПОЛЬЗОВАТЕЛЕЙ ====================

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    weight DECIMAL(5,2), -- вес в кг
    height INTEGER, -- рост в см
    age INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==================== ТАБЛИЦА ПРОДУКТОВ И ЦЕН ====================

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100), -- овощи, фрукты, мясо, и т.д.
    base_price DECIMAL(8,2) NOT NULL, -- базовая цена
    unit VARCHAR(50) NOT NULL, -- кг, гр, шт, литр
    calories_per_unit DECIMAL(8,2), -- калории на единицу
    protein_per_unit DECIMAL(8,2), -- белки
    fat_per_unit DECIMAL(8,2), -- жиры
    carbs_per_unit DECIMAL(8,2), -- углеводы
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== ТАБЛИЦЫ РЕЦЕПТОВ ====================

CREATE TABLE recipes (
    recipe_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    recipe_name VARCHAR(255) NOT NULL,
    description TEXT,
    cooking_time INTEGER, -- время в минутах
    difficulty_level ENUM('easy', 'medium', 'hard'),
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Состав рецептов 
CREATE TABLE recipe_ingredients (
    ingredient_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    recipe_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity DECIMAL(8,2) NOT NULL, -- количество
    required BOOLEAN DEFAULT TRUE, -- обязательный ингредиент
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_recipe_product (recipe_id, product_id)
);

-- Пищевая ценность рецептов (расчетная)
CREATE TABLE recipe_nutrition (
    nutrition_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    recipe_id INTEGER NOT NULL UNIQUE,
    total_calories DECIMAL(8,2) NOT NULL,
    total_protein DECIMAL(8,2) NOT NULL,
    total_fat DECIMAL(8,2) NOT NULL,
    total_carbs DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE
);

-- ==================== ТАБЛИЦЫ СОХРАНЕННЫХ ПЛАНОВ ====================

CREATE TABLE meal_plans (
    plan_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    plan_name VARCHAR(255) NOT NULL,
    goal_type ENUM('weight_loss', 'weight_gain', 'healthy_diet') NOT NULL,
    weekly_budget DECIMAL(8,2) NOT NULL,
    total_calories DECIMAL(8,2),
    total_cost DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Дни плана питания
CREATE TABLE plan_days (
    day_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    plan_id INTEGER NOT NULL,
    day_number INTEGER NOT NULL, -- 1-7 (понедельник-воскресенье)
    total_day_calories DECIMAL(8,2),
    total_day_cost DECIMAL(8,2),
    FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id) ON DELETE CASCADE,
    UNIQUE KEY unique_plan_day (plan_id, day_number)
);

-- Приемы пищи в днях
CREATE TABLE plan_meals (
    meal_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    day_id INTEGER NOT NULL,
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
    recipe_id INTEGER NOT NULL,
    calories DECIMAL(8,2),
    cost DECIMAL(8,2),
    FOREIGN KEY (day_id) REFERENCES plan_days(day_id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);

-- ==================== ТАБЛИЦЫ ПРЕДПОЧТЕНИЙ ПОЛЬЗОВАТЕЛЕЙ ====================

-- Аллергии и запрещенные продукты
CREATE TABLE user_allergies (
    allergy_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    severity ENUM('mild', 'moderate', 'severe') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_user_allergy (user_id, product_id)
);

-- Предпочтения продуктов (нравится/не нравится)
CREATE TABLE user_preferences (
    preference_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    preference_type ENUM('like', 'dislike') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_user_preference (user_id, product_id)
);

-- ==================== ТАБЛИЦЫ ДЛЯ LLM ВЗАИМОДЕЙСТВИЙ ====================

CREATE TABLE llm_interactions (
    interaction_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER,
    plan_id INTEGER,
    prompt_type ENUM('plan_generation', 'recipe_suggestion', 'modification') NOT NULL,
    user_input TEXT NOT NULL, -- входные данные пользователя
    llm_response JSON NOT NULL, -- структурированный ответ LLM
    model_used VARCHAR(100),
    tokens_used INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id)
);
-- Пример запроса
INSERT INTO LLMInteractions (
    id_user, 
    id_plan,
    prompt_text, 
    response_text,
    interaction_type,
    tokens_used
) VALUES (
    123,
    456,
    'Сгенерируй план питания на 7 дней: цель - похудение, бюджет - 5000 руб, аллергии - орехи, предпочтения - курица, овощи',
    '{"plan": "7-дневный план...", "recipes": [...], "shopping_list": [...]}',
    'plan_generation',
    1250
);

-- ==================== ТАБЛИЦА СПИСКОВ ПОКУПОК ====================

CREATE TABLE shopping_lists (
    list_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    plan_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    total_estimated_cost DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Элементы списка покупок
CREATE TABLE shopping_list_items (
    item_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    list_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity_needed DECIMAL(8,2) NOT NULL,
    estimated_cost DECIMAL(8,2),
    purchased BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (list_id) REFERENCES shopping_lists(list_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ==================== ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ ====================

-- Индексы для пользователей
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Индексы для продуктов
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(base_price);

-- Индексы для рецептов
CREATE INDEX idx_recipes_name ON recipes(recipe_name);
CREATE INDEX idx_recipes_meal_type ON recipes(meal_type);
CREATE INDEX idx_recipes_difficulty ON recipes(difficulty_level);

-- Индексы для планов питания
CREATE INDEX idx_plans_user ON meal_plans(user_id);
CREATE INDEX idx_plans_goal ON meal_plans(goal_type);
CREATE INDEX idx_plans_created ON meal_plans(created_at);

-- Индексы для дней и приемов пищи
CREATE INDEX idx_days_plan ON plan_days(plan_id);
CREATE INDEX idx_meals_day ON plan_meals(day_id);
CREATE INDEX idx_meals_type ON plan_meals(meal_type);

-- Индексы для предпочтений
CREATE INDEX idx_allergies_user ON user_allergies(user_id);
CREATE INDEX idx_preferences_user ON user_preferences(user_id);

-- Индексы для LLM
CREATE INDEX idx_llm_user ON llm_interactions(user_id);
CREATE INDEX idx_llm_plan ON llm_interactions(plan_id);
CREATE INDEX idx_llm_created ON llm_interactions(created_at);

-- Индексы для списков покупок
CREATE INDEX idx_shopping_plan ON shopping_lists(plan_id);
CREATE INDEX idx_shopping_user ON shopping_lists(user_id);
CREATE INDEX idx_items_list ON shopping_list_items(list_id);
CREATE INDEX idx_items_product ON shopping_list_items(product_id);

