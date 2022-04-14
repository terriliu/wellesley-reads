-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: wellesleyreads_db
-- ------------------------------------------------------
-- Server version	5.5.68-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `author` (
  `aid` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(30) DEFAULT NULL,
  `author_bio` varchar(100) DEFAULT NULL,
  `has_user_account` tinyint(4) DEFAULT NULL,
  `user_account_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`aid`),
  KEY `user_account_id` (`user_account_id`),
  CONSTRAINT `author_ibfk_1` FOREIGN KEY (`user_account_id`) REFERENCES `user` (`uid`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `author`
--

LOCK TABLES `author` WRITE;
/*!40000 ALTER TABLE `author` DISABLE KEYS */;
INSERT INTO `author` VALUES (1,'Audrey Niffenegger','Author of The Time Traveler\'s Wife',0,NULL),(2,'Agatha Christie','Famous British Author',0,NULL),(3,'Andy Weir','Author of the famous movie The Martian',0,NULL),(4,'Michelle Obama','Former First Lady of the United States',0,NULL),(5,'John Green','New York Times bestselling author',0,NULL),(6,'George Orwell','Famous English novelist',0,NULL),(7,'Anne Frank','One of the most discussed Jewish victims of the Holocaust',0,NULL),(8,'Bram Stoker','Irish author, best known today for his 1897 Gothic horror novel Dracula',0,NULL),(9,'Dan Brown','Author of many #1 bestselling novels',0,NULL),(10,'Suzanne Collins','American tevelision writer',0,NULL),(11,'Nicholas Sparks','Romance, Love, <3',0,NULL),(12,'Arthur Conan Doyle','British writer and physician',0,NULL),(13,'Isaac Asimov','Considered one of the \"Big Three\" science fiction writers of his time',0,NULL),(14,'Tara Westover','American memoirist, essayist, and historian.',0,NULL),(15,'Stephen King','Author of The Shining',0,NULL),(16,'Jon Krakauer','American writier and mountaineer',0,NULL),(17,'William Peter Blatty','Won the Academy Award for the screenplay of the film adaptation for The Exorcist',0,NULL);
/*!40000 ALTER TABLE `author` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `befriend`
--

DROP TABLE IF EXISTS `befriend`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `befriend` (
  `uid_1` int(11) NOT NULL DEFAULT '0',
  `uid_2` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid_1`,`uid_2`),
  KEY `uid_2` (`uid_2`),
  CONSTRAINT `befriend_ibfk_1` FOREIGN KEY (`uid_1`) REFERENCES `user` (`uid`) ON UPDATE CASCADE,
  CONSTRAINT `befriend_ibfk_2` FOREIGN KEY (`uid_2`) REFERENCES `user` (`uid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `befriend`
--

LOCK TABLES `befriend` WRITE;
/*!40000 ALTER TABLE `befriend` DISABLE KEYS */;
INSERT INTO `befriend` VALUES (1,2),(1,3),(1,4),(1,5),(1,6),(2,1),(2,3),(2,4),(2,5),(2,6),(3,1),(3,2),(4,1),(4,2),(5,1),(5,2),(6,1),(6,2);
/*!40000 ALTER TABLE `befriend` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book` (
  `bid` int(11) NOT NULL AUTO_INCREMENT,
  `bname` varchar(40) DEFAULT NULL,
  `genre` set('romance','mystery','science-fiction','nonfiction','fiction','horror') DEFAULT NULL,
  `avg_rating` float unsigned DEFAULT NULL,
  `aid` int(11) DEFAULT NULL,
  PRIMARY KEY (`bid`),
  KEY `aid` (`aid`),
  KEY `bname` (`bname`),
  CONSTRAINT `book_ibfk_1` FOREIGN KEY (`aid`) REFERENCES `author` (`aid`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES (1,'The Time Traveler\'s Wife','romance,science-fiction,fiction',0,1),(2,'Murder on the Orient Express','mystery,fiction',0,2),(3,'The Martian','science-fiction,fiction',0,3),(4,'Becoming','nonfiction',0,4),(5,'The Shining','fiction,horror',0,15),(6,'The Fault in Our Stars','romance,fiction',0,5),(7,'The Da Vinci Code','mystery,fiction',0,9),(8,'1984','science-fiction,fiction',0,6),(9,'The Diary of a Young Girl','nonfiction',0,7),(10,'Dracula','fiction,horror',0,8),(11,'The Notebook','romance,fiction',0,11),(12,'Angels & Demons','mystery,fiction',0,9),(13,'The Hunger Games','science-fiction,fiction',0,10),(14,'A Walk to Remember','romance,fiction',0,11),(15,'The Adventure of Sherlock Holmes','mystery,fiction',0,12),(16,'I,Robot','science-fiction,fiction',0,13),(17,'Educated','nonfiction',0,14),(18,'It','fiction,horror',0,15),(19,'Into the Wild','nonfiction',0,16),(20,'The Exorcist','fiction,horror',0,17);
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_on_shelf`
--

DROP TABLE IF EXISTS `book_on_shelf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `book_on_shelf` (
  `bid` int(11) NOT NULL DEFAULT '0',
  `shelf_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`bid`,`shelf_id`),
  KEY `shelf_id` (`shelf_id`),
  CONSTRAINT `book_on_shelf_ibfk_1` FOREIGN KEY (`bid`) REFERENCES `book` (`bid`) ON UPDATE CASCADE,
  CONSTRAINT `book_on_shelf_ibfk_2` FOREIGN KEY (`shelf_id`) REFERENCES `shelf` (`shelf_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_on_shelf`
--

LOCK TABLES `book_on_shelf` WRITE;
/*!40000 ALTER TABLE `book_on_shelf` DISABLE KEYS */;
INSERT INTO `book_on_shelf` VALUES (1,1),(1,7),(1,13),(2,5),(2,13),(2,18),(3,2),(3,6),(3,18),(4,11),(4,14),(4,16),(5,6),(6,1),(6,6),(6,7),(7,4),(7,5),(7,17),(8,2),(8,4),(8,9),(8,19),(9,9),(9,10),(10,2),(10,4),(11,4),(11,7),(11,12),(11,17),(12,2),(12,3),(12,20),(13,3),(13,8),(13,20),(14,1),(14,12),(14,17),(15,20),(16,11),(16,20),(17,9),(17,10),(18,20),(19,10),(19,14),(19,15),(19,20),(20,3),(20,15),(20,20);
/*!40000 ALTER TABLE `book_on_shelf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rate`
--

DROP TABLE IF EXISTS `rate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rate` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `bid` int(11) NOT NULL DEFAULT '0',
  `rate_date` date DEFAULT NULL,
  `rating` enum('0','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5') DEFAULT NULL,
  PRIMARY KEY (`uid`,`bid`),
  KEY `bid` (`bid`),
  CONSTRAINT `rate_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`) ON UPDATE CASCADE,
  CONSTRAINT `rate_ibfk_2` FOREIGN KEY (`bid`) REFERENCES `book` (`bid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rate`
--

LOCK TABLES `rate` WRITE;
/*!40000 ALTER TABLE `rate` DISABLE KEYS */;
/*!40000 ALTER TABLE `rate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reply`
--

DROP TABLE IF EXISTS `reply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reply` (
  `uid` int(11) NOT NULL DEFAULT '0',
  `rid` int(11) NOT NULL DEFAULT '0',
  `reply_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`uid`,`rid`,`reply_date`),
  KEY `rid` (`rid`),
  CONSTRAINT `reply_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`) ON UPDATE CASCADE,
  CONSTRAINT `reply_ibfk_2` FOREIGN KEY (`rid`) REFERENCES `review` (`rid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reply`
--

LOCK TABLES `reply` WRITE;
/*!40000 ALTER TABLE `reply` DISABLE KEYS */;
/*!40000 ALTER TABLE `reply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `review` (
  `uid` int(11) DEFAULT NULL,
  `bid` int(11) DEFAULT NULL,
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `rating` enum('0','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5') DEFAULT NULL,
  `content` varchar(400) DEFAULT NULL,
  `post_date` datetime DEFAULT NULL,
  PRIMARY KEY (`rid`),
  KEY `uid` (`uid`),
  KEY `bid` (`bid`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`) ON UPDATE CASCADE,
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`bid`) REFERENCES `book` (`bid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shelf`
--

DROP TABLE IF EXISTS `shelf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shelf` (
  `shelf_id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `shelf_name` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`shelf_id`),
  KEY `uid` (`uid`),
  CONSTRAINT `shelf_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shelf`
--

LOCK TABLES `shelf` WRITE;
/*!40000 ALTER TABLE `shelf` DISABLE KEYS */;
INSERT INTO `shelf` VALUES (1,1,'Romance'),(2,1,'Want to read'),(3,2,'Interested'),(4,3,'Want to read'),(5,4,'Mystery'),(6,5,'Book List'),(7,5,'romance'),(8,7,'recommended'),(9,8,'family'),(10,9,'book club'),(11,10,'book club'),(12,10,'Romance'),(13,11,'want to read'),(14,12,'March Reading List'),(15,13,'Interested'),(16,14,'Non-Fiction'),(17,15,'Nicholas Sparks'),(18,16,'Fiction'),(19,16,'Want to Read'),(20,17,'Interested'),(21,18,'Family List'),(22,19,'Book Club Wellesley'),(23,20,'Book Club December'),(24,20,'2022 Reading List');
/*!40000 ALTER TABLE `shelf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `uname` varchar(10) DEFAULT NULL,
  `bio` varchar(100) DEFAULT NULL,
  `fav_genres` set('romance','mystery','science-fiction','nonfiction','fiction','horror') DEFAULT NULL,
  PRIMARY KEY (`uid`),
  KEY `uname` (`uname`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'bc1','hello my name is becky',''),(2,'mchan6','hello my name is jenny',''),(3,'pw3','hello my name is penny',''),(4,'sllong99','hello I am silvia',''),(5,'tan10','my name is thomas',''),(6,'lisa230','my name is lisa',''),(7,'bella99','woof I am bella',''),(8,'belle12','hello I am belle',''),(9,'ronald_r','Ronald here!',''),(10,'potter78','Potter - not Harry Potter though',''),(11,'herm_g','Hermione is my favorite character in all the books!',''),(12,'weasley_r','I love the Weasley\'s family in Harry Potter. ',''),(13,'snowy22','This is Snowy',''),(14,'joe526','This is Joe',''),(15,'jason420','I am Jason',''),(16,'grace1030','Grace',''),(17,'wilson7','\"Wilson',''),(18,'wendy3','I am Wendy from Wellesley',''),(19,'kelly-m','Kelly',''),(20,'tom-ch','Tom',''),(21,'ducky','Ducky',''),(22,'squid4','Squid like Squid Game',''),(23,'jerry20','My name is Jerry',''),(24,'ct2','I am Charlie and I love reading books!',''),(25,'pd9','I am Pelham and I love to read!','');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-04-13 20:55:45
