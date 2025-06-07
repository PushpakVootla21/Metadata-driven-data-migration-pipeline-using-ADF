1. 

CREATE TABLE CATEGORIES (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255),
	created_at DATETIME,
    updated_at DATETIME
);


-- Create the Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name NVARCHAR(255),
    last_name NVARCHAR(255),
    email NVARCHAR(255) UNIQUE,    
    created_at DATETIME,
    updated_at DATETIME
);


CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    description TEXT,
    price DECIMAL(10, 2),
    stock_quantity INT,
    category_id INT,
    created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);


-- Create the Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10, 2),
    order_status NVARCHAR(50),
    shipping_address NVARCHAR(255),
	created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);



-- Create the Order Items table
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    subtotal DECIMAL(10, 2),
	created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


-- Create the Reviews table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT,
    review_text NVARCHAR(MAX),
    review_date DATETIME,
	created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);



-- Create the Cart table
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY,
    customer_id INT,
	created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);


-- Create the Cart Items table
CREATE TABLE CartItems (
    cart_item_id INT PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT,
	created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);














