import sqlite3

DB_PATH = "users.db"  # Make sure this matches the DB_PATH in your Flask app

def create_users_table():
    """Creates the users table in the SQLite database if it doesn't exist."""
    conn = None
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # SQL statement to create the table
        # Using IF NOT EXISTS to prevent errors if the table already exists
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL 
        );
        """
        # In a real app, 'password TEXT NOT NULL' should store hashed passwords.
        
        cursor.execute(create_table_sql)
        conn.commit()
        print(f"Table 'users' checked/created successfully in {DB_PATH}.")
        
    except sqlite3.Error as e:
        print(f"Database error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            conn.close()


def create_product_table():
    """Creates the users table in the SQLite database if it doesn't exist."""
    conn = None
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
               
        cursor.execute("CREATE TABLE products (ProductID VARCHAR(255) PRIMARY KEY, Price REAL, Discount REAL, QtyRemaining INTEGER)")
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", ('P0001', 15.62, 15, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0002', 41.13, 15, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0003', 89.32, 15, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0004', 87.23, 10, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0005', 81.72, 0, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0006', 41.35, 10, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0007', 67.26, 20, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0008', 85.88, 20, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0009', 59.23, 10, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0010', 33.48, 15, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0011', 54.84, 0, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0012', 14.25, 5, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0013', 61.81, 0, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0014', 66.94, 10, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0015', 60.54, 5, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0016', 94.26, 15, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0017', 25.55, 0, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0018', 16.73, 5, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0019', 71.2, 15, 100))
        
        cursor.execute("INSERT INTO products (ProductID, Price, Discount, QtyRemaining) VALUES (?, ?, ?, ?)", 
                       ('P0020', 11.5, 20, 100))
        conn.commit()
        print(f"Table 'users' checked/created successfully in {DB_PATH}.")
        
    except sqlite3.Error as e:
        print(f"Database error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    # create_users_table()
    # create_product_table()



    # You can add some sample users here if you want, for example:
    # conn = sqlite3.connect(DB_PATH)
    # cursor = conn.cursor()
    # try:
    #     cursor.execute("CREATE TABLE IF NOT EXISTS products (ProductID VARCHAR(255) PRIMARY KEY, Price REAL, Discount REAL, QtyRemaining INTEGER)")
    #     # cursor.execute("INSERT INTO users (email, password) VALUES (?, ?)", 
    #     #                ('test@example.com', 'testpass123'))
    #     # cursor.execute("INSERT INTO users (email, password) VALUES (?, ?)", 
    #     #                ('another@example.com', 'securepass456'))
    #     conn.commit()
    #     print("Sample users inserted.")
    # except sqlite3.IntegrityError:
    #     print("Sample users might already exist.") # Handles if you run it multiple times
    # finally:
    #     if conn:
    #         conn.close()
