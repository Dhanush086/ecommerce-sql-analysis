CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    City VARCHAR(50),
    SignupDate DATE
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    Category VARCHAR(30),
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT,
    CustomerID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    OrderDate DATE,
    Status VARCHAR(20) DEFAULT 'Delivered',
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
