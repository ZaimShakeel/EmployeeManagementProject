-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: localhost    Database: companyz_ems
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '5e758fa3-b822-11f0-9ec1-200b742aed8b:1-95';

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `audit_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(64) NOT NULL,
  `entity` varchar(64) NOT NULL,
  `entity_id` varchar(64) DEFAULT NULL,
  `details_json` json DEFAULT NULL,
  `ip_address` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`),
  KEY `fk_audit_user` (`user_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `divisions`
--

DROP TABLE IF EXISTS `divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `divisions` (
  `division_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`division_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `divisions`
--

LOCK TABLES `divisions` WRITE;
/*!40000 ALTER TABLE `divisions` DISABLE KEYS */;
INSERT INTO `divisions` VALUES (1,'Engineering','2025-11-10 01:39:11','2025-11-10 01:39:11'),(2,'Sales','2025-11-10 01:39:11','2025-11-10 01:39:11'),(3,'Operations','2025-11-10 01:39:11','2025-11-10 01:39:11');
/*!40000 ALTER TABLE `divisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `emp_number` varchar(20) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `middle_name` varchar(80) DEFAULT NULL,
  `dob` date NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `address_line1` varchar(255) DEFAULT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(120) DEFAULT NULL,
  `state_province` varchar(120) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country` varchar(120) DEFAULT 'USA',
  `hire_date` date NOT NULL,
  `termination_date` date DEFAULT NULL,
  `status` enum('ACTIVE','ON_LEAVE','TERMINATED') NOT NULL DEFAULT 'ACTIVE',
  `division_id` int NOT NULL,
  `job_title_id` int NOT NULL,
  `manager_employee_id` int DEFAULT NULL,
  `ssn_last4` char(4) DEFAULT NULL,
  `ssn_enc` varbinary(256) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`employee_id`),
  UNIQUE KEY `emp_number` (`emp_number`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_emp_div` (`division_id`),
  KEY `fk_emp_job` (`job_title_id`),
  KEY `fk_emp_mgr` (`manager_employee_id`),
  KEY `idx_emp_last_first` (`last_name`,`first_name`),
  KEY `idx_emp_dob` (`dob`),
  KEY `idx_emp_empnumber` (`emp_number`),
  CONSTRAINT `fk_emp_div` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`division_id`),
  CONSTRAINT `fk_emp_job` FOREIGN KEY (`job_title_id`) REFERENCES `job_titles` (`job_title_id`),
  CONSTRAINT `fk_emp_mgr` FOREIGN KEY (`manager_employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'E0001','Ava','Lee',NULL,'1990-02-15','ava.lee@companyz.example','404-555-0101',NULL,NULL,NULL,NULL,NULL,'USA','2021-07-01',NULL,'ACTIVE',1,1,NULL,'1234',NULL,'2025-11-10 01:39:11','2025-11-10 01:39:11'),(2,'E0002','Noah','Kim',NULL,'1987-09-23','noah.kim@companyz.example','404-555-0102',NULL,NULL,NULL,NULL,NULL,'USA','2022-03-14',NULL,'ACTIVE',2,2,NULL,'9876',NULL,'2025-11-10 01:39:11','2025-11-10 01:39:11');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_titles`
--

DROP TABLE IF EXISTS `job_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_titles` (
  `job_title_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(120) NOT NULL,
  `pay_grade` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`job_title_id`),
  UNIQUE KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_titles`
--

LOCK TABLES `job_titles` WRITE;
/*!40000 ALTER TABLE `job_titles` DISABLE KEYS */;
INSERT INTO `job_titles` VALUES (1,'Software Engineer','P3','2025-11-10 01:39:11','2025-11-10 01:39:11'),(2,'Sales Manager','M2','2025-11-10 01:39:11','2025-11-10 01:39:11'),(3,'HR Generalist','P2','2025-11-10 01:39:11','2025-11-10 01:39:11');
/*!40000 ALTER TABLE `job_titles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pay_statements`
--

DROP TABLE IF EXISTS `pay_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pay_statements` (
  `pay_statement_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `pay_date` date NOT NULL,
  `gross_pay` decimal(12,2) NOT NULL,
  `taxes` decimal(12,2) NOT NULL,
  `deductions` decimal(12,2) NOT NULL,
  `net_pay` decimal(12,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`pay_statement_id`),
  KEY `idx_pay_emp_date` (`employee_id`,`pay_date` DESC),
  CONSTRAINT `fk_pay_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pay_statements`
--

LOCK TABLES `pay_statements` WRITE;
/*!40000 ALTER TABLE `pay_statements` DISABLE KEYS */;
INSERT INTO `pay_statements` VALUES (1,1,'2025-09-01','2025-09-15','2025-09-20',3653.85,800.00,200.00,2653.85,'2025-11-10 01:39:11'),(2,1,'2025-09-16','2025-09-30','2025-10-05',3653.85,800.00,200.00,2653.85,'2025-11-10 01:39:11'),(3,2,'2025-09-01','2025-09-15','2025-09-20',4230.77,950.00,250.00,3030.77,'2025-11-10 01:39:11');
/*!40000 ALTER TABLE `pay_statements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (2,'EMPLOYEE'),(1,'HR_ADMIN');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_history`
--

DROP TABLE IF EXISTS `salary_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_history` (
  `salary_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `effective_date` date NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`salary_id`),
  KEY `fk_sal_upd` (`updated_by`),
  KEY `idx_sal_emp_eff` (`employee_id`,`effective_date` DESC),
  CONSTRAINT `fk_sal_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sal_upd` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_history`
--

LOCK TABLES `salary_history` WRITE;
/*!40000 ALTER TABLE `salary_history` DISABLE KEYS */;
INSERT INTO `salary_history` VALUES (1,1,95000.00,'2024-01-01','Initial',NULL,'2025-11-10 01:39:11'),(2,2,110000.00,'2024-01-01','Initial',NULL,'2025-11-10 01:39:11');
/*!40000 ALTER TABLE `salary_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_employee_map`
--

DROP TABLE IF EXISTS `user_employee_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_employee_map` (
  `user_id` int NOT NULL,
  `employee_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`employee_id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  CONSTRAINT `fk_uemap_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_uemap_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_employee_map`
--

LOCK TABLES `user_employee_map` WRITE;
/*!40000 ALTER TABLE `user_employee_map` DISABLE KEYS */;
INSERT INTO `user_employee_map` VALUES (2,1);
/*!40000 ALTER TABLE `user_employee_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `fk_user_roles_role` (`role_id`),
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,1),(2,2);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(120) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` char(97) DEFAULT NULL,
  `mfa_secret` varbinary(128) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@companyz.example',NULL,NULL,1,'2025-11-10 01:39:11',NULL),(2,'ava.lee','ava.lee@companyz.example',NULL,NULL,1,'2025-11-10 04:28:20',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_employee_current_salary`
--

DROP TABLE IF EXISTS `v_employee_current_salary`;
/*!50001 DROP VIEW IF EXISTS `v_employee_current_salary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_employee_current_salary` AS SELECT 
 1 AS `employee_id`,
 1 AS `current_salary`,
 1 AS `effective_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_employee_self_profile`
--

DROP TABLE IF EXISTS `v_employee_self_profile`;
/*!50001 DROP VIEW IF EXISTS `v_employee_self_profile`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_employee_self_profile` AS SELECT 
 1 AS `employee_id`,
 1 AS `emp_number`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `middle_name`,
 1 AS `dob`,
 1 AS `email`,
 1 AS `phone`,
 1 AS `address_line1`,
 1 AS `address_line2`,
 1 AS `city`,
 1 AS `state_province`,
 1 AS `postal_code`,
 1 AS `country`,
 1 AS `hire_date`,
 1 AS `termination_date`,
 1 AS `status`,
 1 AS `division_id`,
 1 AS `job_title_id`,
 1 AS `manager_employee_id`,
 1 AS `ssn_masked`,
 1 AS `current_salary`,
 1 AS `salary_effective_date`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_monthly_total_pay_by_division`
--

DROP TABLE IF EXISTS `v_monthly_total_pay_by_division`;
/*!50001 DROP VIEW IF EXISTS `v_monthly_total_pay_by_division`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_monthly_total_pay_by_division` AS SELECT 
 1 AS `yyyy_mm`,
 1 AS `division_name`,
 1 AS `total_gross_pay`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_monthly_total_pay_by_job_title`
--

DROP TABLE IF EXISTS `v_monthly_total_pay_by_job_title`;
/*!50001 DROP VIEW IF EXISTS `v_monthly_total_pay_by_job_title`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_monthly_total_pay_by_job_title` AS SELECT 
 1 AS `yyyy_mm`,
 1 AS `job_title`,
 1 AS `total_gross_pay`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'companyz_ems'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_apply_salary_increase_range` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_apply_salary_increase_range`(
  IN p_percent DECIMAL(6,4),           -- e.g., 0.032 for 3.2%
  IN p_min_salary DECIMAL(12,2),
  IN p_max_salary DECIMAL(12,2),
  IN p_effective_date DATE,
  IN p_reason VARCHAR(255),
  IN p_updated_by INT
)
BEGIN
  -- Use a temporary table to collect target employees with their latest salary
  CREATE TEMPORARY TABLE tmp_targets (
    employee_id INT PRIMARY KEY,
    current_salary DECIMAL(12,2)
  ) ENGINE=MEMORY;

  INSERT INTO tmp_targets (employee_id, current_salary)
  SELECT cs.employee_id, cs.current_salary
  FROM v_employee_current_salary cs
  WHERE cs.current_salary >= p_min_salary
    AND cs.current_salary <  p_max_salary;

  -- Insert new rows into salary_history with increased amounts
  INSERT INTO salary_history (employee_id, amount, effective_date, reason, updated_by)
  SELECT
    t.employee_id,
    ROUND(t.current_salary * (1 + p_percent), 2) AS new_amount,
    p_effective_date,
    CONCAT('Bulk increase ', ROUND(p_percent*100,3), '%, range [', p_min_salary, ', ', p_max_salary, '): ', p_reason),
    p_updated_by
  FROM tmp_targets t;

  -- Audit one record per run; detailed per-employee changes can be derived from salary_history diff
  INSERT INTO audit_log (user_id, action, entity, entity_id, details_json)
  VALUES (p_updated_by, 'SALARY_INCREASE_RANGE', 'SALARY', NULL,
          JSON_OBJECT('percent', p_percent, 'min', p_min_salary, 'max', p_max_salary, 'effective_date', p_effective_date, 'reason', p_reason));

  DROP TEMPORARY TABLE IF EXISTS tmp_targets;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_employee_basic` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_employee_basic`(
  IN p_employee_id INT,
  IN p_first_name VARCHAR(80),
  IN p_last_name  VARCHAR(80),
  IN p_email      VARCHAR(255),
  IN p_phone      VARCHAR(32),
  IN p_address1   VARCHAR(255),
  IN p_address2   VARCHAR(255),
  IN p_city       VARCHAR(120),
  IN p_state      VARCHAR(120),
  IN p_postal     VARCHAR(20),
  IN p_country    VARCHAR(120),
  IN p_division_id INT,
  IN p_job_title_id INT,
  IN p_manager_employee_id INT,
  IN p_updated_by INT
)
BEGIN
  UPDATE employees
  SET first_name = p_first_name,
      last_name  = p_last_name,
      email      = p_email,
      phone      = p_phone,
      address_line1 = p_address1,
      address_line2 = p_address2,
      city = p_city,
      state_province = p_state,
      postal_code = p_postal,
      country = p_country,
      division_id = p_division_id,
      job_title_id = p_job_title_id,
      manager_employee_id = p_manager_employee_id
  WHERE employee_id = p_employee_id;

  INSERT INTO audit_log (user_id, action, entity, entity_id, details_json)
  VALUES (p_updated_by, 'EMPLOYEE_UPDATE', 'EMPLOYEE', CAST(p_employee_id AS CHAR),
          JSON_OBJECT('fields', JSON_ARRAY('name','email','phone','address','division','job_title','manager')));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_employee_current_salary`
--

/*!50001 DROP VIEW IF EXISTS `v_employee_current_salary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_employee_current_salary` AS select `sh`.`employee_id` AS `employee_id`,`sh`.`amount` AS `current_salary`,`sh`.`effective_date` AS `effective_date` from (`salary_history` `sh` join (select `salary_history`.`employee_id` AS `employee_id`,max(`salary_history`.`effective_date`) AS `max_eff` from `salary_history` group by `salary_history`.`employee_id`) `last_sh` on(((`sh`.`employee_id` = `last_sh`.`employee_id`) and (`sh`.`effective_date` = `last_sh`.`max_eff`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_employee_self_profile`
--

/*!50001 DROP VIEW IF EXISTS `v_employee_self_profile`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_employee_self_profile` AS select `e`.`employee_id` AS `employee_id`,`e`.`emp_number` AS `emp_number`,`e`.`first_name` AS `first_name`,`e`.`last_name` AS `last_name`,`e`.`middle_name` AS `middle_name`,`e`.`dob` AS `dob`,`e`.`email` AS `email`,`e`.`phone` AS `phone`,`e`.`address_line1` AS `address_line1`,`e`.`address_line2` AS `address_line2`,`e`.`city` AS `city`,`e`.`state_province` AS `state_province`,`e`.`postal_code` AS `postal_code`,`e`.`country` AS `country`,`e`.`hire_date` AS `hire_date`,`e`.`termination_date` AS `termination_date`,`e`.`status` AS `status`,`e`.`division_id` AS `division_id`,`e`.`job_title_id` AS `job_title_id`,`e`.`manager_employee_id` AS `manager_employee_id`,concat('***-**-',coalesce(`e`.`ssn_last4`,'XXXX')) AS `ssn_masked`,`cs`.`current_salary` AS `current_salary`,`cs`.`effective_date` AS `salary_effective_date`,`e`.`created_at` AS `created_at`,`e`.`updated_at` AS `updated_at` from (`employees` `e` left join `v_employee_current_salary` `cs` on((`cs`.`employee_id` = `e`.`employee_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_monthly_total_pay_by_division`
--

/*!50001 DROP VIEW IF EXISTS `v_monthly_total_pay_by_division`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_monthly_total_pay_by_division` AS select date_format(`ps`.`pay_date`,'%Y-%m') AS `yyyy_mm`,`d`.`name` AS `division_name`,sum(`ps`.`gross_pay`) AS `total_gross_pay` from ((`pay_statements` `ps` join `employees` `e` on((`e`.`employee_id` = `ps`.`employee_id`))) join `divisions` `d` on((`d`.`division_id` = `e`.`division_id`))) group by `yyyy_mm`,`division_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_monthly_total_pay_by_job_title`
--

/*!50001 DROP VIEW IF EXISTS `v_monthly_total_pay_by_job_title`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_monthly_total_pay_by_job_title` AS select date_format(`ps`.`pay_date`,'%Y-%m') AS `yyyy_mm`,`jt`.`title` AS `job_title`,sum(`ps`.`gross_pay`) AS `total_gross_pay` from ((`pay_statements` `ps` join `employees` `e` on((`e`.`employee_id` = `ps`.`employee_id`))) join `job_titles` `jt` on((`jt`.`job_title_id` = `e`.`job_title_id`))) group by `yyyy_mm`,`job_title` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-09 23:32:53
