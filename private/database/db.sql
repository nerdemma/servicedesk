-- base de datos servicedesk
-- creado por Emmanuel Breyaue @nerdemma

CREATE DATABASE IF NOT EXIST servicedesk

-- cuentas de usuario
CREATE TABLE IF NOT EXIST users
(
id INT AUTO_INCREMENT PRIMARY_KEY,
username VARCHAR(50) NOT NULL UNIQUE,
email VARCHAR(100) NOT NULL UNIQUE,
password VARCHAR(255) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- tickets
CREATE TABLE IF NOT EXIST tickets
(
id INT AUTO_INCREMENT PRIMARY_KEY,
user_id INT NOT NULL,
title VARCHAR(100) NOT NULL,
description TEXT NOT NULL,
status VARCHAR(20) DEFAULT 'open',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

--- comentarios de los tickets
CREATE TABLE IF NOT EXIST comments
(
id INT AUTO_INCREMENT PRIMARY_KEY,
ticket_id INT NOT NULL,
user_id INT NOT NULL,
comment TEXT NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
);

-- archivos adjuntos (pdf, imagenes, logs, etc)
CREATE TABLE IF NOT EXIST attachments
(
id INT AUTO_INCREMENT PRIMARY_KEY,
ticket_id INT NOT NULL,
file_path VARCHAR(255) NOT NULL,
uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE
);  

-- categorias
CREATE TABLE IF NOT EXIST categories
(
id INT AUTO_INCREMENT PRIMARY_KEY,
name VARCHAR(50) NOT NULL UNIQUE,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);  

-- relacion tickets-categorias (muchos a muchos)
CREATE TABLE IF NOT EXIST ticket_categories
(
ticket_id INT NOT NULL,
category_id INT NOT NULL,
PRIMARY KEY (ticket_id, category_id),  
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
); 

-- prioridades
CREATE TABLE IF NOT EXIST priorities
(
id INT AUTO_INCREMENT PRIMARY_KEY,
name VARCHAR(50) NOT NULL UNIQUE,
level INT NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);  

-- relacion tickets-prioridades (muchos a muchos)
CREATE TABLE IF NOT EXIST ticket_priorities
(
ticket_id INT NOT NULL,
priority_id INT NOT NULL,
PRIMARY KEY (ticket_id, priority_id),  
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (priority_id) REFERENCES priorities(id) ON DELETE CASCADE,
);   

-- agentes
CREATE TABLE IF NOT EXIST agents
(
id INT AUTO_INCREMENT PRIMARY_KEY,
user_id INT NOT NULL,
assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- relacion tickets-agentes (muchos a muchos)
CREATE TABLE IF NOT EXIST ticket_agents
(
ticket_id INT NOT NULL,
agent_id INT NOT NULL,
PRIMARY KEY (ticket_id, agent_id), 
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE
);

-- acuerdos de nivel de servicio (SLA)
CREATE TABLE IF NOT EXIST sla_policies
(
id INT AUTO_INCREMENT PRIMARY_KEY,
name VARCHAR(100) NOT NULL UNIQUE,
response_time INT NOT NULL, 
resolution_time INT NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- relacion tickets-sla (muchos a muchos)
CREATE TABLE IF NOT EXIST ticket_sla
(
ticket_id INT NOT NULL,
sla_id INT NOT NULL,
PRIMARY KEY (ticket_id, sla_id),  
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (sla_id) REFERENCES sla_policies(id) ON DELETE CASCADE
);

-- logs de actividad
CREATE TABLE IF NOT EXIST activity_logs
(
id INT AUTO_INCREMENT PRIMARY_KEY,
user_id INT NOT NULL,
action VARCHAR(255) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- notificaciones
CREATE TABLE IF NOT EXIST notifications
(
id INT AUTO_INCREMENT PRIMARY_KEY,
user_id INT NOT NULL,
message VARCHAR(255) NOT NULL,
is_read BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- etiquetas
CREATE TABLE IF NOT EXIST tags
(
id INT AUTO_INCREMENT PRIMARY_KEY,
name VARCHAR(50) NOT NULL UNIQUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);  

-- relacion tickets-etiquetas (muchos a muchos)
CREATE TABLE IF NOT EXIST ticket_tags
(
ticket_id INT NOT NULL,
tag_id INT NOT NULL,
PRIMARY KEY (ticket_id, tag_id),
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- feedback de los usuarios sobre la resolución del ticket
CREATE TABLE IF NOT EXIST feedback
(
id INT AUTO_INCREMENT PRIMARY_KEY,
ticket_id INT NOT NULL,
user_id INT NOT NULL,
rating INT NOT NULL,
comments TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
    
-- clientes
CREATE TABLE IF NOT EXISTS customers (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
	company VARCHAR(200),
	tax_id VARCHAR(100),
	website VARCHAR(200),
	email VARCHAR(150),
	phone VARCHAR(50),
	created_by INT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	notes TEXT,
	FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);
-- contactos
CREATE TABLE IF NOT EXISTS contacts (
	id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT NOT NULL,
	first_name VARCHAR(100),
	last_name VARCHAR(100),
	email VARCHAR(150),
	phone VARCHAR(50),
	role VARCHAR(100),
	is_primary BOOLEAN DEFAULT FALSE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- direcciones
CREATE TABLE IF NOT EXISTS customer_addresses (
	id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT NOT NULL,
	type VARCHAR(50) DEFAULT 'billing',
	address1 VARCHAR(255),
	address2 VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	postal_code VARCHAR(50),
	country VARCHAR(100),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- activos
CREATE TABLE IF NOT EXISTS assets (
	id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT NOT NULL,
	-- imei, para los telefonos moviles
    serial_number VARCHAR(200),
	model VARCHAR(200),
	-- generico por defecto
    brand VARCHAR(200) DEFAULT 'Generica',
	purchase_date DATE,
	-- 5 años a partir de la fecha de compra
    warranty_until DATE,
	status VARCHAR(50),
	notes TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- servicios
CREATE TABLE IF NOT EXISTS services (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
	description TEXT,
	sku VARCHAR(100),
	unit_price DECIMAL(12,2) DEFAULT 0.00,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- cotizaciones
CREATE TABLE IF NOT EXISTS quotes (
	id INT AUTO_INCREMENT PRIMARY KEY,
	quote_number VARCHAR(50) NOT NULL UNIQUE,
	customer_id INT NOT NULL,
	ticket_id INT DEFAULT NULL,
	status ENUM('draft','sent','accepted','rejected','cancelled') DEFAULT 'draft',
	subtotal DECIMAL(12,2) DEFAULT 0.00,
	tax DECIMAL(12,2) DEFAULT 0.00,
	total DECIMAL(12,2) DEFAULT 0.00,
	currency VARCHAR(10) DEFAULT 'USD',
	valid_until DATE DEFAULT NULL,
	created_by INT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	notes TEXT,
	FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
	FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE SET NULL,
	FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);
-- items de la cotización
CREATE TABLE IF NOT EXISTS quote_items (
	id INT AUTO_INCREMENT PRIMARY KEY,
	quote_id INT NOT NULL,
	service_id INT DEFAULT NULL,
	description TEXT,
	quantity INT DEFAULT 1,
	unit_price DECIMAL(12,2) DEFAULT 0.00,
	line_total DECIMAL(12,2) DEFAULT 0.00,
	FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE,
	FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL
);
-- notas del cliente
CREATE TABLE IF NOT EXISTS customer_notes (
	id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT NOT NULL,
	user_id INT NULL,
	note_type VARCHAR(50),
	subject VARCHAR(200),
	body TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Índices sugeridos para consultas frecuentes
CREATE INDEX IF NOT EXISTS idx_customers_created_by ON customers(created_by);
CREATE INDEX IF NOT EXISTS idx_contacts_customer ON contacts(customer_id);
CREATE INDEX IF NOT EXISTS idx_assets_customer ON assets(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotes_customer ON quotes(customer_id);
CREATE INDEX IF NOT EXISTS idx_quoteitems_quote ON quote_items(quote_id);

-- Nota: si desea enlazar tickets con clientes de forma directa, puede añadir
-- ALTER TABLE tickets ADD COLUMN customer_id INT NULL; y luego un FK hacia customers(id)
-- (hacerlo con precaución si la tabla ya contiene datos).
