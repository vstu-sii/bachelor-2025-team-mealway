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

-- ==================== ТАБЛИЦА СЕССИЙ ====================

CREATE TABLE user_sessions (
    session_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==================== ТАБЛИЦЫ РЕЦЕПТОВ ====================

CREATE TABLE recipes (
    recipe_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    recipe_name VARCHAR(255) NOT NULL,
    description TEXT,
    cooking_time INTEGER, -- время в минутах
    difficulty_level ENUM('easy', 'medium', 'hard'),
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    calculated_cost DECIMAL(8,2), -- расчетная стоимость
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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

-- ==================== ТАБЛИЦА СПИСКОВ ПОКУПОК ====================

CREATE TABLE shopping_lists (
    list_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    plan_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    total_estimated_cost DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Элементы списка покупок с полными ценами
CREATE TABLE shopping_list_items (
    item_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    list_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity_needed DECIMAL(8,2) NOT NULL,
    unit_price DECIMAL(8,2), -- цена за единицу
    total_price DECIMAL(8,2), -- общая цена (quantity * unit_price)
    estimated_cost DECIMAL(8,2), -- для обратной совместимости
    purchased BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (list_id) REFERENCES shopping_lists(list_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ==================== ФУНКЦИИ И ТРИГГЕРЫ ====================

-- Функция для расчета стоимости рецепта
DELIMITER //
CREATE FUNCTION calculate_recipe_cost(recipe_id_param INT) 
RETURNS DECIMAL(8,2)
READS SQL DATA
BEGIN
    DECLARE total_cost DECIMAL(8,2) DEFAULT 0;
    
    SELECT SUM(ri.quantity * p.base_price) INTO total_cost
    FROM recipe_ingredients ri
    JOIN products p ON ri.product_id = p.product_id
    WHERE ri.recipe_id = recipe_id_param;
    
    RETURN COALESCE(total_cost, 0);
END//
DELIMITER ;

-- Триггер для обновления стоимости рецепта при изменении ингредиентов
DELIMITER //
CREATE TRIGGER update_recipe_cost_on_ingredient_change
AFTER INSERT ON recipe_ingredients
FOR EACH ROW
BEGIN
    UPDATE recipes 
    SET calculated_cost = calculate_recipe_cost(NEW.recipe_id),
        updated_at = CURRENT_TIMESTAMP
    WHERE recipe_id = NEW.recipe_id;
END//
DELIMITER ;

-- Триггер для установки цен в списке покупок
DELIMITER //
CREATE TRIGGER set_shopping_item_prices
BEFORE INSERT ON shopping_list_items
FOR EACH ROW
BEGIN
    DECLARE product_price DECIMAL(8,2);
    
    SELECT base_price INTO product_price 
    FROM products 
    WHERE product_id = NEW.product_id;
    
    SET NEW.unit_price = product_price;
    SET NEW.total_price = NEW.quantity_needed * product_price;
    SET NEW.estimated_cost = NEW.total_price;
END//
DELIMITER ;

-- Триггер для обновления общей стоимости списка покупок
DELIMITER //
CREATE TRIGGER update_shopping_list_total
AFTER INSERT ON shopping_list_items
FOR EACH ROW
BEGIN
    UPDATE shopping_lists 
    SET total_estimated_cost = (
        SELECT SUM(total_price) 
        FROM shopping_list_items 
        WHERE list_id = NEW.list_id
    ),
    updated_at = CURRENT_TIMESTAMP
    WHERE list_id = NEW.list_id;
END//
DELIMITER ;

-- ==================== ПРЕДСТАВЛЕНИЯ ====================

-- Представление для стоимости рецептов
CREATE VIEW recipe_costs AS
SELECT 
    r.recipe_id,
    r.recipe_name,
    r.calculated_cost as total_cost,
    rn.total_calories,
    r.meal_type,
    r.difficulty_level
FROM recipes r
JOIN recipe_nutrition rn ON r.recipe_id = rn.recipe_id;

-- Представление для детализированного списка покупок
CREATE VIEW shopping_list_details AS
SELECT 
    sl.list_id,
    sl.plan_id,
    sl.user_id,
    sl.total_estimated_cost,
    sl.created_at,
    sli.item_id,
    sli.product_id,
    p.product_name,
    p.category,
    sli.quantity_needed,
    p.unit,
    sli.unit_price,
    sli.total_price,
    sli.purchased
FROM shopping_lists sl
JOIN shopping_list_items sli ON sl.list_id = sli.list_id
JOIN products p ON sli.product_id = p.product_id;

-- Представление для сводки плана питания
CREATE VIEW plan_summary AS
SELECT 
    mp.plan_id,
    mp.user_id,
    mp.plan_name,
    mp.weekly_budget,
    mp.total_cost as actual_cost,
    CASE 
        WHEN mp.total_cost <= mp.weekly_budget THEN 'within_budget'
        ELSE 'over_budget'
    END as budget_status,
    mp.weekly_budget - mp.total_cost as budget_difference
FROM meal_plans mp;

-- ==================== ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ ====================

-- Индексы для пользователей
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Индексы для сессий
CREATE INDEX idx_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);
CREATE INDEX idx_sessions_active ON user_sessions(is_active);

-- Индексы для продуктов
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(base_price);

-- Индексы для рецептов
CREATE INDEX idx_recipes_name ON recipes(recipe_name);
CREATE INDEX idx_recipes_meal_type ON recipes(meal_type);
CREATE INDEX idx_recipes_difficulty ON recipes(difficulty_level);
CREATE INDEX idx_recipes_cost ON recipes(calculated_cost);

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
CREATE INDEX idx_items_purchased ON shopping_list_items(purchased);

-- ==================== ПРОЦЕДУРЫ ДЛЯ РАБОТЫ С СЕССИЯМИ ====================

DELIMITER //
CREATE PROCEDURE CreateUserSession(
    IN p_user_id INT,
    IN p_session_token VARCHAR(255),
    IN p_duration_days INT
)
BEGIN
    DECLARE expires_time TIMESTAMP;
    
    SET expires_time = DATE_ADD(NOW(), INTERVAL p_duration_days DAY);
    
    INSERT INTO user_sessions (user_id, session_token, expires_at)
    VALUES (p_user_id, p_session_token, expires_time);
    
    SELECT session_token, expires_at FROM user_sessions 
    WHERE session_id = LAST_INSERT_ID();
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ValidateSession(IN p_session_token VARCHAR(255))
BEGIN
    UPDATE user_sessions 
    SET last_activity = CURRENT_TIMESTAMP
    WHERE session_token = p_session_token 
    AND expires_at > NOW() 
    AND is_active = TRUE;
    
    SELECT us.user_id, u.username, u.email, us.expires_at
    FROM user_sessions us
    JOIN users u ON us.user_id = u.user_id
    WHERE us.session_token = p_session_token 
    AND us.expires_at > NOW() 
    AND us.is_active = TRUE;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CleanExpiredSessions()
BEGIN
    UPDATE user_sessions 
    SET is_active = FALSE 
    WHERE expires_at <= NOW();
END//
DELIMITER ;
