

-- Insert records into the Categories table
INSERT INTO Categories (category_id, category_name,created_at,updated_at)
VALUES
    (1, 'Electronics',GETDATE(),GETDATE()),
    (2, 'Clothing',GETDATE(),GETDATE()),
    (3, 'Furniture',GETDATE(),GETDATE()),
    (4, 'Books',GETDATE(),GETDATE())
	
	
-- STEP 5: CREATE A WATERMARK TABLE : TO TRACK TABLE NAMES, THEIR TIMESTAMPS FOR DATA CHANGES
create table watermarktable
(
    TableName varchar(255),
    WatermarkValue datetime			-- to track the old timestamp value @ ADF Pipelines
);

INSERT INTO watermarktable VALUES ('customer_table', '1/1/2010 12:00:00 AM')
INSERT INTO watermarktable VALUES ('project_table', '1/1/2010 12:00:00 AM')

select * from watermarktable


CREATE PROCEDURE usp_write_watermark ( @LastModifiedtime datetime, @TableName sysname )
AS
BEGIN
    UPDATE watermarktable
    SET WatermarkValue = @LastModifiedtime WHERE TableName = @TableName
END


   

-- Insert records into the Customers table
INSERT INTO Customers (customer_id, first_name, last_name, email, created_at,updated_at)
VALUES
    (100, 'John', 'Doe', 'john.doe@example.com', GETDATE(),GETDATE())	

INSERT INTO Customers (customer_id, first_name, last_name, email, created_at,updated_at)
VALUES
    (200, 'Mike', 'Da', 'mike.da@example.com', GETDATE(),GETDATE())

	INSERT INTO Customers (customer_id, first_name, last_name, email, created_at,updated_at)
VALUES
    (300, 'Robert', 'Miller', 'robert.miller@example.com', GETDATE(),GETDATE())

		INSERT INTO Customers (customer_id, first_name, last_name, email, created_at,updated_at)
VALUES
    (400, 'Santa', 'Clara', 'santa.clara@example.com', GETDATE(),GETDATE())
	
	

-- Insert records into the Products table
INSERT INTO Products (product_id, product_name, description, price, stock_quantity, category_id, created_at, updated_at)
VALUES
    (1, 'Product A', 'Description of Product A', 49.99, 100, 4, GETDATE(), GETDATE())

INSERT INTO Products (product_id, product_name, description, price, stock_quantity, category_id, created_at, updated_at)
VALUES
    (2, 'Product B', 'Description of Product B', 29.99, 75, 5, GETDATE(), GETDATE())

INSERT INTO Products (product_id, product_name, description, price, stock_quantity, category_id, created_at, updated_at)
VALUES
    (3, 'Product C', 'Description of Product C', 39.99, 50, 6, GETDATE(), GETDATE())

INSERT INTO Products (product_id, product_name, description, price, stock_quantity, category_id, created_at, updated_at)
VALUES
    (4, 'Product N', 'Description of Product 4', 19.99, 200, 7, GETDATE(), GETDATE());
	
	
	-- Insert records into the Orders table
INSERT INTO Orders (order_id, customer_id, order_date, total_amount, order_status, shipping_address, created_at, updated_at)
VALUES
    (7, 100, GETDATE(), 99.99, 'Processing', '123 Main St, City, Country', GETDATE(), GETDATE()),
    (8, 200, GETDATE(), 149.99, 'Shipped', '456 Elm St, Town, Country', GETDATE(), GETDATE()),
    (9, 300, GETDATE(), 199.99, 'Delivered', '789 Oak St, Village, Country', GETDATE(), GETDATE()),
	(4, 100, GETDATE(), 99.99, 'Processing', '123 Main St, City, Country', GETDATE(), GETDATE()),
    (5, 200, GETDATE(), 149.99, 'Shipped', '456 Elm St, Town, Country', GETDATE(), GETDATE()),
    (6, 300, GETDATE(), 199.99, 'Delivered', '789 Oak St, Village, Country', GETDATE(), GETDATE())



-- Insert records into the OrderItems table
INSERT INTO OrderItems (order_item_id, order_id, product_id, quantity, subtotal, created_at, updated_at)
VALUES
    (1, 1, 1, 2, 99.98, GETDATE(), GETDATE()),
    (2, 1, 2, 1, 29.99, GETDATE(), GETDATE()),
    (3, 2, 3, 3, 149.97, GETDATE(), GETDATE()),
	(4, 1, 1, 2, 99.98, GETDATE(), GETDATE()),
    (5, 1, 2, 1, 29.99, GETDATE(), GETDATE()),
    (6, 2, 3, 3, 149.97, GETDATE(), GETDATE())
	
	
-- Insert records into the Reviews table
INSERT INTO Reviews (review_id, product_id, customer_id, rating, review_text, review_date, created_at, updated_at)
VALUES
    (1, 1, 100, 5, 'This product is excellent!', GETDATE(), GETDATE(), GETDATE()),
    (2, 2, 200, 4, 'Good product overall.', GETDATE(), GETDATE(), GETDATE()),
    (3, 1, 300, 5, 'Highly recommended.', GETDATE(), GETDATE(), GETDATE())
   
-- Insert records into the Cart table
INSERT INTO Cart (cart_id, customer_id, created_at, updated_at)
VALUES
    (1, 100, GETDATE(), GETDATE()),
    (2, 200, GETDATE(), GETDATE()),
    (3, 300, GETDATE(), GETDATE())
   
   
   -- Insert records into the CartItems table
INSERT INTO CartItems (cart_item_id, cart_id, product_id, quantity, created_at, updated_at)
VALUES
    (1, 1, 1, 2, getdate(), getdate()),
    (2, 1, 2, 1, getdate(), getdate()),
    (3, 2, 3, 3, getdate(), getdate())
	
	
	
   
   
   
	
	
	


