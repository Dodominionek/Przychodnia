/*
CREATE DATABASE Przychodnia
*/

/*
CREATE TABLE Sale(
	SalaID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Metraz INT NOT NULL,
	Pietro INT NOT NULL,
	Zdezynfekowana VARCHAR(3) NOT NULL,
	CHECK(Zdezynfekowana LIKE 'Tak' OR Zdezynfekowana LIKE 'Nie')
);

CREATE TABLE Narzedzia(
	NarzedziaID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Sala INT FOREIGN KEY REFERENCES Sale(SalaID) NOT NULL,
	Nazwa VARCHAR(50) NOT NULL,
	Dostepnosc VARCHAR(3) NOT NULL,
	CHECK(Dostepnosc LIKE 'Tak' OR Dostepnosc LIKE 'Nie'), 
	Zdezynfekowana VARCHAR(3) NOT NULL,
	CHECK(Zdezynfekowana LIKE 'Tak' OR Zdezynfekowana LIKE 'Nie')
);

CREATE TABLE Pracownicy(
	PracownikID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Typ VARCHAR(50) NOT NULL,
	Wynagrodzenie INT NOT NULL,
	Zatrudnienie VARCHAR(50) NOT NULL,
	DataZatrudnienia DATE NOT NULL
);

CREATE TABLE Lekarze(
	LekarzID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Pracownik INT FOREIGN KEY REFERENCES Pracownicy(PracownikID) NOT NULL,
	Specjalizacja VARCHAR(50) NOT NULL,
	Imie VARCHAR(50) NOT NULL,
	Nazwisko VARCHAR(50) NOT NULL,
	Mail VARCHAR(50) NOT NULL
);

CREATE TABLE Stazysci(
	StazystaID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Pracownik INT FOREIGN KEY REFERENCES Pracownicy(PracownikID) NOT NULL,
	Imie VARCHAR(50) NOT NULL,
	Nazwisko VARCHAR(50) NOT NULL,
	Uczelnia VARCHAR(50) NOT NULL,
	PrzydzielonyLekarz INT FOREIGN KEY REFERENCES Lekarze(LekarzID) NOT NULL,
	NrLegitymacji INT NOT NULL
);

CREATE TABLE Obsluga(
	ObslugaID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Pracownik INT FOREIGN KEY REFERENCES Pracownicy(PracownikID) NOT NULL,
	Imie VARCHAR(50) NOT NULL,
	Nazwisko VARCHAR(50) NOT NULL,
	Funkcja VARCHAR(50) NOT NULL,
	Stazysta VARCHAR(3) NOT NULL,
	CHECK(Stazysta LIKE 'Tak' OR Stazysta LIKE 'Nie'),
	Etat VARCHAR(10) NOT NULL
);

CREATE TABLE Pacjenci(
	PacjentID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Ubezpieczenie VARCHAR(30) NOT NULL,
	Imie VARCHAR(50) NOT NULL,
	Nazwisko VARCHAR(50) NOT NULL,
	Pesel VARCHAR(11) NOT NULL,
	Numer VARCHAR(12) NOT NULL,
	DataUrodzenia DATE NOT NULL
);

CREATE TABLE Wizyty(
	WizytaID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	DataWizyty DATE NOT NULL,
	LekarzID INT FOREIGN KEY REFERENCES Lekarze(LekarzID) NOT NULL,
	PacjentID INT FOREIGN KEY REFERENCES Pacjenci(PacjentID) NOT NULL,
	RodzajWizyty VARCHAR(50) NOT NULL,
	Pilnosc VARCHAR(50) NOT NULL,
	Sala INT FOREIGN KEY REFERENCES Sale(SalaID) NOT NULL
);
*/

--Widok sali spotkania przydzielonej w danym dniu
/*
CREATE OR ALTER VIEW SalaSpotkania AS
SELECT W.WizytaID AS IDWizyty, S.SalaID AS NumerSali, L.Imie, L.Nazwisko
FROM Sale S JOIN Wizyty W ON W.Sala=S.SalaID
JOIN Lekarze L ON L.LekarzID=W.LekarzID
WHERE DataWizyty='2020-02-02'
*/

--SELECT * FROM SalaSpotkania

