-- 1.
--  Stworzyć blok anonimowy wypisujący zmienną numer_max równą maksymalnemu numerowi Departamentu i
--  dodaj do tabeli departamenty – departament z numerem o 10 wiekszym, typ pola dla zmiennej z nazwą
--  nowego departamentu (zainicjować na EDUCATION) ustawić taki jak dla pola department_name w tabeli (%TYPE)

DECLARE
    NUMER_MAX ZALESKI.DEPARTMENTS.DEPARTMENT_ID%TYPE;
BEGIN
    SELECT MAX(DEPARTMENT_ID)
    INTO NUMER_MAX
    FROM DEPARTMENTS;

    INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME) VALUES (NUMER_MAX + 10, 'NEW DEPARTMENT');
END;

-- 2. Do poprzedniego skryptu dodaj instrukcje zmieniającą location_id (3000) dla dodanego departamentu

DECLARE
    NUMER_MAX ZALESKI.DEPARTMENTS.DEPARTMENT_ID%TYPE;
BEGIN
    SELECT MAX(DEPARTMENT_ID)
    INTO NUMER_MAX
    FROM DEPARTMENTS;

    INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME) VALUES (NUMER_MAX + 10, 'NEW DEPARTMENT');
    UPDATE DEPARTMENTS SET LOCATION_ID = 3000 WHERE DEPARTMENT_ID = NUMER_MAX + 10;
END;

-- 3. Stwórz tabelę nowa z jednym polem typu varchar a następnie wpisz do niej za pomocą pętli liczby od 1 do 10 bez liczb 4 i 6

CREATE TABLE CW_3_3
(
    VAL VARCHAR(30)
);
BEGIN
    FOR X IN 1..10
        LOOP
            IF X != 4 AND X != 6 THEN
                INSERT INTO CW_3_3 (VAL) VALUES (X);
            END IF;
        END LOOP;
END;

-- 4. Wyciągnąć informacje z tabeli countries do jednej zmiennej (%ROWTYPE) dla kraju o identyfikatorze ‘CA’. Wypisać nazwę i region_id na ekran
DECLARE
    RESULT COUNTRIES%ROWTYPE;
BEGIN
    SELECT *
    INTO RESULT
    FROM COUNTRIES
    WHERE COUNTRY_ID = 'CA';

    DBMS_OUTPUT.PUT_LINE('NAZWA = ' || RESULT.COUNTRY_NAME || ' REGION_ID = ' || RESULT.REGION_ID);
END;

-- 5. Za pomocą tabeli INDEX BY wyciągnąć informacje o nazwach departamentów i wypisać na ekran 10 (numery 10,20,…,100)
DECLARE
    TYPE DEPARTMENTS_NAMES IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2 (5);
    DEP_NAMES DEPARTMENTS_NAMES;
    DEP_NAME  DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN
    FOR X IN 1..10
        LOOP
            SELECT DEPARTMENT_NAME INTO DEP_NAME FROM DEPARTMENTS WHERE DEPARTMENT_ID = X * 10;
            DEP_NAMES(X) := DEP_NAME;
        END LOOP;

    FOR X IN 1..10
        LOOP
            DBMS_OUTPUT.PUT_LINE(X * 10 || ' nazwa departamentu to ' || TO_CHAR(DEP_NAMES(X)));
        END LOOP;
END;

-- 6. Zmienić skrypt z 5 tak aby pojawiały się wszystkie informacje na ekranie (wstawić %ROWTYPE do tabeli)
DECLARE
    TYPE DEPARTMENTS_NAMES IS TABLE OF DEPARTMENTS%ROWTYPE INDEX BY VARCHAR2 (5);
    DEP_NAMES DEPARTMENTS_NAMES;
    DEP_NAME  DEPARTMENTS%ROWTYPE;
BEGIN
    FOR X IN 1..10
        LOOP
            SELECT * INTO DEP_NAME FROM DEPARTMENTS WHERE DEPARTMENT_ID = X * 10;
            DEP_NAMES(X) := DEP_NAME;
        END LOOP;

    FOR X IN 1..10
        LOOP
            DBMS_OUTPUT.PUT_LINE(X * 10 || ' department ' ||
                                 'nazwa to ' || TO_CHAR(DEP_NAMES(X).DEPARTMENT_NAME) || ' ' ||
                                 'id managera  = ' || TO_CHAR(DEP_NAMES(X).MANAGER_ID) || ' ' ||
                                 'id lokacji = ' || TO_CHAR(DEP_NAMES(X).LOCATION_ID));
        END LOOP;
