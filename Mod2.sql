CREATE VIEW OrdersView AS
SELECT OrderID, OrderQuantity, OrderCost FROM Orders WHERE OrderQuantity > 2;

CREATE VIEW HighPayers AS
SELECT Customers.CustomerID, Customers.CustomerName, orders.OrderID, orders.OrderCost, menu.ItemName, menu.ItemType FROM customers
INNER JOIN orders ON orders.OrderID = Customers.OrderID
INNER JOIN menu ON menu.ItemID = orders.MenuItemID
ORDER BY OrderCost DESC;

SELECT ItemName FROM Menu WHERE ItemID = ANY (
SELECT MenuItemID FROM orders WHERE OrderQuantity > 2
);

CREATE PROCEDURE GetMaxQuantity()
SELECT MAX(OrderQuantity) FROM Orders;

PREPARE GetOrderDetail 'SELECT OrderID, OrderQuantity, OrderCost FROM Orders WHERE OrderID = ANY (
SELECT OrderID FROM Customers WHERE CustomerID = ?
)';

DELIMITER //
CREATE PROCEDURE CancelOrder(IN OrderToCancel INT)
BEGIN
DELETE FROM Orders WHERE OrderID = OrderToCancel;
SELECT CONCAT('Order ', OrderToCancel, ' is Cancelled') AS Conformation;
END //
DELIMITER ;

INSERT INTO Bookings VALUES
(1, '2022-10-10', 5),
(2, '2022-11-12', 3),
(3, '2022-10-11', 2),
(4, '2022-10-13', 2);

DELIMITER //
CREATE PROCEDURE CheckBooking(IN InputDate DATE, IN InputNumber INT)
BEGIN
SELECT CASE
  WHEN BookingDate = InputDate AND TableNo = InputNumber THEN 'Table is Free'
  ELSE 'Table is Booked'
  END AS 'Booking Status'
FROM Bookings WHERE TableNo = InputNumber;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddValidBooking(IN InputDate DATE, IN InputNumber INT)
BEGIN
DECLARE isBooked BOOL;
START TRANSACTION;
INSERT INTO Bookings (BookingDate, TableNo) VALUES (InputDate, InputNumber);
IF COUNT(TableNo) > 1 THEN
	ROLLBACK;
    SET isBooked = false;
ELSE
	COMMIT;
    SET isBooked = true;
END IF;
SELECT
	CASE WHEN isBooked THEN 'Table is already booked - booking cancelled'
    ELSE 'Booking Added'
    END AS 'Command Result';
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddBooking(IN NewBookingID INT, IN NewBookingDate DATE, IN NewTableNo INT)
BEGIN
INSERT INTO Bookings VALUES (NewBookingID, NewBookingDate, NewTableNo);
SELECT 'Booking Added' AS 'Conformation';
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateBooking(IN ToUpdate INT, IN NewBookingDate DATE)
BEGIN
UPDATE Bookings
SET BookingDate = NewBookingDate WHERE BookingID = ToUpdate;
SELECT 'Booking Updated' AS 'Conformation';
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CancelBooking(IN TargetID INT)
BEGIN
DELETE FROM Bookings WHERE BookingID = TargetID;
SELECT 'Booking Deleted' AS 'Conformation';
END //
DELIMITER ;