--Widok przydzielonych dla danego lekarza stażysy
/*
CREATE OR ALTER VIEW PrzydzieloniStazysci AS
SELECT L.Imie AS ImieLekarza, L.Nazwisko NazwiskoLekarza, S.Imie ImieStazysty, S.Nazwisko AS NazwiskoStazysty
FROM Lekarze L JOIN Stazysci S ON L.LekarzID=S.PrzydzielonyLekarz
WHERE LEFT(L.Imie,1)='A' AND LEN(L.Nazwisko)>2
*/

--SELECT * FROM PrzydzieloniStazysci

--Widok osob w przychodni, ktorzy nie sa lekarzami
/*
CREATE OR ALTER VIEW NieLekarze AS
SELECT S.Imie+' '+S.Nazwisko AS Nielekarze
FROM Stazysci S
UNION
SELECT O.Imie+' '+O.Nazwisko
FROM Obsluga O
*/

--SELECT * FROM NieLekarze

--Zlicza wizyty lekarza o danym id w danym dniu
/*
CREATE OR ALTER PROCEDURE IleWizyt @IDLearza INT, @DataWiz DATE
AS
SELECT COUNT(W.WizytaID)
FROM Wizyty W JOIN Lekarze L ON L.LekarzID=W.LekarzID
WHERE L.LekarzID=@IDLearza AND W.DataWizyty=@DataWiz
*/

--EXEC IleWizyt 3,'2020-02-03'

--Wyswietla wolne sale w danym dniu
/*
CREATE OR ALTER PROCEDURE WolneSale @DataSal DATE
AS
SELECT Sal.SalaID AS WolneSale
FROM Sale Sal
WHERE SalaID NOT IN (SELECT S.SalaID
FROM Sale S JOIN Wizyty W ON W.Sala=S.SalaID
WHERE @DataSal=W.DataWizyty)
GROUP BY Sal.SalaID
*/

--EXEC WolneSale '2020-02-02'

--Wyswietla wizyty lekarza o danym nazwisku w danym dniu
/*
CREATE OR ALTER PROCEDURE WizytyDnia @DataWiz DATE, @LekarzWiz VARCHAR(50)
AS 
SELECT W.*
FROM Wizyty W JOIN Lekarze L ON W.LekarzID=L.LekarzID
WHERE L.Nazwisko=@LekarzWiz AND W.DataWizyty=@DataWiz
*/

--EXEC WizytyDnia '2020-02-02','Zab'

--Oblicza kwote ubezpieczenia pozostala pacjentowi
/*
CREATE OR ALTER FUNCTION UbezpieczeniePoWizycie (@Pacjent INT)
RETURNS TABLE
AS 
RETURN(
SELECT W.PacjentID, 10000-COUNT(W.WizytaID)*1000 AS Zostalo
FROM Wizyty W JOIN Pacjenci P ON W.PacjentID=P.PacjentID
WHERE W.PacjentID=@Pacjent AND P.Ubezpieczenie='Podstawowe'
GROUP BY W.PacjentID
UNION
SELECT W.PacjentID, 40000-COUNT(W.WizytaID)*1000 AS Zostalo
FROM Wizyty W JOIN Pacjenci P ON W.PacjentID=P.PacjentID
WHERE W.PacjentID=@Pacjent AND P.Ubezpieczenie='Rozszerzone'
GROUP BY W.PacjentID)
GO
*/

--SELECT * FROM UbezpieczeniePoWizycie(1)
--GO

--Koszt pracy pracownika obslugi od poczatku roku
/*
CREATE OR ALTER FUNCTION ObliczKosztyPracy (@Obsluga INT)
RETURNS TABLE
AS
RETURN(
SELECT (MONTH(CAST(GETDATE() AS DATE))-MONTH(P.DataZatrudnienia)+1)*2000 AS Koszt
FROM Obsluga O JOIN Pracownicy P ON O.Pracownik=P.PracownikID
WHERE O.ObslugaID=@Obsluga)
GO
*/

--SELECT * FROM ObliczKosztyPracy(1)
--GO

--Kazda wizyta to pol godziny pracy stazysty, liczy godziny pracy stazystow przydzielonych do danego lekarza
/*
CREATE OR ALTER FUNCTION GodzinyStazystow (@Lekarz INT)
RETURNS TABLE
AS
RETURN(
SELECT S.StazystaID, (COUNT(W.WizytaID)*0.5) AS Godziny
FROM Wizyty W JOIN Lekarze L ON W.LekarzID=L.LekarzID
JOIN Stazysci S ON L.LekarzID=S.PrzydzielonyLekarz
WHERE @Lekarz=L.LekarzID
GROUP BY S.StazystaID)
GO
*/