END;

-- 7. Zadeklaruj kursor jako wynagrodzenie, nazwisko dla departamentu o numerze 50. Dla elementów kursora wypisać na ekran,
-- jeśli wynagrodzenie jest wyższe niż 3100: nazwisko osoby i tekst ‘nie dawać podwyżki’ w przeciwnym przypadku: nazwisko + ‘dać podwyżkę’
DECLARE
    TYPE ROW_TYPE IS RECORD
                     (
                         SALARY    NUMBER,
                         LAST_NAME VARCHAR2(25)
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT SALARY, LAST_NAME FROM EMPLOYEES WHERE DEPARTMENT_ID = 50';

    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;

        IF ROW_VALUE.SALARY > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(ROW_VALUE.LAST_NAME || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(ROW_VALUE.LAST_NAME || ' - dać podwyżke');
        END IF;
    END LOOP;
END;

-- 8. Zadeklarować kursor zwracający zarobki imię i nazwisko pracownika z parametrami,
-- gdzie pierwsze dwa parametry określają widełki zarobków a trzeci część imienia pracownika. Wypisać na ekran pracowników:
--
-- a. z widełkami 1000- 5000 z częścią imienia a (może być również A)
-- b. z widełkami 5000-20000 z częścią imienia u (może być również U)
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE CW_3_8(part_of_name VARCHAR2, min_salary NUMBER, max_salary NUMBER)
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         SALARY     NUMBER,
                         FIRST_NAME VARCHAR2(25),
                         LAST_NAME  VARCHAR2(25)
                     );
    ROW_VALUE ROW_TYPE;
    CUR       SYS_REFCURSOR;
BEGIN
    OPEN CUR FOR 'SELECT SALARY, FIRST_NAME, LAST_NAME FROM EMPLOYEES ' ||
                 'WHERE SALARY > ' || min_salary || ' AND SALARY < ' || max_salary ||
                 'AND (FIRST_NAME LIKE ''%' || LOWER(part_of_name) || '%'' OR FIRST_NAME LIKE ''%' ||
                 UPPER(part_of_name) || '%'')';

    LOOP
        FETCH CUR INTO ROW_VALUE;
        EXIT WHEN CUR%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('SALARY = ' || ROW_VALUE.SALARY || ', ' ||
                             'FIRST_NAME = ' || ROW_VALUE.FIRST_NAME || ', ' ||
                             'LAST_NAME = ' || ROW_VALUE.LAST_NAME);
    END LOOP;
END;

BEGIN
    CW_3_8('a', 1000, 5000);
    CW_3_8('u', 5000, 20000);
END;
/

-- 9. Swtwórz procedury:
-- a. dodającą wiersz do tabeli Jobs – z dwoma parametrami wejściowymi określającymi Job_id, Job_title,
-- przetestuj działanie wrzuć wyjątki – co najmniej when others

CREATE OR REPLACE PROCEDURE CW_3_9_a(v_job_id VARCHAR2, v_job_title VARCHAR2)
    IS
BEGIN
    INSERT INTO JOBS (JOB_ID, JOB_TITLE)
    VALUES (v_job_id, v_job_title);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Podałes złe dane wejsciowe');
        DBMS_OUTPUT.PUT_LINE('Kod błedu: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Komunikat: ' || SQLERRM);
END;

BEGIN
    CW_3_9_a('NEW_JOB', 'some title');
END;
/

-- b.  modyfikującą title w tabeli Jobs – z dwoma parametrami id dla którego ma być modyfikacja
-- oraz nową wartość dla Job_title – przetestować działanie, dodać swój wyjątek dla no Jobs updated – najpierw sprawdzić numer błędu
CREATE OR REPLACE PROCEDURE CW_3_9_b(v_job_id VARCHAR2, v_job_title VARCHAR2)
    IS
DECLARE
    NO_JOBS_UPDATED EXCEPTION;
    PRAGMA EXCEPTION_INIT (NO_JOBS_UPDATED, -2001);
BEGIN
    UPDATE JOBS SET JOB_TITLE = v_job_title WHERE JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie zaktualizowano żadnych danych');
    END IF;
EXCEPTION
    WHEN NO_JOBS_UPDATED THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Podałes złe dane wejsciowe');
        DBMS_OUTPUT.PUT_LINE('Kod błedu: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Komunikat: ' || SQLERRM);
END;

BEGIN
    CW_3_9_b('AD_PRESxxx', 'President');
END;
/

-- c. usuwającą wiersz z tabeli Jobs o podanym Job_id– przetestować działanie, dodaj wyjątek dla no Jobs deleted
CREATE OR REPLACE PROCEDURE CW_3_9_c(v_job_id VARCHAR2)
    IS
    NO_JOBS_DELETED EXCEPTION;
    PRAGMA EXCEPTION_INIT (NO_JOBS_DELETED, -2001);
BEGIN
    DELETE FROM JOBS WHERE JOB_ID = v_job_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie usunieto żadnych danych');
    END IF;
EXCEPTION
    WHEN NO_JOBS_DELETED THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Podałes złe dane wejsciowe');
        DBMS_OUTPUT.PUT_LINE('Kod błedu: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Komunikat: ' || SQLERRM);
END;

BEGIN
    CW_3_9_c('AD_PRESxxx');
END;
/

-- d. Wyciągającą zarobki i nazwisko (parametry zwracane przez procedurę) z tabeli employees dla pracownika o przekazanym jako parametr id
CREATE OR REPLACE PROCEDURE CW_3_9_d(v_emp_id IN NUMBER, out_salary OUT NUMBER, out_last_name OUT VARCHAR2)
    IS
    TYPE ROW_TYPE IS RECORD
                     (
                         SALARY    NUMBER,
                         LAST_NAME VARCHAR2(25)
                     );
    ROW_RESULT ROW_TYPE;
    CUR        SYS_REFCURSOR;

BEGIN
    OPEN CUR FOR 'SELECT SALARY, LAST_NAME FROM EMPLOYEES WHERE EMPLOYEE_ID = ' || v_emp_id;
    FETCH CUR INTO ROW_RESULT;
    out_salary := ROW_RESULT.SALARY;
    out_last_name := ROW_RESULT.LAST_NAME;
END;
/

DECLARE
    v_out_salary    NUMBER;
    v_out_last_name VARCHAR2(30);
BEGIN
    CW_3_9_d(100, v_out_salary, v_out_last_name);
    DBMS_OUTPUT.PUT_LINE('SALARY = ' || v_out_salary || ', LAST_NAME = ' || v_out_last_name);
END;

-- e. dodającą do tabeli employees wiersz – większość parametrów ustawić na domyślne (id poprzez sekwencję),
-- stworzyć wyjątek jeśli wynagrodzenie dodawanego pracownika jest wyższe niż 20000

CREATE OR REPLACE PROCEDURE CW_3_9_e(v_first_name VARCHAR2 DEFAULT 'Patryk',
                                     v_last_name VARCHAR2 DEFAULT 'Brzostek',
                                     v_e_mail VARCHAR2 DEFAULT 'pinbrzostek7@gmail.com',
                                     v_phone_number VARCHAR2 DEFAULT '+48 123 123 123',
                                     v_salary NUMBER DEFAULT 10000)
    IS
    SALARY_TOO_HIGH EXCEPTION;
    PRAGMA EXCEPTION_INIT (SALARY_TOO_HIGH, -2001);
    LAST_ID NUMBER;
BEGIN
    IF v_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Wynagrodzenie za duże');
    END IF;

    SELECT MAX(EMPLOYEE_ID) INTO LAST_ID FROM EMPLOYEES;
    INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, SALARY, HIRE_DATE, JOB_ID)
    VALUES (LAST_ID + 1, v_first_name, v_last_name, v_e_mail, v_phone_number, v_salary, CURRENT_DATE, 'AD_PRES');

EXCEPTION
    WHEN SALARY_TOO_HIGH THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Podałes złe dane wejsciowe');
        DBMS_OUTPUT.PUT_LINE('Kod błedu: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Komunikat: ' || SQLERRM);
END;

BEGIN
    CW_3_9_e(v_last_name => 'Adamski');
END;
