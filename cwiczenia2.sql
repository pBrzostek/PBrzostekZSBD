-- I. 
-- Usuwanie tabel
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE jobs CASCADE CONSTRAINTS;
DROP TABLE job_history CASCADE CONSTRAINTS;
DROP TABLE countries CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;
DROP TABLE locations CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;

-- II. 
-- Kopiowanie tabel
CREATE TABLE BRZOSTEK.departments AS (SELECT * FROM HR.departments);
CREATE TABLE BRZOSTEK.locations AS (SELECT * FROM HR.locations);
CREATE TABLE BRZOSTEK.countries AS (SELECT * FROM HR.countries);
CREATE TABLE BRZOSTEK.regions AS (SELECT * FROM HR.regions);
CREATE TABLE BRZOSTEK.job_history AS (SELECT * FROM HR.job_history);
CREATE TABLE BRZOSTEK.jobs AS (SELECT * FROM HR.jobs);
CREATE TABLE BRZOSTEK.employees AS (SELECT * FROM HR.employees);

-- Klucze glowne
ALTER TABLE departments ADD PRIMARY KEY (DEPARTMENT_ID);
ALTER TABLE locations ADD PRIMARY KEY (LOCATION_ID);
ALTER TABLE countries ADD PRIMARY KEY (COUNTRY_ID);
ALTER TABLE regions ADD PRIMARY KEY (REGION_ID);
ALTER TABLE job_history ADD PRIMARY KEY (EMPLOYEE_ID, START_DATE);
ALTER TABLE jobs ADD PRIMARY KEY (JOB_ID);
ALTER TABLE employees ADD PRIMARY KEY (EMPLOYEE_ID);

-- Klucze obce
ALTER TABLE departments ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE departments ADD FOREIGN KEY (location_id) REFERENCES locations(location_id);
ALTER TABLE locations ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);
ALTER TABLE job_history ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE job_history ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE employees ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE countries ADD FOREIGN KEY (REGION_ID) REFERENCES regions(REGION_ID);


-- III.
---  # 1
--- Z tabeli employees wypisz w jednej kolumnie nazwisko i zarobki ??? nazwij kolumn?? wynagrodzenie,
--- dla os??b z departament??w 20 i 50 z zarobkami pomi??dzy 2000 a 7000, uporz??dkuj kolumny wed??ug nazwiska
CREATE VIEW cwiczenie_1 AS
    SELECT CONCAT(CONCAT(first_name,' ') , salary) AS wynagrodzenie FROM employees
    WHERE department_id IN (20, 50) AND salary BETWEEN 2000 AND 5000 ORDER BY last_name DESC;

---  # 2
--- Z tabeli employees wyci??gn???? informacj?? data zatrudnienia, nazwisko oraz kolumn?? podan?? przez u??ytkownika
--- dla os??b maj??cych menad??era zatrudnionych w roku 2005. Uporz??dkowa?? wed??ug kolumny podanej przez u??ytkownika

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE CW_2(column_name VARCHAR2)
    IS
    ROW_VALUE VARCHAR2(3000);
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT HIRE_DATE || '' '' ||  LAST_NAME || '' '' || ' || column_name || ' FROM EMPLOYEES ' ||
                 'WHERE MANAGER_ID IS NOT NULL AND HIRE_DATE BETWEEN DATE ''2005-01-01'' AND DATE ''2005-12-31'' ' ||
                 'ORDER BY ' || column_name;
    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(ROW_VALUE);
    END LOOP;
END;
/

BEGIN
    CW_2('EMAIL');
END;
/


---  # 3
--- Wypisa?? imiona i nazwiska razem, zarobki oraz numer telefonu porz??dkuj??c dane wed??ug pierwszej kolumny malej??co
-- a nast??pnie drugiej rosn??co (u??y?? numer??w do porz??dkowania) dla os??b z trzeci?? liter?? nazwiska ???e??? oraz cz????ci?? imienia podan?? przez u??ytkownika

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE CW_3(partOfName VARCHAR2)
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         NAME         VARCHAR2(60),
                         SALARY       NUMBER,
                         PHONE_NUMBER VARCHAR2(20)
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT FIRST_NAME || '' '' || LAST_NAME AS NAME, SALARY, PHONE_NUMBER FROM EMPLOYEES ' ||
                 'WHERE REGEXP_LIKE(LAST_NAME, ''^..a'') AND FIRST_NAME LIKE ''%' || partOfName || '%''' ||
                 'ORDER BY NAME DESC, SALARY ASC';
    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Imie = ' || ROW_VALUE.NAME ||', ' ||
                             'Wynagrodzenie = ' || ROW_VALUE.SALARY || ', ' ||
                             'Numer telefonu = ' || ROW_VALUE.PHONE_NUMBER);
    END LOOP;
END;
/

BEGIN
    CW_3('er');
END;
/