--SELECT * FROM GodzinyStazystow(1)
--GO

/*
INSERT INTO Sale VALUES(20,1,'Tak')
INSERT INTO Sale VALUES(30,1,'Tak')
INSERT INTO Sale VALUES(15,1,'Nie')
INSERT INTO Sale VALUES(20,2,'Tak')
INSERT INTO Sale VALUES(10,2,'Nie')
INSERT INTO Sale VALUES(20,3,'Tak')
*/

/*
INSERT INTO Narzedzia VALUES(1,'Stol rehabilitacyjny','Tak','Tak')
INSERT INTO Narzedzia VALUES(1,'Pilka lekarska','Tak','Tak')
INSERT INTO Narzedzia VALUES(2,'Pilka lekarska','Tak','Tak')
INSERT INTO Narzedzia VALUES(3,'Stol dentystyczby','Tak','Nie')
INSERT INTO Narzedzia VALUES(3,'Wiertla','Nie','Nie')
INSERT INTO Narzedzia VALUES(5,'Drabinki','Tak','Tak')
*/

/*
INSERT INTO Pracownicy VALUES ('Pracownik',30000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',30000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',30000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',30000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',30000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',30000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',1000,'1/3 Etatu','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',1000,'1/3 Etatu','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',1000,'1/3 Etatu','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',1000,'1/3 Etatu','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',100000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',100000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',100000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Pracownik',100000,'Pelen Etat','2020-01-01')
INSERT INTO Pracownicy VALUES ('Dyrektor',1300000,'Pelen Etat','2019-01-01')
*/

/*
INSERT INTO Lekarze VALUES (11,'Fizjoterapeuta','Adam','Sep','a.s@gmail.com')
INSERT INTO Lekarze VALUES (12,'Fizjoterapeuta','Jan','Cep','j.c@gmail.com')
INSERT INTO Lekarze VALUES (13,'Stomatolog','Stefan','Zab','s.z@gmail.com')
INSERT INTO Lekarze VALUES (14,'Stomatolog','Jan','Kowal','j.k@gmail.com')
*/

/*
INSERT INTO Stazysci VALUES(7,'Adam','Kos','Uniwersytet',1,111320)
INSERT INTO Stazysci VALUES(8,'Dominik','Lek','Uniwersytet',1,111321)
INSERT INTO Stazysci VALUES(9,'Damian','Hol','Uniwersytet',1,111322)
INSERT INTO Stazysci VALUES(10,'Sebastian','Bak','Uniwersytet',3,111324)
*/

/*
INSERT INTO Obsluga VALUES(1,'Kazimierz','Rys','Ochrona','Nie','Pelen')
INSERT INTO Obsluga VALUES(2,'Ada','Kolo','Ochrona','Nie','Pelen')
INSERT INTO Obsluga VALUES(3,'Marek','Ret','Opieka','Nie','Pelen')
INSERT INTO Obsluga VALUES(4,'Kasia','Dos','Opieka','Nie','Pelen')
INSERT INTO Obsluga VALUES(5,'Ania','Los','Opieka','Nie','Pelen')
INSERT INTO Obsluga VALUES(6,'Kuba','Dom','Opieka','Nie','Pelen')
*/

/*
INSERT INTO Pacjenci VALUES('Podstawowe','Maria','Kowal','99121193211','503022111','1999-12-11')
INSERT INTO Pacjenci VALUES('Rozszerzone','Karol','Samotny','99121193331','622022881','1999-12-11')
*/

/*
INSERT INTO Wizyty VALUES('2020-02-02',1,1,'Kontrola','Niepilne',1)
INSERT INTO Wizyty VALUES('2020-02-02',3,2,'Kontrola','Niepilne',3)
INSERT INTO Wizyty VALUES('2020-02-03',3,2,'Zabieg','Pilne',3)
INSERT INTO Wizyty VALUES('2020-02-03',3,1,'Zabieg','Niepilne',3)
*/

--SELECT * FROM Sale
--SELECT * FROM Narzedzia
--SELECT * FROM Pracownicy
--SELECT * FROM Lekarze
--SELECT * FROM Stazysci
--SELECT * FROM Obsluga
--SELECT * FROM Pacjenci
--SELECT * FROM Wizyty
