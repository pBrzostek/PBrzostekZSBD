DROP TABLE departments;
DROP TABLE locations;
DROP TABLE countries;
DROP TABLE regions;
DROP TABLE job_history;
DROP TABLE jobs;
DROP TABLE employees;

CREATE TABLE departments (department_id INT PRIMARY KEY, department_name VARCHAR(30) NOT NULL, manager_id INT, location_id INT);
CREATE TABLE locations (location_id INT PRIMARY KEY, street_address VARCHAR(30), postal_code VARCHAR(15), city VARCHAR(30), state_province VARCHAR(30), country_id INT);
CREATE TABLE regions (region_id INT PRIMARY KEY, region_name VARCHAR(30));
CREATE TABLE countries (country_id INT PRIMARY KEY, country_name VARCHAR(30), region_id INT,
                        FOREIGN KEY(region_id) REFERENCES regions(region_id));

CREATE TABLE job_history (employee_id INT, start_date DATE, end_date DATE, job_id INT, department_id INT,
                            CONSTRAINT job_history_id PRIMARY KEY (employee_id, start_date));
CREATE TABLE jobs (job_id INT PRIMARY KEY, job_title VARCHAR(30));
ALTER TABLE jobs ADD min_salary FLOAT;
ALTER TABLE jobs ADD max_salary FLOAT;
CREATE TABLE employees (employee_id INT PRIMARY KEY, first_name VARCHAR(30), last_name VARCHAR(30), email VARCHAR(30),
phone_number VARCHAR(15), hire_date DATE, job_id INT, salary FLOAT, commission_pct VARCHAR(30), manager_id INT, department_id INT);

ALTER TABLE departments ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE departments ADD FOREIGN KEY (location_id) REFERENCES locations(location_id);
ALTER TABLE locations ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);
ALTER TABLE job_history ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE job_history ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE employees ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE jobs ADD CHECK (max_salary - min_salary > 2000);