---  # 4.
--- Wypisa?? imi?? i nazwisko, liczb?? miesi??cy przepracowanych ??? funkcje months_between oraz round oraz kolumn?? wysoko????_dodatku jako (u??y?? CASE lub DECODE):
--- 10% wynagrodzenia dla liczby miesi??cy do 150
--- 20% wynagrodzenia dla liczby miesi??cy od 150 do 200
--- 30% wynagrodzenia dla liczby miesi??cy od 200
--- uporz??dkowa?? wed??ug liczby miesi??cy

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE CW_4
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         NAME         VARCHAR2(60),
                         WORKING_MOTHS       NUMBER,
                         ADDITIONAL_SALARY NUMBER
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT E.FIRST_NAME || '' '' || E.LAST_NAME AS NAME, ' ||
                 'ROUND(MONTHS_BETWEEN(CURRENT_DATE, JH.START_DATE)) AS WORKING_MOTHS, ' ||
                 '(CASE ' ||
                 'WHEN ROUND(MONTHS_BETWEEN(CURRENT_DATE, JH.START_DATE)) < 150 THEN 0.1 * E.SALARY ' ||
                 'WHEN ROUND(MONTHS_BETWEEN(CURRENT_DATE, JH.START_DATE)) > 200 THEN 0.2 * E.SALARY ' ||
                 'ELSE 0.3 * E.SALARY ' ||
                 'END) AS ADDITIONAL_SALARY FROM EMPLOYEES E ' ||
                 'JOIN JOB_HISTORY JH on E.EMPLOYEE_ID = JH.EMPLOYEE_ID ' ||
                 'ORDER BY WORKING_MOTHS DESC';
    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Imie = ' || ROW_VALUE.NAME ||', ' ||
                             'Przepracowane miesiace = ' || ROW_VALUE.WORKING_MOTHS || ', ' ||
                             'Dodatkowe_wynagrodzenie = ' || ROW_VALUE.ADDITIONAL_SALARY);
    END LOOP;
END;
/

BEGIN
    CW_4();
END;
/

---  # 5
--- Dla ka??dego dzia????w w kt??rych minimalna p??aca jest wy??sza ni?? 5000 wypisz sum?? oraz ??redni?? zarobk??w zaokr??glon?? do ca??o??ci nazwij odpowiednio kolumny

SELECT D.DEPARTMENT_NAME, SUM(E.SALARY) AS SUMMARY, ROUND(AVG(E.SALARY), 0) AS AVERGAE FROM DEPARTMENTS D
    JOIN EMPLOYEES E ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
    GROUP BY D.DEPARTMENT_NAME
    HAVING AVG(E.SALARY) > 5000;

---  # 6
--- Wypisa?? nazwisko, numer departamentu, nazw?? departamentu, id pracy, dla os??b z pracuj??cych Toronto
SELECT LAST_NAME, D.DEPARTMENT_ID, DEPARTMENT_NAME, JOB_ID FROM DEPARTMENTS D
    JOIN EMPLOYEES E ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
    JOIN LOCATIONS L ON L.LOCATION_ID = D.LOCATION_ID
    WHERE L.CITY = 'Toronto';

---  # 7
--- Dla pracownik??w o imieniu ???Jennifer??? wypisz imi?? i nazwisko tego pracownika oraz osoby kt??re z nim wsp????pracuj??
SELECT E.FIRST_NAME, LAST_NAME FROM EMPLOYEES E
    JOIN JOBS J ON E.JOB_ID = J.JOB_ID
    WHERE E.FIRST_NAME = 'Jennifer'
       OR E.JOB_ID IN (SELECT JOB_ID FROM EMPLOYEES WHERE FIRST_NAME = 'Jennifer');

---  # 8
--- Wypisa?? wszystkie departamenty w kt??rych nie ma pracownik??w
SELECT * FROM DEPARTMENTS
    WHERE DEPARTMENT_ID NOT IN (SELECT DISTINCT DEPARTMENT_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL);

---  # 9
--- Skopiuj tabel?? Job_grades od u??ytkownika HR

CREATE TABLE ZALESKI.JOB_GRADES AS (SELECT * FROM HR.JOB_GRADES);

---  # 10
--- Wypisz imi?? i nazwisko, id pracy, nazw?? departamentu, zarobki, oraz odpowiedni grade dla ka??dego pracownika

SELECT E.FIRST_NAME, E.LAST_NAME, E.JOB_ID, D.DEPARTMENT_NAME, E.SALARY, JG.GRADE FROM EMPLOYEES E
        JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
        JOIN JOB_GRADES JG ON E.EMPLOYEE_ID = JG.EMPLOYEE_ID;

---  # 11
--- Wypisz imi?? nazwisko oraz zarobki dla os??b kt??re zarabiaj?? wi??cej ni?? ??rednia wszystkich, uporz??dkuj malej??co wed??ug zarobk??w

SELECT FIRST_NAME, LAST_NAME, SALARY FROM EMPLOYEES
    WHERE SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES)
    ORDER BY SALARY DESC

---  # 12
--- Wypisz id imie i nazwisko os??b, kt??re pracuj?? w departamencie z osobami maj??cymi w nazwisku ???u???

SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME FROM EMPLOYEES E
    JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
    WHERE D.DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM EMPLOYEES WHERE FIRST_NAME LIKE '%e%');

